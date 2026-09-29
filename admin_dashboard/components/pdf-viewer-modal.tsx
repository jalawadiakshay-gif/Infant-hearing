"use client";
import { useEffect, useState } from "react";
import { X, Download, ExternalLink, FileText, ZoomIn, ZoomOut, RotateCw, Maximize2 } from "lucide-react";

interface PdfViewerModalProps {
  url: string;
  title?: string;
  onClose: () => void;
}

export default function PdfViewerModal({ url, title = "Clinical Report", onClose }: PdfViewerModalProps) {
  const [zoom, setZoom] = useState(100);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);

  // Close on Escape
  useEffect(() => {
    const handleKey = (e: KeyboardEvent) => e.key === "Escape" && onClose();
    window.addEventListener("keydown", handleKey);
    return () => window.removeEventListener("keydown", handleKey);
  }, [onClose]);

  // Prevent body scroll when modal open
  useEffect(() => {
    document.body.style.overflow = "hidden";
    return () => { document.body.style.overflow = ""; };
  }, []);

  const handleZoomIn  = () => setZoom((z) => Math.min(z + 20, 200));
  const handleZoomOut = () => setZoom((z) => Math.max(z - 20, 60));
  const handleReset   = () => setZoom(100);

  // Encode URL for iframe — adds #toolbar=1 for Chrome's built-in PDF viewer
  const iframeSrc = `${url}#toolbar=1&navpanes=0&scrollbar=1`;

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center p-4"
      style={{ background: "rgba(7,15,35,0.88)", backdropFilter: "blur(6px)" }}
      onClick={onClose}
    >
      <div
        className="relative flex flex-col w-full max-w-5xl rounded-2xl overflow-hidden shadow-2xl border border-slate-200 dark:border-slate-700"
        style={{ height: "90vh", background: "#1e293b" }}
        onClick={(e) => e.stopPropagation()}
      >
        {/* ── Toolbar ── */}
        <div className="flex items-center justify-between px-5 py-3 bg-slate-800 border-b border-slate-700 flex-shrink-0">
          {/* Left — title */}
          <div className="flex items-center gap-2.5 min-w-0">
            <div className="w-8 h-8 rounded-lg bg-rose-500/20 border border-rose-500/30 flex items-center justify-center flex-shrink-0">
              <FileText className="w-4 h-4 text-rose-400" />
            </div>
            <div className="min-w-0">
              <p className="text-sm font-semibold text-slate-100 truncate">{title}</p>
              <p className="text-[10px] text-slate-400 font-medium">PDF Report · Baalshravya</p>
            </div>
          </div>

          {/* Center — zoom controls */}
          <div className="flex items-center gap-1 bg-slate-700 rounded-xl p-1 border border-slate-600">
            <button
              onClick={handleZoomOut}
              disabled={zoom <= 60}
              title="Zoom out"
              className="w-7 h-7 rounded-lg flex items-center justify-center text-slate-300 hover:text-white hover:bg-slate-600 disabled:opacity-30 disabled:cursor-not-allowed transition-all"
            >
              <ZoomOut className="w-3.5 h-3.5" />
            </button>
            <button
              onClick={handleReset}
              title="Reset zoom"
              className="px-2.5 h-7 rounded-lg text-[11px] font-bold text-slate-300 hover:text-white hover:bg-slate-600 transition-all min-w-[3rem] text-center"
            >
              {zoom}%
            </button>
            <button
              onClick={handleZoomIn}
              disabled={zoom >= 200}
              title="Zoom in"
              className="w-7 h-7 rounded-lg flex items-center justify-center text-slate-300 hover:text-white hover:bg-slate-600 disabled:opacity-30 disabled:cursor-not-allowed transition-all"
            >
              <ZoomIn className="w-3.5 h-3.5" />
            </button>
            <div className="w-px h-4 bg-slate-600 mx-0.5" />
            <button
              onClick={handleReset}
              title="Reset"
              className="w-7 h-7 rounded-lg flex items-center justify-center text-slate-300 hover:text-white hover:bg-slate-600 transition-all"
            >
              <RotateCw className="w-3.5 h-3.5" />
            </button>
          </div>

          {/* Right — actions */}
          <div className="flex items-center gap-2">
            <a
              href={url}
              target="_blank"
              rel="noreferrer"
              title="Open in new tab"
              className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-semibold text-slate-300 bg-slate-700 border border-slate-600 hover:bg-slate-600 hover:text-white transition-all"
            >
              <Maximize2 className="w-3.5 h-3.5" />
              Full Screen
            </a>
            <a
              href={url}
              download
              title="Download PDF"
              className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-semibold text-sky-300 bg-sky-500/10 border border-sky-500/30 hover:bg-sky-500/20 hover:text-sky-200 transition-all"
            >
              <Download className="w-3.5 h-3.5" />
              Download
            </a>
            <a
              href={url}
              target="_blank"
              rel="noreferrer"
              title="Open PDF"
              className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-semibold text-emerald-300 bg-emerald-500/10 border border-emerald-500/30 hover:bg-emerald-500/20 hover:text-emerald-200 transition-all"
            >
              <ExternalLink className="w-3.5 h-3.5" />
              Open
            </a>
            <button
              onClick={onClose}
              title="Close (Esc)"
              className="w-8 h-8 rounded-lg bg-slate-700 border border-slate-600 flex items-center justify-center text-slate-400 hover:text-white hover:bg-rose-500/20 hover:border-rose-500/40 transition-all"
            >
              <X className="w-4 h-4" />
            </button>
          </div>
        </div>

        {/* ── PDF Viewer ── */}
        <div className="flex-1 relative overflow-hidden bg-slate-700">
          {/* Loading skeleton */}
          {loading && !error && (
            <div className="absolute inset-0 flex flex-col items-center justify-center gap-3 z-10 bg-slate-800">
              <div className="w-12 h-12 rounded-2xl bg-rose-500/20 border border-rose-500/30 flex items-center justify-center animate-pulse">
                <FileText className="w-6 h-6 text-rose-400" />
              </div>
              <p className="text-slate-400 text-sm font-medium">Loading PDF…</p>
              <div className="flex gap-1.5">
                {[0,1,2].map(i => (
                  <div
                    key={i}
                    className="w-2 h-2 rounded-full bg-sky-400"
                    style={{ animation: `bounce 1s ${i * 0.15}s infinite` }}
                  />
                ))}
              </div>
            </div>
          )}

          {/* Error fallback */}
          {error && (
            <div className="absolute inset-0 flex flex-col items-center justify-center gap-4 bg-slate-800 z-10">
              <div className="w-14 h-14 rounded-2xl bg-rose-500/10 border border-rose-500/20 flex items-center justify-center">
                <FileText className="w-7 h-7 text-rose-400" />
              </div>
              <div className="text-center">
                <p className="text-slate-200 font-semibold text-sm">Cannot preview in browser</p>
                <p className="text-slate-400 text-xs mt-1">Use the buttons above to open or download</p>
              </div>
              <div className="flex gap-3">
                <a
                  href={url}
                  target="_blank"
                  rel="noreferrer"
                  className="flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-semibold text-white bg-sky-600 hover:bg-sky-500 transition-all"
                >
                  <ExternalLink className="w-4 h-4" />
                  Open PDF
                </a>
                <a
                  href={url}
                  download
                  className="flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-semibold text-sky-300 bg-sky-500/10 border border-sky-500/30 hover:bg-sky-500/20 transition-all"
                >
                  <Download className="w-4 h-4" />
                  Download
                </a>
              </div>
            </div>
          )}

          {/* The actual PDF iframe */}
          {!error && (
            <iframe
              key={zoom} // re-mount on zoom change triggers re-render
              src={iframeSrc}
              title={title}
              className="w-full h-full border-none"
              style={{
                transform: `scale(${zoom / 100})`,
                transformOrigin: "top center",
                width: `${(100 * 100) / zoom}%`,
                height: `${(100 * 100) / zoom}%`,
              }}
              onLoad={() => setLoading(false)}
              onError={() => { setLoading(false); setError(true); }}
            />
          )}
        </div>

        {/* ── Footer ── */}
        <div className="flex items-center justify-between px-5 py-2.5 bg-slate-800 border-t border-slate-700 flex-shrink-0">
          <p className="text-[10px] text-slate-400 font-medium">
            Press <kbd className="px-1.5 py-0.5 rounded bg-slate-700 text-slate-300 font-bold border border-slate-600 text-[10px]">Esc</kbd> to close
          </p>
          <p className="text-[10px] text-slate-500">Baalshravya Clinical Report · Confidential</p>
        </div>
      </div>

      <style>{`
        @keyframes bounce {
          0%, 100% { transform: translateY(0); opacity: 1; }
          50% { transform: translateY(-6px); opacity: 0.5; }
        }
      `}</style>
    </div>
  );
}
