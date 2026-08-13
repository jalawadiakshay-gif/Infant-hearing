import Sidebar from "@/components/sidebar";

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex min-h-screen">
      <Sidebar />
      <main
        className="flex-1 overflow-auto bg-slate-50 dark:bg-slate-950 transition-colors duration-200"
        style={{ marginLeft: "var(--sidebar-width, 260px)" }}
      >
        {children}
      </main>
    </div>
  );
}
