# B.Ross Membership Gateway

Verified: 2026-09-18 (gateway inspection, source and installed admin files). Other service checks retain their stated dates.

## Current membership and admin state

The gateway is healthy. Owner login-link review and signed-in recovery are enabled. Member lookup remains `legacy_email`; enforcement remains `dry_run`. No gateway host ports are published. SWAG reaches `bross-membership:3110` on the dedicated edge network; PostgreSQL stays on the internal database network.

Use `https://supporter.bross.cloud/` for membership status and `GET/POST /identity-recovery` for account-link help (no portal subdirectory). Use only `https://admin.bross.cloud/` for administration: B.Ross Media and Supporter Management are tabs. Login links and recovery requests stay inside Supporter Management. Internal renderer/API routes remain necessary, but aren't separate operator entry pages. Supporter's admin paths remain denied.

Production migrations 008 (verified login links) and 009 (recovery requests) were applied and registered at operator-confirmed checkpoints. One externally verified pilot login link was confirmed. These are dated checkpoints, not a fresh database count.

The operator reports the browser checks complete. Retain that as operator evidence, not an independent live CSRF/replay/approval test. Prior signed-out forged-header checks returned 302 on protected entry routes, 403 on Supporter admin and 200 on public support. No new real link, payment or Plex operation was performed for this documentation update.

Latest recovery wording/raw-field hardening has 96 focused passing source checks (no skips). A newer running image is now observed, but its exact bundled source hasn't been compared: don't assume those source changes are either still absent or verified deployed. Payment intake still associates unknown provider accounts by normalized email; review that ownership risk before verified-link activation. Native OIDC and app-specific login appearance remain planned. See [the identity rollout](BROSS-IDENTITY-ROLLOUT.md) for evidence and remaining gates.

## Purpose

Existing provider intake still associates accounts by normalized email when no provider identifier is known. That separate ownership risk is unchanged and needs Phase 3 review. The new lookup is not a claim that all email associations have been removed. No card, bank or payment credentials are added to the identity schema.

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
| Private application port | 3110; no host port binding |

Source:

- Windows: `R:\github\bross-supporter-gateway`
- UNC: `\\TOWER\addonfiles\github\bross-supporter-gateway`
- Unraid: `/mnt/cache_addons/addonfiles/github/bross-supporter-gateway`

The repository service copy isn't the active build context. Recreate/rebuild through Unraid's Compose Manager GUI.

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
| GET | `/support` | Support plan and provider page |
| POST | `/checkout/stripe` | Create a hosted Stripe Checkout session |
| POST | `/webhooks/stripe` | Verify and ingest Stripe events |
| POST | `/webhooks/paypal` | Verify and ingest PayPal events |
| POST | `/webhooks/patreon` | Verify and ingest Patreon events |
| GET | `/health` | Private database-aware health (not a public SWAG route) |

SWAG exposes the support, checkout, and webhook routes under `https://bross.cloud`.

Provider webhooks must remain free of proxy-level interactive authentication. The application verifies the provider signatures.

## Supporter self-service

| Method | Route on supporter.bross.cloud | Purpose |
|---|---|---|
| GET | `/` | Authenticated membership status or account-link help |
| POST | `/manual-review` | Existing payment/Plex account-match review |
| POST | `/plex-link` | Existing Plex link request |
| GET | `/logout` | Existing portal sign-out |
| GET / POST | `/identity-recovery` | Signed-in Authentik-to-membership recovery request |

Recovery doesn't need an email from the payment provider. The optional subscription, transaction or membership reference assists manual review; a submitted ID isn't ownership proof. Candidate lookup uses provider + subscription ID. Other references require externally verified manual selection. Keep privacy warnings; requesting review doesn't change support or access.

Latest member copy: "Already supporting B.Ross, but your accounts aren't linked?", "All requests are manually reviewed", "Support Method" and "Subscription, transaction or membership ID (if available)". Member pages explain the action/outcome without advertising internal IDs or automatic linking mechanics. Legacy magic-link/Plex session routes remain compatibility features, not the current portal entry point.

## Private API and tabbed administration

`GET /api/v1/memberships/:email` requires `X-API-Key`.

Open only `https://admin.bross.cloud/`. The Compose WebUI points at this root. Its unchanged owner-only Authentik rule protects both tabs. The private gateway `/admin` namespace serves embedded views/APIs through that host; known top-level renderer navigation redirects into the matching root tab.

Internal identity APIs: `GET/POST /admin/api/identity-links`, `POST /admin/api/identity-links/:linkId/revoke`, `GET /admin/api/identity-recovery`, `POST /admin/api/identity-recovery/:requestId/decision`. These aren't separate operator pages.

Gateway Basic admin authentication is disabled. Preserve owner-only edge authorization, independently configured owner UID/Host/Origin/token checks for identity decisions, Supporter admin denial and the unpublished backend port. Matching login flows alone don't enforce owner access.

Supporter Management retains reconciliation, observations, Plex review, overrides, enforcement proposals, notifications, self-service queues and invitation processing. Review/approval doesn't merge members or change payments/Plex access.

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
- Authority-scoped verified Authentik login links (migration 008).
- Identity-bound recovery requests and decisions (migration 009).

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

Latest recorded focused source run: 96 passing checks, zero failures/skips. Earlier isolated PostgreSQL/HTTP runs passed concurrency, replay, ownership conflicts, audit rollback, revision and member/owner controls; those preceded the latest raw-field hardening. No fresh full-suite/dependency audit or exact image/source verification is claimed here.

```sh
cd /mnt/cache_addons/addonfiles/github/bross-supporter-gateway
pnpm test
```

The test suite covers configuration, providers, reconciliation, notifications, pages, self-service, access evaluation, enforcement gates, and invitation behavior.

## Build and verify

```sh
cd /boot/config/plugins/compose.manager/projects/bross-membership
docker compose config --quiet
docker compose ps
docker compose logs --tail=100 membership
docker exec swag curl -fsS --max-time 10 http://bross-membership:3110/health
```

Run configuration validation in Tower's terminal; build/recreate through Compose Manager's GUI only. Phase 1B used existing images, not a source rebuild. The current containers report healthy; private health and public support checks passed before recreation, and the operator confirmed support/portal access afterward.

## Backups

Back up:

- PostgreSQL data or a tested logical dump.
- Non-secret `settings.env`.
- User-owned `secrets.env` and `postgres.env` through a protected secret-backup process.
- Source and migrations in the homelab repository.

A copied PostgreSQL directory is not a tested restore. Verify the restore path before you need it.

## Current project status

Owner review, recovery and the tabbed admin are deployed. Verified-link member lookup, native OIDC and app-specific login appearance remain separately gated. Stripe/Cash App, PayPal and Patreon are present; fresh authorized Checkout/signed-webhook observations remain separate gates. Venmo is deferred. A legitimate manual Plex2 invite/restore and full production enforcement gates remain unresolved. The [identity rollout](BROSS-IDENTITY-ROLLOUT.md) retains the complete roadmap.
