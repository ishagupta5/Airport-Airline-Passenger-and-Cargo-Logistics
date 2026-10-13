import { ZodError } from 'zod';

export function errorHandler(err, req, res, next) {
  console.error('[API Error]:', err);

  if (err instanceof ZodError) {
    return res.status(400).json({
      error: 'Validation failed',
      details: err.errors.map(e => ({ field: e.path.join('.'), message: e.message }))
    });
  }

  // Handle MySQL errors
  if (err.code) {
    if (err.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({ error: 'Duplicate entry: A record with these unique details already exists.' });
    }
    if (err.sqlState === '45000') {
      // Custom SIGNAL from triggers or stored procedures
      return res.status(400).json({ error: err.sqlMessage || err.message });
    }
    if (err.code === 'ER_NO_REFERENCED_ROW_2') {
      return res.status(400).json({ error: 'Foreign key integrity error: referenced record does not exist.' });
    }
  }

  const statusCode = err.statusCode || 500;
  res.status(statusCode).json({
    error: err.message || 'Internal server error occurred'
  });
}
