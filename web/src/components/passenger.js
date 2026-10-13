import { apiRequest } from '../utils/api.js';
import { escapeHtml, showToast, openModal, closeModal, formatCurrency } from '../utils/helpers.js';

let activeFlightForBooking = null;
let selectedSeatId = null;
let selectedSeatNumber = null;
let selectedSeatFare = 68500;

export function initPassenger() {
  setupFlightSearch();
  setupPNRLookup();
  setupBookingForm();
}

function setupFlightSearch() {
  const btnSearch = document.getElementById('btn-search-flights');
  if (!btnSearch) return;

  btnSearch.addEventListener('click', async () => {
    const origin = document.getElementById('search-origin').value;
    const dest = document.getElementById('search-dest').value;
    const carrier = document.getElementById('search-carrier').value;
    const date = document.getElementById('search-date')?.value;

    if (origin !== 'ALL' && dest !== 'ALL' && origin === dest) {
      showToast('Validation Error: Origin and Destination airports cannot be identical.', 'error');
      return;
    }

    const tbody = document.getElementById('tbody-passenger-search');
    tbody.innerHTML = `<tr><td colspan="7" style="text-align: center; color: var(--text-muted);">Searching flights...</td></tr>`;

    try {
      let queryParams = [];
      if (origin !== 'ALL') queryParams.push(`origin=${origin}`);
      if (dest !== 'ALL') queryParams.push(`dest=${dest}`);
      if (carrier !== 'ALL') queryParams.push(`carrier=${encodeURIComponent(carrier)}`);
      if (date) queryParams.push(`date=${date}`);

      const queryString = queryParams.length > 0 ? `?${queryParams.join('&')}` : '';
      const res = await apiRequest(`/flights${queryString}`);
      const flights = res.flights || [];

      if (flights.length === 0) {
        tbody.innerHTML = `<tr><td colspan="7" style="text-align: center; color: var(--text-muted); padding: 2rem;">No matching flights found for this route. Try changing search criteria.</td></tr>`;
        return;
      }

      tbody.innerHTML = flights.map(f => {
        // Base fare based on duration
        const fare = Math.round((f.duration_hours || 2.5) * 8500);

        return `
          <tr>
            <td><strong style="color: var(--accent-cyan);">${escapeHtml(f.flight_number)}</strong></td>
            <td>${escapeHtml(f.airline_name)}</td>
            <td><strong>${escapeHtml(f.origin)} ➔ ${escapeHtml(f.destination)}</strong></td>
            <td>${escapeHtml(f.scheduled_departure.substring(11, 16))}<br><small style="color: var(--text-muted);">${escapeHtml(f.origin_timezone)}</small></td>
            <td>${escapeHtml(f.scheduled_arrival.substring(11, 16))}<br><small style="color: var(--text-muted);">${escapeHtml(f.destination_timezone)} (${escapeHtml(f.duration_hours)}h)</small></td>
            <td><strong>${formatCurrency(fare)}</strong></td>
            <td>
              <button class="btn btn-primary btn-sm" onclick="window.startBookingFlow(${f.flight_id}, '${escapeHtml(f.flight_number)}', '${escapeHtml(f.airline_name)}', '${escapeHtml(f.origin)}', '${escapeHtml(f.destination)}', ${fare})">
                Select Seat & Book
              </button>
            </td>
          </tr>
        `;
      }).join('');
    } catch (err) {
      tbody.innerHTML = `<tr><td colspan="7" style="text-align: center; color: var(--accent-rose);">Error searching flights.</td></tr>`;
    }
  });

  // Run initial search
  btnSearch.click();
}

window.startBookingFlow = async function(flightId, flightNumber, airline, origin, dest, fare) {
  activeFlightForBooking = { flightId, flightNumber, airline, origin, dest, fare };
  selectedSeatId = null;
  selectedSeatNumber = null;
  selectedSeatFare = fare;

  // Reset modal UI state
  document.getElementById('selected-seat-label').innerText = 'Selected Seat: None';
  document.getElementById('btn-proceed-to-passenger-form').style.display = '';
  document.getElementById('btn-proceed-to-passenger-form').disabled = true;
  document.getElementById('modal-seat-flight-title').innerText = `${flightNumber} (${origin} ➔ ${dest})`;

  const seatGrid = document.getElementById('seat-map-grid');
  seatGrid.innerHTML = `<div style="grid-column: span 6; text-align: center; color: var(--text-muted);">Loading aircraft cabin...</div>`;

  openModal('modal-seat-picker');

  try {
    const res = await apiRequest(`/flights/${flightId}/seats`);
    const seats = res.seats || [];

    seatGrid.innerHTML = seats.map(s => {
      const isOccupied = s.is_occupied;
      return `
        <div 
          class="seat ${isOccupied ? 'occupied' : ''} ${s.is_exit_row ? 'exit-row' : ''}" 
          title="Seat ${s.seat_number} - ${s.cabin_class}"
          onclick="window.selectSeatItem(this, ${s.seat_id}, '${s.seat_number}', ${isOccupied}, '${s.cabin_class}')">
          ${s.seat_number}
        </div>
      `;
    }).join('');
  } catch (err) {
    seatGrid.innerHTML = `<div style="grid-column: span 6; text-align: center; color: var(--accent-rose);">Failed to load seats: ${escapeHtml(err.message)}</div>`;
  }
};

window.selectSeatItem = function(element, seatId, seatNumber, isOccupied, cabinClass) {
  if (isOccupied) return;

  document.querySelectorAll('#seat-map-grid .seat').forEach(el => el.classList.remove('selected'));
  element.classList.add('selected');

  selectedSeatId = seatId;
  selectedSeatNumber = seatNumber;

  // Multiplier for cabin class
  let classMultiplier = 1.0;
  if (cabinClass === 'Business') classMultiplier = 2.2;
  if (cabinClass === 'First') classMultiplier = 3.5;

  selectedSeatFare = Math.round(activeFlightForBooking.fare * classMultiplier);

  document.getElementById('selected-seat-label').innerText = `Selected Seat: ${seatNumber} (${cabinClass}) - ${formatCurrency(selectedSeatFare)}`;
  document.getElementById('btn-proceed-to-passenger-form').disabled = false;
};

function setupBookingForm() {
  const btnProceed = document.getElementById('btn-proceed-to-passenger-form');
  if (btnProceed) {
    btnProceed.addEventListener('click', () => {
      if (!selectedSeatId) return;
      closeModal('modal-seat-picker');

      // Populate Passenger details modal
      document.getElementById('booking-summary-flight').innerText = activeFlightForBooking.flightNumber;
      document.getElementById('booking-summary-seat').innerText = selectedSeatNumber;
      document.getElementById('booking-summary-fare').innerText = formatCurrency(selectedSeatFare);

      openModal('modal-passenger-details');
    });
  }

  const btnSubmitBooking = document.getElementById('btn-submit-final-booking');
  if (btnSubmitBooking) {
    btnSubmitBooking.addEventListener('click', async () => {
      const firstName = document.getElementById('pax-first-name').value.trim();
      const lastName = document.getElementById('pax-last-name').value.trim();
      const passport = document.getElementById('pax-passport').value.trim().toUpperCase();
      const nationality = document.getElementById('pax-nationality').value.trim();
      const dob = document.getElementById('pax-dob').value;
      const gender = document.getElementById('pax-gender').value;
      const email = document.getElementById('pax-email').value.trim();
      const phone = document.getElementById('pax-phone').value.trim();
      const paymentMethod = document.getElementById('pax-payment-method').value;

      if (!firstName || !lastName || !passport || !dob || !email || !phone) {
        showToast('Please fill in all passenger required fields.', 'error');
        return;
      }

      btnSubmitBooking.disabled = true;
      btnSubmitBooking.innerText = 'Reserving Seat in Database...';

      try {
        const payload = {
          passenger: {
            first_name: firstName,
            last_name: lastName,
            passport_number: passport,
            nationality,
            date_of_birth: dob,
            gender,
            email,
            phone
          },
          flight_id: activeFlightForBooking.flightId,
          seat_id: selectedSeatId,
          fare_amount: selectedSeatFare,
          payment_method: paymentMethod
        };

        const res = await apiRequest('/bookings', {
          method: 'POST',
          body: JSON.stringify(payload)
        });

        closeModal('modal-passenger-details');
        showToast(`Success! Seat ${selectedSeatNumber} confirmed with PNR ${res.pnr}`, 'success');

        // Automatically retrieve and display the new booking
        document.getElementById('input-pnr').value = res.pnr;
        document.getElementById('btn-lookup-pnr').click();
      } catch (err) {
        showToast(`Booking Failed: ${err.message}`, 'error');
      } finally {
        btnSubmitBooking.disabled = false;
        btnSubmitBooking.innerText = 'Confirm & Pay';
      }
    });
  }
}

function setupPNRLookup() {
  const btnLookup = document.getElementById('btn-lookup-pnr');
  if (!btnLookup) return;

  btnLookup.addEventListener('click', async () => {
    const inputPnr = document.getElementById('input-pnr').value.trim().toUpperCase();
    const resultBox = document.getElementById('pnr-result-box');

    if (!inputPnr) {
      showToast('Please enter a PNR reference code.', 'warning');
      return;
    }

    resultBox.style.display = 'block';
    resultBox.innerHTML = `<span style="color: var(--text-muted);">Querying booking records...</span>`;

    try {
      const data = await apiRequest(`/bookings/${inputPnr}`);

      const baggageList = data.baggage || [];
      const baggageHtml = baggageList.length > 0 
        ? baggageList.map(b => `<div style="color: var(--text-primary);">${escapeHtml(b.tag_number)}: <strong>${escapeHtml(b.weight_kg)} kg</strong> (${escapeHtml(b.status)})</div>`).join('')
        : `<span style="color: var(--text-muted);">No checked baggage recorded</span>`;

      resultBox.innerHTML = `
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.85rem; border-bottom: 1px solid rgba(255,255,255,0.1); padding-bottom: 0.5rem;">
          <div>
            <h4 style="color: var(--accent-cyan); font-size: 1.15rem; margin: 0;">PNR Reference: ${escapeHtml(data.pnr)}</h4>
            <small style="color: var(--text-muted);">${escapeHtml(data.airline_name)} • ${escapeHtml(data.flight_number)}</small>
          </div>
          <span class="badge badge-${escapeHtml(data.booking_status.toLowerCase().replace('-', ''))}">${escapeHtml(data.booking_status)}</span>
        </div>

        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem; font-size: 0.875rem;">
          <div><small style="color: var(--text-muted);">PASSENGER NAME</small><br><strong>${escapeHtml(data.passenger_name)}</strong></div>
          <div><small style="color: var(--text-muted);">PASSPORT</small><br><strong>${escapeHtml(data.passport_number)}</strong></div>
          <div><small style="color: var(--text-muted);">ROUTE</small><br><strong>${escapeHtml(data.origin)} ➔ ${escapeHtml(data.destination)}</strong></div>
          <div><small style="color: var(--text-muted);">SEAT ALLOCATED</small><br><strong style="color: var(--accent-emerald); font-size: 1.1rem;">${escapeHtml(data.seat_number)} (${escapeHtml(data.cabin_class)})</strong></div>
          <div><small style="color: var(--text-muted);">DEPARTURE GATE</small><br><strong style="color: var(--accent-amber);">${escapeHtml(data.departure_gate)}</strong></div>
          <div><small style="color: var(--text-muted);">TOTAL FARE PAID</small><br><strong>${formatCurrency(data.total_amount)}</strong></div>
        </div>

        <div style="margin-top: 1rem; padding-top: 0.75rem; border-top: 1px solid rgba(255,255,255,0.08);">
          <small style="color: var(--text-muted);">CHECKED BAGGAGE</small>
          ${baggageHtml}
        </div>

        <div style="display: flex; gap: 0.75rem; margin-top: 1.25rem;">
          ${data.booking_status === 'Confirmed' 
            ? `<button class="btn btn-primary btn-sm" onclick="window.performCheckIn('${escapeHtml(data.pnr)}')">✓ Online Check-In</button>` 
            : `<button class="btn btn-secondary btn-sm" onclick="window.viewBoardingPass('${escapeHtml(data.pnr)}')">🎫 View Boarding Pass</button>`
          }
        </div>
      `;
    } catch (err) {
      resultBox.innerHTML = `<span style="color: var(--accent-rose);">${escapeHtml(err.message)}</span>`;
    }
  });
}

window.performCheckIn = async function(pnr) {
  try {
    const res = await apiRequest(`/bookings/${pnr}/check-in`, { method: 'POST' });
    showToast('Check-in completed successfully! Boarding pass issued.', 'success');
    document.getElementById('btn-lookup-pnr').click();
  } catch (err) {
    showToast(`Check-in Error: ${err.message}`, 'error');
  }
};

window.viewBoardingPass = async function(pnr) {
  try {
    const data = await apiRequest(`/bookings/${pnr}/boarding-pass`);

    const bpCard = document.getElementById('boarding-pass-content');
    bpCard.innerHTML = `
      <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid rgba(255,255,255,0.2); padding-bottom: 0.75rem; margin-bottom: 0.75rem;">
        <span style="font-weight: 800; font-size: 1.2rem; color: var(--accent-cyan);">${escapeHtml(data.airline_name)} • BOARDING PASS</span>
        <span style="font-family: var(--font-mono); font-size: 0.85rem; color: var(--accent-emerald);">SEQ #${escapeHtml(data.sequence_number)}</span>
      </div>
      <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 0.75rem; font-size: 0.85rem;">
        <div><small style="color: var(--text-muted);">PASSENGER</small><br><strong>${escapeHtml(data.passenger_name)}</strong></div>
        <div><small style="color: var(--text-muted);">FLIGHT</small><br><strong style="color: var(--accent-cyan);">${escapeHtml(data.flight_number)}</strong></div>
        <div><small style="color: var(--text-muted);">SEAT</small><br><strong style="color: var(--accent-emerald); font-size: 1.15rem;">${escapeHtml(data.seat_number)}</strong></div>
        <div><small style="color: var(--text-muted);">ROUTE</small><br><strong>${escapeHtml(data.origin_iata)} ➔ ${escapeHtml(data.destination_iata)}</strong></div>
        <div><small style="color: var(--text-muted);">BOARDING TIME</small><br><strong>${escapeHtml(data.boarding_time?.substring(11, 16) || 'TBD')}</strong></div>
        <div><small style="color: var(--text-muted);">GATE</small><br><strong style="color: var(--accent-amber);">${escapeHtml(data.departure_gate)}</strong></div>
      </div>
      <div class="barcode-sim">||| | |||| | |||||| || | ||| ||||</div>
      <div style="text-align: right; margin-top: 1rem;">
        <button class="btn btn-secondary btn-sm" onclick="window.print()">🖨️ Print / Save as PDF</button>
      </div>
    `;

    openModal('modal-boarding-pass');
  } catch (err) {
    showToast(`Boarding Pass Error: ${err.message}`, 'error');
  }
};
