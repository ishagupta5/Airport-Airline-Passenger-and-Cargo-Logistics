import express from 'express';
import { pool } from '../config/db.js';
import { authenticateToken, requireRole } from '../middleware/auth.js';

const router = express.Router();

// GET /api/audit-logs - Admin access only
router.get('/', authenticateToken, requireRole('Admin'), async (req, res, next) => {
  try {
    const limit = parseInt(req.query.limit || '100', 10);

    const [rows] = await pool.query(
      `SELECT 
         al.log_id,
         al.user_id,
         u.username,
         u.full_name AS user_full_name,
         u.user_role,
         al.action_type,
         al.entity_table,
         al.entity_id,
         al.old_value,
         al.new_value,
         al.ip_address,
         al.logged_at
       FROM audit_logs al
       LEFT JOIN system_users u ON al.user_id = u.user_id
       ORDER BY al.log_id DESC
       LIMIT ?`,
      [limit]
    );

    res.json(rows);
  } catch (err) {
    next(err);
  }
});

export default router;
