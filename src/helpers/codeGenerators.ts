import { Counter } from '../models/counter.model.js';

/** Atomically increment and return the next value for a logical counter. */
async function nextSequence(key: string): Promise<number> {
  const doc = await Counter.findOneAndUpdate(
    { key },
    { $inc: { seq: 1 } },
    { upsert: true, new: true, setDefaultsOnInsert: true },
  ).lean();
  return doc?.seq ?? 1;
}

function pad(value: number, length: number): string {
  return String(value).padStart(length, '0');
}

function currentYear(): string {
  return String(new Date().getFullYear());
}

/** BDI-[PROVINCE]-[COMMUNE]-[YEAR]-[SEQUENCE] (sequence padded to 4). */
export async function generatePropertyId(provinceCode: string, communeCode: string): Promise<string> {
  const year = currentYear();
  const province = (provinceCode || 'XXX').toUpperCase();
  const commune = (communeCode || 'XXX').toUpperCase();
  const seq = await nextSequence(`PROPERTY:${province}:${commune}:${year}`);
  return `BDI-${province}-${commune}-${year}-${pad(seq, 4)}`;
}

/** VER-BDI-YEAR-SEQUENCE (6 digits). */
export async function generateVerificationCode(): Promise<string> {
  const year = currentYear();
  const seq = await nextSequence(`VERIFICATION:${year}`);
  return `VER-BDI-${year}-${pad(seq, 6)}`;
}

/** PRO-BDI-YEAR-SEQUENCE (6 digits). */
export async function generatePromotionCode(): Promise<string> {
  const year = currentYear();
  const seq = await nextSequence(`PROMOTION:${year}`);
  return `PRO-BDI-${year}-${pad(seq, 6)}`;
}

/** COMS-BDI-YEAR-SEQUENCE (6 digits). */
export async function generateSalesCommissionCode(): Promise<string> {
  const year = currentYear();
  const seq = await nextSequence(`SALES_COMMISSION:${year}`);
  return `COMS-BDI-${year}-${pad(seq, 6)}`;
}

/** COMR-BDI-YEAR-SEQUENCE (6 digits). */
export async function generateRentalCommissionCode(): Promise<string> {
  const year = currentYear();
  const seq = await nextSequence(`RENTAL_COMMISSION:${year}`);
  return `COMR-BDI-${year}-${pad(seq, 6)}`;
}

/** VIS-BDI-YEAR-SEQUENCE (6 digits). */
export async function generateVisitBookingRef(): Promise<string> {
  const year = currentYear();
  const seq = await nextSequence(`VISIT_BOOKING:${year}`);
  return `VIS-BDI-${year}-${pad(seq, 6)}`;
}

/** TXN-BDI-YEAR-SEQUENCE (6 digits). */
export async function generateTransactionCode(): Promise<string> {
  const year = currentYear();
  const seq = await nextSequence(`TRANSACTION:${year}`);
  return `TXN-BDI-${year}-${pad(seq, 6)}`;
}

/** CTR-BDI-YEAR-SEQUENCE (6 digits). */
export async function generateContractNumber(): Promise<string> {
  const year = currentYear();
  const seq = await nextSequence(`CONTRACT:${year}`);
  return `CTR-BDI-${year}-${pad(seq, 6)}`;
}

/** RA-BDI-YEAR-SEQUENCE (6 digits). */
export async function generateApplicationCode(): Promise<string> {
  const year = currentYear();
  const seq = await nextSequence(`RENTAL_APPLICATION:${year}`);
  return `RA-BDI-${year}-${pad(seq, 6)}`;
}

/** RFD-BDI-YEAR-SEQUENCE (6 digits). */
export async function generateRefundReference(): Promise<string> {
  const year = currentYear();
  const seq = await nextSequence(`REFUND:${year}`);
  return `RFD-BDI-${year}-${pad(seq, 6)}`;
}

/** ADJ-BDI-YEAR-SEQUENCE (6 digits). */
export async function generateAdjustmentReference(): Promise<string> {
  const year = currentYear();
  const seq = await nextSequence(`ADJUSTMENT:${year}`);
  return `ADJ-BDI-${year}-${pad(seq, 6)}`;
}

/** AG-PROVINCE-SEQUENCE (4 digits). */
export async function generateAgentCode(provinceCode: string): Promise<string> {
  const province = (provinceCode || 'XXX').toUpperCase();
  const seq = await nextSequence(`AGENT:${province}`);
  return `AG-${province}-${pad(seq, 4)}`;
}

/** STF-SEQUENCE (4 digits). */
export async function generateStaffCode(): Promise<string> {
  const seq = await nextSequence('STAFF');
  return `STF-${pad(seq, 4)}`;
}

/** PAY-[CATEGORY]-YEAR-SEQUENCE (6 digits). */
export async function generatePaymentReference(category: string): Promise<string> {
  const year = currentYear();
  const cat = (category || 'OTHER').toUpperCase();
  const seq = await nextSequence(`PAYMENT:${cat}:${year}`);
  return `PAY-${cat}-${year}-${pad(seq, 6)}`;
}
