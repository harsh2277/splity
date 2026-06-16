const express = require('express');
const { sql } = require('../config/db');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

// GET /api/expenses — all expenses for current user
router.get('/', authenticate, async (req, res) => {
  try {
    const { group_id, is_personal } = req.query;

    let expenses;
    if (group_id) {
      expenses = await sql`
        SELECT e.*, u.name AS paid_by_name, g.name AS group_name
        FROM expenses e
        LEFT JOIN users u ON u.id = e.paid_by
        LEFT JOIN groups g ON g.id = e.group_id
        WHERE e.group_id = ${group_id}
        ORDER BY e.created_at DESC
      `;
    } else if (is_personal === 'true') {
      expenses = await sql`
        SELECT e.*, u.name AS paid_by_name
        FROM expenses e
        LEFT JOIN users u ON u.id = e.paid_by
        WHERE e.created_by = ${req.user.id} AND e.is_personal = true
        ORDER BY e.created_at DESC
      `;
    } else {
      expenses = await sql`
        SELECT e.*, u.name AS paid_by_name, g.name AS group_name
        FROM expenses e
        LEFT JOIN users u ON u.id = e.paid_by
        LEFT JOIN groups g ON g.id = e.group_id
        WHERE e.created_by = ${req.user.id}
           OR e.group_id IN (
             SELECT group_id FROM group_members WHERE user_id = ${req.user.id} AND status = 'active'
           )
        ORDER BY e.created_at DESC
      `;
    }

    res.json({ expenses });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/expenses — create expense
router.post('/', authenticate, async (req, res) => {
  try {
    const {
      title,
      amount,
      category,
      is_personal,
      group_id,
      paid_by,
      split_method,
      notes,
      splits,
      expense_date,
    } = req.body;

    if (!title || !amount) {
      return res.status(400).json({ error: 'title and amount are required' });
    }

    // Validate group membership before INSERT
    if (group_id) {
      const [membership] = await sql`
        SELECT id FROM group_members
        WHERE group_id = ${group_id} AND user_id = ${req.user.id} AND status = 'active'
      `;
      if (!membership) {
        return res.status(403).json({ error: 'You are not an active member of this group' });
      }
    }

    const paidBy = paid_by || req.user.id;

    const [expense] = await sql`
      INSERT INTO expenses (title, amount, category, is_personal, group_id, paid_by, split_method, notes, expense_date, created_by)
      VALUES (
        ${title},
        ${amount},
        ${category || 'other'},
        ${is_personal ?? false},
        ${group_id || null},
        ${paidBy},
        ${split_method || 'equal'},
        ${notes || null},
        ${expense_date || null},
        ${req.user.id}
      )
      RETURNING *
    `;

    // Insert splits if provided
    if (splits && Array.isArray(splits) && splits.length > 0) {
      for (const split of splits) {
        await sql`
          INSERT INTO expense_splits (expense_id, user_id, amount)
          VALUES (${expense.id}, ${split.user_id}, ${split.amount})
          ON CONFLICT (expense_id, user_id) DO UPDATE SET amount = EXCLUDED.amount
        `;
      }
    } else if (!is_personal && group_id) {
      // Auto equal split: get group members
      const members = await sql`
        SELECT user_id FROM group_members WHERE group_id = ${group_id} AND status = 'active'
      `;
      if (members.length > 0) {
        const totalAmount = parseFloat(amount);
        const n = members.length;
        const base = Math.floor((totalAmount * 100) / n) / 100;
        const remainder = Math.round((totalAmount - base * n) * 100) / 100;

        for (const m of members) {
          const isPayer = m.user_id === paidBy;
          const splitAmount = isPayer ? (base + remainder).toFixed(2) : base.toFixed(2);
          await sql`
            INSERT INTO expense_splits (expense_id, user_id, amount)
            VALUES (${expense.id}, ${m.user_id}, ${splitAmount})
            ON CONFLICT (expense_id, user_id) DO NOTHING
          `;
        }
      }
    }

    res.status(201).json({ expense });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/expenses/:id — expense detail with splits
router.get('/:id', authenticate, async (req, res) => {
  try {
    const [expense] = await sql`
      SELECT e.*, u.name AS paid_by_name, g.name AS group_name
      FROM expenses e
      LEFT JOIN users u ON u.id = e.paid_by
      LEFT JOIN groups g ON g.id = e.group_id
      WHERE e.id = ${req.params.id}
    `;
    if (!expense) return res.status(404).json({ error: 'Expense not found' });

    const splits = await sql`
      SELECT es.*, u.name AS user_name, u.avatar_url
      FROM expense_splits es
      JOIN users u ON u.id = es.user_id
      WHERE es.expense_id = ${req.params.id}
    `;

    res.json({ expense, splits });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// PATCH /api/expenses/:id — update expense (creator only)
router.patch('/:id', authenticate, async (req, res) => {
  try {
    const [existing] = await sql`SELECT created_by FROM expenses WHERE id = ${req.params.id}`;
    if (!existing) return res.status(404).json({ error: 'Expense not found' });
    if (existing.created_by !== req.user.id) {
      return res.status(403).json({ error: 'Not authorized to update this expense' });
    }

    const { title, amount, category, notes, expense_date } = req.body;
    const [expense] = await sql`
      UPDATE expenses
      SET
        title = COALESCE(${title || null}, title),
        amount = COALESCE(${amount != null ? amount : null}, amount),
        category = COALESCE(${category || null}, category),
        notes = COALESCE(${notes || null}, notes),
        expense_date = COALESCE(${expense_date || null}, expense_date),
        updated_at = NOW()
      WHERE id = ${req.params.id}
      RETURNING *
    `;
    res.json({ expense });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// DELETE /api/expenses/:id
router.delete('/:id', authenticate, async (req, res) => {
  try {
    const [expense] = await sql`SELECT created_by FROM expenses WHERE id = ${req.params.id}`;
    if (!expense) return res.status(404).json({ error: 'Expense not found' });
    if (expense.created_by !== req.user.id) {
      return res.status(403).json({ error: 'Not authorized to delete this expense' });
    }
    await sql`DELETE FROM expenses WHERE id = ${req.params.id}`;
    res.json({ message: 'Expense deleted' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/expenses/:id/settle — mark split as settled
router.post('/:id/settle', authenticate, async (req, res) => {
  try {
    await sql`
      UPDATE expense_splits
      SET is_settled = true, settled_at = NOW()
      WHERE expense_id = ${req.params.id} AND user_id = ${req.user.id}
    `;
    res.json({ message: 'Expense split settled' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
