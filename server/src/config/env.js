import dotenv from 'dotenv';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
dotenv.config();

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const caPath = path.resolve(__dirname, '../../certs/ca.pem');
export const config = {
  port: parseInt(process.env.PORT || '3000', 10),
  nodeEnv: process.env.NODE_ENV || 'development',
  jwtSecret: process.env.JWT_SECRET,
  corsOrigin: process.env.CORS_ORIGIN || 'http://localhost:5173',
  db: {
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '3306', 10),
    user: process.env.DB_USER || 'airport_admin',
    password: process.env.DB_PASSWORD || 'airport_secure_pass_2026',
    database: process.env.DB_NAME || 'airport_logistics_db',
    ssl: process.env.DB_SSL === 'true'
  ? {
      ca: fs.readFileSync(caPath, 'utf8'),
      rejectUnauthorized: true
    }
  : undefined,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
    timezone: '+00:00',
    dateStrings: true
  }
};
