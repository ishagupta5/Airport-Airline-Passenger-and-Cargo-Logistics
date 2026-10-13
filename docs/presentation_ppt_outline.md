# Presentation Deck Outline & Defense Script (PPT)
## Topic: Airport & Airline Passenger and Cargo Logistics Management System (DBMS)

---

### Slide 1: Title & Introduction
- **Project Title:** Airport & Airline Passenger and Cargo Logistics Management System
- **Subtitle:** Production-Grade Full-Stack RDBMS with Real-Time ACID Guarantees
- **Candidate:** B.Tech Computer Science & Engineering Final Year Defense
- **Technology Stack:** MySQL 8.0+ (InnoDB Engine), Node 20 (Express REST API), Vite Client (Glassmorphism Dark UI)
- **Key Metric:** 22 Entities, 0 Gate Conflicts, Strict Aviation Safety Enforcement.

---

### Slide 2: Problem Statement & Motivation
- **The Core Problem:** Legacy spreadsheets and flat files cause catastrophic failures in airport operations:
  - Duplicate passenger records and out-of-sync flight manifests.
  - Race conditions causing double-booking of seats during concurrent peak bookings.
  - Gate clashes and lack of turnaround buffer windows.
  - Uninspected hazardous cargo loaded onto passenger flights without customs clearance.
  - Zero auditability or transactional rollback capability.
- **The Solution:** A unified, normalized 3NF database schema enforcing declarative constraints, row-level concurrency locks, and trigger-driven safety checks.

---

### Slide 3: Relational Architecture & ER Model
- **22 Cohesive Entities Organized in 6 Modules:**
  1. *Infrastructure:* Airports, Terminals, Gates, Runways
  2. *Airlines & Fleet:* Airlines, Aircraft Types, Aircraft, Aircraft Maintenance
  3. *Passenger Operations:* Passengers, Flights, Flight Seats, Bookings, Ticket Seats, Boarding Passes, Baggage
  4. *Flight Crew:* Crew Members, Flight Crew Assignments
  5. *Cargo Freight:* Cargo Shipments, Flight Cargo Manifest
  6. *Governance & Security:* System Users, Audit Logs, Payments
- **Cardinality Rules:** Enforces 1:N and M:N associative mapping across operational entities.

---

### Slide 4: Concurrency Control & Double-Booking Elimination
- **The Race Condition:** Concurrent transactions booking the exact same seat on high-demand flights.
- **DBMS Showpiece Solution:** `sp_book_ticket` Stored Procedure
  - Employs `START TRANSACTION` with `SELECT ... FOR UPDATE`.
  - Places exclusive X-locks on flight and seat indexes.
  - Atomic generation of 6-character unique PNR, booking record, ticket seat, and payment.
  - Rollback on exception guarantees zero half-booked orphaned rows.

---

### Slide 5: Multi-Level Gate & Infrastructure Integrity
- **Gate-to-Airport Verification:** Trigger `trg_validate_flight_gates` guarantees departure gates belong strictly to the departure airport.
- **45-Minute Turnaround Safety Window:**
  - Automated trigger rejects assigning two overlapping flights to the same gate within a 45-minute window.
  - Live dashboard metric computes gate conflicts dynamically from real flight timetable data.

---

### Slide 6: Cargo Logistics & Aircraft Payload Enforcement
- **Air Waybill (AWB) Lifecycle:** `Booked` ➔ `Depot` ➔ `Customs Inspection` ➔ `Loaded` ➔ `In-Air` ➔ `Delivered`.
- **Payload Safety Trigger (`trg_validate_cargo_manifest`):**
  - Rejects cargo loading if current manifested weight + shipment weight exceeds `aircraft_types.max_cargo_weight_kg`.
  - Rejects cargo volume exceeding aircraft hold limits.
  - Rejects manifesting cargo if `customs_status <> 'Cleared'`.
  - Blocks hazardous goods on non-DGR certified passenger flights.

---

### Slide 7: Flight Crew Duty Safety Monitor
- **Civil Aviation Regulations Enforcement:**
  - Hard constraint: Maximum 14 hours cumulative rolling duty hours.
  - Soft-warning tiers unified across SQL, API, and UI:
    - $\le 10$ hrs: `NORMAL` (Green)
    - $10$ to $12$ hrs: `WARNING: APPROACHING LIMIT` (Amber)
    - $> 12$ hrs: `CRITICAL: REST REQUIRED` (Rose)

---

### Slide 8: Database Normalization Case Study (0NF ➔ 3NF)
- **Starting Point (0NF):** Flat spreadsheet with repeating cargo lists and multivalued columns.
- **1NF:** Atomic attributes, composite primary key `(FlightNo, CargoAWB)`.
- **2NF:** Elimination of partial dependencies into `Cargo`, `Flights`, and associative `Manifest`.
- **3NF:** Elimination of transitive dependencies ($\text{Flight} \rightarrow \text{DepIATA} \rightarrow \text{City}$) into decoupled `Airports` and `AircraftTypes`.

---

### Slide 9: Role-Based Access Control (RBAC) & Auditability
- **Fine-Grained Permissions (DCL):**
  - `Admin`: Full database access and read-only SQL sandbox execution.
  - `AirlineStaff`: Flight dispatch, schedule management, booking records.
  - `GroundStaff`: Gate management, baggage tagging, boarding pass generation.
  - `CargoHandler`: Depot intake, flight hold manifesting.
  - `CustomsOfficer`: Customs clearance decisions (Cleared, Held, Rejected).
- **Session Audit Trigger:** Triggers capture `@app_user_id` on state changes into immutable `audit_logs`.

---

### Slide 10: Full-Stack Implementation & Live REST API
- **Containerized Architecture:** Docker Compose spins up MySQL 8.0, Express API (:3000), and Vite Client (:5173).
- **Security Engineering:** Parameterized queries only, Zod request validation, Helmet HTTP headers, rate limiting.
- **SQL Sandbox:** Read-only execution console with regex keyword blocking, statement timeouts, row caps, and CSV export.

---

### Slide 11: Experimental Results & Test Assertions
- **Automated Verification:**
  - Parallel booking stress test: exactly 1 transaction wins, duplicate is safely rejected.
  - Overweight cargo manifest: successfully rejected by database trigger.
  - Uncleared cargo loading: rejected with `SQLSTATE 45000`.
  - Gate clash test: 45-minute turnaround window triggers schedule conflict rejection.
- **Lighthouse Performance:** 95+ score with full responsive mobile design and zero XSS vulnerability.

---

### Slide 12: Conclusion & Future Scope
- **Project Achievements:** Transformed an error-prone spreadsheet model into a battle-tested, ACID-compliant RDBMS.
- **Future Roadmap:**
  - Real-time IoT RFID baggage carousel tracking.
  - Machine learning cargo volumetric 3D bin-packing optimization.
- **Questions & Answers:** Open for examiner questions.

---

## ⏱️ 3-Minute Live Project Demonstration Script

### Minute 0:00 – 0:45: Introduction & Operational Dashboard
> "Good morning, respected examiners. Today I am demonstrating the Airport & Airline Passenger and Cargo Logistics Management System. On the main dashboard, all numbers you see—active flights, checked-in passengers, manifested cargo tonnage, and gate conflicts—are computed live from MySQL 8.0 database queries, refreshing automatically. You can see real international hubs: DEL, BOM, BLR, DXB, and LHR."

### Minute 0:45 – 1:30: Passenger Booking & Double-Booking Prevention
> "Next, let's explore passenger booking. In the Passenger tab, I can search flights from Delhi to London. When I select a flight, the system queries `/api/flights/:id/seats` to fetch the exact aircraft cabin layout for that Boeing 777. Notice that occupied seats are locked. When I reserve seat 12A, the system invokes our stored procedure `sp_book_ticket` which acquires a pessimistic `SELECT ... FOR UPDATE` lock on that seat. If another user attempts to book 12A simultaneously, the database safely rejects them. Once confirmed, a 6-character PNR is generated, and checking in immediately issues an official boarding pass with departure gate and sequence number."

### Minute 1:30 – 2:15: Cargo Freight, Payload Checks & Customs Clearance
> "Moving to air freight logistics: In the Cargo tab, we track Air Waybills across their entire lifecycle. Here is shipment AWB-125 for aerospace parts, currently 'Pending Inspection'. Notice that if I attempt to load it onto a flight, the database trigger blocks it because it is not cleared. When I log in as Customs Officer Rao and click 'Approve', the stored procedure `sp_clear_customs` marks it Cleared and records an immutable audit log. Now, when manifesting to flight AI-101, our trigger verifies that the shipment does not exceed the aircraft's 20.2-ton maximum belly payload limit before allowing the manifest."

### Minute 2:15 – 3:00: Safety Monitoring & SQL Execution Sandbox
> "Finally, in the Fleet and Crew tab, our crew audit query enforces the aviation 14-hour duty limit, dynamically warning dispatchers if any pilot exceeds 10 or 12 hours. And in our SQL Sandbox, administrators can execute custom analytical queries—such as cargo payload utilization—running against MySQL with row caps, statement timeouts, and CSV export. The entire system runs in Docker with one command: `docker compose up`. Thank you, and I look forward to your questions."
