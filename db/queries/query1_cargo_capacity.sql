-- Query 1: Flight Cargo Payload & Volume Capacity Utilization
-- Computes manifested weight and remaining payload capacity per flight
SELECT 
    f.flight_id,
    f.flight_number,
    a.name AS airline_name,
    act.model_name AS aircraft_model,
    act.max_cargo_weight_kg AS max_allowed_weight_kg,
    IFNULL(SUM(cs.weight_kg), 0.00) AS total_manifested_cargo_weight_kg,
    (act.max_cargo_weight_kg - IFNULL(SUM(cs.weight_kg), 0.00)) AS remaining_cargo_capacity_kg,
    ROUND((IFNULL(SUM(cs.weight_kg), 0.00) / act.max_cargo_weight_kg) * 100, 2) AS cargo_weight_utilization_pct
FROM flights f
JOIN airlines a ON f.airline_id = a.airline_id
JOIN aircraft ac ON f.aircraft_id = ac.aircraft_id
JOIN aircraft_types act ON ac.type_id = act.type_id
LEFT JOIN flight_cargo_manifest fcm ON f.flight_id = fcm.flight_id
LEFT JOIN cargo_shipments cs ON fcm.cargo_id = cs.cargo_id
GROUP BY f.flight_id, f.flight_number, a.name, act.model_name, act.max_cargo_weight_kg
ORDER BY cargo_weight_utilization_pct DESC;
