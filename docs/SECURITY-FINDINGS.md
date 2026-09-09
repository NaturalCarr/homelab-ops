# Security Controls and Findings

Verified: 2026-09-07

This is a focused operational review. It is not a penetration test.

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

`admin.bross.cloud` and `new.bross.cloud` use forward authentication through Authentik. The outpost route is intentionally open so sign-in can start and finish. The authorization subrequest location is internal.

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

Ports 3100 and 3110 are bound on Tower. A LAN client can bypass SWAG and Authentik by using the host and port directly.

- Port 3100 has no application authentication for the media admin router.
- Port 3110 applies its own application controls.

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
