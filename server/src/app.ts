import express from "express";
import cors from "cors";
import helmet from "helmet";
import { env, corsOrigins } from "./config/env";
import healthRouter from "./routes/health";
import authRouter from "./routes/auth";
import meRouter from "./routes/me";
import adminRouter from "./routes/admin";
import { ApiError } from "./lib/errors";
import { errorHandler } from "./middleware/errorHandler";

export function createApp() {
  const app = express();

  app.use(helmet());
  app.use(
    cors({
      origin: corsOrigins === "*" ? true : corsOrigins,
      credentials: false
    })
  );
  app.use(express.json({ limit: "1mb" }));

  app.get("/", (_req, res) => res.json({ ok: true }));

  app.use("/health", healthRouter);
  app.use("/auth", authRouter);
  app.use("/me", meRouter);
  app.use("/admin", adminRouter);

  app.use((_req, _res, next) => next(new ApiError("Not Found", 404)));
  app.use(errorHandler);

  // Expose env for quick debugging (development only).
  if (env.NODE_ENV === "development") {
    app.get("/__env", (_req, res) => res.json({ SERVER_PORT: env.SERVER_PORT }));
  }

  return app;
}

