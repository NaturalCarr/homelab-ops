# Site Operations

Verified: 2026-09-07

## Safe working method

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

Build:

```sh
cd /boot/config/plugins/compose.manager/projects/bross-api
docker compose config
docker compose up -d --build
```

Verify:

```sh
docker compose ps
docker compose logs --tail=100 bross-api
curl -sS http://127.0.0.1:3100/api/health
curl -sS http://127.0.0.1:3100/api/uptime
```

## Membership gateway

Test:

```sh
cd /boot/homelab-ops/services/bross-membership
pnpm test
```

Build:

```sh
cd /boot/config/plugins/compose.manager/projects/bross-membership
docker compose config
docker compose up -d --build
```

Verify:

```sh
docker compose ps
docker compose logs --tail=100 membership
curl -sS http://127.0.0.1:3110/health
```

Never test webhooks with unsigned production requests. Use the provider's test tools or signed fixtures.

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
