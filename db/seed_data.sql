-- ============================================================================
-- AIRPORT & AIRLINE PASSENGER AND CARGO LOGISTICS MANAGEMENT SYSTEM
-- Seed Sample Data File (MySQL 8.0+ Only)
-- Production Clean Dataset with Dynamic Relative Timestamps
-- ============================================================================

USE airport_logistics_db;

-- ----------------------------------------------------------------------------
-- 1. SYSTEM USERS (Password for all demo users is: password123)
-- ----------------------------------------------------------------------------
-- Bcrypt hash generated with 10 salt rounds for 'password123':
-- $2b$10$wE96X.JgV2fQY5Z8HqvKveo3qQy7K/R4g7cO0l2QW9A7aB3vD9Q6O
INSERT INTO system_users (username, password_hash, full_name, email, user_role) VALUES
('admin_main', '$2b$10$wE96X.JgV2fQY5Z8HqvKveo3qQy7K/R4g7cO0l2QW9A7aB3vD9Q6O', 'Rajesh Sharma', 'admin@airport.gov.in', 'Admin'),
('ai_ops_lead', '$2b$10$wE96X.JgV2fQY5Z8HqvKveo3qQy7K/R4g7cO0l2QW9A7aB3vD9Q6O', 'Priya Deshmukh', 'p.deshmukh@airindia.in', 'AirlineStaff'),
('indigo_dispatcher', '$2b$10$wE96X.JgV2fQY5Z8HqvKveo3qQy7K/R4g7cO0l2QW9A7aB3vD9Q6O', 'Amit Kumar', 'a.kumar@goindigo.in', 'AirlineStaff'),
('emirates_rep', '$2b$10$wE96X.JgV2fQY5Z8HqvKveo3qQy7K/R4g7cO0l2QW9A7aB3vD9Q6O', 'Tariq Al-Mansoor', 't.mansoor@emirates.com', 'AirlineStaff'),
('ba_ops', '$2b$10$wE96X.JgV2fQY5Z8HqvKveo3qQy7K/R4g7cO0l2QW9A7aB3vD9Q6O', 'Oliver Smith', 'oliver.smith@ba.com', 'AirlineStaff'),
('ground_supervisor', '$2b$10$wE96X.JgV2fQY5Z8HqvKveo3qQy7K/R4g7cO0l2QW9A7aB3vD9Q6O', 'Vikram Singh', 'v.singh@dial.in', 'GroundStaff'),
('ramp_controller', '$2b$10$wE96X.JgV2fQY5Z8HqvKveo3qQy7K/R4g7cO0l2QW9A7aB3vD9Q6O', 'Sunil Verma', 's.verma@mial.in', 'GroundStaff'),
('cargo_depot_mgr', '$2b$10$wE96X.JgV2fQY5Z8HqvKveo3qQy7K/R4g7cO0l2QW9A7aB3vD9Q6O', 'Anil Mehta', 'a.mehta@celebbi.in', 'CargoHandler'),
('cargo_loader_1', '$2b$10$wE96X.JgV2fQY5Z8HqvKveo3qQy7K/R4g7cO0l2QW9A7aB3vD9Q6O', 'Ramesh Yadav', 'r.yadav@dhad.in', 'CargoHandler'),
('customs_inspector', '$2b$10$wE96X.JgV2fQY5Z8HqvKveo3qQy7K/R4g7cO0l2QW9A7aB3vD9Q6O', 'S. K. Rao', 'sk.rao@customs.gov.in', 'CustomsOfficer'),
('customs_officer_2', '$2b$10$wE96X.JgV2fQY5Z8HqvKveo3qQy7K/R4g7cO0l2QW9A7aB3vD9Q6O', 'Neha Nair', 'neha.nair@customs.gov.in', 'CustomsOfficer'),
('pax_aravind', '$2b$10$wE96X.JgV2fQY5Z8HqvKveo3qQy7K/R4g7cO0l2QW9A7aB3vD9Q6O', 'Aravind Swaminathan', 'aravind.s@gmail.com', 'Passenger');

-- ----------------------------------------------------------------------------
-- 2. AIRPORTS (DEL, BOM, BLR, DXB, LHR)
-- ----------------------------------------------------------------------------
INSERT INTO airports (airport_id, iata_code, icao_code, name, city, country, timezone, latitude, longitude) VALUES
(1, 'DEL', 'VIDP', 'Indira Gandhi International Airport', 'New Delhi', 'India', 'Asia/Kolkata', 28.5562, 77.1000),
(2, 'BOM', 'VABB', 'Chhatrapati Shivaji Maharaj International Airport', 'Mumbai', 'India', 'Asia/Kolkata', 19.0896, 72.8656),
(3, 'BLR', 'VOBL', 'Kempegowda International Airport', 'Bengaluru', 'India', 'Asia/Kolkata', 13.1986, 77.7066),
(4, 'DXB', 'OMDB', 'Dubai International Airport', 'Dubai', 'United Arab Emirates', 'Asia/Dubai', 25.2532, 55.3657),
(5, 'LHR', 'EGLL', 'London Heathrow Airport', 'London', 'United Kingdom', 'Europe/London', 51.4700, -0.4543);

-- ----------------------------------------------------------------------------
-- 3. TERMINALS
-- ----------------------------------------------------------------------------
INSERT INTO terminals (terminal_id, airport_id, terminal_name, passenger_capacity, has_cargo_facility) VALUES
(1, 1, 'Terminal 1', 15000000, FALSE),
(2, 1, 'Terminal 3', 40000000, TRUE),
(3, 1, 'Cargo Terminal A', 0, TRUE),
(4, 2, 'Terminal 1', 12000000, FALSE),
(5, 2, 'Terminal 2', 30000000, TRUE),
(6, 2, 'Air Cargo Complex', 0, TRUE),
(7, 3, 'Terminal 1', 25000000, TRUE),
(8, 3, 'Terminal 2', 15000000, FALSE),
(9, 4, 'Terminal 1', 20000000, FALSE),
(10, 4, 'Terminal 3', 35000000, TRUE),
(11, 4, 'Cargo Mega Terminal', 0, TRUE),
(12, 5, 'Terminal 2', 18000000, FALSE),
(13, 5, 'Terminal 5', 30000000, TRUE);

-- ----------------------------------------------------------------------------
-- 4. GATES (Comprehensive gate allocation across all 5 airports)
-- ----------------------------------------------------------------------------
INSERT INTO gates (gate_id, terminal_id, gate_number, gate_type, is_operational) VALUES
-- DEL (Airport 1)
(1, 2, 'Gate 14', 'International', TRUE),
(2, 2, 'Gate 15', 'International', TRUE),
(3, 2, 'Gate 16', 'International', TRUE),
(4, 1, 'Gate 02', 'Domestic', TRUE),
(5, 1, 'Gate 05', 'Domestic', TRUE),
(6, 3, 'Bay DEL-C1', 'Cargo', TRUE),
-- BOM (Airport 2)
(7, 5, 'Gate B20', 'Domestic', TRUE),
(8, 5, 'Gate B22', 'International', TRUE),
(9, 5, 'Gate B24', 'International', TRUE),
(10, 4, 'Gate B02', 'Domestic', TRUE),
(11, 6, 'Bay BOM-C1', 'Cargo', TRUE),
-- BLR (Airport 3)
(12, 7, 'Gate 101', 'Domestic', TRUE),
(13, 7, 'Gate 102', 'Domestic', TRUE),
(14, 7, 'Gate 104', 'International', TRUE),
(15, 7, 'Gate 108', 'International', TRUE),
-- DXB (Airport 4)
(16, 10, 'Gate C16', 'International', TRUE),
(17, 10, 'Gate C18', 'International', TRUE),
(18, 10, 'Gate C20', 'International', TRUE),
(19, 10, 'Gate C22', 'International', TRUE),
(20, 11, 'Bay DXB-C1', 'Cargo', TRUE),
-- LHR (Airport 5)
(21, 13, 'Gate A10', 'International', TRUE),
(22, 13, 'Gate A12', 'International', TRUE),
(23, 13, 'Gate A14', 'International', TRUE),
(24, 13, 'Gate A16', 'International', TRUE);

-- ----------------------------------------------------------------------------
-- 5. RUNWAYS
-- ----------------------------------------------------------------------------
INSERT INTO runways (runway_id, airport_id, runway_identifier, length_meters, surface_type, status) VALUES
(1, 1, '11/29', 4430, 'Asphalt', 'Active'),
(2, 1, '10/28', 3810, 'Concrete', 'Active'),
(3, 1, '09/27', 4280, 'Asphalt', 'Active'),
(4, 2, '09/27', 3448, 'Asphalt', 'Active'),
(5, 2, '14/32', 2925, 'Asphalt', 'Active'),
(6, 3, '09R/27L', 4000, 'Concrete', 'Active'),
(7, 3, '09L/27R', 4000, 'Asphalt', 'Active'),
(8, 4, '12L/30R', 4450, 'Asphalt', 'Active'),
(9, 4, '12R/30L', 4000, 'Asphalt', 'Active'),
(10, 5, '09L/27R', 3902, 'Asphalt', 'Active'),
(11, 5, '09R/27L', 3660, 'Asphalt', 'Active');

-- ----------------------------------------------------------------------------
-- 6. AIRLINES
-- ----------------------------------------------------------------------------
INSERT INTO airlines (airline_id, iata_code, icao_code, name, country_of_origin, contact_number, email) VALUES
(1, 'AI', 'AIC', 'Air India', 'India', '+91-11-24622220', 'support@airindia.in'),
(2, '6E', 'IGO', 'IndiGo', 'India', '+91-124-6173838', 'customer.relations@goindigo.in'),
(3, 'EK', 'UAE', 'Emirates', 'United Arab Emirates', '+971-600-555555', 'customer.support@emirates.com'),
(4, 'BA', 'BAW', 'British Airways', 'United Kingdom', '+44-344-4930787', 'contact@ba.com');

-- ----------------------------------------------------------------------------
-- 7. AIRCRAFT TYPES
-- ----------------------------------------------------------------------------
INSERT INTO aircraft_types (type_id, model_name, manufacturer, passenger_capacity, max_cargo_weight_kg, max_cargo_volume_m3, cruising_speed_kmh) VALUES
(1, 'Airbus A320neo', 'Airbus', 186, 4500.00, 37.40, 828),
(2, 'Airbus A321neo', 'Airbus', 232, 5800.00, 51.70, 833),
(3, 'Boeing 777-300ER', 'Boeing', 342, 20200.00, 150.00, 905),
(4, 'Boeing 787-9 Dreamliner', 'Boeing', 290, 16000.00, 125.00, 903),
(5, 'Airbus A350-900', 'Airbus', 316, 18500.00, 138.00, 903);

-- ----------------------------------------------------------------------------
-- 8. AIRCRAFT FLEET (Consistent Status with Maintenance Logs)
-- ----------------------------------------------------------------------------
INSERT INTO aircraft (aircraft_id, tail_number, airline_id, type_id, manufacture_year, total_flight_hours, status) VALUES
(1, 'VT-EXN', 1, 1, 2018, 14200.50, 'Active'),
(2, 'VT-ALX', 1, 3, 2016, 28400.00, 'Active'),
(3, 'VT-ANB', 1, 4, 2019, 11800.25, 'Active'),
(4, 'VT-IFH', 2, 1, 2020, 9500.00, 'Active'),
(5, 'VT-IMQ', 2, 2, 2021, 7200.10, 'Active'),
(6, 'VT-ISZ', 2, 1, 2017, 18900.75, 'Active'), -- Maintenance completed; set to Active
(7, 'A6-EGB', 3, 3, 2017, 24500.00, 'Active'), -- Avionics check completed; set to Active
(8, 'A6-EPN', 3, 3, 2019, 15300.60, 'Active'),
(9, 'A6-EVH', 3, 5, 2022, 4100.30, 'Active'),
(10, 'G-STBD', 4, 3, 2015, 32100.00, 'Active'),
(11, 'G-ZBJA', 4, 4, 2018, 16750.40, 'Active'),
(12, 'G-XWBA', 4, 5, 2020, 8900.00, 'In Maintenance'); -- In maintenance; not scheduled

-- ----------------------------------------------------------------------------
-- 9. AIRCRAFT MAINTENANCE
-- ----------------------------------------------------------------------------
INSERT INTO aircraft_maintenance (maintenance_id, aircraft_id, maintenance_type, started_at, completed_at, performed_by, description, cost, status) VALUES
(1, 6, 'Routine Inspection', '2026-09-27 08:00:00', '2026-09-28 16:00:00', 'Air Works India Engineering', '500-hour hydraulic line check.', 45000.00, 'Completed'),
(2, 2, 'Engine Overhaul', '2026-09-15 06:00:00', '2026-09-25 18:00:00', 'GE Aviation DEL', 'GE90-115B turbine blade overhaul.', 420000.00, 'Completed'),
(3, 10, 'C-Check', '2026-09-01 00:00:00', '2026-09-14 23:59:59', 'British Airways Engineering', 'Comprehensive structural inspection.', 850000.00, 'Completed'),
(4, 7, 'Avionics Check', '2026-09-26 10:00:00', '2026-09-27 18:00:00', 'Emirates Engineering DXB', 'Weather radar calibration.', 28000.00, 'Completed'),
(5, 12, 'Routine Inspection', NOW(), NULL, 'British Airways Maintenance LHR', 'Scheduled A-check and avionics diagnostics.', 35000.00, 'In Progress');

-- ----------------------------------------------------------------------------
-- 10. PASSENGERS
-- ----------------------------------------------------------------------------
INSERT INTO passengers (passenger_id, first_name, last_name, passport_number, nationality, date_of_birth, gender, email, phone, frequent_flyer_number, loyalty_points) VALUES
(1, 'Aravind', 'Swaminathan', 'Z8912345', 'Indian', '1992-04-15', 'Male', 'aravind.s@gmail.com', '+91-9840123456', 'AI-FF-99182', 14500),
(2, 'Neha', 'Desai', 'K4519823', 'Indian', '1995-11-20', 'Female', 'neha.desai@yahoo.com', '+91-9820987654', '6E-PERK-112', 3200),
(3, 'Rohan', 'Mehta', 'M1290348', 'Indian', '1988-08-05', 'Male', 'rohan.m@techcorp.in', '+91-9811223344', 'AI-FF-44120', 28900),
(4, 'Sarah', 'Jenkins', 'GB9821301', 'British', '1990-02-14', 'Female', 'sarah.j@consulting.uk', '+44-7700900123', 'BA-EXEC-991', 45000),
(5, 'Mohammed', 'Al-Hashimi', 'UAE881902', 'Emirati', '1985-06-30', 'Male', 'm.hashimi@dubaitrade.ae', '+971-501234567', 'EK-SKY-88210', 82100),
(6, 'Ananya', 'Roy', 'R6712940', 'Indian', '1998-01-25', 'Female', 'ananya.roy@outlook.com', '+91-9730554433', NULL, 0),
(7, 'Vikramaditya', 'Rao', 'V5519824', 'Indian', '1979-12-10', 'Male', 'v.rao@logistics.in', '+91-9900112233', 'AI-FF-77192', 18900),
(8, 'Emma', 'Watson', 'GB1192834', 'British', '1994-09-18', 'Female', 'emma.w@designstudio.uk', '+44-7811223344', 'BA-EXEC-442', 12300),
(9, 'Karan', 'Johar', 'P9918273', 'Indian', '1982-03-22', 'Male', 'karan@dharma.in', '+91-9821010101', '6E-PERK-990', 6400),
(10, 'Pooja', 'Hegde', 'H3391827', 'Indian', '1993-10-13', 'Female', 'pooja@cinestar.in', '+91-9819998877', 'EK-SKY-33100', 31200),
(11, 'David', 'Miller', 'US4491823', 'American', '1987-07-04', 'Male', 'david.miller@nybank.com', '+1-212-5550198', NULL, 0),
(12, 'Siddharth', 'Nair', 'N8821903', 'Indian', '1996-05-08', 'Male', 'siddharth.nair@startup.io', '+91-9845098765', 'AI-FF-10023', 8500),
(13, 'Elena', 'Rostova', 'RU4412098', 'Russian', '1991-09-12', 'Female', 'elena.rostova@travel.ru', '+7-916-1234567', NULL, 0),
(14, 'Akira', 'Tanaka', 'JP9921002', 'Japanese', '1986-03-17', 'Male', 'tanaka.a@tokyoair.jp', '+81-90-12345678', 'AI-FF-88200', 21400);

-- ----------------------------------------------------------------------------
-- 11. FLIGHT SEATS INVENTORY (Every aircraft has realistic seat allocations)
-- ----------------------------------------------------------------------------
-- Aircraft 1: A320neo (Air India)
INSERT INTO flight_seats (aircraft_id, seat_number, cabin_class, is_exit_row) VALUES
(1, '01A', 'Business', FALSE), (1, '01B', 'Business', FALSE), (1, '01C', 'Business', FALSE),
(1, '02A', 'Business', FALSE), (1, '02B', 'Business', FALSE), (1, '02C', 'Business', FALSE),
(1, '05A', 'Economy', FALSE),  (1, '05B', 'Economy', FALSE),  (1, '05C', 'Economy', FALSE),
(1, '10A', 'Economy', TRUE),   (1, '10B', 'Economy', TRUE),   (1, '10C', 'Economy', TRUE);

-- Aircraft 2: B777-300ER (Air India)
INSERT INTO flight_seats (aircraft_id, seat_number, cabin_class, is_exit_row) VALUES
(2, '01A', 'First', FALSE),    (2, '01B', 'First', FALSE),    (2, '01C', 'First', FALSE),
(2, '02A', 'First', FALSE),    (2, '02B', 'First', FALSE),    (2, '02C', 'First', FALSE),
(2, '07A', 'Business', FALSE), (2, '07B', 'Business', FALSE), (2, '07K', 'Business', FALSE),
(2, '12A', 'Business', FALSE), (2, '12B', 'Business', FALSE), (2, '12K', 'Business', FALSE),
(2, '20A', 'Economy', FALSE),  (2, '20B', 'Economy', FALSE),  (2, '20C', 'Economy', FALSE),
(2, '31A', 'Economy', TRUE),   (2, '31B', 'Economy', TRUE),   (2, '31C', 'Economy', TRUE);

-- Aircraft 3: B787-9 (Air India)
INSERT INTO flight_seats (aircraft_id, seat_number, cabin_class, is_exit_row) VALUES
(3, '01A', 'Business', FALSE), (3, '01B', 'Business', FALSE), (3, '01D', 'Business', FALSE),
(3, '06A', 'Business', FALSE), (3, '06B', 'Business', FALSE), (3, '06D', 'Business', FALSE),
(3, '14A', 'Economy', FALSE),  (3, '14B', 'Economy', FALSE),  (3, '14C', 'Economy', FALSE),
(3, '22A', 'Economy', TRUE),   (3, '22B', 'Economy', TRUE),   (3, '22C', 'Economy', TRUE);

-- Aircraft 4: A320neo (IndiGo)
INSERT INTO flight_seats (aircraft_id, seat_number, cabin_class, is_exit_row) VALUES
(4, '01A', 'Economy', FALSE),  (4, '01B', 'Economy', FALSE),  (4, '01C', 'Economy', FALSE),
(4, '02A', 'Economy', FALSE),  (4, '02B', 'Economy', FALSE),  (4, '02C', 'Economy', FALSE),
(4, '10A', 'Economy', FALSE),  (4, '10B', 'Economy', FALSE),  (4, '10C', 'Economy', FALSE),
(4, '12A', 'Economy', TRUE),   (4, '12B', 'Economy', TRUE),   (4, '12C', 'Economy', TRUE);

-- Aircraft 5: A321neo (IndiGo)
INSERT INTO flight_seats (aircraft_id, seat_number, cabin_class, is_exit_row) VALUES
(5, '01A', 'Economy', FALSE),  (5, '01B', 'Economy', FALSE),  (5, '01C', 'Economy', FALSE),
(5, '08A', 'Economy', FALSE),  (5, '08B', 'Economy', FALSE),  (5, '08C', 'Economy', FALSE),
(5, '15A', 'Economy', TRUE),   (5, '15B', 'Economy', TRUE),   (5, '15C', 'Economy', TRUE);

-- Aircraft 6: A320neo (IndiGo)
INSERT INTO flight_seats (aircraft_id, seat_number, cabin_class, is_exit_row) VALUES
(6, '01A', 'Economy', FALSE),  (6, '01B', 'Economy', FALSE),  (6, '01C', 'Economy', FALSE),
(6, '05A', 'Economy', FALSE),  (6, '05B', 'Economy', FALSE),  (6, '05C', 'Economy', FALSE);

-- Aircraft 7: B777-300ER (Emirates)
INSERT INTO flight_seats (aircraft_id, seat_number, cabin_class, is_exit_row) VALUES
(7, '01A', 'First', FALSE),    (7, '01B', 'First', FALSE),    (7, '01E', 'First', FALSE),
(7, '06A', 'Business', FALSE), (7, '06B', 'Business', FALSE), (7, '06K', 'Business', FALSE),
(7, '16A', 'Economy', FALSE),  (7, '16B', 'Economy', FALSE),  (7, '16C', 'Economy', FALSE),
(7, '25A', 'Economy', TRUE),   (7, '25B', 'Economy', TRUE),   (7, '25C', 'Economy', TRUE);

-- Aircraft 8: B777-300ER (Emirates)
INSERT INTO flight_seats (aircraft_id, seat_number, cabin_class, is_exit_row) VALUES
(8, '01A', 'First', FALSE),    (8, '01B', 'First', FALSE),
(8, '05A', 'Business', FALSE), (8, '05B', 'Business', FALSE),
(8, '18A', 'Economy', FALSE),  (8, '18B', 'Economy', FALSE);

-- Aircraft 9: A350-900 (Emirates)
INSERT INTO flight_seats (aircraft_id, seat_number, cabin_class, is_exit_row) VALUES
(9, '01A', 'Business', FALSE), (9, '01B', 'Business', FALSE), (9, '01K', 'Business', FALSE),
(9, '08A', 'Business', FALSE), (9, '08B', 'Business', FALSE), (9, '08K', 'Business', FALSE),
(9, '14A', 'Economy', FALSE),  (9, '14B', 'Economy', FALSE),  (9, '14C', 'Economy', FALSE);

-- Aircraft 10: B777-300ER (British Airways)
INSERT INTO flight_seats (aircraft_id, seat_number, cabin_class, is_exit_row) VALUES
(10, '01A', 'First', FALSE),   (10, '01B', 'First', FALSE),
(10, '05A', 'Business', FALSE),(10, '05B', 'Business', FALSE),
(10, '15A', 'Economy', FALSE), (10, '15B', 'Economy', FALSE),
(10, '22A', 'Economy', TRUE),  (10, '22B', 'Economy', TRUE);

-- Aircraft 11: B787-9 (British Airways)
INSERT INTO flight_seats (aircraft_id, seat_number, cabin_class, is_exit_row) VALUES
(11, '01A', 'Business', FALSE),(11, '01B', 'Business', FALSE),
(11, '10A', 'Economy', FALSE), (11, '10B', 'Economy', FALSE);

-- Aircraft 12: A350-900 (British Airways)
INSERT INTO flight_seats (aircraft_id, seat_number, cabin_class, is_exit_row) VALUES
(12, '01A', 'Business', FALSE),(12, '01B', 'Business', FALSE),
(12, '12A', 'Economy', FALSE), (12, '12B', 'Economy', FALSE);

-- ----------------------------------------------------------------------------
-- 12. SCHEDULED FLIGHTS (Relative to CURRENT_DATE with realistic block times)
-- ----------------------------------------------------------------------------
-- Flight 1: AI-101 (DEL -> LHR), 9h duration
-- Flight 2: AI-102 (LHR -> DEL), 8.5h duration
-- Flight 3: 6E-205 (DEL -> BOM), 2h 15m duration
-- Flight 4: 6E-508 (BOM -> BLR), 1h 45m duration
-- Flight 5: EK-501 (BOM -> DXB), 3h 15m duration
-- Flight 6: EK-511 (DEL -> DXB), 3h 30m duration
-- Flight 7: BA-198 (BOM -> LHR), 9h 30m duration
-- Flight 8: BA-143 (LHR -> DEL), 8h 45m duration
-- Flight 9: AI-503 (DEL -> BLR), Yesterday, Arrived
-- Flight 10: 6E-301 (BLR -> DEL), Yesterday, Arrived
-- Flight 11: EK-512 (DXB -> DEL), Today, In-Air
-- Flight 12: AI-131 (BOM -> DXB), Today Evening, Scheduled
INSERT INTO flights (
    flight_id, flight_number, airline_id, aircraft_id, 
    departure_airport_id, arrival_airport_id, departure_gate_id, arrival_gate_id, 
    scheduled_departure, scheduled_arrival, actual_departure, actual_arrival, 
    allows_dgr, status, delay_reason
) VALUES
-- 1. AI-101: DEL -> LHR (Gate 14 DEL, Gate A10 LHR)
(1, 'AI-101', 1, 2, 1, 5, 1, 21, 
 TIMESTAMP(CURDATE(), '02:30:00'), TIMESTAMP(CURDATE(), '11:30:00'), 
 NULL, NULL, TRUE, 'Scheduled', NULL),

-- 2. AI-102: LHR -> DEL (Gate A12 LHR, Gate 15 DEL)
(2, 'AI-102', 1, 2, 5, 1, 22, 2, 
 TIMESTAMP(CURDATE(), '14:00:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 1 DAY), '02:30:00'), 
 NULL, NULL, TRUE, 'Scheduled', NULL),

-- 3. 6E-205: DEL -> BOM (Gate 02 DEL, Gate B22 BOM)
(3, '6E-205', 2, 4, 1, 2, 4, 8, 
 TIMESTAMP(CURDATE(), '06:00:00'), TIMESTAMP(CURDATE(), '08:15:00'), 
 NULL, NULL, FALSE, 'Boarding', NULL),

-- 4. 6E-508: BOM -> BLR (Gate B20 BOM, Gate 101 BLR)
(4, '6E-508', 2, 5, 2, 3, 7, 12, 
 TIMESTAMP(CURDATE(), '10:15:00'), TIMESTAMP(CURDATE(), '12:00:00'), 
 NULL, NULL, FALSE, 'Scheduled', NULL),

-- 5. EK-501: BOM -> DXB (Gate B24 BOM, Gate C18 DXB)
(5, 'EK-501', 3, 7, 2, 4, 9, 17, 
 TIMESTAMP(CURDATE(), '04:30:00'), TIMESTAMP(CURDATE(), '07:45:00'), 
 NULL, NULL, TRUE, 'Scheduled', NULL),

-- 6. EK-511: DEL -> DXB (Gate 16 DEL, Gate C20 DXB)
(6, 'EK-511', 3, 8, 1, 4, 3, 18, 
 TIMESTAMP(CURDATE(), '11:00:00'), TIMESTAMP(CURDATE(), '14:30:00'), 
 NULL, NULL, TRUE, 'Scheduled', NULL),

-- 7. BA-198: BOM -> LHR (Gate B22 BOM, Gate A14 LHR)
(7, 'BA-198', 4, 10, 2, 5, 8, 23, 
 TIMESTAMP(CURDATE(), '13:15:00'), TIMESTAMP(CURDATE(), '22:45:00'), 
 NULL, NULL, TRUE, 'Scheduled', NULL),

-- 8. BA-143: LHR -> DEL (Gate A10 LHR, Gate 14 DEL)
(8, 'BA-143', 4, 11, 5, 1, 21, 1, 
 TIMESTAMP(CURDATE(), '20:00:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 1 DAY), '08:45:00'), 
 NULL, NULL, TRUE, 'Scheduled', NULL),

-- 9. AI-503: DEL -> BLR (Arrived yesterday)
(9, 'AI-503', 1, 3, 1, 3, 5, 14, 
 TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 1 DAY), '14:00:00'), TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 1 DAY), '16:45:00'), 
 TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 1 DAY), '14:25:00'), TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 1 DAY), '17:05:00'), 
 TRUE, 'Arrived', 'ATC Clearance Delay'),

-- 10. 6E-301: BLR -> DEL (Arrived yesterday)
(10, '6E-301', 2, 4, 3, 1, 13, 4, 
 TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 1 DAY), '18:00:00'), TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 1 DAY), '20:45:00'), 
 TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 1 DAY), '18:02:00'), TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 1 DAY), '20:40:00'), 
 FALSE, 'Arrived', NULL),

-- 11. EK-512: DXB -> DEL (Currently In-Air)
(11, 'EK-512', 3, 9, 4, 1, 17, 2, 
 DATE_SUB(NOW(), INTERVAL 2 HOUR), DATE_ADD(NOW(), INTERVAL 90 MINUTE), 
 DATE_SUB(NOW(), INTERVAL 110 MINUTE), NULL, 
 TRUE, 'In-Air', NULL),

-- 12. AI-131: BOM -> DXB (Today Evening)
(12, 'AI-131', 1, 1, 2, 4, 9, 18, 
 TIMESTAMP(CURDATE(), '18:30:00'), TIMESTAMP(CURDATE(), '21:45:00'), 
 NULL, NULL, FALSE, 'Scheduled', NULL);

-- ----------------------------------------------------------------------------
-- 13. BOOKINGS
-- ----------------------------------------------------------------------------
INSERT INTO bookings (booking_id, booking_reference, passenger_id, flight_id, booking_date, booking_status, total_amount) VALUES
(1, 'PNR101A', 1, 1, NOW(), 'Confirmed', 68500.00),
(2, 'PNR101B', 3, 1, NOW(), 'Confirmed', 125000.00),
(3, 'PNR101C', 4, 1, NOW(), 'Checked-In', 210000.00),
(4, 'PNR205A', 2, 3, NOW(), 'Confirmed', 4500.00),
(5, 'PNR205B', 9, 3, NOW(), 'Confirmed', 7800.00),
(6, 'PNR501A', 5, 5, NOW(), 'Checked-In', 89000.00),
(7, 'PNR501B', 10, 5, NOW(), 'Confirmed', 95000.00),
(8, 'PNR198A', 4, 7, NOW(), 'Confirmed', 185000.00),
(9, 'PNR198B', 8, 7, NOW(), 'Confirmed', 72000.00),
(10, 'PNR503A', 7, 9, NOW(), 'Checked-In', 6200.00),
(11, 'PNR301A', 6, 10, NOW(), 'Checked-In', 5800.00),
(12, 'PNR512A', 11, 11, NOW(), 'Checked-In', 38000.00),
(13, 'PNR131A', 12, 12, NOW(), 'Confirmed', 24500.00),
(14, 'PNR102A', 13, 2, NOW(), 'Confirmed', 82000.00),
(15, 'PNR511A', 14, 6, NOW(), 'Confirmed', 42000.00);

-- ----------------------------------------------------------------------------
-- 14. TICKET SEATS (Seats match the aircraft assigned to each flight)
-- ----------------------------------------------------------------------------
-- Flight 1 (Aircraft 2): seats 13 to 29
-- Flight 3 (Aircraft 4): seats 37 to 48
-- Flight 5 (Aircraft 7): seats 58 to 69
-- Flight 7 (Aircraft 10): seats 76 to 83
-- Flight 9 (Aircraft 3): seats 30 to 36
-- Flight 10 (Aircraft 4): seats 37 to 48
-- Flight 11 (Aircraft 9): seats 70 to 75
-- Flight 12 (Aircraft 1): seats 1 to 12
-- Flight 2 (Aircraft 2): seats 13 to 29
-- Flight 6 (Aircraft 8): seats 70 to 75

INSERT INTO ticket_seats (ticket_id, booking_id, flight_id, seat_id, fare_amount, status) VALUES
(1, 1, 1, 19, 68500.00, 'Reserved'),
(2, 2, 1, 20, 125000.00, 'Reserved'),
(3, 3, 1, 13, 210000.00, 'Checked-In'),
(4, 4, 3, 43, 4500.00, 'Reserved'),
(5, 5, 3, 44, 7800.00, 'Reserved'),
(6, 6, 5, 70, 89000.00, 'Checked-In'),
(7, 7, 5, 71, 95000.00, 'Reserved'),
(8, 8, 7, 97, 185000.00, 'Reserved'),
(9, 9, 7, 98, 72000.00, 'Reserved'),
(10, 10, 9, 31, 6200.00, 'Checked-In'),
(11, 11, 10, 45, 5800.00, 'Checked-In'),
(12, 12, 11, 88, 38000.00, 'Checked-In'),
(13, 13, 12, 1, 24500.00, 'Reserved'),
(14, 14, 2, 21, 82000.00, 'Reserved'),
(15, 15, 6, 82, 42000.00, 'Reserved');


-- ----------------------------------------------------------------------------
-- 15. BOARDING PASSES (Issued for Checked-In passengers)
-- ----------------------------------------------------------------------------
INSERT INTO boarding_passes (boarding_pass_id, booking_id, ticket_id, gate_id, boarding_time, sequence_number) VALUES
(1, 3, 3, 1, TIMESTAMP(CURDATE(), '01:45:00'), 1),
(2, 6, 6, 9, TIMESTAMP(CURDATE(), '03:45:00'), 1),
(3, 10, 10, 5, TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 1 DAY), '13:15:00'), 1),
(4, 11, 11, 13, TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 1 DAY), '17:15:00'), 1),
(5, 12, 12, 17, DATE_SUB(NOW(), INTERVAL 165 MINUTE), 1);

-- ----------------------------------------------------------------------------
-- 16. BAGGAGE LOGISTICS
-- ----------------------------------------------------------------------------
INSERT INTO baggage (baggage_id, booking_id, tag_number, weight_kg, status, is_excess_weight, excess_fee) VALUES
(1, 1, 'BAG-AI-9001A', 21.50, 'Checked-In', FALSE, 0.00),
(2, 1, 'BAG-AI-9001B', 14.00, 'Checked-In', FALSE, 0.00),
(3, 3, 'BAG-AI-1002A', 28.00, 'Loaded', TRUE, 4500.00),
(4, 4, 'BAG-6E-2051A', 12.00, 'Checked-In', FALSE, 0.00),
(5, 6, 'BAG-EK-5011A', 23.00, 'Loaded', FALSE, 0.00),
(6, 6, 'BAG-EK-5011B', 24.50, 'Loaded', FALSE, 0.00),
(7, 10, 'BAG-AI-5031A', 18.00, 'Claimed', FALSE, 0.00),
(8, 11, 'BAG-6E-3011A', 14.50, 'Claimed', FALSE, 0.00),
(9, 12, 'BAG-EK-5121A', 19.80, 'In-Transit', FALSE, 0.00),
(10, 8, 'BAG-BA-1981A', 22.00, 'Checked-In', FALSE, 0.00),
(11, 13, 'BAG-AI-1311A', 15.00, 'Checked-In', FALSE, 0.00);

-- ----------------------------------------------------------------------------
-- 17. CREW MEMBERS (No titles in first_name; roles maintain rank)
-- ----------------------------------------------------------------------------
INSERT INTO crew_members (crew_id, employee_code, first_name, last_name, role, airline_id, license_number, nationality, accumulated_duty_hours) VALUES
(1, 'AI-P-001', 'Vikram', 'Batra', 'Captain', 1, 'ATPL-IND-9812', 'Indian', 68.50),
(2, 'AI-P-002', 'Tarun', 'Goyal', 'First Officer', 1, 'CPL-IND-4412', 'Indian', 52.00),
(3, 'AI-C-101', 'Sunita', 'Rao', 'Cabin Crew Lead', 1, 'CC-IND-8819', 'Indian', 74.00),
(4, '6E-P-001', 'Sameer', 'Khan', 'Captain', 2, 'ATPL-IND-1120', 'Indian', 80.00),
(5, '6E-P-002', 'Pooja', 'Sharma', 'First Officer', 2, 'CPL-IND-5590', 'Indian', 61.50),
(6, 'EK-P-001', 'Tariq', 'Al-Falasi', 'Captain', 3, 'GCAA-ATPL-901', 'Emirati', 70.00),
(7, 'EK-P-002', 'Jean', 'Dupont', 'First Officer', 3, 'EASA-CPL-7712', 'French', 58.00),
(8, 'BA-P-001', 'James', 'Wilson', 'Captain', 4, 'UK-CAA-99120', 'British', 65.00),
(9, 'BA-P-002', 'Claire', 'Taylor', 'First Officer', 4, 'UK-CAA-44192', 'British', 50.00),
(10, 'AI-C-102', 'Anita', 'Deshmukh', 'Flight Attendant', 1, 'CC-IND-9901', 'Indian', 45.00),
(11, '6E-C-201', 'Rohit', 'Verma', 'Cabin Crew Lead', 2, 'CC-IND-5544', 'Indian', 55.00),
(12, 'EK-C-301', 'Fatima', 'Al-Zahra', 'Cabin Crew Lead', 3, 'GCAA-CC-119', 'Emirati', 62.00);

-- ----------------------------------------------------------------------------
-- 18. FLIGHT CREW ASSIGNMENTS (Includes deliberate duty hour audit cases)
-- ----------------------------------------------------------------------------
INSERT INTO flight_crew_assignments (assignment_id, flight_id, crew_id, duty_start, duty_end, assignment_status) VALUES
-- Flight 1: 7.5 hours shift (NORMAL)
(1, 1, 1, TIMESTAMP(CURDATE(), '01:00:00'), TIMESTAMP(CURDATE(), '08:30:00'), 'Assigned'),
(2, 1, 2, TIMESTAMP(CURDATE(), '01:00:00'), TIMESTAMP(CURDATE(), '08:30:00'), 'Assigned'),
(3, 1, 3, TIMESTAMP(CURDATE(), '01:30:00'), TIMESTAMP(CURDATE(), '08:00:00'), 'Assigned'),
-- Flight 3: 5.0 hours shift (NORMAL)
(4, 3, 4, TIMESTAMP(CURDATE(), '04:30:00'), TIMESTAMP(CURDATE(), '09:30:00'), 'Assigned'),
(5, 3, 5, TIMESTAMP(CURDATE(), '04:30:00'), TIMESTAMP(CURDATE(), '09:30:00'), 'Assigned'),
-- Flight 5: 12.5 hours shift (CRITICAL WARNING DEMO CASE: >12 hours)
(6, 5, 6, TIMESTAMP(CURDATE(), '03:00:00'), TIMESTAMP(CURDATE(), '15:30:00'), 'Assigned'),
(7, 5, 7, TIMESTAMP(CURDATE(), '03:00:00'), TIMESTAMP(CURDATE(), '07:30:00'), 'Assigned'),
-- Flight 7: 8.0 hours shift (NORMAL)
(8, 7, 8, TIMESTAMP(CURDATE(), '11:30:00'), TIMESTAMP(CURDATE(), '19:30:00'), 'Assigned'),
(9, 7, 9, TIMESTAMP(CURDATE(), '11:30:00'), TIMESTAMP(CURDATE(), '19:30:00'), 'Assigned'),
-- Historical Flights
(10, 9, 1, TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 1 DAY), '12:30:00'), TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 1 DAY), '18:00:00'), 'Completed'),
(11, 10, 4, TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 1 DAY), '16:30:00'), TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 1 DAY), '21:45:00'), 'Completed');

-- ----------------------------------------------------------------------------
-- 19. CARGO SHIPMENTS (Full lifecycle: Cleared, Pending, Held, Rejected)
-- ----------------------------------------------------------------------------
INSERT INTO cargo_shipments (
    cargo_id, air_waybill_number, sender_name, sender_contact, 
    receiver_name, receiver_contact, cargo_type, weight_kg, volume_m3, 
    declared_value, freight_charge, customs_status, shipment_status
) VALUES
(1, 'AWB-981-10029811', 'Sun Pharmaceuticals Mumbai', '+91-22-28210000', 'NHS Procurement London', '+44-20-79460912', 'Perishable', 3500.00, 18.50, 450000.00, 245000.00, 'Cleared', 'Loaded'),
(2, 'AWB-981-10029822', 'Tata Electronics Hosur', '+91-4344-200100', 'Foxconn Technology Dubai', '+971-4-8819000', 'Fragile', 1200.00, 8.20, 890000.00, 115000.00, 'Cleared', 'Loaded'),
(3, 'AWB-079-88192011', 'Al-Maktoum Trading Dubai', '+971-4-3310000', 'Reliance Retail Delhi', '+91-11-41109999', 'General', 6200.00, 42.00, 180000.00, 185000.00, 'Cleared', 'In-Air'),
(4, 'AWB-125-44910293', 'Rolls-Royce Aerospace Derby', '+44-1332-242424', 'Air India Engineering DEL', '+91-11-25652000', 'Hazardous', 850.00, 4.50, 650000.00, 140000.00, 'Pending Inspection', 'Booked'),
(5, 'AWB-981-33019844', 'Serum Institute Pune', '+91-20-26993900', 'Ministry of Health UAE', '+971-2-6321000', 'Perishable', 4800.00, 22.00, 1200000.00, 310000.00, 'Cleared', 'Received at Depot'),
(6, 'AWB-589-77192033', 'IndiGo Cargo Logistics', '+91-124-6173838', 'Bluedart Express Bengaluru', '+91-80-22990000', 'General', 2100.00, 15.00, 95000.00, 42000.00, 'Cleared', 'Booked'),
(7, 'AWB-125-99812044', 'Harrods Department Store London', '+44-20-77301234', 'Luxury Retail Mumbai', '+91-22-66112233', 'Valuable', 420.00, 2.80, 980000.00, 95000.00, 'Held', 'Received at Depot'),
(8, 'AWB-981-44129855', 'Bharat Biotech Hyderabad', '+91-40-23480567', 'UNICEF Supply Hub Dubai', '+971-4-8810011', 'Perishable', 1800.00, 12.00, 750000.00, 160000.00, 'Cleared', 'Booked'),
(9, 'AWB-079-55192022', 'Dubai Gold Souk Traders', '+971-4-2260000', 'MMTC PAMP New Delhi', '+91-11-47000000', 'Valuable', 150.00, 1.20, 2500000.00, 85000.00, 'Cleared', 'Loaded'),
(10, 'AWB-125-77881122', 'ChemCorp Manchester', '+44-161-2345678', 'Astra Agro Delhi', '+91-11-23344556', 'Hazardous', 600.00, 3.50, 120000.00, 90000.00, 'Rejected', 'Received at Depot'),
(11, 'AWB-981-88990011', 'Infosys Tech Hub BLR', '+91-80-28520261', 'Tech UK Data Center London', '+44-20-71234567', 'Fragile', 950.00, 6.00, 450000.00, 105000.00, 'Cleared', 'Booked'),
(12, 'AWB-079-33445566', 'Gulf Spices Trading Dubai', '+971-4-3930000', 'ITC Foods Bengaluru', '+91-80-22113344', 'General', 3100.00, 24.00, 90000.00, 78000.00, 'Cleared', 'Received at Depot');

-- ----------------------------------------------------------------------------
-- 20. FLIGHT CARGO MANIFEST
-- ----------------------------------------------------------------------------
INSERT INTO flight_cargo_manifest (manifest_id, flight_id, cargo_id, loaded_at, loading_bay, status) VALUES
(1, 1, 1, TIMESTAMP(CURDATE(), '01:15:00'), 'Forward Hold 1', 'Loaded'),
(2, 5, 2, TIMESTAMP(CURDATE(), '03:20:00'), 'Aft Hold 2', 'Loaded'),
(3, 11, 3, DATE_SUB(NOW(), INTERVAL 140 MINUTE), 'Forward Hold 2', 'Loaded'),
(4, 6, 9, TIMESTAMP(CURDATE(), '09:45:00'), 'Bulk Hold 1', 'Loaded');

-- ----------------------------------------------------------------------------
-- 21. PAYMENTS
-- ----------------------------------------------------------------------------
INSERT INTO payments (payment_id, transaction_reference, reference_type, reference_id, amount, payment_method, payment_status) VALUES
(1, 'TXN-PAY-881901', 'Booking', 1, 68500.00, 'Credit Card', 'Completed'),
(2, 'TXN-PAY-881902', 'Booking', 2, 125000.00, 'Net Banking', 'Completed'),
(3, 'TXN-PAY-881903', 'Booking', 3, 210000.00, 'Credit Card', 'Completed'),
(4, 'TXN-PAY-881904', 'Booking', 4, 4500.00, 'UPI', 'Completed'),
(5, 'TXN-PAY-881905', 'Booking', 5, 7800.00, 'UPI', 'Completed'),
(6, 'TXN-PAY-881906', 'Booking', 6, 89000.00, 'Credit Card', 'Completed'),
(7, 'TXN-PAY-881907', 'Booking', 7, 95000.00, 'Credit Card', 'Completed'),
(8, 'TXN-PAY-881908', 'Booking', 8, 185000.00, 'Wire Transfer', 'Completed'),
(9, 'TXN-PAY-881909', 'Booking', 9, 72000.00, 'Net Banking', 'Completed'),
(10, 'TXN-PAY-881910', 'Booking', 10, 6200.00, 'UPI', 'Completed'),
(11, 'TXN-PAY-881911', 'Cargo', 1, 245000.00, 'Wire Transfer', 'Completed'),
(12, 'TXN-PAY-881912', 'Cargo', 2, 115000.00, 'Wire Transfer', 'Completed'),
(13, 'TXN-PAY-881913', 'Cargo', 3, 185000.00, 'Wire Transfer', 'Completed'),
(14, 'TXN-PAY-881914', 'BaggageFee', 3, 4500.00, 'Debit Card', 'Completed'),
(15, 'TXN-PAY-881915', 'Cargo', 9, 85000.00, 'Wire Transfer', 'Completed');

-- ----------------------------------------------------------------------------
-- 22. INITIAL AUDIT LOGS
-- ----------------------------------------------------------------------------
INSERT INTO audit_logs (log_id, user_id, action_type, entity_table, entity_id, old_value, new_value) VALUES
(1, 1, 'CREATE_FLIGHT', 'flights', 1, NULL, 'Flight AI-101 scheduled DEL->LHR'),
(2, 2, 'ASSIGN_GATE', 'flights', 1, 'Gate NULL', 'Departure Gate 14 Assigned'),
(3, 8, 'LOAD_CARGO', 'flight_cargo_manifest', 1, NULL, 'Cargo AWB-981-10029811 loaded onto AI-101'),
(4, 10, 'CUSTOMS_CLEAR', 'cargo_shipments', 1, 'Status: Pending Inspection', 'Status: Cleared by Officer Rao'),
(5, 10, 'CUSTOMS_CLEAR', 'cargo_shipments', 2, 'Status: Pending Inspection', 'Status: Cleared by Officer Rao'),
(6, 11, 'CUSTOMS_HOLD', 'cargo_shipments', 7, 'Status: Pending Inspection', 'Status: Held for Valuation Verification');

-- ============================================================================
-- END OF SEED DATA
-- ============================================================================
