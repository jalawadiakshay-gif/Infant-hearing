import { neon } from "@neondatabase/serverless";

const sql = neon(process.env.DATABASE_URL!);
export default sql;

// ── Initialize Neon tables (run once on first deploy) ──────────────────────
export async function initNeonTables() {
  await sql`
    CREATE TABLE IF NOT EXISTS district_daily_stats (
      id SERIAL PRIMARY KEY,
      district TEXT NOT NULL,
      stat_date DATE NOT NULL,
      total_children INT DEFAULT 0,
      total_screenings INT DEFAULT 0,
      boa_screenings INT DEFAULT 0,
      q_screenings INT DEFAULT 0,
      pass_count INT DEFAULT 0,
      refer_count INT DEFAULT 0,
      monitor_count INT DEFAULT 0,
      active_ashas INT DEFAULT 0,
      pending_referrals INT DEFAULT 0,
      overdue_followups INT DEFAULT 0,
      synced_at TIMESTAMP DEFAULT NOW(),
      UNIQUE(district, stat_date)
    )
  `;

  await sql`
    CREATE TABLE IF NOT EXISTS monthly_trends (
      id SERIAL PRIMARY KEY,
      year INT NOT NULL,
      month INT NOT NULL,
      district TEXT DEFAULT 'all',
      screening_type TEXT DEFAULT 'total',
      count INT DEFAULT 0,
      UNIQUE(year, month, district, screening_type)
    )
  `;

  await sql`
    CREATE TABLE IF NOT EXISTS asha_performance (
      id SERIAL PRIMARY KEY,
      asha_id TEXT NOT NULL,
      asha_name TEXT,
      district TEXT,
      snap_month DATE NOT NULL,
      screenings_done INT DEFAULT 0,
      referrals_made INT DEFAULT 0,
      followups_completed INT DEFAULT 0,
      UNIQUE(asha_id, snap_month)
    )
  `;

  await sql`
    CREATE TABLE IF NOT EXISTS sync_log (
      id SERIAL PRIMARY KEY,
      synced_at TIMESTAMP DEFAULT NOW(),
      records_processed INT,
      status TEXT
    )
  `;
}
