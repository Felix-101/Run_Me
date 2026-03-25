import type { ReactNode } from "react";
import { Navigate } from "react-router-dom";
import { useSelector } from "react-redux";
import type { RootState } from "../store/store";

export default function ProtectedRoute({
  children,
  requireAdmin
}: {
  children: ReactNode;
  requireAdmin?: boolean;
}) {
  const token = useSelector((s: RootState) => s.auth.accessToken);
  const me = useSelector((s: RootState) => s.auth.me);

  if (!token) return <Navigate to="/login" replace />;

  if (requireAdmin && me && me.role !== "admin") {
    return <Navigate to="/not-authorized" replace />;
  }

  return <>{children}</>;
}

