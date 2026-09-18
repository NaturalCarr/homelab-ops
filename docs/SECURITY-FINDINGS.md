# Security Controls and Findings

Verified: 2026-09-18 (gateway inspection, source and installed admin files). Other service checks retain their stated dates.

## Current membership and admin state

The gateway is healthy. Owner login-link review and signed-in recovery are enabled. Member lookup remains `legacy_email`; enforcement remains `dry_run`. No gateway host ports are published. SWAG reaches `bross-membership:3110` on the dedicated edge network; PostgreSQL stays on the internal database network.

Use `https://supporter.bross.cloud/` for membership status and `GET/POST /identity-recovery` for account-link help (no portal subdirectory). Use only `https://admin.bross.cloud/` for administration: B.Ross Media and Supporter Management are tabs. Login links and recovery requests stay inside Supporter Management. Internal renderer/API routes remain necessary, but aren't separate operator entry pages. Supporter's admin paths remain denied.

Production migrations 008 (verified login links) and 009 (recovery requests) were applied and registered at operator-confirmed checkpoints. One externally verified pilot login link was confirmed. These are dated checkpoints, not a fresh database count.

The operator reports the browser checks complete. Retain that as operator evidence, not an independent live CSRF/replay/approval test. Prior signed-out forged-header checks returned 302 on protected entry routes, 403 on Supporter admin and 200 on public support. No new real link, payment or Plex operation was performed for this documentation update.

Latest recovery wording/raw-field hardening has 96 focused passing source checks (no skips). A newer running image is now observed, but its exact bundled source hasn't been compared: don't assume those source changes are either still absent or verified deployed. Payment intake still associates unknown provider accounts by normalized email; review that ownership risk before verified-link activation. Native OIDC and app-specific login appearance remain planned. See [the identity rollout](BROSS-IDENTITY-ROLLOUT.md) for evidence and remaining gates.

## Gateway identity controls and open findings

This is a focused review, not a penetration test. Identity comes only from verified SWAG/Authentik subrequests; public support/checkout/webhooks clear identity. Keep gateway host ports closed and dedicated edge/internal database networks. Docker/host administrators remain trusted. Direct IPv6-client and exhaustive media checks aren't claimed complete.

Owner identity decisions require configured authority/UID/admin Host, exact mutation Origin, JSON and expiring HMAC proof. Recovery binds submissions to the trusted signed-in UID, ignores client identity selection, stores a single-use token hash and serializes limits (five per hour, three pending per UID). Form proof expires after 15 minutes; requests after 24 hours. Owner decisions require external ownership proof, explicit consent and current revision. Mapping/request/audits are atomic; audit failure rolls back. Conflicting/revoked identities aren't silently reassigned.

Latest source validation checks provider enum, raw reference type/160-character limit and control bytes before the ASCII ID allowlist. SQL stays parameterized; escaped HTML/plain-text owner queue rendering prevents interpreting submitted values as markup. The recorded 96 source checks include injection/XSS cases; they aren't a complete security audit or proof of exact image contents.

Open: provider intake's `resolveUser()` still selects an existing member by normalized email when provider IDs don't resolve. Email equality isn't ownership proof. Revoking a verified link also doesn't block legacy email login. Resolve intake/migration/recovery activation gates before claiming email is no longer an ownership key.

Operator browser checks were reported complete. Preserve owner-only edge rules, Supporter admin denial and port closure. Natural Carr admin has the same-origin Sign Out button; browser confirmation doesn't establish global logout across every application.

## Verified controls

### TLS and HTTP edge

SWAG currently:

- Redirects the catch-all HTTP listener to HTTPS.
- Allows TLS 1.2 and TLS 1.3.
- Disables TLS session tickets.
- Uses a one-day shared session cache.
- Sends HSTS with a one-year maximum age.
- Returns nginx status 444 for an undeclared HTTPS hostname.
- Uses a Mozilla-style modern cipher list.

The shared `ssl.conf` has optional CSP, Permissions-Policy, Referrer-Policy, X-Content-Type-Options, and X-Frame-Options lines commented out. Some individual hosts set a subset of these headers.

### Authentik

The Authentik embedded outpost loads the B.Ross/Natural Carr admin hosts plus New, Request, Stats, and Supporter. Request/Stats now reuse New's login flows and `require-plex-friends` policy binding. Existing admin restrictions weren't changed or re-audited during membership hardening. The outpost route is intentionally open so sign-in can start and finish. The authorization subrequest location is internal.

The forward-auth include passes verified username, group, entitlement, email, name, and UID headers to the upstream.

### Container controls

The B.Ross API and membership application use:

- Read-only root filesystems.
- A tmpfs for `/tmp`.
- `no-new-privileges:true`.
- Non-root user `99:100` for the B.Ross API.
- Bounded Docker JSON logs.

### Application controls

The membership gateway includes:

- Provider-signature verification.
- Idempotent event processing.
- HTTP Basic protection for its direct admin surface when enabled.
- API-key protection for membership lookup.
- HMAC-digested self-service tokens.
- One-time login tokens.
- Secure, HttpOnly, SameSite Lax session cookies.
- CSRF checks.
- Origin checks, rate limits, and generic public responses.
- Manual review and enforcement safety gates.

The B.Ross media rename route checks traversal, extension changes, unsupported file types, invalid names, and collisions.

### Jellyfin metrics

`/metrics` allows private IPv4 ranges and denies other clients.

## Fail2ban

Fail2ban already runs inside SWAG. Traffic entering through SWAG does not need a second host installation when nginx logs contain the event.

Default settings:

- Ignore `10.0.0.0/8`, `192.168.0.0/16`, and `172.16.0.0/12`.
- Use `iptables-allports`.
- Count failures in a 600-second window.
- Ban after 10 matching failures.
- Ban for 600 seconds.

Enabled jails:

- `nginx-http-auth`.
- `nginx-badbots`, with two retries.
- `nginx-botsearch`.
- `nginx-deny`.
- `nginx-unauthorized`.

`maxretry` counts matching log failures. It does not limit ordinary successful connections, connection duration, or the length of a valid WebSocket session. A client can keep a permitted connection open unless nginx or the upstream timeout closes it.

Private LAN ranges are excluded from bans. These jails will not stop a compromised LAN client.

Install Fail2ban on Tower only if Tower exposes host services that do not pass through SWAG and need log-based bans. The SWAG copy cannot inspect an unrelated host service log unless that log is mounted and a jail is designed for it.

## B.Ross admin API boundary

The source defines state-changing routes under `/api/admin`. SWAG currently proxies all `/api/` paths on both:

- Public `bross.cloud`.
- Authentik-protected `admin.bross.cloud`.

The running API returned 404 for `/api/admin/videos` on both direct port 3100 and the public host during the final 2026-09-07 check. The current source does define that route. This means the running container image is behind the source.

The next API rebuild will activate those routes. With the current nginx rule, public `bross.cloud` will expose them unless another control is added first.

Routing was left unchanged. Before the next API rebuild:

1. Decide whether to block `/api/admin` on the public host, add application authentication, or both.
2. Keep the route available on the Authentik-protected admin host.
3. Test signed-out GET, PUT, PATCH, and DELETE behavior through both hosts.
4. Test direct LAN port 3100 separately.

## Direct LAN service ports

Port 3100 remains the separate B.Ross API exposure finding (not changed by this rollout). Membership port 3110 is unpublished; the operator's LAN admin request is denied and container inspection shows no IPv4/IPv6 host bindings.

- Port 3100 has no application authentication for the media admin router.
- The gateway remains reachable to SWAG and its internal database-network peer. Maintain those trust boundaries; Docker/host administrators remain trusted.

Restrict port 3100 to trusted clients or the reverse proxy, or add an application credential before treating the LAN as untrusted.

## Public uptime history

`https://naturalcarr.com/assets/data/uptime-history.json` returned HTTP 200. The file currently holds monitor names, heartbeat timestamps, and daily aggregate counts.

The file has no credentials, but it exposes more operational history than the UI needs. Use one of these designs:

- Store the retained file outside the web root and expose only aggregated API output.
- Publish a reduced public copy without last-beat fields.

Do not move it without changing the B.Ross API volume and publisher configuration.

## Public write and resource routes

`POST /api/visit` is public, writes to disk, and has no rate limit. Add a small request limit and monitor file growth.

The admin playlist routes accept arrays without validating every member against the indexed media library. Add member validation and serialize writes.

Atomic JSON output uses a fixed temporary name per target. Concurrent writes can collide. Use a unique temporary name or a per-file write queue.

## External scripts

B.Ross loads WaveSurfer and Three.js from public CDNs without subresource-integrity hashes. Pin exact versions, add SRI and `crossorigin`, or host tested local copies.

## Security headers

Header policy is not uniform across all hosts. Create a tested baseline for:

- Content-Security-Policy.
- Referrer-Policy.
- X-Content-Type-Options.
- Frame policy through CSP `frame-ancestors` or X-Frame-Options.
- Permissions-Policy.

Test media playback, Plex, Authentik, payment providers, QR assets, and inline scripts before applying a global CSP.

## Upstream and availability findings

Point-in-time checks found:

- `jellyfin.bross.cloud` returned 502.
- `letme.in.bross.cloud` returned no HTTP result.
- `invitation.bross.cloud` reached Wizarr.

These are availability findings, not proof of a security fault. Confirm whether the alias is still required and whether Jellyfin was intentionally stopped.

## Secret handling

Never include values from:

- B.Ross API `.env`.
- Membership `secrets.env`.
- Membership `postgres.env`.
- Authentik environment files.
- Plex, Tautulli, Kuma, payment-provider, SMTP, Discord, or Cloudflare credentials.

Keep public identifiers and operational settings separate from secrets.

## Greenbone

Greenbone Community Edition can validate exposed services, TLS, packages, and network weaknesses. Record scan dates, target scope, severity totals, and remediation status. Do not place raw reports with internal addresses, credentials, or exploit detail in a public web root.

Turn confirmed scan results into work items. Verify each result against the running service before changing production.

## Priority order

1. Resolve the admin API boundary before rebuilding the current API source.
2. Restrict direct access to port 3100 or add application authentication.
3. Move or reduce the public uptime-history file.
4. Add a consistent tested security-header baseline.
5. Add rate and write controls to public and admin API routes.
6. Pin or self-host third-party browser scripts.
7. Resolve the current Jellyfin and Wizarr-alias availability findings.
