import { useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { useAdminViewModel } from "../viewModels/adminViewModel";
import { useAuthViewModel } from "../viewModels/authViewModel";

export default function DashboardView() {
  const admin = useAdminViewModel();
  const auth = useAuthViewModel();
  const navigate = useNavigate();

  useEffect(() => {
    admin.fetchSummary().catch(() => null);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return (
    <div className="min-h-screen bg-slate-50 p-6">
      <div className="mx-auto max-w-4xl">
        <div className="flex items-start justify-between">
          <div>
            <h1 className="text-2xl font-semibold">Admin Dashboard</h1>
            <p className="mt-1 text-slate-600">Protected by JWT + admin role.</p>
          </div>
          <div className="flex gap-2">
            <button
              className="rounded-lg border bg-white px-3 py-2 text-sm"
              type="button"
              onClick={() => {
                auth.logout();
                navigate("/login");
              }}
            >
              Logout
            </button>
          </div>
        </div>

        {admin.status === "loading" ? (
          <div className="mt-6 rounded-xl border bg-white p-6">Loading summary...</div>
        ) : null}

        {admin.error ? (
          <div className="mt-6 rounded-xl border border-red-200 bg-white p-6">
            <p className="text-sm text-red-700">{admin.error}</p>
          </div>
        ) : null}

        {admin.summary ? (
          <div className="mt-6 grid gap-4 lg:grid-cols-2">
            <div className="rounded-xl border bg-white p-6">
              <p className="text-sm text-slate-600">Total users</p>
              <p className="mt-2 text-3xl font-semibold">{admin.summary.usersCount}</p>
            </div>
            <div className="rounded-xl border bg-white p-6">
              <p className="text-sm text-slate-600">Generated at</p>
              <p className="mt-2 text-sm text-slate-900">{admin.summary.generatedAt}</p>
            </div>
          </div>
        ) : null}
      </div>
    </div>
  );
}

