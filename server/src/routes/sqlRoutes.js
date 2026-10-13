import express from 'express';
import { z } from 'zod';
import { queryReadOnly } from '../config/db.js';
import { authenticateToken, requireRole } from '../middleware/auth.js';

const router = express.Router();

const sqlRunSchema = z.object({
  query: z.string().min(1, 'Query cannot be empty')
});

// Blacklist of forbidden SQL keywords and patterns
const FORBIDDEN_PATTERNS = [
  /;/i,                                      // Multiple statements
  /\/\*/i,                                   // Multi-line comment
  /--/i,                                     // Single-line comment
  /#/i,                                      // MySQL comment
  /\b(INSERT|UPDATE|DELETE|DROP|ALTER|TRUNCATE|RENAME|REPLACE)\b/i, // DML/DDL write
  /\b(CREATE|GRANT|REVOKE|FLUSH|KILL|RESET|SHUTDOWN|LOCK)\b/i,      // Admin/DCL
  /\b(INTO\s+OUTFILE|INTO\s+DUMPFILE|LOAD_FILE|LOAD\s+DATA)\b/i,    // File I/O
  /\b(SLEEP|BENCHMARK)\b/i                   // Time-based blind injection primitives
];

router.post('/run', authenticateToken, requireRole('Admin'), async (req, res, next) => {
  const startTime = Date.now();
  try {
    const { query } = sqlRunSchema.parse(req.body);
    const trimmedQuery = query.trim();

    // 1. Must start with SELECT or EXPLAIN
    if (!/^(SELECT|EXPLAIN)\b/i.test(trimmedQuery)) {
      return res.status(400).json({
        error: 'Security Restriction: SQL Sandbox only permits read-only SELECT or EXPLAIN statements.'
      });
    }

    // 2. Check forbidden patterns
    for (const pattern of FORBIDDEN_PATTERNS) {
      if (pattern.test(trimmedQuery)) {
        return res.status(400).json({
          error: 'Security Restriction: Query contains disallowed characters, comments, or mutating SQL commands.'
        });
      }
    }

    // 3. Enforce ROW CAP 500
    let finalQuery = trimmedQuery;
    if (!/\bLIMIT\b/i.test(finalQuery)) {
      finalQuery = `${finalQuery} LIMIT 500`;
    }

    // 4. Execute read-only query
    const { rows, fields } = await queryReadOnly(finalQuery);
    const executionTimeMs = Date.now() - startTime;

    const columns = fields ? fields.map(f => f.name) : [];

    res.json({
      success: true,
      columns,
      rows: Array.isArray(rows) ? rows.slice(0, 500) : [],
      rowCount: Array.isArray(rows) ? rows.length : 0,
      executionTimeMs,
      appliedQuery: finalQuery
    });
  } catch (err) {
    const executionTimeMs = Date.now() - startTime;
    res.status(400).json({
      success: false,
      error: err.sqlMessage || err.message,
      executionTimeMs
    });
  }
});

export default router;
