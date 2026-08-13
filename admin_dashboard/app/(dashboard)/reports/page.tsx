"use client";
import { useState } from "react";
import { FileBarChart, Download, RefreshCw, FileText, Database } from "lucide-react";
import { cn, formatDate } from "@/lib/utils";

interface ReportRow {
  district: string;
  children: number;
  screenings: number;
  passRate: number;
  referRate: number;
  boaCount: number;
  qCount: number;
  activeAshas: number;
  pendingReferrals: number;
  overdueFollowups: number;
}

export default function ReportsPage() {
  const [loading, setLoading] = useState(false);
  const [reportData, setReportData] = useState<ReportRow[] | null>(null);
  const [generatedAt, setGeneratedAt] = useState<string | null>(null);
  const [totalStats, setTotalStats] = useState<Record<string, number> | null>(null);

  const generateReport = async () => {
    setLoading(true);
    try {
      const [statsRes, childrenRes] = await Promise.all([
        fetch("/api/stats"),
        fetch("/api/children?limit=500"),
      ]);
      const stats = await statsRes.json();
      const s = stats.stats;

      setTotalStats({
        totalChildren: s.totalChildren,
        screeningsThisMonth: s.screeningsThisMonth,
        passCount: s.passCount,
        referCount: s.referCount,
        monitorCount: s.monitorCount,
        activeAshas: s.activeAshas,
        pendingReferrals: s.pendingReferrals,
        overdueFollowups: s.overdueFollowups,
        boaScreenings: s.boaScreenings,
        qScreenings: s.qScreenings,
      });

      setReportData(stats.districts ?? []);
      setGeneratedAt(new Date().toLocaleString("en-IN"));
    } catch (err) {
      console.error(err);
    }
    setLoading(false);
  };

  const exportCSV = () => {
    if (!reportData) return;
    const rows = [
      ["Baalshravya District Report", `Generated: ${generatedAt}`],
      [],
      ["District", "Children", "Screenings", "Pass Rate %", "Refer Rate %", "BOA Count", "Q Count", "Active ASHAs", "Pending Referrals", "Overdue Follow-ups"],
      ...reportData.map((r) => [r.district, r.children, r.screenings, r.passRate, r.referRate, r.boaCount ?? 0, r.qCount ?? 0, r.activeAshas, r.pendingReferrals ?? 0, r.overdueFollowups ?? 0]),
    ];
    const csv = rows.map((r) => r.map((v) => `"${v}"`).join(",")).join("\n");
    const dataUri = "data:text/csv;charset=utf-8," + encodeURIComponent(csv);
    const a = document.createElement("a");
    a.setAttribute("href", dataUri);
    a.setAttribute("download", "Baalshravya_District_Report.csv");
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
  };

  return (
    <div className="p-6 space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-xl font-bold text-slate-900 dark:text-slate-100">Reports & Export</h1>
          <p className="text-sm text-slate-500 dark:text-slate-400 font-medium">Government-ready district performance reports</p>
        </div>
      </div>

      {/* Report Generator Card */}
      <div className="bg-white dark:bg-slate-900 rounded-2xl p-6 shadow-sm border border-slate-200 dark:border-slate-800">
        <div className="flex items-start gap-4">
          <div className="w-12 h-12 rounded-2xl bg-sky-50 dark:bg-sky-500/10 flex items-center justify-center flex-shrink-0">
            <FileBarChart className="w-6 h-6 text-sky-600" />
          </div>
          <div className="flex-1">
            <h2 className="font-bold text-slate-900 dark:text-slate-100 text-base">District Performance Report</h2>
            <p className="text-sm text-slate-500 dark:text-slate-400 mt-1 font-medium max-w-3xl">
              Aggregates data from Firestore across all districts. Includes screening coverage, referral rates, ASHA performance, and follow-up compliance. Suitable for submission to district health officials.
            </p>
            <div className="flex items-center gap-3 mt-4 flex-wrap">
              <button
                onClick={generateReport}
                disabled={loading}
                className="flex items-center gap-2 px-5 py-2.5 rounded-xl text-sm font-bold text-white transition-all shadow-sm"
                style={{ background: "linear-gradient(135deg, #0ea5e9, #3b82f6)" }}
              >
                {loading ? <RefreshCw className="w-4 h-4 animate-spin" /> : <Database className="w-4 h-4" />}
                {loading ? "Generating…" : "Generate Report"}
              </button>
              {reportData && (
                <button
                  onClick={exportCSV}
                  className="flex items-center gap-2 px-5 py-2.5 rounded-xl text-sm font-bold bg-emerald-50 border border-emerald-200 text-emerald-700 hover:bg-emerald-100 transition-all shadow-sm"
                >
                  <Download className="w-4 h-4" /> Export CSV
                </button>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Generated Report */}
      {reportData && totalStats && (
        <>
          {/* Header */}
          <div className="bg-white dark:bg-slate-900 rounded-2xl p-6 shadow-sm border border-sky-200 dark:border-sky-500/30">
            <div className="flex items-center justify-between mb-5">
              <div>
                <h3 className="font-bold text-slate-900 dark:text-slate-100 text-base">
                  <span className="text-sky-600">Baalshravya</span> — District Report
                </h3>
                <p className="text-[11px] text-slate-500 dark:text-slate-400 mt-0.5 font-medium">Generated: {generatedAt} · Synced to Neon</p>
              </div>
              <div className="flex items-center gap-1.5 text-xs text-emerald-600 font-bold">
                <span className="w-2 h-2 rounded-full bg-emerald-500 pulse-dot" />
                Live data
              </div>
            </div>

            {/* Overall KPIs */}
            <div className="grid grid-cols-2 sm:grid-cols-5 gap-3">
              {[
                { label: "Total Children", value: totalStats.totalChildren, color: "text-sky-600" },
                { label: "Screenings (Month)", value: totalStats.screeningsThisMonth, color: "text-violet-600" },
                { label: "Pass", value: totalStats.passCount, color: "text-emerald-600" },
                { label: "Refer", value: totalStats.referCount, color: "text-rose-600" },
                { label: "Active ASHAs", value: totalStats.activeAshas, color: "text-indigo-600" },
              ].map(({ label, value, color }) => (
                <div key={label} className="bg-slate-50 dark:bg-slate-800 border border-slate-100 dark:border-slate-800 rounded-xl p-3 text-center">
                  <p className={cn("text-xl font-bold", color)}>{value}</p>
                  <p className="text-[10px] text-slate-500 dark:text-slate-400 mt-1 uppercase tracking-wider font-bold">{label}</p>
                </div>
              ))}
            </div>
          </div>

          {/* District Breakdown */}
          <div className="bg-white dark:bg-slate-900 rounded-2xl overflow-hidden shadow-sm border border-slate-200 dark:border-slate-800">
            <div className="px-6 py-4 border-b border-slate-100 dark:border-slate-800 bg-slate-50 dark:bg-slate-800">
              <h3 className="font-bold text-slate-900 dark:text-slate-100 text-sm">District Breakdown</h3>
            </div>
            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead>
                  <tr className="border-b border-slate-200 dark:border-slate-800 bg-slate-50 dark:bg-slate-800">
                    {["District", "Children", "Screenings", "Pass Rate", "Refer Rate", "ASHA Workers", "Pending Refs", "Coverage"].map((h) => (
                      <th key={h} className="px-5 py-3 text-left text-[11px] font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider">{h}</th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {reportData.length === 0 ? (
                    <tr><td colSpan={8} className="px-5 py-8 text-center text-slate-500 dark:text-slate-400 font-medium">No data available</td></tr>
                  ) : reportData.map((row, i) => {
                    const coverage = row.children > 0 ? Math.round((row.screenings / row.children) * 100) : 0;
                    return (
                      <tr key={row.district} className={cn("border-b border-slate-100 dark:border-slate-800 hover:bg-slate-50 dark:hover:bg-slate-800 dark:bg-slate-800 transition-colors", i === 0 && "bg-amber-50/50")}>
                        <td className="px-5 py-3">
                          <div className="flex items-center gap-2">
                            {i === 0 && <span className="text-amber-500">🏆</span>}
                            <span className="font-bold text-slate-700 dark:text-slate-200">{row.district || "Unknown"}</span>
                          </div>
                        </td>
                        <td className="px-5 py-3 text-slate-600 dark:text-slate-300 font-medium">{row.children}</td>
                        <td className="px-5 py-3 text-slate-600 dark:text-slate-300 font-medium">{row.screenings}</td>
                        <td className="px-5 py-3">
                          <span className="text-emerald-600 font-bold">{row.passRate}%</span>
                        </td>
                        <td className="px-5 py-3">
                          <span className={cn("font-bold", row.referRate > 30 ? "text-rose-600" : "text-amber-600")}>
                            {row.referRate}%
                          </span>
                        </td>
                        <td className="px-5 py-3 text-slate-600 dark:text-slate-300 font-medium">{row.activeAshas}</td>
                        <td className="px-5 py-3">
                          <span className={cn("badge text-[10px]", row.pendingReferrals > 0 ? "bg-rose-50 text-rose-700 border-rose-200" : "bg-emerald-50 text-emerald-700 border-emerald-200")}>
                            {row.pendingReferrals ?? 0}
                          </span>
                        </td>
                        <td className="px-5 py-3">
                          <div className="flex items-center gap-2">
                            <div className="flex-1 h-2 rounded-full bg-slate-100 max-w-[60px] border border-slate-200 dark:border-slate-800 overflow-hidden">
                              <div className="h-full rounded-full" style={{ width: `${Math.min(coverage, 100)}%`, background: coverage >= 70 ? "#10b981" : coverage >= 40 ? "#f59e0b" : "#f43f5e" }} />
                            </div>
                            <span className={cn("text-xs font-bold", coverage >= 70 ? "text-emerald-600" : coverage >= 40 ? "text-amber-600" : "text-rose-600")}>
                              {coverage}%
                            </span>
                          </div>
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          </div>

          {/* Footer Note */}
          <div className="bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-800 rounded-xl px-5 py-4 flex items-start gap-3 shadow-sm">
            <FileText className="w-5 h-5 text-slate-400 dark:text-slate-500 flex-shrink-0" />
            <p className="text-xs text-slate-600 dark:text-slate-300 font-medium leading-relaxed">
              This report reflects live data from Firebase Firestore (project: infant-hearing-app). Aggregated statistics are also stored in Neon PostgreSQL for historical trend analysis. For official government submission, export to CSV and attach to district health report.
            </p>
          </div>
        </>
      )}
    </div>
  );
}
