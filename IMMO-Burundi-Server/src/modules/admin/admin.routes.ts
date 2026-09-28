import { Router } from 'express';
import { authenticate } from '../../middleware/authenticate.js';
import { requireRole } from '../../helpers/authz.js';
import { validateBody, validateQuery } from '../../helpers/validate.js';
import * as controller from './admin.controller.js';
import {
  adminListQuerySchema,
  agentStatusSchema,
  agentVerificationSchema,
  bookingStatusSchema,
  createAgentSchema,
  enquiryStatusSchema,
  propertyBlockSchema,
  propertyRejectionSchema,
  propertyReviewSchema,
  propertyVerificationSchema,
} from './admin.validation.js';

const router = Router();

function mainAdmin(req: any, _res: any, next: any): void {
  requireRole(req, ['MAIN_ADMIN']);
  next();
}

router.use(authenticate, mainAdmin);

router.get('/dashboard/summary', validateQuery(adminListQuerySchema), controller.summary);
router.get('/agents', validateQuery(adminListQuerySchema), controller.listAgents);
router.post('/agents', validateBody(createAgentSchema), controller.createAgent);
router.patch('/agents/:id/status', validateBody(agentStatusSchema), controller.updateAgentStatus);
router.patch('/agents/:id/verification', validateBody(agentVerificationSchema), controller.setAgentVerification);
router.get('/properties', validateQuery(adminListQuerySchema), controller.listProperties);
router.post('/properties/:id/approve', validateBody(propertyReviewSchema), controller.approveProperty);
router.post('/properties/:id/reject', validateBody(propertyRejectionSchema), controller.rejectProperty);
router.post('/properties/:id/request-correction', validateBody(propertyReviewSchema), controller.requestPropertyCorrection);
router.post('/properties/:id/block', validateBody(propertyBlockSchema), controller.blockProperty);
router.post('/properties/:id/unblock', validateBody(propertyReviewSchema), controller.unblockProperty);
router.patch('/properties/:id/verification', validateBody(propertyVerificationSchema), controller.setPropertyVerification);
router.get('/bookings', validateQuery(adminListQuerySchema), controller.listBookings);
router.patch('/bookings/:id/status', validateBody(bookingStatusSchema), controller.updateBookingStatus);
router.get('/requests', validateQuery(adminListQuerySchema), controller.listRequests);
router.patch('/requests/:id/status', validateBody(enquiryStatusSchema), controller.updateRequestStatus);

export default router;
