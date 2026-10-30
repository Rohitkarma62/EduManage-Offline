# EduManage Offline Licensing Architecture

## Approved product rules

- Required license customer/institute name.
- Durations: 1 day, 3 days, 7 days, 1 month, 3 months, 6 months, and 1 year.
- The duration clock starts only at the first successful activation, not at issue time.
- One license may be activated on one device only.
- No notes field is required.
- Expired licenses restrict licensed features but never delete or overwrite institute data.

## Trust boundaries

1. An authenticated licensing backend issues and activates licenses.
2. The backend owns the Ed25519 private signing key. It must not be included in this repository, Flutter bundle, or APK.
3. Android embeds only the backend Ed25519 public key and verifies signed tokens offline.
4. The backend atomically binds a license to the first device activation and refuses a second device.
5. Revocation and server-side status changes are learned on the next successful online synchronization. Immediate remote revocation is impossible while a device remains offline.

## Signed token format

The compact token is payload.signature, where both parts are base64url encoded. The signature is Ed25519 over the exact UTF-8 payload bytes. The signed JSON payload contains:

- license_id: unique license identifier
- customer: required institute/customer name
- device_limit: must equal 1
- issued_at: UTC Unix seconds
- activated_at: null until first activation; then UTC Unix seconds
- expires_at: null until first activation; then UTC expiry timestamp
- device_id_hash: null until activation; then SHA-256 of the app's stable device identifier

On activation the backend returns a newly signed token. The app never calculates the official expiry locally. The server calculates it from first activation and selected duration, using calendar-month arithmetic for month/year terms.

## Backend API contract to implement

- POST /v1/licenses: authenticated admin; required customer and allowed duration; server creates an unactivated one-device license.
- POST /v1/licenses/{id}/activate: app submits the signed unactivated token and stable device identifier; backend atomically sets first activation and returns a newly signed activated token. Repeated activation from the same device returns the existing activation; a different device is rejected.
- POST /v1/licenses/{id}/validate: online synchronization for expiry, revocation, status and trusted server time.
- GET /v1/licenses: authenticated admin list with customer, duration, status, activation, expiry and device binding.
- POST /v1/licenses/{id}/revoke: authenticated admin revocation with audit event.

Admin authentication, rate limits, audit logs, database transactions, key rotation, TLS, backups and monitoring are backend requirements. Private signing material belongs in a managed secret store or KMS.

## Offline clock rollback policy

The client records the last trusted time observation in platform-protected storage. If the local clock moves backwards beyond a small tolerance, the client marks the license as requiring online revalidation. This is tamper detection, not a perfect clock: a fully offline client cannot prove real-world time against a hostile device owner. Server time is authoritative whenever the device reconnects.

## Current implementation boundary

The Flutter repository contains the Ed25519 token parser/verifier core and unit tests. Production activation still requires the backend API, secure Android storage for device identity and last trusted time, embedding the backend public key, and wiring entitlement decisions into licensed feature routes. Do not treat a debug build with no configured public key/backend as a production licensing release.
