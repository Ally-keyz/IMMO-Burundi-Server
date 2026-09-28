import { Request, Response } from 'express';
import * as service from './messaging.service.js';
import { asyncHandler, created, ok } from '../../helpers/http.js';
import { requireUser } from '../../helpers/authz.js';

export const createConversation = asyncHandler(async (req: Request, res: Response) => {
  const user = requireUser(req);
  created(res, await service.createOrGetConversation(user.sub, req.body));
});

export const listConversations = asyncHandler(async (req: Request, res: Response) => {
  const user = requireUser(req);
  ok(res, await service.listConversations(user.sub));
});

export const listMessages = asyncHandler(async (req: Request, res: Response) => {
  const user = requireUser(req);
  const { items, meta } = await service.listMessages(String(req.params.id), user.sub, req.query);
  ok(res, items, meta);
});

export const sendMessage = asyncHandler(async (req: Request, res: Response) => {
  const user = requireUser(req);
  created(res, await service.sendMessage(String(req.params.id), user.sub, req.body));
});
