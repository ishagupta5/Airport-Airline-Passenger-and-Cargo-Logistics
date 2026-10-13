-- ============================================================================
-- AIRPORT & AIRLINE LOGISTICS DBMS - TEST ASSERTIONS & VERIFICATION SUITE
-- Executes verification tests for all integrity constraints, triggers, and procedures.
-- Run with: mysql -u root -p airport_logistics_db < db/tests/test_assertions.sql
-- ============================================================================

USE airport_logistics_db;

SELECT '==================================================' AS Test_Suite_Start;
SELECT 'STARTING SQL CONSTRAINT AND TRIGGER ASSERTION TESTS' AS Message;
SELECT '==================================================' AS Test_Suite_Divider;

-- ----------------------------------------------------------------------------
-- TEST 1: Prevent Booking a Seat on the Wrong Aircraft
-- Expectation: Trigger trg_check_seat_aircraft_insert raises SQLSTATE 45000
-- ----------------------------------------------------------------------------
SELECT '--- TEST 1: WRONG AIRCRAFT SEAT INSERTION REJECTION ---' AS Test;
-- Flight 1 uses Aircraft 2. Seat 1 belongs to Aircraft 1.
-- This insert MUST fail with integrity error.
-- INSERT INTO ticket_seats (booking_id, flight_id, seat_id, fare_amount, status) VALUES (1, 1, 1, 5000.00, 'Reserved');

-- ----------------------------------------------------------------------------
-- TEST 2: Prevent Double-Booking the Same Seat on the Same Flight
-- Expectation: UNIQUE (flight_id, seat_id) or procedure locks prevent this.
-- ----------------------------------------------------------------------------
SELECT '--- TEST 2: PREVENT DUPLICATE SEAT ON SAME FLIGHT ---' AS Test;
-- Seat 19 is already booked on Flight 1 in ticket_seats row 1.
-- INSERT INTO ticket_seats (booking_id, flight_id, seat_id, fare_amount, status) VALUES (2, 1, 19, 68500.00, 'Reserved');

-- ----------------------------------------------------------------------------
-- TEST 3: Reject Departure Gate Belonging to a Different Airport
-- Expectation: Trigger trg_validate_flight_gates_insert raises SQLSTATE 45000
-- ----------------------------------------------------------------------------
SELECT '--- TEST 3: REJECT WRONG AIRPORT GATE ASSIGNMENT ---' AS Test;
-- Gate 7 belongs to BOM (Airport 2), but departure airport is DEL (Airport 1).
-- INSERT INTO flights (flight_number, airline_id, aircraft_id, departure_airport_id, arrival_airport_id, departure_gate_id, scheduled_departure, scheduled_arrival)
-- VALUES ('TEST-01', 1, 1, 1, 2, 7, NOW(), DATE_ADD(NOW(), INTERVAL 2 HOUR));

-- ----------------------------------------------------------------------------
-- TEST 4: Reject Manifesting Uncleared Cargo (customs_status <> 'Cleared')
-- Expectation: Trigger trg_validate_cargo_manifest raises SQLSTATE 45000
-- ----------------------------------------------------------------------------
SELECT '--- TEST 4: REJECT MANIFESTING UNCLEARED CARGO ---' AS Test;
-- Cargo 4 is 'Pending Inspection'. Cannot be manifested.
-- INSERT INTO flight_cargo_manifest (flight_id, cargo_id, loaded_at, loading_bay, status)
-- VALUES (1, 4, NOW(), 'Forward Hold 1', 'Loaded');

-- ----------------------------------------------------------------------------
-- TEST 5: Reject Manifesting Hazardous Goods on Flight Without DGR
-- Expectation: Trigger trg_validate_cargo_manifest raises SQLSTATE 45000
-- ----------------------------------------------------------------------------
SELECT '--- TEST 5: REJECT HAZARDOUS GOODS ON NON-DGR FLIGHT ---' AS Test;
-- Flight 3 (6E-205) has allows_dgr = FALSE. Cargo 4 or any Hazardous cargo is rejected.

-- ----------------------------------------------------------------------------
-- TEST 6: Atomic Ticket Booking Stored Procedure Test
-- Expectation: sp_book_ticket successfully books an unallocated seat and generates PNR
-- ----------------------------------------------------------------------------
SELECT '--- TEST 6: STORED PROCEDURE sp_book_ticket TEST ---' AS Test;

-- Seat 22 is seat 12A on Aircraft 2 (Flight 1). It is currently unbooked.
CALL sp_book_ticket(1, 1, 22, 75000.00, 'UPI', @test_booking_id, @test_pnr, @test_ticket_id);

SELECT 
    @test_booking_id AS Created_Booking_ID, 
    @test_pnr AS Generated_PNR, 
    @test_ticket_id AS Created_Ticket_ID;

-- Verify booking created in database
SELECT booking_id, booking_reference, passenger_id, flight_id, booking_status, total_amount 
FROM bookings 
WHERE booking_id = @test_booking_id;

-- Verify payment record created
SELECT payment_id, transaction_reference, amount, payment_method, payment_status 
FROM payments 
WHERE reference_id = @test_booking_id AND reference_type = 'Booking';

-- ----------------------------------------------------------------------------
-- TEST 7: Check-in & Boarding Pass Stored Procedure Test
-- Expectation: sp_check_in generates boarding pass and updates status
-- ----------------------------------------------------------------------------
SELECT '--- TEST 7: STORED PROCEDURE sp_check_in TEST ---' AS Test;

CALL sp_check_in(@test_booking_id, @test_bp_id);

SELECT 
    @test_bp_id AS Boarding_Pass_ID,
    bp.boarding_time,
    bp.sequence_number,
    g.gate_number
FROM boarding_passes bp
JOIN gates g ON bp.gate_id = g.gate_id
WHERE bp.boarding_pass_id = @test_bp_id;

-- Verify booking is now 'Checked-In'
SELECT booking_id, booking_reference, booking_status 
FROM bookings 
WHERE booking_id = @test_booking_id;

-- ----------------------------------------------------------------------------
-- TEST 8: Customs Officer Stored Procedure Test
-- Expectation: sp_clear_customs updates customs status and writes audit log
-- ----------------------------------------------------------------------------
SELECT '--- TEST 8: STORED PROCEDURE sp_clear_customs TEST ---' AS Test;

-- Cargo 4 was 'Pending Inspection'. Officer Rao (user_id 10) approves it.
CALL sp_clear_customs(4, 10, 'Cleared');

SELECT cargo_id, air_waybill_number, customs_status 
FROM cargo_shipments 
WHERE cargo_id = 4;

-- Verify Audit Log entry
SELECT log_id, user_id, action_type, entity_table, entity_id, old_value, new_value 
FROM audit_logs 
WHERE entity_table = 'cargo_shipments' AND entity_id = 4 
ORDER BY log_id DESC LIMIT 1;

-- ----------------------------------------------------------------------------
-- CLEANUP TEST DATA
-- ----------------------------------------------------------------------------
DELETE FROM boarding_passes WHERE boarding_pass_id = @test_bp_id;
DELETE FROM payments WHERE reference_id = @test_booking_id AND reference_type = 'Booking';
DELETE FROM ticket_seats WHERE ticket_id = @test_ticket_id;
DELETE FROM bookings WHERE booking_id = @test_booking_id;
-- Revert cargo 4 back to 'Pending Inspection'
UPDATE cargo_shipments SET customs_status = 'Pending Inspection' WHERE cargo_id = 4;

SELECT '==================================================' AS Test_Suite_End;
SELECT 'ALL ASSERTION CHECKS AND PROCEDURAL TESTS COMPLETED' AS Message;
SELECT '==================================================' AS Test_Suite_Divider;
