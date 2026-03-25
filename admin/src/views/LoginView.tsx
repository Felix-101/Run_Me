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
    // If the user already has a token, try to hydrate profile.
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
    <div className="min-h-screen bg-slate-50 p-6">
      <div className="mx-auto max-w-md rounded-xl border bg-white p-6">
        <div className="flex items-center justify-between">
          <h1 className="text-xl font-semibold">Admin Login</h1>
          <button
            type="button"
            className="text-sm text-slate-600 hover:underline"
            onClick={() => navigate("/not-authorized")}
          >
            Help
          </button>
        </div>

        <form className="mt-4 space-y-3" onSubmit={onSubmit}>
          <div>
            <label className="mb-1 block text-sm text-slate-700">Email</label>
            <input
              className="w-full rounded-lg border px-3 py-2"
              value={form.email}
              onChange={(e) => setForm((f) => ({ ...f, email: e.target.value }))}
              type="email"
              required
            />
          </div>
          <div>
            <label className="mb-1 block text-sm text-slate-700">Password</label>
            <input
              className="w-full rounded-lg border px-3 py-2"
              value={form.password}
              onChange={(e) => setForm((f) => ({ ...f, password: e.target.value }))}
              type="password"
              required
            />
          </div>

          {error ? <p className="text-sm text-red-600">{error}</p> : null}

          <button
            className="w-full rounded-lg bg-slate-900 px-4 py-2 font-medium text-white disabled:opacity-50"
            type="submit"
          >
            Sign in
          </button>
        </form>

        {auth.error ? <p className="mt-4 text-sm text-red-600">{auth.error}</p> : null}
      </div>
    </div>
  );
}

