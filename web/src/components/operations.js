import { apiRequest } from '../utils/api.js';
import { escapeHtml, showToast, openModal } from '../utils/helpers.js';

export function initOperations() {
  loadFleetData();
  loadCrewData();
}

export async function loadFleetData() {
  const tbody = document.getElementById('tbody-fleet');
  if (!tbody) return;

  tbody.innerHTML = `<tr><td colspan="6" style="text-align: center; color: var(--text-muted);">Loading fleet fleet registry...</td></tr>`;

  try {
    const fleet = await apiRequest('/fleet');

    tbody.innerHTML = fleet.map(ac => `
      <tr>
        <td><strong style="font-family: var(--font-mono); color: var(--accent-cyan);">${escapeHtml(ac.tail_number)}</strong></td>
        <td>${escapeHtml(ac.airline_name)}</td>
        <td>${escapeHtml(ac.model_name)}</td>
        <td>${escapeHtml(Number(ac.total_flight_hours).toLocaleString())} hrs</td>
        <td><span class="badge badge-${ac.status === 'Active' ? 'arrived' : 'delayed'}">${escapeHtml(ac.status)}</span></td>
        <td>
          <button class="btn btn-secondary btn-sm" onclick="window.inspectMaintenance('${escapeHtml(ac.tail_number)}')">
            Inspect Log
          </button>
        </td>
      </tr>
    `).join('');
  } catch (err) {
    tbody.innerHTML = `<tr><td colspan="6" style="text-align: center; color: var(--accent-rose);">Failed to load fleet data.</td></tr>`;
  }
}

window.inspectMaintenance = async function(tail) {
  try {
    const data = await apiRequest(`/fleet/${tail}/maintenance`);
    const records = data.maintenance_records || [];

    const container = document.getElementById('maintenance-modal-content');
    document.getElementById('maintenance-modal-tail').innerText = tail;

    if (records.length === 0) {
      container.innerHTML = `<p style="color: var(--text-muted); padding: 1.5rem; text-align: center;">No recorded maintenance incidents or scheduled overhauls for aircraft ${escapeHtml(tail)}.</p>`;
    } else {
      container.innerHTML = `
        <table class="data-table">
          <thead>
            <tr>
              <th>Type</th>
              <th>Started</th>
              <th>Completed</th>
              <th>Facility / Performed By</th>
              <th>Description</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody>
            ${records.map(r => `
              <tr>
                <td><strong>${escapeHtml(r.maintenance_type)}</strong></td>
                <td>${escapeHtml(r.started_at?.substring(0, 16) || 'N/A')}</td>
                <td>${escapeHtml(r.completed_at?.substring(0, 16) || 'In Progress')}</td>
                <td>${escapeHtml(r.performed_by)}</td>
                <td><small>${escapeHtml(r.description)}</small></td>
                <td><span class="badge badge-${r.status === 'Completed' ? 'cleared' : 'pending'}">${escapeHtml(r.status)}</span></td>
              </tr>
            `).join('')}
          </tbody>
        </table>
      `;
    }

    openModal('modal-maintenance-history');
  } catch (err) {
    showToast(`Error fetching maintenance log: ${err.message}`, 'error');
  }
};

export async function loadCrewData() {
  const tbody = document.getElementById('tbody-crew');
  if (!tbody) return;

  tbody.innerHTML = `<tr><td colspan="7" style="text-align: center; color: var(--text-muted);">Auditing crew rosters...</td></tr>`;

  try {
    const crew = await apiRequest('/crew/duty-audit');

    tbody.innerHTML = crew.map(c => {
      const hours = parseFloat(c.duty_hours);
      const pct = Math.min(100, Math.round((hours / 14.0) * 100));

      let fillClass = 'fill-emerald';
      let badgeClass = 'badge-cleared';

      if (c.duty_safety_status.includes('CRITICAL')) {
        fillClass = 'fill-rose';
        badgeClass = 'badge-delayed';
      } else if (c.duty_safety_status.includes('WARNING')) {
        fillClass = 'fill-amber';
        badgeClass = 'badge-boarding';
      }

      return `
        <tr>
          <td><strong style="font-family: var(--font-mono);">${escapeHtml(c.employee_code)}</strong></td>
          <td>${escapeHtml(c.crew_name)}</td>
          <td>${escapeHtml(c.role)}</td>
          <td><strong>${escapeHtml(c.flight_number)}</strong></td>
          <td><small>${escapeHtml(c.duty_start?.substring(11, 16))} to ${escapeHtml(c.duty_end?.substring(11, 16))}</small></td>
          <td>
            <strong>${hours.toFixed(1)} hrs</strong> / 14h limit
            <div class="progress-bar-bg">
              <div class="progress-bar-fill ${fillClass}" style="width: ${pct}%;"></div>
            </div>
          </td>
          <td>
            <span class="badge ${badgeClass}">${escapeHtml(c.duty_safety_status)}</span>
          </td>
        </tr>
      `;
    }).join('');
  } catch (err) {
    tbody.innerHTML = `<tr><td colspan="7" style="text-align: center; color: var(--accent-rose);">Failed to audit crew rosters.</td></tr>`;
  }
}
