import { useEffect, useMemo, useState } from "react";
import { getAdminAudit, getAdminSummary, getAllAdminLoans } from "../../services/adminApi";
import type { AdminLoanRow, AdminSummary } from "../../models/admin";
import { formatCompact, formatDate, formatNaira } from "../../utils/format";

type ActivityItem = { id: string; text: string; time: string; tone: "ok" | "warn" | "bad" };

export default function DashboardPage() {
  const [summary, setSummary] = useState<AdminSummary | null>(null);
  const [loans, setLoans] = useState<AdminLoanRow[]>([]);
  const [loansTruncated, setLoansTruncated] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [activity, setActivity] = useState<ActivityItem[]>([]);

  useEffect(() => {
    let cancelled = false;
    (async () => {
      setLoading(true);
      setError(null);
      try {
        const [s, loanRows, audit] = await Promise.all([
          getAdminSummary(),
          getAllAdminLoans(),
          getAdminAudit({ limit: 15 })
        ]);
        if (cancelled) return;
        setSummary(s);
        setLoans(loanRows);
        setLoansTruncated(false);

        const auditLines: ActivityItem[] = audit.items.map(
          (a): ActivityItem => ({
            id: a.id,
            text: `${a.action} · ${a.resource}`,
            time: formatDate(a.createdAt),
            tone: "ok"
          })
        );

        const merged: ActivityItem[] = [
          ...auditLines,
          {
            id: "m1",
            text: "User requested ₦50,000 loan (pending review)",
            time: "Just now",
            tone: "warn" as const
          },
          {
            id: "m2",
            text: "Grant campaign published — Education category",
            time: "12 min ago",
            tone: "ok" as const
          },
          {
            id: "m3",
            text: "Loan fully repaid — principal cleared",
            time: "48 min ago",
            tone: "ok" as const
          }
        ];
        setActivity(merged.slice(0, 8));
      } catch (e) {
        if (!cancelled) setError(e instanceof Error ? e.message : "Failed to load dashboard");
      } finally {
        if (!cancelled) setLoading(false);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, []);

  const stats = useMemo(() => {
    const totalLent = loans
      .filter((l) => l.status === "funded" || l.status === "repaid")
      .reduce((s, l) => s + l.amount, 0);
    const totalRepaid = loans.reduce((s, l) => s + l.repaidAmount, 0);
    const pendingVol = loans.filter((l) => l.status === "pending").reduce((s, l) => s + l.amount, 0);
    const fundedVol = loans.filter((l) => l.status === "funded").reduce((s, l) => s + l.amount, 0);
    return {
      totalLent,
      totalRepaid,
      pendingVol,
      fundedVol,
      loanCount: loans.length
    };
  }, [loans]);

  const chartBars = useMemo(
    () => [
      { label: "Jan", req: 12, fund: 9 },
      { label: "Feb", req: 15, fund: 11 },
      { label: "Mar", req: 18, fund: 14 },
      { label: "Apr", req: 14, fund: 12 },
      { label: "May", req: 22, fund: 18 },
      { label: "Jun", req: 19, fund: 16 }
    ],
    []
  );
  const maxBar = Math.max(...chartBars.map((b) => Math.max(b.req, b.fund)), 1);

  if (loading) {
    return (
      <div className="rounded-2xl border border-runme-border bg-runme-card p-8 text-runme-muted">
        Loading dashboard…
      </div>
    );
  }

  if (error) {
    return (
      <div className="rounded-2xl border border-runme-danger/40 bg-runme-danger/5 p-6 text-sm text-runme-danger">
        {error}
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold tracking-tight text-white">Dashboard</h1>
        <p className="mt-1 text-sm text-runme-muted">Platform health overview · {summary ? formatDate(summary.generatedAt) : ""}</p>
      </div>

      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <StatCard
          title="Total users"
          value={summary ? String(summary.usersCount) : "—"}
          hint="Registered accounts"
          accent
        />
        <StatCard
          title="Total loans"
          value={`${stats.loanCount}${loansTruncated ? "+" : ""}`}
          hint="Rows loaded for stats"
        />
        <StatCard
          title="Total money lent"
          value={formatCompact(stats.totalLent)}
          hint="Funded + repaid principal"
          accent
        />
        <StatCard
          title="Total money repaid"
          value={formatCompact(stats.totalRepaid)}
          hint="Sum of repaid amounts"
        />
      </div>

      <div className="grid gap-6 lg:grid-cols-3">
        <div className="rounded-2xl border border-runme-border bg-runme-card p-5 shadow-card lg:col-span-2">
          <div className="mb-4 flex items-center justify-between">
            <h2 className="text-sm font-semibold uppercase tracking-wider text-runme-subtle">
              Loan requests vs funded
            </h2>
            <div className="flex gap-2 text-[10px] font-semibold uppercase">
              <span className="rounded-lg bg-runme-accent/15 px-2 py-1 text-runme-accent">Volume</span>
              <span className="rounded-lg px-2 py-1 text-runme-muted">Interest</span>
            </div>
          </div>
          <div className="flex h-48 items-end gap-2 border-b border-runme-border pb-2">
            {chartBars.map((b) => (
              <div key={b.label} className="flex flex-1 flex-col items-center gap-1">
                <div className="flex w-full flex-1 items-end justify-center gap-0.5">
                  <div
                    className="w-2/5 rounded-t bg-white/10"
                    style={{ height: `${(b.req / maxBar) * 100}%`, minHeight: "8%" }}
                    title={`Requested ${b.req}`}
                  />
                  <div
                    className="w-2/5 rounded-t bg-runme-accent/90"
                    style={{ height: `${(b.fund / maxBar) * 100}%`, minHeight: "8%" }}
                    title={`Funded ${b.fund}`}
                  />
                </div>
                <span className="text-[10px] text-runme-muted">{b.label}</span>
              </div>
            ))}
          </div>
          <p className="mt-3 text-xs text-runme-muted">
            Illustrative trend — connect analytics warehouse for live series.
          </p>
        </div>

        <div className="rounded-2xl border border-runme-danger/30 bg-runme-danger/[0.06] p-5 shadow-card">
          <h2 className="text-sm font-semibold uppercase tracking-wider text-runme-danger">
            Critical alerts (3)
          </h2>
          <ul className="mt-4 space-y-3 text-sm">
            <li className="border-b border-white/5 pb-3">
              <p className="font-medium text-white">Failed payments</p>
              <p className="mt-1 text-xs text-runme-subtle">3 settlements stuck in pending &gt; 24h</p>
              <button type="button" className="mt-2 text-xs font-semibold text-runme-accent hover:underline">
                View queue
              </button>
            </li>
            <li className="border-b border-white/5 pb-3">
              <p className="font-medium text-white">Suspicious activity</p>
              <p className="mt-1 text-xs text-runme-subtle">Rapid withdrawals to unverified wallets</p>
              <button type="button" className="mt-2 text-xs font-semibold text-runme-accent hover:underline">
                Open fraud monitor
              </button>
            </li>
            <li>
              <p className="font-medium text-white">Identity spoofing</p>
              <p className="mt-1 text-xs text-runme-subtle">Multi-entry login from new device cluster</p>
              <button type="button" className="mt-2 text-xs font-semibold text-runme-accent hover:underline">
                Secure account
              </button>
            </li>
          </ul>
        </div>
      </div>

      <div className="rounded-2xl border border-runme-border bg-runme-card p-5 shadow-card">
        <h2 className="text-sm font-semibold uppercase tracking-wider text-runme-subtle">Recent activity</h2>
        <ul className="mt-4 divide-y divide-runme-border">
          {activity.map((a) => (
            <li key={a.id} className="flex flex-wrap items-start justify-between gap-2 py-3 text-sm">
              <span
                className={
                  a.tone === "bad"
                    ? "text-runme-danger"
                    : a.tone === "warn"
                      ? "text-runme-warning"
                      : "text-neutral-200"
                }
              >
                {a.text}
              </span>
              <span className="text-xs text-runme-muted">{a.time}</span>
            </li>
          ))}
        </ul>
      </div>

      <div className="grid gap-4 md:grid-cols-2">
        <div className="rounded-2xl border border-runme-border bg-runme-raised/50 p-4">
          <p className="text-xs font-semibold uppercase text-runme-muted">Daily transactions</p>
          <p className="mt-2 text-2xl font-bold text-white">{formatNaira(stats.pendingVol + stats.fundedVol * 0.02)}</p>
          <p className="text-xs text-runme-muted">Proxy from pending + fee estimate (demo)</p>
        </div>
        <div className="rounded-2xl border border-runme-border bg-runme-raised/50 p-4">
          <p className="text-xs font-semibold uppercase text-runme-muted">Pipeline</p>
          <p className="mt-2 text-sm text-runme-subtle">
            Pending volume {formatCompact(stats.pendingVol)} · Active funded {formatCompact(stats.fundedVol)}
          </p>
        </div>
      </div>
    </div>
  );
}

function StatCard({
  title,
  value,
  hint,
  accent
}: {
  title: string;
  value: string;
  hint: string;
  accent?: boolean;
}) {
  return (
    <div
      className={[
        "rounded-2xl border p-5 shadow-card",
        accent ? "border-runme-accent/25 bg-runme-glow" : "border-runme-border bg-runme-card"
      ].join(" ")}
    >
      <p className="text-xs font-semibold uppercase tracking-wider text-runme-muted">{title}</p>
      <p className="mt-3 text-3xl font-bold tabular-nums text-white">{value}</p>
      <p className="mt-2 text-xs text-runme-subtle">{hint}</p>
    </div>
  );
}
