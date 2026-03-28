import { Router } from "express";
import { z } from "zod";
import { eq, desc, count } from "drizzle-orm";
import { users, loans, grants, auditLogs } from "../db/schema";
import { db } from "../db/client";
import { redisClient } from "../lib/redis";
import { requireAuth, requireAdmin } from "../middleware/auth";
import { decodeOffsetCursor, encodeOffsetCursor } from "../lib/pagination";

const router = Router();

router.get("/summary", requireAuth, requireAdmin, async (_req, res, next) => {
  try {
    const cacheKey = "admin:summary";
    const cached = await redisClient.get(cacheKey);
    if (cached) {
      return res.json(JSON.parse(cached));
    }

    const result = await db.select({ usersCount: count(users.id) }).from(users);
    const usersCount = result[0]?.usersCount ?? 0;

    const summary = {
      usersCount,
      generatedAt: new Date().toISOString()
    };

    await redisClient.setEx(cacheKey, 30, JSON.stringify(summary));

    return res.json(summary);
  } catch (err) {
    return next(err);
  }
});

const listQuerySchema = z.object({
  limit: z.coerce.number().min(1).max(100).optional().default(50),
  cursor: z.string().optional()
});

router.get("/users", requireAuth, requireAdmin, async (req, res, next) => {
  try {
    const q = listQuerySchema.parse(req.query);
    const limit = q.limit + 1;
    const offset = decodeOffsetCursor(q.cursor);

    const rows = await db
      .select({
        id: users.id,
        email: users.email,
        role: users.role,
        displayName: users.displayName,
        schoolName: users.schoolName,
        studentIdVerified: users.studentIdVerified,
        createdAt: users.createdAt
      })
      .from(users)
      .orderBy(desc(users.createdAt))
      .limit(limit)
      .offset(offset);

    const hasMore = rows.length > q.limit;
    const slice = hasMore ? rows.slice(0, q.limit) : rows;
    const nextCursor = hasMore ? encodeOffsetCursor(offset + q.limit) : null;

    return res.json({
      items: slice.map((u) => ({
        ...u,
        createdAt: u.createdAt.toISOString()
      })),
      nextCursor
    });
  } catch (err) {
    return next(err);
  }
});

router.get("/loans", requireAuth, requireAdmin, async (req, res, next) => {
  try {
    const q = listQuerySchema.parse(req.query);
    const limit = q.limit + 1;
    const offset = decodeOffsetCursor(q.cursor);

    const rows = await db
      .select()
      .from(loans)
      .orderBy(desc(loans.createdAt))
      .limit(limit)
      .offset(offset);

    const hasMore = rows.length > q.limit;
    const slice = hasMore ? rows.slice(0, q.limit) : rows;
    const nextCursor = hasMore ? encodeOffsetCursor(offset + q.limit) : null;

    return res.json({
      items: slice.map((l) => ({
        id: l.id,
        borrowerId: l.borrowerId,
        lenderId: l.lenderId,
        amount: l.amount,
        purpose: l.purpose,
        durationDays: l.durationDays,
        interestRate: l.interestRate,
        status: l.status,
        audience: l.audience,
        reason: l.reason,
        proofFileUrl: l.proofFileUrl,
        repaidAmount: l.repaidAmount,
        createdAt: l.createdAt.toISOString()
      })),
      nextCursor
    });
  } catch (err) {
    return next(err);
  }
});

router.get("/grants", requireAuth, requireAdmin, async (req, res, next) => {
  try {
    const q = listQuerySchema.parse(req.query);
    const limit = q.limit + 1;
    const offset = decodeOffsetCursor(q.cursor);

    const rows = await db
      .select()
      .from(grants)
      .orderBy(desc(grants.createdAt))
      .limit(limit)
      .offset(offset);

    const hasMore = rows.length > q.limit;
    const slice = hasMore ? rows.slice(0, q.limit) : rows;
    const nextCursor = hasMore ? encodeOffsetCursor(offset + q.limit) : null;

    return res.json({
      items: slice.map((g) => ({
        id: g.id,
        requesterId: g.requesterId,
        title: g.title,
        story: g.story,
        goalNaira: g.goalNaira,
        raisedNaira: g.raisedNaira,
        category: g.category,
        studentName: g.studentName,
        isUrgent: g.isUrgent,
        attachmentUrls: g.attachmentUrls ?? [],
        createdAt: g.createdAt.toISOString()
      })),
      nextCursor
    });
  } catch (err) {
    return next(err);
  }
});

router.get("/audit", requireAuth, requireAdmin, async (req, res, next) => {
  try {
    const q = listQuerySchema.parse(req.query);
    const limit = q.limit + 1;
    const offset = decodeOffsetCursor(q.cursor);

    const rows = await db
      .select()
      .from(auditLogs)
      .orderBy(desc(auditLogs.createdAt))
      .limit(limit)
      .offset(offset);

    const hasMore = rows.length > q.limit;
    const slice = hasMore ? rows.slice(0, q.limit) : rows;
    const nextCursor = hasMore ? encodeOffsetCursor(offset + q.limit) : null;

    return res.json({
      items: slice.map((a) => ({
        id: a.id,
        actorId: a.actorId,
        action: a.action,
        resource: a.resource,
        meta: a.meta ?? {},
        createdAt: a.createdAt.toISOString()
      })),
      nextCursor
    });
  } catch (err) {
    return next(err);
  }
});

export default router;
