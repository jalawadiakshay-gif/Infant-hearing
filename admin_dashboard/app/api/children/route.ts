export const dynamic = "force-dynamic";

import { NextResponse } from "next/server";
import { db } from "@/lib/firebase-admin";

export async function GET(req: Request) {
  const { searchParams } = new URL(req.url);
  const limit = parseInt(searchParams.get("limit") ?? "100");
  const status = searchParams.get("status");
  const ashaId = searchParams.get("ashaId");

  try {
    let query: FirebaseFirestore.Query = db.collection("children").orderBy("createdAt", "desc").limit(limit);
    if (ashaId) query = query.where("createdBy", "==", ashaId);
    if (status) query = query.where("status", "==", status);

    const snap = await query.get();
    const children = snap.docs.map((doc) => ({ childId: doc.id, ...doc.data(), createdAt: doc.data().createdAt?.toDate?.()?.toISOString() ?? null, dob: doc.data().dob?.toDate?.()?.toISOString() ?? null }));
    return NextResponse.json({ children, total: children.length });
  } catch (err) {
    return NextResponse.json({ error: String(err) }, { status: 500 });
  }
}

