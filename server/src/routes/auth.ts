import { Router } from "express";
import bcrypt from "bcryptjs";
import { z } from "zod";
import { ApiError } from "../lib/errors";
import { db } from "../db/client";
import { users } from "../db/schema";
import { eq } from "drizzle-orm";
import { signAccessToken } from "../lib/jwt";
import { env } from "../config/env";
import { requireAuth } from "../middleware/auth";
import { redisClient } from "../lib/redis";
import { randomUUID } from "crypto";

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

    const accessToken = signAccessToken({
      userId: user.id,
      role: user.role,
      email: user.email,
      jti: randomUUID()
    });

    return res.status(201).json({ accessToken });
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

    const accessToken = signAccessToken({
      userId: user.id,
      role: user.role,
      email: user.email,
      jti: randomUUID()
    });

    return res.json({ accessToken });
  } catch (err) {
    return next(err);
  }
});

router.post("/logout", requireAuth, async (req, res, next) => {
  try {
    const claims = req.auth;
    if (!claims?.jti) throw new ApiError("Unauthorized", 401);

    // JWT `exp` is expressed in seconds since epoch.
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

