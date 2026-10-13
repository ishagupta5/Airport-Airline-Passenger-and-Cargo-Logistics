-- Query 2: Passenger Complete Flight Itinerary & Checked Baggage Audit
-- Unifies passenger, booking, flight, gate, boarding pass, and baggage details
SELECT 
    p.passenger_id,
    CONCAT(p.first_name, ' ', p.last_name) AS passenger_name,
    p.passport_number,
    b.booking_reference AS pnr_code,
    b.booking_status,
    f.flight_number,
    dep.iata_code AS origin,
    arr.iata_code AS destination,
    IFNULL(bp.sequence_number, 0) AS boarding_seq,
    IFNULL(bg.tag_number, 'NO BAGGAGE') AS baggage_tag,
    IFNULL(bg.weight_kg, 0.00) AS baggage_weight_kg,
    IFNULL(bg.status, 'N/A') AS baggage_status
FROM passengers p
JOIN bookings b ON p.passenger_id = b.passenger_id
JOIN flights f ON b.flight_id = f.flight_id
JOIN airports dep ON f.departure_airport_id = dep.airport_id
JOIN airports arr ON f.arrival_airport_id = arr.airport_id
LEFT JOIN boarding_passes bp ON b.booking_id = bp.booking_id
LEFT JOIN baggage bg ON b.booking_id = bg.booking_id
WHERE b.booking_status IN ('Confirmed', 'Checked-In')
ORDER BY p.passenger_id, f.scheduled_departure;
