import Fastify from "fastify";
import rateLimit from "@fastify/rate-limit";
import { Pool } from "pg";
import { SignJWT } from "jose";
import argon2 from "argon2";
import { createPrivateKey, createPublicKey, randomUUID, verify as verifySignature } from "node:crypto";
import { z } from "zod";
import { addDuration, deviceHash, DURATIONS, signClaims } from "./license.js";

const env = z.object({
  PORT: z.coerce.number().int().positive().default(8080),
  DATABASE_URL: z.string().url(),
  JWT_SECRET: z.string().min(32),
  ADMIN_EMAIL: z.string().email(),
  ADMIN_PASSWORD_HASH: z.string().startsWith("$argon2"),
  LICENSE_SIGNING_PRIVATE_KEY_PEM: z.string().min(80),
}).parse(process.env);

const pool = new Pool({ connectionString: env.DATABASE_URL, max: 10, ssl: process.env.NODE_ENV === "production" ? { rejectUnauthorized: true } : undefined });
const app = Fastify({ logger: true, bodyLimit: 16 * 1024, trustProxy: false });
await app.register(rateLimit, { max: 60, timeWindow: "1 minute" });

const loginBody = z.object({ email: z.string().email(), password: z.string().min(1).max(256) });
const issueBody = z.object({ customer: z.string().trim().min(1).max(200), duration: z.enum(DURATIONS) });
const activateBody = z.object({ device_id: z.string().min(1).max(512), token: z.string().min(20).max(8192) });
const validateBody = z.object({ device_id: z.string().min(1).max(512), token: z.string().min(20).max(8192) });


function verifyLicenseToken(token: string): Record<string, unknown> | null {
  try {
    const parts = token.split(".");
    if (parts.length !== 2) return null;
    const payload = Buffer.from(parts[0]!, "base64url");
    const signature = Buffer.from(parts[1]!, "base64url");
    const publicKey = createPublicKey(createPrivateKey(env.LICENSE_SIGNING_PRIVATE_KEY_PEM));
    if (!verifySignature(null, payload, publicKey, signature)) return null;
    const claims: unknown = JSON.parse(payload.toString("utf8"));
    return claims && typeof claims === "object" && !Array.isArray(claims)
      ? claims as Record<string, unknown> : null;
  } catch { return null; }
}

function bearer(request: { headers: { authorization?: string } }): string | null {
  const value = request.headers.authorization;
  return value?.startsWith("Bearer ") ? value.slice(7) : null;
}
async function requireAdmin(request: any, reply: any): Promise<string | null> {
  const token = bearer(request);
  if (!token) { await reply.code(401).send({ error: "unauthorized" }); return null; }
  try {
    const { jwtVerify } = await import("jose");
    const verified = await jwtVerify(token, new TextEncoder().encode(env.JWT_SECRET), { issuer: "edumanage-licensing", audience: "licensing-admin" });
    request.adminEmail = verified.payload.sub;
    return true;
  } catch { await reply.code(401).send({ error: "unauthorized" }); return null; }
}

app.get("/health", async () => ({ status: "ok" }));

app.post("/v1/admin/login", { config: { rateLimit: { max: 5, timeWindow: "1 minute" } } }, async (request, reply) => {
  const parsed = loginBody.safeParse(request.body);
  if (!parsed.success) return reply.code(400).send({ error: "invalid_request" });
  const emailMatches = parsed.data.email.toLowerCase() === env.ADMIN_EMAIL.toLowerCase();
  const passwordMatches = await argon2.verify(env.ADMIN_PASSWORD_HASH, parsed.data.password).catch(() => false);
  if (!emailMatches || !passwordMatches) return reply.code(401).send({ error: "invalid_credentials" });
  const token = await new SignJWT({ role: "admin" }).setProtectedHeader({ alg: "HS256" })
    .setSubject(env.ADMIN_EMAIL.toLowerCase()).setIssuer("edumanage-licensing")
    .setAudience("licensing-admin").setIssuedAt().setExpirationTime("8h")
    .sign(new TextEncoder().encode(env.JWT_SECRET));
  return { access_token: token, token_type: "Bearer", expires_in: 28800 };
});

app.post("/v1/licenses", async (request, reply) => {
  const adminEmail = await requireAdmin(request, reply);\n  if (!adminEmail) return;
  const parsed = issueBody.safeParse(request.body);
  if (!parsed.success) return reply.code(400).send({ error: "invalid_request" });
  const id = randomUUID();
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const row = (await client.query(
      "INSERT INTO licenses (id, customer, duration) VALUES ($1,$2,$3) RETURNING *",
      [id, parsed.data.customer, parsed.data.duration],
    )).rows[0];
    await client.query("INSERT INTO license_audit_events (license_id,event_type,actor) VALUES ($1,'issued',$2)", [id, adminEmail]);
    await client.query("COMMIT");
    const token = signClaims({ license_id: id, customer: row.customer, device_limit: 1,
      issued_at: Math.floor(new Date(row.issued_at).getTime()/1000), activated_at: null,
      expires_at: null, device_id_hash: null, duration: row.duration }, env.LICENSE_SIGNING_PRIVATE_KEY_PEM);
    return reply.code(201).send({ license_id: id, customer: row.customer, duration: row.duration, status: "unactivated", token });
  } catch (error) { await client.query("ROLLBACK"); throw error; }
  finally { client.release(); }
});

app.get("/v1/licenses", async (request, reply) => {
  if (!await requireAdmin(request, reply)) return;
  const result = await pool.query(
    "SELECT id,customer,duration,issued_at,activated_at,expires_at,revoked_at,device_id_hash FROM licenses ORDER BY issued_at DESC LIMIT 500",
  );
  return { licenses: result.rows.map((row) => ({ ...row, device_id_hash: row.device_id_hash ? "bound" : null,
    status: row.revoked_at ? "revoked" : row.expires_at && new Date(row.expires_at) <= new Date() ? "expired" : row.activated_at ? "active" : "unactivated" })) };
});

app.post("/v1/licenses/:id/activate", async (request, reply) => {
  const id = z.string().uuid().safeParse((request.params as any).id);
  const parsed = activateBody.safeParse(request.body);
  if (!id.success || !parsed.success) return reply.code(400).send({ error: "invalid_request" });
  const hash = deviceHash(parsed.data.device_id);
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const found = await client.query("SELECT * FROM licenses WHERE id=$1 FOR UPDATE", [id.data]);
    if (!found.rowCount) { await client.query("ROLLBACK"); return reply.code(404).send({ error: "license_not_found" }); }
    const row = found.rows[0];
    if (row.revoked_at) { await client.query("ROLLBACK"); return reply.code(403).send({ error: "license_revoked" }); }
    if (row.device_id_hash && row.device_id_hash !== hash) { await client.query("ROLLBACK"); return reply.code(409).send({ error: "device_already_bound" }); }
    if (!row.activated_at) {
      const activatedAt = new Date();
      const expiresAt = addDuration(activatedAt, row.duration);
      await client.query("UPDATE licenses SET activated_at=$2, expires_at=$3, device_id_hash=$4 WHERE id=$1", [id.data, activatedAt, expiresAt, hash]);
      await client.query("INSERT INTO license_audit_events (license_id,event_type,actor) VALUES ($1,'activated',$2)", [id.data, "device"]);
      row.activated_at = activatedAt; row.expires_at = expiresAt; row.device_id_hash = hash;
    }
    await client.query("COMMIT");
    const token = signClaims({ license_id: id.data, customer: row.customer, device_limit: 1,
      issued_at: Math.floor(new Date(row.issued_at).getTime()/1000),
      activated_at: Math.floor(new Date(row.activated_at).getTime()/1000),
      expires_at: Math.floor(new Date(row.expires_at).getTime()/1000),
      device_id_hash: hash, duration: row.duration }, env.LICENSE_SIGNING_PRIVATE_KEY_PEM);
    return { token, activated_at: row.activated_at, expires_at: row.expires_at };
  } catch (error) { await client.query("ROLLBACK"); throw error; }
  finally { client.release(); }
});

app.post("/v1/licenses/:id/validate", async (request, reply) => {
  const id = z.string().uuid().safeParse((request.params as any).id);
  const parsed = validateBody.safeParse(request.body);
  if (!id.success || !parsed.success) return reply.code(400).send({ error: "invalid_request" });
  const claims = verifyLicenseToken(parsed.data.token);\n  if (!claims || claims.license_id !== id.data || claims.device_limit !== 1) return reply.code(401).send({ error: "invalid_license_token" });\n  const result = await pool.query("SELECT customer,activated_at,expires_at,device_id_hash,revoked_at FROM licenses WHERE id=$1", [id.data]);
  if (!result.rowCount) return reply.code(404).send({ error: "license_not_found" });
  const row = result.rows[0], hash = deviceHash(parsed.data.device_id);
  if (row.revoked_at) return reply.code(403).send({ status: "revoked", server_time: new Date().toISOString() });
  if (!row.activated_at || row.device_id_hash !== hash || claims.device_id_hash !== hash) return reply.code(403).send({ status: "device_mismatch", server_time: new Date().toISOString() });
  if (new Date(row.expires_at) <= new Date()) return reply.code(403).send({ status: "expired", server_time: new Date().toISOString() });
  return { status: "active", customer: row.customer, expires_at: row.expires_at, server_time: new Date().toISOString() };
});

app.post("/v1/licenses/:id/revoke", async (request, reply) => {
  if (!await requireAdmin(request, reply)) return;
  const id = z.string().uuid().safeParse((request.params as any).id);
  if (!id.success) return reply.code(400).send({ error: "invalid_request" });
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const updated = await client.query("UPDATE licenses SET revoked_at=COALESCE(revoked_at,now()) WHERE id=$1 RETURNING id", [id.data]);
    if (!updated.rowCount) { await client.query("ROLLBACK"); return reply.code(404).send({ error: "license_not_found" }); }
    await client.query("INSERT INTO license_audit_events (license_id,event_type,actor) VALUES ($1,'revoked',$2)", [id.data, adminEmail]);
    await client.query("COMMIT");
    return { status: "revoked", license_id: id.data };
  } catch (error) { await client.query("ROLLBACK"); throw error; }
  finally { client.release(); }
});

app.addHook("onClose", async () => { await pool.end(); });
await app.listen({ host: "0.0.0.0", port: env.PORT });
