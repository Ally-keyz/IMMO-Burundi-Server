import { Request, Response } from 'express';
import * as authService from './auth.service.js';
import { asyncHandler, ok } from '../../helpers/http.js';
import { requireUser } from '../../helpers/authz.js';
import { createHash } from 'crypto';

function hashIp(req: Request): string | undefined {
  const ip = req.ip ?? req.socket?.remoteAddress;
  if (!ip) return undefined;
  return createHash('sha256').update(ip).digest('hex');
}

export const register = asyncHandler(async (req: Request, res: Response) => {
  const result = await authService.register(req.body);
  res.status(201).json({ success: true, data: result });
});

export const login = asyncHandler(async (req: Request, res: Response) => {
  const { identifier, password } = req.body;
  const result = await authService.login(identifier, password, {
    ipHash: hashIp(req),
    userAgent: req.headers['user-agent'],
    requestId: req.requestId,
  });
  ok(res, result);
});

export const googleLogin = asyncHandler(async (req: Request, res: Response) => {
  const result = await authService.googleLogin(req.body.accessToken, req.body?.role);
  ok(res, result);
});

export const refresh = asyncHandler(async (req: Request, res: Response) => {
  const result = await authService.refresh(req.body.refreshToken);
  ok(res, result);
});

export const setup = asyncHandler(async (req: Request, res: Response) => {
  ok(res, await authService.getAccountSetup(String(req.params.token)));
});

export const activateSetup = asyncHandler(async (req: Request, res: Response) => {
  ok(res, await authService.activateAccount(String(req.params.token), req.body.password));
});

export const logout = asyncHandler(async (req: Request, res: Response) => {
  const user = requireUser(req);
  await authService.logout(user.sub, req.body?.refreshToken);
  ok(res, { loggedOut: true });
});

export const sendOtp = asyncHandler(async (req: Request, res: Response) => {
  const result = await authService.sendOtp(req.body.phone, req.body.purpose);
  ok(res, result);
});

export const verifyOtp = asyncHandler(async (req: Request, res: Response) => {
  const result = await authService.verifyOtp(req.body.phone, req.body.code, req.body.purpose);
  ok(res, result);
});

export const me = asyncHandler(async (req: Request, res: Response) => {
  const user = requireUser(req);
  const result = await authService.getMe(user.sub);
  ok(res, result);
});
