import { z } from 'zod';
import { CURRENCIES, LANGUAGES } from '@immo/shared-types';

export const registerSchema = z.object({
  firstName: z.string().min(1).max(80),
  lastName: z.string().min(1).max(80),
  phone: z.string().min(6).max(30),
  email: z.string().email().optional(),
  password: z.string().min(8).max(128),
  preferredLanguage: z.enum([...LANGUAGES]).optional(),
  preferredCurrency: z.enum([...CURRENCIES]).optional(),
});

export const loginSchema = z.object({
  identifier: z.string().min(3),
  password: z.string().min(1),
});

export const googleSchema = z.object({
  accessToken: z.string().min(20),
  role: z.enum(['CLIENT', 'CUSTOMER', 'AGENT']).optional(),
});

export const refreshSchema = z.object({
  refreshToken: z.string().min(10),
});

export const activateAccountSchema = z.object({
  password: z.string().min(8).max(128),
});

export const logoutSchema = z.object({
  refreshToken: z.string().min(10).optional(),
});

export const otpSendSchema = z.object({
  phone: z.string().min(6),
  purpose: z.enum(['PHONE_VERIFICATION', 'EMAIL_VERIFICATION', 'LOGIN', 'PASSWORD_RESET']),
});

export const otpVerifySchema = z.object({
  phone: z.string().min(6),
  code: z.string().min(4).max(8),
  purpose: z.enum(['PHONE_VERIFICATION', 'EMAIL_VERIFICATION', 'LOGIN', 'PASSWORD_RESET']),
});
