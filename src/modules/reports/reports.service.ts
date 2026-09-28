import { AppError } from '../../middleware/errorHandler.js';
import { Report } from '../../models/report.model.js';
import '../../models/users.model.js';
import { auditLog } from '../../helpers/auditLog.js';

const RESOURCE_TYPES = ['Property', 'User', 'Enquiry', 'Message', 'RentalApplication'];

export async function createReport(userId: string, body: any) {
  if (!RESOURCE_TYPES.includes(body.resourceType)) {
    throw new AppError(400, 'INVALID_RESOURCE_TYPE', `resourceType must be one of ${RESOURCE_TYPES.join(', ')}.`);
  }

  const report = await Report.create({
    reporterId: userId,
    resourceType: body.resourceType,
    resourceId: body.resourceId,
    reason: body.reason,
    description: body.description,
    status: 'PENDING',
  });

  await auditLog({
    actorUserId: userId,
    action: 'REPORT_CREATED',
    resourceType: 'Report',
    resourceId: String(report._id),
    newData: { reportedResource: body.resourceType, reason: body.reason },
  });

  return report;
}

export async function listReports(query: any) {
  const page = Math.max(1, Number(query.page) || 1);
  const pageSize = Math.min(100, Math.max(1, Number(query.pageSize) || 20));
  const skip = (page - 1) * pageSize;

  const filter: Record<string, any> = {};
  if (query.status) filter.status = query.status;
  if (query.resourceType) filter.resourceType = query.resourceType;
  if (query.reason) filter.reason = query.reason;

  const [items, total] = await Promise.all([
    Report.find(filter)
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(pageSize)
      .populate('reporterId', 'firstName lastName phone')
      .populate('assignedTo', 'firstName lastName'),
    Report.countDocuments(filter),
  ]);

  return {
    items,
    meta: { page, pageSize, total, totalPages: Math.max(1, Math.ceil(total / pageSize)) },
  };
}
