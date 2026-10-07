import { Router } from 'express';
import * as controller from './verification.controller.js';
import { authenticate } from '../../middleware/authenticate.js';

const router = Router();

/* Declared before `/requests/:id` — the agent dashboard loads this on mount. */
router.get('/portfolio', authenticate, controller.portfolio);

router.post('/requests', authenticate, controller.createRequest);
router.get('/requests', authenticate, controller.listRequests);
router.get('/requests/:id', authenticate, controller.getRequest);
router.patch('/requests/:id/assign', authenticate, controller.assign);
router.patch('/requests/:id/start', authenticate, controller.start);
router.post('/requests/:id/checks', authenticate, controller.addCheck);
router.patch('/requests/:id/complete', authenticate, controller.complete);

export default router;
