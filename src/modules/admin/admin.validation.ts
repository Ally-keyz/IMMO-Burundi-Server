import { z } from 'zod';
import {
  AGENT_VERIFICATION_STATUSES,
  CURRENCIES,
  ENQUIRY_STATUSES,
  USER_ROLES,
  VISIT_BOOKING_STATUSES,
} from '@immo/shared-types';

const pageFields = {
  page: z.coerce.number().int().min(1).optional(),
  pageSize: z.coerce.number().int().min(1).max(100).optional(),
  periodDays: z.coerce.number().int().min(7).max(90).optional(),
};

export const adminListQuerySchema = z.object({
  ...pageFields,
  q: z.string().trim().max(120).optional(),
  status: z.string().trim().max(40).optional(),
  agentId: z.string().trim().max(80).optional(),
  propertyId: z.string().trim().max(120).optional(),
  listingType: z.string().trim().max(30).optional(),
});

export const createAgentSchema = z.object({
  firstName: z.string().trim().min(1).max(80),
  lastName: z.string().trim().min(1).max(80),
  phone: z.string().trim().min(6).max(30),
  email: z.string().trim().email(),
  role: z.enum(['AGENT', 'FIELD_AGENT']),
  agencyName: z.string().trim().max(160).optional(),
  licenseNumber: z.string().trim().max(80).optional(),
  provinceId: z.string().trim().max(80).optional(),
});

export const agentStatusSchema = z.object({
  status: z.enum(['ACTIVE', 'SUSPENDED', 'INACTIVE']),
  reason: z.string().trim().max(500).optional(),
});

export const agentVerificationSchema = z
  .object({
    status: z.enum([...AGENT_VERIFICATION_STATUSES]),
    note: z.string().trim().max(2000).optional(),
    /** Required whenever the agent ends up unverified, so the agent has something to act on. */
    reason: z.string().trim().max(2000).optional(),
  })
  .superRefine((value, ctx) => {
    if (value.status === 'NOT_VERIFIED' && !value.reason) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['reason'],
        message: 'A reason is required when the agent is not verified.',
      });
    }
  });

export const propertyReviewSchema = z.object({
  note: z.string().trim().max(2000).optional(),
  reason: z.string().trim().max(2000).optional(),
});

export const propertyRejectionSchema = propertyReviewSchema.extend({
  reason: z.string().trim().min(3).max(2000),
});

export const propertyBlockSchema = propertyRejectionSchema;

export const propertyVerificationSchema = z.object({
  status: z.enum(['NOT_VERIFIED', 'PARTIAL', 'VERIFIED', 'FULLY_VERIFIED']),
  note: z.string().trim().max(2000).optional(),
});

export const bookingStatusSchema = z.object({
  status: z.enum([...VISIT_BOOKING_STATUSES]),
});

export const enquiryStatusSchema = z.object({
  status: z.enum([...ENQUIRY_STATUSES]),
});

export const financeQuerySchema = z.object({
  from: z.coerce.date().optional(),
  to: z.coerce.date().optional(),
  currency: z.enum([...CURRENCIES]).optional(),
  role: z.enum([...USER_ROLES]).optional(),
});
