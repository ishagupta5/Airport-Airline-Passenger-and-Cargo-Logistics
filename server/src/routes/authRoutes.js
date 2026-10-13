import express from 'express';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { z } from 'zod';
import { pool } from '../config/db.js';
import { config } from '../config/env.js';
import { authenticateToken } from '../middleware/auth.js';
import { authLimiter } from '../middleware/rateLimiter.js';

const router = express.Router();

const loginSchema = z.object({
  username: z.string().min(1, 'Username is required'),
  password: z.string().min(1, 'Password is required')
});

router.post('/login', authLimiter, async (req, res, next) => {
  try {
    const { username, password } = loginSchema.parse(req.body);

    const [rows] = await pool.query(
      'SELECT user_id, username, password_hash, full_name, email, user_role, is_active FROM system_users WHERE username = ?',
      [username]
    );

    if (rows.length === 0) {
      return res.status(401).json({ error: 'Invalid username or password' });
    }

    const user = rows[0];

    if (!user.is_active) {
      return res.status(403).json({ error: 'Account has been deactivated. Please contact administrator.' });
    }

    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      return res.status(401).json({ error: 'Invalid username or password' });
    }

    // Update last_login
    await pool.query('UPDATE system_users SET last_login = NOW() WHERE user_id = ?', [user.user_id]);

    const tokenPayload = {
      user_id: user.user_id,
      username: user.username,
      full_name: user.full_name,
      email: user.email,
      user_role: user.user_role
    };

    const token = jwt.sign(tokenPayload, config.jwtSecret, { expiresIn: '12h' });

    res.cookie('token', token, {
      httpOnly: true,
      secure: config.nodeEnv === 'production',
      sameSite: 'lax',
      maxAge: 12 * 60 * 60 * 1000
    });

    res.json({
      message: 'Login successful',
      token,
      user: tokenPayload
    });
  } catch (err) {
    next(err);
  }
});

router.post('/logout', (req, res) => {
  res.clearCookie('token');
  res.json({ message: 'Logged out successfully' });
});

router.get('/me', authenticateToken, async (req, res, next) => {
  try {
    const [rows] = await pool.query(
      'SELECT user_id, username, full_name, email, user_role, last_login FROM system_users WHERE user_id = ?',
      [req.user.user_id]
    );

    if (rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json(rows[0]);
  } catch (err) {
    next(err);
  }
});

export default router;
