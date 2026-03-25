import type React from "react";
import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { login, type LoginRequest } from "../services/auth";
import { apiFetch } from "../services/api";

type MeResponse = {
  id: string;
  email: string;
  role: string;
  createdAt: string;
};

export default function LoginPage() {
  const navigate = useNavigate();
  const [form, setForm] = useState<LoginRequest>({ email: "", password: "" });
  const [error, setError] = useState<string | null>(null);
  const [me, setMe] = useState<MeResponse | null>(null);
  const [loading, setLoading] = useState(false);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    setLoading(true);

    try {
      const { accessToken } = await login(form);
      localStorage.setItem("accessToken", accessToken);
      const profile = await apiFetch<MeResponse>("/me", { method: "GET", auth: true });
      setMe(profile);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Login failed");
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="min-h-screen bg-slate-50 p-6">
      <div className="mx-auto max-w-md rounded-xl border bg-white p-6">
        <div className="flex items-center justify-between">
          <h1 className="text-xl font-semibold">Login</h1>
          <button
            className="text-sm text-slate-600 hover:underline"
            onClick={() => navigate("/")}
            type="button"
          >
            Back
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
            disabled={loading}
            className="w-full rounded-lg bg-slate-900 px-4 py-2 font-medium text-white disabled:opacity-50"
            type="submit"
          >
            {loading ? "Logging in..." : "Login"}
          </button>
        </form>

        {me ? (
          <div className="mt-6 rounded-lg bg-slate-50 p-4">
            <p className="text-sm text-slate-600">Logged in as</p>
            <p className="font-medium">{me.email}</p>
            <p className="text-sm text-slate-600">Role: {me.role}</p>
          </div>
        ) : null}
      </div>
    </div>
  );
}

