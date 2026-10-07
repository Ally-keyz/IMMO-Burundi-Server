import { Router } from 'express';
import * as controller from './visits.controller.js';
import { authenticate } from '../../middleware/authenticate.js';

const router = Router();

router.post('/sessions', authenticate, controller.createSession);
router.get('/sessions/property/:propertyId', controller.listSessions);
router.post('/book', authenticate, controller.book);
router.get('/bookings/my', authenticate, controller.myBookings);
router.get('/bookings/property/:propertyId', authenticate, controller.propertyBookings);
router.patch('/bookings/:id/cancel', authenticate, controller.cancel);
router.patch('/bookings/:id/status', authenticate, controller.updateStatus);

export default router;
