import fs from 'fs';
import path from 'path';
import mysql from 'mysql2/promise';
import dotenv from 'dotenv';
dotenv.config();

async function seedDatabase() {
  const host = process.env.DB_HOST || 'localhost';
  const user = process.env.DB_USER || 'airport_admin';
  const password = process.env.DB_PASSWORD || 'airport_secure_pass_2026';
  const database = process.env.MYSQL_DATABASE || process.env.DB_NAME || 'airport_logistics_db';

  console.log(`Connecting to MySQL on ${host} to seed database '${database}'...`);
  const connection = await mysql.createConnection({
    host,
    user,
    password,
    database,
    multipleStatements: true
  });

  try {
    const seedPath = path.resolve(process.cwd(), 'db/seed_data.sql');
    console.log(`Applying seed data from ${seedPath}...`);
    const seedSql = fs.readFileSync(seedPath, 'utf8');
    await connection.query(seedSql);

    console.log('✅ Database seeded successfully!');
  } finally {
    await connection.end();
  }
}

seedDatabase().catch(err => {
  console.error('❌ Failed to seed database:', err);
  process.exit(1);
});
