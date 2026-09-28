import { Router } from 'express';
import * as controller from './messaging.controller.js';
import { authenticate } from '../../middleware/authenticate.js';

const router = Router();

router.post('/conversations', authenticate, controller.createConversation);
router.get('/conversations', authenticate, controller.listConversations);
router.get('/conversations/:id/messages', authenticate, controller.listMessages);
router.post('/conversations/:id/messages', authenticate, controller.sendMessage);

export default router;
