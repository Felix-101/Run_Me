import { sign, verify } from "jsonwebtoken";
import { env } from "../config/env";

export type AccessTokenClaims = {
  sub: string;
  role: string;
  email: string;
  jti: string;
  exp?: number;
};

export function signAccessToken(input: {
  userId: string;
  role: string;
  email: string;
  jti: string;
}) {
  return sign(
    {
      sub: input.userId,
      role: input.role,
      email: input.email,
      jti: input.jti
    },
    env.JWT_ACCESS_SECRET,
    {
      // `expiresIn` is typed as `StringValue | number` (from `ms`), so we cast here
      // because env parsing keeps this as a plain string.
      expiresIn: env.JWT_ACCESS_EXPIRES_IN as any,
      jwtid: input.jti
    }
  );
}

export function verifyAccessToken(token: string): AccessTokenClaims {
  const decoded = verify(token, env.JWT_ACCESS_SECRET) as AccessTokenClaims;
  if (!decoded?.sub || !decoded?.jti) {
    throw new Error("Invalid token claims");
  }
  return decoded;
}

