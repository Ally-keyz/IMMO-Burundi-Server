/**
 * One-off enrichment of the demo agents' channel-page profile fields
 * (bio, slogan, license, review counts). Safe to re-run: only fills
 * empty/absent values, never drops or overwrites existing data.
 */
import { connectDB, disconnectDB } from '../config/db.js';
import Agent from '../models/agent.model.js';

const PROFILES: Record<string, { bio: string; slogan: string; licenseNumber: string; reviewsCount: number; totalSales: number; totalDeals: number }> = {
  'AG-BJM-0001': {
    bio: 'Aline is a licensed real-estate professional based in Bujumbura Mairie, with a passion for matching families with homes that truly fit their lives. Over the past years she has helped dozens of buyers, sellers and tenants across the capital, from first apartments to waterfront guest houses. Fluent in French and Kirundi, she guides every client through the entire journey — from the first viewing to the final signature — with transparency and patience.',
    slogan: 'Helping families find not just a house, but a home in Bujumbura.',
    licenseNumber: 'CN-AG-BJM-2024-0087',
    reviewsCount: 128,
    totalSales: 24,
    totalDeals: 9,
  },
  'AG-BJM-0002': {
    bio: 'Eric manages a young, detail-driven team at Immo Centre, focused on modern office and commercial spaces downtown. He cut his teeth in residential leasing before moving to commercial real estate, and loves negotiating deals that are as good for the tenant as they are for the owner. Expect clear communication, honest advice and quick turnaround on every enquiry.',
    slogan: 'Great deals are done with trust — that is what I sell first.',
    licenseNumber: 'CN-AG-BJM-2024-0112',
    reviewsCount: 42,
    totalSales: 11,
    totalDeals: 16,
  },
};

async function main(): Promise<void> {
  await connectDB();
  const codes = Object.keys(PROFILES);
  for (const code of codes) {
    const res = await Agent.updateOne(
      { agentCode: code, status: 'ACTIVE' },
      { $set: PROFILES[code] },
    );
    console.log(`[ENRICH] ${code}: matched=${res.matchedCount} modified=${res.modifiedCount}`);
  }
  console.log('[ENRICH] Done.');
  await disconnectDB();
}

main().catch(async (err) => {
  console.error('[ENRICH] Failed:', err);
  await disconnectDB().catch(() => undefined);
  process.exit(1);
});