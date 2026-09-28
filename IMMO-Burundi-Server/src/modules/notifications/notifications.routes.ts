import { Router } from 'express';
import * as controller from './notifications.controller.js';
import { authenticate } from '../../middleware/authenticate.js';

const router = Router();

router.get('/', authenticate, controller.list);
router.get('/unread-count', authenticate, controller.unreadCount);
router.patch('/:id/read', authenticate, controller.markRead);
router.post('/read-all', authenticate, controller.markAllRead);

export default router;
