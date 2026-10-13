# Airport & Airline Passenger and Cargo Logistics Management System 

A production-grade, full-stack Relational Database Management System (DBMS) for international airport operations, passenger journeys, and air freight logistics.

Built with **MySQL 8.0+**, **Node 20 (Express + ES Modules)**, and **Vite (Vanilla JS + Glassmorphism Dark UI)**.

---

## 🏛️ System Architecture

```
[ Vite Web Client :5173 ] 
       │ (REST JSON via HTTP/CORS)
       ▼
[ Express API Server :3000 ] 
       │ (mysql2 Connection Pool with @app_user_id Session Tracking)
       ▼
[ MySQL 8.0 Database :3306 ]
  ├── 22 Normalized Tables (3NF/BCNF)
  ├── Declarative CHECK, UNIQUE & FK Constraints
  ├── Triggers: Gate turnaround, payload capacity, duty hours
  └── Stored Procedures: sp_book_ticket (FOR UPDATE), sp_check_in, sp_clear_customs
```

---

## 🚀 Quick Start (One Command via Docker)

### Prerequisites:
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running.

```bash
# 1. Clone or open the project directory
cd airport_cargo_dbms

# 2. Copy environment configuration
cp .env.example .env

# 3. Start MySQL, Backend API, and Web Client
docker compose up -d
```

Once started:
- 🌐 **Web Interface:** [http://localhost:5173](http://localhost:5173)
- 🔌 **REST API Server:** [http://localhost:3000/api](http://localhost:3000/api)
- 🗄️ **MySQL Database:** `localhost:3306` (Database: `airport_logistics_db`)

---

## 💻 Local Development Setup (Without Docker)

### Prerequisites:
- **Node.js 20+**
- **MySQL 8.0+** running locally

```bash
# 1. Install dependencies
npm install

# 2. Create and provision the database
npm run db:reset

# 3. Start Backend & Frontend concurrently
npm run dev
```

---

## 🔑 Demo Credentials (All demo accounts use password: `password123`)

| Username | Role | Permissions |
|---|---|---|
| `admin_main` | **Admin** | Full system privileges, SQL sandbox, audit logs |
| `ai_ops_lead` | **AirlineStaff** | Flight schedule dispatch, status updates |
| `ground_supervisor` | **GroundStaff** | Gates, passenger check-in, boarding passes, baggage |
| `cargo_depot_mgr` | **CargoHandler** | Freight depot intake, flight hold manifesting |
| `customs_inspector` | **CustomsOfficer** | Cargo inspection decisions (Cleared, Held, Rejected) |
| `pax_aravind` | **Passenger** | Public schedules and personal booking lookup |

---

## 🛡️ Database Engineering Highlights

### 1. Concurrent Seat Locking (`sp_book_ticket`)
Eliminates double-booking race conditions by executing atomic row-level locks using `SELECT ... FOR UPDATE`:
```sql
SELECT aircraft_id FROM flights WHERE flight_id = p_flight_id FOR UPDATE;
SELECT COUNT(*) FROM ticket_seats WHERE flight_id = p_flight_id AND seat_id = p_seat_id AND status <> 'Cancelled' FOR UPDATE;
```

### 2. Multi-Level Gate Integrity
- Ensures departure gates belong strictly to the departure airport.
- Enforces a **45-minute turnaround safety window** to prevent gate collisions.

### 3. Cargo Payload Capacity Verification
Trigger `trg_validate_cargo_manifest` calculates current belly payload weight + new shipment weight and rejects loading if it exceeds `aircraft_types.max_cargo_weight_kg`.

### 4. Aviation Safety Crew Roster Monitor
Enforces the mandatory 14-hour rolling shift limit with soft warning tiers:
- `NORMAL`: $\le 10$ hours
- `WARNING: APPROACHING LIMIT`: $> 10$ and $\le 12$ hours
- `CRITICAL: REST REQUIRED`: $> 12$ hours

---

## 🧪 Testing & Verification

### Run Automated API Integration Tests:
```bash
npm test
```

### Run SQL Assertions & Procedural Verification:
```bash
mysql -u root -p airport_logistics_db < db/tests/test_assertions.sql
```

---

## 📁 Repository Layout

```
airport_cargo_dbms/
├── docker-compose.yml       # Production container orchestration
├── .env.example             # Default environment variables
├── package.json             # Root monorepo orchestration
├── db/
│   ├── schema.sql           # MySQL 8.0 DDL (22 entities, triggers, procedures)
│   ├── seed_data.sql         # Relative sample data across DEL, BOM, BLR, DXB, LHR
│   ├── queries/             # Canonical queries (single source of truth)
│   └── tests/               # SQL constraint assertion test suite
├── server/                  # Node 20 Express REST API (ES modules, zod, mysql2)
├── web/                     # Vite Client (Dark Glassmorphism, responsive, zero XSS)
├── docs/                    # University project report and presentation deck
└── scripts/                 # db-reset.js and db-seed.js
```
