import { NextResponse } from "next/server";
import { db } from "@/lib/firebase-admin";
import sql, { initNeonTables } from "@/lib/neon";

export const dynamic = "force-dynamic";

export async function GET() {
  try {
    // ── Fetch all needed collections in parallel ──────────────────────────
    const [childrenSnap, screeningsSnap, referralsSnap, followupsSnap, usersSnap] =
      await Promise.all([
        db.collection("children").get(),
        db.collection("screenings").get(),
        db.collection("referrals").get(),
        db.collection("followups").get(),
        db.collection("users").where("role", "==", "asha").get(),
      ]);

    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

    // ── KPI aggregation ───────────────────────────────────────────────────
    const totalChildren = childrenSnap.size;
    const activeAshas = usersSnap.size;

    let screeningsThisMonth = 0, passCount = 0, referCount = 0, monitorCount = 0;
    let boaScreenings = 0, qScreenings = 0;

    screeningsSnap.forEach((doc) => {
      const data = doc.data();
      const date = data.date?.toDate?.() ?? new Date(data.date ?? 0);
      if (date >= startOfMonth) screeningsThisMonth++;
      if (data.result === "pass") passCount++;
      if (data.result === "refer") referCount++;
      if (data.result === "monitor") monitorCount++;
      if (data.type === "boa") boaScreenings++;
      if (data.type === "q") qScreenings++;
    });

    let pendingReferrals = 0;
    referralsSnap.forEach((doc) => {
      if (doc.data().status === "pending") pendingReferrals++;
    });

    let overdueFollowups = 0;
    followupsSnap.forEach((doc) => {
      const data = doc.data();
      const visitDate = data.visitDate?.toDate?.() ?? new Date(data.visitDate ?? 0);
      if (!data.completed && visitDate < now) overdueFollowups++;
    });

    const stats = {
      totalChildren,
      screeningsThisMonth,
      passCount,
      referCount,
      monitorCount,
      activeAshas,
      pendingReferrals,
      overdueFollowups,
      boaScreenings,
      qScreenings,
    };

    // ── Monthly trend (last 6 months) ─────────────────────────────────────
    const monthlyMap: Record<string, { boa: number; q: number; total: number }> = {};
    screeningsSnap.forEach((doc) => {
      const data = doc.data();
      const date = data.date?.toDate?.() ?? new Date(data.date ?? 0);
      const key = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, "0")}`;
      if (!monthlyMap[key]) monthlyMap[key] = { boa: 0, q: 0, total: 0 };
      monthlyMap[key].total++;
      if (data.type === "boa") monthlyMap[key].boa++;
      if (data.type === "q") monthlyMap[key].q++;
    });

    const monthLabels = Array.from({ length: 6 }, (_, i) => {
      const d = new Date(now.getFullYear(), now.getMonth() - (5 - i), 1);
      return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}`;
    });

    const trends = monthLabels.map((key) => {
      const [yr, mo] = key.split("-");
      const label = new Date(Number(yr), Number(mo) - 1, 1).toLocaleString("en-IN", { month: "short", year: "2-digit" });
      return { month: label, ...(monthlyMap[key] ?? { boa: 0, q: 0, total: 0 }) };
    });

    // ── District breakdown ────────────────────────────────────────────────
    const districtMap: Record<string, { children: number; screenings: number; pass: number; refer: number; ashas: Set<string> }> = {};

    childrenSnap.forEach((doc) => {
      const d = doc.data();
      const dist = d.village ?? "Unknown";
      if (!districtMap[dist]) districtMap[dist] = { children: 0, screenings: 0, pass: 0, refer: 0, ashas: new Set() };
      districtMap[dist].children++;
    });

    screeningsSnap.forEach((doc) => {
      const d = doc.data();
      const dist = d.district ?? "Unknown";
      if (!districtMap[dist]) districtMap[dist] = { children: 0, screenings: 0, pass: 0, refer: 0, ashas: new Set() };
      districtMap[dist].screenings++;
      if (d.result === "pass") districtMap[dist].pass++;
      if (d.result === "refer") districtMap[dist].refer++;
    });

    usersSnap.forEach((doc) => {
      const d = doc.data();
      const dist = d.district ?? "Unknown";
      if (!districtMap[dist]) districtMap[dist] = { children: 0, screenings: 0, pass: 0, refer: 0, ashas: new Set() };
      districtMap[dist].ashas.add(doc.id);
    });

    const districts = Object.entries(districtMap).map(([district, data]) => ({
      district,
      children: data.children,
      screenings: data.screenings,
      passRate: data.screenings > 0 ? Math.round((data.pass / data.screenings) * 100) : 0,
      referRate: data.screenings > 0 ? Math.round((data.refer / data.screenings) * 100) : 0,
      activeAshas: data.ashas.size,
      pendingReferrals: 0,
    }));

    // ── Sync summary to Neon ──────────────────────────────────────────────
    try {
      await initNeonTables();
      const today = now.toISOString().split("T")[0];
      await sql`
        INSERT INTO district_daily_stats (district, stat_date, total_children, total_screenings,
          boa_screenings, q_screenings, pass_count, refer_count, monitor_count, active_ashas,
          pending_referrals, overdue_followups)
        VALUES ('all', ${today}, ${totalChildren}, ${screeningsThisMonth},
          ${boaScreenings}, ${qScreenings}, ${passCount}, ${referCount}, ${monitorCount},
          ${activeAshas}, ${pendingReferrals}, ${overdueFollowups})
        ON CONFLICT (district, stat_date) DO UPDATE SET
          total_children = EXCLUDED.total_children,
          total_screenings = EXCLUDED.total_screenings,
          boa_screenings = EXCLUDED.boa_screenings,
          q_screenings = EXCLUDED.q_screenings,
          pass_count = EXCLUDED.pass_count,
          refer_count = EXCLUDED.refer_count,
          monitor_count = EXCLUDED.monitor_count,
          active_ashas = EXCLUDED.active_ashas,
          pending_referrals = EXCLUDED.pending_referrals,
          overdue_followups = EXCLUDED.overdue_followups,
          synced_at = NOW()
      `;
    } catch (neonErr) {
      console.warn("Neon sync skipped (env not configured?):", neonErr);
    }

    return NextResponse.json({ stats, trends, districts });
  } catch (err) {
    console.error("/api/stats error:", err);
    return NextResponse.json({ error: "Failed to fetch stats" }, { status: 500 });
  }
}
