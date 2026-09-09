# B.Ross Membership Gateway

Verified: 2026-09-07

## Purpose

The membership gateway pulls Stripe, PayPal, and Patreon supporter state into one PostgreSQL model. It runs the public plans, signed webhooks, self-service portal, private review tools, and guarded media-access workflow.

Plex remains the media-access authority. Wizarr supplies invitation and account observations. Ombi follows Plex sharing.

## Runtime

| Item | Value |
|---|---|
| Application container | `bross-membership` |
| Database container | `bross-membership-db` |
| Runtime | Node.js 22 |
| Framework | Express 5.1 |
| Database | PostgreSQL 16 Alpine |
| Database client | `pg` 8.16 |
| Email | Nodemailer 9 |
| QR generation | `qrcode` and `@napi-rs/canvas` |
| Host port | 3110 |

Source:

- Windows: `O:\homelab-ops\services\bross-membership`
- UNC: `\\TOWER\flash\homelab-ops\services\bross-membership`
- Unraid: `/boot/homelab-ops/services/bross-membership`

Compose Manager:

- Windows: `O:\config\plugins\compose.manager\projects\bross-membership\docker-compose.yml`
- Unraid: `/boot/config/plugins/compose.manager/projects/bross-membership/docker-compose.yml`

## Container controls

Application:

- Read-only root filesystem.
- `/tmp` tmpfs.
- `no-new-privileges:true`.
- Restart unless stopped.
- Three 10 MB JSON log files.
- Health check requests `http://127.0.0.1:3110/health`.

Database:

- Persistent data in appdata `bross-membership/postgres`.
- PostgreSQL health check before application start.
- `no-new-privileges:true`.
- Three 10 MB JSON log files.

## Configuration boundary

Appdata files:

- `settings.env` - non-secret operational settings.
- `secrets.env` - provider keys, application secrets, SMTP credentials, and service tokens.
- `postgres.env` - PostgreSQL password.

Do not read, copy, log, or commit the two secret files. Real credentials never belong in Compose or this repository.

## Public routes

| Method | Route | Purpose |
|---|---|---|
| GET | `/` | Redirect to `/support` |
| GET | `/support` | Support plan and provider page |
| POST | `/checkout/stripe` | Create a hosted Stripe Checkout session |
| POST | `/webhooks/stripe` | Verify and ingest Stripe events |
| POST | `/webhooks/paypal` | Verify and ingest PayPal events |
| POST | `/webhooks/patreon` | Verify and ingest Patreon events |
| GET | `/health` | Database-aware health |

SWAG exposes the support, checkout, and webhook routes under `https://bross.cloud`.

Provider webhooks must remain free of proxy-level interactive authentication. The application verifies the provider signatures.

## Supporter self-service

| Method | Route | Purpose |
|---|---|---|
| GET | `/manage` | Sign-in or authenticated portal |
| POST | `/manage/request` | Request a magic link |
| GET | `/manage/verify` | Verification page |
| POST | `/manage/verify` | Consume a one-time token and create a session |
| GET | `/manage/plex-auth` | Start Plex PIN/OAuth authentication |
| GET | `/manage/plex-auth/callback` | Complete Plex authentication |
| POST | `/manage/manual-review` | Submit an account-match review |
| POST | `/manage/plex-link` | Submit a Plex link request |
| POST | `/manage/logout` | Revoke the current session |

The source tests these controls:

- Raw magic-link tokens use the URL fragment, not the query string.
- Stored login and session tokens are purpose-separated HMAC digests.
- Login tokens are one-time and expire.
- Session cookies are Secure, HttpOnly, SameSite Lax, and scoped to `/manage`.
- State-changing portal requests require a session-bound CSRF token.
- Sign-in and review forms use generic responses, origin checks, a honeypot, and keyed rate limits.
- Plex OAuth state uses a signed short-lived HttpOnly cookie.
- The Plex token used for sign-in is not retained.
- Review requests do not grant access without administrator approval.

## Private API and dashboard

`GET /api/v1/memberships/:email` uses `X-API-Key`.

The application also has a private `/admin/` dashboard with routes for:

- Overview and reconciliation.
- Wizarr observation.
- Plex access review.
- Identity-link decisions.
- Temporary overrides.
- Enforcement proposals, approval, skip, status, and latest run.
- Notification status and test delivery.
- Self-service readiness and review queues.
- Pending supporter invitations and processing.

The main SWAG configuration does not expose the membership `/admin` route. On `bross.cloud`, `/admin*` redirects to the separate media-admin site at `admin.bross.cloud`. The Compose Manager WebUI label that points to `https://bross.cloud/admin/` therefore does not reach this dashboard.

The membership application can apply its own HTTP Basic authentication if the admin route is reached directly. Keep it enabled unless the route is placed behind a verified identity proxy.

## Provider model

Incoming provider events are:

1. Verified against the provider signature.
2. Parsed from the raw request body.
3. Stored for idempotent processing.
4. Normalized into provider-independent supporter and subscription state.
5. Reconciled against provider APIs when requested or scheduled.

No card number, bank credential, payment password, or complete payment record belongs in this service.

## Identity and access model

The database uses privacy-minimized records for:

- Provider supporters and subscriptions.
- Plex account references.
- Candidate, verified, and rejected supporter-to-Plex links.
- Observed service access.
- Time-bounded manual overrides.
- Recommendations.
- Enforcement actions and audit history.
- Self-service tokens, sessions, and review requests.
- Invitation queue state.

Unverified identity links, mismatched accounts, and unknown states must go to review.

## Enforcement safety

The design keeps observation, recommendation, approval, and execution separate.

- Plex 1 remains observation-only.
- Only a server explicitly marked for enforcement can receive writes.
- Automatic mode can add or restore access only.
- Disable actions always require manual approval.
- Dry-run remains the safe production default.
- Limits, circuit breakers, and audit records must remain enabled.
- Provider, identity, and access uncertainty resolves to review, not a write.

Do not enable broad production enforcement until one legitimate manual invite or restore passes end to end.

## Notifications

Email and Discord run independently. One can fail without stopping the other or the enforcement workflow.

The source supports:

- Administrative summaries.
- Circuit-breaker notices.
- Missing-link notices.
- Successful manual-disable notices.
- Self-service magic links.
- Invitation emails with inline QR codes.

Notification logs and messages must not disclose webhook URLs, provider credentials, private email lists, or unnecessary user identity.

## Invitation workflow

The supporter invitation queue uses states such as:

`pending -> processing -> created -> sent`

Failures can be retried to the configured limit. The workflow can create a Wizarr invitation, generate a QR code, and send an email with the QR image.

## Tests

The current source has 21 test files and 179 `test()` calls.

```sh
cd /boot/homelab-ops/services/bross-membership
pnpm test
```

The test suite covers configuration, providers, reconciliation, notifications, pages, self-service, access evaluation, enforcement gates, and invitation behavior.

## Build and verify

```sh
cd /boot/config/plugins/compose.manager/projects/bross-membership
docker compose up -d --build
docker compose ps
docker compose logs --tail=100 membership
curl -sS http://127.0.0.1:3110/health
```

The health endpoint returned `{"status":"ok"}` on 2026-09-07.

## Backups

Back up:

- PostgreSQL data or a tested logical dump.
- Non-secret `settings.env`.
- User-owned `secrets.env` and `postgres.env` through a protected secret-backup process.
- Source and migrations in the homelab repository.

A copied PostgreSQL directory is not a tested restore. Verify the restore path before you need it.

## Current project status

The project snapshot dated 2026-09-05 records:

- Core gateway, observation, dry-run enforcement, notifications, and self-service as deployed.
- Manual live-write testing and full production activation as incomplete.
- Wizarr-mediated invitation work as in progress.
- Stripe-hosted Cash App Pay source as complete but deployment pending.

The source changed again on 2026-09-07. Live health was verified, but each later
phase was not retested during this documentation pass. Use the current source,
current database migrations, and a fresh validation run before changing
enforcement mode.
