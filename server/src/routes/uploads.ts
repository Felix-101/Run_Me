import { Router } from "express";
import { z } from "zod";
import { requireAuth } from "../middleware/auth";
import { env } from "../config/env";

const router = Router();

const presignSchema = z.object({
  purpose: z.enum(["loan_proof", "grant_media"]),
  contentType: z.string().min(3).max(200),
  fileName: z.string().min(1).max(500)
});

router.post("/presign", requireAuth, async (req, res, next) => {
  try {
    presignSchema.parse(req.body);

    if (!process.env.STORAGE_BUCKET_URL) {
      return res.json({
        uploadUrl: `${env.SERVER_BASE_URL ?? "http://localhost:4000"}/__upload_placeholder`,
        fileUrl: `https://example.invalid/uploads/${Date.now()}-stub`,
        headers: {},
        message:
          "Set STORAGE_BUCKET_URL or integrate Supabase Storage / S3 presign; this is a development stub."
      });
    }

    return res.json({
      uploadUrl: "https://example.invalid/presigned-put",
      fileUrl: "https://example.invalid/object",
      headers: {}
    });
  } catch (err) {
    return next(err);
  }
});

export default router;
