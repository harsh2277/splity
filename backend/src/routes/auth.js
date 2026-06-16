const express = require('express');
const bcrypt = require('bcryptjs');
const https = require('https');
const jwt = require('jsonwebtoken');
const { sql } = require('../config/db');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

// POST /api/auth/register
router.post('/register', async (req, res) => {
  try {
    const { name, email, password, phone, upi_id } = req.body;
    if (!name || !email || !password) {
      return res.status(400).json({ error: 'name, email, and password are required' });
    }

    const existing = await sql`SELECT id FROM users WHERE email = ${email}`;
    if (existing.length > 0) {
      return res.status(409).json({ error: 'Email already in use' });
    }

    const password_hash = await bcrypt.hash(password, 10);
    const [user] = await sql`
      INSERT INTO users (name, email, password_hash, phone, upi_id)
      VALUES (${name}, ${email}, ${password_hash}, ${phone || null}, ${upi_id || null})
      RETURNING id, name, email, phone, upi_id, avatar_url, created_at
    `;

    const token = jwt.sign({ id: user.id, email: user.email }, process.env.JWT_SECRET, {
      expiresIn: process.env.JWT_EXPIRES_IN || '7d',
    });

    res.status(201).json({ user, token });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/auth/login
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ error: 'email and password are required' });
    }

    const [user] = await sql`SELECT * FROM users WHERE email = ${email}`;
    if (!user) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const valid = await bcrypt.compare(password, user.password_hash);
    if (!valid) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const token = jwt.sign({ id: user.id, email: user.email }, process.env.JWT_SECRET, {
      expiresIn: process.env.JWT_EXPIRES_IN || '7d',
    });

    const { password_hash, ...userWithoutPassword } = user;
    res.json({ user: userWithoutPassword, token });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/auth/forgot-password  (sends reset token — stub for now)
router.post('/forgot-password', async (req, res) => {
  try {
    const { email } = req.body;
    if (!email) return res.status(400).json({ error: 'email is required' });

    const [user] = await sql`SELECT id FROM users WHERE email = ${email}`;
    // Always return 200 to avoid email enumeration
    if (!user) return res.json({ message: 'If that email exists, a reset link was sent.' });

    // TODO: integrate email service to send reset link
    res.json({ message: 'If that email exists, a reset link was sent.' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/auth/me
router.get('/me', authenticate, async (req, res) => {
  try {
    const [user] = await sql`
      SELECT id, name, email, phone, upi_id, avatar_url, created_at FROM users WHERE id = ${req.user.id}
    `;
    if (!user) return res.status(404).json({ error: 'User not found' });
    res.json({ user });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/auth/google — verify Firebase ID token and return our JWT
router.post('/google', async (req, res) => {
  try {
    const { id_token } = req.body;
    if (!id_token) return res.status(400).json({ error: 'id_token is required' });

    // Verify the Firebase ID token via Google's tokeninfo endpoint
    const googleData = await new Promise((resolve, reject) => {
      https.get(`https://oauth2.googleapis.com/tokeninfo?id_token=${id_token}`, (r) => {
        let body = '';
        r.on('data', (chunk) => (body += chunk));
        r.on('end', () => {
          try {
            const parsed = JSON.parse(body);
            if (parsed.error) reject(new Error(parsed.error_description || parsed.error));
            else resolve(parsed);
          } catch (e) { reject(e); }
        });
      }).on('error', reject);
    });

    const { email, name, picture, sub: googleId } = googleData;
    if (!email) return res.status(400).json({ error: 'Could not get email from Google token' });

    // Upsert user
    let [user] = await sql`SELECT id, name, email, phone, upi_id, avatar_url FROM users WHERE email = ${email}`;

    if (!user) {
      [user] = await sql`
        INSERT INTO users (name, email, password_hash, avatar_url)
        VALUES (${name || email.split('@')[0]}, ${email}, ${'google_' + googleId}, ${picture || null})
        RETURNING id, name, email, phone, upi_id, avatar_url, created_at
      `;
    }

    const token = jwt.sign({ id: user.id, email: user.email }, process.env.JWT_SECRET, {
      expiresIn: process.env.JWT_EXPIRES_IN || '7d',
    });

    res.json({ user, token });
  } catch (err) {
    console.error(err);
    res.status(401).json({ error: 'Invalid Google token' });
  }
});

module.exports = router;
