import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import cookieParser from 'cookie-parser';
import { config } from './config/env.js';
import { apiLimiter } from './middleware/rateLimiter.js';
import { errorHandler } from './middleware/errorHandler.js';

import authRoutes from './routes/authRoutes.js';
import dashboardRoutes from './routes/dashboardRoutes.js';
import flightRoutes from './routes/flightRoutes.js';
import bookingRoutes from './routes/bookingRoutes.js';
import baggageRoutes from './routes/baggageRoutes.js';
import fleetRoutes from './routes/fleetRoutes.js';
import crewRoutes from './routes/crewRoutes.js';
import cargoRoutes from './routes/cargoRoutes.js';
import auditRoutes from './routes/auditRoutes.js';
import sqlRoutes from './routes/sqlRoutes.js';

const app = express();

// Security and utility middleware
app.use(helmet());
app.use(cors({
  origin: [config.corsOrigin, 'http://localhost:5173', 'http://127.0.0.1:5173', 'http://localhost:8080'],
  credentials: true
}));
app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());

if (config.nodeEnv !== 'test') {
  app.use(morgan('dev'));
}

// Global API rate limiter
app.use('/api', apiLimiter);

// Root Welcome & API Status Landing Page
app.get('/', (req, res) => {
  res.json({
    name: 'Airport & Airline Logistics Management DBMS API',
    version: '2.0.0',
    status: 'ONLINE',
    message: 'Backend API Server is running and connected to MySQL 8.0.',
    documentation: 'Try accessing the endpoints listed below in your browser or application',
    endpoints: {
      health: 'http://localhost:3000/api/health',
      dashboardStats: 'http://localhost:3000/api/dashboard/stats',
      flights: 'http://localhost:3000/api/flights',
      fleet: 'http://localhost:3000/api/fleet',
      crewAudit: 'http://localhost:3000/api/crew/duty-audit',
      cargo: 'http://localhost:3000/api/cargo',
      frontendClient: 'http://localhost:5173'
    }
  });
});

app.get('/api', (req, res) => {
  res.redirect('/');
});

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', service: 'airport-dbms-api', timestamp: new Date().toISOString() });
});

// Mount modular API routes
app.use('/api/auth', authRoutes);
app.use('/api/dashboard', dashboardRoutes);
app.use('/api/flights', flightRoutes);
app.use('/api/bookings', bookingRoutes);
app.use('/api/baggage', baggageRoutes);
app.use('/api/fleet', fleetRoutes);
app.use('/api/crew', crewRoutes);
app.use('/api/cargo', cargoRoutes);
app.use('/api/audit-logs', auditRoutes);
app.use('/api/sql', sqlRoutes);

// 404 Handler
app.use((req, res) => {
  res.status(404).json({ error: `Route '${req.originalUrl}' not found.` });
});

// Central Error Handler
app.use(errorHandler);

// Start Server if not imported by test suite
if (process.env.NODE_ENV !== 'test') {
  app.listen(config.port, () => {
    console.log(`✈️  Airport Logistics DBMS Backend running on port ${config.port} [${config.nodeEnv}]`);
  });
}

export default app;
