import { Router } from 'express';
import * as controller from './enquiries.controller.js';
import { authenticate } from '../../middleware/authenticate.js';

const router = Router();

router.post('/', authenticate, controller.create);
router.get('/', authenticate, controller.listMine);
router.get('/inbox', authenticate, controller.agentInbox);
router.get('/property/:propertyId', authenticate, controller.listForProperty);
router.patch('/:id/respond', authenticate, controller.respond);
router.patch('/:id/status', authenticate, controller.setStatus);

export default router;
