import { Router } from 'express';
import * as controller from './geo.controller.js';

const router = Router();

router.get('/provinces', controller.provinces);
router.get('/provinces/:id/communes', controller.communes);
router.get('/communes/:id/zones', controller.zones);
router.get('/exchange-rates', controller.exchangeRates);

export default router;
