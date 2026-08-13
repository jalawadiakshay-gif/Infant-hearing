"use client";
import { useEffect, useState } from "react";
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from "recharts";
import { Trophy, Search } from "lucide-react";
import { cn, formatDate, formatRelativeDate } from "@/lib/utils";
import type { AshaPerformance } from "@/lib/types";

export default function AshaWorkersPage() {
  const [workers, setWorkers] = useState<AshaPerformance[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");

  useEffect(() => {
    (async () => {
      setLoading(true);
      const res = await fetch("/api/asha");
      const data = await res.json();
      setWorkers(data.workers ?? []);
      setLoading(false);
    })();
  }, []);

  const filtered = workers.filter((w) => {
    const q = search.toLowerCase();
    return !q || w.name.toLowerCase().includes(q) || (w.district ?? "").toLowerCase().includes(q) || w.phone.includes(q);
  });

  const top5 = workers.slice(0, 5).map((w) => ({ name: w.name.split(" ")[0], screenings: w.screeningsDone }));

  return (
    <div className="p-6 space-y-5">
      <div>
        <h1 className="text-xl font-bold text-slate-900 dark:text-slate-100">ASHA Workers</h1>
        <p className="text-sm text-slate-500 dark:text-slate-400 font-medium">{workers.length} registered workers</p>
      </div>

      {/* Leaderboard chart */}
      {!loading && workers.length > 0 && (
        <div className="bg-white dark:bg-slate-900 rounded-2xl p-5 shadow-sm border border-slate-200 dark:border-slate-800">
          <div className="flex items-center gap-2 mb-4">
            <Trophy className="w-5 h-5 text-amber-500" />
            <h2 className="font-bold text-slate-900 dark:text-slate-100 text-sm">Top Performers (by Screenings)</h2>
          </div>
          <ResponsiveContainer width="100%" height={160}>
            <BarChart data={top5} margin={{ top: 0, right: 4, left: -20, bottom: 0 }}>
              <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" />
              <XAxis dataKey="name" tick={{ fill: "#64748b", fontSize: 11, fontWeight: 500 }} axisLine={false} tickLine={false} />
              <YAxis tick={{ fill: "#64748b", fontSize: 11, fontWeight: 500 }} axisLine={false} tickLine={false} />
              <Tooltip contentStyle={{ background: "#ffffff", border: "1px solid #e2e8f0", borderRadius: 12, fontSize: 12, color: "#0f172a", boxShadow: "0 4px 6px -1px rgb(0 0 0 / 0.1)" }} />
              <Bar dataKey="screenings" fill="#0ea5e9" radius={[6, 6, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>
      )}

      {/* Search */}
      <div className="relative">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400 dark:text-slate-500" />
        <input value={search} onChange={(e) => setSearch(e.target.value)}
          placeholder="Search by name, district, phone…"
          className="w-full pl-9 pr-4 py-2.5 rounded-xl text-sm bg-white dark:bg-slate-900 shadow-sm border border-slate-200 dark:border-slate-800 text-slate-900 dark:text-slate-100 placeholder-slate-400 dark:placeholder-slate-500 focus:outline-none focus:ring-4 focus:ring-sky-50 dark:focus:ring-sky-900/20 focus:border-sky-400 dark:focus:border-sky-500 transition-all" />
      </div>

      {/* Cards grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        {loading ? (
          Array.from({ length: 6 }).map((_, i) => (
            <div key={i} className="bg-white dark:bg-slate-900 border border-slate-100 dark:border-slate-800 rounded-2xl p-5 space-y-3 animate-pulse">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-xl bg-slate-100" />
                <div className="space-y-2 flex-1">
                  <div className="h-4 bg-slate-100 rounded w-3/4" />
                  <div className="h-3 bg-slate-100 rounded w-1/2" />
                </div>
              </div>
              <div className="h-px bg-slate-50 dark:bg-slate-800" />
              <div className="grid grid-cols-3 gap-3">
                {[1, 2, 3].map((j) => <div key={j} className="h-12 bg-slate-100 rounded-lg" />)}
              </div>
            </div>
          ))
        ) : filtered.length === 0 ? (
          <p className="col-span-3 text-center text-slate-500 dark:text-slate-400 py-8 font-medium">No workers found</p>
        ) : filtered.map((w, i) => (
          <div key={w.uid} className="bg-white dark:bg-slate-900 rounded-2xl p-5 card-hover shadow-sm border border-slate-200 dark:border-slate-800">
            <div className="flex items-center gap-3 mb-4">
              <div className="relative">
                <div className="w-10 h-10 rounded-xl flex items-center justify-center text-sm font-bold text-sky-700 dark:text-sky-400 bg-sky-100">
                  {w.name.charAt(0).toUpperCase()}
                </div>
                {i < 3 && (
                  <div className="absolute -top-1.5 -right-1.5 w-5 h-5 rounded-full flex items-center justify-center text-[9px] font-bold text-white shadow-sm"
                    style={{ background: ["#f59e0b","#94a3b8","#b45309"][i] }}>
                    {i + 1}
                  </div>
                )}
              </div>
              <div className="min-w-0 flex-1">
                <p className="font-bold text-slate-900 dark:text-slate-100 text-sm truncate">{w.name}</p>
                <p className="text-[11px] text-slate-500 dark:text-slate-400 font-medium">{w.district || w.village || "Unknown district"} · {w.phone}</p>
              </div>
            </div>

            <div className="h-px bg-slate-100 mb-4" />

            <div className="grid grid-cols-3 gap-2 text-center mb-3">
              <div className="bg-sky-50 dark:bg-sky-500/10 border border-sky-100 rounded-xl py-2">
                <p className="text-lg font-bold text-sky-700 dark:text-sky-400">{w.screeningsDone}</p>
                <p className="text-[9px] text-slate-500 dark:text-slate-400 font-semibold uppercase tracking-wider">Tests</p>
              </div>
              <div className="bg-amber-50 border border-amber-100 rounded-xl py-2">
                <p className="text-lg font-bold text-amber-700">{w.referralsMade}</p>
                <p className="text-[9px] text-slate-500 dark:text-slate-400 font-semibold uppercase tracking-wider">Referrals</p>
              </div>
              <div className="bg-emerald-50 border border-emerald-100 rounded-xl py-2">
                <p className="text-lg font-bold text-emerald-700">{w.followupsDone}</p>
                <p className="text-[9px] text-slate-500 dark:text-slate-400 font-semibold uppercase tracking-wider">Follow-ups</p>
              </div>
            </div>

            {w.lastActivity && (
              <p className="text-[10px] text-slate-500 dark:text-slate-400 font-medium">Last active: {formatRelativeDate(w.lastActivity)}</p>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}
