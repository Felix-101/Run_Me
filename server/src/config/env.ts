import { z } from "zod";

/** Upstash/console often shows `redis-cli --tls -u redis://...` — Node needs only the URL part. */
function extractRedisConnectionUrl(raw: string): string {
  const s = raw.trim();
  const m = s.match(/(rediss?:\/\/[^\s'"]+)/i);
  return m ? m[1] : s;
}

const EnvSchema = z.object({
  NODE_ENV: z.enum(["development", "test", "production"]).default("development"),
  /** Koyeb/Heroku often set `PORT`; `SERVER_PORT` wins if both are set. */
  PORT: z.coerce.number().optional(),
  SERVER_PORT: z.coerce.number().optional(),
  SERVER_BASE_URL: z.string().optional(),

  CORS_ORIGIN: z.string().optional().default("*"),

  DATABASE_URL: z.string().min(1),
  /** TCP Redis URL — `redis://` or `rediss://`. Not `https://` REST; not the full `redis-cli` command (we strip the URL from it if pasted). */
  REDIS_URL: z.preprocess(
    (val) => (typeof val === "string" ? extractRedisConnectionUrl(val) : val),
    z
      .string()
      .min(1)
      .refine((u) => /^rediss?:\/\//i.test(u), {
        message:
          "Must be a Redis URL starting with redis:// or rediss://. Do not paste the whole `redis-cli --tls -u ...` line — only the URL after -u (or use rediss:// for TLS)."
      })
      .refine((u) => !/\s/.test(u), {
        message: "REDIS_URL must not contain spaces. Paste only the connection URL."
      })
  ),

  JWT_ACCESS_SECRET: z.string().min(1),
  JWT_ACCESS_EXPIRES_IN: z.string().default("1h"),

  JWT_REFRESH_SECRET: z.string().min(1),
  JWT_REFRESH_EXPIRES_IN: z.string().default("7d"),

  BCRYPT_SALT_ROUNDS: z.coerce.number().default(10),

  // Dev bootstrap: server will create this admin if missing.
  ADMIN_EMAIL: z.string().email().optional(),
  ADMIN_PASSWORD: z.string().min(6).optional()
});

const parsed = EnvSchema.safeParse(process.env);

if (!parsed.success) {
  // eslint-disable-next-line no-console
  console.error("Invalid env:", parsed.error.flatten().fieldErrors);
  throw new Error(
    "Invalid environment variables. For production you must set: DATABASE_URL, REDIS_URL, " +
      "JWT_ACCESS_SECRET, JWT_REFRESH_SECRET (see docs/SERVER_ENV.md). On Koyeb: Service → Environment."
  );
}

const raw = parsed.data;
const serverPort = raw.SERVER_PORT ?? raw.PORT ?? 4000;

export const env = {
  ...raw,
  SERVER_PORT: serverPort
};

export const corsOrigins = env.CORS_ORIGIN === "*"
  ? "*"
  : env.CORS_ORIGIN.split(",").map((s) => s.trim()).filter(Boolean);

