import bcrypt from "bcryptjs";
import { eq } from "drizzle-orm";
import { users } from "./schema";
import { db } from "./client";
import { env } from "../config/env";

export async function seedAdminIfMissing() {
  if (!env.ADMIN_EMAIL || !env.ADMIN_PASSWORD) return;

  const existing = await db
    .select()
    .from(users)
    .where(eq(users.email, env.ADMIN_EMAIL))
    .limit(1);

  if (existing.length > 0) return;

  const passwordHash = await bcrypt.hash(env.ADMIN_PASSWORD, env.BCRYPT_SALT_ROUNDS);

  await db.insert(users).values({
    email: env.ADMIN_EMAIL,
    passwordHash,
    role: "admin"
  });
}

