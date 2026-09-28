import { Router } from 'express';
import { authenticate } from '../../middleware/authenticate.js';
import * as controller from '../properties/properties.controller.js';

const router = Router();

router.get('/', authenticate, controller.listManaged);
router.get('/:id/analytics', authenticate, controller.managedAnalytics);
router.get('/:id', authenticate, controller.getManaged);
router.patch('/:id', authenticate, controller.updateManaged);
router.delete('/:id', authenticate, controller.deleteManaged);

export default router;
