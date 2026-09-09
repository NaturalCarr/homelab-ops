# Authentik Integration

Verified integration boundary: 2026-09-07

The full Authentik stack report hasn't been merged yet. This file covers only
what was verified at the SWAG boundary. Do not add secret values here.

## Verified SWAG integration

`auth.bross.cloud` proxies to `http://authentik-server:9000` and uses Docker DNS
through `resolver 127.0.0.11 valid=30s`.

SWAG currently protects:

- `admin.bross.cloud`
- `new.bross.cloud`

Both hosts include:

- `/config/nginx/authentik-server.conf`
- `/config/nginx/authentik-location.conf`

The outpost ping returned HTTP 204 through
`admin.bross.cloud/outpost.goauthentik.io/ping` during setup. A signed-out request
to the admin root redirected to Authentik on 2026-09-07.

Navidrome has commented Authentik includes. They aren't active.

## Protected resources

The admin host contains:

- Static `admin.html`.
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

## Sign-out

Don't document a guessed logout URL. Record the tested Authentik end-session
path only after the provider and flow settings are verified.

## Merge procedure

1. Save the completed report without credentials.
2. Link it from `docs/README.md`.
3. Compare every route claim with the live SWAG files.
4. Resolve conflicts in favor of live Compose and SWAG state.
5. Add the verification date.
6. Keep the original handoff under `reference/` if the canonical report is rewritten.
