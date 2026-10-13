import express from 'express';
import { z } from 'zod';
import { pool } from '../config/db.js';
import { authenticateToken, requireRole } from '../middleware/auth.js';

const router = express.Router();

// GET /api/fleet - Full fleet list with model and maintenance status
router.get('/', async (req, res, next) => {
  try {
    const [rows] = await pool.query(
      `SELECT 
         ac.aircraft_id,
         ac.tail_number,
         a.name AS airline_name,
         a.iata_code AS airline_iata,
         act.model_name,
         act.passenger_capacity,
         act.max_cargo_weight_kg,
         ac.manufacture_year,
         ac.total_flight_hours,
         ac.status,
         (SELECT status FROM aircraft_maintenance 
          WHERE aircraft_id = ac.aircraft_id 
          ORDER BY started_at DESC LIMIT 1) AS last_maintenance_status
       FROM aircraft ac
       JOIN airlines a ON ac.airline_id = a.airline_id
       JOIN aircraft_types act ON ac.type_id = act.type_id
       ORDER BY ac.aircraft_id ASC`
    );

    res.json(rows);
  } catch (err) {
    next(err);
  }
});

// GET /api/fleet/:tail/maintenance - Maintenance logs for specific aircraft
router.get('/:tail/maintenance', async (req, res, next) => {
  try {
    const tail = req.params.tail.trim();

    const [aircraft] = await pool.query(
      'SELECT aircraft_id, tail_number FROM aircraft WHERE tail_number = ?',
      [tail]
    );

    if (aircraft.length === 0) {
      return res.status(404).json({ error: `Aircraft with tail number '${tail}' not found.` });
    }

    const [logs] = await pool.query(
      `SELECT 
         maintenance_id, maintenance_type, started_at, completed_at, 
         performed_by, description, cost, status
       FROM aircraft_maintenance
       WHERE aircraft_id = ?
       ORDER BY started_at DESC`,
      [aircraft[0].aircraft_id]
    );

    res.json({
      tail_number: tail,
      maintenance_records: logs
    });
  } catch (err) {
    next(err);
  }
});

// POST /api/fleet/:tail/maintenance - Schedule maintenance
const maintenanceSchema = z.object({
  maintenance_type: z.enum(['Routine Inspection', 'Engine Overhaul', 'Avionics Check', 'C-Check', 'Emergency Repair']),
  performed_by: z.string().min(2),
  description: z.string().min(5),
  cost: z.number().nonnegative().default(0)
});

router.post('/:tail/maintenance', authenticateToken, requireRole('AirlineStaff', 'Admin'), async (req, res, next) => {
  try {
    const tail = req.params.tail.trim();
    const data = maintenanceSchema.parse(req.body);

    const [aircraft] = await pool.query(
      'SELECT aircraft_id FROM aircraft WHERE tail_number = ?',
      [tail]
    );

    if (aircraft.length === 0) {
      return res.status(404).json({ error: 'Aircraft not found' });
    }

    const [result] = await pool.query(
      `INSERT INTO aircraft_maintenance 
       (aircraft_id, maintenance_type, started_at, performed_by, description, cost, status)
       VALUES (?, ?, NOW(), ?, ?, ?, 'In Progress')`,
      [aircraft[0].aircraft_id, data.maintenance_type, data.performed_by, data.description, data.cost]
    );

    // Update aircraft status to 'In Maintenance'
    await pool.query('UPDATE aircraft SET status = "In Maintenance" WHERE aircraft_id = ?', [aircraft[0].aircraft_id]);

    res.status(201).json({
      message: 'Maintenance scheduled and aircraft grounded for inspection',
      maintenance_id: result.insertId
    });
  } catch (err) {
    next(err);
  }
});

export default router;
