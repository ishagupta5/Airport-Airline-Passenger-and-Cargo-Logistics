-- ============================================================================
-- AIRPORT & AIRLINE PASSENGER AND CARGO LOGISTICS MANAGEMENT SYSTEM
-- Database Schema Definition (MySQL 8.0+ / MariaDB / PostgreSQL ANSI Compatible)
-- Author: B.Tech Computer Science DBMS Project
-- Version: 1.0.0
-- ============================================================================

DROP DATABASE IF EXISTS airport_logistics_db;
CREATE DATABASE airport_logistics_db 
    CHARACTER SET utf8mb4 
    COLLATE utf8mb4_unicode_ci;

USE airport_logistics_db;

-- ----------------------------------------------------------------------------
-- 1. SYSTEM & SECURITY MODULE
-- ----------------------------------------------------------------------------

-- System Users & Role-Based Access Control
CREATE TABLE system_users (
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

-- Audit Logging Table
CREATE TABLE audit_logs (
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

-- Airports Data
CREATE TABLE airports (
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

-- Airport Terminals
CREATE TABLE terminals (
    terminal_id INT AUTO_INCREMENT PRIMARY KEY,
    airport_id INT NOT NULL,
    terminal_name VARCHAR(50) NOT NULL,
    passenger_capacity INT NOT NULL,
    has_cargo_facility BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_terminal_airport FOREIGN KEY (airport_id) REFERENCES airports(airport_id) ON DELETE CASCADE,
    CONSTRAINT uq_airport_terminal UNIQUE (airport_id, terminal_name)
) ENGINE=InnoDB;

-- Gates Allocation
CREATE TABLE gates (
    gate_id INT AUTO_INCREMENT PRIMARY KEY,
    terminal_id INT NOT NULL,
    gate_number VARCHAR(10) NOT NULL,
    gate_type ENUM('Domestic', 'International', 'Cargo') DEFAULT 'International',
    is_operational BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_gate_terminal FOREIGN KEY (terminal_id) REFERENCES terminals(terminal_id) ON DELETE CASCADE,
    CONSTRAINT uq_terminal_gate UNIQUE (terminal_id, gate_number)
) ENGINE=InnoDB;

-- Runways Management
CREATE TABLE runways (
    runway_id INT AUTO_INCREMENT PRIMARY KEY,
    airport_id INT NOT NULL,
    runway_identifier VARCHAR(10) NOT NULL, -- e.g., '09L/27R'
    length_meters INT NOT NULL,
    surface_type VARCHAR(50) DEFAULT 'Asphalt',
    status ENUM('Active', 'Maintenance', 'Closed') DEFAULT 'Active',
    CONSTRAINT fk_runway_airport FOREIGN KEY (airport_id) REFERENCES airports(airport_id) ON DELETE CASCADE,
    CONSTRAINT chk_runway_length CHECK (length_meters > 500)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 3. AIRLINES & FLEET MODULE
-- ----------------------------------------------------------------------------

-- Airline Companies
CREATE TABLE airlines (
    airline_id INT AUTO_INCREMENT PRIMARY KEY,
    iata_code VARCHAR(2) NOT NULL UNIQUE,
    icao_code VARCHAR(3) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    country_of_origin VARCHAR(100) NOT NULL,
    contact_number VARCHAR(20) NOT NULL,
    email VARCHAR(100) NOT NULL,
    CONSTRAINT chk_airline_iata CHECK (LENGTH(iata_code) = 2)
) ENGINE=InnoDB;

-- Aircraft Models & Types
CREATE TABLE aircraft_types (
    type_id INT AUTO_INCREMENT PRIMARY KEY,
    model_name VARCHAR(50) NOT NULL UNIQUE, -- e.g. Airbus A320neo, Boeing 777-300ER
    manufacturer VARCHAR(50) NOT NULL,     -- e.g. Airbus, Boeing
    passenger_capacity INT NOT NULL,
    max_cargo_weight_kg DECIMAL(10,2) NOT NULL,
    max_cargo_volume_m3 DECIMAL(10,2) NOT NULL,
    cruising_speed_kmh INT NOT NULL,
    CONSTRAINT chk_pax_cap CHECK (passenger_capacity >= 0),
    CONSTRAINT chk_cargo_wt CHECK (max_cargo_weight_kg >= 0.00)
) ENGINE=InnoDB;

-- Individual Aircraft Fleet
CREATE TABLE aircraft (
    aircraft_id INT AUTO_INCREMENT PRIMARY KEY,
    tail_number VARCHAR(20) NOT NULL UNIQUE, -- e.g. VT-EXN, A6-EGB
    airline_id INT NOT NULL,
    type_id INT NOT NULL,
    manufacture_year INT NOT NULL,
    total_flight_hours DECIMAL(10,2) DEFAULT 0.00,
    status ENUM('Active', 'In Maintenance', 'Grounded', 'Retired') DEFAULT 'Active',
    CONSTRAINT fk_aircraft_airline FOREIGN KEY (airline_id) REFERENCES airlines(airline_id) ON DELETE RESTRICT,
    CONSTRAINT fk_aircraft_type FOREIGN KEY (type_id) REFERENCES aircraft_types(type_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Maintenance Records
CREATE TABLE aircraft_maintenance (
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

-- Registered Passengers
CREATE TABLE passengers (
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

-- Scheduled Flights
CREATE TABLE flights (
    flight_id INT AUTO_INCREMENT PRIMARY KEY,
    flight_number VARCHAR(10) NOT NULL, -- e.g. AI-101, EK-501
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

-- Seat Inventory per Aircraft
CREATE TABLE flight_seats (
    seat_id INT AUTO_INCREMENT PRIMARY KEY,
    aircraft_id INT NOT NULL,
    seat_number VARCHAR(5) NOT NULL, -- e.g., '12A', '01B'
    cabin_class ENUM('Economy', 'Premium Economy', 'Business', 'First') NOT NULL,
    is_exit_row BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_seat_aircraft FOREIGN KEY (aircraft_id) REFERENCES aircraft(aircraft_id) ON DELETE CASCADE,
    CONSTRAINT uq_aircraft_seat UNIQUE (aircraft_id, seat_number)
) ENGINE=InnoDB;

-- Passenger Ticket Bookings
CREATE TABLE bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_reference VARCHAR(8) NOT NULL UNIQUE, -- PNR Code e.g. PNR77A12
    passenger_id INT NOT NULL,
    flight_id INT NOT NULL,
    booking_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    booking_status ENUM('Confirmed', 'Checked-In', 'Cancelled', 'No-Show') DEFAULT 'Confirmed',
    total_amount DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_booking_passenger FOREIGN KEY (passenger_id) REFERENCES passengers(passenger_id),
    CONSTRAINT fk_booking_flight FOREIGN KEY (flight_id) REFERENCES flights(flight_id)
) ENGINE=InnoDB;

-- Reserved Seats per Ticket Booking
CREATE TABLE ticket_seats (
    ticket_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL,
    seat_id INT NOT NULL,
    fare_amount DECIMAL(10,2) NOT NULL,
    status ENUM('Reserved', 'Checked-In', 'Cancelled') DEFAULT 'Reserved',
    CONSTRAINT fk_tkt_booking FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE CASCADE,
    CONSTRAINT fk_tkt_seat FOREIGN KEY (seat_id) REFERENCES flight_seats(seat_id),
    CONSTRAINT uq_booking_seat UNIQUE (booking_id, seat_id)
) ENGINE=InnoDB;

-- Boarding Passes Issued
CREATE TABLE boarding_passes (
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

-- Checked Baggage Logistics
CREATE TABLE baggage (
    baggage_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL,
    tag_number VARCHAR(30) NOT NULL UNIQUE, -- e.g. BAG-DEL-98124
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

-- Crew Members (Pilots, Flight Attendants)
CREATE TABLE crew_members (
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

-- Flight Crew Roster & Duty Hours Rule
CREATE TABLE flight_crew_assignments (
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

-- Cargo Shipment Orders
CREATE TABLE cargo_shipments (
    cargo_id INT AUTO_INCREMENT PRIMARY KEY,
    air_waybill_number VARCHAR(20) NOT NULL UNIQUE, -- AWB Code e.g. AWB-99182341
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

-- Flight Cargo Loading Manifest
CREATE TABLE flight_cargo_manifest (
    manifest_id INT AUTO_INCREMENT PRIMARY KEY,
    flight_id INT NOT NULL,
    cargo_id INT NOT NULL,
    loaded_at DATETIME NOT NULL,
    loading_bay VARCHAR(20) NOT NULL, -- e.g., 'Aft Hold 1', 'Forward Hold 2'
    status ENUM('Manifested', 'Loaded', 'Offloaded') DEFAULT 'Manifested',
    CONSTRAINT fk_manifest_flight FOREIGN KEY (flight_id) REFERENCES flights(flight_id) ON DELETE CASCADE,
    CONSTRAINT fk_manifest_cargo FOREIGN KEY (cargo_id) REFERENCES cargo_shipments(cargo_id) ON DELETE CASCADE,
    CONSTRAINT uq_flight_cargo UNIQUE (flight_id, cargo_id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 7. FINANCIAL & INVOICING MODULE
-- ----------------------------------------------------------------------------

-- Financial Transactions & Invoices
CREATE TABLE payments (
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
-- 8. INDEXES FOR OPTIMIZED QUERY PERFORMANCE
-- ----------------------------------------------------------------------------

CREATE INDEX idx_airports_iata ON airports(iata_code);
CREATE INDEX idx_flights_num_dep ON flights(flight_number, scheduled_departure);
CREATE INDEX idx_flights_status ON flights(status);
CREATE INDEX idx_passengers_passport ON passengers(passport_number);
CREATE INDEX idx_bookings_pnr ON bookings(booking_reference);
CREATE INDEX idx_cargo_awb ON cargo_shipments(air_waybill_number);
CREATE INDEX idx_cargo_status ON cargo_shipments(shipment_status);
CREATE INDEX idx_baggage_tag ON baggage(tag_number);
CREATE INDEX idx_audit_logged ON audit_logs(logged_at);

-- ----------------------------------------------------------------------------
-- 9. TRIGGERS & AUTOMATION LOGIC
-- ----------------------------------------------------------------------------

DELIMITER //

-- Trigger: Audit log on flight status modification
CREATE TRIGGER trg_audit_flight_status_update
AFTER UPDATE ON flights
FOR EACH ROW
BEGIN
    IF OLD.status <> NEW.status THEN
        INSERT INTO audit_logs (user_id, action_type, entity_table, entity_id, old_value, new_value)
        VALUES (
            1, 
            'UPDATE_FLIGHT_STATUS', 
            'flights', 
            NEW.flight_id, 
            CONCAT('Status: ', OLD.status), 
            CONCAT('Status: ', NEW.status, ' Reason: ', IFNULL(NEW.delay_reason, 'N/A'))
        );
    END IF;
END //

-- Trigger: Automatically award loyalty points upon successful booking confirmation
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
-- 10. SYSTEM VIEWS
-- ----------------------------------------------------------------------------

-- View: Complete Flight Schedule with Airport Names and Gates
CREATE VIEW vw_flight_schedule_details AS
SELECT 
    f.flight_id,
    f.flight_number,
    a.name AS airline_name,
    act.model_name AS aircraft_model,
    dep.iata_code AS dep_iata,
    dep.city AS dep_city,
    arr.iata_code AS arr_iata,
    arr.city AS arr_city,
    g_dep.gate_number AS departure_gate,
    f.scheduled_departure,
    f.scheduled_arrival,
    f.status
FROM flights f
JOIN airlines a ON f.airline_id = a.airline_id
JOIN aircraft ac ON f.aircraft_id = ac.aircraft_id
JOIN aircraft_types act ON ac.type_id = act.type_id
JOIN airports dep ON f.departure_airport_id = dep.airport_id
JOIN airports arr ON f.arrival_airport_id = arr.airport_id
LEFT JOIN gates g_dep ON f.departure_gate_id = g_dep.gate_id;

-- View: Flight Cargo Payload Utilization Summary
CREATE VIEW vw_flight_cargo_manifest_summary AS
SELECT 
    f.flight_id,
    f.flight_number,
    act.model_name,
    act.max_cargo_weight_kg AS max_allowed_weight_kg,
    IFNULL(SUM(cs.weight_kg), 0.00) AS total_manifested_cargo_weight_kg,
    (act.max_cargo_weight_kg - IFNULL(SUM(cs.weight_kg), 0.00)) AS remaining_cargo_capacity_kg,
    ROUND((IFNULL(SUM(cs.weight_kg), 0.00) / act.max_cargo_weight_kg) * 100, 2) AS cargo_weight_utilization_pct
FROM flights f
JOIN aircraft ac ON f.aircraft_id = ac.aircraft_id
JOIN aircraft_types act ON ac.type_id = act.type_id
LEFT JOIN flight_cargo_manifest fcm ON f.flight_id = fcm.flight_id
LEFT JOIN cargo_shipments cs ON fcm.cargo_id = cs.cargo_id
GROUP BY f.flight_id, f.flight_number, act.model_name, act.max_cargo_weight_kg;

-- ----------------------------------------------------------------------------
-- 11. ROLE-BASED ACCESS CONTROL (DCL)
-- ----------------------------------------------------------------------------

-- Create Roles
DROP ROLE IF EXISTS r_admin, r_airline_staff, r_ground_staff, r_cargo_handler, r_customs_officer, r_passenger;
CREATE ROLE r_admin, r_airline_staff, r_ground_staff, r_cargo_handler, r_customs_officer, r_passenger;

-- Admin: Full Access
GRANT ALL PRIVILEGES ON airport_logistics_db.* TO r_admin;

-- Airline Staff: Manage Flights, Bookings, Tickets, Passenger profiles
GRANT SELECT, INSERT, UPDATE ON airport_logistics_db.flights TO r_airline_staff;
GRANT SELECT, INSERT, UPDATE ON airport_logistics_db.bookings TO r_airline_staff;
GRANT SELECT, INSERT, UPDATE ON airport_logistics_db.passengers TO r_airline_staff;
GRANT SELECT ON airport_logistics_db.airports TO r_airline_staff;

-- Ground Staff: Manage Gates, Baggage, Boarding Passes
GRANT SELECT, UPDATE ON airport_logistics_db.gates TO r_ground_staff;
GRANT SELECT, INSERT, UPDATE ON airport_logistics_db.baggage TO r_ground_staff;
GRANT SELECT, INSERT, UPDATE ON airport_logistics_db.boarding_passes TO r_ground_staff;

-- Cargo Handler: Manage Cargo Manifests and Status
GRANT SELECT, INSERT, UPDATE ON airport_logistics_db.cargo_shipments TO r_cargo_handler;
GRANT SELECT, INSERT, UPDATE ON airport_logistics_db.flight_cargo_manifest TO r_cargo_handler;

-- Customs Officer: Inspect & Clear Cargo
GRANT SELECT, UPDATE (customs_status) ON airport_logistics_db.cargo_shipments TO r_customs_officer;

-- Passenger: Read-only Flight Schedules and Personal Bookings
GRANT SELECT ON airport_logistics_db.vw_flight_schedule_details TO r_passenger;

-- ============================================================================
-- END OF SCHEMA DEFINITION
-- ============================================================================
