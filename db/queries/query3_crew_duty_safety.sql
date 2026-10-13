-- Query 3: Flight Crew Duty Hour Exceedance & Safety Audit
-- Audits crew duty hours enforcing the 14-hour safety rule with Warning (>10h) and Critical (>12h) tiers
SELECT 
    cm.employee_code,
    CONCAT(cm.first_name, ' ', cm.last_name) AS crew_name,
    cm.role,
    al.name AS airline_name,
    f.flight_number,
    fca.duty_start,
    fca.duty_end,
    fca.duty_hours,
    CASE 
        WHEN fca.duty_hours > 12.00 THEN 'CRITICAL: REST REQUIRED'
        WHEN fca.duty_hours > 10.00 THEN 'WARNING: APPROACHING LIMIT'
        ELSE 'NORMAL'
    END AS duty_safety_status
FROM flight_crew_assignments fca
JOIN crew_members cm ON fca.crew_id = cm.crew_id
JOIN airlines al ON cm.airline_id = al.airline_id
JOIN flights f ON fca.flight_id = f.flight_id
ORDER BY fca.duty_hours DESC;
