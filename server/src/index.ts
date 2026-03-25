import dotenv from "dotenv";
dotenv.config();

import { createApp } from "./app";
import { env } from "./config/env";
import { connectRedis } from "./lib/redis";
import { seedAdminIfMissing } from "./db/seed";
import { redisClient } from "./lib/redis";

async function main() {
  // Validate env before doing anything else.
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  const _ = env;

  await connectRedis();
  await seedAdminIfMissing();

  const app = createApp();
  const server = app.listen(env.SERVER_PORT, () => {
    // eslint-disable-next-line no-console
    console.log(`RunMe API listening on ${env.SERVER_BASE_URL ?? `:${env.SERVER_PORT}`}`);
  });

  const shutdown = async () => {
    try {
      await redisClient.quit();
    } finally {
      server.close(() => process.exit(0));
    }
  };

  process.on("SIGINT", shutdown);
  process.on("SIGTERM", shutdown);
}

main().catch((err) => {
  // eslint-disable-next-line no-console
  console.error(err);
  process.exit(1);
});

