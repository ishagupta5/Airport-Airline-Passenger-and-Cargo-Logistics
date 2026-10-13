import { apiRequest } from '../utils/api.js';
import { escapeHtml, showToast, openModal, closeModal, formatCurrency } from '../utils/helpers.js';

let activeCargoIdForManifest = null;

export function initCargo() {
  loadCargoShipments();
  setupCargoFilters();
  setupNewCargoBooking();
}

function setupCargoFilters() {
  const filterSelect = document.getElementById('cargo-filter-type');
  if (filterSelect) {
    filterSelect.addEventListener('change', () => loadCargoShipments());
  }

  const customsFilter = document.getElementById('cargo-filter-customs');
  if (customsFilter) {
    customsFilter.addEventListener('change', () => loadCargoShipments());
  }
}

export async function loadCargoShipments() {
  const tbody = document.getElementById('tbody-cargo');
  if (!tbody) return;

  const type = document.getElementById('cargo-filter-type')?.value || 'ALL';
  const customs = document.getElementById('cargo-filter-customs')?.value || 'ALL';

  tbody.innerHTML = `<tr><td colspan="8" style="text-align: center; color: var(--text-muted);">Querying freight manifest...</td></tr>`;

  try {
    let queryParams = [];
    if (type !== 'ALL') queryParams.push(`type=${type}`);
    if (customs !== 'ALL') queryParams.push(`customs=${customs}`);

    const queryString = queryParams.length > 0 ? `?${queryParams.join('&')}` : '';
    const shipments = await apiRequest(`/cargo${queryString}`);

    if (shipments.length === 0) {
      tbody.innerHTML = `<tr><td colspan="8" style="text-align: center; color: var(--text-muted); padding: 1.5rem;">No cargo shipments found matching criteria.</td></tr>`;
      return;
    }

    tbody.innerHTML = shipments.map(item => {
      let badgeClass = 'badge-pending';
      if (item.customs_status === 'Cleared') badgeClass = 'badge-cleared';
      if (item.customs_status === 'Held') badgeClass = 'badge-held';
      if (item.customs_status === 'Rejected') badgeClass = 'badge-rejected';

      const holdInfo = item.flight_number 
        ? `<strong style="color: var(--accent-cyan);">${escapeHtml(item.flight_number)}</strong><br><small style="color: var(--text-muted);">${escapeHtml(item.loading_bay || 'Hold')}</small>`
        : `<span style="color: var(--text-muted);">Unassigned</span>`;

      return `
        <tr>
          <td><strong style="font-family: var(--font-mono); color: var(--accent-cyan);">${escapeHtml(item.air_waybill_number)}</strong></td>
          <td>${escapeHtml(item.sender_name)}<br><small style="color: var(--text-muted);">➔ ${escapeHtml(item.receiver_name)}</small></td>
          <td><span class="badge badge-scheduled">${escapeHtml(item.cargo_type)}</span></td>
          <td><strong>${Number(item.weight_kg).toLocaleString()} kg</strong><br><small style="color: var(--text-muted);">${item.volume_m3} m³</small></td>
          <td>${holdInfo}</td>
          <td><span class="badge ${badgeClass}">${escapeHtml(item.customs_status)}</span></td>
          <td><strong>${escapeHtml(item.shipment_status)}</strong></td>
          <td>
            <div style="display: flex; gap: 0.35rem; flex-wrap: wrap;">
              ${item.customs_status === 'Pending Inspection' ? `
                <button class="btn btn-primary btn-sm" onclick="window.updateCustomsDecision(${item.cargo_id}, 'Cleared')">Approve</button>
                <button class="btn btn-secondary btn-sm" onclick="window.updateCustomsDecision(${item.cargo_id}, 'Held')">Hold</button>
                <button class="btn btn-danger btn-sm" onclick="window.updateCustomsDecision(${item.cargo_id}, 'Rejected')">Reject</button>
              ` : ''}
              ${item.customs_status === 'Cleared' && item.shipment_status !== 'Loaded' && item.shipment_status !== 'In-Air' ? `
                <button class="btn btn-secondary btn-sm" onclick="window.openManifestModal(${item.cargo_id}, '${escapeHtml(item.air_waybill_number)}')">Manifest to Flight</button>
              ` : ''}
              ${item.customs_status === 'Cleared' && item.shipment_status === 'Loaded' ? `
                <span style="color: var(--accent-emerald); font-size: 0.8rem;">✓ Manifest Loaded</span>
              ` : ''}
            </div>
          </td>
        </tr>
      `;
    }).join('');
  } catch (err) {
    tbody.innerHTML = `<tr><td colspan="8" style="text-align: center; color: var(--accent-rose);">Failed to load cargo records.</td></tr>`;
  }
}

window.updateCustomsDecision = async function(cargoId, decision) {
  try {
    await apiRequest(`/cargo/${cargoId}/clear-customs`, {
      method: 'POST',
      body: JSON.stringify({ decision })
    });

    showToast(`Customs status updated to '${decision}' in RDBMS!`, 'success');
    loadCargoShipments();
  } catch (err) {
    showToast(`Customs update failed: ${err.message}`, 'error');
  }
};

window.openManifestModal = function(cargoId, awbNumber) {
  activeCargoIdForManifest = cargoId;
  document.getElementById('manifest-modal-awb').innerText = awbNumber;
  openModal('modal-manifest-cargo');
};

function setupNewCargoBooking() {
  const btnSubmitManifest = document.getElementById('btn-submit-manifest');
  if (btnSubmitManifest) {
    btnSubmitManifest.addEventListener('click', async () => {
      const flightId = parseInt(document.getElementById('manifest-flight-id').value, 10);
      const bay = document.getElementById('manifest-loading-bay').value;

      try {
        await apiRequest(`/cargo/${activeCargoIdForManifest}/manifest`, {
          method: 'POST',
          body: JSON.stringify({ flight_id: flightId, loading_bay: bay })
        });

        closeModal('modal-manifest-cargo');
        showToast('Cargo manifested and belly payload verified against max aircraft weight!', 'success');
        loadCargoShipments();
      } catch (err) {
        showToast(`Manifest Error: ${err.message}`, 'error');
      }
    });
  }
}
