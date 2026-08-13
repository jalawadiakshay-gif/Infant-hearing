import { initializeApp, getApps, cert, App } from "firebase-admin/app";
import { getFirestore, Firestore } from "firebase-admin/firestore";
import { getAuth, Auth } from "firebase-admin/auth";

// ── Lazy initialization — only runs when first called, not at import time ──
function getAdminApp(): App {
  if (getApps().length > 0) return getApps()[0]!;

  return initializeApp({
    credential: cert({
      projectId: process.env.FIREBASE_PROJECT_ID ?? "",
      clientEmail: process.env.FIREBASE_CLIENT_EMAIL ?? "",
      privateKey: (process.env.FIREBASE_PRIVATE_KEY ?? "").replace(/\\n/g, "\n"),
    }),
    storageBucket: `${process.env.FIREBASE_PROJECT_ID ?? ""}.firebasestorage.app`,
  });
}

export function getDb(): Firestore {
  return getFirestore(getAdminApp());
}

export function getAdminAuth(): Auth {
  return getAuth(getAdminApp());
}

// Convenience re-export for API routes
export const db = new Proxy({} as Firestore, {
  get(_target, prop) {
    const firestoreInstance = getDb();
    const value = (firestoreInstance as unknown as Record<string | symbol, unknown>)[prop];
    if (typeof value === "function") return value.bind(firestoreInstance);
    return value;
  },
});
