"use client";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import {
  LayoutDashboard,
  Baby,
  Stethoscope,
  ArrowUpRight,
  CalendarCheck,
  Users,
  FileBarChart,
  LogOut,
  Ear,
  RefreshCw,
  Sun,
  Moon,
  Monitor,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { useAuth } from "@/components/auth-provider";
import { signOut } from "firebase/auth";
import { auth } from "@/lib/firebase";
import { useTheme } from "next-themes";
import { useEffect, useState } from "react";

const navItems = [
  { href: "/",              icon: LayoutDashboard, label: "Overview" },
  { href: "/children",     icon: Baby,            label: "Children" },
  { href: "/screenings",   icon: Stethoscope,     label: "Screenings" },
  { href: "/referrals",    icon: ArrowUpRight,    label: "Referrals" },
  { href: "/followups",    icon: CalendarCheck,   label: "Follow-ups" },
  { href: "/asha-workers", icon: Users,           label: "ASHA Workers" },
  { href: "/reports",      icon: FileBarChart,    label: "Reports" },
];

function ThemeToggle() {
  const { theme, setTheme } = useTheme();
  const [mounted, setMounted] = useState(false);

  // Avoid hydration mismatch
  useEffect(() => setMounted(true), []);
  if (!mounted) return <div className="h-9" />;

  const options = [
    { value: "light", icon: Sun,     title: "Light mode" },
    { value: "dark",  icon: Moon,    title: "Dark mode" },
    { value: "system",icon: Monitor, title: "System preference" },
  ] as const;

  return (
    <div className="flex items-center gap-1 bg-slate-100 dark:bg-slate-800 rounded-xl p-1 border border-slate-200 dark:border-slate-700">
      {options.map(({ value, icon: Icon, title }) => (
        <button
          key={value}
          title={title}
          onClick={() => setTheme(value)}
          className={cn(
            "flex-1 flex items-center justify-center h-7 rounded-lg transition-all duration-200",
            theme === value
              ? "bg-white dark:bg-slate-600 shadow-sm text-sky-600 dark:text-sky-400"
              : "text-slate-400 hover:text-slate-600 dark:hover:text-slate-300"
          )}
        >
          <Icon className="w-3.5 h-3.5" />
        </button>
      ))}
    </div>
  );
}

export default function Sidebar() {
  const pathname = usePathname();
  const router = useRouter();
  const { user } = useAuth();

  const handleSignOut = async () => {
    try {
      await signOut(auth);
      router.push("/login");
    } catch (error) {
      console.error("Failed to sign out", error);
    }
  };

  return (
    <aside
      className="fixed left-0 top-0 h-full flex flex-col bg-white dark:bg-slate-900 border-r border-slate-200 dark:border-slate-800 shadow-sm z-40 transition-colors duration-200"
      style={{ width: "var(--sidebar-width, 260px)" }}
    >
      {/* Logo */}
      <div className="flex items-center gap-3 px-6 py-5 border-b border-slate-100 dark:border-slate-800">
        <div className="w-9 h-9 rounded-xl flex items-center justify-center bg-sky-500 shadow-sm">
          <Ear className="w-5 h-5 text-white" />
        </div>
        <div>
          <p className="font-bold text-sm text-slate-900 dark:text-slate-100 tracking-wide">Baalshravya</p>
          <p className="text-[10px] text-slate-500 dark:text-slate-400 tracking-widest uppercase font-medium">Admin Portal</p>
        </div>
      </div>

      {/* Nav Items */}
      <nav className="flex-1 px-3 py-4 space-y-1 overflow-y-auto">
        <p className="px-3 mb-2 text-[10px] text-slate-400 dark:text-slate-500 uppercase tracking-widest font-semibold">
          Navigation
        </p>
        {navItems.map(({ href, icon: Icon, label }) => {
          const isActive = pathname === href || (href !== "/" && pathname.startsWith(href));
          return (
            <Link
              key={href}
              href={href}
              className={cn(
                "flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-all duration-200 group",
                isActive
                  ? "bg-sky-50 dark:bg-sky-500/10 text-sky-700 dark:text-sky-400"
                  : "text-slate-600 dark:text-slate-400 hover:text-slate-900 dark:hover:text-slate-100 hover:bg-slate-50 dark:hover:bg-slate-800"
              )}
            >
              <Icon className={cn("w-4 h-4 flex-shrink-0 transition-colors", isActive ? "text-sky-600 dark:text-sky-400" : "text-slate-400 dark:text-slate-500 group-hover:text-slate-600 dark:group-hover:text-slate-300")} />
              {label}
            </Link>
          );
        })}
      </nav>

      {/* Database sync indicator */}
      <div className="mx-3 mb-3 px-3 py-2.5 rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 flex items-center gap-2">
        <RefreshCw className="w-3.5 h-3.5 text-slate-400 flex-shrink-0" />
        <div className="min-w-0">
          <p className="text-[10px] text-slate-700 dark:text-slate-300 font-semibold">Neon PostgreSQL</p>
          <p className="text-[9px] text-slate-500 dark:text-slate-500 truncate">Analytics DB connected</p>
        </div>
        <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 flex-shrink-0" />
      </div>

      {/* Theme Toggle */}
      <div className="px-3 mb-3">
        <p className="px-1 mb-1.5 text-[10px] text-slate-400 dark:text-slate-500 uppercase tracking-widest font-semibold">Appearance</p>
        <ThemeToggle />
      </div>

      {/* Bottom — Sign out */}
      <div className="px-3 pb-4 border-t border-slate-100 dark:border-slate-800 pt-3">
        <div className="flex items-center gap-3 px-3 py-2 mb-1">
          <div className="w-8 h-8 rounded-full flex items-center justify-center text-xs font-bold text-white uppercase bg-slate-800 dark:bg-slate-600 shadow-sm">
            {user?.email?.[0] || "A"}
          </div>
          <div className="min-w-0 flex-1">
            <p className="text-sm font-semibold text-slate-900 dark:text-slate-100 truncate">{user?.email || "Admin"}</p>
            <p className="text-[10px] text-slate-500 dark:text-slate-400 truncate font-medium">District Officer</p>
          </div>
        </div>
        <button
          onClick={handleSignOut}
          className="flex items-center gap-2 w-full px-3 py-2 rounded-xl text-sm font-medium text-slate-500 dark:text-slate-400 hover:text-rose-600 dark:hover:text-rose-400 hover:bg-rose-50 dark:hover:bg-rose-500/10 transition-all duration-200"
        >
          <LogOut className="w-4 h-4" />
          Sign out
        </button>
      </div>
    </aside>
  );
}
