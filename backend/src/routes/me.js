import { Router } from 'express';
import { query } from '../db.js';
import { asyncHandler, sendOk } from '../http.js';
import { profileUpdateSchema, validate } from '../validators.js';

export const meRouter = Router();

meRouter.get(
  '/',
  asyncHandler(async (req, res) => {
    sendOk(res, req.auth.profile);
  }),
);

meRouter.patch(
  '/',
  validate(profileUpdateSchema),
  asyncHandler(async (req, res) => {
    const { fullName, avatar, phone, upiId } = req.body;
    const result = await query(
      `
        update profiles
        set
          full_name = coalesce($2, full_name),
          avatar = coalesce($3, avatar),
          phone = coalesce($4, phone),
          upi_id = coalesce($5, upi_id)
        where id = $1
        returning *
      `,
      [req.auth.profile.id, fullName, avatar, phone, upiId],
    );

    req.auth.profile = result.rows[0];
    sendOk(res, result.rows[0]);
  }),
);
