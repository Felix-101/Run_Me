export type ApiResult<T> = { data: T } | { error: string };

const SERVER_BASE_URL =
  import.meta.env.VITE_SERVER_BASE_URL?.toString() ?? "http://localhost:4000";

export async function apiFetch<T>(
  path: string,
  options?: RequestInit & { auth?: boolean }
): Promise<T> {
  const token = options?.auth ? localStorage.getItem("accessToken") : null;

  const res = await fetch(`${SERVER_BASE_URL}${path}`, {
    ...options,
    headers: {
      "Content-Type": "application/json",
      ...(options?.headers ?? {}),
      ...(token ? { Authorization: `Bearer ${token}` } : {})
    }
  });

  if (!res.ok) {
    const text = await res.text().catch(() => "");
    throw new Error(text || `Request failed: ${res.status}`);
  }

  // Some endpoints return 204.
  if (res.status === 204) return undefined as unknown as T;

  return (await res.json()) as T;
}

