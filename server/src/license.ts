import { createHash, createPrivateKey, sign } from "node:crypto";

export const DURATIONS = ["1d", "3d", "7d", "1m", "3m", "6m", "1y"] as const;
export type LicenseDuration = typeof DURATIONS[number];

export function addDuration(start: Date, duration: LicenseDuration): Date {
  const result = new Date(start);
  const days: Record<"1d" | "3d" | "7d", number> = { "1d": 1, "3d": 3, "7d": 7 };
  if (duration in days) {
    result.setUTCDate(result.getUTCDate() + days[duration as keyof typeof days]);
    return result;
  }
  const months: Record<"1m" | "3m" | "6m" | "1y", number> =
    { "1m": 1, "3m": 3, "6m": 6, "1y": 12 };
  const count = months[duration as keyof typeof months];
  const day = result.getUTCDate();
  result.setUTCDate(1);
  result.setUTCMonth(result.getUTCMonth() + count);
  const lastDay = new Date(Date.UTC(result.getUTCFullYear(), result.getUTCMonth() + 1, 0)).getUTCDate();
  result.setUTCDate(Math.min(day, lastDay));
  return result;
}

export function deviceHash(deviceId: string): string {
  if (!deviceId.trim() || deviceId.length > 512) throw new Error("Invalid device identifier.");
  return createHash("sha256").update(deviceId, "utf8").digest("hex");
}

export function signClaims(claims: Record<string, unknown>, privatePem: string): string {
  const payload = Buffer.from(JSON.stringify(claims), "utf8");
  const signature = sign(null, payload, createPrivateKey(privatePem));
  return `${payload.toString("base64url")}.${signature.toString("base64url")}`;
}
