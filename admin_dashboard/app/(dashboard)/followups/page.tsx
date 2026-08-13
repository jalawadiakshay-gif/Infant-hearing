"use client";
import { useEffect, useState } from "react";
import { AlertTriangle, CalendarCheck, Clock } from "lucide-react";
import { cn, formatDate, formatRelativeDate } from "@/lib/utils";
import type { Followup } from "@/lib/types";

export default function FollowupsPage() {
  const [followups, setFollowups] = useState<Followup[]>([]);
  const [loading, setLoading] = useState(true);
  const [showOverdue, setShowOverdue] = useState(false);

  useEffect(() => {
    (async () => {
      setLoading(true);
      const res = await fetch("/api/followups");
      const data = await res.json();
      setFollowups(data.followups ?? []);
      setLoading(false);
    })();
  }, []);

  const now = new Date();
  const allFollowups = followups;
  const overdueCount = followups.filter((f) => !f.completed && f.visitDate && new Date(f.visitDate) < now).length;
  const upcomingCount = followups.filter((f) => !f.completed && f.visitDate && new Date(f.visitDate) >= now).length;
  const completedCount = followups.filter((f) => f.completed).length;

  const displayed = showOverdue
    ? allFollowups.filter((f) => !f.completed && f.visitDate && new Date(f.visitDate) < now)
    : allFollowups;

  return (
    <div className="p-6 space-y-5">
      <div>
        <h1 className="text-xl font-bold text-slate-900 dark:text-slate-100">Follow-up Visits</h1>
        <p className="text-sm text-slate-500 dark:text-slate-400 font-medium">{followups.length} total follow-ups</p>
      </div>

      {/* Summary cards */}
      <div className="grid grid-cols-3 gap-4">
        <div className="bg-white dark:bg-slate-900 rounded-2xl p-5 card-hover border border-rose-200 shadow-sm">
          <div className="flex items-center gap-3 mb-3">
            <div className="w-10 h-10 rounded-xl bg-rose-50 flex items-center justify-center">
              <AlertTriangle className="w-5 h-5 text-rose-600" />
            </div>
            <div>
              <p className="text-2xl font-bold text-slate-900 dark:text-slate-100">{overdueCount}</p>
              <p className="text-xs font-semibold text-rose-600">Overdue</p>
            </div>
          </div>
          <p className="text-[11px] text-slate-500 dark:text-slate-400 font-medium">Missed scheduled visits requiring immediate attention</p>
        </div>
        <div className="bg-white dark:bg-slate-900 rounded-2xl p-5 card-hover border border-slate-200 dark:border-slate-800 shadow-sm">
          <div className="flex items-center gap-3 mb-3">
            <div className="w-10 h-10 rounded-xl bg-sky-50 dark:bg-sky-500/10 flex items-center justify-center">
              <Clock className="w-5 h-5 text-sky-600" />
            </div>
            <div>
              <p className="text-2xl font-bold text-slate-900 dark:text-slate-100">{upcomingCount}</p>
              <p className="text-xs font-semibold text-sky-600">Upcoming</p>
            </div>
          </div>
          <p className="text-[11px] text-slate-500 dark:text-slate-400 font-medium">Scheduled visits in the future</p>
        </div>
        <div className="bg-white dark:bg-slate-900 rounded-2xl p-5 card-hover border border-slate-200 dark:border-slate-800 shadow-sm">
          <div className="flex items-center gap-3 mb-3">
            <div className="w-10 h-10 rounded-xl bg-emerald-50 flex items-center justify-center">
              <CalendarCheck className="w-5 h-5 text-emerald-600" />
            </div>
            <div>
              <p className="text-2xl font-bold text-slate-900 dark:text-slate-100">{completedCount}</p>
              <p className="text-xs font-semibold text-emerald-600">Completed</p>
            </div>
          </div>
          <p className="text-[11px] text-slate-500 dark:text-slate-400 font-medium">Successfully completed follow-up visits</p>
        </div>
      </div>

      {/* Filter toggle */}
      <div className="flex items-center gap-3 bg-white dark:bg-slate-900 p-1 rounded-xl w-fit border border-slate-200 dark:border-slate-800 shadow-sm">
        <button onClick={() => setShowOverdue(false)}
          className={cn("px-4 py-2 rounded-lg text-sm font-bold transition-all", !showOverdue ? "bg-sky-50 dark:bg-sky-500/10 text-sky-700 dark:text-sky-400 border border-sky-200 dark:border-sky-500/30 shadow-sm" : "bg-transparent text-slate-500 dark:text-slate-400 hover:text-slate-700 dark:text-slate-200")}>
          All Follow-ups
        </button>
        <button onClick={() => setShowOverdue(true)}
          className={cn("px-4 py-2 rounded-lg text-sm font-bold transition-all flex items-center gap-2", showOverdue ? "bg-rose-50 text-rose-700 border border-rose-200 shadow-sm" : "bg-transparent text-slate-500 dark:text-slate-400 hover:text-slate-700 dark:text-slate-200")}>
          {overdueCount > 0 && <span className="w-4 h-4 rounded-full bg-rose-500 text-[9px] font-bold text-white flex items-center justify-center">{overdueCount}</span>}
          Overdue Only
        </button>
      </div>

      {/* Table */}
      <div className="bg-white dark:bg-slate-900 rounded-2xl overflow-hidden border border-slate-200 dark:border-slate-800 shadow-sm">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-slate-100 dark:border-slate-800 bg-slate-50/50 dark:bg-slate-800/50">
                {["Visit Date", "Child ID", "ASHA ID", "Status", "Completed At", "Notes"].map((h) => (
                  <th key={h} className="px-5 py-3 text-left text-[11px] font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {loading ? (
                Array.from({ length: 6 }).map((_, i) => (
                  <tr key={i} className="border-b border-slate-50">
                    {Array.from({ length: 6 }).map((__, j) => <td key={j} className="px-5 py-3"><div className="h-4 rounded-lg animate-pulse bg-slate-100 w-4/5" /></td>)}
                  </tr>
                ))
              ) : displayed.length === 0 ? (
                <tr><td colSpan={6} className="px-5 py-8 text-center text-slate-500 dark:text-slate-400 font-medium">No follow-ups {showOverdue ? "overdue" : ""}</td></tr>
              ) : displayed.map((f) => {
                const isOverdue = !f.completed && f.visitDate && new Date(f.visitDate) < now;
                return (
                  <tr key={f.followupId} className={cn("border-b border-slate-100 dark:border-slate-800 hover:bg-slate-50 dark:hover:bg-slate-800 dark:bg-slate-800 transition-colors", isOverdue && "bg-rose-50/30")}>
                    <td className="px-5 py-3">
                      <div className="flex items-center gap-2">
                        {isOverdue && <span className="w-1.5 h-1.5 rounded-full bg-rose-500 flex-shrink-0" />}
                        <span className={cn("text-xs font-bold", isOverdue ? "text-rose-600" : "text-slate-600 dark:text-slate-300")}>{f.visitDate ? formatDate(f.visitDate) : "—"}</span>
                      </div>
                      {isOverdue && <p className="text-[10px] text-rose-500 mt-0.5 font-medium">Overdue · {formatRelativeDate(f.visitDate)}</p>}
                    </td>
                    <td className="px-5 py-3 text-slate-500 dark:text-slate-400 text-xs font-mono font-medium">{f.childId.slice(0, 8)}…</td>
                    <td className="px-5 py-3 text-slate-500 dark:text-slate-400 text-xs font-mono font-medium">{f.ashaId.slice(0, 8)}…</td>
                    <td className="px-5 py-3">
                      {f.completed
                        ? <span className="badge bg-emerald-50 text-emerald-700 border-emerald-200 text-[10px]">Completed</span>
                        : isOverdue
                          ? <span className="badge bg-rose-50 text-rose-700 border-rose-200 text-[10px]">Overdue</span>
                          : <span className="badge bg-sky-50 dark:bg-sky-500/10 text-sky-700 dark:text-sky-400 border-sky-200 dark:border-sky-500/30 text-[10px]">Pending</span>
                      }
                    </td>
                    <td className="px-5 py-3 text-slate-500 dark:text-slate-400 text-xs font-medium">{f.completedAt ? formatRelativeDate(f.completedAt) : "—"}</td>
                    <td className="px-5 py-3 text-slate-600 dark:text-slate-300 text-xs max-w-[200px] truncate font-medium">{f.notes ?? "—"}</td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
