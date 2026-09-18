# Homelab Operations Documentation

Verified: 2026-09-07

Membership/identity documentation reconciled: 2026-09-18. Other sections retain their original check dates.

This is the working technical record for my public sites and the services behind
them. It covers the live SWAG routes, source files, application services, data
flow, deployment, access controls, backups, and known problems.

Live configuration wins when a document disagrees with production. Files under
`reference/` are older snapshots. Use them for history, not current state.

## Start here

- [Platform overview](PLATFORM-OVERVIEW.md) - system boundaries and data flow.
- [Routes and access](ROUTES-AND-ACCESS.md) - public URLs, upstreams, and Windows, Unraid, and container paths.
- [B.Ross Cloud](BROSS-CLOUD.md) - public portal and protected media admin.
- [B.Ross API](BROSS-API.md) - endpoints, collectors, tests, and deployment.
- [Natural Carr](NATURALCARR.md) - portfolio routes, resumes, and live metrics.
- [Dataviz](DATAVIZ.md) - dashboard sources and chart behavior.
- [Membership gateway](BROSS-MEMBERSHIP.md) - support plans, webhooks, self-service, review, and enforcement controls.
- [B.Ross identity rollout](BROSS-IDENTITY-ROLLOUT.md) - canonical roadmap and checkpoints; edge isolation/owner review are live, first pilot link verified, signed-in recovery is enabled; latest image/source correspondence remains unverified, OIDC/login presentation remain planned.
- [Home IT site](BROSS-NATURALCARR.md) - source and deployment for `bross.naturalcarr.com`.
- [SWAG edge](SWAG-EDGE.md) - nginx, TLS, static roots, forward auth, and reload procedure.
- [Service subdomains](SERVICE-SUBDOMAINS.md) - purpose and proxy behavior for each service host.
- [Operations](OPERATIONS.md) - safe editing, builds, reloads, testing, and backups.
- [Syncthing](SYNCTHING.md) - container mappings, folders, device sharing, and rollback.
- [Security findings](SECURITY-FINDINGS.md) - verified controls, open findings, and retest requirements.
- [Authentik integration](AUTHENTIK.md) - verified SWAG boundary and missing internal report scope.
- [Historical references](reference/README.md) - imported older documentation.

## Scope

The documented public surface includes:

- `bross.cloud` and its active service subdomains.
- `naturalcarr.com`, including role and job-specific pages.
- `bross.naturalcarr.com`.
- The B.Ross API on port 3100.
- The membership gateway on private Docker port 3110 (no host-published port).
- Uptime Kuma and Tautulli data published through the sites.
- The standalone dataviz project (no active public route).

The Authentik containers and internal policy design still need their own verified
report. These docs cover only the confirmed SWAG connection and protected routes.

## Documentation rules

- Never store secrets, keys, cookies, tokens, passwords, provider credentials, or private user records here.
- Name environment variables without recording their values.
- Mark facts as verified, inferred, historical, or planned.
- Date anything that can drift.
- Update the route matrix after a SWAG change.
- Update the service document after a route, schema, volume, or build change.

## Main source paths

| Area | Windows path | Unraid path |
|---|---|---|
| Live SWAG config | `R:\dockers\appdata\swag\nginx\site-confs` | `/mnt/cache_addons/addonfiles/dockers/appdata/swag/nginx/site-confs` |
| B.Ross public files | `R:\dockers\appdata\swag\www\bross` | `/mnt/cache_addons/addonfiles/dockers/appdata/swag/www/bross` |
| Natural Carr public files | `R:\dockers\appdata\swag\www\natural` | `/mnt/cache_addons/addonfiles/dockers/appdata/swag/www/natural` |
| Dataviz files | `R:\dockers\appdata\swag\www\dataviz` | `/mnt/cache_addons/addonfiles/dockers/appdata/swag/www/dataviz` |
| Deployed Home IT site | `R:\dockers\appdata\swag\www\hire` | `/mnt/cache_addons/addonfiles/dockers/appdata/swag/www/hire` |
| B.Ross API source | `R:\dockers\appdata\bross-api` | `/mnt/cache_addons/addonfiles/dockers/appdata/bross-api` |
| Compose projects | `O:\config\plugins\compose.manager\projects` | `/boot/config/plugins/compose.manager/projects` |
| Homelab repository | `O:\homelab-ops` | `/boot/homelab-ops` |
| Resume library | `Q:\resumes` | `/mnt/user/Files/Documents/resumes` |

`Q:\resumes` currently resolves to `\\TOWER\Files\Documents\resumes`. Verify the
share path again before any write because Unraid share mappings can change.
