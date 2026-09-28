import { Router } from 'express';
import * as controller from './paymentLinks.controller.js';
import { authenticate, optionalAuth } from '../../middleware/authenticate.js';

const router = Router();

router.post('/', authenticate, controller.create);
router.get('/agent', authenticate, controller.listAgentLinks);
// Anyone holding the token may view and pay a link — no account required.
router.get('/r/:token', optionalAuth, controller.resolveLink);
router.post('/r/:token/pay', optionalAuth, controller.payLink);

export default router;