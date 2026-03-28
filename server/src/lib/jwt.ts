import { sign, verify } from "jsonwebtoken";
import { env } from "../config/env";

export type AccessTokenClaims = {
  sub: string;
  role: string;
  email: string;
  jti: string;
  exp?: number;
};

export type RefreshTokenClaims = {
  sub: string;
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
      expiresIn: env.JWT_ACCESS_EXPIRES_IN as any
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

export function signRefreshToken(input: { userId: string; jti: string }) {
  return sign({ sub: input.userId, jti: input.jti }, env.JWT_REFRESH_SECRET, {
    expiresIn: env.JWT_REFRESH_EXPIRES_IN as any
  });
}

export function verifyRefreshToken(token: string): RefreshTokenClaims {
  const decoded = verify(token, env.JWT_REFRESH_SECRET) as RefreshTokenClaims;
  if (!decoded?.sub || !decoded?.jti) {
    throw new Error("Invalid refresh token claims");
  }
  return decoded;
}
