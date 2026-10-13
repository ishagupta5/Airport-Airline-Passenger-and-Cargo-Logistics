import express from 'express';
import { pool } from '../config/db.js';

const router = express.Router();

// GET /api/crew/duty-audit - Enforces 14h aviation rule with soft-warning tiers
router.get('/duty-audit', async (req, res, next) => {
  try {
    const [rows] = await pool.query(
      `SELECT 
         cm.crew_id,
         cm.employee_code,
         CONCAT(cm.first_name, ' ', cm.last_name) AS crew_name,
         cm.role,
         cm.license_number,
         al.name AS airline_name,
         f.flight_id,
         f.flight_number,
         fca.duty_start,
         fca.duty_end,
         fca.duty_hours,
         fca.assignment_status,
         CASE 
           WHEN fca.duty_hours > 12.00 THEN 'CRITICAL: REST REQUIRED'
           WHEN fca.duty_hours > 10.00 THEN 'WARNING: APPROACHING LIMIT'
           ELSE 'NORMAL'
         END AS duty_safety_status
       FROM flight_crew_assignments fca
       JOIN crew_members cm ON fca.crew_id = cm.crew_id
       JOIN airlines al ON cm.airline_id = al.airline_id
       JOIN flights f ON fca.flight_id = f.flight_id
       ORDER BY fca.duty_hours DESC`
    );

    res.json(rows);
  } catch (err) {
    next(err);
  }
});

export default router;
