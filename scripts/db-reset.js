import fs from 'fs';
import path from 'path';
import mysql from 'mysql2/promise';
import dotenv from 'dotenv';
dotenv.config();

async function resetDatabase() {
  const host = process.env.DB_HOST || 'localhost';
  const user = process.env.DB_ROOT_USER || 'root';
  const password = process.env.MYSQL_ROOT_PASSWORD || process.env.DB_ROOT_PASSWORD || 'rootpassword';
  const database = process.env.MYSQL_DATABASE || process.env.DB_NAME || 'airport_logistics_db';

  console.log(`Connecting to MySQL on ${host} as ${user}...`);
  const connection = await mysql.createConnection({
    host,
    user,
    password,
    multipleStatements: true
  });

  try {
    console.log(`Dropping and recreating database '${database}'...`);
    await connection.query(`DROP DATABASE IF EXISTS \`${database}\`;`);
    await connection.query(`CREATE DATABASE \`${database}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;`);
    await connection.query(`USE \`${database}\`;`);

    const schemaPath = path.resolve(process.cwd(), 'db/schema.sql');
    console.log(`Applying schema from ${schemaPath}...`);
    const schemaSql = fs.readFileSync(schemaPath, 'utf8');
    await connection.query(schemaSql);

    const seedPath = path.resolve(process.cwd(), 'db/seed_data.sql');
    console.log(`Seeding data from ${seedPath}...`);
    const seedSql = fs.readFileSync(seedPath, 'utf8');
    await connection.query(seedSql);

    console.log('✅ Database reset and seeded successfully!');
  } finally {
    await connection.end();
  }
}

resetDatabase().catch(err => {
  console.error('❌ Failed to reset database:', err);
  process.exit(1);
});
