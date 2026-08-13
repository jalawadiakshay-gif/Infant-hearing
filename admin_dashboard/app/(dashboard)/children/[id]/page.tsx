"use client";
import { useEffect, useState, useCallback } from "react";
import { useParams, useRouter } from "next/navigation";
import {
  ArrowLeft,
  Play,
  FileText,
  ChevronDown,
  ChevronUp,
  Download,
  AlertTriangle,
  CheckCircle,
  Clock,
  Mic,
  ClipboardList,
  Video,
  Baby,
  Phone,
  MapPin,
  Calendar,
  Hash,
  Copy,
  CheckCheck,
  RefreshCw,
  X,
} from "lucide-react";
import { cn, getResultBg, getAgeLabel, formatDate } from "@/lib/utils";
import type { Child, Screening } from "@/lib/types";

// ── Video Modal ──────────────────────────────────────────────────────────────

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
        {/* Header */}
        <div className="flex items-center justify-between px-4 py-3 border-b border-slate-100 dark:border-slate-800 bg-slate-50 dark:bg-slate-800">
          <div className="flex items-center gap-2">
            <Video className="w-4 h-4 text-sky-600" />
            <span className="text-sm font-semibold text-slate-900 dark:text-slate-100">BOA Session Recording</span>
          </div>
          <div className="flex items-center gap-2">
            <a
              href={url}
              target="_blank"
              rel="noreferrer"
              className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-medium text-slate-600 dark:text-slate-300 bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 hover:border-sky-300 hover:text-sky-700 dark:text-sky-400 transition-all"
            >
              <Download className="w-3 h-3" /> Download
            </a>
            <button
              onClick={onClose}
              className="w-8 h-8 rounded-lg bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 flex items-center justify-center text-slate-500 dark:text-slate-400 hover:text-slate-900 dark:hover:text-slate-100 dark:text-slate-100 transition-colors shadow-sm"
            >
              <X className="w-4 h-4" />
            </button>
          </div>
        </div>
        <video
          src={url}
          controls
          autoPlay
          className="w-full bg-slate-900 max-h-[70vh]"
        />
        <div className="bg-slate-50 dark:bg-slate-800 border-t border-slate-100 dark:border-slate-800 py-2">
          <p className="text-center text-xs text-slate-500 dark:text-slate-400">
            Press <kbd className="px-1.5 py-0.5 rounded bg-slate-200 text-slate-700 dark:text-slate-200 font-medium">Esc</kbd> to close
          </p>
        </div>
      </div>
    </div>
  );
}

// ── BOA Trial Detail Row ─────────────────────────────────────────────────────

function BoaTrialRow({ trial, index }: { trial: any; index: number }) {
  const responseLabel =
    trial.r === "y" ? "Response ✓" : trial.r === "n" ? "No Response" : "Uncertain";
  const responseColor =
    trial.r === "y" ? "text-emerald-600" : trial.r === "n" ? "text-rose-600" : "text-amber-600";

  return (
    <tr className="border-b border-slate-100 dark:border-slate-800 text-xs hover:bg-slate-50 dark:hover:bg-slate-800 dark:bg-slate-800 transition-colors">
      <td className="px-4 py-2.5 text-slate-500 dark:text-slate-400 font-medium">
        {trial.c ? (
          <span className="text-purple-600 font-semibold">Catch</span>
        ) : (
          <span>#{index + 1}</span>
        )}
      </td>
      <td className="px-4 py-2.5">
        <span className="font-mono text-sky-700 dark:text-sky-400 bg-sky-50 dark:bg-sky-500/10 border border-sky-200 dark:border-sky-500/30 px-2 py-0.5 rounded font-medium">
          {trial.db} dB HL
        </span>
      </td>
      <td className="px-4 py-2.5 text-slate-600 dark:text-slate-300 font-medium">{trial.hz ? `${(trial.hz / 1000).toFixed(1)} kHz` : "—"}</td>
      <td className={cn("px-4 py-2.5 font-semibold", responseColor)}>{responseLabel}</td>
      <td className="px-4 py-2.5 text-slate-600 dark:text-slate-300">
        {trial.ai !== undefined ? (
          <div className="flex items-center gap-2">
            <div
              className="h-2 rounded-full bg-slate-100 border border-slate-200 dark:border-slate-800"
              style={{ width: 48 }}
            >
              <div
                className="h-full rounded-full bg-sky-50 dark:bg-sky-500/100"
                style={{ width: `${(trial.ai * 100).toFixed(0)}%` }}
              />
            </div>
            <span className="font-medium">{(trial.ai * 100).toFixed(0)}%</span>
          </div>
        ) : "—"}
      </td>
      <td className="px-4 py-2.5 text-slate-600 dark:text-slate-300 capitalize font-medium">{trial.det ?? "—"}</td>
      <td className="px-4 py-2.5 text-slate-600 dark:text-slate-300 font-medium">{trial.ms ? `${trial.ms}ms` : "—"}</td>
    </tr>
  );
}

// ── Questionnaire Answer Row ─────────────────────────────────────────────────

function QuestionnaireAnswers({ answers }: { answers: Record<string, string> }) {
  if (!answers || Object.keys(answers).length === 0)
    return <p className="text-slate-500 dark:text-slate-400 text-sm">No questionnaire answers recorded.</p>;

  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
      {Object.entries(answers).map(([q, a]) => (
        <div key={q} className="flex items-start gap-2 p-2.5 rounded-lg bg-slate-50 dark:bg-slate-800 border border-slate-100 dark:border-slate-800">
          <span className="text-xs text-slate-500 dark:text-slate-400 mt-0.5 min-w-[60px] font-mono font-medium">{q}</span>
          <span
            className={cn(
              "text-xs font-semibold capitalize",
              a === "yes" || a === "y" ? "text-emerald-600" : a === "no" || a === "n" ? "text-rose-600" : "text-slate-700 dark:text-slate-200"
            )}
          >
            {a}
          </span>
        </div>
      ))}
    </div>
  );
}

// ── Screening Card ───────────────────────────────────────────────────────────

function ScreeningCard({
  screening,
  onPlayVideo,
}: {
  screening: Screening & { b?: any; q?: any };
  onPlayVideo: (url: string) => void;
}) {
  const [expanded, setExpanded] = useState(false);
  const isBoa = screening.type === "boa";

  const outcomeIcon = {
    pass: <CheckCircle className="w-4 h-4 text-emerald-500" />,
    refer: <AlertTriangle className="w-4 h-4 text-rose-500" />,
    monitor: <Clock className="w-4 h-4 text-amber-500" />,
    incomplete: <Clock className="w-4 h-4 text-slate-400 dark:text-slate-500" />,
  }[screening.result] ?? <Clock className="w-4 h-4 text-slate-400 dark:text-slate-500" />;

  return (
    <div className="glass rounded-xl shadow-sm border border-slate-200 dark:border-slate-800 overflow-hidden bg-white dark:bg-slate-900">
      {/* Header row */}
      <div
        className="flex items-center gap-3 px-5 py-4 cursor-pointer hover:bg-slate-50 dark:hover:bg-slate-800 dark:bg-slate-800 transition-colors"
        onClick={() => setExpanded((v) => !v)}
      >
        {/* Type badge */}
        <div className={cn(
          "flex items-center gap-1.5 px-2.5 py-1 rounded-lg text-xs font-bold border",
          isBoa
            ? "bg-sky-50 dark:bg-sky-500/10 text-sky-700 dark:text-sky-400 border-sky-200 dark:border-sky-500/30"
            : "bg-violet-50 text-violet-700 border-violet-200"
        )}>
          {isBoa ? <Mic className="w-3 h-3" /> : <ClipboardList className="w-3 h-3" />}
          {isBoa ? "BOA Test" : "Questionnaire"}
        </div>

        {/* Result */}
        <div className="flex items-center gap-1.5">
          {outcomeIcon}
          <span className={cn("badge text-[10px] capitalize", getResultBg(screening.result))}>
            {screening.result}
          </span>
        </div>

        {/* BOA outcome */}
        {isBoa && screening.b?.outcome && (
          <span className="text-xs text-slate-500 dark:text-slate-400 font-medium hidden sm:block">
            {screening.b.outcome.replace(/([A-Z])/g, " $1").trim()}
          </span>
        )}

        {/* Q score */}
        {!isBoa && screening.q?.score !== undefined && (
          <span className="text-xs text-slate-500 dark:text-slate-400 font-medium">
            Score: <span className="text-slate-900 dark:text-slate-100 font-bold">{screening.q.score}</span>
          </span>
        )}

        {/* Spacer */}
        <div className="flex-1" />

        {/* Date */}
        <span className="text-xs text-slate-500 dark:text-slate-400 shrink-0 font-medium">
          {screening.date ? formatDate(screening.date) : "—"}
        </span>

        {/* Media icons */}
        <div className="flex items-center gap-1.5 shrink-0">
          {screening.videoUrl && (
            <button
              onClick={(e) => { e.stopPropagation(); onPlayVideo(screening.videoUrl!); }}
              className="w-7 h-7 rounded-lg bg-sky-50 dark:bg-sky-500/10 border border-sky-200 dark:border-sky-500/30 flex items-center justify-center text-sky-600 hover:bg-sky-100 transition-all shadow-sm"
              title="Play BOA video"
            >
              <Play className="w-3.5 h-3.5" />
            </button>
          )}
          {screening.pdfUrl && (
            <a
              href={screening.pdfUrl}
              target="_blank"
              rel="noreferrer"
              onClick={(e) => e.stopPropagation()}
              className="w-7 h-7 rounded-lg bg-rose-50 border border-rose-200 flex items-center justify-center text-rose-600 hover:bg-rose-100 transition-all shadow-sm"
              title="View PDF report"
            >
              <FileText className="w-3.5 h-3.5" />
            </a>
          )}
        </div>

        {/* Expand toggle */}
        {expanded
          ? <ChevronUp className="w-4 h-4 text-slate-400 dark:text-slate-500 shrink-0" />
          : <ChevronDown className="w-4 h-4 text-slate-400 dark:text-slate-500 shrink-0" />
        }
      </div>

      {/* Expanded content */}
      {expanded && (
        <div className="border-t border-slate-100 dark:border-slate-800 px-5 py-4 space-y-4 bg-slate-50/50 dark:bg-slate-800/50">
          {/* Meta row */}
          <div className="flex flex-wrap gap-x-6 gap-y-1 text-xs text-slate-500 dark:text-slate-400 font-medium">
            <span>ID: <span className="font-mono text-slate-600 dark:text-slate-300">{screening.screeningId}</span></span>
            <span>By: <span className="font-mono text-slate-600 dark:text-slate-300">{screening.conductedBy?.slice(0, 12)}…</span></span>
            {screening.offline && <span className="text-amber-600 font-semibold">⚡ Offline session</span>}
            {isBoa && screening.b?.noise !== undefined && (
              <span>Noise floor: <span className="text-slate-700 dark:text-slate-200 font-semibold">{screening.b.noise.toFixed(1)} dB</span></span>
            )}
          </div>

          {/* BOA: Trials table */}
          {isBoa && screening.b?.trials && screening.b.trials.length > 0 && (
            <div className="bg-white dark:bg-slate-900 p-4 rounded-xl border border-slate-200 dark:border-slate-800 shadow-sm">
              <p className="text-xs font-bold text-slate-600 dark:text-slate-300 uppercase tracking-wide mb-3">
                Trial Breakdown ({screening.b.trials.length} trials)
              </p>
              <div className="rounded-lg overflow-hidden border border-slate-200 dark:border-slate-800">
                <table className="w-full text-xs">
                  <thead>
                    <tr className="border-b border-slate-200 dark:border-slate-800 bg-slate-50 dark:bg-slate-800">
                      {["#", "Level", "Frequency", "Response", "AI Confidence", "Detection", "Latency"].map((h) => (
                        <th key={h} className="px-4 py-2.5 text-left text-[10px] font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider">
                          {h}
                        </th>
                      ))}
                    </tr>
                  </thead>
                  <tbody>
                    {screening.b.trials.map((t: any, i: number) => (
                      <BoaTrialRow key={i} trial={t} index={i} />
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {/* BOA: No trials message */}
          {isBoa && (!screening.b?.trials || screening.b.trials.length === 0) && (
            <p className="text-slate-500 dark:text-slate-400 text-sm italic">No trial data recorded for this session.</p>
          )}

          {/* Questionnaire: Answers */}
          {!isBoa && (
            <div className="bg-white dark:bg-slate-900 p-4 rounded-xl border border-slate-200 dark:border-slate-800 shadow-sm">
              <p className="text-xs font-bold text-slate-600 dark:text-slate-300 uppercase tracking-wide mb-3">
                Questionnaire Responses
                {screening.q?.score !== undefined && (
                  <span className="ml-3 normal-case text-slate-500 dark:text-slate-400 font-medium">
                    Score: {screening.q.score}
                    {screening.q?.pct !== undefined && ` · Risk: ${screening.q.pct.toFixed(0)}%`}
                    {screening.q?.age !== undefined && ` · Age at test: ${screening.q.age}mo`}
                  </span>
                )}
              </p>
              <QuestionnaireAnswers answers={screening.q?.answers ?? {}} />
            </div>
          )}

          {/* Video section */}
          {screening.videoUrl && (
            <div className="flex items-center gap-3 p-3 rounded-xl bg-sky-50 dark:bg-sky-500/10 border border-sky-100 shadow-sm">
              <Video className="w-5 h-5 text-sky-600 shrink-0" />
              <div className="flex-1">
                <p className="text-sm font-bold text-sky-900">Session Video Available</p>
                <p className="text-[10px] text-slate-500 dark:text-slate-400 mt-0.5 font-mono truncate">{screening.videoUrl}</p>
              </div>
              <button
                onClick={() => onPlayVideo(screening.videoUrl!)}
                className="flex items-center gap-1.5 px-4 py-2 rounded-lg bg-sky-100 border border-sky-200 dark:border-sky-500/30 text-sky-700 dark:text-sky-400 text-xs hover:bg-sky-200 transition-all font-bold shadow-sm"
              >
                <Play className="w-3.5 h-3.5 fill-current" /> Play
              </button>
              <a
                href={screening.videoUrl}
                target="_blank"
                rel="noreferrer"
                className="flex items-center gap-1.5 px-4 py-2 rounded-lg bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 text-slate-600 dark:text-slate-300 text-xs hover:border-sky-300 hover:text-sky-700 dark:text-sky-400 transition-all font-semibold shadow-sm"
              >
                <Download className="w-3.5 h-3.5" /> Download
              </a>
            </div>
          )}

          {/* PDF section */}
          {screening.pdfUrl && (
            <div className="flex items-center gap-3 p-3 rounded-xl bg-rose-50 border border-rose-100 shadow-sm">
              <FileText className="w-5 h-5 text-rose-600 shrink-0" />
              <div className="flex-1">
                <p className="text-sm font-bold text-rose-900">PDF Report Available</p>
                <p className="text-[10px] text-slate-500 dark:text-slate-400 mt-0.5 font-mono truncate">{screening.pdfUrl}</p>
              </div>
              <a
                href={screening.pdfUrl}
                target="_blank"
                rel="noreferrer"
                className="flex items-center gap-1.5 px-4 py-2 rounded-lg bg-rose-100 border border-rose-200 text-rose-700 text-xs hover:bg-rose-200 transition-all font-bold shadow-sm"
              >
                <Download className="w-3.5 h-3.5" /> Open PDF
              </a>
            </div>
          )}
        </div>
      )}
    </div>
  );
}

// ── Main Page ────────────────────────────────────────────────────────────────

export default function ChildDetailPage() {
  const { id } = useParams<{ id: string }>();
  const router = useRouter();

  const [child, setChild] = useState<Child | null>(null);
  const [screenings, setScreenings] = useState<Screening[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [videoUrl, setVideoUrl] = useState<string | null>(null);
  const [copiedCode, setCopiedCode] = useState(false);

  // Filter state
  const [typeFilter, setTypeFilter] = useState<"all" | "boa" | "q">("all");

  const loadData = useCallback(async () => {
    if (!id) return;
    setLoading(true);
    setError(null);
    try {
      const res = await fetch(`/api/children/${id}`);
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const data = await res.json();
      setChild(data.child);
      setScreenings(data.screenings ?? []);
    } catch (e: any) {
      setError(e.message ?? "Failed to load");
    } finally {
      setLoading(false);
    }
  }, [id]);

  useEffect(() => { loadData(); }, [loadData]);

  const copyCode = async (code: string) => {
    await navigator.clipboard.writeText(code);
    setCopiedCode(true);
    setTimeout(() => setCopiedCode(false), 2000);
  };

  const filtered = screenings.filter((s) =>
    typeFilter === "all" || s.type === typeFilter
  );

  const boaCount = screenings.filter((s) => s.type === "boa").length;
  const qCount = screenings.filter((s) => s.type === "q").length;
  const videoCount = screenings.filter((s) => s.videoUrl).length;

  if (loading) {
    return (
      <div className="p-6 space-y-5">
        <div className="flex items-center gap-3 mb-6">
          <button onClick={() => router.back()} className="w-10 h-10 rounded-xl glass flex items-center justify-center text-slate-500 dark:text-slate-400 hover:text-slate-900 dark:hover:text-slate-100 dark:text-slate-100 transition-colors shadow-sm border border-slate-200 dark:border-slate-800">
            <ArrowLeft className="w-5 h-5" />
          </button>
          <div className="h-8 w-48 bg-slate-200 rounded animate-pulse" />
        </div>
        {Array.from({ length: 4 }).map((_, i) => (
          <div key={i} className="glass rounded-xl h-16 animate-pulse bg-white dark:bg-slate-900 border-slate-200 dark:border-slate-800" />
        ))}
      </div>
    );
  }

  if (error || !child) {
    return (
      <div className="p-6 flex flex-col items-center justify-center min-h-[60vh] gap-4">
        <AlertTriangle className="w-12 h-12 text-rose-500" />
        <p className="text-slate-700 dark:text-slate-200 font-medium">{error ?? "Child not found"}</p>
        <button onClick={() => router.back()} className="px-4 py-2 rounded-xl glass border border-slate-200 dark:border-slate-800 text-slate-600 dark:text-slate-300 hover:text-slate-900 dark:hover:text-slate-100 dark:text-slate-100 transition-colors text-sm shadow-sm font-medium">
          ← Go Back
        </button>
      </div>
    );
  }

  return (
    <div className="p-6 space-y-6 max-w-5xl mx-auto">
      {videoUrl && <VideoModal url={videoUrl} onClose={() => setVideoUrl(null)} />}

      {/* ── Back + Title ── */}
      <div className="flex items-center gap-4">
        <button
          onClick={() => router.back()}
          className="w-10 h-10 rounded-xl bg-white dark:bg-slate-900 shadow-sm border border-slate-200 dark:border-slate-800 flex items-center justify-center text-slate-500 dark:text-slate-400 hover:text-slate-900 dark:hover:text-slate-100 dark:text-slate-100 transition-colors"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>
        <div>
          <h1 className="text-2xl font-bold text-slate-900 dark:text-slate-100 flex items-center gap-2">
            <Baby className="w-6 h-6 text-sky-500" />
            {child.name}
          </h1>
          <p className="text-sm text-slate-500 dark:text-slate-400 font-medium">{child.dob ? getAgeLabel(child.dob) : "Age unknown"}</p>
        </div>
        <div className="flex-1" />
        <button
          onClick={loadData}
          className="flex items-center gap-2 px-4 py-2 rounded-xl bg-white dark:bg-slate-900 shadow-sm border border-slate-200 dark:border-slate-800 text-slate-600 dark:text-slate-300 hover:text-slate-900 dark:hover:text-slate-100 dark:text-slate-100 text-xs font-semibold transition-colors"
        >
          <RefreshCw className="w-3.5 h-3.5" /> Refresh
        </button>
      </div>

      {/* ── Child Profile Card ── */}
      <div className="bg-white dark:bg-slate-900 rounded-2xl border border-slate-200 dark:border-slate-800 p-6 shadow-sm">
        <div className="flex flex-wrap gap-4 items-start justify-between">
          {/* Left: Info grid */}
          <div className="grid grid-cols-2 sm:grid-cols-3 gap-x-8 gap-y-4 text-sm flex-1">
            <InfoField icon={<Hash className="w-4 h-4" />} label="Child Code">
              {child.childCode ? (
                <div className="flex items-center gap-2 mt-1">
                  <span className="font-mono font-semibold text-sky-700 dark:text-sky-400 bg-sky-50 dark:bg-sky-500/10 border border-sky-200 dark:border-sky-500/30 px-2.5 py-1 rounded text-sm tracking-wide shadow-sm">
                    {child.childCode}
                  </span>
                  <button
                    onClick={() => copyCode(child.childCode!)}
                    className="text-slate-400 dark:text-slate-500 hover:text-sky-600 dark:hover:text-sky-400 transition-colors"
                    title="Copy"
                  >
                    {copiedCode ? <CheckCheck className="w-4 h-4 text-emerald-500" /> : <Copy className="w-4 h-4" />}
                  </button>
                </div>
              ) : <span className="text-slate-400 dark:text-slate-500 italic text-sm mt-1 block">Not assigned</span>}
            </InfoField>

            <InfoField icon={<Calendar className="w-4 h-4" />} label="Date of Birth">
              <span className="mt-1 block font-medium text-slate-700 dark:text-slate-200">
                {child.dob ? new Date(child.dob).toLocaleDateString("en-IN") : "—"}
              </span>
            </InfoField>

            <InfoField icon={<Baby className="w-4 h-4" />} label="Gender">
              <span className="mt-1 block font-medium text-slate-700 dark:text-slate-200">
                {child.gender === "M" ? "Male" : child.gender === "F" ? "Female" : "Other"}
              </span>
            </InfoField>

            <InfoField icon={<Phone className="w-4 h-4" />} label="Parent">
              <div className="mt-1">
                <p className="text-slate-900 dark:text-slate-100 font-semibold">{child.parentName}</p>
                <p className="text-xs text-slate-500 dark:text-slate-400 font-medium">{child.parentPhone}</p>
              </div>
            </InfoField>

            <InfoField icon={<MapPin className="w-4 h-4" />} label="Village">
              <span className="mt-1 block font-medium text-slate-700 dark:text-slate-200">{child.village ?? "—"}</span>
            </InfoField>

            <InfoField icon={<AlertTriangle className="w-4 h-4" />} label="NICU Risk">
              <div className="mt-1">
                {child.risk?.nicu ? (
                  <span className="badge bg-rose-50 text-rose-700 border-rose-200 text-xs shadow-sm">NICU Risk</span>
                ) : (
                  <span className="text-slate-500 dark:text-slate-400 text-sm font-medium">None</span>
                )}
              </div>
            </InfoField>

            {child.birthWeight && (
              <InfoField icon={null} label="Birth Weight">
                <span className="mt-1 block font-medium text-slate-700 dark:text-slate-200">{child.birthWeight} kg</span>
              </InfoField>
            )}

            {child.gestationalAge && (
              <InfoField icon={null} label="Gestational Age">
                <span className="mt-1 block font-medium text-slate-700 dark:text-slate-200">{child.gestationalAge} weeks</span>
              </InfoField>
            )}

            {child.hospitalName && (
              <InfoField icon={null} label="Hospital">
                <span className="mt-1 block font-medium text-slate-700 dark:text-slate-200">{child.hospitalName}</span>
              </InfoField>
            )}
          </div>

          {/* Right: Status badge */}
          <div className="flex flex-col items-end gap-2 shrink-0 bg-slate-50 dark:bg-slate-800 p-4 rounded-xl border border-slate-100 dark:border-slate-800">
            <p className="text-[10px] text-slate-500 dark:text-slate-400 uppercase tracking-widest font-bold mb-1">Current Status</p>
            <span className={cn("badge text-sm capitalize px-4 py-2 shadow-sm font-bold", getResultBg(child.status ?? "new"))}>
              {child.status ?? "new"}
            </span>
            <span className="text-[10px] text-slate-500 dark:text-slate-400 font-medium mt-1">
              Registered {child.createdAt ? formatDate(child.createdAt) : "—"}
            </span>
          </div>
        </div>
      </div>

      {/* ── Screening Summary Stats ── */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
        {[
          { label: "Total Screenings", value: screenings.length, color: "text-slate-900 dark:text-slate-100" },
          { label: "BOA Tests", value: boaCount, color: "text-sky-600" },
          { label: "Questionnaires", value: qCount, color: "text-violet-600" },
          { label: "Videos Stored", value: videoCount, color: "text-emerald-600" },
        ].map((stat) => (
          <div key={stat.label} className="bg-white dark:bg-slate-900 rounded-xl shadow-sm border border-slate-200 dark:border-slate-800 p-5">
            <p className={cn("text-3xl font-bold", stat.color)}>{stat.value}</p>
            <p className="text-xs text-slate-500 dark:text-slate-400 mt-1 font-semibold">{stat.label}</p>
          </div>
        ))}
      </div>

      {/* ── Screenings List ── */}
      <div>
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-bold text-slate-900 dark:text-slate-100">Screening Reports</h2>
          <div className="flex items-center gap-2 bg-slate-100 p-1 rounded-xl border border-slate-200 dark:border-slate-800">
            {(["all", "boa", "q"] as const).map((t) => (
              <button
                key={t}
                onClick={() => setTypeFilter(t)}
                className={cn(
                  "px-4 py-1.5 rounded-lg text-xs font-bold transition-all shadow-sm",
                  typeFilter === t
                    ? t === "boa"
                      ? "bg-sky-50 dark:bg-sky-500/10 text-sky-700 dark:text-sky-400 border border-sky-200 dark:border-sky-500/30"
                      : t === "q"
                      ? "bg-violet-50 text-violet-700 border border-violet-200"
                      : "bg-white dark:bg-slate-900 text-slate-900 dark:text-slate-100 border border-slate-200 dark:border-slate-800"
                    : "bg-transparent border-transparent text-slate-500 dark:text-slate-400 hover:text-slate-700 dark:text-slate-200 shadow-none"
                )}
              >
                {t === "all" ? "All" : t === "boa" ? "BOA" : "Questionnaire"}
              </button>
            ))}
          </div>
        </div>

        {filtered.length === 0 ? (
          <div className="bg-white dark:bg-slate-900 rounded-2xl border border-slate-200 dark:border-slate-800 shadow-sm p-16 text-center">
            <ClipboardList className="w-12 h-12 text-slate-300 mx-auto mb-4" />
            <p className="text-slate-500 dark:text-slate-400 font-medium">No {typeFilter === "all" ? "" : typeFilter === "boa" ? "BOA " : "questionnaire "}screenings recorded yet.</p>
          </div>
        ) : (
          <div className="space-y-4">
            {filtered.map((s) => (
              <ScreeningCard
                key={s.screeningId}
                screening={s as any}
                onPlayVideo={setVideoUrl}
              />
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

// ── InfoField helper ──────────────────────────────────────────────────────────

function InfoField({
  icon,
  label,
  children,
}: {
  icon: React.ReactNode;
  label: string;
  children: React.ReactNode;
}) {
  return (
    <div>
      <div className="flex items-center gap-1.5 mb-1">
        {icon && <span className="text-slate-400 dark:text-slate-500">{icon}</span>}
        <span className="text-[10px] text-slate-500 dark:text-slate-400 uppercase tracking-widest font-bold">{label}</span>
      </div>
      <div className="text-sm text-slate-700 dark:text-slate-200">{children}</div>
    </div>
  );
}
