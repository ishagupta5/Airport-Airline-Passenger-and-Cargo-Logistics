import { apiRequest } from '../utils/api.js';
import { escapeHtml, showToast } from '../utils/helpers.js';

const sqlPresets = {
  1: `-- Query 1: Flight Cargo Payload & Volume Capacity Utilization
SELECT 
    f.flight_id,
    f.flight_number,
    a.name AS airline_name,
    act.model_name AS aircraft_model,
    act.max_cargo_weight_kg AS max_allowed_weight_kg,
    IFNULL(SUM(cs.weight_kg), 0.00) AS total_manifested_cargo_weight_kg,
    (act.max_cargo_weight_kg - IFNULL(SUM(cs.weight_kg), 0.00)) AS remaining_cargo_capacity_kg,
    ROUND((IFNULL(SUM(cs.weight_kg), 0.00) / act.max_cargo_weight_kg) * 100, 2) AS cargo_weight_utilization_pct
FROM flights f
JOIN airlines a ON f.airline_id = a.airline_id
JOIN aircraft ac ON f.aircraft_id = ac.aircraft_id
JOIN aircraft_types act ON ac.type_id = act.type_id
LEFT JOIN flight_cargo_manifest fcm ON f.flight_id = fcm.flight_id
LEFT JOIN cargo_shipments cs ON fcm.cargo_id = cs.cargo_id
GROUP BY f.flight_id, f.flight_number, a.name, act.model_name, act.max_cargo_weight_kg
ORDER BY cargo_weight_utilization_pct DESC`,

  2: `-- Query 2: Passenger Complete Flight Itinerary & Checked Baggage Audit
SELECT 
    p.passenger_id,
    CONCAT(p.first_name, ' ', p.last_name) AS passenger_name,
    p.passport_number,
    b.booking_reference AS pnr_code,
    b.booking_status,
    f.flight_number,
    dep.iata_code AS origin,
    arr.iata_code AS destination,
    IFNULL(bp.sequence_number, 0) AS boarding_seq,
    IFNULL(bg.tag_number, 'NO BAGGAGE') AS baggage_tag,
    IFNULL(bg.weight_kg, 0.00) AS baggage_weight_kg,
    IFNULL(bg.status, 'N/A') AS baggage_status
FROM passengers p
JOIN bookings b ON p.passenger_id = b.passenger_id
JOIN flights f ON b.flight_id = f.flight_id
JOIN airports dep ON f.departure_airport_id = dep.airport_id
JOIN airports arr ON f.arrival_airport_id = arr.airport_id
LEFT JOIN boarding_passes bp ON b.booking_id = bp.booking_id
LEFT JOIN baggage bg ON b.booking_id = bg.booking_id
WHERE b.booking_status IN ('Confirmed', 'Checked-In')
ORDER BY p.passenger_id, f.scheduled_departure`,

  3: `-- Query 3: Flight Crew Duty Hour Exceedance & Safety Audit
SELECT 
    cm.employee_code,
    CONCAT(cm.first_name, ' ', cm.last_name) AS crew_name,
    cm.role,
    al.name AS airline_name,
    f.flight_number,
    fca.duty_start,
    fca.duty_end,
    fca.duty_hours,
    CASE 
        WHEN fca.duty_hours > 12.00 THEN 'CRITICAL: REST REQUIRED'
        WHEN fca.duty_hours > 10.00 THEN 'WARNING: APPROACHING LIMIT'
        ELSE 'NORMAL'
    END AS duty_safety_status
FROM flight_crew_assignments fca
JOIN crew_members cm ON fca.crew_id = cm.crew_id
JOIN airlines al ON cm.airline_id = al.airline_id
JOIN flights f ON fca.flight_id = f.flight_id
ORDER BY fca.duty_hours DESC`
};

let lastQueryResults = null;

export function initSQLSandbox() {
  const selectPreset = document.getElementById('select-sql-preset');
  const editor = document.getElementById('sql-query-editor');
  const btnRun = document.getElementById('btn-run-sql');
  const btnExport = document.getElementById('btn-export-csv');

  if (selectPreset && editor) {
    selectPreset.addEventListener('change', () => {
      const val = selectPreset.value;
      if (sqlPresets[val]) {
        editor.value = sqlPresets[val];
      }
    });

    // Initial load
    editor.value = sqlPresets[1];
  }

  if (btnRun && editor) {
    btnRun.addEventListener('click', async () => {
      const query = editor.value.trim();
      const thead = document.getElementById('thead-sql-results');
      const tbody = document.getElementById('tbody-sql-results');
      const metaBox = document.getElementById('sql-meta-info');

      if (!query) {
        showToast('Please enter an SQL query to execute.', 'warning');
        return;
      }

      btnRun.disabled = true;
      btnRun.innerText = 'Executing query...';
      tbody.innerHTML = `<tr><td colspan="10" style="text-align: center; color: var(--text-muted);">Executing read-only query on MySQL...</td></tr>`;

      try {
        const res = await apiRequest('/sql/run', {
          method: 'POST',
          body: JSON.stringify({ query })
        });

        lastQueryResults = res;

        if (metaBox) {
          metaBox.innerHTML = `
            <span style="color: var(--accent-emerald);">✓ Success:</span> Returned <strong>${res.rowCount} rows</strong> in <strong>${res.executionTimeMs} ms</strong>.
          `;
        }

        const columns = res.columns || [];
        const rows = res.rows || [];

        thead.innerHTML = `<tr>${columns.map(c => `<th>${escapeHtml(c)}</th>`).join('')}</tr>`;

        if (rows.length === 0) {
          tbody.innerHTML = `<tr><td colspan="${Math.max(1, columns.length)}" style="text-align: center; color: var(--text-muted); padding: 1.5rem;">Query returned 0 rows.</td></tr>`;
        } else {
          tbody.innerHTML = rows.map(r => `
            <tr>${columns.map(c => `<td>${escapeHtml(r[c] !== null && r[c] !== undefined ? r[c] : 'NULL')}</td>`).join('')}</tr>
          `).join('');
        }

        if (btnExport) btnExport.style.display = 'inline-flex';
      } catch (err) {
        if (metaBox) {
          metaBox.innerHTML = `<span style="color: var(--accent-rose);">Execution Error: ${escapeHtml(err.message)}</span>`;
        }
        tbody.innerHTML = `<tr><td colspan="10" style="text-align: center; color: var(--accent-rose);">${escapeHtml(err.message)}</td></tr>`;
      } finally {
        btnRun.disabled = false;
        btnRun.innerText = 'Execute SQL Query';
      }
    });
  }

  if (btnExport) {
    btnExport.addEventListener('click', () => {
      if (!lastQueryResults || !lastQueryResults.rows || lastQueryResults.rows.length === 0) {
        showToast('No query data to export.', 'warning');
        return;
      }

      const columns = lastQueryResults.columns;
      const csvRows = [];
      csvRows.push(columns.join(','));

      for (const row of lastQueryResults.rows) {
        const values = columns.map(c => {
          const val = row[c] === null || row[c] === undefined ? '' : String(row[c]);
          return `"${val.replace(/"/g, '""')}"`;
        });
        csvRows.push(values.join(','));
      }

      const blob = new Blob([csvRows.join('\n')], { type: 'text/csv' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `query_result_${Date.now()}.csv`;
      a.click();
      URL.revokeObjectURL(url);
      showToast('Exported CSV file successfully!', 'success');
    });
  }
}
