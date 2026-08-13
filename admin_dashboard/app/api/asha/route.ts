export const dynamic = "force-dynamic";

import { NextResponse } from "next/server";
import { db } from "@/lib/firebase-admin";
import type { QueryDocumentSnapshot, Timestamp } from "firebase-admin/firestore";

interface WorkerRow {
  uid: string;
  name: string;
  phone: string;
  district: string;
  village: string;
  createdAt: string | null;
  screeningsDone: number;
  referralsMade: number;
  followupsDone: number;
  lastActivity: string | null;
}

export async function GET() {
  try {
    const [usersSnap, screeningsSnap, referralsSnap, followupsSnap] = await Promise.all([
      db.collection("users").where("role", "==", "asha").get(),
      db.collection("screenings").get(),
      db.collection("referrals").get(),
      db.collection("followups").where("completed", "==", true).get(),
    ]);

    const ashaMap: Record<string, { screenings: number; referrals: number; followups: number; lastActivity?: string }> = {};
    usersSnap.forEach((doc: QueryDocumentSnapshot) => { ashaMap[doc.id] = { screenings: 0, referrals: 0, followups: 0 }; });

    screeningsSnap.forEach((doc: QueryDocumentSnapshot) => {
      const uid = doc.data().conductedBy as string | undefined;
      if (uid && ashaMap[uid]) {
        ashaMap[uid].screenings++;
        const date = (doc.data().date as Timestamp | undefined)?.toDate?.()?.toISOString();
        if (date && (!ashaMap[uid].lastActivity || date > ashaMap[uid].lastActivity!)) {
          ashaMap[uid].lastActivity = date;
        }
      }
    });

    referralsSnap.forEach((doc: QueryDocumentSnapshot) => {
      const uid = doc.data().ashaId as string | undefined;
      if (uid && ashaMap[uid]) ashaMap[uid].referrals++;
    });

    followupsSnap.forEach((doc: QueryDocumentSnapshot) => {
      const uid = doc.data().ashaId as string | undefined;
      if (uid && ashaMap[uid]) ashaMap[uid].followups++;
    });

    const workers: WorkerRow[] = usersSnap.docs.map((doc: QueryDocumentSnapshot) => {
      const d = doc.data();
      const perf = ashaMap[doc.id] ?? { screenings: 0, referrals: 0, followups: 0 };
      return {
        uid: doc.id,
        name: (d.name as string) ?? "",
        phone: (d.phone as string) ?? "",
        district: (d.district as string) ?? "",
        village: (d.village as string) ?? "",
        createdAt: (d.createdAt as Timestamp | undefined)?.toDate?.()?.toISOString() ?? null,
        screeningsDone: perf.screenings,
        referralsMade: perf.referrals,
        followupsDone: perf.followups,
        lastActivity: perf.lastActivity ?? null,
      };
    }).sort((a: WorkerRow, b: WorkerRow) => b.screeningsDone - a.screeningsDone);

    return NextResponse.json({ workers, total: workers.length });
  } catch (err) {
    return NextResponse.json({ error: String(err) }, { status: 500 });
  }
}

