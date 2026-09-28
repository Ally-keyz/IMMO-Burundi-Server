import { Server as HTTPServer } from 'http';
import { Server as SocketIOServer, Socket } from 'socket.io';
import jwt from 'jsonwebtoken';
import { env } from './env.js';

let io: SocketIOServer;

export function initSocket(httpServer: HTTPServer): SocketIOServer {
  io = new SocketIOServer(httpServer, {
    cors: { origin: env.WEB_ORIGIN.split(','), credentials: true },
    transports: ['websocket', 'polling'],
  });

  io.use((socket: Socket, next) => {
    const token =
      (socket.handshake.auth?.token as string) ||
      (socket.handshake.headers?.authorization?.replace('Bearer ', '') as string);

    if (!token) {
      socket.data = { userId: null, role: 'GUEST' };
      return next();
    }

    try {
      const decoded = jwt.verify(token, env.JWT_SECRET) as { sub: string; role: string };
      socket.data = { userId: decoded.sub, role: decoded.role };
      next();
    } catch {
      socket.data = { userId: null, role: 'GUEST' };
      next();
    }
  });

  io.on('connection', (socket: Socket) => {
    const userId = socket.data.userId as string | null;
    if (userId) {
      socket.join(`user:${userId}`);
      console.log(`[SOCKET] User ${userId} connected`);
    }

    socket.on('join:property', (propertyId: string) => {
      socket.join(`property:${propertyId}`);
    });

    socket.on('leave:property', (propertyId: string) => {
      socket.leave(`property:${propertyId}`);
    });

    socket.on('disconnect', () => {
      console.log(`[SOCKET] ${userId ?? 'anonymous'} disconnected`);
    });
  });

  return io;
}

export function getIO(): SocketIOServer {
  if (!io) throw new Error('Socket.io not initialized');
  return io;
}