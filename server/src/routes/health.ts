import { Router } from "express";
import { redisClient } from "../lib/redis";
import { ApiError } from "../lib/errors";

const router = Router();

router.get("/", async (_req, res, next) => {
  try {
    const redisStatus = await redisClient.ping();
    if (!redisStatus) throw new ApiError("Redis not reachable", 503);
    return res.json({
      ok: true,
      redis: redisStatus
    });
  } catch (err) {
    return next(err);
  }
});

export default router;

