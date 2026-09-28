import { Router } from 'express';
import * as controller from './reports.controller.js';
import { authenticate } from '../../middleware/authenticate.js';

const router = Router();

router.post('/', authenticate, controller.create);
router.get('/', authenticate, controller.list);

export default router;
