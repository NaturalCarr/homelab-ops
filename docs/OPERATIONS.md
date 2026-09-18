# Site Operations

Verified: 2026-09-18 (gateway inspection, source and installed admin files). Other service checks retain their stated dates.

## Current membership and admin state

The gateway is healthy. Owner login-link review and signed-in recovery are enabled. Member lookup remains `legacy_email`; enforcement remains `dry_run`. No gateway host ports are published. SWAG reaches `bross-membership:3110` on the dedicated edge network; PostgreSQL stays on the internal database network.

Use `https://supporter.bross.cloud/` for membership status and `GET/POST /identity-recovery` for account-link help (no portal subdirectory). Use only `https://admin.bross.cloud/` for administration: B.Ross Media and Supporter Management are tabs. Login links and recovery requests stay inside Supporter Management. Internal renderer/API routes remain necessary, but aren't separate operator entry pages. Supporter's admin paths remain denied.

Production migrations 008 (verified login links) and 009 (recovery requests) were applied and registered at operator-confirmed checkpoints. One externally verified pilot login link was confirmed. These are dated checkpoints, not a fresh database count.

The operator reports the browser checks complete. Retain that as operator evidence, not an independent live CSRF/replay/approval test. Prior signed-out forged-header checks returned 302 on protected entry routes, 403 on Supporter admin and 200 on public support. No new real link, payment or Plex operation was performed for this documentation update.

Latest recovery wording/raw-field hardening has 96 focused passing source checks (no skips). A newer running image is now observed, but its exact bundled source hasn't been compared: don't assume those source changes are either still absent or verified deployed. Payment intake still associates unknown provider accounts by normalized email; review that ownership risk before verified-link activation. Native OIDC and app-specific login appearance remain planned. See [the identity rollout](BROSS-IDENTITY-ROLLOUT.md) for evidence and remaining gates.

For the PostgreSQL 16 temporary test, use network none, no host ports, tmpfs data and an active-host-swap check. Set `PGDATA=/var/lib/postgresql/data` directly on its 0700 tmpfs mount so the image's ownership setup covers the mounted directory. Don't put PGDATA beneath a root-owned 0700 parent. Retain root-private backup/log permissions, and remove only the newly captured test-container ID. Take a fresh backup again before production migration; schema testing is not full disaster-recovery or concurrency validation.

## Safe working method

Before any further rebuild, compare exact bundled code against source without exposing secrets. The newest observed image differs from recorded recovery deployment; older hash-pinned commands correctly detect source drift and mustn't be reused as current recipes. Rebuild/recreate only through Compose Manager GUI. Preserve additive008/009, ownership data and newer payment events on rollback; never restore an old archive over newer transactions.

For isolated PostgreSQL16 checks, use network none, no host ports, tmpfs data and an active-swap check. Set `PGDATA=/var/lib/postgresql/data` directly on its mount so image ownership setup covers it. Retain private diagnostics and remove only captured temporary container IDs.

Every live change follows the same path:

1. Identify the live source of truth.
2. Read the current file and check for unrelated user changes.
3. Copy only the required files to a local, secret-free staging directory.
4. Make the smallest change.
5. Run syntax checks and tests in staging.
6. Create a timestamped backup of each live file that will change.
7. Copy the named files back.
8. Compare SHA-256 hashes.
9. Rebuild or reload only the affected service.
10. Test the public and LAN paths.

Never bulk-copy over appdata. Keep `node_modules`, databases, logs, and secret environment files out of staging and deployment copies.

## Working across the network share

Mapped drives verified on this workstation:

- `R:` -> `\\TOWER\addonfiles`
- `Q:` -> `\\TOWER\Files`
- `O:` -> `\\TOWER\flash`
- `B:` and `H:` -> `\\TOWER\flash\homelab-ops`

Some Windows tools cannot launch with a UNC current directory. Set a local working directory and use an absolute target path:

```powershell
Set-Location C:\Users\Natural
Get-Content -LiteralPath 'R:\dockers\appdata\swag\www\bross\index.html'
```

Patch in a local staging path, validate the result, then copy the exact file back. Never deploy production changes with a broad wildcard.

## Static B.Ross deployment

Live root:

`/mnt/cache_addons/addonfiles/dockers/appdata/swag/www/bross`

HTML, CSS, JavaScript, image, audio, video, and JSON changes are visible without a container rebuild.

After deployment:

- Use a hard refresh.
- Test Media and Cloud selection.
- Test desktop mouse and mobile touch dropdown behavior.
- Test music startup after a user interaction.
- Test Watch, Hosting, Support, and Donate.
- Test protected admin redirect while signed out.

## Static Natural Carr deployment

Live root:

`/mnt/cache_addons/addonfiles/dockers/appdata/swag/www/natural`

After deployment:

- Test the root and every role route.
- Confirm the title, not only the HTTP 200 status.
- Test each job page and its JSON download.
- Test the live metric request with browser developer tools.
- Hover the uptime card and inspect every service row.
- Test keyboard, mouse wheel, touch, and reduced motion.

## B.Ross API

Compose project:

```sh
cd /boot/config/plugins/compose.manager/projects/bross-api
```

Validate source:

```sh
cd /mnt/cache_addons/addonfiles/dockers/appdata/bross-api
npm test
```

Validate, then build through Unraid's Compose Manager GUI:

```sh
cd /boot/config/plugins/compose.manager/projects/bross-api
docker compose config --quiet
```

Verify:

```sh
docker compose ps
docker compose logs --tail=100 bross-api
curl -sS http://127.0.0.1:3100/api/health
curl -sS http://127.0.0.1:3100/api/uptime
```

## Membership gateway

Targeted deployment-path verification: 2026-09-16. Source is the private build context, not the flash-drive service copy. Recreate/rebuild through the Unraid Compose Manager GUI only. The [identity rollout](BROSS-IDENTITY-ROLLOUT.md) records the applied header/proxy/network changes, exact backups, and remaining phase gates. Port 3110 is no longer published; don't use host-port health checks or old LAN-upstream backups without coordinating Compose rollback.

Test:

```sh
cd /mnt/cache_addons/addonfiles/github/bross-supporter-gateway
pnpm test
```

Validate configuration without printing expanded secret values:

```sh
cd /boot/config/plugins/compose.manager/projects/bross-membership
docker compose config --quiet
```

Verify:

```sh
docker compose ps
docker compose logs --tail=100 membership
docker exec swag curl -fsS --max-time 10 http://bross-membership:3110/health
```

Never test webhooks with unsigned production requests. Use the provider's test tools or signed fixtures.

For operator-run deployment commands, use ready-to-paste inline blocks rather than creating new script files. On `/boot`, copy file contents without ownership-preservation flags (`cp -p` fails on the flash filesystem). Back up exact destinations, compare hashes, and validate effective Compose quietly before GUI recreation. The Phase 1B network change used existing images, without rebuilding the dirty gateway source.

## SWAG configuration

Live host configuration:

`/mnt/cache_addons/addonfiles/dockers/appdata/swag/nginx/site-confs/default.conf`

Authentik host configuration:

`/mnt/cache_addons/addonfiles/dockers/appdata/swag/nginx/site-confs/auth.bross.cloud.conf`

Before a reload:

```sh
docker exec swag nginx -t
```

Reload only after a successful test:

```sh
docker exec swag nginx -s reload
```

Then test both the intended host and a host that must not receive the route.

## Uptime publication

The API publisher runs every five minutes. Check:

```sh
curl -sS http://127.0.0.1:3100/api/uptime
stat /mnt/cache_addons/addonfiles/dockers/appdata/swag/www/natural/assets/data/stats.json
stat /mnt/cache_addons/addonfiles/dockers/appdata/swag/www/natural/assets/data/uptime-history.json
```

Confirm:

- `generatedAt` changes.
- `updatedAt` changes.
- `daysCovered` does not unexpectedly reset.
- `observedSince` does not move forward without an intended prune.
- Monitor names match the published Kuma status page.
- `gapDays` does not grow.

## Uptime backfill

The backfill tool reads a copied Kuma SQLite database and merges older heartbeats into the retained JSON.

Run a dry run first:

```sh
docker run --rm --user 99:100 \
  -v /mnt/cache_addons/addonfiles/dockers/appdata/bross-api/src:/app/src:ro \
  -v /mnt/cache_addons/addonfiles/dockers/appdata/uptimekuma:/kuma:ro \
  -v /mnt/cache_addons/addonfiles/dockers/appdata/swag/www/natural/assets/data:/data \
  node:22-alpine \
  node /app/src/tools/backfill-kuma.js --slug alluserfacingservices --dry-run
```

Review:

- Date range before and after.
- Number of imported beats.
- Monitor mapping.
- Pooled uptime.
- Equal-weight monitor mean.
- Whether one monitor controls the pooled result.

Back up `uptime-history.json` before the non-dry run.

## Resume publication

Private source:

`Q:\resumes\json`

Published job copies:

`R:\dockers\appdata\swag\www\natural\js\<job-id>`

For each update:

1. Edit the private source.
2. Validate it as JSON.
3. Import it into Reactive Resume and check the target template.
4. Copy the approved JSON to the related public directory.
5. Confirm the page link downloads that exact file.
6. Compare hashes.

PDF files must be regenerated from the approved JSON. Do not treat old PDFs as current source.

## Home IT site

```sh
cd /boot/homelab-ops/hire-site
npm test
```

After a successful static build, copy only the generated `index.html` and approved `og.png` to SWAG `www/hire`.

## Backup priority

Highest priority:

- `uptime-history.json`
- Membership PostgreSQL data and tested logical exports
- B.Ross playlist/default JSON
- Secret environment files through a protected backup method
- SWAG site and nginx configuration
- B.Ross API source
- Homelab repository
- Resume master JSON

## Rollback

Keep timestamped backups next to the changed file or in a private backup directory. Rollback restores the exact file, validates it, then rebuilds or reloads only when required.

Never use a recursive delete or a destructive Git reset as a rollback method.
