import { apiFetch } from "./api";
import type {
  AdminAuditRow,
  AdminGrantRow,
  AdminLoanRow,
  AdminSummary,
  AdminUserRow,
  Paginated
} from "../models/admin";

/** Page size for admin list endpoints; must be ≤ server `listQuerySchema` max (100). */
export const ADMIN_LIST_PAGE_SIZE = 50;

async function fetchAllAdminPages<T>(
  fetchPage: (cursor: string | undefined) => Promise<Paginated<T>>
): Promise<T[]> {
  const all: T[] = [];
  let cursor: string | undefined;
  for (;;) {
    const page = await fetchPage(cursor);
    all.push(...page.items);
    if (!page.nextCursor) break;
    cursor = page.nextCursor;
  }
  return all;
}

export async function getAllAdminLoans(): Promise<AdminLoanRow[]> {
  return fetchAllAdminPages((cursor) =>
    getAdminLoans({ limit: ADMIN_LIST_PAGE_SIZE, cursor })
  );
}

export async function getAllAdminGrants(): Promise<AdminGrantRow[]> {
  return fetchAllAdminPages((cursor) =>
    getAdminGrants({ limit: ADMIN_LIST_PAGE_SIZE, cursor })
  );
}

export async function getAllAdminUsers(): Promise<AdminUserRow[]> {
  return fetchAllAdminPages((cursor) =>
    getAdminUsers({ limit: ADMIN_LIST_PAGE_SIZE, cursor })
  );
}

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
