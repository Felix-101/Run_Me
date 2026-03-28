import { useState } from "react";

export default function SettingsPage() {
  const [platformName, setPlatformName] = useState("RunMe");
  const [currency, setCurrency] = useState("NGN");
  const [maxLoan, setMaxLoan] = useState("500000");
  const [maxDuration, setMaxDuration] = useState("365");
  const [interest, setInterest] = useState("0");
  const [sandbox, setSandbox] = useState(true);
  const [apiKey, setApiKey] = useState("");

  return (
    <div className="mx-auto max-w-3xl space-y-8">
      <div>
        <h1 className="text-2xl font-bold text-white">Settings</h1>
        <p className="mt-1 text-sm text-runme-muted">
          Platform configuration (local UI only — persist via API when backend supports it)
        </p>
      </div>

      <section className="rounded-2xl border border-runme-border bg-runme-card p-6 shadow-card">
        <h2 className="text-sm font-semibold uppercase tracking-wider text-runme-accent">General</h2>
        <div className="mt-4 space-y-4">
          <label className="block">
            <span className="text-xs font-semibold uppercase text-runme-muted">Platform name</span>
            <input
              value={platformName}
              onChange={(e) => setPlatformName(e.target.value)}
              className="mt-1 w-full rounded-xl border border-runme-border bg-runme-raised px-3 py-2 text-sm text-white"
            />
          </label>
          <label className="block">
            <span className="text-xs font-semibold uppercase text-runme-muted">Currency</span>
            <select
              value={currency}
              onChange={(e) => setCurrency(e.target.value)}
              className="mt-1 w-full rounded-xl border border-runme-border bg-runme-raised px-3 py-2 text-sm text-white"
            >
              <option value="NGN">₦ NGN</option>
              <option value="USD">USD (future)</option>
            </select>
          </label>
        </div>
      </section>

      <section className="rounded-2xl border border-runme-border bg-runme-card p-6 shadow-card">
        <h2 className="text-sm font-semibold uppercase tracking-wider text-runme-accent">Loan rules</h2>
        <div className="mt-4 grid gap-4 sm:grid-cols-3">
          <label className="block">
            <span className="text-xs font-semibold uppercase text-runme-muted">Max loan (₦)</span>
            <input
              type="number"
              value={maxLoan}
              onChange={(e) => setMaxLoan(e.target.value)}
              className="mt-1 w-full rounded-xl border border-runme-border bg-runme-raised px-3 py-2 text-sm text-white"
            />
          </label>
          <label className="block">
            <span className="text-xs font-semibold uppercase text-runme-muted">Max duration (days)</span>
            <input
              type="number"
              value={maxDuration}
              onChange={(e) => setMaxDuration(e.target.value)}
              className="mt-1 w-full rounded-xl border border-runme-border bg-runme-raised px-3 py-2 text-sm text-white"
            />
          </label>
          <label className="block">
            <span className="text-xs font-semibold uppercase text-runme-muted">Interest % (APR)</span>
            <input
              type="number"
              value={interest}
              onChange={(e) => setInterest(e.target.value)}
              className="mt-1 w-full rounded-xl border border-runme-border bg-runme-raised px-3 py-2 text-sm text-white"
            />
          </label>
        </div>
      </section>

      <section className="rounded-2xl border border-runme-border bg-runme-card p-6 shadow-card">
        <h2 className="text-sm font-semibold uppercase tracking-wider text-runme-accent">
          Wallet / Interswitch
        </h2>
        <div className="mt-4 flex flex-wrap items-center gap-6">
          <label className="flex cursor-pointer items-center gap-2 text-sm text-runme-subtle">
            <input
              type="checkbox"
              checked={sandbox}
              onChange={(e) => setSandbox(e.target.checked)}
              className="rounded border-runme-border text-runme-accent focus:ring-runme-accent"
            />
            Sandbox mode
          </label>
          <span className="text-xs text-runme-muted">Toggle sandbox vs live payment rails (UI only).</span>
        </div>
        <label className="mt-4 block">
          <span className="text-xs font-semibold uppercase text-runme-muted">API secret (masked)</span>
          <input
            type="password"
            value={apiKey}
            onChange={(e) => setApiKey(e.target.value)}
            placeholder="••••••••"
            className="mt-1 w-full rounded-xl border border-runme-border bg-runme-raised px-3 py-2 font-mono text-sm text-white"
          />
        </label>
      </section>

      <section className="rounded-2xl border border-runme-border bg-runme-card p-6 shadow-card">
        <h2 className="text-sm font-semibold uppercase tracking-wider text-runme-accent">Admin accounts</h2>
        <p className="mt-2 text-sm text-runme-muted">
          Invite and revoke admins through your identity provider or future `/admin/admins` API. This panel is
          read-only for now.
        </p>
        <button
          type="button"
          className="mt-4 rounded-xl border border-runme-border px-4 py-2 text-xs font-semibold uppercase text-runme-subtle hover:border-runme-accent/50 hover:text-white"
        >
          Add admin (coming soon)
        </button>
      </section>

      <div className="flex justify-end">
        <button
          type="button"
          className="rounded-xl bg-runme-accent px-6 py-2.5 text-sm font-semibold text-black hover:bg-runme-accent-hover"
        >
          Save changes
        </button>
      </div>
    </div>
  );
}
