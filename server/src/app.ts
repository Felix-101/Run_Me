import express from "express";
import cors from "cors";
import helmet from "helmet";
import { env, corsOrigins } from "./config/env";
import healthRouter from "./routes/health";
import authRouter from "./routes/auth";
import meRouter from "./routes/me";
import adminRouter from "./routes/admin";
import loansRouter from "./routes/loans";
import grantsRouter from "./routes/grants";
import uploadsRouter from "./routes/uploads";
import { ApiError } from "./lib/errors";
import { errorHandler } from "./middleware/errorHandler";
import { mountSwagger } from "./swagger";

export function createApp() {
  const app = express();

  app.use(
    helmet({
      contentSecurityPolicy: {
        useDefaults: true,
        directives: {
          "script-src": ["'self'", "'unsafe-inline'", "'unsafe-eval'"],
          "style-src": ["'self'", "'unsafe-inline'"],
          "img-src": ["'self'", "data:", "https:"]
        }
      }
    })
  );
  app.use(
    cors({
      origin: corsOrigins === "*" ? true : corsOrigins,
      credentials: false
    })
  );
  app.use(express.json({ limit: "1mb" }));

  app.get("/", (_req, res) => res.json({ ok: true }));

  mountSwagger(app);

  app.use("/health", healthRouter);
  app.use("/auth", authRouter);
  app.use("/me", meRouter);
  app.use("/admin", adminRouter);
  app.use("/loans", loansRouter);
  app.use("/grants", grantsRouter);
  app.use("/uploads", uploadsRouter);

  app.use((_req, _res, next) => next(new ApiError("Not Found", 404)));
  app.use(errorHandler);

  // Expose env for quick debugging (development only).
  if (env.NODE_ENV === "development") {
    app.get("/__env", (_req, res) => res.json({ SERVER_PORT: env.SERVER_PORT }));
  }

  return app;
}

