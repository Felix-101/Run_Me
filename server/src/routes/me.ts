import { Router } from "express";
import { eq } from "drizzle-orm";
import { db } from "../db/client";
import { users } from "../db/schema";
import { requireAuth } from "../middleware/auth";
import { ApiError } from "../lib/errors";

const router = Router();

router.get("/", requireAuth, async (req, res, next) => {
  try {
    const auth = req.auth;
    if (!auth) throw new ApiError("Unauthorized", 401);

    const result = await db
      .select({
        id: users.id,
        email: users.email,
        role: users.role,
        createdAt: users.createdAt
      })
      .from(users)
      .where(eq(users.id, auth.sub))
      .limit(1);

    const user = result[0];
    if (!user) throw new ApiError("User not found", 404);

    return res.json(user);
  } catch (err) {
    return next(err);
  }
});

export default router;

