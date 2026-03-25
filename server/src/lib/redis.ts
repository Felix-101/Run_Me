import { createClient } from "redis";
import { env } from "../config/env";

// Singleton Redis client for the API process.
export const redisClient = createClient({
  url: env.REDIS_URL
});

export async function connectRedis() {
  if (redisClient.isOpen) return;
  await redisClient.connect();
}

