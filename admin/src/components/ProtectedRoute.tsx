import type { ReactNode } from "react";
import { useEffect } from "react";
import { Navigate, Outlet } from "react-router-dom";
import { useDispatch, useSelector } from "react-redux";
import type { RootState } from "../store/store";
import type { AppDispatch } from "../store/store";
import { fetchMeThunk } from "../store/authSlice";

export default function ProtectedRoute({
  requireAdmin,
  children
}: {
  requireAdmin?: boolean;
  /** @deprecated use nested routes + Outlet */
  children?: ReactNode;
}) {
  const dispatch = useDispatch<AppDispatch>();
  const token = useSelector((s: RootState) => s.auth.accessToken);
  const me = useSelector((s: RootState) => s.auth.me);
  const status = useSelector((s: RootState) => s.auth.status);

  useEffect(() => {
    if (token && !me) {
      dispatch(fetchMeThunk());
    }
  }, [dispatch, token, me]);

  if (!token) return <Navigate to="/login" replace />;

  if (token && !me && status === "loading") {
    return (
      <div className="flex min-h-screen items-center justify-center bg-runme-bg">
        <div className="text-runme-muted">Loading session…</div>
      </div>
    );
  }

  if (token && !me && status === "error") {
    return <Navigate to="/login" replace />;
  }

  if (requireAdmin && me && me.role !== "admin") {
    return <Navigate to="/not-authorized" replace />;
  }

  if (children) return <>{children}</>;
  return <Outlet />;
}
