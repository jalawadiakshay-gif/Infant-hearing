export const dynamic = "force-dynamic";

import { NextResponse } from "next/server";
import { db } from "@/lib/firebase-admin";

export async function GET(req: Request) {
  const { searchParams } = new URL(req.url);
  const limit = parseInt(searchParams.get("limit") ?? "100");
  const type = searchParams.get("type");
  const result = searchParams.get("result");

  try {
    let query: FirebaseFirestore.Query = db.collection("screenings").orderBy("date", "desc").limit(limit);
    if (type) query = query.where("type", "==", type);
    if (result) query = query.where("result", "==", result);

    const snap = await query.get();
    const screenings = snap.docs.map((doc) => {
      const d = doc.data();
      return {
        screeningId: doc.id,
        ...d,
        date: d.date?.toDate?.()?.toISOString() ?? null,
        createdAt: d.createdAt?.toDate?.()?.toISOString() ?? null,
      };
    });
    return NextResponse.json({ screenings, total: screenings.length });
  } catch (err) {
    return NextResponse.json({ error: String(err) }, { status: 500 });
  }
}

