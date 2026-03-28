import type { NextFunction, Request, Response } from "express";
import { ZodError } from "zod";
import { ApiError } from "../lib/errors";

export function errorHandler(err: unknown, _req: Request, res: Response, _next: NextFunction) {
  const status = err instanceof ApiError ? err.status : err instanceof ZodError ? 400 : 500;

  const message =
    err instanceof ApiError
      ? err.message
      : err instanceof ZodError
        ? "Invalid request"
        : "Internal server error";

  if (status === 500) {
    // eslint-disable-next-line no-console
    console.error("Unhandled API error:", err);
  }

  if (res.headersSent) return;
  res.status(status).json({
    error: {
      message
    }
  });
}

