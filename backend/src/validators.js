import { z } from 'zod';
import { HttpError } from './http.js';

export function validate(schema, source = 'body') {
  return (req, _res, next) => {
    const result = schema.safeParse(req[source]);

    if (!result.success) {
      next(new HttpError(400, 'Invalid request', result.error.flatten()));
      return;
    }

    req[source] = result.data;
    next();
  };
}

export const uuidParamSchema = z.object({
  groupId: z.string().uuid().optional(),
  expenseId: z.string().uuid().optional(),
});

export const profileUpdateSchema = z.object({
  fullName: z.string().trim().min(1).max(120).optional(),
  avatar: z.string().trim().max(32).optional(),
  phone: z.string().trim().max(32).optional(),
  upiId: z.string().trim().max(320).nullable().optional(),
});

export const createGroupSchema = z.object({
  name: z.string().trim().min(1).max(120),
  companyName: z.string().trim().min(1).max(160),
  type: z.string().trim().min(1).max(40).default('Other'),
  approvalRequired: z.boolean().default(false),
  imageUrl: z.string().url().nullable().optional(),
});

export const joinGroupSchema = z.object({
  inviteCode: z.string().trim().min(4).max(16),
});

export const addMemberSchema = z.object({
  email: z.string().trim().email(),
  displayName: z.string().trim().min(1).max(120).optional(),
  avatar: z.string().trim().max(32).optional(),
});

export const createExpenseSchema = z.object({
  groupId: z.string().uuid().nullable().optional(),
  title: z.string().trim().min(1).max(180),
  amount: z.coerce.number().positive(),
  currency: z.string().trim().length(3).default('INR'),
  category: z.string().trim().min(1).max(60).default('other'),
  splitMethod: z.enum(['equal', 'exact', 'percentage']).default('equal'),
  notes: z.string().trim().max(1000).nullable().optional(),
  expenseDate: z.string().date().optional(),
  isPersonal: z.boolean().default(false),
  paidByProfileId: z.string().uuid().nullable().optional(),
  splits: z
    .array(
      z.object({
        profileId: z.string().uuid().nullable().optional(),
        memberEmail: z.string().trim().email().nullable().optional(),
        amount: z.coerce.number().nonnegative(),
        percentage: z.coerce.number().min(0).max(100).nullable().optional(),
      }),
    )
    .optional(),
});

export const updateExpenseStatusSchema = z.object({
  status: z.enum(['pending', 'approved', 'rejected']),
});

export const createSettlementSchema = z.object({
  groupId: z.string().uuid().nullable().optional(),
  payeeProfileId: z.string().uuid().nullable().optional(),
  payeeEmail: z.string().trim().email().nullable().optional(),
  amount: z.coerce.number().positive(),
  currency: z.string().trim().length(3).default('INR'),
  status: z.enum(['pending', 'completed', 'failed', 'cancelled']).default('pending'),
  note: z.string().trim().max(500).nullable().optional(),
});
