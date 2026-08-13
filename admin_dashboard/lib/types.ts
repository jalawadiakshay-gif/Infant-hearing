// ── Firestore data types (mirror of Flutter models) ─────────────────────────

export interface AppUser {
  uid: string;
  name: string;
  phone: string;
  role: "asha" | "parent" | "clinician" | "admin";
  lang: string;
  district?: string;
  village?: string;
  fcmToken?: string;
  email?: string;
  createdAt?: string;
}

export interface Child {
  childId: string;
  childCode?: string; // Human-readable ID: BSV-MH-YYMM-XXXX (e.g. BSV-MH-2608-4823)
  name: string;
  dob: string;
  gender: "M" | "F" | "O";
  parentName: string;
  parentPhone: string;
  village?: string;
  createdBy: string; // ASHA UID
  birthWeight?: number;
  gestationalAge?: number;
  birthType?: string;
  hospitalName?: string;
  pediatricianName?: string;
  hearingScreeningStatus?: string;
  risk?: { nicu: boolean; nicuDuration?: number };
  lastScreening?: { date: string; type: string; result: string };
  status?: "new" | "pass" | "refer" | "monitor";
  followup?: { date: string; notes?: string; done: boolean };
  createdAt?: string;
}

export interface BoaTrial {
  db: number;
  hz: number;
  r: string;
  c: boolean;
  ai: number;
  det: string;
  ms: number;
}

export interface Screening {
  screeningId: string;
  childId: string;
  conductedBy: string;
  type: "q" | "boa";
  result: "pass" | "refer" | "monitor" | "incomplete";
  date: string;
  offline: boolean;
  clipPath?: string;
  videoUrl?: string;
  pdfUrl?: string;
  createdAt?: string;
  q?: {
    answers?: Record<string, string>;
    score?: number;
    pct?: number;
    age?: number;
  };
  b?: {
    outcome?: string;
    noise?: number;
    trials?: BoaTrial[];
  };
}

export interface Referral {
  referralId: string;
  childId: string;
  ashaId: string;
  screeningId: string;
  reason: string;
  hospital: string;
  status: "pending" | "scheduled" | "visited" | "tested" | "resolved";
  date: string;
  notes?: string;
  updatedAt?: string;
  createdAt?: string;
}

export interface Followup {
  followupId: string;
  childId: string;
  ashaId: string;
  screeningId?: string;
  visitDate: string;
  completed: boolean;
  completedAt?: string;
  notes?: string;
  createdAt?: string;
}

// ── Dashboard aggregates ──────────────────────────────────────────────────────

export interface DashboardStats {
  totalChildren: number;
  screeningsThisMonth: number;
  passCount: number;
  referCount: number;
  monitorCount: number;
  activeAshas: number;
  pendingReferrals: number;
  overdueFollowups: number;
  boaScreenings: number;
  qScreenings: number;
}

export interface MonthlyTrend {
  month: string;
  boa: number;
  questionnaire: number;
  total: number;
}

export interface DistrictRow {
  district: string;
  children: number;
  screenings: number;
  passRate: number;
  referRate: number;
  activeAshas: number;
  pendingReferrals: number;
}

export interface AshaPerformance extends AppUser {
  screeningsDone: number;
  referralsMade: number;
  followupsDone: number;
  lastActivity?: string;
}
