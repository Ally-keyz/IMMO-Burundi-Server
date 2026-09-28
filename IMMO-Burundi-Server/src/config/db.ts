import mongoose from 'mongoose';
import { env } from './env.js';

let isConnected = false;

/** Never log the credentials embedded in a mongodb+srv:// URI. */
function redact(uri: string): string {
  return uri.replace(/\/\/([^@/]+)@/, '//***:***@');
}

export async function connectDB(): Promise<void> {
  if (isConnected) return;
  await mongoose.connect(env.MONGODB_URI);
  isConnected = true;
  console.log(`[DB] Connected to ${redact(env.MONGODB_URI)}`);
}

export async function disconnectDB(): Promise<void> {
  if (!isConnected) return;
  await mongoose.disconnect();
  isConnected = false;
  console.log('[DB] Disconnected');
}