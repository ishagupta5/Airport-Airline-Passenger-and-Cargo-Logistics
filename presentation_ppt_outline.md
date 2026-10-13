# Presentation Deck Outline (PPT)
## Topic: Airport & Airline Passenger and Cargo Logistics Management System DBMS Project

---

### Slide 1: Title Slide
- **Title:** Airport & Airline Passenger and Cargo Logistics Management System
- **Subtitle:** A Relational Database Management System (DBMS) Project
- **Presented By:** B.Tech Computer Science & Engineering (Final Year)
- **Database System:** MySQL 8.0+ / PostgreSQL 15+
- **Speaker Notes:** Good morning, esteemed panel members. Today I am presenting my final-year DBMS project titled "Airport & Airline Passenger and Cargo Logistics Management System".

---

### Slide 2: Project Overview & Context
- **Industry Context:** Aviation hubs handle thousands of flights, passengers, and metric tons of cargo daily.
- **Core Challenge:** Managing simultaneous passenger check-in, seat inventory, gate allocations, crew duty rules, and customs clearance.
- **Solution:** A centralized, multi-tenant 22-entity RDBMS with ACID guarantees.
- **Speaker Notes:** In modern aviation, data consistency and speed are critical. Our system unifies passenger journeys and cargo logistics into a single relational database.

---

### Slide 3: Problem Statement
- **Legacy Limitations:** Spreadsheets & isolated file systems.
- **Key Issues:**
  1. Data redundancy and manifest inconsistencies.
  2. Race conditions during seat reservations (Double booking).
  3. Absence of automated payload capacity checks.
  4. Security risks in customs cargo clearance.
  5. Lack of role-based access control and immutable audit logging.
- **Speaker Notes:** Spreadsheet workbooks lack row-level locking and declarative constraints, leading to dangerous errors in flight capacity and customs clearance.

---

### Slide 4: Project Objectives
- Centralize passenger, airport, fleet, crew, and cargo operations.
- Enforce declarative data constraints (FK, UNIQUE, CHECK).
- Eliminate temporal gate assignment clashes.
- Streamline cargo Air Waybill (AWB) tracking & customs inspection.
- Enforce aviation safety rules ($\le 14$ hrs crew duty hours).
- Enforce Role-Based Access Control (RBAC).

---

### Slide 5: System Users & Role-Based Access
- **Admin:** System configuration & user management.
- **Airline Staff:** Flight dispatch, booking management, crew roster.
- **Ground Staff:** Gate allocation, passenger check-in, baggage tags.
- **Cargo Handler:** Freight depot intake, cargo loading manifests.
- **Customs Officer:** Cargo inspection and clearance approval.
- **Passenger:** Schedule lookup, PNR status, baggage tracking.

---

### Slide 6: System Modules Architecture
1. **Security & Governance:** `system_users`, `audit_logs`
2. **Airport & Infrastructure:** `airports`, `terminals`, `gates`, `runways`
3. **Airlines & Fleet:** `airlines`, `aircraft_types`, `aircraft`, `aircraft_maintenance`
4. **Passenger & Operations:** `passengers`, `flights`, `flight_seats`, `bookings`, `ticket_seats`, `boarding_passes`, `baggage`
5. **Crew Management:** `crew_members`, `flight_crew_assignments`
6. **Cargo Logistics:** `cargo_shipments`, `flight_cargo_manifest`
7. **Financials:** `payments`

---

### Slide 7: Database Design Methodology
- Conceptual Design $\rightarrow$ ER Modeling.
- Logical Design $\rightarrow$ Relational Schema Mapping.
- Physical Design $\rightarrow$ Indexing & Partitioning Strategy.
- Integrity Enforcements $\rightarrow$ Foreign Keys, Triggers, Views.

---

### Slide 8: Entity-Relationship (ER) Model Overview
- **Core Entities:** 22 logical entities.
- **Key Relationships:**
  - Airport $\rightarrow$ Terminal $\rightarrow$ Gate ($1:N$)
  - Airline $\rightarrow$ Aircraft $\rightarrow$ Flight ($1:N$)
  - Flight $\leftrightarrow$ Passenger Booking ($1:N$)
  - Flight $\leftrightarrow$ Crew Members ($M:N$)
  - Flight $\leftrightarrow$ Cargo Shipments ($M:N$)

---

### Slide 9: ER Diagram
- *Visual Diagram Slide:* Embed Mermaid / dbdiagram.io ERD diagram image.
- Highlights primary key to foreign key relationships and cardinalities.

---

### Slide 10: Relational Schema & Integrity Constraints
- Synthetic primary keys (`AUTO_INCREMENT`).
- Referential Integrity with `ON DELETE CASCADE` / `RESTRICT`.
- Declarative `CHECK` Constraints:
  - `length_meters > 500` for runways.
  - `scheduled_arrival > scheduled_departure` for flights.
  - `duty_hours <= 14.00` for flight crew shifts.
  - `weight_kg > 0` for cargo and baggage.

---

### Slide 11: Normalization - The Need for 3NF
- **Motivation:** Eliminate insertion, update, and deletion anomalies.
- **Case Study:** Un-normalized ground manifest sheet (`UNNORMALIZED_MANIFEST`).
- **Anomalies in 0NF:** Multivalued cargo items, repeating passenger lists, transitive dependencies on airport cities.

---

### Slide 12: Normalization Step 1 - 0NF to 1NF
- **Action:** Atomicity enforcement.
- **Transformation:** Removed repeating comma-separated AWB lists into atomic rows.
- **Primary Key:** Composite key `(FlightNo, CargoAWB)`.

---

### Slide 13: Normalization Step 2 - 1NF to 2NF
- **Action:** Removed Partial Functional Dependencies.
- **Separation:**
  - `CARGO` table dependent only on `CargoAWB`.
  - `FLIGHT` table dependent only on `FlightNo`.
  - `MANIFEST` junction table dependent on both `(FlightNo, CargoAWB)`.

---

### Slide 14: Normalization Step 3 - 2NF to 3NF
- **Action:** Removed Transitive Functional Dependencies.
- **Decomposition:**
  - $\text{FlightNo} \rightarrow \text{DepIATA} \rightarrow \text{DepCity}$ split into `AIRPORTS` table.
  - $\text{FlightNo} \rightarrow \text{TailNumber} \rightarrow \text{AircraftModel}$ split into `AIRCRAFT_TYPES` table.
- **Result:** Schema achieved 3NF / BCNF compliance.

---

### Slide 15: Data Dictionary Overview
- Meticulous data dictionary for all 22 tables.
- Standard format: Column Name, Data Type, Nullable, Key, Default, Constraints & Description.

---

### Slide 16: SQL Implementation - Schema DDL Highlights
- Clean DDL executed on MySQL 8.0+.
- Sample DDL snippet for `flights` and `cargo_shipments`.
- Explicit index definitions for fast querying (`iata_code`, `passport_number`, `pnr`, `air_waybill_number`).

---

### Slide 17: Realistic Sample Dataset Scope
- **Geographic Coverage:** DEL (Delhi), BOM (Mumbai), BLR (Bengaluru), DXB (Dubai), LHR (London).
- **Airlines:** Air India, IndiGo, Emirates, British Airways.
- **Fleet Types:** Airbus A320neo, A321neo, Boeing 777-300ER, B787-9, A350-900.
- **Dataset Scale:** 10–15+ realistic rows per core table.

---

### Slide 18: Automation - Triggers & Business Logic
- **Trigger 1: Audit Logging:** Automatically logs flight status updates (e.g. Scheduled $\rightarrow$ Delayed) with timestamp and user ID into `audit_logs`.
- **Trigger 2: Loyalty Rewards:** Automatically awards passenger loyalty points upon PNR confirmation ($\lfloor \text{Total Amount} / 100 \rfloor$).

---

### Slide 19: System Views for Operational Efficiency
- **`vw_flight_schedule_details`:** Denormalized flight schedules with airport names, cities, and departure gates.
- **`vw_flight_cargo_manifest_summary`:** Live payload weight calculation comparing manifested cargo against max aircraft limit.

---

### Slide 20: Complex Analytical Query 1 - Cargo Payload Check
- **Purpose:** Prevent aircraft overload by computing remaining payload capacity ($kg$) before departure.
- *SQL Feature:* `LEFT JOIN`, `SUM()`, `GROUP BY`, `ROUND()`.

---

### Slide 21: Complex Analytical Query 2 - Passenger Itinerary & Baggage Audit
- **Purpose:** Retrieve complete passenger journey details, PNR code, assigned seat, boarding sequence, and checked baggage status.
- *SQL Feature:* Multi-table join across 6 tables (`passengers`, `bookings`, `flights`, `airports`, `boarding_passes`, `baggage`).

---

### Slide 22: Complex Analytical Query 3 - Crew Duty Hour Safety Validation
- **Purpose:** Audit crew duty hours to enforce aviation safety regulations ($\le 14$ hrs limit).
- *SQL Feature:* Calculated columns, `CASE WHEN` conditional flag (`CRITICAL: REST REQUIRED`).

---

### Slide 23: Role-Based Access Control (RBAC) & Security
- DCL `GRANT` statements creating roles: `r_admin`, `r_airline_staff`, `r_ground_staff`, `r_cargo_handler`, `r_customs_officer`, `r_passenger`.
- Ensures customs officers cannot alter flight schedules and airline staff cannot bypass customs clearance flags.

---

### Slide 24: Key Project Outcomes & Results
- Successfully eliminated data redundancy anomalies.
- Enforced real-time ACID transactional integrity for booking & logistics.
- Implemented aviation safety and customs governance constraints.
- Generated full SQL scripts and a 25-30 page project report.

---

### Slide 25: Conclusion & Future Scope
- **Conclusion:** A robust, university-grade DBMS solution for airport logistics management.
- **Future Work:**
  - Real-time RFID IoT baggage tracking.
  - Graph-based dynamic gate collision resolution.
  - Machine learning cargo density optimization.
- **Questions & Answers:** Thank you! Open for questions.

---
**End of Presentation Deck Outline**
