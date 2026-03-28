# Server environment variables

This document lists every environment variable the **RunMe API** (`server/`) reads at startup. Values are validated in `server/src/config/env.ts` with [Zod](https://zod.dev); invalid or missing required variables cause the process to exit with an error.

Load variables from a **`.env`** file in the repo root or `server/` (the app calls `dotenv.config()` from `server/src/index.ts`), or set them in your host (Docker, Koyeb, etc.).

---

## Quick reference

| Variable | Required | Default | Purpose |
|----------|----------|---------|---------|
| `NODE_ENV` | No | `development` | `development` \| `test` \| `production` |
| `PORT` | No | — | Listen port (PaaS often sets this) |
| `SERVER_PORT` | No | `4000` if `PORT` unset | Listen port; **overrides** `PORT` when both are set |
| `SERVER_BASE_URL` | No | — | Public API base URL (logs, upload stubs, Swagger links) |
| `CORS_ORIGIN` | No | `*` | Browser origins, comma-separated, or `*` |
| `DATABASE_URL` | **Yes** | — | PostgreSQL connection URI (e.g. Supabase) |
| `REDIS_URL` | **Yes** | — | **TCP** Redis URL: `redis://…` or **`rediss://…`** (TLS). **Not** `https://` |
| `JWT_ACCESS_SECRET` | **Yes** | — | Secret for signing **access** JWTs |
| `JWT_ACCESS_EXPIRES_IN` | No | `1h` | Access token lifetime (`jsonwebtoken` / `ms` format) |
| `JWT_REFRESH_SECRET` | **Yes** | — | Secret for signing **refresh** JWTs (must differ from access) |
| `JWT_REFRESH_EXPIRES_IN` | No | `7d` | Refresh token lifetime |
| `BCRYPT_SALT_ROUNDS` | No | `10` | Cost factor for password hashes |
| `ADMIN_EMAIL` | No | — | Bootstrap: create admin user if missing |
| `ADMIN_PASSWORD` | No | — | Bootstrap: admin password (min 6 chars) |
| `STORAGE_BUCKET_URL` | No | — | Optional; real presigned uploads when storage is wired |

---

## Required variables (production)

You must set:

1. **`DATABASE_URL`** — Postgres (see [SUPABASE.md](./SUPABASE.md) for Supabase URI and SSL).
2. **`REDIS_URL`** — TCP connection string only.

### Upstash

The RunMe server uses the official **`redis`** Node client (TCP), **not** the REST API.

- In the [Upstash console](https://console.upstash.com), open your database and copy the **Redis URL** (or “Endpoint” formatted as `rediss://default:YOUR_PASSWORD@YOUR_HOST:6379`).
- It must start with **`rediss://`** (recommended) or **`redis://`**.
- Do **not** paste the **`https://…upstash.io`** REST URL — that causes `TypeError: Invalid protocol`.
- If you copy the **`redis-cli --tls -u redis://…`** line, either paste **only** the URL after `-u`, or paste the whole line: the server **extracts** the `redis://` / `rediss://` URL automatically. Do not include extra text without a URL in it.

For TLS on Upstash, use **`rediss://`**. The API automatically rewrites **`redis://` → `rediss://`** when the host ends with **`upstash.io`**, because plain `redis://` to Upstash is closed immediately (`Socket closed unexpectedly`).

Other providers (Redis Cloud, ElastiCache, etc.) also expose a `redis(s)://` URL.
3. **`JWT_ACCESS_SECRET`** — long random string.
4. **`JWT_REFRESH_SECRET`** — **different** long random string.

Generate secrets locally:

```bash
openssl rand -hex 32
```

Run twice and assign to the two JWT variables.

---

## Port binding

- **`SERVER_PORT`**: preferred explicit port (e.g. `4000`).
- **`PORT`**: many platforms (Koyeb, Heroku, Railway) inject this automatically.

Resolved listen port: **`SERVER_PORT` ?? `PORT` ?? `4000`**.

---

## CORS

- **`CORS_ORIGIN`**: `*` allows any origin.
- For specific apps: `https://app.example.com,https://admin.example.com` (no spaces after commas, or trim is applied).

---

## Optional admin bootstrap

If **`ADMIN_EMAIL`** and **`ADMIN_PASSWORD`** are both set, the server creates an **`admin`** user on startup **only when** that email does not already exist. Useful for first deploy. Remove or leave unset after you have a real admin account if you prefer not to rely on env-based bootstrap.

---

## Optional storage

**`STORAGE_BUCKET_URL`** is read in `server/src/routes/uploads.ts` but **not** part of the Zod schema. If unset, `POST /uploads/presign` returns stub URLs. Set it when you integrate S3 or Supabase Storage.

---

## Example `.env` (local development)

Create a file named `.env` (do not commit secrets; add `.env` to `.gitignore`):

```env
NODE_ENV=development
SERVER_PORT=4000
SERVER_BASE_URL=http://localhost:4000

CORS_ORIGIN=*

DATABASE_URL=postgresql://USER:PASSWORD@HOST:5432/postgres?sslmode=require
REDIS_URL=redis://127.0.0.1:6379

JWT_ACCESS_SECRET=replace-with-openssl-rand-hex-32
JWT_REFRESH_SECRET=replace-with-a-different-openssl-rand-hex-32
JWT_ACCESS_EXPIRES_IN=1h
JWT_REFRESH_EXPIRES_IN=7d

BCRYPT_SALT_ROUNDS=10

# Optional first-time admin
# ADMIN_EMAIL=admin@example.com
# ADMIN_PASSWORD=change-me-securely

# Optional
# STORAGE_BUCKET_URL=https://your-bucket.example.com
```

Adjust `DATABASE_URL` and `REDIS_URL` to match your local Docker Compose services or cloud URLs.

---

## Validation errors

If startup prints `Invalid env:` with field errors, check:

- Required strings are non-empty.
- `ADMIN_PASSWORD` is at least **6** characters when `ADMIN_EMAIL` is used (both must be set together for seeding).
- `NODE_ENV` is exactly `development`, `test`, or `production`.

---

## Related docs

- **[SUPABASE.md](./SUPABASE.md)** — Supabase Postgres URI, running SQL migrations, Koyeb notes.
- **[REST_API.md](./REST_API.md)** — HTTP API surface; **§16** for Swagger at `/docs`.
