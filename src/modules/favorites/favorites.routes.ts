import { Router } from 'express';
import * as controller from './favorites.controller.js';
import { authenticate } from '../../middleware/authenticate.js';

const router = Router();

router.get('/', authenticate, controller.list);
router.post('/', authenticate, controller.add);
router.delete('/:propertyId', authenticate, controller.remove);

export default router;
