# runme

Monorepo for:
- Server (Express + Drizzle ORM + Postgres + Redis)
- Landing client (React + Tailwind)
- Admin dashboard (React + Tailwind + MVVM + Redux Toolkit)
- Mobile app (Flutter)

## Prerequisites
- Node.js (>= 22)
- Docker (for Postgres + Redis)

## Local development
1. Copy env:
   - `cp .env.example .env`
2. Start databases:
   - `docker compose up -d`
3. Install dependencies:
   - `npm install`
4. Apply migrations:
   - `npm run db:migrate`
5. Start the apps:
   - `npm run dev`

## Environment variables
See `.env.example` at the repo root and the `*/.env.example` files for each app.

Notes:
- `web/` and `admin/` use Vite env var `VITE_SERVER_BASE_URL` (optional).
- **`admin/`**: if `VITE_SERVER_BASE_URL` is unset, dev and production builds use the default API URL in `admin/src/config/apiBase.ts`. Set `VITE_SERVER_BASE_URL=http://localhost:4000` in `admin/.env.local` when using a local server.
- `mobile/` reads `mobile/assets/config.json` at runtime (see `mobile/.env.example`).

