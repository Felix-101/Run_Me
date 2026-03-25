import { NextFunction, Request, Response } from "express";
import { ApiError } from "../lib/errors";
import { verifyAccessToken } from "../lib/jwt";
import { redisClient } from "../lib/redis";
import { env } from "../config/env";

function getBearerToken(req: Request) {
  const header = req.header("Authorization");
  if (!header) return null;
  const [scheme, token] = header.split(" ");
  if (scheme?.toLowerCase() !== "bearer" || !token) return null;
  return token;
}

export async function requireAuth(req: Request, _res: Response, next: NextFunction) {
  try {
    const token = getBearerToken(req);
    if (!token) throw new ApiError("Unauthorized", 401);

    const claims = verifyAccessToken(token);

    const jti = claims.jti;
    const blacklistKey = `bl:${jti}`;

    // If this token was logged out, it will be present in Redis.
    const isBlacklisted = await redisClient.get(blacklistKey);
    if (isBlacklisted) throw new ApiError("Unauthorized", 401);

    req.auth = claims;
    return next();
  } catch (err) {
    // Ensure consistent status codes for auth failures.
    const status = err instanceof ApiError ? err.status : 401;
    return next(new ApiError("Unauthorized", status));
  }
}

export function requireRole(role: string) {
  return (req: Request, _res: Response, next: NextFunction) => {
    const userRole = req.auth?.role;
    if (!userRole) return next(new ApiError("Unauthorized", 401));
    if (userRole !== role) return next(new ApiError("Forbidden", 403));
    return next();
  };
}

export function requireAdmin(req: Request, res: Response, next: NextFunction) {
  return requireRole("admin")(req, res, next);
}

