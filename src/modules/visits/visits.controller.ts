import { Request, Response } from 'express';
import * as service from './visits.service.js';
import { asyncHandler, created, ok } from '../../helpers/http.js';
import { requireUser } from '../../helpers/authz.js';

export const createSession = asyncHandler(async (req: Request, res: Response) => {
  created(res, await service.createSession(req, req.body));
});

export const listSessions = asyncHandler(async (req: Request, res: Response) => {
  ok(res, await service.listSessions(String(req.params.propertyId)));
});

export const book = asyncHandler(async (req: Request, res: Response) => {
  const user = requireUser(req);
  created(res, await service.bookVisit(user.sub, req.body));
});

export const cancel = asyncHandler(async (req: Request, res: Response) => {
  const user = requireUser(req);
  ok(res, await service.cancelBooking(String(req.params.id), user.sub, req.requestId));
});

export const myBookings = asyncHandler(async (req: Request, res: Response) => {
  const user = requireUser(req);
  const { items, meta } = await service.myBookings(user.sub, req.query);
  ok(res, items, meta);
});

export const updateStatus = asyncHandler(async (req: Request, res: Response) => {
  ok(res, await service.updateBookingStatus(String(req.params.id), req.body.status, req));
});

export const propertyBookings = asyncHandler(async (req: Request, res: Response) => {
  const user = requireUser(req);
  const { items, meta } = await service.propertyBookings(req, String(req.params.propertyId), req.query);
  ok(res, items, meta);
});
