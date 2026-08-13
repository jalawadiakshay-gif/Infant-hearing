"use client";
import { useEffect, useState } from "react";
import {
  Baby, Stethoscope, ArrowUpRight, CalendarCheck,
  Users, AlertTriangle, TrendingUp, Activity, RefreshCw,
} from "lucide-react";
import {
  AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer,
  PieChart, Pie, Cell, Legend,
} from "recharts";
import { cn } from "@/lib/utils";
import { useTheme } from "next-themes";

interface Stats {
  totalChildren: number; screeningsThisMonth: number; passCount: number;
  referCount: number; monitorCount: number; activeAshas: number;
  pendingReferrals: number; overdueFollowups: number; boaScreenings: number; qScreenings: number;
}
interface Trend { month: string; boa: number; questionnaire: number; total: number; }
interface District { district: string; children: number; screenings: number; passRate: number; referRate: number; activeAshas: number; }

const RESULT_COLORS = ["#10b981", "#f43f5e", "#f59e0b"]; // emerald-500, rose-500, amber-500

function KpiCard({ icon: Icon, label, value, sub, color, alert }: {
  icon: React.ElementType; label: string; value: number | string; sub?: string;
  color: string; alert?: boolean;
}) {
  return (
    <div className={cn("glass rounded-2xl p-5 card-hover relative overflow-hidden", alert && Number(value) > 0 ? "border-rose-300 dark:border-rose-500/50" : "")}>
      <div className="flex items-start justify-between mb-4">
        <div className={cn("w-10 h-10 rounded-xl flex items-center justify-center", color)}>
          <Icon className="w-5 h-5" />
        </div>
        {alert && Number(value) > 0 && (
          <span className="w-2 h-2 rounded-full bg-rose-500 pulse-dot absolute top-4 right-4" />
        )}
      </div>
      <p className="text-2xl font-bold text-slate-900 dark:text-slate-100 mb-0.5">{typeof value === "number" ? value.toLocaleString() : value}</p>
      <p className="text-xs text-slate-500 dark:text-slate-400 font-medium">{label}</p>
      {sub && <p className="text-[10px] text-slate-400 dark:text-slate-500 mt-0.5">{sub}</p>}
    </div>
  );
}

export default function DashboardPage() {
  const [stats, setStats] = useState<Stats | null>(null);
  const [trends, setTrends] = useState<Trend[]>([]);
  const [districts, setDistricts] = useState<District[]>([]);
  const [loading, setLoading] = useState(true);
  const [lastSync, setLastSync] = useState<string | null>(null);
  const { resolvedTheme } = useTheme();
  const isDark = resolvedTheme === "dark";

  const fetchData = async () => {
    setLoading(true);
    try {
      const res = await fetch("/api/stats");
      const data = await res.json();
      setStats(data.stats);
      setTrends(data.trends);
      setDistricts(data.districts?.slice(0, 8) ?? []);
      setLastSync(new Date().toLocaleTimeString("en-IN"));
    } catch { /* silently handle */ }
    setLoading(false);
  };

  useEffect(() => { fetchData(); }, []);

  const pieData = stats ? [
    { name: "Pass", value: stats.passCount },
    { name: "Refer", value: stats.referCount },
    { name: "Monitor", value: stats.monitorCount },
  ] : [];

  const chartGridColor = isDark ? "#1e293b" : "#f1f5f9";
  const chartAxisColor = isDark ? "#64748b" : "#64748b";
  const chartTooltipStyle = isDark
    ? { background: "#1e293b", border: "1px solid #334155", borderRadius: 12, color: "#f1f5f9", fontSize: 12, boxShadow: "0 4px 6px -1px rgb(0 0 0 / 0.4)" }
    : { background: "#ffffff", border: "1px solid #e2e8f0", borderRadius: 12, color: "#0f172a", fontSize: 12, boxShadow: "0 4px 6px -1px rgb(0 0 0 / 0.1)" };

  return (
    <div className="min-h-screen p-6 space-y-6">
      {/* ── Header ── */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-900 dark:text-slate-100">
            <span className="gradient-text">Baalshravya</span> Dashboard
          </h1>
          <p className="text-sm text-slate-500 dark:text-slate-400 mt-0.5">
            Early Infant Hearing Detection — District Overview
          </p>
        </div>
        <button
          onClick={fetchData}
          disabled={loading}
          className="flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-medium glass text-slate-600 dark:text-slate-300 hover:text-slate-900 dark:hover:text-slate-100 hover:border-sky-300 dark:hover:border-sky-600 transition-all duration-200"
        >
          <RefreshCw className={cn("w-4 h-4", loading && "animate-spin")} />
          {loading ? "Syncing…" : "Refresh"}
        </button>
      </div>

      {lastSync && (
        <p className="text-[11px] text-slate-400 dark:text-slate-500 -mt-2 font-medium">
          Last synced to Neon: {lastSync} · Data from Firestore
        </p>
      )}

      {/* ── KPI Grid ── */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <KpiCard icon={Baby} label="Total Children" value={stats?.totalChildren ?? "—"} sub="Registered infants" color="bg-sky-50 dark:bg-sky-500/10 text-sky-600 dark:text-sky-400" />
        <KpiCard icon={Stethoscope} label="Screenings This Month" value={stats?.screeningsThisMonth ?? "—"} sub={`BOA: ${stats?.boaScreenings ?? 0}  Q: ${stats?.qScreenings ?? 0}`} color="bg-violet-50 dark:bg-violet-500/10 text-violet-600 dark:text-violet-400" />
        <KpiCard icon={ArrowUpRight} label="Pending Referrals" value={stats?.pendingReferrals ?? "—"} sub="Awaiting action" color="bg-rose-50 dark:bg-rose-500/10 text-rose-600 dark:text-rose-400" alert />
        <KpiCard icon={CalendarCheck} label="Overdue Follow-ups" value={stats?.overdueFollowups ?? "—"} sub="Missed scheduled visits" color="bg-amber-50 dark:bg-amber-500/10 text-amber-600 dark:text-amber-400" alert />
        <KpiCard icon={TrendingUp} label="Pass Rate" value={stats && stats.passCount + stats.referCount + stats.monitorCount > 0 ? `${Math.round((stats.passCount / (stats.passCount + stats.referCount + stats.monitorCount)) * 100)}%` : "—"} sub="Cleared children" color="bg-emerald-50 dark:bg-emerald-500/10 text-emerald-600 dark:text-emerald-400" />
        <KpiCard icon={AlertTriangle} label="Refer Rate" value={stats && stats.passCount + stats.referCount + stats.monitorCount > 0 ? `${Math.round((stats.referCount / (stats.passCount + stats.referCount + stats.monitorCount)) * 100)}%` : "—"} sub="Need hospital review" color="bg-orange-50 dark:bg-orange-500/10 text-orange-600 dark:text-orange-400" />
        <KpiCard icon={Users} label="Active ASHA Workers" value={stats?.activeAshas ?? "—"} sub="Registered in system" color="bg-cyan-50 dark:bg-cyan-500/10 text-cyan-600 dark:text-cyan-400" />
        <KpiCard icon={Activity} label="Total Screenings" value={(stats ? stats.boaScreenings + stats.qScreenings : 0)} sub="All time" color="bg-indigo-50 dark:bg-indigo-500/10 text-indigo-600 dark:text-indigo-400" />
      </div>

      {/* ── Charts Row ── */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-5">
        {/* Trend chart */}
        <div className="lg:col-span-2 glass rounded-2xl p-5">
          <div className="flex items-center justify-between mb-4">
            <div>
              <h2 className="font-semibold text-slate-900 dark:text-slate-100 text-sm">Screening Trend</h2>
              <p className="text-[11px] text-slate-500 dark:text-slate-400">Last 6 months</p>
            </div>
            <div className="flex items-center gap-3 text-[11px] text-slate-500 dark:text-slate-400 font-medium">
              <span className="flex items-center gap-1"><span className="w-2 h-2 rounded-full bg-sky-500 inline-block" />BOA</span>
              <span className="flex items-center gap-1"><span className="w-2 h-2 rounded-full bg-violet-500 inline-block" />Questionnaire</span>
            </div>
          </div>
          <ResponsiveContainer width="100%" height={200}>
            <AreaChart data={trends} margin={{ top: 4, right: 4, left: -20, bottom: 0 }}>
              <defs>
                <linearGradient id="boa" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="#0ea5e9" stopOpacity={isDark ? 0.25 : 0.15} />
                  <stop offset="95%" stopColor="#0ea5e9" stopOpacity={0} />
                </linearGradient>
                <linearGradient id="q" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="#8b5cf6" stopOpacity={isDark ? 0.25 : 0.15} />
                  <stop offset="95%" stopColor="#8b5cf6" stopOpacity={0} />
                </linearGradient>
              </defs>
              <CartesianGrid strokeDasharray="3 3" stroke={chartGridColor} />
              <XAxis dataKey="month" tick={{ fill: chartAxisColor, fontSize: 11 }} axisLine={false} tickLine={false} />
              <YAxis tick={{ fill: chartAxisColor, fontSize: 11 }} axisLine={false} tickLine={false} />
              <Tooltip contentStyle={chartTooltipStyle} />
              <Area type="monotone" dataKey="boa" stroke="#0ea5e9" fill="url(#boa)" strokeWidth={2} dot={false} name="BOA" />
              <Area type="monotone" dataKey="questionnaire" stroke="#8b5cf6" fill="url(#q)" strokeWidth={2} dot={false} name="Questionnaire" />
            </AreaChart>
          </ResponsiveContainer>
        </div>

        {/* Result Donut */}
        <div className="glass rounded-2xl p-5 flex flex-col">
          <h2 className="font-semibold text-slate-900 dark:text-slate-100 text-sm mb-1">Result Distribution</h2>
          <p className="text-[11px] text-slate-500 dark:text-slate-400 mb-4">All screenings</p>
          <div className="flex-1 flex items-center justify-center">
            {pieData.some((d) => d.value > 0) ? (
              <ResponsiveContainer width="100%" height={180}>
                <PieChart>
                  <Pie data={pieData} cx="50%" cy="50%" innerRadius={55} outerRadius={80} paddingAngle={3} dataKey="value">
                    {pieData.map((_, i) => <Cell key={i} fill={RESULT_COLORS[i]} />)}
                  </Pie>
                  <Legend iconType="circle" iconSize={8} wrapperStyle={{ fontSize: 11, color: isDark ? "#94a3b8" : "#475569", fontWeight: 500 }} />
                  <Tooltip contentStyle={chartTooltipStyle} />
                </PieChart>
              </ResponsiveContainer>
            ) : (
              <p className="text-slate-500 dark:text-slate-400 text-sm text-center">No data yet</p>
            )}
          </div>
        </div>
      </div>

      {/* ── District Table ── */}
      <div className="glass rounded-2xl overflow-hidden">
        <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100 dark:border-slate-800">
          <div>
            <h2 className="font-semibold text-slate-900 dark:text-slate-100 text-sm">District Performance</h2>
            <p className="text-[11px] text-slate-500 dark:text-slate-400">Top districts by activity</p>
          </div>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-slate-100 dark:border-slate-800 bg-slate-50/50 dark:bg-slate-800/50">
                {["District", "Children", "Screenings", "Pass Rate", "Refer Rate", "ASHA Workers"].map((h) => (
                  <th key={h} className="px-6 py-3 text-left text-[11px] font-semibold text-slate-500 dark:text-slate-400 uppercase tracking-wider">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {loading ? (
                Array.from({ length: 5 }).map((_, i) => (
                  <tr key={i} className="border-b border-slate-100 dark:border-slate-800">
                    {Array.from({ length: 6 }).map((__, j) => (
                      <td key={j} className="px-6 py-3">
                        <div className="h-4 rounded-lg animate-pulse bg-slate-100 dark:bg-slate-800" style={{ width: `${60 + ((i * 7 + j * 13) % 40)}%` }} />
                      </td>
                    ))}
                  </tr>
                ))
              ) : districts.length === 0 ? (
                <tr><td colSpan={6} className="px-6 py-8 text-center text-slate-500 dark:text-slate-400">No data yet</td></tr>
              ) : (
                districts.map((d) => (
                  <tr key={d.district} className="border-b border-slate-100 dark:border-slate-800 table-row-hover">
                    <td className="px-6 py-3 font-semibold text-slate-700 dark:text-slate-200">{d.district}</td>
                    <td className="px-6 py-3 text-slate-600 dark:text-slate-300 font-medium">{d.children}</td>
                    <td className="px-6 py-3 text-slate-600 dark:text-slate-300 font-medium">{d.screenings}</td>
                    <td className="px-6 py-3">
                      <div className="flex items-center gap-2">
                        <div className="flex-1 h-1.5 rounded-full bg-slate-100 dark:bg-slate-700 max-w-[80px]">
                          <div className="h-full rounded-full bg-emerald-500" style={{ width: `${d.passRate}%` }} />
                        </div>
                        <span className="text-emerald-600 dark:text-emerald-400 font-semibold text-xs">{d.passRate}%</span>
                      </div>
                    </td>
                    <td className="px-6 py-3">
                      <span className={cn("badge text-xs", d.referRate > 30 ? "bg-rose-50 dark:bg-rose-500/10 text-rose-700 dark:text-rose-400 border-rose-200 dark:border-rose-500/30" : "bg-amber-50 dark:bg-amber-500/10 text-amber-700 dark:text-amber-400 border-amber-200 dark:border-amber-500/30")}>
                        {d.referRate}%
                      </span>
                    </td>
                    <td className="px-6 py-3 text-slate-600 dark:text-slate-300 font-medium">{d.activeAshas}</td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
