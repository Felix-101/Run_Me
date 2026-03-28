import { Buffer } from "buffer";

/** Opaque cursor encoding a numeric offset (simple pagination). */
export function decodeOffsetCursor(cursor?: string): number {
  if (!cursor) return 0;
  try {
    const j = JSON.parse(Buffer.from(cursor, "base64url").toString("utf8")) as { o?: unknown };
    if (typeof j.o !== "number" || !Number.isFinite(j.o) || j.o < 0) return 0;
    return Math.floor(j.o);
  } catch {
    return 0;
  }
}

export function encodeOffsetCursor(offset: number): string {
  return Buffer.from(JSON.stringify({ o: offset }), "utf8").toString("base64url");
}
