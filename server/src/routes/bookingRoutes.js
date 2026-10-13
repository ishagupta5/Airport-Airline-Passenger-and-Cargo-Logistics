import express from 'express';
import { z } from 'zod';
import { pool } from '../config/db.js';
import { optionalAuth, authenticateToken } from '../middleware/auth.js';

const router = express.Router();

const bookingSchema = z.object({
  passenger_id: z.number().int().positive().optional(),
  passenger: z.object({
    first_name: z.string().min(1),
    last_name: z.string().min(1),
    passport_number: z.string().min(3),
    nationality: z.string().min(2),
    date_of_birth: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
    gender: z.enum(['Male', 'Female', 'Other']),
    email: z.string().email(),
    phone: z.string().min(5)
  }).optional(),
  flight_id: z.number().int().positive(),
  seat_id: z.number().int().positive(),
  fare_amount: z.number().positive(),
  payment_method: z.enum(['Credit Card', 'Debit Card', 'UPI', 'Net Banking', 'Wire Transfer', 'Cash']).default('Credit Card')
});

// POST /api/bookings - Atomic reservation via sp_book_ticket
router.post('/', optionalAuth, async (req, res, next) => {
  const connection = await pool.getConnection();
  try {
    const data = bookingSchema.parse(req.body);

    let passengerId = data.passenger_id;

    // Auto-create passenger if passenger object is passed
    if (!passengerId && data.passenger) {
      const p = data.passenger;
      const [existing] = await connection.query(
        'SELECT passenger_id FROM passengers WHERE passport_number = ?',
        [p.passport_number]
      );

      if (existing.length > 0) {
        passengerId = existing[0].passenger_id;
      } else {
        const [insertRes] = await connection.query(
          `INSERT INTO passengers 
           (first_name, last_name, passport_number, nationality, date_of_birth, gender, email, phone) 
           VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
          [p.first_name, p.last_name, p.passport_number, p.nationality, p.date_of_birth, p.gender, p.email, p.phone]
        );
        passengerId = insertRes.insertId;
      }
    }

    if (!passengerId) {
      return res.status(400).json({ error: 'passenger_id or valid passenger details must be provided.' });
    }

    // Call stored procedure sp_book_ticket
    await connection.query(
      `CALL sp_book_ticket(?, ?, ?, ?, ?, @p_booking_id, @p_pnr, @p_ticket_id)`,
      [passengerId, data.flight_id, data.seat_id, data.fare_amount, data.payment_method]
    );

    const [outRows] = await connection.query(
      `SELECT @p_booking_id AS booking_id, @p_pnr AS pnr, @p_ticket_id AS ticket_id`
    );

    const bookingResult = outRows[0];

    res.status(201).json({
      message: 'Ticket booked successfully',
      booking_id: bookingResult.booking_id,
      pnr: bookingResult.pnr,
      ticket_id: bookingResult.ticket_id
    });
  } catch (err) {
    next(err);
  } finally {
    connection.release();
  }
});

// GET /api/bookings/:pnr
router.get('/:pnr', async (req, res, next) => {
  try {
    const pnr = req.params.pnr.trim().toUpperCase();

    const [rows] = await pool.query(
      `SELECT 
         b.booking_id,
         b.booking_reference AS pnr,
         b.booking_status,
         b.total_amount,
         b.booking_date,
         p.passenger_id,
         CONCAT(p.first_name, ' ', p.last_name) AS passenger_name,
         p.passport_number,
         p.email AS passenger_email,
         p.phone AS passenger_phone,
         p.loyalty_points,
         f.flight_id,
         f.flight_number,
         a.name AS airline_name,
         act.model_name AS aircraft_model,
         dep.iata_code AS origin,
         dep.city AS origin_city,
         arr.iata_code AS destination,
         arr.city AS destination_city,
         f.scheduled_departure,
         f.scheduled_arrival,
         IFNULL(g.gate_number, 'TBD') AS departure_gate,
         fs.seat_number,
         fs.cabin_class,
         ts.fare_amount,
         bp.boarding_pass_id,
         bp.sequence_number,
         bp.boarding_time
       FROM bookings b
       JOIN passengers p ON b.passenger_id = p.passenger_id
       JOIN flights f ON b.flight_id = f.flight_id
       JOIN airlines a ON f.airline_id = a.airline_id
       JOIN aircraft ac ON f.aircraft_id = ac.aircraft_id
       JOIN aircraft_types act ON ac.type_id = act.type_id
       JOIN airports dep ON f.departure_airport_id = dep.airport_id
       JOIN airports arr ON f.arrival_airport_id = arr.airport_id
       LEFT JOIN gates g ON f.departure_gate_id = g.gate_id
       LEFT JOIN ticket_seats ts ON b.booking_id = ts.booking_id
       LEFT JOIN flight_seats fs ON ts.seat_id = fs.seat_id
       LEFT JOIN boarding_passes bp ON b.booking_id = bp.booking_id
       WHERE b.booking_reference = ?`,
      [pnr]
    );

    if (rows.length === 0) {
      return res.status(404).json({ error: `Booking reference '${pnr}' not found in database.` });
    }

    const booking = rows[0];

    // Fetch baggage list
    const [baggageRows] = await pool.query(
      `SELECT baggage_id, tag_number, weight_kg, status, is_excess_weight, excess_fee
       FROM baggage
       WHERE booking_id = ?`,
      [booking.booking_id]
    );

    booking.baggage = baggageRows;

    res.json(booking);
  } catch (err) {
    next(err);
  }
});

// POST /api/bookings/:pnr/check-in
router.post('/:pnr/check-in', async (req, res, next) => {
  const connection = await pool.getConnection();
  try {
    const pnr = req.params.pnr.trim().toUpperCase();

    const [rows] = await connection.query(
      'SELECT booking_id, booking_status FROM bookings WHERE booking_reference = ?',
      [pnr]
    );

    if (rows.length === 0) {
      return res.status(404).json({ error: `Booking '${pnr}' not found.` });
    }

    const booking = rows[0];

    // Execute stored procedure sp_check_in
    await connection.query('CALL sp_check_in(?, @p_bp_id)', [booking.booking_id]);

    const [out] = await connection.query('SELECT @p_bp_id AS boarding_pass_id');

    res.json({
      message: 'Check-in completed successfully',
      booking_status: 'Checked-In',
      boarding_pass_id: out[0].boarding_pass_id
    });
  } catch (err) {
    next(err);
  } finally {
    connection.release();
  }
});

// GET /api/bookings/:pnr/boarding-pass
router.get('/:pnr/boarding-pass', async (req, res, next) => {
  try {
    const pnr = req.params.pnr.trim().toUpperCase();

    const [rows] = await pool.query(
      `SELECT 
         bp.boarding_pass_id,
         bp.sequence_number,
         bp.boarding_time,
         bp.issued_at,
         b.booking_reference AS pnr,
         CONCAT(p.first_name, ' ', p.last_name) AS passenger_name,
         p.passport_number,
         f.flight_number,
         a.name AS airline_name,
         a.iata_code AS airline_iata,
         dep.iata_code AS origin_iata,
         dep.city AS origin_city,
         arr.iata_code AS destination_iata,
         arr.city AS destination_city,
         IFNULL(g.gate_number, 'Gate 14') AS departure_gate,
         fs.seat_number,
         fs.cabin_class
       FROM boarding_passes bp
       JOIN bookings b ON bp.booking_id = b.booking_id
       JOIN passengers p ON b.passenger_id = p.passenger_id
       JOIN ticket_seats ts ON bp.ticket_id = ts.ticket_id
       JOIN flight_seats fs ON ts.seat_id = fs.seat_id
       JOIN flights f ON b.flight_id = f.flight_id
       JOIN airlines a ON f.airline_id = a.airline_id
       JOIN airports dep ON f.departure_airport_id = dep.airport_id
       JOIN airports arr ON f.arrival_airport_id = arr.airport_id
       LEFT JOIN gates g ON bp.gate_id = g.gate_id
       WHERE b.booking_reference = ?`,
      [pnr]
    );

    if (rows.length === 0) {
      return res.status(404).json({ error: `Boarding pass not issued yet for PNR '${pnr}'. Please check-in first.` });
    }

    res.json(rows[0]);
  } catch (err) {
    next(err);
  }
});

export default router;
