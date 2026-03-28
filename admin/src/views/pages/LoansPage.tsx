import { useEffect, useMemo, useState } from "react";
import type { ReactNode } from "react";
import { Link, useLocation, useParams } from "react-router-dom";
import { getAdminLoans } from "../../services/adminApi";
import type { AdminLoanRow } from "../../models/admin";
import { formatDate, formatNaira } from "../../utils/format";

const statuses = ["all", "pending", "funded", "repaid"] as const;

export default function LoansPage() {
  const [items, setItems] = useState<AdminLoanRow[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [status, setStatus] = useState<(typeof statuses)[number]>("all");
  const [minAmt, setMinAmt] = useState("");
  const [maxAmt, setMaxAmt] = useState("");

  useEffect(() => {
    let c = false;
    (async () => {
      setLoading(true);
      try {
        const res = await getAdminLoans({ limit: 200 });
        if (!c) setItems(res.items);
      } catch (e) {
        if (!c) setError(e instanceof Error ? e.message : "Failed to load loans");
      } finally {
        if (!c) setLoading(false);
      }
    })();
    return () => {
      c = true;
    };
  }, []);

  const filtered = useMemo(() => {
    const min = minAmt ? Number(minAmt) : null;
    const max = maxAmt ? Number(maxAmt) : null;
    return items.filter((l) => {
      if (status !== "all" && l.status !== status) return false;
      if (min !== null && !Number.isNaN(min) && l.amount < min) return false;
      if (max !== null && !Number.isNaN(max) && l.amount > max) return false;
      return true;
    });
  }, [items, status, minAmt, maxAmt]);

  if (loading) return <p className="text-runme-muted">Loading loans…</p>;
  if (error) return <p className="text-runme-danger">{error}</p>;

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-white">Loans</h1>
        <p className="mt-1 text-sm text-runme-muted">Monitor and control the lending pipeline</p>
      </div>

      <div className="flex flex-wrap items-end gap-3 rounded-2xl border border-runme-border bg-runme-card p-4">
        <div>
          <label className="mb-1 block text-xs font-semibold uppercase text-runme-muted">Status</label>
          <select
            value={status}
            onChange={(e) => setStatus(e.target.value as (typeof statuses)[number])}
            className="rounded-xl border border-runme-border bg-runme-raised px-3 py-2 text-sm text-white"
          >
            {statuses.map((s) => (
              <option key={s} value={s}>
                {s}
              </option>
            ))}
          </select>
        </div>
        <div>
          <label className="mb-1 block text-xs font-semibold uppercase text-runme-muted">Min ₦</label>
          <input
            type="number"
            value={minAmt}
            onChange={(e) => setMinAmt(e.target.value)}
            className="w-32 rounded-xl border border-runme-border bg-runme-raised px-3 py-2 text-sm text-white"
            placeholder="0"
          />
        </div>
        <div>
          <label className="mb-1 block text-xs font-semibold uppercase text-runme-muted">Max ₦</label>
          <input
            type="number"
            value={maxAmt}
            onChange={(e) => setMaxAmt(e.target.value)}
            className="w-32 rounded-xl border border-runme-border bg-runme-raised px-3 py-2 text-sm text-white"
            placeholder="∞"
          />
        </div>
      </div>

      <div className="overflow-hidden rounded-2xl border border-runme-border bg-runme-card shadow-card">
        <table className="w-full text-left text-sm">
          <thead className="border-b border-runme-border bg-runme-raised/80 text-xs font-semibold uppercase text-runme-muted">
            <tr>
              <th className="px-4 py-3">Borrower</th>
              <th className="px-4 py-3">Amount</th>
              <th className="px-4 py-3">Status</th>
              <th className="px-4 py-3">Duration</th>
              <th className="px-4 py-3">Funded %</th>
              <th className="px-4 py-3 text-right">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-runme-border">
            {filtered.map((l) => {
              const pct =
                l.status === "repaid"
                  ? 100
                  : l.amount > 0
                    ? Math.min(100, Math.round((l.repaidAmount / l.amount) * 100))
                    : 0;
              return (
                <tr key={l.id} className="hover:bg-white/[0.02]">
                  <td className="px-4 py-3 font-mono text-xs text-runme-subtle">{l.borrowerId.slice(0, 8)}…</td>
                  <td className="px-4 py-3 text-white">{formatNaira(l.amount)}</td>
                  <td className="px-4 py-3">
                    <StatusPill status={l.status} />
                  </td>
                  <td className="px-4 py-3 text-runme-subtle">{l.durationDays} days</td>
                  <td className="px-4 py-3">
                    <div className="flex items-center gap-2">
                      <div className="h-1.5 w-20 overflow-hidden rounded-full bg-white/10">
                        <div
                          className="h-full bg-runme-accent"
                          style={{ width: `${pct}%` }}
                        />
                      </div>
                      <span className="text-xs text-runme-muted">{pct}%</span>
                    </div>
                  </td>
                  <td className="px-4 py-3 text-right">
                    <Link
                      to={`/loans/${l.id}`}
                      state={{ loan: l }}
                      className="text-xs font-semibold text-runme-accent hover:underline"
                    >
                      View
                    </Link>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
}

function StatusPill({ status }: { status: string }) {
  const map: Record<string, string> = {
    pending: "bg-runme-warning/20 text-runme-warning",
    funded: "bg-runme-accent/15 text-runme-accent",
    repaid: "bg-emerald-500/15 text-emerald-400",
    defaulted: "bg-runme-danger/20 text-runme-danger"
  };
  return (
    <span
      className={`rounded-full px-2 py-0.5 text-xs font-medium ${map[status] ?? "bg-white/10 text-runme-subtle"}`}
    >
      {status}
    </span>
  );
}

export function LoanDetailPage() {
  const { loanId } = useParams();
  const location = useLocation();
  const st = location.state as { loan?: AdminLoanRow } | undefined;
  const [loan, setLoan] = useState<AdminLoanRow | null>(st?.loan ?? null);
  const [loading, setLoading] = useState(!st?.loan);

  useEffect(() => {
    if (st?.loan || !loanId) return;
    let c = false;
    (async () => {
      try {
        const res = await getAdminLoans({ limit: 500 });
        const found = res.items.find((x) => x.id === loanId);
        if (!c) setLoan(found ?? null);
      } finally {
        if (!c) setLoading(false);
      }
    })();
    return () => {
      c = true;
    };
  }, [loanId, st?.loan]);

  useEffect(() => {
    if (st?.loan) setLoading(false);
  }, [st?.loan]);

  if (loading) return <p className="text-runme-muted">Loading loan…</p>;
  if (!loan) {
    return (
      <div>
        <Link to="/loans" className="text-runme-accent hover:underline">
          ← Loans
        </Link>
        <p className="mt-4 text-runme-muted">Loan not found.</p>
      </div>
    );
  }

  const fundedPct =
    loan.amount > 0 ? Math.min(100, Math.round((loan.repaidAmount / loan.amount) * 100)) : 0;

  return (
    <div className="mx-auto max-w-3xl space-y-6">
      <Link to="/loans" className="text-sm text-runme-accent hover:underline">
        ← Loans
      </Link>
      <div className="rounded-2xl border border-runme-border bg-runme-card p-6 shadow-card">
        <h1 className="text-2xl font-bold text-white">Loan {loan.id.slice(0, 8)}…</h1>
        <p className="mt-1 text-sm text-runme-muted">Created {formatDate(loan.createdAt)}</p>

        <div className="mt-6 grid gap-4 sm:grid-cols-2">
          <Field label="Borrower" value={loan.borrowerId} mono />
          <Field label="Amount" value={formatNaira(loan.amount)} />
          <Field label="Status" value={<StatusPill status={loan.status} />} />
          <Field label="Duration" value={`${loan.durationDays} days`} />
          <Field label="Purpose" value={loan.purpose} />
          <Field label="Audience" value={loan.audience} />
          <Field label="Repaid" value={formatNaira(loan.repaidAmount)} />
          <Field label="Funded %" value={`${fundedPct}%`} />
        </div>

        {loan.reason ? (
          <div className="mt-6">
            <p className="text-xs font-semibold uppercase text-runme-muted">Reason</p>
            <p className="mt-1 text-sm text-runme-subtle">{loan.reason}</p>
          </div>
        ) : null}

        <div className="mt-8 border-t border-runme-border pt-6">
          <h2 className="text-sm font-semibold uppercase text-runme-subtle">Lenders & schedule</h2>
          <p className="mt-2 text-sm text-runme-muted">
            Backer list and amortization schedule will appear when wired to `/loans/:id/backings` and repayment
            installments.
          </p>
        </div>

        <div className="mt-6 flex flex-wrap gap-2">
          <button
            type="button"
            className="rounded-xl border border-runme-border px-4 py-2 text-xs font-semibold uppercase text-runme-subtle hover:border-runme-accent/50 hover:text-white"
          >
            Flag suspicious
          </button>
          <button
            type="button"
            className="rounded-xl border border-runme-warning/40 px-4 py-2 text-xs font-semibold uppercase text-runme-warning hover:bg-runme-warning/10"
          >
            Mark defaulted
          </button>
          <button
            type="button"
            className="rounded-xl bg-runme-accent/20 px-4 py-2 text-xs font-semibold uppercase text-runme-accent hover:bg-runme-accent/30"
          >
            Approve / reject
          </button>
        </div>
      </div>
    </div>
  );
}

function Field({
  label,
  value,
  mono
}: {
  label: string;
  value: ReactNode;
  mono?: boolean;
}) {
  return (
    <div className="rounded-xl border border-runme-border bg-runme-raised/50 p-3">
      <p className="text-[10px] font-semibold uppercase text-runme-muted">{label}</p>
      <div className={`mt-1 text-sm text-white ${mono ? "font-mono text-xs" : ""}`}>{value}</div>
    </div>
  );
}
