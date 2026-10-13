// Utility to display flight seat map in the seat‑picker modal
import { apiRequest } from './api.js';
import { openModal, closeModal, showToast } from './helpers.js';

/**
 * Load seats for a given flight and open the seat‑picker modal.
 * This mirrors the booking‑flow seat view but does not allow selection.
 *
 * @param {number|string} flightId   The numeric ID of the flight.
 * @param {string}        flightNumber Human‑readable flight number (e.g. "AI‑101").
 */
export async function viewFlightSeats(flightId, flightNumber) {
  const seatGrid = document.getElementById('seat-map-grid');
  if (!seatGrid) {
    showToast('Seat map container not found.', 'error');
    return;
  }

  // Show a loading placeholder and open the modal.
  seatGrid.innerHTML = `<div style="grid-column: span 6; text-align:center; color:var(--text-muted);">
    Loading seat layout…
  </div>`;
  document.getElementById('modal-seat-flight-title').innerText = `${flightNumber} – Seats`;
  const proceedButton = document.getElementById('btn-proceed-to-passenger-form');
  if (proceedButton) proceedButton.style.display = 'none';
  openModal('modal-seat-picker');

  try {
    const { seats = [] } = await apiRequest(`/flights/${flightId}/seats`);
    // Re‑use the same markup as the booking flow – seats are clickable but the
    // selection handler will simply ignore occupied seats. This gives a familiar UI.
    seatGrid.innerHTML = seats.map(s => {
  const occupied = Number(s.is_occupied) === 1;
  const classes = `seat ${occupied ? 'occupied' : ''} ${s.is_exit_row ? 'exit-row' : ''}`;

  return `<div class="${classes}"
    title="Seat ${s.seat_number} - ${s.cabin_class}"
    onclick="this.classList.toggle('seat-info-selected'); document.getElementById('selected-seat-label').innerText = 'Seat: ${s.seat_number} (${s.cabin_class}) - ${occupied ? 'Occupied' : 'Available'}'">
    ${s.seat_number}
  </div>`;
}).join('');
  } catch (err) {
    seatGrid.innerHTML = `<div style="grid-column: span 6; text-align:center; color:var(--accent-rose);">
      Failed to load seats: ${err.message}
    </div>`;
    // Keep the modal open so the user can see the error.
  }
}
