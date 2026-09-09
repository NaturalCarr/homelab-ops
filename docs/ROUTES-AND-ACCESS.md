# Routes and Access

Verified: 2026-09-07

## Public route matrix

| Public route | Purpose | SWAG target | Access |
|---|---|---|---|
| `https://bross.cloud/` | Main B.Ross media and cloud portal | Static `/config/www/bross` | Public |
| `https://bross.cloud/api/*` | Public B.Ross API | `192.168.1.253:3100` | Public read and tracking routes |
| `https://bross.cloud/support` | Membership plans | `192.168.1.253:3110` | Public |
| `https://bross.cloud/checkout/stripe` | Stripe Checkout creation | `192.168.1.253:3110` | Public POST |
| `https://bross.cloud/webhooks/paypal` | PayPal event intake | `192.168.1.253:3110` | Public signed POST |
| `https://bross.cloud/webhooks/patreon` | Patreon event intake | `192.168.1.253:3110` | Public signed POST |
| `https://bross.cloud/webhooks/stripe` | Stripe event intake | `192.168.1.253:3110` | Public signed POST |
| `https://bross.cloud/manage` | Supporter self-service | `192.168.1.253:3110` | Application session |
| `https://admin.bross.cloud/` | B.Ross media administration | Static `/config/www/bross/admin.html` | Authentik |
| `https://admin.bross.cloud/api/*` | Admin media API | `192.168.1.253:3100` | Authentik at SWAG |
| `https://admin.bross.cloud/youtube-dl` | Downloader UI | `192.168.1.253:8282/youtube-dl` | Authentik at SWAG |
| `https://admin.bross.cloud/youtube-dl-auto` | TubeSync UI | `192.168.1.253:4848` | Authentik at SWAG |
| `https://new.bross.cloud/` | Recently added media report | Static `/config/www/bross/tautulli/recentlyadded.html` | Authentik |
| `https://auth.bross.cloud/` | Authentik service | `authentik-server:9000` on Docker DNS | Authentik |
| `https://letme.in.bross.cloud/` | Wizarr invitation service | `192.168.1.253:5690` | Upstream application |
| `https://invitation.bross.cloud/` | Wizarr invitation service alias | `192.168.1.253:5690` | Upstream application |
| `https://read.bross.cloud/` | Ubooquity library | `192.168.1.253:2202` | Upstream application |
| `https://read.bross.cloud/admin*` | Ubooquity administration | `192.168.1.253:2203` | Upstream application |
| `https://request.bross.cloud/` | Ombi requests | `192.168.1.253:3579` | Upstream application |
| `https://stats.bross.cloud/` | Tautulli | `192.168.1.253:8181` | Upstream application |
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
| `https://naturalcarr.com/js/<job-id>/` | Job-specific portfolio | Static directory | Public |
| `https://bross.naturalcarr.com/` | Home IT and smart-home services | Static `/config/www/hire` | Public |

`resume.naturalcarr.com`, `wedding.bross.cloud`, the old ZNC host, and `j2024.bross.cloud` are present only in disabled or commented configuration. They are not active routes.

The standalone dataviz directory has no active SWAG server block. `naturalcarr.com/dataviz/` does not reach it; the Natural Carr fallback serves the main portfolio page at that path.

## Job-specific Natural Carr routes

| Identifier | Route | Resume JSON |
|---|---|---|
| `branch-cloud-ops` | `/js/branch-cloud-ops/` | `natural-carr-branch-cloud-operations-engineer-resume.json` |
| `cuny-infra-ops` | `/js/cuny-infra-ops/` | `natural-carr-cuny-infrastructure-operations-engineer-resume.json` |
| `datadog-service-management` | `/js/datadog-service-management/` | `natural-carr-datadog-developer-advocate-service-management-resume.json` |
| `kalshi-it-admin` | `/js/kalshi-it-admin/` | `natural-carr-kalshi-it-administrator-resume.json` |
| `my-it-crew-senior-support` | `/js/my-it-crew-senior-support/` | `natural-carr-my-it-crew-senior-it-support-engineer-resume.json` |
| `orveon-infrastructure` | `/js/orveon-infrastructure/` | `natural-carr-orveon-infrastructure-engineer-resume.json` |
| `plaid-techops` | `/js/plaid-techops/` | `natural-carr-plaid-techops-engineer-resume.json` |

The `sysadmin` page also contains the NHL IT Service Desk Manager resume JSON.

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
curl -sS http://192.168.1.253:3110/health
```

Direct port 3100 access bypasses SWAG and Authentik. Treat it as a trusted-LAN interface until application authentication or firewall restrictions are added.
