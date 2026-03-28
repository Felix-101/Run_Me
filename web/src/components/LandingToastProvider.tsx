import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useRef,
  useState,
  type ReactNode
} from "react";

const TOAST_MS = 3000;

type ToastContextValue = {
  showToast: (message: string) => void;
};

const ToastContext = createContext<ToastContextValue | null>(null);

export function useLandingToast(): ToastContextValue {
  const ctx = useContext(ToastContext);
  if (!ctx) {
    throw new Error("useLandingToast must be used within LandingToastProvider");
  }
  return ctx;
}

export function LandingToastProvider({ children }: { children: ReactNode }) {
  const [open, setOpen] = useState(false);
  const [message, setMessage] = useState("");
  const hideTimer = useRef<ReturnType<typeof setTimeout> | null>(null);

  const clearHide = useCallback(() => {
    if (hideTimer.current !== null) {
      clearTimeout(hideTimer.current);
      hideTimer.current = null;
    }
  }, []);

  const showToast = useCallback(
    (msg: string) => {
      clearHide();
      setMessage(msg);
      setOpen(true);
      hideTimer.current = setTimeout(() => {
        setOpen(false);
        hideTimer.current = null;
      }, TOAST_MS);
    },
    [clearHide]
  );

  useEffect(() => () => clearHide(), [clearHide]);

  return (
    <ToastContext.Provider value={{ showToast }}>
      {children}
      <div
        className="pointer-events-none fixed inset-x-0 top-0 z-[200] flex justify-center px-4 pt-4"
        aria-live="polite"
      >
        {open ? (
          <div className="pointer-events-auto animate-[fadeSlide_0.25s_ease-out] rounded-xl border border-amber-500/40 bg-amber-400 px-6 py-3 text-center text-sm font-bold text-black shadow-xl">
            {message}
          </div>
        ) : null}
      </div>
      <style>{`
        @keyframes fadeSlide {
          from { opacity: 0; transform: translateY(-8px); }
          to { opacity: 1; transform: translateY(0); }
        }
      `}</style>
    </ToastContext.Provider>
  );
}
