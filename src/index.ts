import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { mkdirSync } from 'node:fs';
import path from 'node:path';
import { createServer } from 'http';
import { Server as SocketIOServer } from 'socket.io';
import { env, databaseFromUri } from './config/env.js';
import { connectDB } from './config/db.js';
import { requestId } from './middleware/requestId.js';
import { notFound, errorHandler } from './middleware/errorHandler.js';

/* ── Routes (imported after DB connected) ─────────────────── */
import authRoutes from './modules/auth/auth.routes.js';
import userRoutes from './modules/users/users.routes.js';
import propertyRoutes from './modules/properties/properties.routes.js';
import agentPropertyRoutes from './modules/properties/agentProperties.routes.js';
import favoriteRoutes from './modules/favorites/favorites.routes.js';
import enquiryRoutes from './modules/enquiries/enquiries.routes.js';
import visitRoutes from './modules/visits/visits.routes.js';
import rentalAppRoutes from './modules/rentalApplications/rentalApplications.routes.js';
import geoRoutes from './modules/geo/geo.routes.js';
import notificationRoutes from './modules/notifications/notifications.routes.js';
import messagingRoutes from './modules/messaging/messaging.routes.js';
import reportRoutes from './modules/reports/reports.routes.js';
import auditRoutes from './modules/auditLogs/auditLogs.routes.js';
import verificationRoutes from './modules/verification/verification.routes.js';
import agentRoutes from './modules/agents/agents.routes.js';
import dealsRoutes from './modules/deals/deals.routes.js';
import fileRoutes from './modules/files/files.routes.js';
import adminRoutes from './modules/admin/admin.routes.js';

/* ── Socket.io helpers ────────────────────────────────────── */
import { initSocket } from './config/socket.js';
import { disconnectDB } from './config/db.js';
import { startKeepWarm, type KeepWarmHandle } from './config/keepWarm.js';

let io: SocketIOServer;
let httpServer: ReturnType<typeof createServer>;
let keepWarm: KeepWarmHandle | null = null;

async function bootstrap(): Promise<void> {
  await connectDB();

  const app = express();
  httpServer = createServer(app);
  io = initSocket(httpServer);

  /* ── Global middleware ─────────────────────────────────── */
  // Render terminates TLS and forwards the real client IP in
  // X-Forwarded-For. Without this every request reports the proxy's address,
  // which is what audit-log IP hashing and any future rate limiting key on.
  app.set('trust proxy', 1);

  app.use(helmet({ crossOriginResourcePolicy: { policy: 'cross-origin' } }));
  app.use(cors({ origin: env.WEB_ORIGIN.split(','), credentials: true }));
  app.use(express.json({ limit: '10mb' }));
  app.use(requestId);

  /* ── Local file storage (profile photos etc.) ──────────── */
  // Only meaningful for STORAGE_DRIVER=LOCAL. Under CLOUDINARY every image has
  // an absolute res.cloudinary.com URL, so this mount would serve nothing and
  // would 404 with a 200 for missing files if it stayed.
  if (env.STORAGE_DRIVER === 'LOCAL') {
    const storageDir = path.resolve(process.cwd(), env.STORAGE_LOCAL_DIR);
    mkdirSync(storageDir, { recursive: true });
    app.use('/uploads', express.static(storageDir));
  }

  /* ── Health check ─────────────────────────────────────── */
  // The database name is in the payload on purpose: a site showing zero
  // listings is nearly always a MONGODB_URI pointing at the wrong database,
  // and "test" is otherwise invisible from outside.
  app.get('/api/health', (_req, res) => {
    res.json({
      success: true,
      data: {
        status: 'ok',
        uptime: process.uptime(),
        database: databaseFromUri(env.MONGODB_URI),
        storage: env.STORAGE_DRIVER,
      },
    });
  });

  /* ── Mount routes ─────────────────────────────────────── */
  app.use('/api/auth', authRoutes);
  app.use('/api/users', userRoutes);
  app.use('/api/properties', propertyRoutes);
  app.use('/api/agent/properties', agentPropertyRoutes);
  app.use('/api/favorites', favoriteRoutes);
  app.use('/api/enquiries', enquiryRoutes);
  app.use('/api/visits', visitRoutes);
  app.use('/api/rental-applications', rentalAppRoutes);
  app.use('/api/geo', geoRoutes);
  app.use('/api/notifications', notificationRoutes);
  app.use('/api/messages', messagingRoutes);
  app.use('/api/reports', reportRoutes);
  app.use('/api/audit-logs', auditRoutes);
  app.use('/api/verification', verificationRoutes);
  app.use('/api/agents', agentRoutes);
  app.use('/api/deals', dealsRoutes);
  app.use('/api/files', fileRoutes);
  app.use('/api/admin', adminRoutes);

  /* ── 404 + error handler ──────────────────────────────── */
  app.use(notFound);
  app.use(errorHandler);

  httpServer.listen(env.PORT, () => {
    console.log(`[API] Running on http://localhost:${env.PORT} (${env.NODE_ENV})`);
    // Started only once the socket is actually accepting connections, so the
    // first scheduled ping cannot race the listen.
    keepWarm = startKeepWarm();
  });
}

bootstrap().catch((err) => {
  console.error('[FATAL]', err);
  process.exit(1);
});

/**
 * Render sends SIGTERM before every deploy and restart. Without a handler the
 * process dies mid-request and in-flight socket connections are severed with
 * no log, so drain explicitly and give the work a bounded window to finish.
 */
for (const signal of ['SIGTERM', 'SIGINT'] as const) {
  process.on(signal, () => {
    console.log(`[API] ${signal} received — draining connections`);
    // Stop pinging before closing, otherwise a ping can be in flight against
    // this instance while it is tearing down.
    keepWarm?.stop();
    keepWarm = null;
    const force = setTimeout(() => {
      console.warn('[API] Drain timed out — forcing exit');
      process.exit(1);
    }, 10_000);
    force.unref();

    httpServer.close((err) => {
      if (err) console.error('[API] Error while closing HTTP server:', err);
      void disconnectDB()
        .catch((dbErr) => console.error('[API] Error while closing DB:', dbErr))
        .finally(() => process.exit(err ? 1 : 0));
    });
  });
}

export { io };