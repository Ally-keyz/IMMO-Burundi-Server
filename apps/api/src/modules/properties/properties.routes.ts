import { Router } from 'express';
import * as controller from './properties.controller.js';
import { authenticate, optionalAuth } from '../../middleware/authenticate.js';
import { denyRoles } from '../../helpers/authz.js';

const router = Router();

function denyPublicAgents(req: any, _res: any, next: any): void {
  denyRoles(req, ['AGENT', 'FIELD_AGENT']);
  next();
}

/* ── Static routes (must precede /:id) ────────────────────── */
router.get('/featured', optionalAuth, denyPublicAgents, controller.featured);
router.get('/recent', optionalAuth, denyPublicAgents, controller.recent);
router.get('/verified', optionalAuth, denyPublicAgents, controller.verified);
router.get('/popular-locations', optionalAuth, denyPublicAgents, controller.popularLocations);

/* ── Collection ───────────────────────────────────────────── */
router.post('/', authenticate, controller.create);
router.get('/', optionalAuth, denyPublicAgents, controller.list);

/* ── Item ─────────────────────────────────────────────────── */
router.get('/:id', optionalAuth, denyPublicAgents, controller.getOne);
router.patch('/:id', authenticate, controller.update);
router.post('/:id/submit', authenticate, controller.submit);
router.post('/:id/approve', authenticate, controller.approve);
router.post('/:id/reject', authenticate, controller.reject);
router.post('/:id/request-correction', authenticate, controller.requestCorrection);
router.post('/:id/publish', authenticate, controller.publish);
router.post('/:id/unpublish', authenticate, controller.unpublish);
router.post('/:id/archive', authenticate, controller.archive);
router.post('/:id/mark-sold', authenticate, controller.markSold);
router.post('/:id/mark-rented', authenticate, controller.markRented);
router.post('/:id/relist', authenticate, controller.relist);
router.get('/:id/related', optionalAuth, denyPublicAgents, controller.related);
router.post('/:id/favorite', authenticate, controller.favorite);
router.get('/:id/analytics', authenticate, controller.analytics);

export default router;
