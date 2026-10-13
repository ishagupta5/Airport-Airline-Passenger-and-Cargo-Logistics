import express from 'express';
import { z } from 'zod';
import { pool } from '../config/db.js';
import { authenticateToken, requireRole } from '../middleware/auth.js';

const router = express.Router();

// GET /api/baggage - Search by tag or list recent
router.get('/', async (req, res, next) => {
  try {
    const { tag, booking_id } = req.query;

    let query = `
      SELECT 
        bg.baggage_id, bg.booking_id, bg.tag_number, bg.weight_kg, bg.status, 
        bg.is_excess_weight, bg.excess_fee,
        b.booking_reference, f.flight_number,
        CONCAT(p.first_name, ' ', p.last_name) AS passenger_name
      FROM baggage bg
      JOIN bookings b ON bg.booking_id = b.booking_id
      JOIN passengers p ON b.passenger_id = p.passenger_id
      JOIN flights f ON b.flight_id = f.flight_id
    `;
    const params = [];

    if (tag) {
      query += ' WHERE bg.tag_number = ?';
      params.push(tag);
    } else if (booking_id) {
      query += ' WHERE bg.booking_id = ?';
      params.push(parseInt(booking_id, 10));
    } else {
      query += ' ORDER BY bg.baggage_id DESC LIMIT 50';
    }

    const [rows] = await pool.query(query, params);
    res.json(rows);
  } catch (err) {
    next(err);
  }
});

// POST /api/baggage - Check in baggage with weight verification & excess fee
const baggageSchema = z.object({
  booking_id: z.number().int().positive(),
  weight_kg: z.number().positive(),
  is_international: z.boolean().default(false)
});

router.post('/', authenticateToken, requireRole('GroundStaff', 'Admin'), async (req, res, next) => {
  try {
    const { booking_id, weight_kg, is_international } = baggageSchema.parse(req.body);

    // Limit: 15kg for domestic, 23kg for international
    const maxFreeWeight = is_international ? 23.0 : 15.0;
    const isExcess = weight_kg > maxFreeWeight;
    const excessKg = isExcess ? (weight_kg - maxFreeWeight) : 0;
    const excessFee = isExcess ? Math.round(excessKg * 500) : 0; // 500 INR per kg

    // Generate Tag Number: BAG-<AIRLINE>-<RANDOM>
    const tagNumber = `BAG-TAG-${Math.floor(100000 + Math.random() * 900000)}`;

    const [result] = await pool.query(
      `INSERT INTO baggage (booking_id, tag_number, weight_kg, status, is_excess_weight, excess_fee)
       VALUES (?, ?, ?, 'Checked-In', ?, ?)`,
      [booking_id, tagNumber, weight_kg, isExcess, excessFee]
    );

    res.status(201).json({
      message: 'Baggage checked in successfully',
      baggage_id: result.insertId,
      tag_number: tagNumber,
      weight_kg,
      is_excess_weight: isExcess,
      excess_fee: excessFee
    });
  } catch (err) {
    next(err);
  }
});

export default router;
