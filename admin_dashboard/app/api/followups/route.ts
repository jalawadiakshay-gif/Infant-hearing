export const dynamic = "force-dynamic";

import { NextResponse } from "next/server";
import { db } from "@/lib/firebase-admin";

export async function GET(req: Request) {
  const { searchParams } = new URL(req.url);
  const overdue = searchParams.get("overdue") === "true";

  try {
    let query: FirebaseFirestore.Query = db.collection("followups").orderBy("visitDate", "asc");
    if (overdue) query = query.where("completed", "==", false);

    const snap = await query.get();
    const now = new Date();
    const followups = snap.docs.map((doc) => {
      const d = doc.data();
      const visitDate = d.visitDate?.toDate?.() ?? null;
      return {
        followupId: doc.id,
        ...d,
        visitDate: visitDate?.toISOString() ?? null,
        completed: d.completed as boolean ?? false,
        completedAt: (d.completedAt as { toDate?: () => Date } | undefined)?.toDate?.()?.toISOString() ?? null,
        createdAt: (d.createdAt as { toDate?: () => Date } | undefined)?.toDate?.()?.toISOString() ?? null,
        isOverdue: !d.completed && visitDate ? visitDate < now : false,
      };
    }).filter((f) => overdue ? !f.completed : true);

    return NextResponse.json({ followups, total: followups.length });
  } catch (err) {
    return NextResponse.json({ error: String(err) }, { status: 500 });
  }
}

