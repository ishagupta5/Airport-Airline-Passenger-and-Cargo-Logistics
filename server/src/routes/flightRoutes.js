import express from 'express';
import { z } from 'zod';
import { pool, queryWithUser } from '../config/db.js';
import { authenticateToken, requireRole } from '../middleware/auth.js';

const router = express.Router();

// GET /api/flights with filters
router.get('/', async (req, res, next) => {
  try {
    const { origin, dest, carrier, date, status, page = 1, limit = 20 } = req.query;
    const offset = (Math.max(1, parseInt(page, 10)) - 1) * parseInt(limit, 10);

    let whereClauses = [];
    let queryParams = [];

    if (origin && origin !== 'ALL') {
      whereClauses.push('dep.iata_code = ?');
      queryParams.push(origin);
    }

    if (dest && dest !== 'ALL') {
      whereClauses.push('arr.iata_code = ?');
      queryParams.push(dest);
    }

    if (carrier && carrier !== 'ALL') {
      whereClauses.push('a.name LIKE ?');
      queryParams.push(`%${carrier}%`);
    }

    if (date) {
      whereClauses.push('DATE(f.scheduled_departure) = ?');
      queryParams.push(date);
    }

    if (status && status !== 'ALL') {
      whereClauses.push('f.status = ?');
      queryParams.push(status);
    }

    const whereSql = whereClauses.length > 0 ? `WHERE ${whereClauses.join(' AND ')}` : '';

    const [countRows] = await pool.query(
      `SELECT COUNT(*) AS total
       FROM flights f
       JOIN airlines a ON f.airline_id = a.airline_id
       JOIN airports dep ON f.departure_airport_id = dep.airport_id
       JOIN airports arr ON f.arrival_airport_id = arr.airport_id
       ${whereSql}`,
      queryParams
    );

    const total = countRows[0].total;

    const [rows] = await pool.query(
      `SELECT 
         f.flight_id,
         f.flight_number,
         a.name AS airline_name,
         a.iata_code AS airline_iata,
         ac.tail_number,
         act.model_name AS aircraft_model,
         dep.iata_code AS origin,
         dep.city AS origin_city,
         dep.timezone AS origin_timezone,
         arr.iata_code AS destination,
         arr.city AS destination_city,
         arr.timezone AS destination_timezone,
         IFNULL(g_dep.gate_number, 'TBD') AS departure_gate,
         IFNULL(g_arr.gate_number, 'TBD') AS arrival_gate,
         f.scheduled_departure,
         f.scheduled_arrival,
         f.actual_departure,
         f.actual_arrival,
         ROUND(TIMESTAMPDIFF(MINUTE, f.scheduled_departure, f.scheduled_arrival) / 60.0, 1) AS duration_hours,
         f.allows_dgr,
         f.status,
         f.delay_reason
       FROM flights f
       JOIN airlines a ON f.airline_id = a.airline_id
       JOIN aircraft ac ON f.aircraft_id = ac.aircraft_id
       JOIN aircraft_types act ON ac.type_id = act.type_id
       JOIN airports dep ON f.departure_airport_id = dep.airport_id
       JOIN airports arr ON f.arrival_airport_id = arr.airport_id
       LEFT JOIN gates g_dep ON f.departure_gate_id = g_dep.gate_id
       LEFT JOIN gates g_arr ON f.arrival_gate_id = g_arr.gate_id
       ${whereSql}
       ORDER BY f.scheduled_departure ASC
       LIMIT ? OFFSET ?`,
      [...queryParams, parseInt(limit, 10), offset]
    );

    res.json({
      flights: rows,
      pagination: {
        total,
        page: parseInt(page, 10),
        limit: parseInt(limit, 10),
        totalPages: Math.ceil(total / parseInt(limit, 10))
      }
    });
  } catch (err) {
    next(err);
  }
});

// GET /api/flights/:id
router.get('/:id', async (req, res, next) => {
  try {
    const flightId = parseInt(req.params.id, 10);
    const [rows] = await pool.query(
      `SELECT 
         f.flight_id, f.flight_number, a.name AS airline_name, act.model_name AS aircraft_model,
         dep.iata_code AS origin, dep.city AS origin_city,
         arr.iata_code AS destination, arr.city AS destination_city,
         IFNULL(g.gate_number, 'TBD') AS departure_gate,
         f.scheduled_departure, f.scheduled_arrival, f.status, f.delay_reason
       FROM flights f
       JOIN airlines a ON f.airline_id = a.airline_id
       JOIN aircraft ac ON f.aircraft_id = ac.aircraft_id
       JOIN aircraft_types act ON ac.type_id = act.type_id
       JOIN airports dep ON f.departure_airport_id = dep.airport_id
       JOIN airports arr ON f.arrival_airport_id = arr.airport_id
       LEFT JOIN gates g ON f.departure_gate_id = g.gate_id
       WHERE f.flight_id = ?`,
      [flightId]
    );

    if (rows.length === 0) {
      return res.status(404).json({ error: 'Flight not found' });
    }

    res.json(rows[0]);
  } catch (err) {
    next(err);
  }
});

// GET /api/flights/:id/seats - Returns real cabin occupancy for THAT specific flight
router.get('/:id/seats', async (req, res, next) => {
  try {
    const flightId = parseInt(req.params.id, 10);

    // Get aircraft model
    const [flightRows] = await pool.query(
      `SELECT f.flight_id, f.flight_number, f.aircraft_id, act.model_name
       FROM flights f
       JOIN aircraft ac ON f.aircraft_id = ac.aircraft_id
       JOIN aircraft_types act ON ac.type_id = act.type_id
       WHERE f.flight_id = ?`,
      [flightId]
    );

    if (flightRows.length === 0) {
      return res.status(404).json({ error: 'Flight not found' });
    }

    const flight = flightRows[0];

    // Get all seats for this aircraft, joined with occupied status on THIS flight
    const [seats] = await pool.query(
      `SELECT 
         fs.seat_id,
         fs.seat_number,
         fs.cabin_class,
         fs.is_exit_row,
         CASE WHEN ts.ticket_id IS NOT NULL THEN TRUE ELSE FALSE END AS is_occupied,
         ts.booking_id
       FROM flight_seats fs
       LEFT JOIN ticket_seats ts 
         ON fs.seat_id = ts.seat_id 
         AND ts.flight_id = ? 
         AND ts.status <> 'Cancelled'
       WHERE fs.aircraft_id = ?
       ORDER BY fs.cabin_class DESC, fs.seat_number ASC`,
      [flightId, flight.aircraft_id]
    );

    res.json({
      flight_id: flight.flight_id,
      flight_number: flight.flight_number,
      aircraft_model: flight.model_name,
      total_seats: seats.length,
      available_seats: seats.filter(s => !s.is_occupied).length,
      seats
    });
  } catch (err) {
    next(err);
  }
});

// PATCH /api/flights/:id/status
const updateStatusSchema = z.object({
  status: z.enum(['Scheduled', 'Boarding', 'In-Air', 'Delayed', 'Cancelled', 'Arrived']),
  delay_reason: z.string().optional()
});

router.patch('/:id/status', authenticateToken, requireRole('AirlineStaff', 'Admin'), async (req, res, next) => {
  try {
    const flightId = parseInt(req.params.id, 10);
    const { status, delay_reason } = updateStatusSchema.parse(req.body);

    const [result] = await queryWithUser(
      req.user.user_id,
      `UPDATE flights 
       SET status = ?, delay_reason = ? 
       WHERE flight_id = ?`,
      [status, delay_reason || null, flightId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Flight not found' });
    }

    res.json({ message: 'Flight status updated successfully', status, delay_reason });
  } catch (err) {
    next(err);
  }
});

export default router;
