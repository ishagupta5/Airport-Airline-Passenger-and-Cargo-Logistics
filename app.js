/* ============================================================================
   AIRPORT & AIRLINE LOGISTICS DBMS - APPLICATION LOGIC
   Synchronized with schema.sql & seed_data.sql
   ============================================================================ */

// MOCK DATABASE DATA (Directly matching seed_data.sql)
const db = {
  airports: [
    { id: 1, iata: 'DEL', name: 'Indira Gandhi International Airport', city: 'New Delhi', country: 'India' },
    { id: 2, iata: 'BOM', name: 'Chhatrapati Shivaji Maharaj Intl Airport', city: 'Mumbai', country: 'India' },
    { id: 3, iata: 'BLR', name: 'Kempegowda International Airport', city: 'Bengaluru', country: 'India' },
    { id: 4, iata: 'DXB', name: 'Dubai International Airport', city: 'Dubai', country: 'UAE' },
    { id: 5, iata: 'LHR', name: 'London Heathrow Airport', city: 'London', country: 'UK' }
  ],

  flights: [
    { flight_id: 1, flight_no: 'AI-101', airline: 'Air India', aircraft: 'Boeing 777-300ER (VT-ALX)', origin: 'DEL', dest: 'LHR', gate: 'Gate 14', dep: '2026-09-29 02:30', status: 'Scheduled', fare: 68500 },
    { flight_id: 2, flight_no: '6E-205', airline: 'IndiGo', aircraft: 'Airbus A320neo (VT-IFH)', origin: 'DEL', dest: 'BOM', gate: 'Gate 02', dep: '2026-09-29 06:00', status: 'Boarding', fare: 4500 },
    { flight_id: 3, flight_no: 'EK-501', airline: 'Emirates', aircraft: 'Boeing 777-300ER (A6-EGB)', origin: 'BOM', dest: 'DXB', gate: 'Gate 16', dep: '2026-09-29 04:30', status: 'Scheduled', fare: 89000 },
    { flight_id: 4, flight_no: 'BA-198', airline: 'British Airways', aircraft: 'Boeing 777-300ER (G-STBD)', origin: 'BOM', dest: 'LHR', gate: 'Gate 16', dep: '2026-09-29 13:15', status: 'Scheduled', fare: 185000 },
    { flight_id: 5, flight_no: 'AI-503', airline: 'Air India', aircraft: 'Boeing 787-9 (VT-ANB)', origin: 'DEL', dest: 'BLR', gate: 'Gate 05', dep: '2026-09-28 14:00', status: 'Arrived', fare: 6200 },
    { flight_id: 6, flight_no: '6E-301', airline: 'IndiGo', aircraft: 'Airbus A320neo (VT-IFH)', origin: 'BLR', dest: 'DEL', gate: 'Gate 101', dep: '2026-09-28 18:00', status: 'Arrived', fare: 5800 },
    { flight_id: 7, flight_no: 'EK-512', airline: 'Emirates', aircraft: 'Airbus A350-900 (A6-EVH)', origin: 'DXB', dest: 'DEL', gate: 'Gate C20', dep: '2026-09-28 20:00', status: 'In-Air', fare: 38000 }
  ],

  passengers: [
    { pnr: 'PNR101A', name: 'Aravind Swaminathan', passport: 'Z8912345', flight: 'AI-101', seat: '07A', status: 'Confirmed', baggage: 'BAG-AI-9001A (21.5kg)' },
    { pnr: 'PNR101C', name: 'Sarah Jenkins', passport: 'GB9821301', flight: 'AI-101', seat: '01A', status: 'Checked-In', baggage: 'BAG-AI-1002A (28.0kg - Excess)' },
    { pnr: 'PNR205A', name: 'Neha Desai', passport: 'K4519823', flight: '6E-205', seat: '12A', status: 'Confirmed', baggage: 'BAG-6E-2051A (12.0kg)' },
    { pnr: 'PNR501A', name: 'Mohammed Al-Hashimi', passport: 'UAE881902', flight: 'EK-501', seat: '01B', status: 'Checked-In', baggage: 'BAG-EK-5011A (23.0kg)' }
  ],

  fleet: [
    { tail: 'VT-EXN', airline: 'Air India', model: 'Airbus A320neo', hours: '14,200 hrs', status: 'Active' },
    { tail: 'VT-ALX', airline: 'Air India', model: 'Boeing 777-300ER', hours: '28,400 hrs', status: 'Active' },
    { tail: 'VT-ISZ', airline: 'IndiGo', model: 'Airbus A320neo', hours: '18,900 hrs', status: 'In Maintenance' },
    { tail: 'A6-EGB', airline: 'Emirates', model: 'Boeing 777-300ER', hours: '24,500 hrs', status: 'Active' },
    { tail: 'G-STBD', airline: 'British Airways', model: 'Boeing 777-300ER', hours: '32,100 hrs', status: 'Active' }
  ],

  crew: [
    { code: 'AI-P-001', name: 'Captain Vikram Batra', role: 'Captain', flight: 'AI-101', duty_times: '01:00 - 08:30', hours: 7.5, status: 'NORMAL' },
    { code: '6E-P-001', name: 'Captain Sameer Khan', role: 'Captain', flight: '6E-205', duty_times: '04:30 - 09:30', hours: 5.0, status: 'NORMAL' },
    { code: 'EK-P-001', name: 'Captain Tariq Al-Falasi', role: 'Captain', flight: 'EK-501', duty_times: '03:00 - 16:30', hours: 13.5, status: 'CRITICAL: REST REQUIRED' },
    { code: 'BA-P-001', name: 'Captain James Wilson', role: 'Captain', flight: 'BA-198', duty_times: '11:30 - 19:30', hours: 8.0, status: 'NORMAL' }
  ],

  cargo: [
    { awb: 'AWB-981-10029811', shipper: 'Sun Pharma ➔ NHS London', type: 'Perishable', weight: '3,500 kg', hold: 'Forward Hold 1 (AI-101)', customs: 'Cleared', pipeline: 'Loaded' },
    { awb: 'AWB-981-10029822', shipper: 'Tata Electronics ➔ Foxconn Dubai', type: 'Fragile', weight: '1,200 kg', hold: 'Aft Hold 2 (EK-501)', customs: 'Cleared', pipeline: 'Loaded' },
    { awb: 'AWB-079-88192011', shipper: 'Al-Maktoum ➔ Reliance Delhi', type: 'General', weight: '6,200 kg', hold: 'Forward Hold 2 (EK-512)', customs: 'Cleared', pipeline: 'In-Air' },
    { awb: 'AWB-125-44910293', shipper: 'Rolls-Royce ➔ Air India Engineering', type: 'Hazardous', weight: '850 kg', hold: 'Unassigned', customs: 'Pending Inspection', pipeline: 'Booked' }
  ]
};

// SQL PRESET QUERIES
const sqlPresets = {
  1: {
    query: `-- Query 1: Flight Cargo Payload & Volume Capacity Utilization
SELECT 
    f.flight_number,
    a.name AS airline_name,
    act.model_name AS aircraft_model,
    act.max_cargo_weight_kg AS max_allowed_cargo_kg,
    IFNULL(SUM(cs.weight_kg), 0.00) AS total_manifested_cargo_kg,
    (act.max_cargo_weight_kg - IFNULL(SUM(cs.weight_kg), 0.00)) AS remaining_capacity_kg,
    ROUND((IFNULL(SUM(cs.weight_kg), 0.00) / act.max_cargo_weight_kg) * 100, 2) AS weight_utilization_pct
FROM flights f
JOIN airlines a ON f.airline_id = a.airline_id
JOIN aircraft ac ON f.aircraft_id = ac.aircraft_id
JOIN aircraft_types act ON ac.type_id = act.type_id
LEFT JOIN flight_cargo_manifest fcm ON f.flight_id = fcm.flight_id
LEFT JOIN cargo_shipments cs ON fcm.cargo_id = cs.cargo_id
GROUP BY f.flight_id, f.flight_number, a.name, act.model_name, act.max_cargo_weight_kg;`,
    headers: ['Flight No', 'Airline', 'Aircraft Model', 'Max Allowed Cargo (kg)', 'Manifested Weight (kg)', 'Remaining Capacity (kg)', 'Utilization %'],
    data: [
      ['AI-101', 'Air India', 'Boeing 777-300ER', '20,200.00', '3,500.00', '16,700.00', '17.33%'],
      ['EK-501', 'Emirates', 'Boeing 777-300ER', '20,200.00', '1,200.00', '19,000.00', '5.94%'],
      ['EK-512', 'Emirates', 'Airbus A350-900', '18,500.00', '6,200.00', '12,300.00', '33.51%']
    ]
  },
  2: {
    query: `-- Query 2: Passenger Complete Flight Itinerary & Checked Baggage Audit
SELECT 
    p.passenger_id,
    CONCAT(p.first_name, ' ', p.last_name) AS passenger_name,
    p.passport_number,
    b.booking_reference AS pnr_code,
    f.flight_number,
    dep.iata_code AS origin,
    arr.iata_code AS destination,
    bp.sequence_number AS boarding_seq,
    IFNULL(bg.tag_number, 'NO BAGGAGE') AS baggage_tag,
    IFNULL(bg.weight_kg, 0.00) AS baggage_weight_kg
FROM passengers p
JOIN bookings b ON p.passenger_id = b.passenger_id
JOIN flights f ON b.flight_id = f.flight_id
JOIN airports dep ON f.departure_airport_id = dep.airport_id
JOIN airports arr ON f.arrival_airport_id = arr.arrival_airport_id
LEFT JOIN boarding_passes bp ON b.booking_id = bp.booking_id
LEFT JOIN baggage bg ON b.booking_id = bg.booking_id;`,
    headers: ['ID', 'Passenger Name', 'Passport', 'PNR Code', 'Flight', 'Route', 'Seq No', 'Baggage Tag', 'Weight (kg)'],
    data: [
      ['1', 'Aravind Swaminathan', 'Z8912345', 'PNR101A', 'AI-101', 'DEL ➔ LHR', '1', 'BAG-AI-9001A', '21.50'],
      ['4', 'Sarah Jenkins', 'GB9821301', 'PNR101C', 'AI-101', 'DEL ➔ LHR', '3', 'BAG-AI-1002A', '28.00'],
      ['2', 'Neha Desai', 'K4519823', 'PNR205A', '6E-205', 'DEL ➔ BOM', '12', 'BAG-6E-2051A', '12.00']
    ]
  },
  3: {
    query: `-- Query 3: Flight Crew Duty Hour Exceedance & Safety Audit
SELECT 
    cm.employee_code,
    CONCAT(cm.first_name, ' ', cm.last_name) AS crew_name,
    cm.role,
    f.flight_number,
    fca.duty_hours,
    CASE 
        WHEN fca.duty_hours > 12.00 THEN 'CRITICAL: REST REQUIRED'
        ELSE 'NORMAL'
    END AS safety_status
FROM flight_crew_assignments fca
JOIN crew_members cm ON fca.crew_id = cm.crew_id
JOIN flights f ON fca.flight_id = f.flight_id;`,
    headers: ['Emp Code', 'Crew Member', 'Role', 'Flight', 'Logged Duty Hours', 'Safety Status'],
    data: [
      ['EK-P-001', 'Captain Tariq Al-Falasi', 'Captain', 'EK-501', '13.50 hrs', 'CRITICAL: REST REQUIRED'],
      ['BA-P-001', 'Captain James Wilson', 'Captain', 'BA-198', '8.00 hrs', 'NORMAL'],
      ['AI-P-001', 'Captain Vikram Batra', 'Captain', 'AI-101', '7.50 hrs', 'NORMAL']
    ]
  }
};

// INITIALIZATION
document.addEventListener('DOMContentLoaded', () => {
  setupTabs();
  renderMasterFlights();
  renderPassengerSearch(db.flights);
  renderFleet();
  renderCrew();
  renderCargo();
  setupSQLConsole();
  setupEventListeners();
});

// TAB NAVIGATION LOGIC
function setupTabs() {
  const btns = document.querySelectorAll('.nav-btn');
  btns.forEach(btn => {
    btn.addEventListener('click', () => {
      btns.forEach(b => b.classList.remove('active'));
      btn.classList.add('active');

      const targetId = btn.getAttribute('data-tab');
      document.querySelectorAll('.tab-content').forEach(tab => tab.classList.remove('active'));
      document.getElementById(targetId).classList.add('active');
    });
  });
}

// RENDER MASTER FLIGHTS
function renderMasterFlights() {
  const tbody = document.getElementById('tbody-flights-master');
  tbody.innerHTML = db.flights.map(f => `
    <tr>
      <td><strong style="color: var(--accent-cyan);">${f.flight_no}</strong></td>
      <td>${f.airline}</td>
      <td>${f.aircraft}</td>
      <td><strong>${f.origin} ➔ ${f.dest}</strong></td>
      <td>${f.gate}</td>
      <td>${f.dep}</td>
      <td><span class="badge badge-${f.status.toLowerCase().replace('-', '')}">${f.status}</span></td>
      <td>
        <button class="btn btn-secondary btn-sm" onclick="openSeatPicker('${f.flight_no}', '${f.aircraft}')">💺 View Seats</button>
      </td>
    </tr>
  `).join('');
}

// RENDER PASSENGER SEARCH
function renderPassengerSearch(flightList) {
  const tbody = document.getElementById('tbody-passenger-search');
  tbody.innerHTML = flightList.map(f => `
    <tr>
      <td><strong style="color: var(--accent-cyan);">${f.flight_no}</strong></td>
      <td>${f.airline}</td>
      <td>${f.origin} ➔ ${f.dest}</td>
      <td>${f.dep}</td>
      <td>${f.dep} (+4 hrs)</td>
      <td>₹${f.fare.toLocaleString('en-IN')}</td>
      <td>
        <button class="btn btn-primary btn-sm" onclick="openSeatPicker('${f.flight_no}', '${f.aircraft}')">Select Seat & Book</button>
      </td>
    </tr>
  `).join('');
}

// RENDER FLEET
function renderFleet() {
  const tbody = document.getElementById('tbody-fleet');
  tbody.innerHTML = db.fleet.map(item => `
    <tr>
      <td><strong style="font-family: var(--font-mono); color: var(--accent-cyan);">${item.tail}</strong></td>
      <td>${item.airline}</td>
      <td>${item.model}</td>
      <td>${item.hours}</td>
      <td><span class="badge badge-${item.status === 'Active' ? 'arrived' : 'delayed'}">${item.status}</span></td>
      <td><button class="btn btn-secondary btn-sm">Inspect Log</button></td>
    </tr>
  `).join('');
}

// RENDER CREW
function renderCrew() {
  const tbody = document.getElementById('tbody-crew');
  tbody.innerHTML = db.crew.map(c => `
    <tr>
      <td><strong style="font-family: var(--font-mono);">${c.code}</strong></td>
      <td>${c.name}</td>
      <td>${c.role}</td>
      <td><strong>${c.flight}</strong></td>
      <td>${c.duty_times}</td>
      <td>
        <strong>${c.hours} hrs</strong>
        <div class="progress-bar-bg">
          <div class="progress-bar-fill fill-${c.hours > 12 ? 'rose' : 'emerald'}" style="width: ${(c.hours / 14) * 100}%;"></div>
        </div>
      </td>
      <td>
        <span class="badge badge-${c.hours > 12 ? 'delayed' : 'cleared'}">${c.status}</span>
      </td>
    </tr>
  `).join('');
}

// RENDER CARGO
function renderCargo() {
  const tbody = document.getElementById('tbody-cargo');
  tbody.innerHTML = db.cargo.map((item, idx) => `
    <tr>
      <td><strong style="font-family: var(--font-mono); color: var(--accent-cyan);">${item.awb}</strong></td>
      <td>${item.shipper}</td>
      <td><span class="badge badge-scheduled">${item.type}</span></td>
      <td>${item.weight}</td>
      <td>${item.hold}</td>
      <td><span class="badge badge-${item.customs === 'Cleared' ? 'cleared' : 'pending'}">${item.customs}</span></td>
      <td><strong>${item.pipeline}</strong></td>
      <td>
        ${item.customs === 'Cleared' 
          ? '<span style="color: var(--accent-emerald); font-size: 0.8rem;">✓ Inspection Cleared</span>' 
          : `<button class="btn btn-primary btn-sm" onclick="clearCustoms(${idx})">Approve Customs</button>`
        }
      </td>
    </tr>
  `).join('');
}

// CLEAR CUSTOMS ACTION
window.clearCustoms = function(idx) {
  db.cargo[idx].customs = 'Cleared';
  db.cargo[idx].pipeline = 'Loaded';
  renderCargo();
  alert(`Customs Inspection Passed for Air Waybill ${db.cargo[idx].awb}! Status updated in RDBMS.`);
};

// PNR LOOKUP
function setupEventListeners() {
  document.getElementById('btn-lookup-pnr').addEventListener('click', () => {
    const inputPnr = document.getElementById('input-pnr').value.trim().toUpperCase();
    const resultBox = document.getElementById('pnr-result-box');

    const found = db.passengers.find(p => p.pnr === inputPnr);
    if (found) {
      resultBox.style.display = 'block';
      resultBox.innerHTML = `
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.75rem;">
          <h4 style="color: var(--accent-cyan); font-size: 1.1rem;">PNR Reference: ${found.pnr}</h4>
          <span class="badge badge-cleared">${found.status}</span>
        </div>
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 1rem; font-size: 0.9rem;">
          <div><strong>Passenger:</strong> ${found.name}</div>
          <div><strong>Passport:</strong> ${found.passport}</div>
          <div><strong>Flight:</strong> ${found.flight}</div>
          <div><strong>Seat Allocated:</strong> <span style="color: var(--accent-emerald); font-weight: 700;">${found.seat}</span></div>
          <div><strong>Luggage Tag:</strong> ${found.baggage}</div>
        </div>
        <button class="btn btn-primary btn-sm" style="margin-top: 1rem;" onclick="generateBoardingPass('${found.pnr}')">🖨️ Issue Boarding Pass</button>
      `;
    } else {
      resultBox.style.display = 'block';
      resultBox.innerHTML = `<span style="color: var(--accent-rose);">PNR Reference '${inputPnr}' not found in database records. Try 'PNR101A'.</span>`;
    }
  });

  // SEARCH FLIGHTS FILTER
  document.getElementById('btn-search-flights').addEventListener('click', () => {
    const origin = document.getElementById('search-origin').value;
    const dest = document.getElementById('search-dest').value;
    const carrier = document.getElementById('search-carrier').value;

    let filtered = db.flights;
    if (origin !== 'ALL') filtered = filtered.filter(f => f.origin === origin);
    if (dest !== 'ALL') filtered = filtered.filter(f => f.dest === dest);
    if (carrier !== 'ALL') filtered = filtered.filter(f => f.airline.includes(carrier));

    renderPassengerSearch(filtered);
  });
}

// MODAL SEAT PICKER
let currentSelectedSeat = null;
window.openSeatPicker = function(flightNo, aircraftModel) {
  document.getElementById('modal-seat-aircraft').innerText = `${flightNo} (${aircraftModel})`;
  const seatGrid = document.getElementById('seat-map-grid');
  
  const seats = ['01A', '01B', '02A', '02B', '07A', '07B', '12A', '12B', '15A', '15B', '20A', '20B'];
  const occupied = ['01A', '07A'];

  seatGrid.innerHTML = seats.map(s => {
    const isOcc = occupied.includes(s);
    return `<div class="seat ${isOcc ? 'occupied' : ''}" onclick="selectSeat(this, '${s}', ${isOcc})">${s}</div>`;
  }).join('');

  document.getElementById('modal-seat-picker').classList.add('active');
};

window.selectSeat = function(el, seatNum, isOcc) {
  if (isOcc) return;
  document.querySelectorAll('.seat').forEach(s => s.classList.remove('selected'));
  el.classList.add('selected');
  currentSelectedSeat = seatNum;
  document.getElementById('selected-seat-label').innerText = `Selected Seat: ${seatNum}`;
  document.getElementById('btn-confirm-seat').disabled = false;
};

document.getElementById('btn-confirm-seat').addEventListener('click', () => {
  alert(`Seat ${currentSelectedSeat} reserved successfully! PNR generated: PNR${Math.floor(100+Math.random()*900)}`);
  closeModal('modal-seat-picker');
});

// BOARDING PASS MODAL
window.generateBoardingPass = function(pnr) {
  const p = db.passengers.find(x => x.pnr === pnr);
  const bpContent = document.getElementById('boarding-pass-content');
  bpContent.innerHTML = `
    <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid rgba(255,255,255,0.2); padding-bottom: 0.75rem; margin-bottom: 0.75rem;">
      <span style="font-weight: 800; font-size: 1.2rem; color: var(--accent-cyan);">AIR INDIA • BOARDING PASS</span>
      <span style="font-family: var(--font-mono); font-size: 0.85rem; color: var(--accent-emerald);">ZONE 1</span>
    </div>
    <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 0.75rem; font-size: 0.85rem;">
      <div><small style="color: var(--text-muted);">PASSENGER</small><br><strong>${p.name}</strong></div>
      <div><small style="color: var(--text-muted);">FLIGHT</small><br><strong style="color: var(--accent-cyan);">${p.flight}</strong></div>
      <div><small style="color: var(--text-muted);">SEAT</small><br><strong style="color: var(--accent-emerald); font-size: 1.1rem;">${p.seat}</strong></div>
      <div><small style="color: var(--text-muted);">ORIGIN ➔ DEST</small><br><strong>DEL ➔ LHR</strong></div>
      <div><small style="color: var(--text-muted);">BOARDING TIME</small><br><strong>01:45 AM</strong></div>
      <div><small style="color: var(--text-muted);">GATE</small><br><strong style="color: var(--accent-amber);">GATE 14</strong></div>
    </div>
    <div class="barcode-sim">||| | |||| | |||||| || | ||| ||||</div>
  `;
  document.getElementById('modal-boarding-pass').classList.add('active');
};

window.closeModal = function(id) {
  document.getElementById(id).classList.remove('active');
};

// SQL CONSOLE SETUP
function setupSQLConsole() {
  const select = document.getElementById('select-sql-preset');
  const editor = document.getElementById('sql-query-editor');

  const updateEditor = () => {
    const val = select.value;
    editor.value = sqlPresets[val].query;
  };

  select.addEventListener('change', updateEditor);
  updateEditor();

  document.getElementById('btn-run-sql').addEventListener('click', () => {
    const val = select.value;
    const preset = sqlPresets[val];

    const thead = document.getElementById('thead-sql-results');
    const tbody = document.getElementById('tbody-sql-results');

    thead.innerHTML = `<tr>${preset.headers.map(h => `<th>${h}</th>`).join('')}</tr>`;
    tbody.innerHTML = preset.data.map(row => `<tr>${row.map(cell => `<td>${cell}</td>`).join('')}</tr>`).join('');
  });
}
