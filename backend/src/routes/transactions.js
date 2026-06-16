const express = require('express');
const { sql } = require('../config/db');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

// GET /api/transactions — all transactions involving current user
router.get('/', authenticate, async (req, res) => {
  try {
    const transactions = await sql`
      SELECT t.*,
        fu.name AS from_user_name, fu.avatar_url AS from_avatar,
        tu.name AS to_user_name, tu.avatar_url AS to_avatar,
        e.title AS expense_title
      FROM transactions t
      JOIN users fu ON fu.id = t.from_user
      JOIN users tu ON tu.id = t.to_user
      LEFT JOIN expenses e ON e.id = t.expense_id
      WHERE t.from_user = ${req.user.id} OR t.to_user = ${req.user.id}
      ORDER BY t.created_at DESC
    `;
    res.json({ transactions });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/transactions/:id
router.get('/:id', authenticate, async (req, res) => {
  try {
    const [transaction] = await sql`
      SELECT t.*,
        fu.name AS from_user_name, fu.avatar_url AS from_avatar,
        tu.name AS to_user_name, tu.avatar_url AS to_avatar,
        e.title AS expense_title
      FROM transactions t
      JOIN users fu ON fu.id = t.from_user
      JOIN users tu ON tu.id = t.to_user
      LEFT JOIN expenses e ON e.id = t.expense_id
      WHERE t.id = ${req.params.id}
        AND (t.from_user = ${req.user.id} OR t.to_user = ${req.user.id})
    `;
    if (!transaction) return res.status(404).json({ error: 'Transaction not found' });
    res.json({ transaction });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/transactions — create a payment transaction
router.post('/', authenticate, async (req, res) => {
  try {
    const { to_user, amount, expense_id, note } = req.body;
    if (!to_user || !amount) {
      return res.status(400).json({ error: 'to_user and amount are required' });
    }

    const [transaction] = await sql`
      INSERT INTO transactions (from_user, to_user, amount, expense_id, note, status)
      VALUES (${req.user.id}, ${to_user}, ${amount}, ${expense_id || null}, ${note || null}, 'pending')
      RETURNING *
    `;

    res.status(201).json({ transaction });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// PATCH /api/transactions/:id/status — update transaction status
router.patch('/:id/status', authenticate, async (req, res) => {
  try {
    const { status } = req.body;
    const allowed = ['pending', 'completed', 'failed'];
    if (!allowed.includes(status)) {
      return res.status(400).json({ error: 'status must be pending, completed, or failed' });
    }

    // Fetch the transaction first to enforce role-based transitions
    const [existing] = await sql`
      SELECT * FROM transactions
      WHERE id = ${req.params.id}
        AND (from_user = ${req.user.id} OR to_user = ${req.user.id})
    `;
    if (!existing) return res.status(404).json({ error: 'Transaction not found' });

    // Only from_user (payer) can mark completed; only to_user (receiver) can mark failed
    if (status === 'completed' && existing.from_user !== req.user.id) {
      return res.status(403).json({ error: 'Only the payer can mark a transaction as completed' });
    }
    if (status === 'failed' && existing.to_user !== req.user.id) {
      return res.status(403).json({ error: 'Only the receiver can mark a transaction as failed' });
    }

    const [transaction] = await sql`
      UPDATE transactions
      SET status = ${status}, updated_at = NOW()
      WHERE id = ${req.params.id}
      RETURNING *
    `;

    res.json({ transaction });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
