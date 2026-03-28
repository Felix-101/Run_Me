import { Router } from "express";
import { z } from "zod";
import { eq, and, desc, ne } from "drizzle-orm";
import { db } from "../db/client";
import { grants, grantDonations, grantComments, users } from "../db/schema";
import { requireAuth } from "../middleware/auth";
import { ApiError } from "../lib/errors";
import { decodeOffsetCursor, encodeOffsetCursor } from "../lib/pagination";

const router = Router();

const grantCategory = z.enum(["studentStory", "urgentNeed", "education"]);

function serializeGrant(row: typeof grants.$inferSelect) {
  return {
    id: row.id,
    title: row.title,
    story: row.story,
    goalNaira: row.goalNaira,
    raisedNaira: row.raisedNaira,
    category: row.category,
    studentName: row.studentName,
    createdAt: row.createdAt.toISOString(),
    attachmentUrls: row.attachmentUrls ?? [],
    isUrgent: row.isUrgent
  };
}

const listQuerySchema = z.object({
  category: grantCategory.optional(),
  urgentOnly: z.coerce.boolean().optional().default(false),
  excludeBorrowerId: z.string().uuid().optional(),
  limit: z.coerce.number().min(1).max(100).optional().default(20),
  cursor: z.string().optional()
});

router.get("/", requireAuth, async (req, res, next) => {
  try {
    const q = listQuerySchema.parse(req.query);
    const limit = q.limit + 1;
    const offset = decodeOffsetCursor(q.cursor);

    const conditions = [];
    if (q.category) conditions.push(eq(grants.category, q.category));
    if (q.urgentOnly) conditions.push(eq(grants.isUrgent, true));
    if (q.excludeBorrowerId) {
      conditions.push(ne(grants.requesterId, q.excludeBorrowerId));
    }

    const whereClause = conditions.length > 0 ? and(...conditions) : undefined;

    const rows = await (whereClause
      ? db
          .select()
          .from(grants)
          .where(whereClause)
          .orderBy(desc(grants.createdAt))
          .limit(limit)
          .offset(offset)
      : db.select().from(grants).orderBy(desc(grants.createdAt)).limit(limit).offset(offset));

    const hasMore = rows.length > q.limit;
    const slice = hasMore ? rows.slice(0, q.limit) : rows;
    const nextCursor = hasMore ? encodeOffsetCursor(offset + q.limit) : null;

    return res.json({
      items: slice.map(serializeGrant),
      nextCursor
    });
  } catch (err) {
    return next(err);
  }
});

const createGrantSchema = z.object({
  title: z.string().min(1).max(300),
  story: z.string().min(1).max(10000),
  goalNaira: z.number().positive(),
  category: grantCategory,
  studentName: z.string().min(1).max(200),
  isUrgent: z.boolean().optional(),
  attachmentUrls: z.array(z.string().url()).optional()
});

router.post("/", requireAuth, async (req, res, next) => {
  try {
    const auth = req.auth;
    if (!auth) throw new ApiError("Unauthorized", 401);

    const body = createGrantSchema.parse(req.body);

    const inserted = await db
      .insert(grants)
      .values({
        requesterId: auth.sub,
        title: body.title,
        story: body.story,
        goalNaira: body.goalNaira,
        category: body.category,
        studentName: body.studentName,
        isUrgent: body.isUrgent ?? false,
        attachmentUrls: body.attachmentUrls ?? []
      })
      .returning();

    const row = inserted[0];
    if (!row) throw new ApiError("Failed to create grant", 500);

    return res.status(201).json(serializeGrant(row));
  } catch (err) {
    return next(err);
  }
});

router.get("/:grantId/donations", requireAuth, async (req, res, next) => {
  try {
    const grantId = z.string().uuid().parse(req.params.grantId);

    const g = await db.select().from(grants).where(eq(grants.id, grantId)).limit(1);
    if (!g[0]) throw new ApiError("Grant not found", 404);

    const rows = await db
      .select({
        id: grantDonations.id,
        grantId: grantDonations.grantId,
        donorId: grantDonations.donorId,
        donorDisplayName: grantDonations.donorDisplayName,
        amountNaira: grantDonations.amountNaira,
        createdAt: grantDonations.createdAt
      })
      .from(grantDonations)
      .where(eq(grantDonations.grantId, grantId))
      .orderBy(desc(grantDonations.createdAt));

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

const donateSchema = z.object({
  amountNaira: z.number().positive(),
  anonymous: z.boolean().optional()
});

router.post("/:grantId/donations", requireAuth, async (req, res, next) => {
  try {
    const auth = req.auth;
    if (!auth) throw new ApiError("Unauthorized", 401);

    const grantId = z.string().uuid().parse(req.params.grantId);
    const body = donateSchema.parse(req.body);

    const userRows = await db
      .select({ displayName: users.displayName, email: users.email })
      .from(users)
      .where(eq(users.id, auth.sub))
      .limit(1);
    const u = userRows[0];
    if (!u) throw new ApiError("User not found", 404);

    const displayName = body.anonymous ? "Anonymous" : u.displayName ?? u.email.split("@")[0] ?? "Supporter";

    const result = await db.transaction(async (tx) => {
      const gRows = await tx.select().from(grants).where(eq(grants.id, grantId)).limit(1);
      const grant = gRows[0];
      if (!grant) throw new ApiError("Grant not found", 404);

      const donationRows = await tx
        .insert(grantDonations)
        .values({
          grantId,
          donorId: auth.sub,
          amountNaira: body.amountNaira,
          anonymous: body.anonymous ?? false,
          donorDisplayName: displayName
        })
        .returning({
          id: grantDonations.id,
          grantId: grantDonations.grantId,
          donorId: grantDonations.donorId,
          donorDisplayName: grantDonations.donorDisplayName,
          amountNaira: grantDonations.amountNaira,
          createdAt: grantDonations.createdAt
        });

      const d = donationRows[0];
      if (!d) throw new ApiError("Failed to donate", 500);

      const newRaised = grant.raisedNaira + body.amountNaira;
      await tx.update(grants).set({ raisedNaira: newRaised }).where(eq(grants.id, grantId));

      return { donation: d, raisedNaira: newRaised };
    });

    return res.status(201).json({
      ...result.donation,
      createdAt: result.donation.createdAt.toISOString(),
      raisedNaira: result.raisedNaira
    });
  } catch (err) {
    return next(err);
  }
});

router.get("/:grantId/comments", requireAuth, async (req, res, next) => {
  try {
    const grantId = z.string().uuid().parse(req.params.grantId);

    const g = await db.select().from(grants).where(eq(grants.id, grantId)).limit(1);
    if (!g[0]) throw new ApiError("Grant not found", 404);

    const rows = await db
      .select({
        id: grantComments.id,
        authorName: grantComments.authorName,
        message: grantComments.message,
        createdAt: grantComments.createdAt
      })
      .from(grantComments)
      .where(eq(grantComments.grantId, grantId))
      .orderBy(desc(grantComments.createdAt));

    return res.json({
      items: rows.map((r) => ({
        id: r.id,
        authorName: r.authorName,
        message: r.message,
        createdAt: r.createdAt.toISOString()
      }))
    });
  } catch (err) {
    return next(err);
  }
});

const commentSchema = z.object({
  authorName: z.string().min(1).max(120),
  message: z.string().min(1).max(2000)
});

router.post("/:grantId/comments", requireAuth, async (req, res, next) => {
  try {
    const grantId = z.string().uuid().parse(req.params.grantId);
    const body = commentSchema.parse(req.body);

    const g = await db.select().from(grants).where(eq(grants.id, grantId)).limit(1);
    if (!g[0]) throw new ApiError("Grant not found", 404);

    const inserted = await db
      .insert(grantComments)
      .values({
        grantId,
        authorName: body.authorName,
        message: body.message
      })
      .returning({
        id: grantComments.id,
        authorName: grantComments.authorName,
        message: grantComments.message,
        createdAt: grantComments.createdAt
      });

    const row = inserted[0];
    if (!row) throw new ApiError("Failed to post comment", 500);

    return res.status(201).json({
      id: row.id,
      authorName: row.authorName,
      message: row.message,
      createdAt: row.createdAt.toISOString()
    });
  } catch (err) {
    return next(err);
  }
});

router.get("/:grantId", requireAuth, async (req, res, next) => {
  try {
    const grantId = z.string().uuid().parse(req.params.grantId);

    const rows = await db.select().from(grants).where(eq(grants.id, grantId)).limit(1);
    const row = rows[0];
    if (!row) throw new ApiError("Grant not found", 404);

    return res.json(serializeGrant(row));
  } catch (err) {
    return next(err);
  }
});

export default router;
