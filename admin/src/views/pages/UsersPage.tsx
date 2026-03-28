import { useEffect, useMemo, useState } from "react";
import { Link, useLocation, useParams } from "react-router-dom";
import { getAllAdminUsers } from "../../services/adminApi";
import type { AdminUserRow } from "../../models/admin";
import { formatDate } from "../../utils/format";

function pseudoTrust(id: string) {
  let h = 0;
  for (let i = 0; i < id.length; i++) h = (h * 31 + id.charCodeAt(i)) >>> 0;
  return 55 + (h % 45);
}

export default function UsersPage() {
  const [items, setItems] = useState<AdminUserRow[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [suspended, setSuspended] = useState<Record<string, boolean>>({});

  useEffect(() => {
    let c = false;
    (async () => {
      setLoading(true);
      try {
        const rows = await getAllAdminUsers();
        if (!c) setItems(rows);
      } catch (e) {
        if (!c) setError(e instanceof Error ? e.message : "Failed to load users");
      } finally {
        if (!c) setLoading(false);
      }
    })();
    return () => {
      c = true;
    };
  }, []);

  const rows = useMemo(() => items, [items]);

  if (loading) {
    return <p className="text-runme-muted">Loading users…</p>;
  }
  if (error) {
    return <p className="text-runme-danger">{error}</p>;
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-white">Users</h1>
        <p className="mt-1 text-sm text-runme-muted">Manage and monitor accounts · {rows.length} loaded</p>
      </div>

      <div className="overflow-hidden rounded-2xl border border-runme-border bg-runme-card shadow-card">
        <table className="w-full text-left text-sm">
          <thead className="border-b border-runme-border bg-runme-raised/80 text-xs font-semibold uppercase tracking-wider text-runme-muted">
            <tr>
              <th className="px-4 py-3">Name</th>
              <th className="px-4 py-3">Email</th>
              <th className="px-4 py-3">School</th>
              <th className="px-4 py-3">Trust</th>
              <th className="px-4 py-3">Status</th>
              <th className="px-4 py-3 text-right">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-runme-border">
            {rows.map((u) => {
              const trust = pseudoTrust(u.id);
              const isSuspended = suspended[u.id];
              return (
                <tr key={u.id} className="hover:bg-white/[0.02]">
                  <td className="px-4 py-3 font-medium text-white">
                    {u.displayName ?? u.email.split("@")[0]}
                  </td>
                  <td className="px-4 py-3 text-runme-subtle">{u.email}</td>
                  <td className="px-4 py-3 text-runme-subtle">{u.schoolName ?? "—"}</td>
                  <td className="px-4 py-3">
                    <div className="flex items-center gap-2">
                      <div className="h-1.5 w-24 overflow-hidden rounded-full bg-white/10">
                        <div
                          className="h-full rounded-full bg-runme-accent"
                          style={{ width: `${trust}%` }}
                        />
                      </div>
                      <span className="tabular-nums text-xs text-runme-subtle">{trust}%</span>
                    </div>
                  </td>
                  <td className="px-4 py-3">
                    <span
                      className={
                        isSuspended
                          ? "rounded-full bg-runme-danger/15 px-2 py-0.5 text-xs font-medium text-runme-danger"
                          : "rounded-full bg-runme-accent/15 px-2 py-0.5 text-xs font-medium text-runme-accent"
                      }
                    >
                      {isSuspended ? "Suspended" : "Active"}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-right">
                    <Link
                      to={`/users/${u.id}`}
                      state={{ user: u, trust }}
                      className="mr-2 text-xs font-semibold text-runme-accent hover:underline"
                    >
                      View
                    </Link>
                    <button
                      type="button"
                      className="text-xs font-semibold text-runme-subtle hover:text-white"
                      onClick={() =>
                        setSuspended((prev) => ({ ...prev, [u.id]: !prev[u.id] }))
                      }
                    >
                      {isSuspended ? "Activate" : "Suspend"}
                    </button>
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

export function UserDetailPage() {
  const { userId } = useParams();
  const location = useLocation();
  const fromState = location.state as { user?: AdminUserRow; trust?: number } | undefined;
  const [user, setUser] = useState<AdminUserRow | null>(fromState?.user ?? null);
  const [loading, setLoading] = useState(!fromState?.user);

  useEffect(() => {
    if (fromState?.user || !userId) return;
    let c = false;
    (async () => {
      try {
        const rows = await getAllAdminUsers();
        const found = rows.find((u) => u.id === userId);
        if (!c) setUser(found ?? null);
      } finally {
        if (!c) setLoading(false);
      }
    })();
    return () => {
      c = true;
    };
  }, [userId, fromState?.user]);

  useEffect(() => {
    if (fromState?.user) setLoading(false);
  }, [fromState?.user]);

  const trust = fromState?.trust ?? (user ? pseudoTrust(user.id) : 72);

  if (loading) {
    return <p className="text-runme-muted">Loading profile…</p>;
  }

  if (!user) {
    return (
      <div className="text-runme-muted">
        <p>User not found.</p>
        <Link to="/users" className="mt-2 inline-block text-runme-accent hover:underline">
          Back to users
        </Link>
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-3xl space-y-6">
      <Link to="/users" className="text-sm text-runme-accent hover:underline">
        ← Users
      </Link>
      <div className="rounded-2xl border border-runme-border bg-runme-card p-6 shadow-card">
        <h1 className="text-2xl font-bold text-white">{user.displayName ?? user.email}</h1>
        <p className="text-runme-subtle">{user.email}</p>
        <p className="mt-2 text-xs text-runme-muted">Joined {formatDate(user.createdAt)}</p>

        <div className="mt-6 grid gap-4 sm:grid-cols-2">
          <div className="rounded-xl border border-runme-border bg-runme-raised/50 p-4">
            <p className="text-xs font-semibold uppercase text-runme-muted">School</p>
            <p className="mt-1 text-white">{user.schoolName ?? "—"}</p>
          </div>
          <div className="rounded-xl border border-runme-border bg-runme-raised/50 p-4">
            <p className="text-xs font-semibold uppercase text-runme-muted">Verification</p>
            <p className="mt-1 text-white">{user.studentIdVerified ? "Verified" : "Unverified"}</p>
          </div>
          <div className="rounded-xl border border-runme-border bg-runme-raised/50 p-4">
            <p className="text-xs font-semibold uppercase text-runme-muted">Trust score (est.)</p>
            <p className="mt-1 text-2xl font-bold text-runme-accent">{trust}%</p>
            <button
              type="button"
              className="mt-2 text-xs font-semibold text-runme-subtle hover:text-runme-accent"
            >
              Manual override…
            </button>
          </div>
          <div className="rounded-xl border border-runme-border bg-runme-raised/50 p-4">
            <p className="text-xs font-semibold uppercase text-runme-muted">Role</p>
            <p className="mt-1 text-white">{user.role}</p>
          </div>
        </div>

        <div className="mt-8 space-y-4">
          <h2 className="text-sm font-semibold uppercase tracking-wider text-runme-subtle">Loan history</h2>
          <p className="text-sm text-runme-muted">
            Detailed history will appear when the admin API exposes per-user loans. Use the Loans section for now.
          </p>
          <h2 className="text-sm font-semibold uppercase tracking-wider text-runme-subtle">Transactions</h2>
          <p className="text-sm text-runme-muted">Ledger view is on the Transactions page (demo data).</p>
          <h2 className="text-sm font-semibold uppercase tracking-wider text-runme-subtle">Grants</h2>
          <p className="text-sm text-runme-muted">Grant activity will link here when donor/requester filters ship.</p>
        </div>
      </div>
    </div>
  );
}
