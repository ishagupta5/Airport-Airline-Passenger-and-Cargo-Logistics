import mysql from 'mysql2/promise';
import { config } from './env.js';

export const pool = mysql.createPool(config.db);

// Helper to run queries with session user ID set for audit triggers
export async function queryWithUser(userId, sql, params = []) {
  const connection = await pool.getConnection();
  try {
    if (userId) {
      await connection.query('SET @app_user_id = ?', [userId]);
    }
    const [rows, fields] = await connection.query(sql, params);
    return [rows, fields];
  } finally {
    connection.release();
  }
}

// Read-only execution for SQL Sandbox
export async function queryReadOnly(sql) {
  const connection = await pool.getConnection();
  try {
    // Set statement timeout to 5 seconds
    await connection.query('SET max_execution_time = 5000');
    const [rows, fields] = await connection.query(sql);
    return { rows, fields };
  } finally {
    connection.release();
  }
}
