import { Router } from "express";
import { eq, count } from "drizzle-orm";
import { users } from "../db/schema";
import { db } from "../db/client";
import { redisClient } from "../lib/redis";
import { ApiError } from "../lib/errors";
import { requireAuth, requireAdmin } from "../middleware/auth";

const router = Router();

router.get("/summary", requireAuth, requireAdmin, async (_req, res, next) => {
  try {
    const cacheKey = "admin:summary";
    const cached = await redisClient.get(cacheKey);
    if (cached) {
      return res.json(JSON.parse(cached));
    }

    const result = await db.select({ usersCount: count(users.id) }).from(users);
    const usersCount = result[0]?.usersCount ?? 0;

    const summary = {
      usersCount,
      generatedAt: new Date().toISOString()
    };

    // Cache for quick subsequent loads (placeholder for future admin dashboards).
    await redisClient.setEx(cacheKey, 30, JSON.stringify(summary));

    return res.json(summary);
  } catch (err) {
    return next(err);
  }
});

export default router;

