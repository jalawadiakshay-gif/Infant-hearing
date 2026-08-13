"use client";
import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { Search, Filter, Download, Copy, CheckCheck } from "lucide-react";
import { cn, getResultBg, getAgeLabel, formatDate } from "@/lib/utils";
import type { Child } from "@/lib/types";

const STATUS_OPTS = ["all", "new", "pass", "refer", "monitor"];

export default function ChildrenPage() {
  const router = useRouter();
  const [children, setChildren] = useState<Child[]>([]);
  const [filtered, setFiltered] = useState<Child[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [status, setStatus] = useState("all");
  const [copiedId, setCopiedId] = useState<string | null>(null);

  useEffect(() => {
    (async () => {
      setLoading(true);
      const res = await fetch("/api/children?limit=200");
      const data = await res.json();
      setChildren(data.children ?? []);
      setLoading(false);
    })();
  }, []);

  useEffect(() => {
    const q = search.toLowerCase();
    setFiltered(
      children.filter((c) => {
        const matchSearch =
          !q ||
          c.name.toLowerCase().includes(q) ||
          c.parentName.toLowerCase().includes(q) ||
          c.parentPhone.includes(q) ||
          (c.village ?? "").toLowerCase().includes(q) ||
          (c.childCode ?? "").toLowerCase().includes(q);
        const matchStatus = status === "all" || c.status === status;
        return matchSearch && matchStatus;
      })
    );
  }, [children, search, status]);

  const copyToClipboard = async (text: string, id: string) => {
    try {
      await navigator.clipboard.writeText(text);
      setCopiedId(id);
      setTimeout(() => setCopiedId(null), 2000);
    } catch {
      // Fallback
    }
  };

  const exportCSV = () => {
    const rows = [
      ["Child Code", "Name", "DOB", "Gender", "Parent", "Phone", "Village", "Status", "Last Screening", "NICU Risk", "Registered"],
    ];
    filtered.forEach((c) => {
      rows.push([
        c.childCode ?? "—",
        c.name,
        c.dob ? new Date(c.dob).toLocaleDateString("en-IN") : "",
        c.gender,
        c.parentName,
        c.parentPhone,
        c.village ?? "",
        c.status ?? "new",
        c.lastScreening?.result ?? "—",
        c.risk?.nicu ? "Yes" : "No",
        c.createdAt ? new Date(c.createdAt).toLocaleDateString("en-IN") : "",
      ]);
    });
    const csv = rows.map((r) => r.map((v) => `"${v}"`).join(",")).join("\n");
    const dataUri = "data:text/csv;charset=utf-8," + encodeURIComponent(csv);
    const a = document.createElement("a");
    a.setAttribute("href", dataUri);
    a.setAttribute("download", "Baalshravya_Children_Registry.csv");
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
  };

  return (
    <div className="p-6 space-y-5">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-xl font-bold text-slate-900 dark:text-slate-100">Children Registry</h1>
          <p className="text-sm text-slate-500 dark:text-slate-400">
            {filtered.length} of {children.length} infants
          </p>
        </div>
        <button
          onClick={exportCSV}
          className="flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-medium glass border border-slate-200 dark:border-slate-800 text-slate-600 dark:text-slate-300 hover:text-sky-600 dark:hover:text-sky-400 hover:border-sky-200 dark:hover:border-sky-800 transition-all"
        >
          <Download className="w-4 h-4" /> Export CSV
        </button>
      </div>

      {/* Filters */}
      <div className="flex flex-col sm:flex-row gap-3">
        <div className="flex-1 relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400 dark:text-slate-500" />
          <input
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search by name, parent, phone, village, or Child Code…"
            className="w-full pl-9 pr-4 py-2.5 rounded-xl text-sm glass border border-slate-200 dark:border-slate-800 text-slate-900 dark:text-slate-100 placeholder-slate-400 dark:placeholder-slate-500 focus:outline-none focus:border-sky-400 dark:focus:border-sky-500 focus:ring-4 focus:ring-sky-50 dark:focus:ring-sky-900/20 transition-all"
          />
        </div>
        <div className="flex items-center gap-2">
          <Filter className="w-4 h-4 text-slate-400 dark:text-slate-500" />
          {STATUS_OPTS.map((s) => (
            <button
              key={s}
              onClick={() => setStatus(s)}
              className={cn(
                "px-3 py-2 rounded-xl text-xs font-medium capitalize transition-all",
                status === s
                  ? "bg-sky-50 dark:bg-sky-500/10 text-sky-700 dark:text-sky-400 border border-sky-200 dark:border-sky-500/30"
                  : "glass border border-slate-200 dark:border-slate-800 text-slate-600 dark:text-slate-400 hover:text-slate-900 dark:hover:text-slate-100 hover:bg-slate-50 dark:hover:bg-slate-800"
              )}
            >
              {s}
            </button>
          ))}
        </div>
      </div>

      {/* Table */}
      <div className="glass rounded-2xl overflow-hidden shadow-sm">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-slate-100 dark:border-slate-800 bg-slate-50/50 dark:bg-slate-800/50">
                {[
                  "Child Code",
                  "Child Name",
                  "Age",
                  "Parent",
                  "Village",
                  "Risk",
                  "Status",
                  "Last Screening",
                  "Registered",
                ].map((h) => (
                  <th
                    key={h}
                    className="px-5 py-3 text-left text-[11px] font-semibold text-slate-500 dark:text-slate-400 uppercase tracking-wider"
                  >
                    {h}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {loading ? (
                Array.from({ length: 8 }).map((_, i) => (
                  <tr key={i} className="border-b border-slate-50 dark:border-slate-800">
                    {Array.from({ length: 9 }).map((__, j) => (
                      <td key={j} className="px-5 py-3">
                        <div className="h-4 rounded-lg animate-pulse bg-slate-100 dark:bg-slate-800 w-4/5" />
                      </td>
                    ))}
                  </tr>
                ))
              ) : filtered.length === 0 ? (
                <tr>
                  <td
                    colSpan={9}
                    className="px-5 py-8 text-center text-slate-500 dark:text-slate-400"
                  >
                    No children found
                  </td>
                </tr>
              ) : (
                filtered.map((c) => (
                  <tr
                    key={c.childId}
                    className="border-b border-slate-100 dark:border-slate-800 table-row-hover cursor-pointer"
                    onClick={() => router.push(`/children/${c.childId}`)}
                  >
                    {/* Child Code */}
                    <td className="px-5 py-3">
                      {c.childCode ? (
                        <div className="flex items-center gap-1.5">
                          <span className="font-mono text-xs text-sky-700 dark:text-sky-400 bg-sky-50 dark:bg-sky-500/10 border border-sky-200 dark:border-sky-500/20 px-2 py-0.5 rounded-md tracking-wide">
                            {c.childCode}
                          </span>
                          <button
                            onClick={(e) => {
                              e.stopPropagation();
                              copyToClipboard(c.childCode!, c.childId);
                            }}
                            className="text-slate-400 hover:text-sky-600 dark:hover:text-sky-400 transition-colors"
                            title="Copy Child Code"
                          >
                            {copiedId === c.childId ? (
                              <CheckCheck className="w-3.5 h-3.5 text-emerald-500 dark:text-emerald-400" />
                            ) : (
                              <Copy className="w-3.5 h-3.5" />
                            )}
                          </button>
                        </div>
                      ) : (
                        <span className="text-slate-400 text-xs italic">No code</span>
                      )}
                    </td>

                    {/* Child Name */}
                    <td className="px-5 py-3">
                      <div className="flex items-center gap-2">
                        <div
                          className="w-7 h-7 rounded-lg flex items-center justify-center text-xs font-bold text-sky-700 dark:text-sky-400 bg-sky-100 dark:bg-sky-500/20"
                        >
                          {c.name.charAt(0).toUpperCase()}
                        </div>
                        <span className="font-semibold text-slate-700 dark:text-slate-200">{c.name}</span>
                      </div>
                    </td>

                    <td className="px-5 py-3 text-slate-500 dark:text-slate-400 text-xs font-medium">
                      {c.dob ? getAgeLabel(c.dob) : "—"}
                    </td>

                    <td className="px-5 py-3">
                      <p className="text-slate-700 dark:text-slate-200 font-medium">{c.parentName}</p>
                      <p className="text-[10px] text-slate-500 dark:text-slate-400">{c.parentPhone}</p>
                    </td>

                    <td className="px-5 py-3 text-slate-600 dark:text-slate-300 text-xs font-medium">
                      {c.village ?? "—"}
                    </td>

                    <td className="px-5 py-3">
                      {c.risk?.nicu ? (
                        <span className="badge bg-rose-50 dark:bg-rose-500/10 text-rose-700 dark:text-rose-400 border-rose-200 dark:border-rose-500/20 text-[10px]">
                          NICU
                        </span>
                      ) : (
                        <span className="text-slate-400 text-xs">—</span>
                      )}
                    </td>

                    <td className="px-5 py-3">
                      <span
                        className={cn(
                          "badge text-[10px] capitalize",
                          getResultBg(c.status ?? "new")
                        )}
                      >
                        {c.status ?? "new"}
                      </span>
                    </td>

                    <td className="px-5 py-3">
                      {c.lastScreening ? (
                        <div>
                          <span
                            className={cn(
                              "badge text-[10px] capitalize",
                              getResultBg(c.lastScreening.result)
                            )}
                          >
                            {c.lastScreening.result}
                          </span>
                          <p className="text-[10px] text-slate-500 dark:text-slate-400 mt-0.5 font-medium">
                            {c.lastScreening.type === "boa" ? "BOA" : "Questionnaire"}
                          </p>
                        </div>
                      ) : (
                        <span className="text-slate-400 dark:text-slate-500 text-xs">Not screened</span>
                      )}
                    </td>

                    <td className="px-5 py-3 text-slate-500 dark:text-slate-400 text-xs font-medium">
                      {c.createdAt ? formatDate(c.createdAt) : "—"}
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
