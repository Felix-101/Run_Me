import { useMemo, useState } from "react";
import { MOCK_TRANSACTIONS } from "../../data/mockTransactions";
import type { TransactionRow } from "../../models/admin";
import { formatDate, formatNaira } from "../../utils/format";

const types = ["all", "Deposit", "Withdrawal", "Loan", "Grant", "Repayment"] as const;
const stat = ["all", "Success", "Failed", "Pending"] as const;

export default function TransactionsPage() {
  const [type, setType] = useState<(typeof types)[number]>("all");
  const [status, setStatus] = useState<(typeof stat)[number]>("all");
  const [from, setFrom] = useState("");
  const [to, setTo] = useState("");

  const filtered = useMemo(() => {
    return MOCK_TRANSACTIONS.filter((t) => {
      if (type !== "all" && t.type !== type) return false;
      if (status !== "all" && t.status !== status) return false;
      if (from && new Date(t.createdAt) < new Date(from)) return false;
      if (to && new Date(t.createdAt) > new Date(to)) return false;
      return true;
    });
  }, [type, status, from, to]);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-white">Transactions</h1>
        <p className="mt-1 text-sm text-runme-muted">Money movement ledger (demo rows until API ships)</p>
      </div>

      <div className="flex flex-wrap items-end gap-3 rounded-2xl border border-runme-border bg-runme-card p-4">
        <div>
          <label className="mb-1 block text-xs font-semibold uppercase text-runme-muted">Type</label>
          <select
            value={type}
            onChange={(e) => setType(e.target.value as (typeof types)[number])}
            className="rounded-xl border border-runme-border bg-runme-raised px-3 py-2 text-sm text-white"
          >
            {types.map((x) => (
              <option key={x} value={x}>
                {x}
              </option>
            ))}
          </select>
        </div>
        <div>
          <label className="mb-1 block text-xs font-semibold uppercase text-runme-muted">Status</label>
          <select
            value={status}
            onChange={(e) => setStatus(e.target.value as (typeof stat)[number])}
            className="rounded-xl border border-runme-border bg-runme-raised px-3 py-2 text-sm text-white"
          >
            {stat.map((x) => (
              <option key={x} value={x}>
                {x}
              </option>
            ))}
          </select>
        </div>
        <div>
          <label className="mb-1 block text-xs font-semibold uppercase text-runme-muted">From</label>
          <input
            type="datetime-local"
            value={from}
            onChange={(e) => setFrom(e.target.value)}
            className="rounded-xl border border-runme-border bg-runme-raised px-3 py-2 text-sm text-white"
          />
        </div>
        <div>
          <label className="mb-1 block text-xs font-semibold uppercase text-runme-muted">To</label>
          <input
            type="datetime-local"
            value={to}
            onChange={(e) => setTo(e.target.value)}
            className="rounded-xl border border-runme-border bg-runme-raised px-3 py-2 text-sm text-white"
          />
        </div>
      </div>

      <div className="overflow-hidden rounded-2xl border border-runme-border bg-runme-card shadow-card">
        <table className="w-full text-left text-sm">
          <thead className="border-b border-runme-border bg-runme-raised/80 text-xs font-semibold uppercase text-runme-muted">
            <tr>
              <th className="px-4 py-3">User</th>
              <th className="px-4 py-3">Type</th>
              <th className="px-4 py-3">Amount</th>
              <th className="px-4 py-3">Status</th>
              <th className="px-4 py-3">Date</th>
              <th className="px-4 py-3 text-right">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-runme-border">
            {filtered.map((t) => (
              <tr key={t.id} className="hover:bg-white/[0.02]">
                <td className="px-4 py-3 text-white">{t.userLabel}</td>
                <td className="px-4 py-3 text-runme-subtle">{t.type}</td>
                <td className="px-4 py-3 tabular-nums text-white">{formatNaira(t.amount)}</td>
                <td className="px-4 py-3">
                  <TxStatus s={t.status} />
                </td>
                <td className="px-4 py-3 text-xs text-runme-muted">{formatDate(t.createdAt)}</td>
                <td className="px-4 py-3 text-right">
                  <button
                    type="button"
                    className="text-xs font-semibold text-runme-accent hover:underline"
                  >
                    Details
                  </button>
                  {t.status === "Failed" ? (
                    <button
                      type="button"
                      className="ml-2 text-xs font-semibold text-runme-warning hover:underline"
                    >
                      Retry
                    </button>
                  ) : null}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

function TxStatus({ s }: { s: TransactionRow["status"] }) {
  const cls =
    s === "Success"
      ? "bg-emerald-500/15 text-emerald-400"
      : s === "Failed"
        ? "bg-runme-danger/20 text-runme-danger"
        : "bg-runme-warning/15 text-runme-warning";
  return <span className={`rounded-full px-2 py-0.5 text-xs font-medium ${cls}`}>{s}</span>;
}
