import { Router } from 'express';
import * as controller from './rentalApplications.controller.js';
import { authenticate } from '../../middleware/authenticate.js';

const router = Router();

router.post('/', authenticate, controller.create);
router.get('/my', authenticate, controller.myApplications);
router.get('/property/:propertyId', authenticate, controller.propertyApplications);
router.patch('/:id', authenticate, controller.update);

export default router;
