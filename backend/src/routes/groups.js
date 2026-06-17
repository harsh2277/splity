import { randomBytes } from 'node:crypto';
import { Router } from 'express';
import { query, withTransaction } from '../db.js';
import { HttpError, asyncHandler, notFound, sendCreated, sendOk } from '../http.js';
import {
  addMemberSchema,
  createGroupSchema,
  joinGroupSchema,
  validate,
} from '../validators.js';

export const groupsRouter = Router();

function makeInviteCode(name) {
  const prefix = name.replace(/[^a-z0-9]/gi, '').toUpperCase().padEnd(4, 'X').slice(0, 4);
  return `${prefix}${randomBytes(2).toString('hex').toUpperCase()}`;
}

async function assertGroupAccess(groupId, profileId) {
  const result = await query(
    `
      select gm.role, gm.status
      from group_members gm
      where gm.group_id = $1 and gm.profile_id = $2 and gm.status = 'active'
    `,
    [groupId, profileId],
  );

  if (!result.rowCount) {
    throw new HttpError(403, 'You do not have access to this group');
  }

  return result.rows[0];
}

groupsRouter.get(
  '/',
  asyncHandler(async (req, res) => {
    const result = await query(
      `
        select
          g.*,
          gm.role,
          count(active_members.id)::int as members_count
        from groups g
        join group_members gm on gm.group_id = g.id
        left join group_members active_members
          on active_members.group_id = g.id and active_members.status = 'active'
        where gm.profile_id = $1 and gm.status = 'active'
        group by g.id, gm.role
        order by g.created_at desc
      `,
      [req.auth.profile.id],
    );

    sendOk(res, result.rows);
  }),
);

groupsRouter.post(
  '/',
  validate(createGroupSchema),
  asyncHandler(async (req, res) => {
    const group = await withTransaction(async (client) => {
      let created;

      for (let attempt = 0; attempt < 5; attempt += 1) {
        try {
          const inviteCode = makeInviteCode(req.body.name);
          const result = await client.query(
            `
              insert into groups (
                name,
                company_name,
                type,
                invite_code,
                approval_required,
                image_url,
                created_by
              )
              values ($1, $2, $3, $4, $5, $6, $7)
              returning *
            `,
            [
              req.body.name,
              req.body.companyName,
              req.body.type,
              inviteCode,
              req.body.approvalRequired,
              req.body.imageUrl || null,
              req.auth.profile.id,
            ],
          );
          created = result.rows[0];
          break;
        } catch (error) {
          if (error.code !== '23505' || attempt === 4) throw error;
        }
      }

      await client.query(
        `
          insert into group_members (group_id, profile_id, display_name, email, avatar, role, status)
          values ($1, $2, $3, $4, $5, 'owner', 'active')
        `,
        [
          created.id,
          req.auth.profile.id,
          req.auth.profile.full_name,
          req.auth.profile.email,
          req.auth.profile.avatar,
        ],
      );

      return created;
    });

    sendCreated(res, group);
  }),
);

groupsRouter.post(
  '/join',
  validate(joinGroupSchema),
  asyncHandler(async (req, res) => {
    const inviteCode = req.body.inviteCode.trim().toUpperCase();

    const groupResult = await query('select * from groups where invite_code = $1', [
      inviteCode,
    ]);

    if (!groupResult.rowCount) {
      notFound('Invite code not found');
    }

    const group = groupResult.rows[0];
    const status = group.approval_required ? 'pending' : 'active';

    const memberResult = await query(
      `
        insert into group_members (group_id, profile_id, display_name, email, avatar, role, status)
        values ($1, $2, $3, $4, $5, 'member', $6)
        on conflict (group_id, profile_id)
        do update set status = excluded.status
        returning *
      `,
      [
        group.id,
        req.auth.profile.id,
        req.auth.profile.full_name,
        req.auth.profile.email,
        req.auth.profile.avatar,
        status,
      ],
    );

    sendOk(res, { group, membership: memberResult.rows[0] });
  }),
);

groupsRouter.get(
  '/:groupId',
  asyncHandler(async (req, res) => {
    await assertGroupAccess(req.params.groupId, req.auth.profile.id);

    const result = await query(
      `
        select
          g.*,
          count(gm.id)::int as members_count
        from groups g
        left join group_members gm on gm.group_id = g.id and gm.status = 'active'
        where g.id = $1
        group by g.id
      `,
      [req.params.groupId],
    );

    if (!result.rowCount) notFound('Group not found');
    sendOk(res, result.rows[0]);
  }),
);

groupsRouter.get(
  '/:groupId/members',
  asyncHandler(async (req, res) => {
    await assertGroupAccess(req.params.groupId, req.auth.profile.id);

    const result = await query(
      `
        select
          gm.*,
          p.full_name,
          p.upi_id,
          p.supabase_user_id
        from group_members gm
        left join profiles p on p.id = gm.profile_id
        where gm.group_id = $1 and gm.status <> 'removed'
        order by gm.created_at asc
      `,
      [req.params.groupId],
    );

    sendOk(res, result.rows);
  }),
);

groupsRouter.post(
  '/:groupId/members',
  validate(addMemberSchema),
  asyncHandler(async (req, res) => {
    await assertGroupAccess(req.params.groupId, req.auth.profile.id);

    const result = await query(
      `
        insert into group_members (
          group_id,
          display_name,
          email,
          avatar,
          role,
          status,
          invited_by
        )
        values ($1, $2, $3, $4, 'member', 'pending', $5)
        on conflict (group_id, email)
        do update set
          display_name = excluded.display_name,
          avatar = excluded.avatar,
          status = excluded.status,
          invited_by = excluded.invited_by
        returning *
      `,
      [
        req.params.groupId,
        req.body.displayName || req.body.email,
        req.body.email.toLowerCase(),
        req.body.avatar || null,
        req.auth.profile.id,
      ],
    );

    sendCreated(res, result.rows[0]);
  }),
);
