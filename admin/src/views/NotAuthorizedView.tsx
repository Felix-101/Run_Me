import { useNavigate } from "react-router-dom";

export default function NotAuthorizedView() {
  const navigate = useNavigate();
  return (
    <div className="flex min-h-screen items-center justify-center bg-runme-bg p-6">
      <div className="w-full max-w-md rounded-2xl border border-runme-border bg-runme-card p-8 shadow-card">
        <h1 className="text-xl font-semibold text-white">Not authorized</h1>
        <p className="mt-2 text-sm text-runme-muted">
          Your account does not have access to the admin area.
        </p>
        <button
          className="mt-6 rounded-xl bg-runme-accent px-4 py-2.5 text-sm font-semibold text-black hover:bg-runme-accent-hover"
          type="button"
          onClick={() => navigate("/login")}
        >
          Go to login
        </button>
      </div>
    </div>
  );
}
