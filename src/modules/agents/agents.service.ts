import { Request } from 'express';
import Agent from '../../models/agent.model.js';
import { shapeAgent } from '../../helpers/dtoShapers.js';
import { paginationMeta, parsePagination } from '../../helpers/http.js';

function escapeRegex(value: string): string {
  return value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

/**
 * Public agent directory — active agents only, with optional text search
 * (name / code / agency), province and top-agent filters.
 */
export async function listAgents(req: Request) {
  const { page, pageSize, skip } = parsePagination(req.query);
  const q = typeof req.query.q === 'string' ? req.query.q.trim() : '';
  const province = typeof req.query.province === 'string' && req.query.province ? req.query.province : undefined;
  const topAgent = req.query.topAgent === 'true' || req.query.topAgent === '1';

  const match: Record<string, unknown> = { status: 'ACTIVE' };
  if (province) match.provinceId = province;
  if (topAgent) match.topAgent = true;

  const pipeline: any[] = [
    { $match: match },
    {
      $lookup: {
        from: 'users',
        localField: 'userId',
        foreignField: '_id',
        as: 'user',
      },
    },
    {
      $addFields: {
        userId: { $arrayElemAt: ['$user', 0] },
        fullName: {
          $trim: {
            input: {
              $concat: [
                { $ifNull: [{ $arrayElemAt: ['$user.firstName', 0] }, ''] },
                ' ',
                { $ifNull: [{ $arrayElemAt: ['$user.lastName', 0] }, ''] },
              ],
            },
          },
        },
      },
    },
  ];

  if (q) {
    const rx = new RegExp(escapeRegex(q), 'i');
    pipeline.push({
      $match: {
        $or: [{ agentCode: rx }, { agencyName: rx }, { fullName: rx }],
      },
    });
  }

  pipeline.push(
    { $sort: { topAgent: -1, rating: -1, totalProperties: -1, createdAt: -1 } },
    { $facet: { total: [{ $count: 'count' }], items: [{ $skip: skip }, { $limit: pageSize }] } },
  );

  const [{ total, items }] = await Agent.aggregate(pipeline as any);
  const count = total.length ? total[0].count : 0;

  await Agent.populate(items, { path: 'provinceId', select: 'name code' });

  return {
    items: items.map(shapeAgent),
    meta: paginationMeta(page, pageSize, count),
  };
}

/** Current user's own agent profile (if any) — returns null otherwise. */
export async function getMyAgent(userId: string) {
  const agent = await Agent.findOne({ userId })
    .populate('provinceId', 'name code')
    .populate('userId', 'firstName lastName photoUrl');
  return agent ? shapeAgent(agent as any) : null;
}

/** Public single-agent profile for the channel page. */
export async function getAgent(agentId: string) {
  const agent = await Agent.findOne({ _id: agentId, status: 'ACTIVE' })
    .populate('provinceId', 'name code')
    .populate('userId', 'firstName lastName photoUrl phone email');
  return agent ? shapeAgent(agent as any) : null;
}