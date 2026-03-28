# Supabase PostgreSQL + Koyeb (RunMe API)

This guide explains how to connect the **Node API** (`server/`) to **Supabase Postgres**, apply the schema, and run the service on **Koyeb**.

For **every** server environment variable (required/optional, defaults, examples), see **[SERVER_ENV.md](./SERVER_ENV.md)**.

## 1. Create a Supabase project

1. Go to [https://supabase.com](https://supabase.com) and create a project.
2. Wait until the database is **healthy** (Dashboard → Project Settings → Database).

## 2. Get the connection string

1. In Supabase: **Project Settings → Database**.
2. Under **Connection string**, choose **URI**.
3. Use the **Transaction** pooler when possible (recommended for server apps and IPv4-only hosts like Koyeb):
   - Host often looks like `aws-0-<region>.pooler.supabase.com`
   - Port **6543** (pooler) or **5432** (direct)
4. Replace `[YOUR-PASSWORD]` with the database password you set at project creation.

Example (pooler):

```text
postgresql://postgres.<project-ref>:[YOUR-PASSWORD]@aws-0-eu-central-1.pooler.supabase.com:6543/postgres?sslmode=require
```

Append `?sslmode=require` if it is not already present. The API sets `ssl` on the `pg` `Pool` when the host is `supabase.com` or in production.

## 3. Apply the schema

The canonical SQL migration lives at:

`server/drizzle/0000_init.sql`

**Option A — Supabase SQL Editor (simplest)**

1. Open **SQL → New query**.
2. Paste the full contents of `server/drizzle/0000_init.sql`.
3. Run the script once on a **fresh** database.

**Option B — `psql` from your machine**

```bash
cd /path/to/Run_Me
psql "$DATABASE_URL" -f server/drizzle/0000_init.sql
```

Use the same URI you will set as `DATABASE_URL` for the API.

> **Existing databases:** If you already had an older `users` table from an earlier RunMe migration, you may need manual `ALTER TABLE` statements instead of re-running the full file. For a greenfield project, the script above is enough.

### Backfill wallets for users created before the `wallets` table

If you add the `wallets` table after users already exist:

```sql
INSERT INTO wallets (user_id, balance_naira)
SELECT id, 0 FROM users
ON CONFLICT (user_id) DO NOTHING;
```

## 4. Redis

The API still uses **Redis** for:

- Admin summary cache (`/admin/summary`)
- Access-token **logout** blacklist (`POST /auth/logout`)

Use a managed Redis (e.g. **Upstash**, **Redis Cloud**, or a small VM) and set `REDIS_URL` in Koyeb.

**Upstash:** use the **`rediss://default:PASSWORD@HOST:PORT`** string from the database page — **not** the `https://…upstash.io` REST URL (the Node `redis` client will throw `Invalid protocol`).

Local dev: `docker compose` or `redis://localhost:6379` if you run Redis locally.

## 5. Environment variables (Koyeb)

The checklist below covers typical Supabase + Koyeb deploys. **Full reference:** [SERVER_ENV.md](./SERVER_ENV.md).

Set these in the Koyeb service **Environment** tab (or your `.env` locally):

| Variable | Purpose |
|----------|---------|
| `DATABASE_URL` | Supabase Postgres URI (`sslmode=require`) |
| `REDIS_URL` | Redis connection URL |
| `JWT_ACCESS_SECRET` | Long random string (sign access tokens) |
| `JWT_REFRESH_SECRET` | **Different** long random string (sign refresh tokens) |
| `JWT_ACCESS_EXPIRES_IN` | Optional; default `1h` |
| `JWT_REFRESH_EXPIRES_IN` | Optional; default `7d` |
| `SERVER_PORT` | `4000` or whatever Koyeb injects |
| `PORT` | If set (common on PaaS), used as listen port when `SERVER_PORT` is omitted |
| `SERVER_BASE_URL` | Public API URL, e.g. `https://your-app.koyeb.app` |
| `CORS_ORIGIN` | Comma-separated origins or `*` |
| `NODE_ENV` | `production` |
| `ADMIN_EMAIL` / `ADMIN_PASSWORD` | Optional: seed first admin on first boot |

Generate secrets:

```bash
openssl rand -hex 32
```

## 6. Drizzle Kit (optional)

The repo includes `drizzle.config.ts` for **future** `drizzle-kit generate` / `migrate` workflows. If `drizzle-kit generate` fails with a version mismatch in your workspace, rely on `server/drizzle/0000_init.sql` until dependencies are aligned.

```bash
npm run db:generate --workspace server   # when drizzle-kit + drizzle-orm match
npm run db:migrate --workspace server   # applies generated migrations
```

## 7. Deploy on Koyeb

Heroku-style buildpacks (including Koyeb’s default Node build) **require a lockfile** next to the `package.json` they install (`package-lock.json`, `yarn.lock`, or `pnpm-lock.yaml`).

This repo is an **npm workspaces** monorepo: the root has `package-lock.json`, but **`server/` also has its own `server/package-lock.json`** so you can set Koyeb’s **root directory** to `server` and build without “Missing lockfile” errors. **Commit and push** `server/package-lock.json` after it is generated.

### Option A — Deploy only the API (`server/`)

1. In Koyeb, set **Root directory** (or equivalent) to **`server`**.
2. **Build command**: `npm ci && npm run build`
3. **Run command**: `npm start` (runs `node dist/index.js`)
4. Set **port** from `PORT` (already supported via `env.ts`; optional `SERVER_PORT` override).

### Option B — Deploy from monorepo root

1. Leave root directory as **`.`** (repository root).
2. **Build command**: `npm ci && npm run build --workspace server`
3. **Run command**: `npm run start --workspace server`
4. Uses the **root** `package-lock.json`.

In both cases, add **environment variables** from section 5.

If the app **exits immediately** with `Invalid environment variables` / Zod `Required` errors, the host has not set the **required** keys. At minimum add **`DATABASE_URL`**, **`REDIS_URL`**, **`JWT_ACCESS_SECRET`**, and **`JWT_REFRESH_SECRET`** in Koyeb under **your service → Environment** (same names as in `docs/SERVER_ENV.md`). Empty values are rejected.

Health check path: `GET /health` (see `server/src/routes/health.ts`).

## 8. Verify

```bash
curl -sS https://your-api.koyeb.app/health
curl -sS https://your-api.koyeb.app/
```

Register and log in:

```bash
curl -sS -X POST https://your-api.koyeb.app/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"you@school.edu","password":"secret12"}'
```

You should receive a JSON body with `accessToken` and `refreshToken`.
