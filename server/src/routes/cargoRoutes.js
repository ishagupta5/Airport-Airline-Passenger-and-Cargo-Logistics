import express from 'express';
import { z } from 'zod';
import { pool } from '../config/db.js';
import { authenticateToken, requireRole } from '../middleware/auth.js';

const router = express.Router();

// GET /api/cargo - Cargo shipments with filters
router.get('/', async (req, res, next) => {
  try {
    const { type, customs, flight } = req.query;

    let whereClauses = [];
    let params = [];

    if (type && type !== 'ALL') {
      whereClauses.push('cs.cargo_type = ?');
      params.push(type);
    }

    if (customs && customs !== 'ALL') {
      whereClauses.push('cs.customs_status = ?');
      params.push(customs);
    }

    if (flight) {
      whereClauses.push('f.flight_number = ?');
      params.push(flight);
    }

    const whereSql = whereClauses.length > 0 ? `WHERE ${whereClauses.join(' AND ')}` : '';

    const [rows] = await pool.query(
      `SELECT 
         cs.cargo_id,
         cs.air_waybill_number,
         cs.sender_name,
         cs.sender_contact,
         cs.receiver_name,
         cs.receiver_contact,
         cs.cargo_type,
         cs.weight_kg,
         cs.volume_m3,
         cs.declared_value,
         cs.freight_charge,
         cs.customs_status,
         cs.shipment_status,
         cs.booking_date,
         f.flight_number,
         fcm.loading_bay,
         fcm.loaded_at
       FROM cargo_shipments cs
       LEFT JOIN flight_cargo_manifest fcm ON cs.cargo_id = fcm.cargo_id
       LEFT JOIN flights f ON fcm.flight_id = f.flight_id
       ${whereSql}
       ORDER BY cs.cargo_id DESC`,
      params
    );

    res.json(rows);
  } catch (err) {
    next(err);
  }
});

// POST /api/cargo - Create new AWB shipment
const cargoSchema = z.object({
  sender_name: z.string().min(2),
  sender_contact: z.string().min(5),
  receiver_name: z.string().min(2),
  receiver_contact: z.string().min(5),
  cargo_type: z.enum(['General', 'Perishable', 'Fragile', 'Hazardous', 'Live Animals', 'Valuable']),
  weight_kg: z.number().positive(),
  volume_m3: z.number().positive(),
  declared_value: z.number().positive(),
  freight_charge: z.number().positive()
});

router.post('/', authenticateToken, requireRole('CargoHandler', 'Admin'), async (req, res, next) => {
  try {
    const data = cargoSchema.parse(req.body);
    const awb = `AWB-${Math.floor(100 + Math.random() * 900)}-${Math.floor(10000000 + Math.random() * 90000000)}`;

    const [result] = await pool.query(
      `INSERT INTO cargo_shipments 
       (air_waybill_number, sender_name, sender_contact, receiver_name, receiver_contact, 
        cargo_type, weight_kg, volume_m3, declared_value, freight_charge, customs_status, shipment_status)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'Pending Inspection', 'Booked')`,
      [
        awb, data.sender_name, data.sender_contact, data.receiver_name, data.receiver_contact,
        data.cargo_type, data.weight_kg, data.volume_m3, data.declared_value, data.freight_charge
      ]
    );

    res.status(201).json({
      message: 'Air Waybill registered successfully',
      cargo_id: result.insertId,
      air_waybill_number: awb
    });
  } catch (err) {
    next(err);
  }
});

// POST /api/cargo/:id/clear-customs - Customs Inspection Decision
const customsDecisionSchema = z.object({
  decision: z.enum(['Cleared', 'Held', 'Rejected']),
  reason: z.string().optional()
});

router.post('/:id/clear-customs', authenticateToken, requireRole('CustomsOfficer', 'Admin'), async (req, res, next) => {
  try {
    const cargoId = parseInt(req.params.id, 10);
    const { decision } = customsDecisionSchema.parse(req.body);

    await pool.query('CALL sp_clear_customs(?, ?, ?)', [cargoId, req.user.user_id, decision]);

    res.json({
      message: `Customs inspection updated to '${decision}'`,
      cargo_id: cargoId,
      customs_status: decision
    });
  } catch (err) {
    next(err);
  }
});

// POST /api/cargo/:id/manifest - Assign cargo to flight hold (checked against payload limits)
const manifestSchema = z.object({
  flight_id: z.number().int().positive(),
  loading_bay: z.string().min(2).default('Forward Hold 1')
});

router.post('/:id/manifest', authenticateToken, requireRole('CargoHandler', 'Admin'), async (req, res, next) => {
  try {
    const cargoId = parseInt(req.params.id, 10);
    const { flight_id, loading_bay } = manifestSchema.parse(req.body);

    await pool.query('CALL sp_load_cargo(?, ?, ?)', [flight_id, cargoId, loading_bay]);

    res.json({
      message: 'Cargo manifested and loaded onto aircraft hold successfully',
      cargo_id: cargoId,
      flight_id,
      loading_bay
    });
  } catch (err) {
    next(err);
  }
});

export default router;
