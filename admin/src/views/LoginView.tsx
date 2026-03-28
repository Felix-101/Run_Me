import type React from "react";
import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { useAuthViewModel } from "../viewModels/authViewModel";
import type { LoginRequest } from "../models/auth";

export default function LoginView() {
  const navigate = useNavigate();
  const auth = useAuthViewModel();
  const [form, setForm] = useState<LoginRequest>({ email: "", password: "" });
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (auth.accessToken) {
      auth.fetchMe().catch(() => null);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);

    try {
      await auth.login(form);
      await auth.fetchMe();
      navigate("/", { replace: true });
    } catch (err) {
      setError(err instanceof Error ? err.message : "Login failed");
    }
  }

  return (
    <div className="flex min-h-screen items-center justify-center bg-runme-bg p-6">
      <div className="w-full max-w-md rounded-2xl border border-runme-border bg-runme-card p-8 shadow-card">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-lg font-bold text-white">
              RUN<span className="text-runme-accent">ME</span>
            </p>
            <p className="text-xs font-semibold uppercase tracking-widest text-runme-muted">Lending Admin</p>
          </div>
          <button
            type="button"
            className="text-xs text-runme-muted hover:text-runme-accent"
            onClick={() => navigate("/not-authorized")}
          >
            Help
          </button>
        </div>

        <h1 className="mt-6 text-xl font-semibold text-white">Sign in</h1>
        <p className="mt-1 text-sm text-runme-muted">Admin role required</p>

        <form className="mt-6 space-y-4" onSubmit={onSubmit}>
          <div>
            <label className="mb-1 block text-xs font-semibold uppercase text-runme-muted">Email</label>
            <input
              className="w-full rounded-xl border border-runme-border bg-runme-raised px-3 py-2.5 text-sm text-white placeholder:text-runme-muted focus:border-runme-accent/50 focus:outline-none focus:ring-1 focus:ring-runme-accent/30"
              value={form.email}
              onChange={(e) => setForm((f) => ({ ...f, email: e.target.value }))}
              type="email"
              required
              autoComplete="username"
            />
          </div>
          <div>
            <label className="mb-1 block text-xs font-semibold uppercase text-runme-muted">Password</label>
            <input
              className="w-full rounded-xl border border-runme-border bg-runme-raised px-3 py-2.5 text-sm text-white placeholder:text-runme-muted focus:border-runme-accent/50 focus:outline-none focus:ring-1 focus:ring-runme-accent/30"
              value={form.password}
              onChange={(e) => setForm((f) => ({ ...f, password: e.target.value }))}
              type="password"
              required
              autoComplete="current-password"
            />
          </div>

          {error ? <p className="text-sm text-runme-danger">{error}</p> : null}

          <button
            className="w-full rounded-xl bg-runme-accent py-2.5 text-sm font-semibold text-black hover:bg-runme-accent-hover disabled:opacity-50"
            type="submit"
          >
            Sign in
          </button>
        </form>

        {auth.error ? <p className="mt-4 text-sm text-runme-danger">{auth.error}</p> : null}
      </div>
    </div>
  );
}
