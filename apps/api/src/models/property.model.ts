import { Schema, model } from 'mongoose';
import {
  CURRENCIES,
  DOCUMENT_TYPES,
  LISTING_TYPES,
  LOCATION_PRECISIONS,
  MEDIA_TYPES,
  PROPERTY_STATUSES,
  PROPERTY_TYPES,
  VERIFICATION_RESULTS,
  VERIFICATION_STATUSES,
} from '@immo/shared-types';

/* ── Embedded sub-documents ───────────────────────────────── */

export const propertyMediaSchema = new Schema(
  {
    fileKey: { type: String, required: true },
    url: { type: String },
    thumbUrl: { type: String },
    caption: { type: String },
    isPrimary: { type: Boolean, default: false },
    mediaType: { type: String, enum: [...MEDIA_TYPES], default: 'IMAGE' },
    sortOrder: { type: Number, default: 0 },
  },
  { _id: true },
);

export const propertyDocumentSchema = new Schema(
  {
    documentType: { type: String, enum: [...DOCUMENT_TYPES], required: true },
    fileId: { type: String },
    documentNumber: { type: String },
    issuedBy: { type: String },
    issueDate: { type: Date },
    expiryDate: { type: Date },
    verificationStatus: { type: String, enum: [...VERIFICATION_RESULTS], default: 'NOT_VERIFIED' },
    verificationNotes: { type: String },
  },
  { _id: true },
);

const priceSchema = new Schema(
  {
    amount: { type: Number, required: true, min: 0 },
    currency: { type: String, enum: [...CURRENCIES], default: 'BIF' },
  },
  { _id: false },
);

const statsSchema = new Schema(
  {
    views: { type: Number, default: 0 },
    favorites: { type: Number, default: 0 },
    shares: { type: Number, default: 0 },
    whatsappClicks: { type: Number, default: 0 },
    phoneClicks: { type: Number, default: 0 },
    enquiries: { type: Number, default: 0 },
    visitBookings: { type: Number, default: 0 },
  },
  { _id: false },
);

const badgesSchema = new Schema(
  {
    featured: { type: Boolean, default: false },
    isNew: { type: Boolean, default: true },
    isPromoted: { type: Boolean, default: false },
  },
  { _id: false, suppressReservedKeysWarning: true },
);

/* ── Property — Backend Spec §14 ──────────────────────────── */

export const propertySchema = new Schema(
  {
    propertyId: { type: String, required: true, unique: true, immutable: true },

    // Ownership / responsibility
    ownerUserId: { type: Schema.Types.ObjectId, ref: 'User', index: true },
    landlordUserId: { type: Schema.Types.ObjectId, ref: 'User', index: true },
    agentId: { type: Schema.Types.ObjectId, ref: 'Agent', index: true },
    createdBy: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    approvedBy: { type: Schema.Types.ObjectId, ref: 'User' },
    publishedBy: { type: Schema.Types.ObjectId, ref: 'User' },

    // Multilingual content
    title: { type: String, required: true, trim: true },
    titleFr: { type: String, trim: true },
    titleEn: { type: String, trim: true },
    titleSw: { type: String, trim: true },
    description: { type: String },
    descriptionFr: { type: String },
    descriptionEn: { type: String },
    descriptionSw: { type: String },

    // Classification
    propertyType: { type: String, enum: [...PROPERTY_TYPES], required: true, index: true },
    listingType: { type: String, enum: [...LISTING_TYPES], required: true, index: true },
    status: { type: String, enum: [...PROPERTY_STATUSES], default: 'DRAFT', index: true },
    verificationStatus: { type: String, enum: [...VERIFICATION_STATUSES], default: 'NOT_VERIFIED', index: true },
    verificationLevel: { type: String },
    verificationCode: { type: String },
    verificationResult: { type: String },
    verificationNotes: { type: String },
    verifiedAt: { type: Date },
    verifiedBy: { type: Schema.Types.ObjectId, ref: 'User' },
    disclaimerVersion: { type: String },

    // Pricing
    price: { type: priceSchema, required: true },
    isNegotiable: { type: Boolean, default: false },

    // Features
    surfaceArea: { type: Number },
    bedrooms: { type: Number },
    bathrooms: { type: Number },
    rooms: { type: Number },
    floors: { type: Number },
    parkingSpaces: { type: Number },
    yearBuilt: { type: Number },

    // Location
    provinceId: { type: Schema.Types.ObjectId, ref: 'Province', index: true },
    communeId: { type: Schema.Types.ObjectId, ref: 'Commune', index: true },
    zoneId: { type: Schema.Types.ObjectId, ref: 'Zone' },
    address: { type: String },
    latitude: { type: Number },
    longitude: { type: Number },
    locationPrecision: { type: String, enum: [...LOCATION_PRECISIONS], default: 'APPROXIMATE' },

    // Media & documents
    media: { type: [propertyMediaSchema], default: [] },
    documents: { type: [propertyDocumentSchema], default: [] },

    // Denormalized counters / badges
    stats: { type: statsSchema, default: () => ({}) },
    badges: { type: badgesSchema, default: () => ({}) },

    internalNotes: { type: String },
    reviewNote: { type: String },
    rejectionReason: { type: String },
    reviewedBy: { type: Schema.Types.ObjectId, ref: 'User' },
    reviewedAt: { type: Date },

    // Lifecycle timestamps
    publishedAt: { type: Date },
    soldAt: { type: Date },
    rentedAt: { type: Date },
    archivedAt: { type: Date },
    blockedAt: { type: Date },
    blockedBy: { type: Schema.Types.ObjectId, ref: 'User' },
    blockReason: { type: String },
    deletedAt: { type: Date },
    deletedBy: { type: Schema.Types.ObjectId, ref: 'User' },
  },
  { timestamps: true, suppressReservedKeysWarning: true },
);

/* ── Compound + text indexes ──────────────────────────────── */
propertySchema.index({ status: 1, publishedAt: -1 });
propertySchema.index({ provinceId: 1, communeId: 1, status: 1 });
propertySchema.index({ propertyType: 1, listingType: 1 });
propertySchema.index({ 'price.amount': 1, 'price.currency': 1 });
propertySchema.index({ 'badges.featured': 1, status: 1, publishedAt: -1 });
propertySchema.index(
  { title: 'text', description: 'text', titleFr: 'text', titleEn: 'text', titleSw: 'text' },
  { name: 'property_text_search' },
);

export const Property = model('Property', propertySchema);
export default Property;
