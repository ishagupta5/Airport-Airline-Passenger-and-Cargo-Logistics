import dotenv from 'dotenv';
dotenv.config();

export const config = {
  port: parseInt(process.env.PORT || '3000', 10),
  nodeEnv: process.env.NODE_ENV || 'development',
  jwtSecret: process.env.JWT_SECRET || 'super_secret_airport_jwt_token_key_2026',
  corsOrigin: process.env.CORS_ORIGIN || 'http://localhost:5173',
  db: {
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '3306', 10),
    user: process.env.DB_USER || 'airport_admin',
    password: process.env.DB_PASSWORD || 'airport_secure_pass_2026',
    database: process.env.DB_NAME || 'airport_logistics_db',
    waitForConnections: true,
    connectionLimit: 15,
    queueLimit: 0,
    timezone: '+00:00',
    dateStrings: true
  }
};
