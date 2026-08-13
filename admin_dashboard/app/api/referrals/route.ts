export const dynamic = "force-dynamic";

import { NextResponse } from "next/server";
import { db } from "@/lib/firebase-admin";

export async function GET(req: Request) {
  const { searchParams } = new URL(req.url);
  const status = searchParams.get("status");

  try {
    let query: FirebaseFirestore.Query = db.collection("referrals").orderBy("date", "desc");
    if (status) query = query.where("status", "==", status);

    const snap = await query.get();
    const referrals = snap.docs.map((doc) => {
      const d = doc.data();
      return {
        referralId: doc.id,
        ...d,
        date: d.date?.toDate?.()?.toISOString() ?? null,
        updatedAt: d.updatedAt?.toDate?.()?.toISOString() ?? null,
        createdAt: d.createdAt?.toDate?.()?.toISOString() ?? null,
      };
    });
    return NextResponse.json({ referrals, total: referrals.length });
  } catch (err) {
    return NextResponse.json({ error: String(err) }, { status: 500 });
  }
}

export async function PATCH(req: Request) {
  try {
    const { referralId, status, notes } = await req.json();
    if (!referralId || !status) return NextResponse.json({ error: "Missing fields" }, { status: 400 });

    await db.collection("referrals").doc(referralId).update({
      status,
      notes: notes ?? "",
      updatedAt: new Date(),
    });
    return NextResponse.json({ success: true });
  } catch (err) {
    return NextResponse.json({ error: String(err) }, { status: 500 });
  }
}

