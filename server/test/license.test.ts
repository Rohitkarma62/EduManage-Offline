import test from "node:test";
import assert from "node:assert/strict";
import { addDuration, deviceHash } from "../src/license.js";

test("calendar month duration clamps end-of-month dates", () => {
  assert.equal(addDuration(new Date("2026-01-31T10:00:00Z"), "1m").toISOString(), "2026-02-28T10:00:00.000Z");
});
test("year duration preserves leap day by clamping", () => {
  assert.equal(addDuration(new Date("2024-02-29T12:00:00Z"), "1y").toISOString(), "2025-02-28T12:00:00.000Z");
});
test("day durations use UTC calendar days", () => {
  assert.equal(addDuration(new Date("2026-10-31T10:00:00Z"), "3d").toISOString(), "2026-11-03T10:00:00.000Z");
});
test("device identifiers are hashed, not stored in clear text", () => {
  assert.match(deviceHash("stable-device-id"), /^[a-f0-9]{64}$/);
  assert.throws(() => deviceHash(" "));
});
