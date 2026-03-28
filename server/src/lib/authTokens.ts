import { decode } from "jsonwebtoken";
import { randomUUID } from "crypto";
import { eq } from "drizzle-orm";
import { db } from "../db/client";
import { refreshTokens, users } from "../db/schema";
import { signAccessToken, signRefreshToken } from "./jwt";
import { ApiError } from "./errors";

type UserRow = {
  id: string;
  email: string;
  role: string;
};

export async function issueAuthTokens(
  user: UserRow,
  options: { revokeExistingRefreshTokens?: boolean } = {}
) {
  const revokeExisting = options.revokeExistingRefreshTokens ?? true;
  if (revokeExisting) {
    await db.delete(refreshTokens).where(eq(refreshTokens.userId, user.id));
  }

  const accessJti = randomUUID();
  const refreshJti = randomUUID();

  const accessToken = signAccessToken({
    userId: user.id,
    role: user.role,
    email: user.email,
    jti: accessJti
  });

  const refreshToken = signRefreshToken({
    userId: user.id,
    jti: refreshJti
  });

  const payload = decode(refreshToken) as { exp?: number };
  const expSeconds = payload.exp;
  if (!expSeconds) throw new ApiError("Failed to issue refresh token", 500);

  await db.insert(refreshTokens).values({
    userId: user.id,
    jti: refreshJti,
    expiresAt: new Date(expSeconds * 1000)
  });

  return { accessToken, refreshToken };
}

export async function revokeRefreshTokenByJti(jti: string) {
  await db
    .update(refreshTokens)
    .set({ revokedAt: new Date() })
    .where(eq(refreshTokens.jti, jti));
}

export async function loadUserForAuth(userId: string): Promise<UserRow | null> {
  const rows = await db
    .select({
      id: users.id,
      email: users.email,
      role: users.role
    })
    .from(users)
    .where(eq(users.id, userId))
    .limit(1);
  return rows[0] ?? null;
}
