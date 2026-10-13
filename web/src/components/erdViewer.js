import { escapeHtml, openModal } from '../utils/helpers.js';

// Table Metadata for Interactive Schema Exploration
const schemaMetadata = {
  airports: {
    name: 'airports',
    module: 'Infrastructure',
    pk: 'airport_id',
    columns: [
      { name: 'airport_id', type: 'INT AUTO_INCREMENT', key: 'PK' },
      { name: 'iata_code', type: 'VARCHAR(3)', key: 'UNIQUE' },
      { name: 'icao_code', type: 'VARCHAR(4)', key: 'UNIQUE' },
      { name: 'name', type: 'VARCHAR(150)', key: '' },
      { name: 'city', type: 'VARCHAR(100)', key: '' },
      { name: 'country', type: 'VARCHAR(100)', key: '' },
      { name: 'timezone', type: 'VARCHAR(50)', key: '' }
    ],
    relations: ['terminals (1:N)', 'runways (1:N)', 'flights (1:N)']
  },
  terminals: {
    name: 'terminals',
    module: 'Infrastructure',
    pk: 'terminal_id',
    columns: [
      { name: 'terminal_id', type: 'INT AUTO_INCREMENT', key: 'PK' },
      { name: 'airport_id', type: 'INT', key: 'FK' },
      { name: 'terminal_name', type: 'VARCHAR(50)', key: '' },
      { name: 'passenger_capacity', type: 'INT', key: '' }
    ],
    relations: ['airports (N:1)', 'gates (1:N)']
  },
  gates: {
    name: 'gates',
    module: 'Infrastructure',
    pk: 'gate_id',
    columns: [
      { name: 'gate_id', type: 'INT AUTO_INCREMENT', key: 'PK' },
      { name: 'terminal_id', type: 'INT', key: 'FK' },
      { name: 'gate_number', type: 'VARCHAR(10)', key: '' },
      { name: 'gate_type', type: 'ENUM', key: '' }
    ],
    relations: ['terminals (N:1)', 'flights (1:N)']
  },
  airlines: {
    name: 'airlines',
    module: 'Airlines & Fleet',
    pk: 'airline_id',
    columns: [
      { name: 'airline_id', type: 'INT AUTO_INCREMENT', key: 'PK' },
      { name: 'iata_code', type: 'VARCHAR(2)', key: 'UNIQUE' },
      { name: 'name', type: 'VARCHAR(100)', key: '' },
      { name: 'country_of_origin', type: 'VARCHAR(100)', key: '' }
    ],
    relations: ['aircraft (1:N)', 'flights (1:N)', 'crew_members (1:N)']
  },
  aircraft: {
    name: 'aircraft',
    module: 'Airlines & Fleet',
    pk: 'aircraft_id',
    columns: [
      { name: 'aircraft_id', type: 'INT AUTO_INCREMENT', key: 'PK' },
      { name: 'tail_number', type: 'VARCHAR(20)', key: 'UNIQUE' },
      { name: 'airline_id', type: 'INT', key: 'FK' },
      { name: 'type_id', type: 'INT', key: 'FK' },
      { name: 'status', type: 'ENUM', key: '' }
    ],
    relations: ['airlines (N:1)', 'aircraft_types (N:1)', 'flights (1:N)', 'flight_seats (1:N)']
  },
  flights: {
    name: 'flights',
    module: 'Passenger & Operations',
    pk: 'flight_id',
    columns: [
      { name: 'flight_id', type: 'INT AUTO_INCREMENT', key: 'PK' },
      { name: 'flight_number', type: 'VARCHAR(10)', key: '' },
      { name: 'airline_id', type: 'INT', key: 'FK' },
      { name: 'aircraft_id', type: 'INT', key: 'FK' },
      { name: 'departure_airport_id', type: 'INT', key: 'FK' },
      { name: 'arrival_airport_id', type: 'INT', key: 'FK' },
      { name: 'departure_gate_id', type: 'INT', key: 'FK' },
      { name: 'scheduled_departure', type: 'DATETIME', key: '' },
      { name: 'scheduled_arrival', type: 'DATETIME', key: '' },
      { name: 'status', type: 'ENUM', key: '' }
    ],
    relations: ['bookings (1:N)', 'flight_crew_assignments (1:N)', 'flight_cargo_manifest (1:N)']
  },
  bookings: {
    name: 'bookings',
    module: 'Passenger & Operations',
    pk: 'booking_id',
    columns: [
      { name: 'booking_id', type: 'INT AUTO_INCREMENT', key: 'PK' },
      { name: 'booking_reference', type: 'VARCHAR(8)', key: 'UNIQUE (PNR)' },
      { name: 'passenger_id', type: 'INT', key: 'FK' },
      { name: 'flight_id', type: 'INT', key: 'FK' },
      { name: 'booking_status', type: 'ENUM', key: '' },
      { name: 'total_amount', type: 'DECIMAL(10,2)', key: '' }
    ],
    relations: ['ticket_seats (1:N)', 'boarding_passes (1:1)', 'baggage (1:N)', 'payments (1:1)']
  },
  cargo_shipments: {
    name: 'cargo_shipments',
    module: 'Cargo Logistics',
    pk: 'cargo_id',
    columns: [
      { name: 'cargo_id', type: 'INT AUTO_INCREMENT', key: 'PK' },
      { name: 'air_waybill_number', type: 'VARCHAR(20)', key: 'UNIQUE (AWB)' },
      { name: 'sender_name', type: 'VARCHAR(100)', key: '' },
      { name: 'cargo_type', type: 'ENUM', key: '' },
      { name: 'weight_kg', type: 'DECIMAL(10,2)', key: '' },
      { name: 'customs_status', type: 'ENUM', key: '' },
      { name: 'shipment_status', type: 'ENUM', key: '' }
    ],
    relations: ['flight_cargo_manifest (1:N)', 'payments (1:1)']
  }
};

export function initERDViewer() {
  const container = document.getElementById('erd-cards-container');
  if (!container) return;

  container.innerHTML = Object.keys(schemaMetadata).map(key => {
    const table = schemaMetadata[key];
    return `
      <div class="stat-card" style="cursor: pointer;" onclick="window.viewTableSchema('${key}')">
        <div class="stat-header">
          <span class="stat-title">${escapeHtml(table.module)}</span>
          <span style="font-size: 0.8rem; color: var(--accent-cyan); font-family: var(--font-mono);">PK: ${table.pk}</span>
        </div>
        <div style="font-size: 1.25rem; font-weight: 700; color: #ffffff; margin-bottom: 0.5rem;">
          🗄️ ${escapeHtml(table.name)}
        </div>
        <div style="font-size: 0.8rem; color: var(--text-muted);">
          Columns: ${table.columns.length} • Relations: ${table.relations.length}
        </div>
      </div>
    `;
  }).join('');
}

window.viewTableSchema = function(key) {
  const table = schemaMetadata[key];
  if (!table) return;

  document.getElementById('erd-modal-title').innerText = `Table Schema: ${table.name}`;
  const content = document.getElementById('erd-modal-content');

  content.innerHTML = `
    <div style="margin-bottom: 1rem;">
      <span class="badge badge-scheduled">Module: ${escapeHtml(table.module)}</span>
      <span class="badge badge-cleared" style="margin-left: 0.5rem;">Primary Key: ${escapeHtml(table.pk)}</span>
    </div>

    <h4 style="margin-bottom: 0.5rem; color: var(--text-secondary);">Columns & Types:</h4>
    <table class="data-table" style="margin-bottom: 1.5rem;">
      <thead>
        <tr>
          <th>Column Name</th>
          <th>Data Type</th>
          <th>Key Attribute</th>
        </tr>
      </thead>
      <tbody>
        ${table.columns.map(c => `
          <tr>
            <td><strong style="color: var(--accent-cyan); font-family: var(--font-mono);">${escapeHtml(c.name)}</strong></td>
            <td>${escapeHtml(c.type)}</td>
            <td>${c.key ? `<span class="badge badge-${c.key === 'PK' ? 'cleared' : 'boarding'}">${escapeHtml(c.key)}</span>` : '<span style="color: var(--text-muted);">-</span>'}</td>
          </tr>
        `).join('')}
      </tbody>
    </table>

    <h4 style="margin-bottom: 0.5rem; color: var(--text-secondary);">Relational Foreign Key Connections:</h4>
    <ul style="padding-left: 1.25rem; color: var(--text-primary); font-size: 0.875rem;">
      ${table.relations.map(r => `<li>${escapeHtml(r)}</li>`).join('')}
    </ul>
  `;

  openModal('modal-erd-details');
};
