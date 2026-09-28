import { Router } from 'express';
import * as controller from './agents.controller.js';
import { authenticate, optionalAuth } from '../../middleware/authenticate.js';
import { denyRoles } from '../../helpers/authz.js';

const router = Router();

function denyPublicAgents(req: any, _res: any, next: any): void {
  denyRoles(req, ['AGENT', 'FIELD_AGENT']);
  next();
}

router.get('/', optionalAuth, denyPublicAgents, controller.list);
router.get('/me', authenticate, controller.myProfile);
router.get('/:id', optionalAuth, denyPublicAgents, controller.getOne);

export default router;