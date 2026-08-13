"use client";
import { useEffect, useState } from "react";
import { AlertTriangle, CheckCircle, Clock, ChevronRight } from "lucide-react";
import { cn, getReferralStatusColor, formatDate, formatRelativeDate } from "@/lib/utils";
import type { Referral } from "@/lib/types";

const PIPELINE = ["pending", "scheduled", "visited", "tested", "resolved"] as const;
const PIPELINE_ICONS = [AlertTriangle, Clock, ChevronRight, ChevronRight, CheckCircle];

export default function ReferralsPage() {
  const [referrals, setReferrals] = useState<Referral[]>([]);
  const [loading, setLoading] = useState(true);
  const [activeStatus, setActiveStatus] = useState<string>("all");
  const [updating, setUpdating] = useState<string | null>(null);

  const fetchReferrals = async () => {
    setLoading(true);
    const res = await fetch("/api/referrals");
    const data = await res.json();
    setReferrals(data.referrals ?? []);
    setLoading(false);
  };

  useEffect(() => { fetchReferrals(); }, []);

  const updateStatus = async (referralId: string, newStatus: string) => {
    setUpdating(referralId);
    await fetch("/api/referrals", {
      method: "PATCH",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ referralId, status: newStatus }),
    });
    await fetchReferrals();
    setUpdating(null);
  };

  const filtered = activeStatus === "all" ? referrals : referrals.filter((r) => r.status === activeStatus);

  const countByStatus = (s: string) => referrals.filter((r) => r.status === s).length;

  return (
    <div className="p-6 space-y-5">
      <div>
        <h1 className="text-xl font-bold text-slate-900 dark:text-slate-100">Referral Tracking</h1>
        <p className="text-sm text-slate-500 dark:text-slate-400 font-medium">{referrals.length} total referrals</p>
      </div>

      {/* Pipeline summary */}
      <div className="grid grid-cols-5 gap-4">
        {PIPELINE.map((status, i) => {
          const Icon = PIPELINE_ICONS[i];
          const count = countByStatus(status);
          return (
            <button key={status} onClick={() => setActiveStatus(status === activeStatus ? "all" : status)}
              className={cn("bg-white dark:bg-slate-900 shadow-sm rounded-xl p-4 flex flex-col items-center gap-2 card-hover transition-all border", activeStatus === status ? "border-sky-400 ring-4 ring-sky-50" : "border-slate-200 dark:border-slate-800")}>
              <div className={cn("w-10 h-10 rounded-xl flex items-center justify-center", getReferralStatusColor(status))}>
                <Icon className="w-5 h-5" />
              </div>
              <p className="text-2xl font-bold text-slate-900 dark:text-slate-100">{count}</p>
              <p className="text-xs text-slate-500 dark:text-slate-400 capitalize font-semibold">{status}</p>
            </button>
          );
        })}
      </div>

      {/* Referrals table */}
      <div className="bg-white dark:bg-slate-900 shadow-sm rounded-2xl overflow-hidden border border-slate-200 dark:border-slate-800">
        <div className="px-6 py-4 border-b border-slate-100 dark:border-slate-800 flex items-center justify-between">
          <div>
            <h2 className="font-bold text-slate-900 dark:text-slate-100 text-sm">Referral Records</h2>
            <p className="text-[11px] text-slate-500 dark:text-slate-400">{filtered.length} shown</p>
          </div>
          <button onClick={() => setActiveStatus("all")}
            className={cn("text-xs font-semibold text-slate-500 dark:text-slate-400 hover:text-slate-900 dark:hover:text-slate-100 dark:text-slate-100 transition-colors", activeStatus === "all" && "text-sky-600")}>
            Show all
          </button>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-slate-100 dark:border-slate-800 bg-slate-50/50 dark:bg-slate-800/50">
                {["Date", "Reason", "Hospital", "Status", "ASHA ID", "Last Updated", "Action"].map((h) => (
                  <th key={h} className="px-5 py-3 text-left text-[11px] font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {loading ? (
                Array.from({ length: 6 }).map((_, i) => (
                  <tr key={i} className="border-b border-slate-50">
                    {Array.from({ length: 7 }).map((__, j) => <td key={j} className="px-5 py-3"><div className="h-4 rounded-lg animate-pulse bg-slate-100 w-4/5" /></td>)}
                  </tr>
                ))
              ) : filtered.length === 0 ? (
                <tr><td colSpan={7} className="px-5 py-8 text-center text-slate-500 dark:text-slate-400 font-medium">No referrals</td></tr>
              ) : filtered.map((r) => (
                <tr key={r.referralId} className="border-b border-slate-100 dark:border-slate-800 hover:bg-slate-50 dark:hover:bg-slate-800 dark:bg-slate-800 transition-colors">
                  <td className="px-5 py-3 text-slate-600 dark:text-slate-300 text-xs font-medium">{formatDate(r.date)}</td>
                  <td className="px-5 py-3 text-slate-700 dark:text-slate-200 max-w-[160px] truncate font-medium">{r.reason}</td>
                  <td className="px-5 py-3 text-slate-600 dark:text-slate-300 text-xs font-medium">{r.hospital}</td>
                  <td className="px-5 py-3">
                    <span className={cn("badge text-[10px] capitalize", getReferralStatusColor(r.status))}>{r.status}</span>
                  </td>
                  <td className="px-5 py-3 text-slate-500 dark:text-slate-400 text-xs font-mono font-medium">{r.ashaId.slice(0, 8)}…</td>
                  <td className="px-5 py-3 text-slate-500 dark:text-slate-400 text-xs font-medium">{formatRelativeDate(r.updatedAt)}</td>
                  <td className="px-5 py-3">
                    {r.status !== "resolved" && (
                      <select
                        value={r.status}
                        disabled={updating === r.referralId}
                        onChange={(e) => updateStatus(r.referralId, e.target.value)}
                        className="text-xs bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-800 rounded-lg px-2 py-1.5 text-slate-700 dark:text-slate-200 font-semibold focus:outline-none focus:border-sky-400 dark:focus:border-sky-500 focus:ring-2 focus:ring-sky-100 cursor-pointer shadow-sm"
                      >
                        {PIPELINE.map((s) => <option key={s} value={s} className="bg-white dark:bg-slate-900 text-slate-900 dark:text-slate-100">{s}</option>)}
                      </select>
                    )}
                    {r.status === "resolved" && <span className="text-emerald-600 text-xs font-bold">✓ Resolved</span>}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
