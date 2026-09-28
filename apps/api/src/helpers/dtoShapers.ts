/**
 * DTO shaping — Backend Spec §97.
 * Never return a raw Mongoose document to a client; every response passes
 * through one of these role-aware shapers.
 */
import {
  AdminPropertyDTO,
  AgentPropertyDTO,
  AgentSummary,
  GeoRef,
  OwnerPropertyDTO,
  PropertyDocumentDTO,
  PropertySummaryDTO,
  PublicPropertyDTO,
} from '@immo/shared-types';

export const VERIFICATION_DISCLAIMER_VERSION = '2025-01';
export const VERIFICATION_DISCLAIMER =
  'IMMO BURUNDI verifies documents as provided and does not guarantee ownership. ' +
  'Independent legal due diligence is always recommended before any transaction.';

function toPlain(doc: any): any {
  if (!doc) return doc;
  if (typeof doc.toObject === 'function') return doc.toObject({ virtuals: false });
  return doc;
}

function iso(value: any): string | undefined {
  if (!value) return undefined;
  const d = value instanceof Date ? value : new Date(value);
  return Number.isNaN(d.getTime()) ? undefined : d.toISOString();
}

function refGeo(value: any, fallbackId?: any): GeoRef {
  if (value && typeof value === 'object' && !(value instanceof Date)) {
    return {
      _id: String(value._id ?? ''),
      code: String(value.code ?? ''),
      name: String(value.name ?? ''),
    };
  }
  return { _id: String(value ?? fallbackId ?? ''), code: '', name: '' };
}

export function shapeAgent(agent: any): AgentSummary | undefined {
  const a = toPlain(agent);
  if (!a || !a._id) return undefined;
  const user = a.userId && typeof a.userId === 'object' ? a.userId : undefined;
  return {
    id: String(a._id),
    agentCode: a.agentCode ?? '',
    firstName: user?.firstName ?? a.firstName ?? '',
    lastName: user?.lastName ?? a.lastName ?? '',
    photoUrl: a.photo ?? user?.photoUrl,
    agencyName: a.agencyName,
    rating: a.rating,
    reviewsCount: a.reviewsCount,
    topAgent: Boolean(a.topAgent),
    totalProperties: a.totalProperties ?? 0,
    totalSales: a.totalSales,
    totalDeals: a.totalDeals,
    province:
      a.provinceId && typeof a.provinceId === 'object' ? refGeo(a.provinceId) : undefined,
    licenseNumber: a.licenseNumber,
    bio: a.bio,
    slogan: a.slogan,
    phone: user?.phone,
    email: user?.email,
  };
}

function shapeMedia(media: any[]): any[] {
  if (!Array.isArray(media)) return [];
  return media.map((m) => {
    const item = toPlain(m);
    return {
      id: String(item._id ?? ''),
      fileKey: item.fileKey ?? '',
      url: item.url,
      thumbUrl: item.thumbUrl,
      caption: item.caption,
      isPrimary: Boolean(item.isPrimary),
      mediaType: item.mediaType ?? 'IMAGE',
      sortOrder: item.sortOrder ?? 0,
    };
  });
}

export function shapeDocuments(documents: any[]): PropertyDocumentDTO[] {
  if (!Array.isArray(documents)) return [];
  return documents.map((d) => {
    const item = toPlain(d);
    return {
      id: String(item._id ?? ''),
      documentType: item.documentType ?? 'OTHER',
      fileName: item.fileName ?? item.fileKey ?? '',
      fileId: item.fileId,
      documentNumber: item.documentNumber,
      issuedBy: item.issuedBy,
      issueDate: iso(item.issueDate),
      expiryDate: iso(item.expiryDate),
      verificationStatus: item.verificationStatus ?? 'NOT_VERIFIED',
      verificationNotes: item.verificationNotes,
    };
  });
}

function personName(user: any): string | undefined {
  const u = toPlain(user);
  if (!u || typeof u !== 'object') return undefined;
  const name = [u.firstName, u.lastName].filter(Boolean).join(' ').trim();
  return name || undefined;
}

/** Public property card — home / search results. */
export function toPropertySummaryDTO(property: any): PropertySummaryDTO {
  const p = toPlain(property);
  const dto: any = {
    id: String(p._id ?? ''),
    _id: String(p._id ?? ''),
    propertyId: p.propertyId,
    title: p.title,
    titleFr: p.titleFr,
    titleEn: p.titleEn,
    titleSw: p.titleSw,
    description: p.description,
    propertyType: p.propertyType,
    listingType: p.listingType,
    status: p.status,
    price: {
      amount: p.price?.amount ?? 0,
      currency: p.price?.currency ?? 'BIF',
    },
    location: {
      province: refGeo(p.provinceId),
      commune: refGeo(p.communeId),
      zone: p.zoneId ? refGeo(p.zoneId) : undefined,
      address: p.address,
      latitude: p.latitude,
      longitude: p.longitude,
      locationPrecision: p.locationPrecision ?? 'APPROXIMATE',
    },
    features: {
      surfaceArea: p.surfaceArea,
      bedrooms: p.bedrooms,
      bathrooms: p.bathrooms,
      rooms: p.rooms,
      floors: p.floors,
      parkingSpaces: p.parkingSpaces,
      yearBuilt: p.yearBuilt,
      isNegotiable: p.isNegotiable,
    },
    media: shapeMedia(p.media),
    agent: shapeAgent(p.agentId),
    verification: {
      status: p.verificationStatus ?? 'NOT_VERIFIED',
      level: p.verificationLevel,
      code: p.verificationCode,
      verifiedAt: iso(p.verifiedAt),
      verificationResult: p.verificationResult,
      disclaimerVersion: p.disclaimerVersion,
    },
    stats: {
      views: p.stats?.views ?? 0,
      favorites: p.stats?.favorites ?? 0,
      shares: p.stats?.shares ?? 0,
    },
    badges: {
      featured: Boolean(p.badges?.featured),
      isNew: p.badges?.isNew ?? true,
      isPromoted: Boolean(p.badges?.isPromoted),
    },
    publishedAt: iso(p.publishedAt),
    createdAt: iso(p.createdAt) ?? new Date().toISOString(),
  };
  return dto as PropertySummaryDTO;
}

/** Full public detail — adds owner first name + verification disclaimer. */
export function toPublicPropertyDTO(property: any): PublicPropertyDTO {
  const p = toPlain(property);
  const base = toPropertySummaryDTO(p);
  const owner = toPlain(p.ownerUserId);
  const dto: any = {
    ...base,
    ownerFirstName: owner && typeof owner === 'object' ? owner.firstName : undefined,
    verificationDisclaimer: VERIFICATION_DISCLAIMER,
  };
  return dto as PublicPropertyDTO;
}

/** Owner / landlord view — private owner fields + internal analytics. */
export function toOwnerPropertyDTO(property: any): OwnerPropertyDTO {
  const p = toPlain(property);
  const base = toPublicPropertyDTO(p);
  const owner = toPlain(p.ownerUserId);
  const analytics = p.analytics ?? {};
  const dto: any = {
    ...base,
    ownerPhonePrivate: owner && typeof owner === 'object' ? owner.phone : undefined,
    ownerEmailPrivate: owner && typeof owner === 'object' ? owner.email : undefined,
    ownerAddressPrivate: owner && typeof owner === 'object' ? owner.address : undefined,
    createdByName: personName(p.createdBy),
    approvedByName: personName(p.approvedBy),
    publishedByName: personName(p.publishedBy),
    ownerAnalytics: {
      totalViews: analytics.totalViews ?? p.stats?.views ?? 0,
      uniqueVisitors: analytics.uniqueVisitors ?? 0,
      whatsappClicks: analytics.whatsappClicks ?? p.stats?.whatsappClicks ?? 0,
      phoneClicks: analytics.phoneClicks ?? p.stats?.phoneClicks ?? 0,
      enquiries: analytics.enquiries ?? p.stats?.enquiries ?? 0,
      visitBookings: analytics.visitBookings ?? p.stats?.visitBookings ?? 0,
    },
    blockReason: p.blockReason,
    blockedAt: iso(p.blockedAt),
  };
  return dto as OwnerPropertyDTO;
}

/** Agent view — agent-visible analytics. */
export function toAgentPropertyDTO(property: any): AgentPropertyDTO {
  const p = toPlain(property);
  const base = toOwnerPropertyDTO(p);
  const analytics = p.analytics ?? {};
  const dto: any = {
    ...base,
    agentAnalytics: {
      viewsGenerated: analytics.viewsGenerated ?? p.stats?.views ?? 0,
      enquiriesGenerated: analytics.enquiriesGenerated ?? p.stats?.enquiries ?? 0,
      visitBookings: analytics.visitBookings ?? p.stats?.visitBookings ?? 0,
      conversionRate: analytics.conversionRate,
    },
    documents: shapeDocuments(p.documents),
    verificationNotes: p.verificationNotes,
    rejectionReason: p.rejectionReason,
  };
  return dto as AgentPropertyDTO;
}

/** Admin view — everything, including internal notes and documents. */
export function toAdminPropertyDTO(property: any): AdminPropertyDTO {
  const p = toPlain(property);
  const base = toOwnerPropertyDTO(p);
  const dto: any = {
    ...base,
    ownerUserId: p.ownerUserId ? String(p.ownerUserId._id ?? p.ownerUserId) : undefined,
    landlordUserId: p.landlordUserId ? String(p.landlordUserId._id ?? p.landlordUserId) : undefined,
    createdById: p.createdBy ? String(p.createdBy._id ?? p.createdBy) : undefined,
    approvedById: p.approvedBy ? String(p.approvedBy._id ?? p.approvedBy) : undefined,
    publishedById: p.publishedBy ? String(p.publishedBy._id ?? p.publishedBy) : undefined,
    internalNotes: p.internalNotes,
    reviewNote: p.reviewNote,
    rejectionReason: p.rejectionReason,
    reviewedBy: p.reviewedBy ? String(p.reviewedBy._id ?? p.reviewedBy) : undefined,
    reviewedByName: personName(p.reviewedBy),
    reviewedAt: iso(p.reviewedAt),
    blockReason: p.blockReason,
    blockedAt: iso(p.blockedAt),
    blockedById: p.blockedBy ? String(p.blockedBy._id ?? p.blockedBy) : undefined,
    documents: shapeDocuments(p.documents),
    verificationNotes: p.verificationNotes,
  };
  return dto as AdminPropertyDTO;
}
