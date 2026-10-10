import { Router } from 'express';
import * as controller from './deals.controller.js';
import { authenticate } from '../../middleware/authenticate.js';

const router = Router();

router.post('/mark-paid', authenticate, controller.markPaid);

export default router;
