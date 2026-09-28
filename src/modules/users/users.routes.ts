import { Router } from 'express';
import * as controller from './users.controller.js';
import { authenticate } from '../../middleware/authenticate.js';

const router = Router();

router.get('/', authenticate, controller.list);
router.get('/me', authenticate, controller.me);
router.get('/me/recent-views', authenticate, controller.recentViews);
router.get('/:id', authenticate, controller.getOne);
router.patch('/:id', authenticate, controller.update);

export default router;
