# Routes and Access

Verified: 2026-09-18 (gateway inspection, source and installed admin files). Other service checks retain their stated dates.

## Current membership and admin state

The gateway is healthy. Owner login-link review and signed-in recovery are enabled. Member lookup remains `legacy_email`; enforcement remains `dry_run`. No gateway host ports are published. SWAG reaches `bross-membership:3110` on the dedicated edge network; PostgreSQL stays on the internal database network.

Use `https://supporter.bross.cloud/` for membership status and `GET/POST /identity-recovery` for account-link help (no portal subdirectory). Use only `https://admin.bross.cloud/` for administration: B.Ross Media and Supporter Management are tabs. Login links and recovery requests stay inside Supporter Management. Internal renderer/API routes remain necessary, but aren't separate operator entry pages. Supporter's admin paths remain denied.

Production migrations 008 (verified login links) and 009 (recovery requests) were applied and registered at operator-confirmed checkpoints. One externally verified pilot login link was confirmed. These are dated checkpoints, not a fresh database count.

The operator reports the browser checks complete. Retain that as operator evidence, not an independent live CSRF/replay/approval test. Prior signed-out forged-header checks returned 302 on protected entry routes, 403 on Supporter admin and 200 on public support. No new real link, payment or Plex operation was performed for this documentation update.

Latest recovery wording/raw-field hardening has 96 focused passing source checks (no skips). A newer running image is now observed, but its exact bundled source hasn't been compared: don't assume those source changes are either still absent or verified deployed. Payment intake still associates unknown provider accounts by normalized email; review that ownership risk before verified-link activation. Native OIDC and app-specific login appearance remain planned. See [the identity rollout](BROSS-IDENTITY-ROLLOUT.md) for evidence and remaining gates.

## Public route matrix

| Public route | Purpose | SWAG target | Access |
|---|---|---|---|
| `https://bross.cloud/` | Main B.Ross media and cloud portal | Static `/config/www/bross` | Public |
| `https://bross.cloud/api/*` | Public B.Ross API | `192.168.1.253:3100` | Public read and tracking routes |
| `https://bross.cloud/support` and `/support/` | Membership plans | `bross-membership:3110` on private Docker DNS | Public; identity headers cleared |
| `https://bross.cloud/checkout/stripe` | Stripe Checkout creation | `bross-membership:3110` | Public POST; identity headers cleared |
| `https://bross.cloud/webhooks/paypal` | PayPal event intake | `bross-membership:3110` | Public signed POST; identity headers cleared |
| `https://bross.cloud/webhooks/patreon` | Patreon event intake | `bross-membership:3110` | Public signed POST; identity headers cleared |
| `https://bross.cloud/webhooks/stripe` | Stripe event intake | `bross-membership:3110` | Public signed POST; identity headers cleared |
| `https://supporter.bross.cloud/` | Supporter self-service | `bross-membership:3110` | Authentik at SWAG; verified identity forwarded |
| `https://admin.bross.cloud/` | Tabbed B.Ross Media / Supporter Management | Static `/config/www/bross/admin.html` | Authentik |
| `https://supporter.bross.cloud/identity-recovery` | Signed-in account-link help | `bross-membership:3110` | Authentik + identity-bound form guards |
| `https://admin.bross.cloud/admin/*` | Internal embedded gateway views/APIs, not entry pages | `bross-membership:3110` | Owner-only Authentik; independent identity-decision guards |
| `https://admin.bross.cloud/api/*` | Admin media API | `192.168.1.253:3100` | Authentik at SWAG |
| `https://admin.bross.cloud/youtube-dl` | Downloader UI | `192.168.1.253:8282/youtube-dl` | Authentik at SWAG |
| `https://admin.bross.cloud/youtube-dl-auto` | TubeSync UI | `192.168.1.253:4848` | Authentik at SWAG |
| `https://new.bross.cloud/` | Recently added media report | Static `/config/www/bross/tautulli/recentlyadded.html` | Authentik |
| `https://auth.bross.cloud/` | Authentik service | `authentik-server:9000` on Docker DNS | Authentik |
| `https://letme.in.bross.cloud/` | Wizarr invitation service | `192.168.1.253:5690` | Upstream application |
| `https://invitation.bross.cloud/` | Wizarr invitation service alias | `192.168.1.253:5690` | Upstream application |
| `https://read.bross.cloud/` | Ubooquity library | `192.168.1.253:2202` | Upstream application |
| `https://read.bross.cloud/admin*` | Ubooquity administration | `192.168.1.253:2203` | Upstream application |
| `https://request.bross.cloud/` | Ombi requests | `192.168.1.253:3579` | Authentik plus native app session; existing API exemptions retained |
| `https://stats.bross.cloud/` | Tautulli | `192.168.1.253:8181` | Authentik plus individual Plex/guest session; existing API/newsletter/image exemptions retained |
| `https://meshcentral.bross.cloud/` | VM and endpoint management | HTTPS `192.168.1.253:8087` | Upstream application |
| `https://jellyfin.bross.cloud/` | Jellyfin media server | `192.168.1.253:8097` | Upstream application |
| `https://jellyfin.bross.cloud/metrics` | Jellyfin Prometheus metrics | `192.168.1.253:8097` | Private IPv4 ranges only |
| `https://nextcloud.bross.cloud/` | Cloud Drive | `192.168.1.253:11000` | Nextcloud login |
| `https://navidrome.bross.cloud/` | Music service | `192.168.1.253:4533` | Navidrome login |
| `https://plex.bross.cloud/` | Plex server 1 | `192.168.1.253:32400` | Plex authentication |
| `https://plex2.bross.cloud/` | Plex server 2 | `192.168.1.253:42400` | Plex authentication |
| `https://naturalcarr.com/` | Main DevOps portfolio | Static `/config/www/natural` | Public |
| `https://naturalcarr.com/devops/` | DevOps portfolio alias | Static directory | Public |
| `https://naturalcarr.com/it-manager/` | IT management portfolio | Static directory | Public |
| `https://naturalcarr.com/sysadmin/` | IT service desk and operations portfolio | Static directory | Public |
| `https://naturalcarr.com/systems/` | General IT and systems portfolio | Static directory | Public |
| `https://naturalcarr.com/js/<capability-profile>/` | Tailored capability portfolio | Static directory | Public |
| `https://admin.naturalcarr.com/` | Portfolio admin with Sign Out | Static `/config/www/natural-admin` | Owner-only Authentik |
| `https://resume.naturalcarr.com/` | Reactive Resume | `192.168.1.253:3000` | Active SWAG block; upstream availability not retested |
| `https://bross.naturalcarr.com/` | Home IT and smart-home services | Static `/config/www/hire` | Public |

`wedding.bross.cloud`, the old ZNC host, and `j2024.bross.cloud` are present only in disabled or commented configuration. They are not active routes.

The standalone dataviz directory has no active SWAG server block. `naturalcarr.com/dataviz/` does not reach it; the Natural Carr fallback serves the main portfolio page at that path.

## Tailored Natural Carr routes

Membership/identity verification: 2026-09-16. The member portal is at https://supporter.bross.cloud/; all owner administration is in the tabs at https://admin.bross.cloud/. All seven membership proxy locations use the private Docker-DNS helper. No host IPv4/IPv6 port bindings remain on the gateway/database. The operator confirmed LAN port-3110 denial and working public support/signed-in portal. See [the identity rollout](BROSS-IDENTITY-ROLLOUT.md) for the full state and acceptance gates.

| Identifier | Route | Resume JSON |
|---|---|---|
| `cloud-ops` | `/js/cloud-ops/` | `natural-carr-branch-cloud-ops-engineer-resume.json` |
| `infra-ops` | `/js/infra-ops/` | `natural-carr-infrastructure-operations-resume.json` |
| `service-ops` | `/js/service-ops/` | `natural-carr-service-operations-resume.json` |
| `endpoint-id` | `/js/endpoint-id/` | `natural-carr-endpoint-identity-resume.json` |
| `systems-support` | `/js/systems-support/` | `natural-carr-systems-support-resume.json` |
| `azure-infra` | `/js/azure-infra/` | `natural-carr-azure-infrastructure-resume.json` |
| `endpoint-auto` | `/js/endpoint-auto/` | `natural-carr-endpoint-automation-resume.json` |
| `network-infra` | `/js/network-infra/` | `natural-carr-network-infrastructure-resume.json` |
| `linux-systems` | `/js/linux-systems/` | `natural-carr-linux-systems-resume.json` |
| `ops-process` | `/js/ops-process/` | `natural-carr-operations-process-resume.json` |

The `sysadmin` page also contains the NHL IT Service Desk Manager resume JSON.

The capability-based routes were standardized on 2026-09-17. Retired employer- and job-specific URLs remain compatibility redirects. Published JSON files must match the approved files under `Q:\resumes\json\job specific` by SHA-256.

Route names, published filenames, browser titles, and eyebrow copy must describe Natural Carr's verified capabilities or positioning. Never expose the target employer, exact job title, requisition number, or application ID anywhere in a public NaturalCarr.com URL or those public-facing fields. The Website profile label and destination URL in Reactive Resume must match the capability-based route. Internal canonical JSON filenames may retain application identifiers for source tracking.

Every Natural Carr portfolio route must store its own role-matched PDF in the route directory, and both visible resume buttons must download that PDF. JSON files are editable sources and may remain published for maintenance, but they are not the visitor-facing resume download. Verify each PDF by content type and `%PDF` signature because a missing file can be masked by the root-page fallback.

## Path translations

### Windows paths

| Use | Drive path | UNC path |
|---|---|---|
| Appdata and public site files | `R:\dockers\appdata` | `\\TOWER\addonfiles\dockers\appdata` |
| Flash drive and Compose projects | `O:\` | `\\TOWER\flash` |
| Homelab repository | `O:\homelab-ops` | `\\TOWER\flash\homelab-ops` |
| Resume library | `Q:\resumes` | `\\TOWER\Files\Documents\resumes` |

### Unraid paths

| Windows/UNC area | Unraid path |
|---|---|
| `R:\dockers\appdata` | `/mnt/cache_addons/addonfiles/dockers/appdata` |
| `O:\config\plugins\compose.manager\projects` | `/boot/config/plugins/compose.manager/projects` |
| `O:\homelab-ops` | `/boot/homelab-ops` |
| `Q:\resumes` | Usually `/mnt/user/Files/Documents/resumes`; verify the share path on Tower before a write |

### Container paths

| Host path | Container path | Container |
|---|---|---|
| SWAG appdata | `/config` | `swag` |
| B.Ross web root | `/config/www/bross` | `swag` |
| Natural Carr web root | `/config/www/natural` | `swag` |
| Home IT web root | `/config/www/hire` | `swag` |
| B.Ross assets | `/assets` | `bross-api` |
| Natural data directory | `/data` | `bross-api` |
| Private visitor directory | `/tracking` | `bross-api` |

## Working from Windows

The SMB shares work through mapped drives or absolute UNC paths. Some Windows command runners cannot start with a UNC current directory and fail with `CreateProcessWithLogonW failed: 267`.

Use this pattern:

1. Start the command from a local path such as `C:\Users\Natural` or another local staging directory.
2. Pass the target as an absolute mapped-drive or UNC path.
3. Stage edits on a local writable path when a patch tool cannot operate against the share.
4. Copy only the named, verified files back to Tower.
5. Compare SHA-256 hashes after the copy.

SMB gives file access, not an Unraid shell. `docker compose`, `docker exec`, and host commands must run in Tower's terminal unless an approved SSH or remote Docker connection is available.

## Browser and command access

Use public HTTPS for user-facing checks:

```sh
curl -I https://bross.cloud/
curl -I https://admin.bross.cloud/
curl -sS https://bross.cloud/api/health
```

Use LAN ports for direct service checks from the local network:

```sh
curl -sS http://192.168.1.253:3100/api/health
```

Direct port 3100 access bypasses SWAG and Authentik. Treat it as a trusted-LAN interface until application authentication or firewall restrictions are added.

Membership port 3110 is intentionally unreachable from the LAN. From Tower's terminal, check its private health path through SWAG:

```sh
docker exec swag curl -fsS --max-time 10 http://bross-membership:3110/health
```
