import { createClient } from "redis";
import { env } from "../config/env";

/**
 * Upstash public endpoints require TLS. CLI examples use `redis-cli --tls -u redis://...`
 * but the Node client must use `rediss://` or the server closes the socket immediately.
 */
function redisUrlWithTlsWhenNeeded(url: string): string {
  const trimmed = url.trim();
  if (/^redis:\/\//i.test(trimmed) && /\.upstash\.io\b/i.test(trimmed)) {
    return trimmed.replace(/^redis:\/\//i, "rediss://");
  }
  return trimmed;
}

const redisUrl = redisUrlWithTlsWhenNeeded(env.REDIS_URL);

// Singleton Redis client for the API process.
export const redisClient = createClient({
  url: redisUrl,
  socket: {
    reconnectStrategy: (retries) => Math.min(retries * 100, 3000)
  }
});

redisClient.on("error", (err) => {
  // eslint-disable-next-line no-console
  console.error("[redis]", err.message);
});

export async function connectRedis() {
  if (redisClient.isOpen) return;
  try {
    await redisClient.connect();
  } catch (err) {
    // eslint-disable-next-line no-console
    console.error(
      "[redis] Failed to connect. For Upstash use rediss:// (TLS). Current URL protocol:",
      redisUrl.split("://")[0] ?? "?"
    );
    throw err;
  }
}
