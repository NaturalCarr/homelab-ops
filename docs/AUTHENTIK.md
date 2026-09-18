# Authentik Integration

Verified: 2026-09-18 (gateway inspection, source and installed admin files). Other service checks retain their stated dates.

## Current membership and admin state

The gateway is healthy. Owner login-link review and signed-in recovery are enabled. Member lookup remains `legacy_email`; enforcement remains `dry_run`. No gateway host ports are published. SWAG reaches `bross-membership:3110` on the dedicated edge network; PostgreSQL stays on the internal database network.

Use `https://supporter.bross.cloud/` for membership status and `GET/POST /identity-recovery` for account-link help (no portal subdirectory). Use only `https://admin.bross.cloud/` for administration: B.Ross Media and Supporter Management are tabs. Login links and recovery requests stay inside Supporter Management. Internal renderer/API routes remain necessary, but aren't separate operator entry pages. Supporter's admin paths remain denied.

Production migrations 008 (verified login links) and 009 (recovery requests) were applied and registered at operator-confirmed checkpoints. One externally verified pilot login link was confirmed. These are dated checkpoints, not a fresh database count.

The operator reports the browser checks complete. Retain that as operator evidence, not an independent live CSRF/replay/approval test. Prior signed-out forged-header checks returned 302 on protected entry routes, 403 on Supporter admin and 200 on public support. No new real link, payment or Plex operation was performed for this documentation update.

Latest recovery wording/raw-field hardening has 96 focused passing source checks (no skips). A newer running image is now observed, but its exact bundled source hasn't been compared: don't assume those source changes are either still absent or verified deployed. Payment intake still associates unknown provider accounts by normalized email; review that ownership risk before verified-link activation. Native OIDC and app-specific login appearance remain planned. See [the identity rollout](BROSS-IDENTITY-ROLLOUT.md) for evidence and remaining gates.

The full Authentik stack report hasn't been merged yet. This file covers only
what was verified at the SWAG boundary. Do not add secret values here.

## Verified SWAG integration

`auth.bross.cloud` proxies to `http://authentik-server:9000` and uses Docker DNS
through `resolver 127.0.0.11 valid=30s`.

SWAG currently protects:

- `admin.bross.cloud`
- `admin.naturalcarr.com`
- `new.bross.cloud`
- `request.bross.cloud`
- `stats.bross.cloud`
- `supporter.bross.cloud`

Protected hosts use the shared forward-auth includes:

- `/config/nginx/authentik-server.conf`
- `/config/nginx/authentik-location.conf`

The outpost ping returned HTTP 204 through
`admin.bross.cloud/outpost.goauthentik.io/ping` during setup. A signed-out request
to the admin root redirected to Authentik on 2026-09-07.

Navidrome has commented Authentik includes. They aren't active.

## Authentication flow architecture

Verified: 2026-09-12

The `default-authentication-flow` ("Welcome to authentik!") uses two
identification stages at the same order to control where the Plex login button
appears:

| Order | Stage | Policy | Effect |
|---|---|---|---|
| 10 | `bross-identification-with-plex` | `show-plex-for-allowed-apps` (negate=false) | Username + email + Plex button |
| 10 | `bross-identification-standard` | `show-plex-for-allowed-apps` (negate=true) | Username + email only |
| 20 | `default-authentication-password` | — | Password field |
| 30 | `default-authentication-mfa-validation` | — | MFA if configured |
| 100 | `default-authentication-login` | — | Session creation |

The expression policy `show-plex-for-allowed-apps` reads the `next` URL
parameter to determine which application is requesting authentication. When the
domain matches the allowed list, the Plex stage runs; otherwise the standard
stage runs. The username/email field always appears regardless of which stage is
selected.

Allowed Plex domains: `supporter.bross.cloud`, `new.bross.cloud`,
`request.bross.cloud`, `stats.bross.cloud`.

Blocked (standard identification only): `auth.bross.cloud`, `admin.bross.cloud`,
all other hosts.


## Protected resources

The admin host contains:

- Static two-tab `admin.html`: B.Ross Media and Supporter Management.
- Private gateway proxy with embedded login-link/recovery tools and independent owner decision guards.
- B.Ross admin API proxy.
- youtube-dl proxy.
- TubeSync proxy.

The recently-added host serves a Tautulli-generated static report.

## Missing report scope

The full internal report still needs:

- Compose files, images, versions, container roles, networks, ports, volumes, and health checks.
- PostgreSQL and Redis roles.
- Environment-variable names (never values).
- Applications, providers, outposts, flows, stages, groups, policies, and mappings.
- The complete forward-auth request path.
- Sessions, cookies, reauthentication, recovery, and logout.
- DNS, TLS, backup, restore, update, rollback, and disaster recovery.
- Known issues, recommendations, verified facts, and unknowns.

## Request/Stats outpost repair (applied)

Targeted checks: 2026-09-16. SWAG retains both medianet and the membership edge network after recreation. Authentik is reachable. Before repair, Request and Stats returned HTTP 500 because their Authentik authorization checks returned HTTP 404. Their outpost-start routes also returned 404. The repair confirmed their provider/application entries were absent and created them.

New returns a signed-out redirect and its login chain reaches HTTP 200. After the repairs below, the operator confirmed the affected media sites work. No separate exhaustive per-user authorization audit was performed.

Paste into Tower's root terminal:

```bash
bash /boot/homelab-ops/scripts/repair-bross-outpost.sh apply
```

The script targets the verified Authentik 2026.8.1 image. It checks existing Request/Stats providers, preserves their rules, and adds them to the embedded outpost without replacing current entries. If neither provider nor an existing application is found for a host, it creates a single-application forward-auth entry using New's login flows and copied application policy bindings. New entries get fresh client/cookie secrets. Conflicting or nonstandard configurations stop before writes.

Application/provider creation and outpost assignment run in a database transaction. A private ID-only rollback record is saved under `/mnt/cache_addons/addonfiles/dockers/appdata/authentik/data/access-repair-backups` before commit. It records original assignments and newly added objects; it isn't a full Authentik database backup. No existing provider settings, admin policies, SWAG routes, or Tautulli settings are changed. No API token is needed.

Applied on 2026-09-16. Request and Stats entries were created with New's login flows and `require-plex-friends` policy binding. Both were added to the embedded outpost. Its logs now load both hosts. Request, Stats, New, and Supporter independently return signed-out HTTP 302. The first checks briefly returned 500 before the outpost refreshed. Rollback record: `/mnt/cache_addons/addonfiles/dockers/appdata/authentik/data/access-repair-backups/bross-outpost-20260916T235416121558Z.json`.

Signed-in checks exposed a separate backend DNS problem. Stats logs reported `tautulli could not be resolved`. Tautulli runs on the default bridge; SWAG runs on medianet and the membership edge. Request used the name `ombi`, but its scoped resolver is the router, not Docker DNS. Published LAN upstream checks passed: Ombi port 3579 returned HTTP 200; Tautulli port 8181 returned HTTP 303. The applied proxy repair uses those existing LAN endpoints for only the two Ombi and four Tautulli locations. Authentik includes, API exemptions, and Tautulli permissions stay unchanged.

The media upstream repair is applied and preserved in the current default proxy. The operator confirmed the affected sites work. Membership Phase 1A/1B are also live: seven private Docker-DNS upstreams, verified/cleared identity headers, no host port 3110, and an internal app/database network. The signed-in membership portal works at `https://supporter.bross.cloud/`. See [the identity rollout](BROSS-IDENTITY-ROLLOUT.md) for exact evidence and remaining checks.

## Planned shared identity and login presentation

Request, Stats, New, and Supporter use the same Authentik authority. App-specific login appearance is planned, not deployed. Stable membership links must be introduced before native gateway OIDC; validate issuer/subject and don't equate proxy UID with OIDC subject. Email mismatches need verified account linking, not automatic merging. Keep Tautulli's existing individual Plex/guest sessions and per-user history restrictions (no shared Basic/admin session).

## Sign-out

Natural Carr admin uses the published same-origin `/outpost.goauthentik.io/sign_out` link through the existing outpost include. Installed HTML/hash and signed-out redirects were checked; the operator reports browser checks complete. Do not infer global SSO logout or independently tested clearing of every application session.
## Merge procedure

1. Save the completed report without credentials.
2. Link it from `docs/README.md`.
3. Compare every route claim with the live SWAG files.
4. Resolve conflicts in favor of live Compose and SWAG state.
5. Add the verification date.
6. Keep the original handoff under `reference/` if the canonical report is rewritten.
