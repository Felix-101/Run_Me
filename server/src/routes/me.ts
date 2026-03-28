import { Router } from "express";
import { z } from "zod";
import { eq, and, desc, count } from "drizzle-orm";
import { db } from "../db/client";
import {
  users,
  wallets,
  bankAccounts,
  notifications,
  loans,
  grantDonations
} from "../db/schema";
import { requireAuth } from "../middleware/auth";
import { ApiError } from "../lib/errors";

const router = Router();

function trustLevel(score: number): "Low" | "Medium" | "High" {
  if (score < 40) return "Low";
  if (score < 70) return "Medium";
  return "High";
}

router.get("/", requireAuth, async (req, res, next) => {
  try {
    const auth = req.auth;
    if (!auth) throw new ApiError("Unauthorized", 401);

    const result = await db
      .select({
        id: users.id,
        email: users.email,
        role: users.role,
        createdAt: users.createdAt,
        displayName: users.displayName,
        schoolName: users.schoolName,
        studentIdVerified: users.studentIdVerified
      })
      .from(users)
      .where(eq(users.id, auth.sub))
      .limit(1);

    const user = result[0];
    if (!user) throw new ApiError("User not found", 404);

    return res.json({
      ...user,
      createdAt: user.createdAt.toISOString()
    });
  } catch (err) {
    return next(err);
  }
});

const patchMeSchema = z.object({
  displayName: z.string().min(1).max(200).optional(),
  schoolName: z.string().min(1).max(200).optional(),
  studentIdVerified: z.boolean().optional()
});

router.patch("/", requireAuth, async (req, res, next) => {
  try {
    const auth = req.auth;
    if (!auth) throw new ApiError("Unauthorized", 401);

    const body = patchMeSchema.parse(req.body);

    await db
      .update(users)
      .set({
        ...(body.displayName !== undefined ? { displayName: body.displayName } : {}),
        ...(body.schoolName !== undefined ? { schoolName: body.schoolName } : {}),
        ...(body.studentIdVerified !== undefined
          ? { studentIdVerified: body.studentIdVerified }
          : {})
      })
      .where(eq(users.id, auth.sub));

    const result = await db
      .select({
        id: users.id,
        email: users.email,
        role: users.role,
        createdAt: users.createdAt,
        displayName: users.displayName,
        schoolName: users.schoolName,
        studentIdVerified: users.studentIdVerified
      })
      .from(users)
      .where(eq(users.id, auth.sub))
      .limit(1);

    const user = result[0];
    if (!user) throw new ApiError("User not found", 404);

    return res.json({
      ...user,
      createdAt: user.createdAt.toISOString()
    });
  } catch (err) {
    return next(err);
  }
});

router.get("/trust-score", requireAuth, async (req, res, next) => {
  try {
    const auth = req.auth;
    if (!auth) throw new ApiError("Unauthorized", 401);

    const userRows = await db
      .select({ studentIdVerified: users.studentIdVerified })
      .from(users)
      .where(eq(users.id, auth.sub))
      .limit(1);
    const u = userRows[0];
    if (!u) throw new ApiError("User not found", 404);

    const repaid = await db
      .select({ c: count() })
      .from(loans)
      .where(and(eq(loans.borrowerId, auth.sub), eq(loans.status, "repaid")));

    const funded = await db
      .select({ c: count() })
      .from(loans)
      .where(and(eq(loans.borrowerId, auth.sub), eq(loans.status, "funded")));

    const donationsMade = await db
      .select({ c: count() })
      .from(grantDonations)
      .where(eq(grantDonations.donorId, auth.sub));

    const verificationScore = u.studentIdVerified ? 88 : 45;
    const repaymentScore = Math.min(100, 40 + Number(repaid[0]?.c ?? 0) * 15);
    const socialScore = Math.min(100, 50 + Number(funded[0]?.c ?? 0) * 5);
    const activityScore = Math.min(100, 60 + Math.min(20, Number(donationsMade[0]?.c ?? 0) * 4));

    const score = Math.round(
      verificationScore * 0.25 +
        repaymentScore * 0.35 +
        socialScore * 0.2 +
        activityScore * 0.2
    );

    return res.json({
      score,
      level: trustLevel(score),
      factors: {
        verificationScore,
        repaymentScore,
        socialScore,
        activityScore
      }
    });
  } catch (err) {
    return next(err);
  }
});

router.get("/wallet", requireAuth, async (req, res, next) => {
  try {
    const auth = req.auth;
    if (!auth) throw new ApiError("Unauthorized", 401);

    const rows = await db
      .select({ balanceNaira: wallets.balanceNaira })
      .from(wallets)
      .where(eq(wallets.userId, auth.sub))
      .limit(1);

    const balance = rows[0]?.balanceNaira ?? 0;

    return res.json({
      balanceNaira: balance,
      currency: "NGN"
    });
  } catch (err) {
    return next(err);
  }
});

const depositSchema = z.object({
  amountNaira: z.number().positive(),
  provider: z.string().optional(),
  callbackUrl: z.string().url().optional()
});

router.post("/wallet/deposits", requireAuth, async (req, res, next) => {
  try {
    depositSchema.parse(req.body);
    return res.json({
      status: "pending",
      redirectUrl: null,
      message: "Payment provider not configured; integrate Paystack/Stripe in production."
    });
  } catch (err) {
    return next(err);
  }
});

const withdrawalSchema = z.object({
  amountNaira: z.number().positive(),
  bankAccountId: z.string().uuid()
});

router.post("/wallet/withdrawals", requireAuth, async (req, res, next) => {
  try {
    withdrawalSchema.parse(req.body);
    return res.json({
      status: "pending",
      message: "Withdrawal pipeline not configured."
    });
  } catch (err) {
    return next(err);
  }
});

router.get("/bank-accounts", requireAuth, async (req, res, next) => {
  try {
    const auth = req.auth;
    if (!auth) throw new ApiError("Unauthorized", 401);

    const rows = await db
      .select({
        id: bankAccounts.id,
        accountNumber: bankAccounts.accountNumber,
        bankCode: bankAccounts.bankCode,
        accountName: bankAccounts.accountName,
        createdAt: bankAccounts.createdAt
      })
      .from(bankAccounts)
      .where(eq(bankAccounts.userId, auth.sub));

    return res.json({
      items: rows.map((r) => ({
        ...r,
        createdAt: r.createdAt.toISOString()
      }))
    });
  } catch (err) {
    return next(err);
  }
});

const bankAccountSchema = z.object({
  accountNumber: z.string().min(5).max(20),
  bankCode: z.string().min(2).max(10),
  accountName: z.string().min(2).max(200)
});

router.post("/bank-accounts", requireAuth, async (req, res, next) => {
  try {
    const auth = req.auth;
    if (!auth) throw new ApiError("Unauthorized", 401);

    const body = bankAccountSchema.parse(req.body);

    const inserted = await db
      .insert(bankAccounts)
      .values({
        userId: auth.sub,
        accountNumber: body.accountNumber,
        bankCode: body.bankCode,
        accountName: body.accountName
      })
      .returning({
        id: bankAccounts.id,
        accountNumber: bankAccounts.accountNumber,
        bankCode: bankAccounts.bankCode,
        accountName: bankAccounts.accountName,
        createdAt: bankAccounts.createdAt
      });

    const r = inserted[0];
    if (!r) throw new ApiError("Failed to create bank account", 500);

    return res.status(201).json({
      ...r,
      createdAt: r.createdAt.toISOString()
    });
  } catch (err) {
    return next(err);
  }
});

const notificationsQuerySchema = z.object({
  limit: z.coerce.number().min(1).max(100).optional().default(20),
  cursor: z.string().optional(),
  unreadOnly: z.coerce.boolean().optional().default(false)
});

router.get("/notifications", requireAuth, async (req, res, next) => {
  try {
    const auth = req.auth;
    if (!auth) throw new ApiError("Unauthorized", 401);

    const q = notificationsQuerySchema.parse(req.query);

    const limit = q.limit + 1;
    const notifConditions = [eq(notifications.userId, auth.sub)];
    if (q.unreadOnly) notifConditions.push(eq(notifications.read, false));

    const rows = await db
      .select({
        id: notifications.id,
        title: notifications.title,
        body: notifications.body,
        read: notifications.read,
        type: notifications.type,
        createdAt: notifications.createdAt
      })
      .from(notifications)
      .where(and(...notifConditions))
      .orderBy(desc(notifications.createdAt))
      .limit(limit);

    const hasMore = rows.length > q.limit;
    const slice = hasMore ? rows.slice(0, q.limit) : rows;
    const nextCursor =
      hasMore && slice.length > 0 ? slice[slice.length - 1]!.id : null;

    return res.json({
      items: slice.map((n) => ({
        id: n.id,
        title: n.title,
        body: n.body,
        read: n.read,
        type: n.type,
        createdAt: n.createdAt.toISOString()
      })),
      nextCursor
    });
  } catch (err) {
    return next(err);
  }
});

router.patch("/notifications/:id/read", requireAuth, async (req, res, next) => {
  try {
    const auth = req.auth;
    if (!auth) throw new ApiError("Unauthorized", 401);

    const id = z.string().uuid().parse(req.params.id);

    const updated = await db
      .update(notifications)
      .set({ read: true })
      .where(and(eq(notifications.id, id), eq(notifications.userId, auth.sub)))
      .returning({ id: notifications.id });

    if (updated.length === 0) throw new ApiError("Notification not found", 404);

    return res.json({ ok: true });
  } catch (err) {
    return next(err);
  }
});

export default router;
