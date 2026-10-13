import { apiRequest } from '../utils/api.js';
import { escapeHtml, showToast } from '../utils/helpers.js';

export async function loadDashboardStats() {
  try {
    const stats = await apiRequest('/dashboard/stats');

    const elFlights = document.getElementById('stat-active-flights');
    const elPax = document.getElementById('stat-passengers-count');
    const elCargo = document.getElementById('stat-cargo-weight');
    const elGate = document.getElementById('stat-gate-utilization');
    const elConflicts = document.getElementById('stat-gate-conflicts');

    if (elFlights) elFlights.innerText = stats.activeFlightsToday;
    if (elPax) elPax.innerText = stats.passengersCheckedIn.toLocaleString();
    if (elCargo) elCargo.innerText = `${stats.manifestedCargoTons} Tons (${stats.manifestedCargoKg.toLocaleString()} kg)`;
    if (elGate) elGate.innerText = `${stats.gateUtilizationPercentage}%`;
    if (elConflicts) {
      elConflicts.innerText = `${stats.gateConflictsCount} Conflicts`;
      elConflicts.style.color = stats.gateConflictsCount > 0 ? 'var(--accent-rose)' : 'var(--accent-emerald)';
    }

    const elCustoms = document.getElementById('stat-customs-cleared');
    if (elCustoms) elCustoms.innerText = `Customs cleared: ${stats.customsClearedPercentage}%`;
  } catch (err) {
    console.error('Failed to load dashboard stats:', err);
  }
}

export async function loadMasterFlights() {
  const tbody = document.getElementById('tbody-flights-master');
  if (!tbody) return;

  tbody.innerHTML = `<tr><td colspan="8" style="text-align: center; color: var(--text-muted);">Loading live radar...</td></tr>`;

  try {
    const res = await apiRequest('/flights?limit=25');
    const flights = res.flights || [];

    if (flights.length === 0) {
      tbody.innerHTML = `<tr><td colspan="8" style="text-align: center; color: var(--text-muted);">No flights scheduled today.</td></tr>`;
      return;
    }

    tbody.innerHTML = flights.map(f => `
      <tr>
        <td><strong style="color: var(--accent-cyan);">${escapeHtml(f.flight_number)}</strong></td>
        <td>${escapeHtml(f.airline_name)}</td>
        <td><small style="color: var(--text-muted);">${escapeHtml(f.tail_number)}</small><br>${escapeHtml(f.aircraft_model)}</td>
        <td><strong>${escapeHtml(f.origin)} ➔ ${escapeHtml(f.destination)}</strong><br><small style="color: var(--text-muted);">${escapeHtml(f.origin_city)} to ${escapeHtml(f.destination_city)}</small></td>
        <td><strong style="color: var(--accent-amber);">${escapeHtml(f.departure_gate)}</strong></td>
        <td>${escapeHtml(f.scheduled_departure.substring(11, 16))}<br><small style="color: var(--text-muted);">${escapeHtml(f.scheduled_departure.substring(0, 10))}</small></td>
        <td><span class="badge badge-${escapeHtml(f.status.toLowerCase().replace('-', ''))}">${escapeHtml(f.status)}</span></td>
               <td>
          <button class="btn btn-secondary btn-sm" onclick="window.viewFlightSeats(${f.flight_id}, '${escapeHtml(f.flight_number)}')">💺 View Seats</button>
        </td>
      </tr>
    `).join('');
  } catch (err) {
    tbody.innerHTML = `<tr><td colspan="8" style="text-align: center; color: var(--accent-rose);">Failed to load flight schedule. Ensure server is running.</td></tr>`;
  }
}

export function initDashboard() {
  loadDashboardStats();
  loadMasterFlights();

  const refreshBtn = document.getElementById('btn-refresh-flights');
  if (refreshBtn) {
    refreshBtn.addEventListener('click', () => {
      loadDashboardStats();
      loadMasterFlights();
      showToast('Live Radar & Operational Metrics Refreshed!', 'info');
    });
  }

  // Auto-refresh every 30 seconds
  setInterval(() => {
    loadDashboardStats();
  }, 30000);
}
