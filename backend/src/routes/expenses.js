import { Router } from 'express';
import { query, withTransaction } from '../db.js';
import { HttpError, asyncHandler, notFound, sendCreated, sendOk } from '../http.js';
import {
  createExpenseSchema,
  updateExpenseStatusSchema,
  validate,
} from '../validators.js';

export const expensesRouter = Router();

async function canUseGroup(groupId, profileId) {
  if (!groupId) return true;

  const result = await query(
    `
      select 1
      from group_members
      where group_id = $1 and profile_id = $2 and status = 'active'
    `,
    [groupId, profileId],
  );

  return Boolean(result.rowCount);
}

expensesRouter.get(
  '/',
  asyncHandler(async (req, res) => {
    const result = await query(
      `
        select
          e.*,
          g.name as group_name,
          creator.full_name as created_by_name,
          payer.full_name as paid_by_name
        from expenses e
        left join groups g on g.id = e.group_id
        left join profiles creator on creator.id = e.created_by
        left join profiles payer on payer.id = e.paid_by
        where
          e.created_by = $1
          or e.paid_by = $1
          or exists (
            select 1
            from expense_splits es
            where es.expense_id = e.id and es.profile_id = $1
          )
          or exists (
            select 1
            from group_members gm
            where gm.group_id = e.group_id and gm.profile_id = $1 and gm.status = 'active'
          )
        order by e.expense_date desc, e.created_at desc
      `,
      [req.auth.profile.id],
    );

    sendOk(res, result.rows);
  }),
);

expensesRouter.post(
  '/',
  validate(createExpenseSchema),
  asyncHandler(async (req, res) => {
    const body = req.body;
    const groupId = body.groupId || null;

    if (!(await canUseGroup(groupId, req.auth.profile.id))) {
      throw new HttpError(403, 'You do not have access to this group');
    }

    const expense = await withTransaction(async (client) => {
      const expenseResult = await client.query(
        `
          insert into expenses (
            group_id,
            created_by,
            paid_by,
            title,
            amount,
            currency,
            category,
            split_method,
            notes,
            expense_date,
            is_personal,
            status
          )
          values ($1, $2, $3, $4, $5, $6, $7, $8, $9, coalesce($10, current_date), $11, $12)
          returning *
        `,
        [
          groupId,
          req.auth.profile.id,
          body.paidByProfileId || req.auth.profile.id,
          body.title,
          body.amount,
          body.currency,
          body.category,
          body.splitMethod,
          body.notes || null,
          body.expenseDate || null,
          body.isPersonal,
          'approved',
        ],
      );

      const created = expenseResult.rows[0];

      if (body.splits?.length) {
        for (const split of body.splits) {
          if (!split.profileId && !split.memberEmail) {
            throw new HttpError(400, 'Each split needs profileId or memberEmail');
          }

          await client.query(
            `
              insert into expense_splits (
                expense_id,
                profile_id,
                member_email,
                amount,
                percentage
              )
              values ($1, $2, $3, $4, $5)
            `,
            [
              created.id,
              split.profileId || null,
              split.memberEmail?.toLowerCase() || null,
              split.amount,
              split.percentage || null,
            ],
          );
        }
      }

      return created;
    });

    sendCreated(res, expense);
  }),
);

expensesRouter.patch(
  '/:expenseId/status',
  validate(updateExpenseStatusSchema),
  asyncHandler(async (req, res) => {
    const result = await query(
      `
        update expenses
        set status = $2
        where id = $1 and created_by = $3
        returning *
      `,
      [req.params.expenseId, req.body.status, req.auth.profile.id],
    );

    if (!result.rowCount) notFound('Expense not found');
    sendOk(res, result.rows[0]);
  }),
);
