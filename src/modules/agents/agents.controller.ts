import { Request, Response } from 'express';
import * as service from './agents.service.js';
import { asyncHandler, ok } from '../../helpers/http.js';
import { requireUser } from '../../helpers/authz.js';

export const list = asyncHandler(async (req: Request, res: Response) => {
  const { items, meta } = await service.listAgents(req);
  ok(res, items, meta);
});

export const myProfile = asyncHandler(async (req: Request, res: Response) => {
  const user = requireUser(req);
  ok(res, await service.getMyAgent(user.sub));
});

export const getOne = asyncHandler(async (req: Request, res: Response) => {
  const agent = await service.getAgent(String(req.params.id));
  if (!agent) {
    res.status(404).json({ message: 'Agent not found', code: 'AGENT_NOT_FOUND' });
    return;
  }
  ok(res, agent);
});