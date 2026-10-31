# Licensing API (initial backend implementation)

This is a deployable Node.js API service, separate from the offline Flutter client. It provides admin login, license issue/list/revoke, first-device activation, and online validation.

## Requirements

- Node.js 22+
- PostgreSQL 15+
- HTTPS termination at a trusted reverse proxy or platform ingress
- An Argon2id admin password hash
- A 32+ byte random JWT secret
- An Ed25519 PKCS8 private key injected from a managed secret store/KMS

Copy `.env.example` to a local secret file and populate values out-of-band. Never commit real credentials or the private signing key. Apply `migrations/001_initial.sql` to PostgreSQL before starting the API.

## Run

```sh
npm install
npm test
npm run typecheck
npm start
```

## Endpoints

- `POST /v1/admin/login`: admin email/password to short-lived bearer token.
- `POST /v1/licenses`: authenticated issue; body `{customer,duration}`.
- `GET /v1/licenses`: authenticated list.
- `POST /v1/licenses/:id/activate`: app activation; body `{device_id}`.
- `POST /v1/licenses/:id/validate`: online status sync; body `{device_id}`.
- `POST /v1/licenses/:id/revoke`: authenticated revocation.

Durations are `1d, 3d, 7d, 1m, 3m, 6m, 1y`. Month/year durations use UTC calendar arithmetic. Activation is serialized with a row lock; only the first device can bind, and same-device retries are idempotent.

## Production gates still required

This is not yet a production deployment. Before exposing it publicly: provision TLS, network/database access controls, secret-manager/KMS signing, backups and restore drills, monitoring/alerting, admin account lifecycle and MFA, security review, integration tests against PostgreSQL, and client integration. The API currently uses an environment-injected PEM key as a development adapter; replace it with a KMS signer before production. Online validation is authoritative for revocation; offline devices cannot receive immediate revocation.
