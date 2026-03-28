import { NavLink, Outlet, useNavigate } from "react-router-dom";
import { useAuthViewModel } from "../viewModels/authViewModel";

const nav = [
  { to: "/", label: "Dashboard", end: true, icon: "◆" },
  { to: "/users", label: "Users", end: false, icon: "◎" },
  { to: "/loans", label: "Loans", end: false, icon: "◇" },
  { to: "/transactions", label: "Transactions", end: false, icon: "▣" },
  { to: "/grants", label: "Grants", end: false, icon: "✦" },
  { to: "/settings", label: "Settings", end: false, icon: "⚙" }
] as const;

export default function AdminLayout() {
  const auth = useAuthViewModel();
  const navigate = useNavigate();

  return (
    <div className="flex min-h-screen bg-runme-bg">
      <aside className="flex w-60 flex-col border-r border-runme-border bg-runme-surface">
        <div className="border-b border-runme-border px-5 py-6">
          <p className="text-lg font-bold tracking-tight text-white">
            RUN<span className="text-runme-accent">ME</span>
          </p>
          <p className="mt-0.5 text-[10px] font-semibold uppercase tracking-[0.2em] text-runme-muted">
            Lending Admin
          </p>
        </div>

        <nav className="flex flex-1 flex-col gap-0.5 p-3">
          {nav.map((item) => (
            <NavLink
              key={item.to}
              to={item.to}
              end={item.end}
              className={({ isActive }) =>
                [
                  "flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-medium transition-colors",
                  isActive
                    ? "bg-runme-glow text-runme-accent shadow-neon"
                    : "text-runme-subtle hover:bg-white/5 hover:text-white"
                ].join(" ")
              }
            >
              <span className="w-5 text-center text-xs opacity-80">{item.icon}</span>
              {item.label}
            </NavLink>
          ))}
        </nav>

        <div className="border-t border-runme-border p-4">
          <div className="mb-3 inline-flex items-center gap-2 rounded-full border border-runme-accent/30 bg-runme-accent/10 px-3 py-1 text-[10px] font-semibold uppercase tracking-wider text-runme-accent">
            <span className="h-1.5 w-1.5 animate-pulse rounded-full bg-runme-accent" />
            System: Active
          </div>
          <button
            type="button"
            className="w-full rounded-xl border border-runme-border px-3 py-2 text-left text-sm text-runme-subtle transition hover:border-runme-accent/40 hover:text-white"
            onClick={() => {
              auth.logout();
              navigate("/login");
            }}
          >
            Log out
          </button>
        </div>
      </aside>

      <div className="flex min-w-0 flex-1 flex-col">
        <header className="flex flex-wrap items-center gap-4 border-b border-runme-border bg-runme-bg/90 px-6 py-4 backdrop-blur">
          <div className="min-w-[200px] flex-1">
            <input
              type="search"
              placeholder="Search system entities…"
              className="w-full max-w-xl rounded-xl border border-runme-border bg-runme-card px-4 py-2.5 text-sm text-white placeholder:text-runme-muted focus:border-runme-accent/50 focus:outline-none focus:ring-1 focus:ring-runme-accent/30"
            />
          </div>
          <div className="flex flex-wrap items-center gap-2">
            <span className="hidden text-xs text-runme-muted sm:inline">Dashboard</span>
            <span className="hidden text-runme-border sm:inline">|</span>
            <span className="hidden text-xs text-runme-muted sm:inline">System Logs</span>
            <span className="hidden text-runme-border sm:inline">|</span>
            <span className="hidden text-xs text-runme-muted sm:inline">Fraud Monitor</span>
          </div>
          <div className="ml-auto flex items-center gap-2">
            <button
              type="button"
              className="rounded-xl border border-runme-danger/50 px-3 py-2 text-xs font-semibold uppercase tracking-wide text-runme-danger hover:bg-runme-danger/10"
            >
              Emergency lock
            </button>
            <button
              type="button"
              className="rounded-xl bg-runme-accent px-3 py-2 text-xs font-semibold uppercase tracking-wide text-black hover:bg-runme-accent-hover"
            >
              New admin
            </button>
            <button
              type="button"
              className="rounded-xl border border-runme-border p-2 text-runme-muted hover:text-white"
              aria-label="Notifications"
            >
              🔔
            </button>
            <div className="flex h-9 w-9 items-center justify-center rounded-full border border-runme-border bg-runme-raised text-xs font-semibold text-runme-accent">
              A
            </div>
          </div>
        </header>

        <main className="flex-1 overflow-auto p-6 scrollbar-thin">
          <Outlet />
        </main>
      </div>
    </div>
  );
}
