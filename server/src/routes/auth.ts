import { Router } from "express";
import bcrypt from "bcryptjs";
import { z } from "zod";
import { eq, and, isNull } from "drizzle-orm";
import { ApiError } from "../lib/errors";
import { db } from "../db/client";
import { users, wallets, refreshTokens } from "../db/schema";
import { verifyRefreshToken } from "../lib/jwt";
import { env } from "../config/env";
import { requireAuth } from "../middleware/auth";
import { redisClient } from "../lib/redis";
import { issueAuthTokens, revokeRefreshTokenByJti, loadUserForAuth } from "../lib/authTokens";

const router = Router();

const registerSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6)
});

router.post("/register", async (req, res, next) => {
  try {
    const { email, password } = registerSchema.parse(req.body);

    const existing = await db.select().from(users).where(eq(users.email, email)).limit(1);
    if (existing.length > 0) throw new ApiError("Email already in use", 409);

    const passwordHash = await bcrypt.hash(password, env.BCRYPT_SALT_ROUNDS);

    const created = await db
      .insert(users)
      .values({
        email,
        passwordHash,
        role: "user"
      })
      .returning({
        id: users.id,
        email: users.email,
        role: users.role
      });

    const user = created[0];
    if (!user) throw new ApiError("Failed to create user", 500);

    await db.insert(wallets).values({ userId: user.id, balanceNaira: 0 });

    const tokens = await issueAuthTokens(user);

    return res.status(201).json(tokens);
  } catch (err) {
    return next(err);
  }
});

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(1)
});

router.post("/login", async (req, res, next) => {
  try {
    const { email, password } = loginSchema.parse(req.body);

    const existing = await db.select().from(users).where(eq(users.email, email)).limit(1);
    const user = existing[0];
    if (!user) throw new ApiError("Invalid credentials", 401);

    const isValid = await bcrypt.compare(password, user.passwordHash);
    if (!isValid) throw new ApiError("Invalid credentials", 401);

    const tokens = await issueAuthTokens({
      id: user.id,
      email: user.email,
      role: user.role
    });

    return res.json(tokens);
  } catch (err) {
    return next(err);
  }
});

const refreshSchema = z.object({
  refreshToken: z.string().min(1)
});

router.post("/refresh", async (req, res, next) => {
  try {
    const { refreshToken } = refreshSchema.parse(req.body);
    const claims = verifyRefreshToken(refreshToken);

    const rows = await db
      .select()
      .from(refreshTokens)
      .where(
        and(
          eq(refreshTokens.jti, claims.jti),
          isNull(refreshTokens.revokedAt)
        )
      )
      .limit(1);

    const row = rows[0];
    if (!row || row.expiresAt < new Date()) {
      throw new ApiError("Invalid refresh token", 401);
    }

    await revokeRefreshTokenByJti(claims.jti);

    const user = await loadUserForAuth(claims.sub);
    if (!user) throw new ApiError("Invalid refresh token", 401);

    const tokens = await issueAuthTokens(user, { revokeExistingRefreshTokens: false });

    return res.json(tokens);
  } catch (err) {
    return next(err);
  }
});

const logoutBodySchema = z
  .object({
    refreshToken: z.string().optional()
  })
  .optional();

router.post("/logout", requireAuth, async (req, res, next) => {
  try {
    const claims = req.auth;
    if (!claims?.jti) throw new ApiError("Unauthorized", 401);

    const parsed = logoutBodySchema.parse(req.body);
    if (parsed?.refreshToken) {
      try {
        const r = verifyRefreshToken(parsed.refreshToken);
        await revokeRefreshTokenByJti(r.jti);
      } catch {
        // ignore invalid refresh token on logout
      }
    }

    const nowSeconds = Math.floor(Date.now() / 1000);
    const expSeconds = claims.exp ?? nowSeconds;
    const ttlSeconds = Math.max(expSeconds - nowSeconds, 1);

    await redisClient.setEx(`bl:${claims.jti}`, ttlSeconds, "1");

    return res.status(204).send();
  } catch (err) {
    return next(err);
  }
});

export default router;
