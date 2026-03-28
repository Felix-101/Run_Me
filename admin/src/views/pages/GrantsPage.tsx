import { useEffect, useState } from "react";
import { Link, useLocation, useParams } from "react-router-dom";
import { getAdminGrants } from "../../services/adminApi";
import type { AdminGrantRow } from "../../models/admin";
import { formatDate, formatNaira } from "../../utils/format";

export default function GrantsPage() {
  const [items, setItems] = useState<AdminGrantRow[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let c = false;
    (async () => {
      try {
        const res = await getAdminGrants({ limit: 200 });
        if (!c) setItems(res.items);
      } catch (e) {
        if (!c) setError(e instanceof Error ? e.message : "Failed to load grants");
      } finally {
        if (!c) setLoading(false);
      }
    })();
    return () => {
      c = true;
    };
  }, []);

  if (loading) return <p className="text-runme-muted">Loading grants…</p>;
  if (error) return <p className="text-runme-danger">{error}</p>;

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-white">Grants</h1>
        <p className="mt-1 text-sm text-runme-muted">Moderate stories and donation campaigns</p>
      </div>

      <div className="overflow-hidden rounded-2xl border border-runme-border bg-runme-card shadow-card">
        <table className="w-full text-left text-sm">
          <thead className="border-b border-runme-border bg-runme-raised/80 text-xs font-semibold uppercase text-runme-muted">
            <tr>
              <th className="px-4 py-3">Requester</th>
              <th className="px-4 py-3">Title</th>
              <th className="px-4 py-3">Goal</th>
              <th className="px-4 py-3">Raised</th>
              <th className="px-4 py-3">Status</th>
              <th className="px-4 py-3 text-right">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-runme-border">
            {items.map((g) => {
              const pct = g.goalNaira > 0 ? Math.round((g.raisedNaira / g.goalNaira) * 100) : 0;
              const status = pct >= 100 ? "Funded" : g.isUrgent ? "Urgent" : "Active";
              return (
                <tr key={g.id} className="hover:bg-white/[0.02]">
                  <td className="px-4 py-3 font-mono text-xs text-runme-subtle">
                    {g.requesterId.slice(0, 8)}…
                  </td>
                  <td className="max-w-xs truncate px-4 py-3 text-white">{g.title}</td>
                  <td className="px-4 py-3">{formatNaira(g.goalNaira)}</td>
                  <td className="px-4 py-3">{formatNaira(g.raisedNaira)}</td>
                  <td className="px-4 py-3">
                    <span className="rounded-full bg-runme-accent/15 px-2 py-0.5 text-xs font-medium text-runme-accent">
                      {status}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-right">
                    <Link
                      to={`/grants/${g.id}`}
                      state={{ grant: g }}
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

export function GrantDetailPage() {
  const { grantId } = useParams();
  const location = useLocation();
  const st = location.state as { grant?: AdminGrantRow } | undefined;
  const [grant, setGrant] = useState<AdminGrantRow | null>(st?.grant ?? null);
  const [loading, setLoading] = useState(!st?.grant);

  useEffect(() => {
    if (st?.grant || !grantId) return;
    let c = false;
    (async () => {
      try {
        const res = await getAdminGrants({ limit: 500 });
        const found = res.items.find((x) => x.id === grantId);
        if (!c) setGrant(found ?? null);
      } finally {
        if (!c) setLoading(false);
      }
    })();
    return () => {
      c = true;
    };
  }, [grantId, st?.grant]);

  useEffect(() => {
    if (st?.grant) setLoading(false);
  }, [st?.grant]);

  if (loading) return <p className="text-runme-muted">Loading grant…</p>;
  if (!grant) {
    return (
      <div>
        <Link to="/grants" className="text-runme-accent hover:underline">
          ← Grants
        </Link>
        <p className="mt-4 text-runme-muted">Not found.</p>
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-3xl space-y-6">
      <Link to="/grants" className="text-sm text-runme-accent hover:underline">
        ← Grants
      </Link>
      <div className="rounded-2xl border border-runme-border bg-runme-card p-6 shadow-card">
        <div className="flex flex-wrap items-start justify-between gap-4">
          <div>
            <h1 className="text-2xl font-bold text-white">{grant.title}</h1>
            <p className="mt-1 text-sm text-runme-muted">
              {grant.studentName} · {grant.category} {grant.isUrgent ? "· Urgent" : ""}
            </p>
            <p className="mt-2 text-xs text-runme-muted">{formatDate(grant.createdAt)}</p>
          </div>
          <div className="text-right">
            <p className="text-xs uppercase text-runme-muted">Raised / Goal</p>
            <p className="text-lg font-bold text-runme-accent">
              {formatNaira(grant.raisedNaira)} / {formatNaira(grant.goalNaira)}
            </p>
          </div>
        </div>

        <div className="mt-6 rounded-xl border border-runme-border bg-runme-raised/40 p-4">
          <p className="text-xs font-semibold uppercase text-runme-muted">Story</p>
          <p className="mt-2 whitespace-pre-wrap text-sm leading-relaxed text-runme-subtle">{grant.story}</p>
        </div>

        {grant.attachmentUrls?.length ? (
          <div className="mt-4">
            <p className="text-xs font-semibold uppercase text-runme-muted">Media</p>
            <ul className="mt-2 space-y-1 text-sm text-runme-accent">
              {grant.attachmentUrls.map((u) => (
                <li key={u}>
                  <a href={u} target="_blank" rel="noreferrer" className="hover:underline">
                    {u}
                  </a>
                </li>
              ))}
            </ul>
          </div>
        ) : (
          <p className="mt-4 text-xs text-runme-muted">No media URLs on this grant.</p>
        )}

        <div className="mt-8 border-t border-runme-border pt-6">
          <p className="text-xs font-semibold uppercase text-runme-muted">Donors</p>
          <p className="mt-2 text-sm text-runme-muted">
            Donor list will load from `GET /grants/:id/donations` when wired in admin.
          </p>
        </div>

        <div className="mt-6 flex flex-wrap gap-2">
          <button
            type="button"
            className="rounded-xl bg-emerald-500/20 px-4 py-2 text-xs font-semibold uppercase text-emerald-400 hover:bg-emerald-500/30"
          >
            Approve
          </button>
          <button
            type="button"
            className="rounded-xl border border-runme-danger/50 px-4 py-2 text-xs font-semibold uppercase text-runme-danger hover:bg-runme-danger/10"
          >
            Reject
          </button>
          <button
            type="button"
            className="rounded-xl border border-runme-border px-4 py-2 text-xs font-semibold uppercase text-runme-subtle hover:border-runme-warning/50 hover:text-runme-warning"
          >
            Remove content
          </button>
        </div>
      </div>
    </div>
  );
}
