/**
 * Verification requirements — derived per property so an agent can see exactly
 * what is still missing before the system admin will accept a listing.
 *
 * This is a *pre-flight* checklist: it never grants verification. Only a
 * MAIN_ADMIN / verification officer decides the outcome (Backend Spec §14, §28,
 * rule 8 — agents cannot verify their own properties).
 */
import { DOCUMENT_TYPES } from '@immo/shared-types';
import type { VerificationRequirementDTO } from '@immo/shared-types';

/** Documents every listing must carry, whatever the listing type. */
const ALWAYS_REQUIRED = ['LAND_TITLE', 'OWNER_ID'] as const;

/** A sale additionally needs the signed agreement between seller and buyer. */
const SALE_ONLY = ['SALE_AGREEMENT'] as const;

export function requiredDocumentTypes(listingType?: string): string[] {
  const types: string[] = [...ALWAYS_REQUIRED];
  if (listingType === 'SALE') types.push(...SALE_ONLY);
  /* Guard against a listingType outside the enum silently losing its checklist. */
  return types.filter((t) => (DOCUMENT_TYPES as readonly string[]).includes(t));
}

function firstDoc(documents: any[], type: string): any | undefined {
  return Array.isArray(documents) ? documents.find((d) => d?.documentType === type) : undefined;
}

/** A document counts as met once it is attached — even before it is verified. */
function documentRequirement(type: string, documents: any[]): VerificationRequirementDTO {
  const doc = firstDoc(documents, type);
  if (!doc) return { key: `document:${type}`, kind: 'DOCUMENT', status: 'MISSING' };
  return {
    key: `document:${type}`,
    kind: 'DOCUMENT',
    status: 'MET',
    note: doc.verificationStatus && doc.verificationStatus !== 'VERIFIED' ? doc.verificationStatus : undefined,
    fileName: doc.fileName ?? doc.fileKey ?? undefined,
  };
}

function fieldRequirement(key: string, label: string, present: boolean): VerificationRequirementDTO {
  return { key: `field:${key}`, kind: 'FIELD', label, status: present ? 'MET' : 'MISSING' };
}

/**
 * Builds the full checklist for one property. `label` is a human-readable hint
 * carried alongside the machine `key` so the UI can translate the key and still
 * fall back to something meaningful.
 */
export function buildRequirements(property: any): VerificationRequirementDTO[] {
  const p = property ?? {};
  const documents = Array.isArray(p.documents) ? p.documents : [];
  const media = Array.isArray(p.media) ? p.media : [];
  /* Stored flat on the document; only the DTO nests it under `features`. */
  const surfaceArea = Number(p.surfaceArea ?? p.features?.surfaceArea ?? 0);

  const requirements: VerificationRequirementDTO[] = requiredDocumentTypes(p.listingType).map((type) =>
    documentRequirement(type, documents),
  );

  requirements.push(
    fieldRequirement('title', 'Title', Boolean(String(p.title ?? '').trim())),
    fieldRequirement('description', 'Description', Boolean(String(p.description ?? '').trim())),
    fieldRequirement('price', 'Price', Number(p.price?.amount) > 0),
    fieldRequirement('surfaceArea', 'Surface area', surfaceArea > 0),
    fieldRequirement('location', 'Province and commune', Boolean(p.provinceId && p.communeId)),
    fieldRequirement('media', 'At least one photo', media.length > 0),
  );

  return requirements;
}

/** Only the unmet items — the actionable "what to update" list. */
export function missingRequirements(requirements: VerificationRequirementDTO[]): VerificationRequirementDTO[] {
  return requirements.filter((r) => r.status === 'MISSING');
}
