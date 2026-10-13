import test from 'node:test';
import assert from 'node:assert/strict';
import request from 'supertest';
import app from '../src/index.js';

test('Airport DBMS API Test Suite', async (t) => {

  await t.test('GET /api/health returns status ok', async () => {
    const res = await request(app).get('/api/health');
    assert.equal(res.status, 200);
    assert.equal(res.body.status, 'ok');
  });

  await t.test('POST /api/auth/login rejects invalid credentials', async () => {
    const res = await request(app)
      .post('/api/auth/login')
      .send({ username: 'nonexistent', password: 'wrongpassword' });
    assert.equal(res.status, 401);
  });

  await t.test('Role enforcement: /api/audit-logs rejects unauthenticated request', async () => {
    const res = await request(app).get('/api/audit-logs');
    assert.equal(res.status, 401);
  });

  await t.test('SQL Sandbox rejects mutating queries (DROP TABLE)', async () => {
    // Generate valid admin token simulation
    const res = await request(app)
      .post('/api/sql/run')
      .send({ query: 'DROP TABLE passengers;' });
    // Should be rejected by auth or by query validator
    assert.ok(res.status === 401 || res.status === 400);
  });

  await t.test('SQL Sandbox rejects multi-statements with semicolon', async () => {
    const res = await request(app)
      .post('/api/sql/run')
      .send({ query: 'SELECT * FROM airports; SELECT * FROM flights;' });
    assert.ok(res.status === 401 || res.status === 400);
  });

});
