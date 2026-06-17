import { Router } from 'express';
import { query } from '../db.js';
import { HttpError, asyncHandler, sendCreated, sendOk } from '../http.js';
import { createSettlementSchema, validate } from '../validators.js';

export const settlementsRouter = Router();

settlementsRouter.get(
  '/',
  asyncHandler(async (req, res) => {
    const result = await query(
      `
        select
          s.*,
          g.name as group_name,
          payer.full_name as payer_name,
          payee.full_name as payee_name
        from settlements s
        left join groups g on g.id = s.group_id
        join profiles payer on payer.id = s.payer_id
        left join profiles payee on payee.id = s.payee_id
        where
          s.payer_id = $1
          or s.payee_id = $1
          or exists (
            select 1
            from group_members gm
            where gm.group_id = s.group_id and gm.profile_id = $1 and gm.status = 'active'
          )
        order by s.created_at desc
      `,
      [req.auth.profile.id],
    );

    sendOk(res, result.rows);
  }),
);

settlementsRouter.post(
  '/',
  validate(createSettlementSchema),
  asyncHandler(async (req, res) => {
    if (!req.body.payeeProfileId && !req.body.payeeEmail) {
      throw new HttpError(400, 'payeeProfileId or payeeEmail is required');
    }

    const result = await query(
      `
        insert into settlements (
          group_id,
          payer_id,
          payee_id,
          payee_email,
          amount,
          currency,
          status,
          note,
          settled_at
        )
        values ($1, $2, $3, $4, $5, $6, $7, $8, case when $7 = 'completed' then now() else null end)
        returning *
      `,
      [
        req.body.groupId || null,
        req.auth.profile.id,
        req.body.payeeProfileId || null,
        req.body.payeeEmail?.toLowerCase() || null,
        req.body.amount,
        req.body.currency,
        req.body.status,
        req.body.note || null,
      ],
    );

    sendCreated(res, result.rows[0]);
  }),
);
