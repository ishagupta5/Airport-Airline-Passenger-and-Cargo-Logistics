import './styles/main.css';
import { apiRequest } from './utils/api.js';
import { viewFlightSeats } from './utils/flightSeats.js';
import { setupModalDismissals, showToast, openModal, closeModal } from './utils/helpers.js';
import { initDashboard } from './components/dashboard.js';
import { initPassenger } from './components/passenger.js';
import { initOperations } from './components/operations.js';
import { initCargo } from './components/cargo.js';

// Setup Tab Routing with URL Hash

function setupTabRouting() {
  const tabButtons = document.querySelectorAll('.nav-btn');
  const tabContents = document.querySelectorAll('.tab-content');

  const allowedTabs = new Set([
    'tab-dashboard',
    'tab-passenger',
    'tab-operations',
    'tab-cargo'
  ]);

  function switchTab(tabId) {
    if (!allowedTabs.has(tabId)) {
      tabId = 'tab-dashboard';
    }

    tabButtons.forEach(btn => {
      const isActive = btn.getAttribute('data-tab') === tabId;
      btn.classList.toggle('active', isActive);
      btn.setAttribute('aria-selected', String(isActive));
    });

    tabContents.forEach(tab => {
      tab.classList.toggle('active', tab.id === tabId);
    });

    const hash = tabId.replace('tab-', '');
    if (window.location.hash !== `#${hash}`) {
      window.location.hash = hash;
    }
  }

  tabButtons.forEach(btn => {
    btn.addEventListener('click', () => {
      switchTab(btn.getAttribute('data-tab'));
    });
  });

  window.addEventListener('hashchange', () => {
    const requestedTab = `tab-${window.location.hash.replace(/^#/, '')}`;
    switchTab(requestedTab);
  });

  const initialTab = `tab-${window.location.hash.replace(/^#/, '')}`;
  switchTab(
    window.location.hash && allowedTabs.has(initialTab)
      ? initialTab
      : 'tab-dashboard'
  );
}


// Role Switcher & Auth Management

function setupAuthAndRoles() {
  const roleDisplay = document.getElementById('active-role-display');
  const roleBadge = document.querySelector('.role-badge');
  const loginForm = document.getElementById('auth-login-form');
  const loginError = document.getElementById('auth-login-error');
  const loginButton = document.getElementById('auth-login-submit');
  const usernameInput = document.getElementById('auth-username');
  const passwordInput = document.getElementById('auth-password');
  const roleSelect = document.getElementById('select-demo-role');

  const token = localStorage.getItem('airport_auth_token');
  let currentRole = localStorage.getItem('airport_user_role') || 'Admin';

  if (roleDisplay) {
    roleDisplay.innerText = token
      ? `Role: ${currentRole} (Logged in)`
      : 'Not logged in';
  }

  if (roleBadge) {
    roleBadge.addEventListener('click', () => {
      if (roleSelect) {
        roleSelect.value = currentRole;
      }
      if (loginError) loginError.textContent = '';
      openModal('modal-auth-login');
    });
  }

  if (roleSelect) {
    roleSelect.value = currentRole;

    roleSelect.addEventListener('change', () => {
      currentRole = roleSelect.value;
      showToast(
        `Preview role selected: ${currentRole}. This does not change your login permissions.`,
        'info'
      );
    });
  }

  if (loginForm) {
    loginForm.addEventListener('submit', async (event) => {
      event.preventDefault();

      if (loginError) loginError.textContent = '';
      if (loginButton) {
        loginButton.disabled = true;
        loginButton.textContent = 'Logging in...';
      }

      try {
        const data = await apiRequest('/auth/login', {
          method: 'POST',
          body: JSON.stringify({
            username: usernameInput.value.trim(),
            password: passwordInput.value
          })
        });

        localStorage.setItem('airport_auth_token', data.token);

        const authenticatedRole = data.user.user_role;
        localStorage.setItem('airport_user_role', authenticatedRole);
        currentRole = authenticatedRole;

        if (roleDisplay) {
          roleDisplay.innerText = `Role: ${authenticatedRole} (Logged in)`;
        }

        if (roleSelect) {
          roleSelect.value = authenticatedRole;
        }

        passwordInput.value = '';
        closeModal('modal-auth-login');
        showToast(`Logged in successfully as ${data.user.username}`, 'success');
      } catch (error) {
        if (loginError) {
          loginError.textContent = error.message || 'Login failed. Please try again.';
        }
      } finally {
        if (loginButton) {
          loginButton.disabled = false;
          loginButton.textContent = 'Log In';
        }
      }
    });
  }
}


// Global modal helpers exposed to window for inline onclicks
window.closeModal = closeModal;
window.openModal = openModal;
window.viewFlightSeats = viewFlightSeats;

// Initialize Application
document.addEventListener('DOMContentLoaded', () => {
  setupModalDismissals();
  setupTabRouting();
  setupAuthAndRoles();

  initDashboard();
  initPassenger();
  initOperations();
  initCargo();

  console.log('✈️ Airport Logistics DBMS Frontend initialized successfully with live API client!');
});
