-- ============================================================================
-- AIRPORT & AIRLINE PASSENGER AND CARGO LOGISTICS MANAGEMENT SYSTEM
-- Production Database Schema Definition (MySQL 8.0+ Only)
-- Version: 2.0.0
-- ============================================================================

-- Ensure database exists with utf8mb4 encoding
CREATE DATABASE IF NOT EXISTS airport_logistics_db 
    CHARACTER SET utf8mb4 
    COLLATE utf8mb4_unicode_ci;

USE airport_logistics_db;

-- ----------------------------------------------------------------------------
-- 1. SYSTEM & SECURITY MODULE
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS system_users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    user_role ENUM('Admin', 'AirlineStaff', 'GroundStaff', 'CargoHandler', 'CustomsOfficer', 'Passenger') NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS audit_logs (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NULL,
    action_type VARCHAR(50) NOT NULL,
    entity_table VARCHAR(50) NOT NULL,
    entity_id INT NOT NULL,
    old_value TEXT NULL,
    new_value TEXT NULL,
    ip_address VARCHAR(45) NULL,
    logged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_audit_user FOREIGN KEY (user_id) REFERENCES system_users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 2. AIRPORT & INFRASTRUCTURE MODULE
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS airports (
    airport_id INT AUTO_INCREMENT PRIMARY KEY,
    iata_code VARCHAR(3) NOT NULL UNIQUE,
    icao_code VARCHAR(4) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    city VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    timezone VARCHAR(50) NOT NULL,
    latitude DECIMAL(10,8) NULL,
    longitude DECIMAL(11,8) NULL,
    CONSTRAINT chk_iata_length CHECK (LENGTH(iata_code) = 3)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS terminals (
    terminal_id INT AUTO_INCREMENT PRIMARY KEY,
    airport_id INT NOT NULL,
    terminal_name VARCHAR(50) NOT NULL,
    passenger_capacity INT NOT NULL,
    has_cargo_facility BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_terminal_airport FOREIGN KEY (airport_id) REFERENCES airports(airport_id) ON DELETE CASCADE,
    CONSTRAINT uq_airport_terminal UNIQUE (airport_id, terminal_name)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS gates (
    gate_id INT AUTO_INCREMENT PRIMARY KEY,
    terminal_id INT NOT NULL,
    gate_number VARCHAR(10) NOT NULL,
    gate_type ENUM('Domestic', 'International', 'Cargo') DEFAULT 'International',
    is_operational BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_gate_terminal FOREIGN KEY (terminal_id) REFERENCES terminals(terminal_id) ON DELETE CASCADE,
    CONSTRAINT uq_terminal_gate UNIQUE (terminal_id, gate_number)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS runways (
    runway_id INT AUTO_INCREMENT PRIMARY KEY,
    airport_id INT NOT NULL,
    runway_identifier VARCHAR(10) NOT NULL,
    length_meters INT NOT NULL,
    surface_type VARCHAR(50) DEFAULT 'Asphalt',
    status ENUM('Active', 'Maintenance', 'Closed') DEFAULT 'Active',
    CONSTRAINT fk_runway_airport FOREIGN KEY (airport_id) REFERENCES airports(airport_id) ON DELETE CASCADE,
    CONSTRAINT chk_runway_length CHECK (length_meters > 500)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 3. AIRLINES & FLEET MODULE
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS airlines (
    airline_id INT AUTO_INCREMENT PRIMARY KEY,
    iata_code VARCHAR(2) NOT NULL UNIQUE,
    icao_code VARCHAR(3) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    country_of_origin VARCHAR(100) NOT NULL,
    contact_number VARCHAR(20) NOT NULL,
    email VARCHAR(100) NOT NULL,
    CONSTRAINT chk_airline_iata CHECK (LENGTH(iata_code) = 2)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS aircraft_types (
    type_id INT AUTO_INCREMENT PRIMARY KEY,
    model_name VARCHAR(50) NOT NULL UNIQUE,
    manufacturer VARCHAR(50) NOT NULL,
    passenger_capacity INT NOT NULL,
    max_cargo_weight_kg DECIMAL(10,2) NOT NULL,
    max_cargo_volume_m3 DECIMAL(10,2) NOT NULL,
    cruising_speed_kmh INT NOT NULL,
    CONSTRAINT chk_pax_cap CHECK (passenger_capacity >= 0),
    CONSTRAINT chk_cargo_wt CHECK (max_cargo_weight_kg >= 0.00)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS aircraft (
    aircraft_id INT AUTO_INCREMENT PRIMARY KEY,
    tail_number VARCHAR(20) NOT NULL UNIQUE,
    airline_id INT NOT NULL,
    type_id INT NOT NULL,
    manufacture_year INT NOT NULL,
    total_flight_hours DECIMAL(10,2) DEFAULT 0.00,
    status ENUM('Active', 'In Maintenance', 'Grounded', 'Retired') DEFAULT 'Active',
    CONSTRAINT fk_aircraft_airline FOREIGN KEY (airline_id) REFERENCES airlines(airline_id) ON DELETE RESTRICT,
    CONSTRAINT fk_aircraft_type FOREIGN KEY (type_id) REFERENCES aircraft_types(type_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS aircraft_maintenance (
    maintenance_id INT AUTO_INCREMENT PRIMARY KEY,
    aircraft_id INT NOT NULL,
    maintenance_type ENUM('Routine Inspection', 'Engine Overhaul', 'Avionics Check', 'C-Check', 'Emergency Repair') NOT NULL,
    started_at DATETIME NOT NULL,
    completed_at DATETIME NULL,
    performed_by VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    cost DECIMAL(12,2) DEFAULT 0.00,
    status ENUM('Scheduled', 'In Progress', 'Completed', 'Cancelled') DEFAULT 'Scheduled',
    CONSTRAINT fk_maint_aircraft FOREIGN KEY (aircraft_id) REFERENCES aircraft(aircraft_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 4. PASSENGER & FLIGHT OPERATIONS MODULE
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS passengers (
    passenger_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    passport_number VARCHAR(20) NOT NULL UNIQUE,
    nationality VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender ENUM('Male', 'Female', 'Other') NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL,
    frequent_flyer_number VARCHAR(30) UNIQUE NULL,
    loyalty_points INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_loyalty_points CHECK (loyalty_points >= 0)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS flights (
    flight_id INT AUTO_INCREMENT PRIMARY KEY,
    flight_number VARCHAR(10) NOT NULL,
    airline_id INT NOT NULL,
    aircraft_id INT NOT NULL,
    departure_airport_id INT NOT NULL,
    arrival_airport_id INT NOT NULL,
    departure_gate_id INT NULL,
    arrival_gate_id INT NULL,
    scheduled_departure DATETIME NOT NULL,
    scheduled_arrival DATETIME NOT NULL,
    actual_departure DATETIME NULL,
    actual_arrival DATETIME NULL,
    allows_dgr BOOLEAN DEFAULT FALSE,
    status ENUM('Scheduled', 'Boarding', 'In-Air', 'Delayed', 'Cancelled', 'Arrived') DEFAULT 'Scheduled',
    delay_reason VARCHAR(255) NULL,
    CONSTRAINT fk_flight_airline FOREIGN KEY (airline_id) REFERENCES airlines(airline_id),
    CONSTRAINT fk_flight_aircraft FOREIGN KEY (aircraft_id) REFERENCES aircraft(aircraft_id),
    CONSTRAINT fk_flight_dep_airport FOREIGN KEY (departure_airport_id) REFERENCES airports(airport_id),
    CONSTRAINT fk_flight_arr_airport FOREIGN KEY (arrival_airport_id) REFERENCES airports(airport_id),
    CONSTRAINT fk_flight_dep_gate FOREIGN KEY (departure_gate_id) REFERENCES gates(gate_id),
    CONSTRAINT fk_flight_arr_gate FOREIGN KEY (arrival_gate_id) REFERENCES gates(gate_id),
    CONSTRAINT chk_airports_different CHECK (departure_airport_id <> arrival_airport_id),
    CONSTRAINT chk_departure_before_arrival CHECK (scheduled_arrival > scheduled_departure)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS flight_seats (
    seat_id INT AUTO_INCREMENT PRIMARY KEY,
    aircraft_id INT NOT NULL,
    seat_number VARCHAR(5) NOT NULL,
    cabin_class ENUM('Economy', 'Premium Economy', 'Business', 'First') NOT NULL,
    is_exit_row BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_seat_aircraft FOREIGN KEY (aircraft_id) REFERENCES aircraft(aircraft_id) ON DELETE CASCADE,
    CONSTRAINT uq_aircraft_seat UNIQUE (aircraft_id, seat_number)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_reference VARCHAR(8) NOT NULL UNIQUE,
    passenger_id INT NOT NULL,
    flight_id INT NOT NULL,
    booking_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    booking_status ENUM('Confirmed', 'Checked-In', 'Cancelled', 'No-Show') DEFAULT 'Confirmed',
    total_amount DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_booking_passenger FOREIGN KEY (passenger_id) REFERENCES passengers(passenger_id),
    CONSTRAINT fk_booking_flight FOREIGN KEY (flight_id) REFERENCES flights(flight_id)
) ENGINE=InnoDB;

-- Per-flight seat reservation with flight_id and UNIQUE (flight_id, seat_id)
CREATE TABLE IF NOT EXISTS ticket_seats (
    ticket_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL,
    flight_id INT NOT NULL,
    seat_id INT NOT NULL,
    fare_amount DECIMAL(10,2) NOT NULL,
    status ENUM('Reserved', 'Checked-In', 'Cancelled') DEFAULT 'Reserved',
    CONSTRAINT fk_tkt_booking FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE CASCADE,
    CONSTRAINT fk_tkt_flight FOREIGN KEY (flight_id) REFERENCES flights(flight_id) ON DELETE CASCADE,
    CONSTRAINT fk_tkt_seat FOREIGN KEY (seat_id) REFERENCES flight_seats(seat_id),
    CONSTRAINT uq_flight_seat UNIQUE (flight_id, seat_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS boarding_passes (
    boarding_pass_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL UNIQUE,
    ticket_id INT NOT NULL UNIQUE,
    gate_id INT NOT NULL,
    boarding_time DATETIME NOT NULL,
    sequence_number INT NOT NULL,
    issued_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_bp_booking FOREIGN KEY (booking_id) REFERENCES bookings(booking_id),
    CONSTRAINT fk_bp_ticket FOREIGN KEY (ticket_id) REFERENCES ticket_seats(ticket_id),
    CONSTRAINT fk_bp_gate FOREIGN KEY (gate_id) REFERENCES gates(gate_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS baggage (
    baggage_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL,
    tag_number VARCHAR(30) NOT NULL UNIQUE,
    weight_kg DECIMAL(5,2) NOT NULL,
    status ENUM('Checked-In', 'Screened', 'Loaded', 'In-Transit', 'Claimed', 'Lost') DEFAULT 'Checked-In',
    is_excess_weight BOOLEAN DEFAULT FALSE,
    excess_fee DECIMAL(8,2) DEFAULT 0.00,
    CONSTRAINT fk_baggage_booking FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE CASCADE,
    CONSTRAINT chk_baggage_weight CHECK (weight_kg > 0.00)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 5. CREW & DUTY MANAGEMENT MODULE
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS crew_members (
    crew_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_code VARCHAR(20) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    role ENUM('Captain', 'First Officer', 'Cabin Crew Lead', 'Flight Attendant') NOT NULL,
    airline_id INT NOT NULL,
    license_number VARCHAR(30) NOT NULL UNIQUE,
    nationality VARCHAR(50) NOT NULL,
    accumulated_duty_hours DECIMAL(6,2) DEFAULT 0.00,
    CONSTRAINT fk_crew_airline FOREIGN KEY (airline_id) REFERENCES airlines(airline_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS flight_crew_assignments (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY,
    flight_id INT NOT NULL,
    crew_id INT NOT NULL,
    duty_start DATETIME NOT NULL,
    duty_end DATETIME NOT NULL,
    duty_hours DECIMAL(4,2) GENERATED ALWAYS AS (TIMESTAMPDIFF(MINUTE, duty_start, duty_end) / 60.0) STORED,
    assignment_status ENUM('Assigned', 'Completed', 'Replaced') DEFAULT 'Assigned',
    CONSTRAINT fk_assign_flight FOREIGN KEY (flight_id) REFERENCES flights(flight_id) ON DELETE CASCADE,
    CONSTRAINT fk_assign_crew FOREIGN KEY (crew_id) REFERENCES crew_members(crew_id),
    CONSTRAINT uq_flight_crew UNIQUE (flight_id, crew_id),
    CONSTRAINT chk_duty_limit CHECK (duty_hours <= 14.00)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 6. CARGO LOGISTICS MODULE
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS cargo_shipments (
    cargo_id INT AUTO_INCREMENT PRIMARY KEY,
    air_waybill_number VARCHAR(20) NOT NULL UNIQUE,
    sender_name VARCHAR(100) NOT NULL,
    sender_contact VARCHAR(30) NOT NULL,
    receiver_name VARCHAR(100) NOT NULL,
    receiver_contact VARCHAR(30) NOT NULL,
    cargo_type ENUM('General', 'Perishable', 'Fragile', 'Hazardous', 'Live Animals', 'Valuable') NOT NULL,
    weight_kg DECIMAL(10,2) NOT NULL,
    volume_m3 DECIMAL(10,2) NOT NULL,
    declared_value DECIMAL(12,2) NOT NULL,
    freight_charge DECIMAL(10,2) NOT NULL,
    customs_status ENUM('Pending Inspection', 'Cleared', 'Held', 'Rejected') DEFAULT 'Pending Inspection',
    shipment_status ENUM('Booked', 'Received at Depot', 'Loaded', 'In-Air', 'Customs Clearance', 'Out for Delivery', 'Delivered') DEFAULT 'Booked',
    booking_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_cargo_weight CHECK (weight_kg > 0.00),
    CONSTRAINT chk_cargo_vol CHECK (volume_m3 > 0.00)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS flight_cargo_manifest (
    manifest_id INT AUTO_INCREMENT PRIMARY KEY,
    flight_id INT NOT NULL,
    cargo_id INT NOT NULL,
    loaded_at DATETIME NULL,
    loading_bay VARCHAR(20) NOT NULL,
    status ENUM('Manifested', 'Loaded', 'Offloaded') DEFAULT 'Manifested',
    CONSTRAINT fk_manifest_flight FOREIGN KEY (flight_id) REFERENCES flights(flight_id) ON DELETE CASCADE,
    CONSTRAINT fk_manifest_cargo FOREIGN KEY (cargo_id) REFERENCES cargo_shipments(cargo_id) ON DELETE CASCADE,
    CONSTRAINT uq_flight_cargo UNIQUE (flight_id, cargo_id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 7. FINANCIAL & INVOICING MODULE
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_reference VARCHAR(50) NOT NULL UNIQUE,
    reference_type ENUM('Booking', 'Cargo', 'BaggageFee') NOT NULL,
    reference_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_method ENUM('Credit Card', 'Debit Card', 'UPI', 'Net Banking', 'Wire Transfer', 'Cash') NOT NULL,
    payment_status ENUM('Pending', 'Completed', 'Failed', 'Refunded') DEFAULT 'Completed',
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_payment_amount CHECK (amount >= 0.00)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 8. COMPOSITE INDEXES (Removed redundant single-column indexes on UNIQUE cols)
-- ----------------------------------------------------------------------------

CREATE INDEX idx_flights_dep_time ON flights(departure_airport_id, scheduled_departure);
CREATE INDEX idx_flights_status ON flights(status);
CREATE INDEX idx_bookings_flight ON bookings(flight_id, booking_status);
CREATE INDEX idx_manifest_flight ON flight_cargo_manifest(flight_id);
CREATE INDEX idx_cargo_customs_status ON cargo_shipments(customs_status, shipment_status);
CREATE INDEX idx_audit_logged ON audit_logs(logged_at);

-- ----------------------------------------------------------------------------
-- 9. TRIGGERS: INTEGRITY ENFORCEMENT & AUDIT
-- ----------------------------------------------------------------------------

DELIMITER //

-- Trigger: Ensure ticket seat belongs to the flight's assigned aircraft
DROP TRIGGER IF EXISTS trg_check_seat_aircraft_insert //
CREATE TRIGGER trg_check_seat_aircraft_insert
BEFORE INSERT ON ticket_seats
FOR EACH ROW
BEGIN
    DECLARE v_flight_aircraft_id INT;
    DECLARE v_seat_aircraft_id INT;

    SELECT aircraft_id INTO v_flight_aircraft_id FROM flights WHERE flight_id = NEW.flight_id;
    SELECT aircraft_id INTO v_seat_aircraft_id FROM flight_seats WHERE seat_id = NEW.seat_id;

    IF v_flight_aircraft_id IS NULL OR v_seat_aircraft_id IS NULL OR v_flight_aircraft_id <> v_seat_aircraft_id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Integrity Error: Selected seat belongs to a different aircraft model than the booked flight';
    END IF;
END //

DROP TRIGGER IF EXISTS trg_check_seat_aircraft_update //
CREATE TRIGGER trg_check_seat_aircraft_update
BEFORE UPDATE ON ticket_seats
FOR EACH ROW
BEGIN
    DECLARE v_flight_aircraft_id INT;
    DECLARE v_seat_aircraft_id INT;

    SELECT aircraft_id INTO v_flight_aircraft_id FROM flights WHERE flight_id = NEW.flight_id;
    SELECT aircraft_id INTO v_seat_aircraft_id FROM flight_seats WHERE seat_id = NEW.seat_id;

    IF v_flight_aircraft_id <> v_seat_aircraft_id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Integrity Error: Selected seat belongs to a different aircraft model than the booked flight';
    END IF;
END //

-- Trigger: Validate Departure and Arrival Gates belong to their respective airports
DROP TRIGGER IF EXISTS trg_validate_flight_gates_insert //
CREATE TRIGGER trg_validate_flight_gates_insert
BEFORE INSERT ON flights
FOR EACH ROW
BEGIN
    DECLARE v_dep_airport_id INT;
    DECLARE v_arr_airport_id INT;
    DECLARE v_gate_conflict_count INT;

    -- Validate departure gate belongs to departure airport
    IF NEW.departure_gate_id IS NOT NULL THEN
        SELECT t.airport_id INTO v_dep_airport_id
        FROM gates g JOIN terminals t ON g.terminal_id = t.terminal_id
        WHERE g.gate_id = NEW.departure_gate_id;

        IF v_dep_airport_id IS NULL OR v_dep_airport_id <> NEW.departure_airport_id THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Integrity Error: Departure gate does not belong to the departure airport';
        END IF;

        -- 45-min turnaround window check
        SELECT COUNT(*) INTO v_gate_conflict_count
        FROM flights
        WHERE departure_gate_id = NEW.departure_gate_id
          AND status NOT IN ('Cancelled', 'Arrived')
          AND ABS(TIMESTAMPDIFF(MINUTE, scheduled_departure, NEW.scheduled_departure)) < 45;

        IF v_gate_conflict_count > 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Schedule Conflict: Departure gate is already occupied within 45-minute turnaround window';
        END IF;
    END IF;

    -- Validate arrival gate belongs to arrival airport
    IF NEW.arrival_gate_id IS NOT NULL THEN
        SELECT t.airport_id INTO v_arr_airport_id
        FROM gates g JOIN terminals t ON g.terminal_id = t.terminal_id
        WHERE g.gate_id = NEW.arrival_gate_id;

        IF v_arr_airport_id IS NULL OR v_arr_airport_id <> NEW.arrival_airport_id THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Integrity Error: Arrival gate does not belong to the arrival airport';
        END IF;
    END IF;
END //

DROP TRIGGER IF EXISTS trg_validate_flight_gates_update //
CREATE TRIGGER trg_validate_flight_gates_update
BEFORE UPDATE ON flights
FOR EACH ROW
BEGIN
    DECLARE v_dep_airport_id INT;
    DECLARE v_arr_airport_id INT;
    DECLARE v_gate_conflict_count INT;

    IF NEW.departure_gate_id IS NOT NULL THEN
        SELECT t.airport_id INTO v_dep_airport_id
        FROM gates g JOIN terminals t ON g.terminal_id = t.terminal_id
        WHERE g.gate_id = NEW.departure_gate_id;

        IF v_dep_airport_id IS NULL OR v_dep_airport_id <> NEW.departure_airport_id THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Integrity Error: Departure gate does not belong to the departure airport';
        END IF;

        IF NEW.departure_gate_id <> OLD.departure_gate_id OR NEW.scheduled_departure <> OLD.scheduled_departure THEN
            SELECT COUNT(*) INTO v_gate_conflict_count
            FROM flights
            WHERE departure_gate_id = NEW.departure_gate_id
              AND flight_id <> NEW.flight_id
              AND status NOT IN ('Cancelled', 'Arrived')
              AND ABS(TIMESTAMPDIFF(MINUTE, scheduled_departure, NEW.scheduled_departure)) < 45;

            IF v_gate_conflict_count > 0 THEN
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Schedule Conflict: Departure gate is already occupied within 45-minute turnaround window';
            END IF;
        END IF;
    END IF;

    IF NEW.arrival_gate_id IS NOT NULL THEN
        SELECT t.airport_id INTO v_arr_airport_id
        FROM gates g JOIN terminals t ON g.terminal_id = t.terminal_id
        WHERE g.gate_id = NEW.arrival_gate_id;

        IF v_arr_airport_id IS NULL OR v_arr_airport_id <> NEW.arrival_airport_id THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Integrity Error: Arrival gate does not belong to the arrival airport';
        END IF;
    END IF;
END //

-- Trigger: Validate Aircraft Availability (No maintenance in-progress, no overlapping flights)
DROP TRIGGER IF EXISTS trg_validate_aircraft_insert //
CREATE TRIGGER trg_validate_aircraft_insert
BEFORE INSERT ON flights
FOR EACH ROW
BEGIN
    DECLARE v_ac_status VARCHAR(30);
    DECLARE v_maint_count INT;
    DECLARE v_overlap_count INT;

    SELECT status INTO v_ac_status FROM aircraft WHERE aircraft_id = NEW.aircraft_id;
    IF v_ac_status IN ('In Maintenance', 'Grounded', 'Retired') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Safety Error: Cannot schedule flight with aircraft currently grounded or in maintenance';
    END IF;

    SELECT COUNT(*) INTO v_maint_count
    FROM aircraft_maintenance
    WHERE aircraft_id = NEW.aircraft_id
      AND status = 'In Progress';
    IF v_maint_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Safety Error: Aircraft currently has maintenance in progress';
    END IF;

    -- Overlapping flight check
    SELECT COUNT(*) INTO v_overlap_count
    FROM flights
    WHERE aircraft_id = NEW.aircraft_id
      AND status NOT IN ('Cancelled', 'Arrived')
      AND (
          (NEW.scheduled_departure BETWEEN scheduled_departure AND scheduled_arrival)
          OR (NEW.scheduled_arrival BETWEEN scheduled_departure AND scheduled_arrival)
          OR (scheduled_departure BETWEEN NEW.scheduled_departure AND NEW.scheduled_arrival)
      );
    IF v_overlap_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Conflict: Aircraft is already assigned to an overlapping flight schedule';
    END IF;
END //

-- Trigger: Validate Crew Assignment (No overlapping shifts, duty limit <= 14h)
DROP TRIGGER IF EXISTS trg_validate_crew_assignment //
CREATE TRIGGER trg_validate_crew_assignment
BEFORE INSERT ON flight_crew_assignments
FOR EACH ROW
BEGIN
    DECLARE v_overlap_count INT;
    DECLARE v_rolling_duty DECIMAL(6,2);

    -- Check overlapping duty shifts
    SELECT COUNT(*) INTO v_overlap_count
    FROM flight_crew_assignments
    WHERE crew_id = NEW.crew_id
      AND assignment_status = 'Assigned'
      AND (
          (NEW.duty_start BETWEEN duty_start AND duty_end)
          OR (NEW.duty_end BETWEEN duty_start AND duty_end)
          OR (duty_start BETWEEN NEW.duty_start AND NEW.duty_end)
      );
    IF v_overlap_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Crew Safety Error: Crew member has an overlapping duty assignment';
    END IF;

    -- Check rolling 24-hour total duty hours
    SELECT IFNULL(SUM(duty_hours), 0.00) INTO v_rolling_duty
    FROM flight_crew_assignments
    WHERE crew_id = NEW.crew_id
      AND duty_end >= DATE_SUB(NEW.duty_start, INTERVAL 24 HOUR)
      AND duty_start <= NEW.duty_start;

    IF (v_rolling_duty + (TIMESTAMPDIFF(MINUTE, NEW.duty_start, NEW.duty_end) / 60.0)) > 14.00 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Crew Safety Error: 24-hour cumulative duty exceeds 14 hours limit';
    END IF;
END //

-- Trigger: Cargo Manifest validation (Aircraft weight & volume limits, customs clearance, DGR rule)
DROP TRIGGER IF EXISTS trg_validate_cargo_manifest //
CREATE TRIGGER trg_validate_cargo_manifest
BEFORE INSERT ON flight_cargo_manifest
FOR EACH ROW
BEGIN
    DECLARE v_customs_status VARCHAR(30);
    DECLARE v_cargo_type VARCHAR(30);
    DECLARE v_cargo_weight DECIMAL(10,2);
    DECLARE v_cargo_volume DECIMAL(10,2);
    DECLARE v_max_weight DECIMAL(10,2);
    DECLARE v_max_vol DECIMAL(10,2);
    DECLARE v_cur_weight DECIMAL(10,2);
    DECLARE v_cur_vol DECIMAL(10,2);
    DECLARE v_allows_dgr BOOLEAN;

    -- Check customs status
    SELECT customs_status, cargo_type, weight_kg, volume_m3
    INTO v_customs_status, v_cargo_type, v_cargo_weight, v_cargo_volume
    FROM cargo_shipments WHERE cargo_id = NEW.cargo_id;

    IF v_customs_status <> 'Cleared' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Logistics Violation: Cannot manifest cargo that has not received Customs Clearance';
    END IF;

    -- Check dangerous goods restriction
    SELECT f.allows_dgr, act.max_cargo_weight_kg, act.max_cargo_volume_m3
    INTO v_allows_dgr, v_max_weight, v_max_vol
    FROM flights f
    JOIN aircraft ac ON f.aircraft_id = ac.aircraft_id
    JOIN aircraft_types act ON ac.type_id = act.type_id
    WHERE f.flight_id = NEW.flight_id;

    IF v_cargo_type IN ('Hazardous', 'Live Animals') AND (v_allows_dgr IS NULL OR v_allows_dgr = FALSE) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Safety Restriction: Flight is not certified for Dangerous Goods (Hazardous / Live Animals)';
    END IF;

    -- Check max payload capacity
    SELECT IFNULL(SUM(cs.weight_kg), 0.00), IFNULL(SUM(cs.volume_m3), 0.00)
    INTO v_cur_weight, v_cur_vol
    FROM flight_cargo_manifest fcm
    JOIN cargo_shipments cs ON fcm.cargo_id = cs.cargo_id
    WHERE fcm.flight_id = NEW.flight_id;

    IF (v_cur_weight + v_cargo_weight) > v_max_weight THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Payload Exceeded: Total manifested cargo weight exceeds aircraft maximum cargo weight limit';
    END IF;

    IF (v_cur_vol + v_cargo_volume) > v_max_vol THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Volume Exceeded: Total manifested cargo volume exceeds aircraft maximum cargo hold volume';
    END IF;
END //

-- Trigger: Synchronize Cargo Shipment status upon manifest insert
DROP TRIGGER IF EXISTS trg_after_manifest_insert //
CREATE TRIGGER trg_after_manifest_insert
AFTER INSERT ON flight_cargo_manifest
FOR EACH ROW
BEGIN
    UPDATE cargo_shipments
    SET shipment_status = 'Loaded'
    WHERE cargo_id = NEW.cargo_id;
END //

-- Trigger: Audit log on flight status change using session user @app_user_id
DROP TRIGGER IF EXISTS trg_audit_flight_status_update //
CREATE TRIGGER trg_audit_flight_status_update
AFTER UPDATE ON flights
FOR EACH ROW
BEGIN
    IF OLD.status <> NEW.status THEN
        INSERT INTO audit_logs (user_id, action_type, entity_table, entity_id, old_value, new_value)
        VALUES (
            IFNULL(@app_user_id, 1), 
            'UPDATE_FLIGHT_STATUS', 
            'flights', 
            NEW.flight_id, 
            CONCAT('Status: ', OLD.status), 
            CONCAT('Status: ', NEW.status, ' Reason: ', IFNULL(NEW.delay_reason, 'N/A'))
        );
    END IF;
END //

-- Trigger: Audit log on customs status change
DROP TRIGGER IF EXISTS trg_audit_customs_status_update //
CREATE TRIGGER trg_audit_customs_status_update
AFTER UPDATE ON cargo_shipments
FOR EACH ROW
BEGIN
    IF OLD.customs_status <> NEW.customs_status THEN
        INSERT INTO audit_logs (user_id, action_type, entity_table, entity_id, old_value, new_value)
        VALUES (
            IFNULL(@app_user_id, 1),
            'UPDATE_CUSTOMS_STATUS',
            'cargo_shipments',
            NEW.cargo_id,
            CONCAT('Customs: ', OLD.customs_status),
            CONCAT('Customs: ', NEW.customs_status)
        );
    END IF;
END //

-- Trigger: Automatically award loyalty points upon successful booking confirmation
DROP TRIGGER IF EXISTS trg_award_loyalty_points //
CREATE TRIGGER trg_award_loyalty_points
AFTER INSERT ON bookings
FOR EACH ROW
BEGIN
    IF NEW.booking_status = 'Confirmed' THEN
        UPDATE passengers
        SET loyalty_points = loyalty_points + FLOOR(NEW.total_amount / 100)
        WHERE passenger_id = NEW.passenger_id;
    END IF;
END //

DELIMITER ;

-- ----------------------------------------------------------------------------
-- 10. STORED PROCEDURES (DBMS SHOWPIECE)
-- ----------------------------------------------------------------------------

DELIMITER //

-- Stored Procedure: Atomic Ticket Booking with SELECT ... FOR UPDATE
DROP PROCEDURE IF EXISTS sp_book_ticket //
CREATE PROCEDURE sp_book_ticket(
    IN p_passenger_id INT,
    IN p_flight_id INT,
    IN p_seat_id INT,
    IN p_fare_amount DECIMAL(10,2),
    IN p_payment_method VARCHAR(30),
    OUT p_booking_id INT,
    OUT p_pnr VARCHAR(8),
    OUT p_ticket_id INT
)
proc_label: BEGIN
    DECLARE v_seat_exists INT;
    DECLARE v_seat_booked INT;
    DECLARE v_flight_aircraft INT;
    DECLARE v_seat_aircraft INT;
    DECLARE v_pnr VARCHAR(8);
    DECLARE v_chars VARCHAR(36) DEFAULT 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    DECLARE i INT DEFAULT 0;

    -- Error handler: rollback transaction on exception
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- 1. Lock flight row
    SELECT aircraft_id INTO v_flight_aircraft
    FROM flights
    WHERE flight_id = p_flight_id
    FOR UPDATE;

    IF v_flight_aircraft IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Flight does not exist';
    END IF;

    -- 2. Lock seat row and verify matching aircraft
    SELECT aircraft_id INTO v_seat_aircraft
    FROM flight_seats
    WHERE seat_id = p_seat_id
    FOR UPDATE;

    IF v_seat_aircraft IS NULL OR v_flight_aircraft <> v_seat_aircraft THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Seat does not belong to the aircraft assigned to this flight';
    END IF;

    -- 3. Check if seat is already booked for this flight
    SELECT COUNT(*) INTO v_seat_booked
    FROM ticket_seats
    WHERE flight_id = p_flight_id 
      AND seat_id = p_seat_id 
      AND status <> 'Cancelled'
    FOR UPDATE;

    IF v_seat_booked > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Seat is already reserved for this flight';
    END IF;

    -- 4. Generate unique 6-character PNR
    REPEAT
        SET v_pnr = '';
        SET i = 0;
        WHILE i < 6 DO
            SET v_pnr = CONCAT(v_pnr, SUBSTRING(v_chars, FLOOR(1 + RAND() * 32), 1));
            SET i = i + 1;
        END WHILE;
    UNTIL NOT EXISTS (SELECT 1 FROM bookings WHERE booking_reference = v_pnr)
    END REPEAT;

    -- 5. Insert Booking
    INSERT INTO bookings (booking_reference, passenger_id, flight_id, booking_status, total_amount)
    VALUES (v_pnr, p_passenger_id, p_flight_id, 'Confirmed', p_fare_amount);
    SET p_booking_id = LAST_INSERT_ID();

    -- 6. Insert Ticket Seat
    INSERT INTO ticket_seats (booking_id, flight_id, seat_id, fare_amount, status)
    VALUES (p_booking_id, p_flight_id, p_seat_id, p_fare_amount, 'Reserved');
    SET p_ticket_id = LAST_INSERT_ID();

    -- 7. Insert Payment record
    INSERT INTO payments (transaction_reference, reference_type, reference_id, amount, payment_method, payment_status)
    VALUES (CONCAT('TXN-', v_pnr, '-', UNIX_TIMESTAMP()), 'Booking', p_booking_id, p_fare_amount, p_payment_method, 'Completed');

    COMMIT;

    SET p_pnr = v_pnr;
END //

-- Stored Procedure: Passenger Check-in and Boarding Pass Generation
DROP PROCEDURE IF EXISTS sp_check_in //
CREATE PROCEDURE sp_check_in(
    IN p_booking_id INT,
    OUT p_boarding_pass_id INT
)
BEGIN
    DECLARE v_status VARCHAR(20);
    DECLARE v_flight_id INT;
    DECLARE v_ticket_id INT;
    DECLARE v_gate_id INT;
    DECLARE v_dep_time DATETIME;
    DECLARE v_boarding_time DATETIME;
    DECLARE v_seq INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT b.booking_status, b.flight_id, ts.ticket_id, f.departure_gate_id, f.scheduled_departure
    INTO v_status, v_flight_id, v_ticket_id, v_gate_id, v_dep_time
    FROM bookings b
    JOIN ticket_seats ts ON b.booking_id = ts.booking_id
    JOIN flights f ON b.flight_id = f.flight_id
    WHERE b.booking_id = p_booking_id
    FOR UPDATE;

    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Booking not found';
    END IF;

    IF v_status = 'Checked-In' THEN
        SELECT boarding_pass_id INTO p_boarding_pass_id FROM boarding_passes WHERE booking_id = p_booking_id;
        COMMIT;
    ELSE
        IF v_status <> 'Confirmed' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot check in: Booking is not in Confirmed status';
        END IF;

        IF v_gate_id IS NULL THEN
            -- Assign default gate from terminal if gate not assigned
            SELECT g.gate_id INTO v_gate_id
            FROM gates g
            JOIN terminals t ON g.terminal_id = t.terminal_id
            WHERE t.airport_id = (SELECT departure_airport_id FROM flights WHERE flight_id = v_flight_id)
            LIMIT 1;
        END IF;

        SET v_boarding_time = DATE_SUB(v_dep_time, INTERVAL 45 MINUTE);

        -- Sequence number per flight
        SELECT IFNULL(MAX(bp.sequence_number), 0) + 1 INTO v_seq
        FROM boarding_passes bp
        JOIN bookings bk ON bp.booking_id = bk.booking_id
        WHERE bk.flight_id = v_flight_id;

        INSERT INTO boarding_passes (booking_id, ticket_id, gate_id, boarding_time, sequence_number)
        VALUES (p_booking_id, v_ticket_id, v_gate_id, v_boarding_time, v_seq);
        SET p_boarding_pass_id = LAST_INSERT_ID();

        UPDATE bookings SET booking_status = 'Checked-In' WHERE booking_id = p_booking_id;
        UPDATE ticket_seats SET status = 'Checked-In' WHERE ticket_id = v_ticket_id;

        COMMIT;
    END IF;
END //

-- Stored Procedure: Customs Clearance with Audit Logging
DROP PROCEDURE IF EXISTS sp_clear_customs //
CREATE PROCEDURE sp_clear_customs(
    IN p_cargo_id INT,
    IN p_officer_user_id INT,
    IN p_decision VARCHAR(20) -- 'Cleared', 'Held', 'Rejected'
)
BEGIN
    DECLARE v_current_status VARCHAR(30);

    SELECT customs_status INTO v_current_status FROM cargo_shipments WHERE cargo_id = p_cargo_id FOR UPDATE;

    IF v_current_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cargo shipment not found';
    END IF;

    SET @app_user_id = p_officer_user_id;

    UPDATE cargo_shipments
    SET customs_status = p_decision
    WHERE cargo_id = p_cargo_id;
END //

-- Stored Procedure: Manifest and Load Cargo onto Flight
DROP PROCEDURE IF EXISTS sp_load_cargo //
CREATE PROCEDURE sp_load_cargo(
    IN p_flight_id INT,
    IN p_cargo_id INT,
    IN p_loading_bay VARCHAR(20)
)
BEGIN
    INSERT INTO flight_cargo_manifest (flight_id, cargo_id, loaded_at, loading_bay, status)
    VALUES (p_flight_id, p_cargo_id, NOW(), p_loading_bay, 'Loaded');
END //

DELIMITER ;

-- ----------------------------------------------------------------------------
-- 11. SYSTEM VIEWS
-- ----------------------------------------------------------------------------

-- View: Complete Flight Schedule with Airport Names, Timezones, and Departure Gates
CREATE OR REPLACE VIEW vw_flight_schedule_details AS
SELECT 
    f.flight_id,
    f.flight_number,
    a.name AS airline_name,
    act.model_name AS aircraft_model,
    dep.iata_code AS dep_iata,
    dep.city AS dep_city,
    dep.timezone AS dep_timezone,
    arr.iata_code AS arr_iata,
    arr.city AS arr_city,
    arr.timezone AS arr_timezone,
    IFNULL(g_dep.gate_number, 'TBD') AS departure_gate,
    f.scheduled_departure,
    f.scheduled_arrival,
    ROUND(TIMESTAMPDIFF(MINUTE, f.scheduled_departure, f.scheduled_arrival) / 60.0, 1) AS duration_hours,
    f.status,
    f.delay_reason,
    f.allows_dgr
FROM flights f
JOIN airlines a ON f.airline_id = a.airline_id
JOIN aircraft ac ON f.aircraft_id = ac.aircraft_id
JOIN aircraft_types act ON ac.type_id = act.type_id
JOIN airports dep ON f.departure_airport_id = dep.airport_id
JOIN airports arr ON f.arrival_airport_id = arr.airport_id
LEFT JOIN gates g_dep ON f.departure_gate_id = g_dep.gate_id;

-- View: Flight Cargo Payload & Volume Capacity Utilization Summary
CREATE OR REPLACE VIEW vw_flight_cargo_manifest_summary AS
SELECT 
    f.flight_id,
    f.flight_number,
    a.name AS airline_name,
    act.model_name,
    act.max_cargo_weight_kg AS max_allowed_weight_kg,
    IFNULL(SUM(cs.weight_kg), 0.00) AS total_manifested_cargo_weight_kg,
    (act.max_cargo_weight_kg - IFNULL(SUM(cs.weight_kg), 0.00)) AS remaining_cargo_capacity_kg,
    ROUND((IFNULL(SUM(cs.weight_kg), 0.00) / act.max_cargo_weight_kg) * 100, 2) AS cargo_weight_utilization_pct,
    act.max_cargo_volume_m3 AS max_allowed_volume_m3,
    IFNULL(SUM(cs.volume_m3), 0.00) AS total_manifested_cargo_volume_m3,
    ROUND((IFNULL(SUM(cs.volume_m3), 0.00) / act.max_cargo_volume_m3) * 100, 2) AS cargo_volume_utilization_pct
FROM flights f
JOIN airlines a ON f.airline_id = a.airline_id
JOIN aircraft ac ON f.aircraft_id = ac.aircraft_id
JOIN aircraft_types act ON ac.type_id = act.type_id
LEFT JOIN flight_cargo_manifest fcm ON f.flight_id = fcm.flight_id
LEFT JOIN cargo_shipments cs ON fcm.cargo_id = cs.cargo_id
GROUP BY f.flight_id, f.flight_number, a.name, act.model_name, act.max_cargo_weight_kg, act.max_cargo_volume_m3;

-- ----------------------------------------------------------------------------
-- 12. ROLE-BASED ACCESS CONTROL (DCL)
-- ----------------------------------------------------------------------------

DROP ROLE IF EXISTS r_admin, r_airline_staff, r_ground_staff, r_cargo_handler, r_customs_officer, r_passenger;
CREATE ROLE r_admin, r_airline_staff, r_ground_staff, r_cargo_handler, r_customs_officer, r_passenger;

GRANT ALL PRIVILEGES ON airport_logistics_db.* TO r_admin;

GRANT SELECT, INSERT, UPDATE ON airport_logistics_db.flights TO r_airline_staff;
GRANT SELECT, INSERT, UPDATE ON airport_logistics_db.bookings TO r_airline_staff;
GRANT SELECT, INSERT, UPDATE ON airport_logistics_db.passengers TO r_airline_staff;
GRANT SELECT ON airport_logistics_db.airports TO r_airline_staff;

GRANT SELECT, UPDATE ON airport_logistics_db.gates TO r_ground_staff;
GRANT SELECT, INSERT, UPDATE ON airport_logistics_db.baggage TO r_ground_staff;
GRANT SELECT, INSERT, UPDATE ON airport_logistics_db.boarding_passes TO r_ground_staff;

GRANT SELECT, INSERT, UPDATE ON airport_logistics_db.cargo_shipments TO r_cargo_handler;
GRANT SELECT, INSERT, UPDATE ON airport_logistics_db.flight_cargo_manifest TO r_cargo_handler;

GRANT SELECT, UPDATE (customs_status) ON airport_logistics_db.cargo_shipments TO r_customs_officer;

GRANT SELECT ON airport_logistics_db.vw_flight_schedule_details TO r_passenger;

-- ============================================================================
-- END OF SCHEMA DEFINITION
-- ============================================================================
