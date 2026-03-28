import postgres from "postgres";
import { drizzle } from "drizzle-orm/postgres-js";
import { env } from "../config/env";

/**
 * Supabase's transaction pooler (PgBouncer, often port 6543) does not support
 * server-side prepared statements across connections. drizzle-orm + node-pg
 * uses named prepared statements by default, which surfaces as opaque DB errors.
 * postgres.js with `prepare: false` uses the simple query protocol instead.
 */
export const sql = postgres(env.DATABASE_URL, {
  max: 20,
  prepare: false
});

export const db = drizzle(sql);

export async function closeDb(): Promise<void> {
  await sql.end({ timeout: 5 });
}
