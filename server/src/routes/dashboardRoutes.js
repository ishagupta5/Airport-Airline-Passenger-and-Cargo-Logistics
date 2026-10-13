import express from 'express';
import { pool } from '../config/db.js';

const router = express.Router();

router.get('/stats', async (req, res, next) => {
  try {
    // 1. Active flights today
    const [flightsTodayRows] = await pool.query(
      `SELECT COUNT(*) AS active_flights_count 
       FROM flights 
       WHERE DATE(scheduled_departure) = CURDATE() 
         AND status NOT IN ('Cancelled')`
    );

    // 2. Passengers Checked-In
    const [checkedInRows] = await pool.query(
      `SELECT COUNT(*) AS checked_in_count 
       FROM bookings 
       WHERE booking_status = 'Checked-In'`
    );

    // 3. Manifested Cargo (in Tons and kg)
    const [cargoRows] = await pool.query(
      `SELECT IFNULL(SUM(cs.weight_kg), 0) AS total_manifested_kg,
              COUNT(fcm.manifest_id) AS total_manifested_items
       FROM flight_cargo_manifest fcm
       JOIN cargo_shipments cs ON fcm.cargo_id = cs.cargo_id`
    );

    // 4. Customs Cleared percentage
    const [customsRows] = await pool.query(
      `SELECT 
         COUNT(*) AS total_shipments,
         SUM(CASE WHEN customs_status = 'Cleared' THEN 1 ELSE 0 END) AS cleared_shipments
       FROM cargo_shipments`
    );

    const totalShipments = customsRows[0].total_shipments || 0;
    const clearedShipments = customsRows[0].cleared_shipments || 0;
    const customsClearedPct = totalShipments > 0 ? Math.round((clearedShipments / totalShipments) * 100) : 0;

    // 5. Gate Utilization Rate
    const [gateStatsRows] = await pool.query(
      `SELECT 
         (SELECT COUNT(*) FROM gates WHERE is_operational = TRUE) AS total_gates,
         (SELECT COUNT(DISTINCT departure_gate_id) 
          FROM flights 
          WHERE DATE(scheduled_departure) = CURDATE() 
            AND status NOT IN ('Cancelled', 'Arrived') 
            AND departure_gate_id IS NOT NULL) AS active_assigned_gates`
    );

    const totalGates = gateStatsRows[0].total_gates || 1;
    const activeGates = gateStatsRows[0].active_assigned_gates || 0;
    const gateUtilizationPct = Math.round((activeGates / totalGates) * 100);

    // 6. Gate Conflicts (same gate used by two flights within 45 min)
    const [conflictRows] = await pool.query(
      `SELECT COUNT(*) AS conflict_count
       FROM flights f1
       JOIN flights f2 ON f1.departure_gate_id = f2.departure_gate_id
         AND f1.flight_id < f2.flight_id
         AND f1.status NOT IN ('Cancelled', 'Arrived')
         AND f2.status NOT IN ('Cancelled', 'Arrived')
         AND ABS(TIMESTAMPDIFF(MINUTE, f1.scheduled_departure, f2.scheduled_departure)) < 45`
    );

    res.json({
      activeFlightsToday: flightsTodayRows[0].active_flights_count,
      passengersCheckedIn: checkedInRows[0].checked_in_count,
      manifestedCargoKg: parseFloat(cargoRows[0].total_manifested_kg),
      manifestedCargoTons: (parseFloat(cargoRows[0].total_manifested_kg) / 1000).toFixed(1),
      manifestedItemsCount: cargoRows[0].total_manifested_items,
      customsClearedPercentage: customsClearedPct,
      gateUtilizationPercentage: gateUtilizationPct,
      gateConflictsCount: conflictRows[0].conflict_count,
      timestamp: new Date().toISOString()
    });
  } catch (err) {
    next(err);
  }
});

export default router;
