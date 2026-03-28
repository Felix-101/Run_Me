import { Pool } from "pg";
import { drizzle } from "drizzle-orm/node-postgres";
import { env } from "../config/env";

export const pool = new Pool({
  connectionString: env.DATABASE_URL,
  max: 20,
  ssl:
    env.DATABASE_URL.includes("supabase.com") || env.NODE_ENV === "production"
      ? { rejectUnauthorized: false }
      : undefined
});

export const db = drizzle(pool);

