import { AuditLog } from '../../models/auditLog.model.js';

export async function listAuditLogs(query: any) {
  const page = Math.max(1, Number(query.page) || 1);
  const pageSize = Math.min(200, Math.max(1, Number(query.pageSize) || 50));
  const skip = (page - 1) * pageSize;

  const filter: Record<string, any> = {};
  if (query.action) filter.action = query.action;
  if (query.resourceType) filter.resourceType = query.resourceType;
  if (query.actorUserId) filter.actorUserId = query.actorUserId;
  if (query.resourceId) filter.resourceId = query.resourceId;
  if (query.from || query.to) {
    filter.createdAt = {};
    if (query.from) filter.createdAt.$gte = new Date(query.from);
    if (query.to) filter.createdAt.$lte = new Date(query.to);
  }

  const [items, total] = await Promise.all([
    AuditLog.find(filter)
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(pageSize)
      .populate('actorUserId', 'firstName lastName role')
      .lean(),
    AuditLog.countDocuments(filter),
  ]);

  return {
    items,
    meta: { page, pageSize, total, totalPages: Math.max(1, Math.ceil(total / pageSize)) },
  };
}
