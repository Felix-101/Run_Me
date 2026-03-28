import { useState } from "react";
import { Link } from "react-router-dom";

const STORAGE_KEY = "runme_hide_instructor_toast";

export default function InstructorToast() {
  const [hidden, setHidden] = useState(() =>
    typeof sessionStorage !== "undefined" ? sessionStorage.getItem(STORAGE_KEY) === "1" : false
  );

  function dismiss() {
    sessionStorage.setItem(STORAGE_KEY, "1");
    setHidden(true);
  }

  if (hidden) return null;

  return (
    <div
      className="pointer-events-none fixed inset-x-0 bottom-0 z-[100] flex justify-center px-4 pb-6 pt-2 sm:pb-8"
      role="region"
      aria-label="Buildathon instructor notice"
    >
      <div className="pointer-events-auto flex w-full max-w-lg flex-col gap-3 rounded-2xl border border-amber-400/80 bg-amber-300 px-4 py-3 shadow-[0_12px_40px_rgba(0,0,0,0.45)] sm:flex-row sm:items-center sm:justify-between sm:gap-4 sm:px-5 sm:py-3.5">
        <p className="text-center text-sm font-semibold leading-snug text-neutral-900 sm:text-left">
          For Enyata * Interswitch Buildathon 2026 Instructors
        </p>
        <div className="flex shrink-0 items-center justify-center gap-2 sm:justify-end">
          <Link
            to="/instructors"
            className="inline-flex items-center justify-center rounded-xl bg-neutral-900 px-4 py-2 text-xs font-semibold text-amber-200 transition hover:bg-neutral-800"
          >
            Instructor guide
          </Link>
          <button
            type="button"
            onClick={dismiss}
            className="rounded-lg px-2 py-1 text-xs font-medium text-neutral-800/80 underline-offset-2 hover:text-neutral-900 hover:underline"
            aria-label="Dismiss notice"
          >
            Dismiss
          </button>
        </div>
      </div>
    </div>
  );
}
