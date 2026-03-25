import type { Config } from "drizzle-kit";

import dotenv from "dotenv";
import path from "path";

// Ensure Drizzle can read repo-root `.env` when running from the server workspace.
dotenv.config({ path: path.resolve(__dirname, "../..", ".env") });

const config: Config = {
  dialect: "postgresql",
  schema: ["./src/db/schema.ts"],
  out: "./drizzle",
  dbCredentials: {
    connectionString: process.env.DATABASE_URL!
  }
};

export default config;

