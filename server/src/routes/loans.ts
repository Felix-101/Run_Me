import { Router } from "express";
import { z } from "zod";
import { eq, and, desc, sum } from "drizzle-orm";
import { db } from "../db/client";
import { loans, loanBackings } from "../db/schema";
import { requireAuth } from "../middleware/auth";
import { ApiError } from "../lib/errors";
import { decodeOffsetCursor, encodeOffsetCursor } from "../lib/pagination";

const router = Router();

const loanPurpose = z.enum(["rent", "food", "emergency"]);
const loanStatus = z.enum(["pending", "funded", "repaid"]);
const loanAudience = z.enum(["public", "friendsOnly"]);

function serializeLoan(row: typeof loans.$inferSelect) {
  return {
    id: row.id,
    borrowerId: row.borrowerId,
    lenderId: row.lenderId,
    amount: row.amount,
    purpose: row.purpose,
    durationDays: row.durationDays,
    interestRate: row.interestRate,
    status: row.status,
    createdAt: row.createdAt.toISOString(),
    audience: row.audience,
    reason: row.reason,
    proofFileUrl: row.proofFileUrl,
    repaidAmount: row.repaidAmount
  };
}

const listQuerySchema = z.object({
  borrowerId: z.string().uuid().optional(),
  status: loanStatus.optional(),
  limit: z.coerce.number().min(1).max(100).optional().default(20),
  cursor: z.string().optional()
});

router.get("/", requireAuth, async (req, res, next) => {
  try {
    const q = listQuerySchema.parse(req.query);
    const limit = q.limit + 1;
    const offset = decodeOffsetCursor(q.cursor);

    const conditions = [];
    if (q.borrowerId) conditions.push(eq(loans.borrowerId, q.borrowerId));
    if (q.status) conditions.push(eq(loans.status, q.status));

    const whereClause = conditions.length > 0 ? and(...conditions) : undefined;

    const rows = await (whereClause
      ? db
          .select()
          .from(loans)
          .where(whereClause)
          .orderBy(desc(loans.createdAt), desc(loans.id))
          .limit(limit)
          .offset(offset)
      : db
          .select()
          .from(loans)
          .orderBy(desc(loans.createdAt), desc(loans.id))
          .limit(limit)
          .offset(offset));

    const hasMore = rows.length > q.limit;
    const slice = hasMore ? rows.slice(0, q.limit) : rows;
    const nextCursor = hasMore ? encodeOffsetCursor(offset + q.limit) : null;

    return res.json({
      items: slice.map(serializeLoan),
      nextCursor
    });
  } catch (err) {
    return next(err);
  }
});

router.get("/:loanId/coverage", requireAuth, async (req, res, next) => {
  try {
    const loanId = z.string().uuid().parse(req.params.loanId);

    const loanRows = await db.select().from(loans).where(eq(loans.id, loanId)).limit(1);
    const loan = loanRows[0];
    if (!loan) throw new ApiError("Loan not found", 404);

    const sumRows = await db
      .select({ total: sum(loanBackings.amountGuaranteed) })
      .from(loanBackings)
      .where(eq(loanBackings.loanId, loanId));

    const totalGuaranteed = Number(sumRows[0]?.total ?? 0);
    const principal = loan.amount;
    const coverageRatio = principal > 0 ? totalGuaranteed / principal : 0;

    return res.json({
      principal,
      totalGuaranteed,
      coverageRatio
    });
  } catch (err) {
    return next(err);
  }
});

router.get("/:loanId/backings", requireAuth, async (req, res, next) => {
  try {
    const loanId = z.string().uuid().parse(req.params.loanId);

    const loanRows = await db.select().from(loans).where(eq(loans.id, loanId)).limit(1);
    if (!loanRows[0]) throw new ApiError("Loan not found", 404);

    const rows = await db
      .select({
        id: loanBackings.id,
        loanId: loanBackings.loanId,
        backerId: loanBackings.backerId,
        amountGuaranteed: loanBackings.amountGuaranteed
      })
      .from(loanBackings)
      .where(eq(loanBackings.loanId, loanId));

    return res.json({ items: rows });
  } catch (err) {
    return next(err);
  }
});

const createBackingSchema = z.object({
  amountGuaranteed: z.number().positive()
});

router.post("/:loanId/backings", requireAuth, async (req, res, next) => {
  try {
    const auth = req.auth;
    if (!auth) throw new ApiError("Unauthorized", 401);

    const loanId = z.string().uuid().parse(req.params.loanId);
    const body = createBackingSchema.parse(req.body);

    const loanRows = await db.select().from(loans).where(eq(loans.id, loanId)).limit(1);
    const loan = loanRows[0];
    if (!loan) throw new ApiError("Loan not found", 404);
    if (loan.status === "repaid") throw new ApiError("Loan already repaid", 409);

    const inserted = await db
      .insert(loanBackings)
      .values({
        loanId,
        backerId: auth.sub,
        amountGuaranteed: body.amountGuaranteed
      })
      .returning({
        id: loanBackings.id,
        loanId: loanBackings.loanId,
        backerId: loanBackings.backerId,
        amountGuaranteed: loanBackings.amountGuaranteed
      });

    const backing = inserted[0];
    if (!backing) throw new ApiError("Failed to create backing", 500);

    const sumRows = await db
      .select({ total: sum(loanBackings.amountGuaranteed) })
      .from(loanBackings)
      .where(eq(loanBackings.loanId, loanId));

    const totalGuaranteed = Number(sumRows[0]?.total ?? 0);

    if (totalGuaranteed >= loan.amount && loan.status === "pending") {
      await db
        .update(loans)
        .set({
          status: "funded",
          lenderId: auth.sub
        })
        .where(eq(loans.id, loanId));
    }

    return res.status(201).json(backing);
  } catch (err) {
    return next(err);
  }
});

const createLoanSchema = z.object({
  amount: z.number().positive(),
  purpose: loanPurpose,
  durationDays: z.number().int().min(7).max(365),
  audience: loanAudience,
  reason: z.string().max(2000).optional(),
  proofFileUrl: z.string().url().optional().nullable()
});

router.post("/", requireAuth, async (req, res, next) => {
  try {
    const auth = req.auth;
    if (!auth) throw new ApiError("Unauthorized", 401);

    const body = createLoanSchema.parse(req.body);

    const inserted = await db
      .insert(loans)
      .values({
        borrowerId: auth.sub,
        amount: body.amount,
        purpose: body.purpose,
        durationDays: body.durationDays,
        audience: body.audience,
        reason: body.reason ?? null,
        proofFileUrl: body.proofFileUrl ?? null,
        status: "pending",
        repaidAmount: 0
      })
      .returning();

    const row = inserted[0];
    if (!row) throw new ApiError("Failed to create loan", 500);

    return res.status(201).json(serializeLoan(row));
  } catch (err) {
    return next(err);
  }
});

router.get("/:loanId", requireAuth, async (req, res, next) => {
  try {
    const loanId = z.string().uuid().parse(req.params.loanId);

    const rows = await db.select().from(loans).where(eq(loans.id, loanId)).limit(1);
    const row = rows[0];
    if (!row) throw new ApiError("Loan not found", 404);

    return res.json(serializeLoan(row));
  } catch (err) {
    return next(err);
  }
});

const repaymentSchema = z.object({
  amount: z.number().positive()
});

router.post("/:loanId/repayments", requireAuth, async (req, res, next) => {
  try {
    const auth = req.auth;
    if (!auth) throw new ApiError("Unauthorized", 401);

    const loanId = z.string().uuid().parse(req.params.loanId);
    const body = repaymentSchema.parse(req.body);

    const loanRows = await db.select().from(loans).where(eq(loans.id, loanId)).limit(1);
    const loan = loanRows[0];
    if (!loan) throw new ApiError("Loan not found", 404);
    if (loan.borrowerId !== auth.sub) throw new ApiError("Forbidden", 403);
    if (loan.status === "pending") throw new ApiError("Loan is not funded yet", 409);
    if (loan.status === "repaid") throw new ApiError("Loan already repaid", 409);

    const outstanding = loan.amount - loan.repaidAmount;
    if (body.amount > outstanding + 1e-9) {
      throw new ApiError("Amount exceeds outstanding balance", 400);
    }

    const newRepaid = loan.repaidAmount + body.amount;
    const newStatus = newRepaid >= loan.amount - 1e-9 ? "repaid" : loan.status;

    const updated = await db
      .update(loans)
      .set({
        repaidAmount: newRepaid,
        status: newStatus
      })
      .where(eq(loans.id, loanId))
      .returning();

    const row = updated[0];
    if (!row) throw new ApiError("Failed to apply repayment", 500);

    return res.json(serializeLoan(row));
  } catch (err) {
    return next(err);
  }
});

export default router;
