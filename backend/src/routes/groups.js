const express = require('express');
const crypto = require('crypto');
const { sql } = require('../config/db');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

function generateInviteCode() {
  return crypto.randomBytes(4).toString('hex').toUpperCase();
}

// GET /api/groups — list groups for current user
router.get('/', authenticate, async (req, res) => {
  try {
    const groups = await sql`
      SELECT g.*, gm.role, gm.status,
        (SELECT COUNT(*) FROM group_members WHERE group_id = g.id AND status = 'active') AS members_count
      FROM groups g
      JOIN group_members gm ON gm.group_id = g.id AND gm.user_id = ${req.user.id}
      ORDER BY g.created_at DESC
    `;
    res.json({ groups });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/groups — create group
router.post('/', authenticate, async (req, res) => {
  try {
    const { name, company_name, type, approval_required } = req.body;
    if (!name) return res.status(400).json({ error: 'name is required' });

    const invite_code = generateInviteCode();
    const [group] = await sql`
      INSERT INTO groups (name, company_name, type, invite_code, approval_required, created_by)
      VALUES (${name}, ${company_name || null}, ${type || 'Other'}, ${invite_code}, ${approval_required ?? false}, ${req.user.id})
      RETURNING *
    `;

    // Add creator as admin
    await sql`
      INSERT INTO group_members (group_id, user_id, role, status)
      VALUES (${group.id}, ${req.user.id}, 'admin', 'active')
    `;

    res.status(201).json({ group: { ...group, members_count: 1 } });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/groups/:id — group details with members
router.get('/:id', authenticate, async (req, res) => {
  try {
    const [group] = await sql`
      SELECT g.*,
        (SELECT COUNT(*) FROM group_members WHERE group_id = g.id AND status = 'active') AS members_count
      FROM groups g
      JOIN group_members gm ON gm.group_id = g.id AND gm.user_id = ${req.user.id}
      WHERE g.id = ${req.params.id}
    `;
    if (!group) return res.status(404).json({ error: 'Group not found or access denied' });

    const members = await sql`
      SELECT u.id, u.name, u.email, u.avatar_url, gm.role, gm.status, gm.joined_at
      FROM group_members gm
      JOIN users u ON u.id = gm.user_id
      WHERE gm.group_id = ${req.params.id}
    `;

    res.json({ group, members });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/groups/:id/balances — per-user unsettled balances
router.get('/:id/balances', authenticate, async (req, res) => {
  try {
    // Check membership
    const [membership] = await sql`
      SELECT id FROM group_members WHERE group_id = ${req.params.id} AND user_id = ${req.user.id} AND status = 'active'
    `;
    if (!membership) return res.status(403).json({ error: 'Not a member of this group' });

    // For each user, sum what they owe (expense_splits.amount where they are NOT the payer)
    // and sum what they are owed (expense_splits.amount for other users on expenses they paid)
    const rows = await sql`
      SELECT
        es.user_id,
        u.name AS user_name,
        SUM(
          CASE
            WHEN e.paid_by = es.user_id THEN es.amount   -- they paid, they are owed this back
            ELSE -es.amount                                -- they owe this amount
          END
        ) AS balance
      FROM expense_splits es
      JOIN expenses e ON e.id = es.expense_id
      JOIN users u ON u.id = es.user_id
      WHERE e.group_id = ${req.params.id} AND es.is_settled = false
      GROUP BY es.user_id, u.name
      ORDER BY u.name
    `;

    res.json({ balances: rows });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/groups/join — join by invite code
router.post('/join', authenticate, async (req, res) => {
  try {
    const { invite_code } = req.body;
    if (!invite_code) return res.status(400).json({ error: 'invite_code is required' });

    const [group] = await sql`SELECT * FROM groups WHERE invite_code = ${invite_code.trim().toUpperCase()}`;
    if (!group) return res.status(404).json({ error: 'Invalid invite code' });

    const [existing] = await sql`
      SELECT id FROM group_members WHERE group_id = ${group.id} AND user_id = ${req.user.id}
    `;
    if (existing) return res.status(409).json({ error: 'Already a member of this group' });

    const status = group.approval_required ? 'pending' : 'active';
    await sql`
      INSERT INTO group_members (group_id, user_id, role, status)
      VALUES (${group.id}, ${req.user.id}, 'member', ${status})
    `;

    res.json({ group, status });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// PATCH /api/groups/:id/members/:userId/approve — admin approves pending member
router.patch('/:id/members/:userId/approve', authenticate, async (req, res) => {
  try {
    const [adminCheck] = await sql`
      SELECT id FROM group_members
      WHERE group_id = ${req.params.id} AND user_id = ${req.user.id} AND role = 'admin' AND status = 'active'
    `;
    if (!adminCheck) return res.status(403).json({ error: 'Only admins can approve members' });

    const [member] = await sql`
      UPDATE group_members
      SET status = 'active'
      WHERE group_id = ${req.params.id} AND user_id = ${req.params.userId}
      RETURNING *
    `;
    if (!member) return res.status(404).json({ error: 'Member not found' });
    res.json({ member });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// DELETE /api/groups/:id — delete group (creator only)
router.delete('/:id', authenticate, async (req, res) => {
  try {
    const [group] = await sql`SELECT created_by FROM groups WHERE id = ${req.params.id}`;
    if (!group) return res.status(404).json({ error: 'Group not found' });
    if (group.created_by !== req.user.id) {
      return res.status(403).json({ error: 'Only the group creator can delete this group' });
    }
    await sql`DELETE FROM groups WHERE id = ${req.params.id}`;
    res.json({ message: 'Group deleted' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// DELETE /api/groups/:id/members/:userId — admin removes member, or member removes self
router.delete('/:id/members/:userId', authenticate, async (req, res) => {
  try {
    const isSelf = req.params.userId === req.user.id;

    if (!isSelf) {
      // Must be admin
      const [adminCheck] = await sql`
        SELECT id FROM group_members
        WHERE group_id = ${req.params.id} AND user_id = ${req.user.id} AND role = 'admin' AND status = 'active'
      `;
      if (!adminCheck) return res.status(403).json({ error: 'Only admins can remove other members' });
    }

    const result = await sql`
      DELETE FROM group_members
      WHERE group_id = ${req.params.id} AND user_id = ${req.params.userId}
      RETURNING id
    `;
    if (result.length === 0) return res.status(404).json({ error: 'Member not found' });
    res.json({ message: 'Member removed' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// DELETE /api/groups/:id/leave
router.delete('/:id/leave', authenticate, async (req, res) => {
  try {
    await sql`
      DELETE FROM group_members WHERE group_id = ${req.params.id} AND user_id = ${req.user.id}
    `;
    res.json({ message: 'Left group successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
