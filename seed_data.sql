-- ============================================================================
-- AIRPORT & AIRLINE PASSENGER AND CARGO LOGISTICS MANAGEMENT SYSTEM
-- Seed Sample Data File (10-15+ Rows Per Core Table)
-- Airports: DEL (Delhi), BOM (Mumbai), BLR (Bengaluru), DXB (Dubai), LHR (London)
-- Airlines: Air India (AI), IndiGo (6E), Emirates (EK), British Airways (BA)
-- ============================================================================

USE airport_logistics_db;

-- ----------------------------------------------------------------------------
-- 1. SYSTEM USERS
-- ----------------------------------------------------------------------------
INSERT INTO system_users (username, password_hash, full_name, email, user_role) VALUES
('admin_main', '$2a$12$e8Y/e.V5rJ6U/h5tG6j..OqJmR1Vb.XyTz.4m7L8K9', 'Rajesh Sharma', 'admin@airport.gov.in', 'Admin'),
('ai_ops_lead', '$2a$12$K89h/f.S3m8A/g7tH8k..PqJnS2Wc.YzUa.5n8M9L0', 'Priya Deshmukh', 'p.deshmukh@airindia.in', 'AirlineStaff'),
('indigo_dispatcher', '$2a$12$L90i/g.T4n9B/h8tI9l..QrKoT3Xd.ZaVb.6o9N0M1', 'Amit Kumar', 'a.kumar@goindigo.in', 'AirlineStaff'),
('emirates_rep', '$2a$12$M01j/h.U5o0C/i9tJ0m..RsLpU4Ye.AbWc.7p0O1N2', 'Tariq Al-Mansoor', 't.mansoor@emirates.com', 'AirlineStaff'),
('ba_ops', '$2a$12$N12k/i.V6p1D/j0tK1n..StMqV5Zf.BcXd.8q1P2O3', 'Oliver Smith', 'oliver.smith@ba.com', 'AirlineStaff'),
('ground_supervisor', '$2a$12$O23l/j.W7q2E/k1tL2o..TuNrW6Ag.CdYe.9r2Q3P4', 'Vikram Singh', 'v.singh@dial.in', 'GroundStaff'),
('ramp_controller', '$2a$12$P34m/k.X8r3F/l2tM3p..UvOsX7Bh.DeZf.0s3R4Q5', 'Sunil Verma', 's.verma@mial.in', 'GroundStaff'),
('cargo_depot_mgr', '$2a$12$Q45n/l.Y9s4G/m3tN4q..VwPtY8Ci.EfAg.1t4S5R6', 'Anil Mehta', 'a.mehta@celebbi.in', 'CargoHandler'),
('cargo_loader_1', '$2a$12$R56o/m.Z0t5H/n4tO5r..WxQuZ9Dj.FgBh.2u5T6S7', 'Ramesh Yadav', 'r.yadav@dhad.in', 'CargoHandler'),
('customs_inspector', '$2a$12$S67p/n.A1u6I/o5tP6s..XyRvA0Ek.GhCi.3v6U7T8', 'Inspector S. K. Rao', 'sk.rao@customs.gov.in', 'CustomsOfficer'),
('customs_officer_2', '$2a$12$T78q/o.B2v7J/p6tQ7t..YzSwB1Fl.HiDj.4w7V8U9', 'Officer Neha Nair', 'neha.nair@customs.gov.in', 'CustomsOfficer'),
('pax_aravind', '$2a$12$U89r/p.C3w8K/q7tR8u..ZaTxC2Gm.IjEk.5x8W9V0', 'Aravind Swaminathan', 'aravind.s@gmail.com', 'Passenger');

-- ----------------------------------------------------------------------------
-- 2. AIRPORTS
-- ----------------------------------------------------------------------------
INSERT INTO airports (iata_code, icao_code, name, city, country, timezone, latitude, longitude) VALUES
('DEL', 'VIDP', 'Indira Gandhi International Airport', 'New Delhi', 'India', 'Asia/Kolkata', 28.5562, 77.1000),
('BOM', 'VABB', 'Chhatrapati Shivaji Maharaj International Airport', 'Mumbai', 'India', 'Asia/Kolkata', 19.0896, 72.8656),
('BLR', 'VOBL', 'Kempegowda International Airport', 'Bengaluru', 'India', 'Asia/Kolkata', 13.1986, 77.7066),
('DXB', 'OMDB', 'Dubai International Airport', 'Dubai', 'United Arab Emirates', 'Asia/Dubai', 25.2532, 55.3657),
('LHR', 'EGLL', 'London Heathrow Airport', 'London', 'United Kingdom', 'Europe/London', 51.4700, -0.4543);

-- ----------------------------------------------------------------------------
-- 3. TERMINALS
-- ----------------------------------------------------------------------------
INSERT INTO terminals (airport_id, terminal_name, passenger_capacity, has_cargo_facility) VALUES
(1, 'Terminal 1', 15000000, FALSE),
(1, 'Terminal 3', 40000000, TRUE),
(1, 'Cargo Terminal A', 0, TRUE),
(2, 'Terminal 1', 12000000, FALSE),
(2, 'Terminal 2', 30000000, TRUE),
(2, 'Air Cargo Complex', 0, TRUE),
(3, 'Terminal 1', 25000000, TRUE),
(3, 'Terminal 2', 15000000, FALSE),
(4, 'Terminal 1', 20000000, FALSE),
(4, 'Terminal 3', 35000000, TRUE),
(4, 'Cargo Mega Terminal', 0, TRUE),
(5, 'Terminal 2', 18000000, FALSE),
(5, 'Terminal 5', 30000000, TRUE);

-- ----------------------------------------------------------------------------
-- 4. GATES
-- ----------------------------------------------------------------------------
INSERT INTO gates (terminal_id, gate_number, gate_type, is_operational) VALUES
(2, 'Gate 14', 'International', TRUE),
(2, 'Gate 15', 'International', TRUE),
(2, 'Gate 16', 'International', TRUE),
(1, 'Gate 02', 'Domestic', TRUE),
(1, 'Gate 05', 'Domestic', TRUE),
(5, 'Gate B22', 'International', TRUE),
(5, 'Gate B24', 'International', TRUE),
(7, 'Gate 101', 'Domestic', TRUE),
(7, 'Gate 104', 'International', TRUE),
(10, 'Gate C18', 'International', TRUE),
(10, 'Gate C20', 'International', TRUE),
(13, 'Gate A10', 'International', TRUE),
(13, 'Gate A12', 'International', TRUE),
(3, 'Bay C-01', 'Cargo', TRUE),
(6, 'Bay C-04', 'Cargo', TRUE);

-- ----------------------------------------------------------------------------
-- 5. RUNWAYS
-- ----------------------------------------------------------------------------
INSERT INTO runways (airport_id, runway_identifier, length_meters, surface_type, status) VALUES
(1, '11/29', 4430, 'Asphalt', 'Active'),
(1, '10/28', 3810, 'Concrete', 'Active'),
(1, '09/27', 4280, 'Asphalt', 'Active'),
(2, '09/27', 3448, 'Asphalt', 'Active'),
(2, '14/32', 2925, 'Asphalt', 'Active'),
(3, '09R/27L', 4000, 'Concrete', 'Active'),
(3, '09L/27R', 4000, 'Asphalt', 'Active'),
(4, '12L/30R', 4450, 'Asphalt', 'Active'),
(4, '12R/30L', 4000, 'Asphalt', 'Active'),
(5, '09L/27R', 3902, 'Asphalt', 'Active'),
(5, '09R/27L', 3660, 'Asphalt', 'Active');

-- ----------------------------------------------------------------------------
-- 6. AIRLINES
-- ----------------------------------------------------------------------------
INSERT INTO airlines (iata_code, icao_code, name, country_of_origin, contact_number, email) VALUES
('AI', 'AIC', 'Air India', 'India', '+91-11-24622220', 'support@airindia.in'),
('6E', 'IGO', 'IndiGo', 'India', '+91-124-6173838', 'customer.relations@goindigo.in'),
('EK', 'UAE', 'Emirates', 'United Arab Emirates', '+971-600-555555', 'customer.support@emirates.com'),
('BA', 'BAW', 'British Airways', 'United Kingdom', '+44-344-4930787', 'contact@ba.com');

-- ----------------------------------------------------------------------------
-- 7. AIRCRAFT TYPES
-- ----------------------------------------------------------------------------
INSERT INTO aircraft_types (model_name, manufacturer, passenger_capacity, max_cargo_weight_kg, max_cargo_volume_m3, cruising_speed_kmh) VALUES
('Airbus A320neo', 'Airbus', 186, 4500.00, 37.40, 828),
('Airbus A321neo', 'Airbus', 232, 5800.00, 51.70, 833),
('Boeing 777-300ER', 'Boeing', 342, 20200.00, 150.00, 905),
('Boeing 787-9 Dreamliner', 'Boeing', 290, 16000.00, 125.00, 903),
('Airbus A350-900', 'Airbus', 316, 18500.00, 138.00, 903);

-- ----------------------------------------------------------------------------
-- 8. AIRCRAFT FLEET
-- ----------------------------------------------------------------------------
INSERT INTO aircraft (tail_number, airline_id, type_id, manufacture_year, total_flight_hours, status) VALUES
('VT-EXN', 1, 1, 2018, 14200.50, 'Active'),
('VT-ALX', 1, 3, 2016, 28400.00, 'Active'),
('VT-ANB', 1, 4, 2019, 11800.25, 'Active'),
('VT-IFH', 2, 1, 2020, 9500.00, 'Active'),
('VT-IMQ', 2, 2, 2021, 7200.10, 'Active'),
('VT-ISZ', 2, 1, 2017, 18900.75, 'In Maintenance'),
('A6-EGB', 3, 3, 2017, 24500.00, 'Active'),
('A6-EPN', 3, 3, 2019, 15300.60, 'Active'),
('A6-EVH', 3, 5, 2022, 4100.30, 'Active'),
('G-STBD', 4, 3, 2015, 32100.00, 'Active'),
('G-ZBJA', 4, 4, 2018, 16750.40, 'Active'),
('G-XWBA', 4, 5, 2020, 8900.00, 'Active');

-- ----------------------------------------------------------------------------
-- 9. AIRCRAFT MAINTENANCE
-- ----------------------------------------------------------------------------
INSERT INTO aircraft_maintenance (aircraft_id, maintenance_type, started_at, completed_at, performed_by, description, cost, status) VALUES
(6, 'Routine Inspection', '2026-09-27 08:00:00', '2026-09-28 16:00:00', 'Air Works India Engineering', '500-hour hydraulic line & brake pad check.', 45000.00, 'Completed'),
(2, 'Engine Overhaul', '2026-09-15 06:00:00', '2026-09-25 18:00:00', 'GE Aviation Service Center DEL', 'GE90-115B engine turbine blade inspection.', 420000.00, 'Completed'),
(10, 'C-Check', '2026-09-01 00:00:00', '2026-09-14 23:59:59', 'British Airways Maintenance Cardiff', 'Comprehensive structural & avionics overhaul.', 850000.00, 'Completed'),
(7, 'Avionics Check', '2026-09-28 10:00:00', NULL, 'Emirates Engineering DXB Hub', 'Weather radar sensor calibration.', 28000.00, 'In Progress'),
(1, 'Routine Inspection', '2026-10-05 02:00:00', NULL, 'Air India Engineering Services Ltd', 'Scheduled A-check before international departure.', 15000.00, 'Scheduled');

-- ----------------------------------------------------------------------------
-- 10. PASSENGERS
-- ----------------------------------------------------------------------------
INSERT INTO passengers (first_name, last_name, passport_number, nationality, date_of_birth, gender, email, phone, frequent_flyer_number, loyalty_points) VALUES
('Aravind', 'Swaminathan', 'Z8912345', 'Indian', '1992-04-15', 'Male', 'aravind.s@gmail.com', '+91-9840123456', 'AI-FF-99182', 14500),
('Neha', 'Desai', 'K4519823', 'Indian', '1995-11-20', 'Female', 'neha.desai@yahoo.com', '+91-9820987654', '6E-PERK-112', 3200),
('Rohan', 'Mehta', 'M1290348', 'Indian', '1988-08-05', 'Male', 'rohan.m@techcorp.in', '+91-9811223344', 'AI-FF-44120', 28900),
('Sarah', 'Jenkins', 'GB9821301', 'British', '1990-02-14', 'Female', 'sarah.j@consulting.uk', '+44-7700900123', 'BA-EXEC-991', 45000),
('Mohammed', 'Al-Hashimi', 'UAE881902', 'Emirati', '1985-06-30', 'Male', 'm.hashimi@dubaitrade.ae', '+971-501234567', 'EK-SKY-88210', 82100),
('Ananya', 'Roy', 'R6712940', 'Indian', '1998-01-25', 'Female', 'ananya.roy@outlook.com', '+91-9730554433', NULL, 0),
('Vikramaditya', 'Rao', 'V5519824', 'Indian', '1979-12-10', 'Male', 'v.rao@logistics.in', '+91-9900112233', 'AI-FF-77192', 18900),
('Emma', 'Watson', 'GB1192834', 'British', '1994-09-18', 'Female', 'emma.w@designstudio.uk', '+44-7811223344', 'BA-EXEC-442', 12300),
('Karan', 'Johar', 'P9918273', 'Indian', '1982-03-22', 'Male', 'karan@dharma.in', '+91-9821010101', '6E-PERK-990', 6400),
('Pooja', 'Hegde', 'H3391827', 'Indian', '1993-10-13', 'Female', 'pooja@cinestar.in', '+91-9819998877', 'EK-SKY-33100', 31200),
('David', 'Miller', 'US4491823', 'American', '1987-07-04', 'Male', 'david.miller@nybank.com', '+1-212-5550198', NULL, 0),
('Siddharth', 'Nair', 'N8821903', 'Indian', '1996-05-08', 'Male', 'siddharth.nair@startup.io', '+91-9845098765', 'AI-FF-10023', 8500);

-- ----------------------------------------------------------------------------
-- 11. FLIGHTS
-- ----------------------------------------------------------------------------
INSERT INTO flights (flight_number, airline_id, aircraft_id, departure_airport_id, arrival_airport_id, departure_gate_id, arrival_gate_id, scheduled_departure, scheduled_arrival, actual_departure, actual_arrival, status, delay_reason) VALUES
('AI-101', 1, 2, 1, 5, 2, 12, '2026-09-29 02:30:00', '2026-09-29 07:30:00', NULL, NULL, 'Scheduled', NULL),
('AI-102', 1, 2, 5, 1, 13, 1, '2026-09-29 09:45:00', '2026-09-29 22:50:00', NULL, NULL, 'Scheduled', NULL),
('6E-205', 2, 4, 1, 2, 4, 4, '2026-09-29 06:00:00', '2026-09-29 08:10:00', NULL, NULL, 'Scheduled', NULL),
('6E-508', 2, 5, 2, 3, 5, 8, '2026-09-29 10:15:00', '2026-09-29 11:55:00', NULL, NULL, 'Scheduled', NULL),
('EK-501', 3, 7, 2, 4, 3, 10, '2026-09-29 04:30:00', '2026-09-29 06:15:00', NULL, NULL, 'Scheduled', NULL),
('EK-511', 3, 8, 1, 4, 1, 11, '2026-09-29 11:00:00', '2026-09-29 13:00:00', NULL, NULL, 'Scheduled', NULL),
('BA-198', 4, 10, 2, 5, 3, 12, '2026-09-29 13:15:00', '2026-09-29 18:00:00', NULL, NULL, 'Scheduled', NULL),
('BA-143', 4, 11, 5, 1, 12, 2, '2026-09-29 20:00:00', '2026-09-30 09:30:00', NULL, NULL, 'Scheduled', NULL),
('AI-503', 1, 3, 1, 3, 1, 9, '2026-09-28 14:00:00', '2026-09-28 16:45:00', '2026-09-28 14:25:00', '2026-09-28 17:05:00', 'Arrived', 'ATC Clearance Delay'),
('6E-301', 2, 4, 3, 1, 8, 4, '2026-09-28 18:00:00', '2026-09-28 20:45:00', '2026-09-28 18:02:00', '2026-09-28 20:40:00', 'Arrived', NULL),
('EK-512', 3, 9, 4, 1, 10, 2, '2026-09-28 20:00:00', '2026-09-29 01:00:00', '2026-09-28 20:10:00', NULL, 'In-Air', NULL),
('AI-131', 1, 1, 2, 4, 3, 11, '2026-09-29 16:30:00', '2026-09-29 18:30:00', NULL, NULL, 'Scheduled', NULL);

-- ----------------------------------------------------------------------------
-- 12. FLIGHT SEATS (Sample mapping for Aircraft ID 2: Boeing 777-300ER)
-- ----------------------------------------------------------------------------
INSERT INTO flight_seats (aircraft_id, seat_number, cabin_class, is_exit_row) VALUES
(2, '01A', 'First', FALSE),
(2, '01B', 'First', FALSE),
(2, '02A', 'First', FALSE),
(2, '07A', 'Business', FALSE),
(2, '07K', 'Business', FALSE),
(2, '12A', 'Business', FALSE),
(2, '20A', 'Economy', FALSE),
(2, '20B', 'Economy', FALSE),
(2, '20C', 'Economy', FALSE),
(2, '31A', 'Economy', TRUE),
(2, '31B', 'Economy', TRUE),
(2, '31C', 'Economy', TRUE),
(4, '01A', 'Business', FALSE),
(4, '01B', 'Business', FALSE),
(4, '10A', 'Economy', FALSE),
(4, '10B', 'Economy', FALSE),
(4, '12F', 'Economy', FALSE);

-- ----------------------------------------------------------------------------
-- 13. BOOKINGS
-- ----------------------------------------------------------------------------
INSERT INTO bookings (booking_reference, passenger_id, flight_id, booking_status, total_amount) VALUES
('PNR101A', 1, 1, 'Confirmed', 68500.00),
('PNR101B', 3, 1, 'Confirmed', 125000.00),
('PNR101C', 4, 1, 'Checked-In', 210000.00),
('PNR205A', 2, 3, 'Confirmed', 4500.00),
('PNR205B', 9, 3, 'Confirmed', 7800.00),
('PNR501A', 5, 5, 'Checked-In', 89000.00),
('PNR501B', 10, 5, 'Confirmed', 95000.00),
('PNR198A', 4, 7, 'Confirmed', 185000.00),
('PNR198B', 8, 7, 'Confirmed', 72000.00),
('PNR503A', 7, 9, 'Checked-In', 6200.00),
('PNR301A', 6, 10, 'Checked-In', 5800.00),
('PNR512A', 11, 11, 'Checked-In', 38000.00),
('PNR131A', 12, 12, 'Confirmed', 24500.00);

-- ----------------------------------------------------------------------------
-- 14. TICKET SEATS
-- ----------------------------------------------------------------------------
INSERT INTO ticket_seats (booking_id, seat_id, fare_amount, status) VALUES
(1, 7, 68500.00, 'Reserved'),
(2, 4, 125000.00, 'Reserved'),
(3, 1, 210000.00, 'Checked-In'),
(4, 15, 4500.00, 'Reserved'),
(5, 16, 7800.00, 'Reserved'),
(6, 5, 89000.00, 'Checked-In'),
(7, 6, 9500.00, 'Reserved'),
(8, 5, 185000.00, 'Reserved'),
(9, 8, 72000.00, 'Reserved'),
(10, 9, 6200.00, 'Checked-In'),
(11, 17, 5800.00, 'Checked-In'),
(12, 10, 38000.00, 'Checked-In');

-- ----------------------------------------------------------------------------
-- 15. BOARDING PASSES
-- ----------------------------------------------------------------------------
INSERT INTO boarding_passes (booking_id, ticket_id, gate_id, boarding_time, sequence_number) VALUES
(3, 3, 2, '2026-09-29 01:45:00', 1),
(6, 6, 3, '2026-09-29 03:45:00', 4),
(10, 10, 1, '2026-09-28 13:15:00', 12),
(11, 11, 8, '2026-09-28 17:15:00', 8),
(12, 12, 10, '2026-09-28 19:15:00', 2);

-- ----------------------------------------------------------------------------
-- 16. BAGGAGE LOGISTICS
-- ----------------------------------------------------------------------------
INSERT INTO baggage (booking_id, tag_number, weight_kg, status, is_excess_weight, excess_fee) VALUES
(1, 'BAG-AI-9001A', 21.50, 'Checked-In', FALSE, 0.00),
(1, 'BAG-AI-9001B', 14.00, 'Checked-In', FALSE, 0.00),
(3, 'BAG-AI-1002A', 28.00, 'Loaded', TRUE, 4500.00),
(4, 'BAG-6E-2051A', 12.00, 'Checked-In', FALSE, 0.00),
(6, 'BAG-EK-5011A', 23.00, 'Loaded', FALSE, 0.00),
(6, 'BAG-EK-5011B', 24.50, 'Loaded', FALSE, 0.00),
(10, 'BAG-AI-5031A', 18.00, 'Claimed', FALSE, 0.00),
(11, 'BAG-6E-3011A', 14.50, 'Claimed', FALSE, 0.00),
(12, 'BAG-EK-5121A', 19.80, 'In-Transit', FALSE, 0.00);

-- ----------------------------------------------------------------------------
-- 17. CREW MEMBERS
-- ----------------------------------------------------------------------------
INSERT INTO crew_members (employee_code, first_name, last_name, role, airline_id, license_number, nationality, accumulated_duty_hours) VALUES
('AI-P-001', 'Captain Vikram', 'Batra', 'Captain', 1, 'ATPL-IND-9812', 'Indian', 68.50),
('AI-P-002', 'First Officer Tarun', 'Goyal', 'First Officer', 1, 'CPL-IND-4412', 'Indian', 52.00),
('AI-C-101', 'Sunita', 'Rao', 'Cabin Crew Lead', 1, 'CC-IND-8819', 'Indian', 74.00),
('6E-P-001', 'Captain Sameer', 'Khan', 'Captain', 2, 'ATPL-IND-1120', 'Indian', 80.00),
('6E-P-002', 'First Officer Pooja', 'Sharma', 'First Officer', 2, 'CPL-IND-5590', 'Indian', 61.50),
('EK-P-001', 'Captain Tariq', 'Al-Falasi', 'Captain', 3, 'GCAA-ATPL-901', 'Emirati', 70.00),
('EK-P-002', 'First Officer Jean', 'Dupont', 'First Officer', 3, 'EASA-CPL-7712', 'French', 58.00),
('BA-P-001', 'Captain James', 'Wilson', 'Captain', 4, 'UK-CAA-99120', 'British', 65.00),
('BA-P-002', 'First Officer Claire', 'Taylor', 'First Officer', 4, 'UK-CAA-44192', 'British', 50.00);

-- ----------------------------------------------------------------------------
-- 18. FLIGHT CREW ASSIGNMENTS
-- ----------------------------------------------------------------------------
INSERT INTO flight_crew_assignments (flight_id, crew_id, duty_start, duty_end, assignment_status) VALUES
(1, 1, '2026-09-29 01:00:00', '2026-09-29 08:30:00', 'Assigned'),
(1, 2, '2026-09-29 01:00:00', '2026-09-29 08:30:00', 'Assigned'),
(1, 3, '2026-09-29 01:30:00', '2026-09-29 08:00:00', 'Assigned'),
(3, 4, '2026-09-29 04:30:00', '2026-09-29 09:30:00', 'Assigned'),
(3, 5, '2026-09-29 04:30:00', '2026-09-29 09:30:00', 'Assigned'),
(5, 6, '2026-09-29 03:00:00', '2026-09-29 07:30:00', 'Assigned'),
(5, 7, '2026-09-29 03:00:00', '2026-09-29 07:30:00', 'Assigned'),
(7, 8, '2026-09-29 11:30:00', '2026-09-29 19:30:00', 'Assigned'),
(7, 9, '2026-09-29 11:30:00', '2026-09-29 19:30:00', 'Assigned'),
(9, 1, '2026-09-28 12:30:00', '2026-09-28 18:00:00', 'Completed'),
(10, 4, '2026-09-28 16:30:00', '2026-09-28 21:45:00', 'Completed');

-- ----------------------------------------------------------------------------
-- 19. CARGO SHIPMENTS
-- ----------------------------------------------------------------------------
INSERT INTO cargo_shipments (air_waybill_number, sender_name, sender_contact, receiver_name, receiver_contact, cargo_type, weight_kg, volume_m3, declared_value, freight_charge, customs_status, shipment_status) VALUES
('AWB-981-10029811', 'Sun Pharmaceuticals Mumbai', '+91-22-28210000', 'NHS Procurement London', '+44-20-79460912', 'Perishable', 3500.00, 18.50, 450000.00, 245000.00, 'Cleared', 'Loaded'),
('AWB-981-10029822', 'Tata Electronics Hosur', '+91-4344-200100', 'Foxconn Technology Dubai', '+971-4-8819000', 'Fragile', 1200.00, 8.20, 890000.00, 115000.00, 'Cleared', 'Loaded'),
('AWB-079-88192011', 'Al-Maktoum Trading Dubai', '+971-4-3310000', 'Reliance Retail Delhi', '+91-11-41109999', 'General', 6200.00, 42.00, 180000.00, 185000.00, 'Cleared', 'In-Air'),
('AWB-125-44910293', 'Rolls-Royce Aerospace Derby', '+44-1332-242424', 'Air India Engineering DEL', '+91-11-25652000', 'Hazardous', 850.00, 4.50, 650000.00, 140000.00, 'Pending Inspection', 'Booked'),
('AWB-981-33019844', 'Serum Institute Pune', '+91-20-26993900', 'Ministry of Health UAE', '+971-2-6321000', 'Perishable', 4800.00, 22.00, 1200000.00, 310000.00, 'Cleared', 'Received at Depot'),
('AWB-589-77192033', 'IndiGo Cargo Logistics', '+91-124-6173838', 'Bluedart Express Bengaluru', '+91-80-22990000', 'General', 2100.00, 15.00, 95000.00, 42000.00, 'Cleared', 'Booked'),
('AWB-125-99812044', 'Harrods Department Store London', '+44-20-77301234', 'Luxury Retail Mumbai', '+91-22-66112233', 'Valuable', 420.00, 2.80, 980000.00, 95000.00, 'Held', 'Received at Depot');

-- ----------------------------------------------------------------------------
-- 20. FLIGHT CARGO MANIFEST
-- ----------------------------------------------------------------------------
INSERT INTO flight_cargo_manifest (flight_id, cargo_id, loaded_at, loading_bay, status) VALUES
(1, 1, '2026-09-29 01:15:00', 'Forward Hold 1', 'Loaded'),
(5, 2, '2026-09-29 03:20:00', 'Aft Hold 2', 'Loaded'),
(11, 3, '2026-09-28 19:00:00', 'Forward Hold 2', 'Loaded');

-- ----------------------------------------------------------------------------
-- 21. PAYMENTS
-- ----------------------------------------------------------------------------
INSERT INTO payments (transaction_reference, reference_type, reference_id, amount, payment_method, payment_status) VALUES
('TXN-PAY-881901', 'Booking', 1, 68500.00, 'Credit Card', 'Completed'),
('TXN-PAY-881902', 'Booking', 2, 125000.00, 'Net Banking', 'Completed'),
('TXN-PAY-881903', 'Booking', 3, 210000.00, 'Credit Card', 'Completed'),
('TXN-PAY-881904', 'Booking', 4, 4500.00, 'UPI', 'Completed'),
('TXN-PAY-881905', 'Booking', 5, 7800.00, 'UPI', 'Completed'),
('TXN-PAY-881906', 'Booking', 6, 89000.00, 'Credit Card', 'Completed'),
('TXN-PAY-881907', 'Cargo', 1, 245000.00, 'Wire Transfer', 'Completed'),
('TXN-PAY-881908', 'Cargo', 2, 115000.00, 'Wire Transfer', 'Completed'),
('TXN-PAY-881909', 'BaggageFee', 3, 4500.00, 'Debit Card', 'Completed');

-- ----------------------------------------------------------------------------
-- 22. INITIAL AUDIT LOGS
-- ----------------------------------------------------------------------------
INSERT INTO audit_logs (user_id, action_type, entity_table, entity_id, old_value, new_value) VALUES
(1, 'CREATE_FLIGHT', 'flights', 1, NULL, 'Flight AI-101 scheduled DEL->LHR'),
(2, 'ASSIGN_GATE', 'flights', 1, 'Gate NULL', 'Departure Gate 2 Assigned'),
(8, 'LOAD_CARGO', 'flight_cargo_manifest', 1, NULL, 'Cargo AWB-981-10029811 loaded onto AI-101'),
(10, 'CUSTOMS_CLEAR', 'cargo_shipments', 1, 'Status: Pending Inspection', 'Status: Cleared by Officer Rao');

-- ============================================================================
-- END OF SEED DATA
-- ============================================================================
