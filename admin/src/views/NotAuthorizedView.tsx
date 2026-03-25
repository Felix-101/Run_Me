import { useNavigate } from "react-router-dom";

export default function NotAuthorizedView() {
  const navigate = useNavigate();
  return (
    <div className="min-h-screen bg-slate-50 p-6">
      <div className="mx-auto max-w-md rounded-xl border bg-white p-6">
        <h1 className="text-xl font-semibold">Not authorized</h1>
        <p className="mt-2 text-sm text-slate-600">
          Your account does not have access to the admin area.
        </p>
        <button
          className="mt-6 rounded-lg bg-slate-900 px-4 py-2 text-sm text-white"
          type="button"
          onClick={() => navigate("/login")}
        >
          Go to login
        </button>
      </div>
    </div>
  );
}

