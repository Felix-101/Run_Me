import { apiFetch } from "./api";
import type {
  AdminAuditRow,
  AdminGrantRow,
  AdminLoanRow,
  AdminSummary,
  AdminUserRow,
  Paginated
} from "../models/admin";

export async function getAdminSummary() {
  return apiFetch<AdminSummary>("/admin/summary", { method: "GET", auth: true });
}

export async function getAdminUsers(params?: { limit?: number; cursor?: string }) {
  const q = new URLSearchParams();
  if (params?.limit) q.set("limit", String(params.limit));
  if (params?.cursor) q.set("cursor", params.cursor);
  const qs = q.toString();
  return apiFetch<Paginated<AdminUserRow>>(`/admin/users${qs ? `?${qs}` : ""}`, {
    method: "GET",
    auth: true
  });
}

export async function getAdminLoans(params?: { limit?: number; cursor?: string }) {
  const q = new URLSearchParams();
  if (params?.limit) q.set("limit", String(params.limit));
  if (params?.cursor) q.set("cursor", params.cursor);
  const qs = q.toString();
  return apiFetch<Paginated<AdminLoanRow>>(`/admin/loans${qs ? `?${qs}` : ""}`, {
    method: "GET",
    auth: true
  });
}

export async function getAdminGrants(params?: { limit?: number; cursor?: string }) {
  const q = new URLSearchParams();
  if (params?.limit) q.set("limit", String(params.limit));
  if (params?.cursor) q.set("cursor", params.cursor);
  const qs = q.toString();
  return apiFetch<Paginated<AdminGrantRow>>(`/admin/grants${qs ? `?${qs}` : ""}`, {
    method: "GET",
    auth: true
  });
}

export async function getAdminAudit(params?: { limit?: number; cursor?: string }) {
  const q = new URLSearchParams();
  if (params?.limit) q.set("limit", String(params.limit));
  if (params?.cursor) q.set("cursor", params.cursor);
  const qs = q.toString();
  return apiFetch<Paginated<AdminAuditRow>>(`/admin/audit${qs ? `?${qs}` : ""}`, {
    method: "GET",
    auth: true
  });
}
