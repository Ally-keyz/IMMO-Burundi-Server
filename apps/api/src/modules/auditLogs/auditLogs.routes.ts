import { Router } from 'express';
import * as controller from './auditLogs.controller.js';
import { authenticate } from '../../middleware/authenticate.js';

const router = Router();

router.get('/', authenticate, controller.list);

export default router;
