/**
 * Base URL for the RunMe API.
 * - Default is the deployed API (dev + prod) so `npm run dev` works without a local server.
 * - For a local API: `VITE_SERVER_BASE_URL=http://localhost:4000` in `.env` or `.env.local`.
 */
const DEFAULT_API = "https://zesty-nerte-iniverse-8476794d.koyeb.app";

export function getApiBaseUrl(): string {
  const fromEnv = import.meta.env.VITE_SERVER_BASE_URL?.toString().trim();
  if (fromEnv) return fromEnv.replace(/\/$/, "");
  return DEFAULT_API;
}
