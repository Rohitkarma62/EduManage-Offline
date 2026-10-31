CREATE TABLE IF NOT EXISTS licenses (
  id UUID PRIMARY KEY,
  customer TEXT NOT NULL CHECK (length(trim(customer)) > 0),
  duration TEXT NOT NULL CHECK (duration IN ('1d','3d','7d','1m','3m','6m','1y')),
  issued_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  activated_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  device_id_hash CHAR(64),
  revoked_at TIMESTAMPTZ,
  CHECK ((activated_at IS NULL) = (expires_at IS NULL)),
  CHECK ((activated_at IS NULL) = (device_id_hash IS NULL)),
  CHECK (expires_at IS NULL OR expires_at > activated_at)
);
CREATE INDEX IF NOT EXISTS licenses_issued_at_idx ON licenses (issued_at DESC);
CREATE TABLE IF NOT EXISTS license_audit_events (
  id BIGSERIAL PRIMARY KEY,
  license_id UUID REFERENCES licenses(id),
  event_type TEXT NOT NULL,
  actor TEXT NOT NULL,
  occurred_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb
);
CREATE INDEX IF NOT EXISTS license_audit_license_idx
  ON license_audit_events (license_id, occurred_at DESC);
