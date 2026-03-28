import { sql } from "drizzle-orm";
import {
  pgTable,
  text,
  uuid,
  timestamp,
  boolean,
  integer,
  doublePrecision,
  jsonb,
  index
} from "drizzle-orm/pg-core";

export const users = pgTable("users", {
  id: uuid("id").defaultRandom().primaryKey(),
  email: text("email").notNull().unique(),
  passwordHash: text("password_hash").notNull(),
  role: text("role").notNull().default("user"),
  displayName: text("display_name"),
  schoolName: text("school_name"),
  studentIdVerified: boolean("student_id_verified").notNull().default(false),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull()
});

export const refreshTokens = pgTable(
  "refresh_tokens",
  {
    id: uuid("id").defaultRandom().primaryKey(),
    userId: uuid("user_id")
      .notNull()
      .references(() => users.id, { onDelete: "cascade" }),
    jti: text("jti").notNull().unique(),
    expiresAt: timestamp("expires_at", { withTimezone: true }).notNull(),
    revokedAt: timestamp("revoked_at", { withTimezone: true })
  },
  (t) => [index("refresh_tokens_user_idx").on(t.userId)]
);

export const wallets = pgTable("wallets", {
  userId: uuid("user_id")
    .primaryKey()
    .references(() => users.id, { onDelete: "cascade" }),
  balanceNaira: doublePrecision("balance_naira").notNull().default(0)
});

export const bankAccounts = pgTable("bank_accounts", {
  id: uuid("id").defaultRandom().primaryKey(),
  userId: uuid("user_id")
    .notNull()
    .references(() => users.id, { onDelete: "cascade" }),
  accountNumber: text("account_number").notNull(),
  bankCode: text("bank_code").notNull(),
  accountName: text("account_name").notNull(),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull()
});

export const loans = pgTable(
  "loans",
  {
    id: uuid("id").defaultRandom().primaryKey(),
    borrowerId: uuid("borrower_id")
      .notNull()
      .references(() => users.id, { onDelete: "cascade" }),
    lenderId: uuid("lender_id").references(() => users.id, { onDelete: "set null" }),
    amount: doublePrecision("amount").notNull(),
    purpose: text("purpose").notNull(),
    durationDays: integer("duration_days").notNull(),
    interestRate: doublePrecision("interest_rate").notNull().default(0),
    status: text("status").notNull().default("pending"),
    audience: text("audience").notNull(),
    reason: text("reason"),
    proofFileUrl: text("proof_file_url"),
    repaidAmount: doublePrecision("repaid_amount").notNull().default(0),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull()
  },
  (t) => [
    index("loans_borrower_idx").on(t.borrowerId),
    index("loans_status_idx").on(t.status)
  ]
);

export const loanBackings = pgTable(
  "loan_backings",
  {
    id: uuid("id").defaultRandom().primaryKey(),
    loanId: uuid("loan_id")
      .notNull()
      .references(() => loans.id, { onDelete: "cascade" }),
    backerId: uuid("backer_id")
      .notNull()
      .references(() => users.id, { onDelete: "cascade" }),
    amountGuaranteed: doublePrecision("amount_guaranteed").notNull(),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull()
  },
  (t) => [index("loan_backings_loan_idx").on(t.loanId)]
);

export const grants = pgTable(
  "grants",
  {
    id: uuid("id").defaultRandom().primaryKey(),
    requesterId: uuid("requester_id")
      .notNull()
      .references(() => users.id, { onDelete: "cascade" }),
    title: text("title").notNull(),
    story: text("story").notNull(),
    goalNaira: doublePrecision("goal_naira").notNull(),
    raisedNaira: doublePrecision("raised_naira").notNull().default(0),
    category: text("category").notNull(),
    studentName: text("student_name").notNull(),
    isUrgent: boolean("is_urgent").notNull().default(false),
    attachmentUrls: jsonb("attachment_urls")
      .$type<string[]>()
      .notNull()
      .default(sql`'[]'::jsonb`),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull()
  },
  (t) => [index("grants_category_idx").on(t.category)]
);

export const grantDonations = pgTable(
  "grant_donations",
  {
    id: uuid("id").defaultRandom().primaryKey(),
    grantId: uuid("grant_id")
      .notNull()
      .references(() => grants.id, { onDelete: "cascade" }),
    donorId: uuid("donor_id")
      .notNull()
      .references(() => users.id, { onDelete: "cascade" }),
    amountNaira: doublePrecision("amount_naira").notNull(),
    anonymous: boolean("anonymous").notNull().default(false),
    donorDisplayName: text("donor_display_name").notNull(),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull()
  },
  (t) => [index("grant_donations_grant_idx").on(t.grantId)]
);

export const grantComments = pgTable(
  "grant_comments",
  {
    id: uuid("id").defaultRandom().primaryKey(),
    grantId: uuid("grant_id")
      .notNull()
      .references(() => grants.id, { onDelete: "cascade" }),
    authorName: text("author_name").notNull(),
    message: text("message").notNull(),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull()
  },
  (t) => [index("grant_comments_grant_idx").on(t.grantId)]
);

export const notifications = pgTable(
  "notifications",
  {
    id: uuid("id").defaultRandom().primaryKey(),
    userId: uuid("user_id")
      .notNull()
      .references(() => users.id, { onDelete: "cascade" }),
    title: text("title").notNull(),
    body: text("body").notNull(),
    read: boolean("read").notNull().default(false),
    type: text("type").notNull().default("general"),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull()
  },
  (t) => [index("notifications_user_idx").on(t.userId)]
);

export const auditLogs = pgTable("audit_logs", {
  id: uuid("id").defaultRandom().primaryKey(),
  actorId: uuid("actor_id").references(() => users.id, { onDelete: "set null" }),
  action: text("action").notNull(),
  resource: text("resource").notNull(),
  meta: jsonb("meta").$type<Record<string, unknown>>(),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull()
});
