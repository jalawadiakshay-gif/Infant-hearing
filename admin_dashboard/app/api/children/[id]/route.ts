export const dynamic = "force-dynamic";

import { NextResponse } from "next/server";
import { db } from "@/lib/firebase-admin";

// GET /api/children/[id] — fetch one child + all their screenings
export async function GET(
  _req: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id: childId } = await params;
    
    if (!childId) {
      return NextResponse.json({ error: "Missing child ID" }, { status: 400 });
    }

    // Fetch child document
    const childDoc = await db.collection("children").doc(childId).get();
    if (!childDoc.exists) {
      return NextResponse.json({ error: "Child not found" }, { status: 404 });
    }
    const childData = childDoc.data()!;
    const child = {
      childId: childDoc.id,
      ...childData,
      dob: childData.dob?.toDate?.()?.toISOString() ?? null,
      createdAt: childData.createdAt?.toDate?.()?.toISOString() ?? null,
      "followup.date": undefined,
      followup: childData.followup
        ? {
            ...childData.followup,
            date: childData.followup.date?.toDate?.()?.toISOString() ?? null,
          }
        : null,
    };

    // Fetch all screenings for this child
    const screeningSnap = await db
      .collection("screenings")
      .where("childId", "==", childId)
      .limit(50)
      .get();

    const screenings = screeningSnap.docs.map((doc) => {
      const d = doc.data();
      return {
        screeningId: doc.id,
        ...d,
        date: d.date?.toDate?.()?.toISOString() ?? null,
        createdAt: d.createdAt?.toDate?.()?.toISOString() ?? null,
      };
    });

    // Sort in-memory to avoid Firestore composite index requirement
    screenings.sort((a, b) => {
      const dateA = a.date ? new Date(a.date).getTime() : 0;
      const dateB = b.date ? new Date(b.date).getTime() : 0;
      return dateB - dateA; // Descending
    });

    return NextResponse.json({ child, screenings });
  } catch (err) {
    return NextResponse.json({ error: String(err) }, { status: 500 });
  }
}
