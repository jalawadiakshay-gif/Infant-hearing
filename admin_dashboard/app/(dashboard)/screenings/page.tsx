"use client";
import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { Search, Play, FileText, Filter, Video, ExternalLink, Mic, ClipboardList, X, Download } from "lucide-react";
import { cn, getResultBg, formatDate } from "@/lib/utils";
import type { Screening } from "@/lib/types";

const TYPE_OPTS = ["all", "boa", "q"];
const RESULT_OPTS = ["all", "pass", "refer", "monitor", "incomplete"];

function VideoModal({ url, onClose }: { url: string; onClose: () => void }) {
  useEffect(() => {
    const handleKey = (e: KeyboardEvent) => e.key === "Escape" && onClose();
    window.addEventListener("keydown", handleKey);
    return () => window.removeEventListener("keydown", handleKey);
  }, [onClose]);

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center p-4"
      style={{ background: "rgba(15,23,42,0.85)", backdropFilter: "blur(4px)" }}
      onClick={onClose}
    >
      <div
        className="relative w-full max-w-3xl bg-white dark:bg-slate-900 rounded-2xl overflow-hidden shadow-2xl border border-slate-200 dark:border-slate-800"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex items-center justify-between px-4 py-3 border-b border-slate-100 dark:border-slate-800 bg-slate-50 dark:bg-slate-800">
          <div className="flex items-center gap-2">
            <Video className="w-4 h-4 text-sky-600" />
            <span className="text-sm font-bold text-slate-900 dark:text-slate-100">BOA Session Recording</span>
          </div>
          <div className="flex items-center gap-2">
            <a
              href={url}
              target="_blank"
              rel="noreferrer"
              className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-semibold text-slate-600 dark:text-slate-300 bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 hover:border-sky-300 hover:text-sky-700 dark:text-sky-400 transition-all shadow-sm"
            >
              <Download className="w-3.5 h-3.5" /> Download
            </a>
            <button
              onClick={onClose}
              className="w-8 h-8 rounded-lg bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 flex items-center justify-center text-slate-500 dark:text-slate-400 hover:text-slate-900 dark:hover:text-slate-100 dark:text-slate-100 transition-colors shadow-sm"
            >
              <X className="w-4 h-4" />
            </button>
          </div>
        </div>
        <video src={url} controls autoPlay className="w-full max-h-[65vh] bg-slate-900" />
        <div className="bg-slate-50 dark:bg-slate-800 border-t border-slate-100 dark:border-slate-800 py-2">
          <p className="text-center text-xs text-slate-500 dark:text-slate-400 font-medium">
            Press <kbd className="px-1.5 py-0.5 rounded bg-slate-200 text-slate-700 dark:text-slate-200 font-bold">Esc</kbd> to close
          </p>
        </div>
      </div>
    </div>
  );
}

export default function ScreeningsPage() {
  const router = useRouter();
  const [screenings, setScreenings] = useState<Screening[]>([]);
  const [filtered, setFiltered] = useState<Screening[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [type, setType] = useState("all");
  const [result, setResult] = useState("all");
  const [videoUrl, setVideoUrl] = useState<string | null>(null);

  useEffect(() => {
    (async () => {
      setLoading(true);
      const res = await fetch("/api/screenings?limit=200");
      const data = await res.json();
      setScreenings(data.screenings ?? []);
      setLoading(false);
    })();
  }, []);

  useEffect(() => {
    const q = search.toLowerCase();
    setFiltered(
      screenings.filter((s) => {
        const matchSearch =
          !q ||
          s.childId.toLowerCase().includes(q) ||
          s.screeningId.toLowerCase().includes(q) ||
          s.conductedBy?.toLowerCase().includes(q);
        const matchType = type === "all" || s.type === type;
        const matchResult = result === "all" || s.result === result;
        return matchSearch && matchType && matchResult;
      })
    );
  }, [screenings, search, type, result]);

  // Stats
  const boaTotal = screenings.filter((s) => s.type === "boa").length;
  const qTotal = screenings.filter((s) => s.type === "q").length;
  const withVideo = screenings.filter((s) => s.videoUrl).length;
  const withPdf = screenings.filter((s) => s.pdfUrl).length;

  return (
    <div className="p-6 space-y-5">
      {videoUrl && <VideoModal url={videoUrl} onClose={() => setVideoUrl(null)} />}

      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-xl font-bold text-slate-900 dark:text-slate-100">Screening Reports</h1>
          <p className="text-sm text-slate-500 dark:text-slate-400 font-medium">{filtered.length} of {screenings.length} records · BOA + Questionnaire</p>
        </div>
      </div>

      {/* Stats strip */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
        {[
          { label: "BOA Tests", value: boaTotal, color: "text-sky-600" },
          { label: "Questionnaires", value: qTotal, color: "text-violet-600" },
          { label: "Videos Stored", value: withVideo, color: "text-emerald-600" },
          { label: "PDF Reports", value: withPdf, color: "text-rose-600" },
        ].map((s) => (
          <div key={s.label} className="bg-white dark:bg-slate-900 rounded-xl shadow-sm border border-slate-200 dark:border-slate-800 p-5">
            <p className={cn("text-3xl font-bold", s.color)}>{s.value}</p>
            <p className="text-xs text-slate-500 dark:text-slate-400 mt-1 font-semibold">{s.label}</p>
          </div>
        ))}
      </div>

      {/* Filters */}
      <div className="flex flex-col sm:flex-row gap-3">
        <div className="flex-1 relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400 dark:text-slate-500" />
          <input
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search by child ID, screening ID, or ASHA ID…"
            className="w-full pl-9 pr-4 py-2.5 rounded-xl text-sm bg-white dark:bg-slate-900 shadow-sm border border-slate-200 dark:border-slate-800 text-slate-900 dark:text-slate-100 placeholder-slate-400 dark:placeholder-slate-500 focus:outline-none focus:ring-4 focus:ring-sky-50 dark:focus:ring-sky-900/20 focus:border-sky-400 dark:focus:border-sky-500 transition-all"
          />
        </div>
        <div className="flex items-center gap-2 flex-wrap">
          <Filter className="w-4 h-4 text-slate-400 dark:text-slate-500" />
          {TYPE_OPTS.map((t) => (
            <button
              key={t}
              onClick={() => setType(t)}
              className={cn(
                "px-3 py-2 rounded-xl text-xs font-bold capitalize transition-all shadow-sm",
                type === t
                  ? "bg-violet-50 text-violet-700 border border-violet-200"
                  : "bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 text-slate-600 dark:text-slate-300 hover:text-slate-900 dark:hover:text-slate-100 dark:text-slate-100"
              )}
            >
              {t === "q" ? "Questionnaire" : t === "boa" ? "BOA" : "All Types"}
            </button>
          ))}
          {RESULT_OPTS.map((r) => (
            <button
              key={r}
              onClick={() => setResult(r)}
              className={cn(
                "px-3 py-2 rounded-xl text-xs font-bold capitalize transition-all shadow-sm",
                result === r
                  ? "bg-sky-50 dark:bg-sky-500/10 text-sky-700 dark:text-sky-400 border border-sky-200 dark:border-sky-500/30"
                  : "bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 text-slate-600 dark:text-slate-300 hover:text-slate-900 dark:hover:text-slate-100 dark:text-slate-100"
              )}
            >
              {r === "all" ? "All Results" : r}
            </button>
          ))}
        </div>
      </div>

      {/* Table */}
      <div className="bg-white dark:bg-slate-900 shadow-sm rounded-2xl border border-slate-200 dark:border-slate-800 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-slate-100 dark:border-slate-800 bg-slate-50/50 dark:bg-slate-800/50">
                {["Date", "Type", "Result", "BOA Outcome", "Child ID", "ASHA", "Media", ""].map((h) => (
                  <th
                    key={h}
                    className="px-5 py-3 text-left text-[11px] font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider"
                  >
                    {h}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {loading ? (
                Array.from({ length: 8 }).map((_, i) => (
                  <tr key={i} className="border-b border-slate-50">
                    {Array.from({ length: 8 }).map((__, j) => (
                      <td key={j} className="px-5 py-3">
                        <div className="h-4 rounded-lg animate-pulse bg-slate-100 w-4/5" />
                      </td>
                    ))}
                  </tr>
                ))
              ) : filtered.length === 0 ? (
                <tr>
                  <td colSpan={8} className="px-5 py-8 text-center text-slate-500 dark:text-slate-400 font-medium">
                    No screenings found
                  </td>
                </tr>
              ) : (
                filtered.map((s) => (
                  <tr key={s.screeningId} className="border-b border-slate-100 dark:border-slate-800 table-row-hover hover:bg-slate-50 dark:hover:bg-slate-800 dark:bg-slate-800 cursor-pointer" onClick={() => router.push(`/children/${s.childId}`)}>
                    <td className="px-5 py-3 text-slate-600 dark:text-slate-300 text-xs whitespace-nowrap font-medium">
                      {s.date ? formatDate(s.date) : "—"}
                    </td>

                    <td className="px-5 py-3">
                      <span className={cn(
                        "badge text-[10px] flex items-center gap-1 w-fit",
                        s.type === "boa"
                          ? "bg-sky-50 dark:bg-sky-500/10 text-sky-700 dark:text-sky-400 border-sky-200 dark:border-sky-500/30"
                          : "bg-violet-50 text-violet-700 border-violet-200"
                      )}>
                        {s.type === "boa" ? <Mic className="w-2.5 h-2.5" /> : <ClipboardList className="w-2.5 h-2.5" />}
                        {s.type === "boa" ? "BOA" : "Q"}
                      </span>
                    </td>

                    <td className="px-5 py-3">
                      <span className={cn("badge text-[10px] capitalize", getResultBg(s.result))}>
                        {s.result}
                      </span>
                    </td>

                    <td className="px-5 py-3 text-slate-600 dark:text-slate-300 text-xs font-medium">
                      {(s as any).b?.outcome
                        ? (s as any).b.outcome.replace(/([A-Z])/g, " $1").trim()
                        : "—"}
                    </td>

                    <td className="px-5 py-3">
                      <button
                        onClick={(e) => { e.stopPropagation(); router.push(`/children/${s.childId}`); }}
                        className="flex items-center gap-1 text-sky-600 hover:text-sky-700 dark:text-sky-400 transition-colors font-mono text-xs font-semibold"
                        title="View child profile"
                      >
                        {s.childId.slice(0, 8)}…
                        <ExternalLink className="w-3 h-3" />
                      </button>
                    </td>

                    <td className="px-5 py-3 text-slate-500 dark:text-slate-400 text-xs font-mono font-medium">
                      {s.conductedBy?.slice(0, 8)}…
                    </td>

                    <td className="px-5 py-3">
                      <div className="flex items-center gap-2">
                        {s.videoUrl ? (
                          <button
                            onClick={(e) => { e.stopPropagation(); setVideoUrl(s.videoUrl!); }}
                            className="w-8 h-8 rounded-lg bg-sky-50 dark:bg-sky-500/10 border border-sky-200 dark:border-sky-500/30 flex items-center justify-center text-sky-600 hover:bg-sky-100 transition-all shadow-sm"
                            title="Play BOA video"
                          >
                            <Play className="w-3.5 h-3.5 fill-current" />
                          </button>
                        ) : (
                          <div className="w-8 h-8" />
                        )}
                        {s.pdfUrl ? (
                          <a
                            href={s.pdfUrl}
                            target="_blank"
                            rel="noreferrer"
                            onClick={(e) => e.stopPropagation()}
                            className="w-8 h-8 rounded-lg bg-rose-50 border border-rose-200 flex items-center justify-center text-rose-600 hover:bg-rose-100 transition-all shadow-sm"
                            title="Open PDF report"
                          >
                            <FileText className="w-3.5 h-3.5" />
                          </a>
                        ) : (
                          <div className="w-8 h-8" />
                        )}
                        {!s.videoUrl && !s.pdfUrl && (
                          <span className="text-slate-400 dark:text-slate-500 text-xs italic">—</span>
                        )}
                      </div>
                    </td>

                    <td className="px-5 py-3 text-right">
                      <button
                        onClick={(e) => { e.stopPropagation(); router.push(`/children/${s.childId}`); }}
                        className="text-xs font-semibold text-slate-400 dark:text-slate-500 hover:text-sky-600 dark:hover:text-sky-400 transition-colors whitespace-nowrap inline-flex items-center gap-1"
                      >
                        View <ExternalLink className="w-3 h-3" />
                      </button>
                    </td>
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
