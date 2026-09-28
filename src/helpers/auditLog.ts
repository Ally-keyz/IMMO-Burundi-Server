import { AuditLog } from '../models/auditLog.model.js';

export interface AuditLogParams {
  /** Null for system-driven events (e.g. a payment link settling with no signed-in actor). */
  actorUserId: string | null;
  action: string;
  resourceType: string;
  resourceId: string;
  oldData?: unknown;
  newData?: unknown;
  ipHash?: string;
  userAgent?: string;
  requestId?: string;
}

/**
 * Append a record to the immutable audit trail.
 * Never throws — audit failures must not break the primary business action.
 */
export async function auditLog(params: AuditLogParams): Promise<void> {
  try {
    await AuditLog.create({
      actorUserId: params.actorUserId,
      action: params.action,
      resourceType: params.resourceType,
      resourceId: params.resourceId,
      oldData: params.oldData,
      newData: params.newData,
      ipHash: params.ipHash,
      userAgent: params.userAgent,
      requestId: params.requestId,
    });
  } catch (err) {
    console.error('[AUDIT] Failed to persist audit log entry', err);
  }
}

export default auditLog;
