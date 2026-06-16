const express = require('express');
const bcrypt = require('bcryptjs');
const { sql } = require('../config/db');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

// GET /api/users/search
router.get('/search', authenticate, async (req, res) => {
  try {
    const { q } = req.query;
    if (!q) return res.status(400).json({ error: 'q query parameter is required' });

    const users = await sql`
      SELECT id, name, email, avatar_url
      FROM users
      WHERE id != ${req.user.id}
        AND (name ILIKE ${'%' + q + '%'} OR email ILIKE ${'%' + q + '%'})
      LIMIT 20
    `;
    res.json({ users });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/users/profile
router.get('/profile', authenticate, async (req, res) => {
  try {
    const [user] = await sql`
      SELECT id, name, email, phone, upi_id, avatar_url, created_at, updated_at
      FROM users WHERE id = ${req.user.id}
    `;
    if (!user) return res.status(404).json({ error: 'User not found' });
    res.json({ user });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// PATCH /api/users/profile
router.patch('/profile', authenticate, async (req, res) => {
  try {
    const { name, phone, avatar_url, upi_id } = req.body;
    const [user] = await sql`
      UPDATE users
      SET
        name = COALESCE(${name || null}, name),
        phone = COALESCE(${phone || null}, phone),
        avatar_url = COALESCE(${avatar_url || null}, avatar_url),
        upi_id = COALESCE(${upi_id || null}, upi_id),
        updated_at = NOW()
      WHERE id = ${req.user.id}
      RETURNING id, name, email, phone, upi_id, avatar_url, created_at, updated_at
    `;
    res.json({ user });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// PATCH /api/users/password
router.patch('/password', authenticate, async (req, res) => {
  try {
    const { current_password, new_password } = req.body;
    if (!current_password || !new_password) {
      return res.status(400).json({ error: 'current_password and new_password are required' });
    }

    const [user] = await sql`SELECT password_hash FROM users WHERE id = ${req.user.id}`;
    const valid = await bcrypt.compare(current_password, user.password_hash);
    if (!valid) return res.status(401).json({ error: 'Current password is incorrect' });

    const password_hash = await bcrypt.hash(new_password, 10);
    await sql`UPDATE users SET password_hash = ${password_hash}, updated_at = NOW() WHERE id = ${req.user.id}`;
    res.json({ message: 'Password updated successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
