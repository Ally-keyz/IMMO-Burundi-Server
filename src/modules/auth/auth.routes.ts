import { Router } from 'express';
import * as controller from './auth.controller.js';
import { authenticate } from '../../middleware/authenticate.js';
import { validateBody } from '../../helpers/validate.js';
import {
  googleSchema,
  activateAccountSchema,
  loginSchema,
  logoutSchema,
  otpSendSchema,
  otpVerifySchema,
  refreshSchema,
  registerSchema,
} from './auth.validation.js';

const router = Router();

router.post('/register', validateBody(registerSchema), controller.register);
router.post('/login', validateBody(loginSchema), controller.login);
router.post('/google', validateBody(googleSchema), controller.googleLogin);
router.post('/refresh', validateBody(refreshSchema), controller.refresh);
router.post('/logout', authenticate, validateBody(logoutSchema), controller.logout);
router.post('/otp/send', validateBody(otpSendSchema), controller.sendOtp);
router.post('/otp/verify', validateBody(otpVerifySchema), controller.verifyOtp);
router.get('/setup/:token', controller.setup);
router.post('/setup/:token', validateBody(activateAccountSchema), controller.activateSetup);
router.get('/me', authenticate, controller.me);

export default router;
