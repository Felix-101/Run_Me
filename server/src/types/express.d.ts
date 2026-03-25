import type { AccessTokenClaims } from "../lib/jwt";

declare global {
  namespace Express {
    interface Request {
      auth?: AccessTokenClaims;
    }
  }
}

export {};

