# B.Ross Service Subdomains

Verified: 2026-09-18 (gateway inspection, source and installed admin files). Other service checks retain their stated dates.

## Current membership and admin state

The gateway is healthy. Owner login-link review and signed-in recovery are enabled. Member lookup remains `legacy_email`; enforcement remains `dry_run`. No gateway host ports are published. SWAG reaches `bross-membership:3110` on the dedicated edge network; PostgreSQL stays on the internal database network.

Use `https://supporter.bross.cloud/` for membership status and `GET/POST /identity-recovery` for account-link help (no portal subdirectory). Use only `https://admin.bross.cloud/` for administration: B.Ross Media and Supporter Management are tabs. Login links and recovery requests stay inside Supporter Management. Internal renderer/API routes remain necessary, but aren't separate operator entry pages. Supporter's admin paths remain denied.

Production migrations 008 (verified login links) and 009 (recovery requests) were applied and registered at operator-confirmed checkpoints. One externally verified pilot login link was confirmed. These are dated checkpoints, not a fresh database count.

The operator reports the browser checks complete. Retain that as operator evidence, not an independent live CSRF/replay/approval test. Prior signed-out forged-header checks returned 302 on protected entry routes, 403 on Supporter admin and 200 on public support. No new real link, payment or Plex operation was performed for this documentation update.

Latest recovery wording/raw-field hardening has 96 focused passing source checks (no skips). A newer running image is now observed, but its exact bundled source hasn't been compared: don't assume those source changes are either still absent or verified deployed. Payment intake still associates unknown provider accounts by normalized email; review that ownership risk before verified-link activation. Native OIDC and app-specific login appearance remain planned. See [the identity rollout](BROSS-IDENTITY-ROLLOUT.md) for evidence and remaining gates.

This is the SWAG-side map for each service host. Product backups and administration still belong in their own guides.

## Invitation service

Hosts:

- `letme.in.bross.cloud`
- `invitation.bross.cloud`

Both proxy to Wizarr on `192.168.1.253:5690`.

Wizarr handles the B.Ross invitation flow. The membership gateway observes users/invitations and can queue supporter invites behind its safety controls.

`invitation.bross.cloud` redirected to its admin route during the check. `letme.in.bross.cloud` did not return a result. Confirm DNS, certificate coverage, and upstream host handling for the alias.

## Read

Host:

`read.bross.cloud`

Purpose:

Ubooquity library access.

Proxy map:

- General paths -> `192.168.1.253:2202`.
- `/admin`, `/admin-res`, and `/admin-api` -> `192.168.1.253:2203`.

SWAG does not put Authentik in front of these admin paths. Verify Ubooquity's own access control before treating them as protected.

## Request

Host:

`request.bross.cloud`

Purpose:

Ombi media requests.

Upstream:

`192.168.1.253:3579`

The public B.Ross Media menu links directly to this host.

Access update: 2026-09-16. Authentik forward auth now gates the UI using New's existing flows and `require-plex-friends` binding. Native Ombi login and existing API exemptions remain. The LAN upstream repair is applied and operator-confirmed working.

## Stats

Host:

`stats.bross.cloud`

Purpose:

Tautulli Plex statistics.

Upstream:

`192.168.1.253:8181`

`/stats` is passed to the upstream's `/stats` path. Other paths go to the upstream root. The live root redirected through Tautulli's own auth behavior during the check.

The B.Ross API also queries Tautulli on the LAN with a private API key.

Access update: 2026-09-16. Authentik gates the UI; native individual Plex/guest sessions and per-user history limits remain unchanged. Existing API/newsletter/image exemptions remain. Don't inject shared Basic/admin credentials to simulate SSO.

## Supporter portal

`https://supporter.bross.cloud/` is the current membership portal (no `/manage` subdirectory). SWAG forwards verified Authentik identity to `bross-membership:3110` over a dedicated edge network. Port 3110 is unpublished and PostgreSQL is on an internal database-only network shared with the gateway. Support/checkout/signed webhook routes stay public on `bross.cloud` and clear identity headers. See [the identity rollout](BROSS-IDENTITY-ROLLOUT.md) for verified state, backups, and future identity/login work.

## MeshCentral

Host:

`meshcentral.bross.cloud`

Purpose:

VM and endpoint management portal linked from the Cloud Hosting menu.

Upstream:

HTTPS `192.168.1.253:8087`

Proxy behavior:

- Explicit HTTP-to-HTTPS redirect.
- HTTP/1.1 upstream.
- WebSocket Upgrade and Connection headers.
- Forwarded host, client, and protocol headers.
- 330-second send and read timeouts.
- Upstream HSTS header hidden; SWAG supplies edge HSTS.

## Jellyfin

Host:

`jellyfin.bross.cloud`

Purpose:

Media streaming and one of the three Watch choices.

Upstream:

`192.168.1.253:8097`

Proxy behavior:

- Shared proxy and resolver includes.
- Range and If-Range headers for streaming.
- WebSocket route for `/socket`.
- `/metrics` limited to RFC1918 and loopback IPv4 ranges.

The host returned 502 during the 2026-09-07 point-in-time check.

## Nextcloud

Host:

`nextcloud.bross.cloud`

Purpose:

Cloud Drive storage.

Upstream:

`192.168.1.253:11000`

Proxy behavior:

- Unlimited client body size at nginx.
- Shared proxy and resolver includes.
- Proxy buffering disabled.
- Upstream Strict-Transport-Security, Referrer-Policy, X-Content-Type-Options, X-Frame-Options, and X-XSS-Protection headers hidden to prevent conflict with SWAG.

The configured variable says HTTPS while the active `proxy_pass` uses HTTP. Confirm the intended upstream protocol, then remove the stale variable/comment.

## Recently added

Host:

`new.bross.cloud`

Purpose:

Tautulli-generated recently-added media report.

Source:

`/config/www/bross/tautulli/recentlyadded.html`

Access:

Authentik forward auth.

The directory contains many generated newsletter issue files. Keep generation and archival separate from hand-authored site source.

## B.Ross admin

Host:

`admin.bross.cloud`

Purpose:

One owner-only tabbed root: B.Ross Media (playlists, defaults, preview, rename and downloaders) and Supporter Management (gateway dashboard, login links and recovery requests). Embedded views/APIs are internal, not standalone operator pages.

Access:

Authentik forward auth.

Targets:

- Static tabbed shell from `/config/www/bross/admin.html`.
- Internal gateway `/admin` namespace -> `bross-membership:3110` on the private edge.
- `/api/` -> port 3100.
- `/youtube-dl` -> port 8282.
- `/youtube-dl-auto` -> port 4848 after prefix rewrite.

## Navidrome

Host:

`navidrome.bross.cloud`

Purpose:

Music service.

Upstream:

`192.168.1.253:4533`

Authentik includes exist only as comments. Navidrome's own login is the current control.

## Plex 1

Host:

`plex.bross.cloud`

Upstream:

`192.168.1.253:32400`

Purpose:

Primary Plex media service.

Proxy behavior:

- Unlimited client body size.
- Proxy redirects and buffering disabled.
- Shared proxy and resolver includes.
- Passes Plex client, device, platform, product, token, version, cache, provider, vendor, and model headers.

The membership design keeps this server observation-only for automated access enforcement.

## Plex 2

Host:

`plex2.bross.cloud`

Upstream:

`192.168.1.253:42400`

It uses the same streaming and Plex-header policy as Plex 1. The membership design allows guarded enforcement only on a server explicitly configured for it; the current handoff names Plex 2.

## Authentik

Host:

`auth.bross.cloud`

Upstream:

`authentik-server:9000` through Docker DNS.

This host has its own SWAG file. See [Authentik integration](AUTHENTIK.md).

## Inactive hosts

The following names appear only in disabled or commented configuration:

- `wedding.bross.cloud`.
- The old ZNC host.
- `j2024.bross.cloud`.


Do not call these active until they are enabled and tested.

## Natural Carr admin and resume editor

`admin.naturalcarr.com` serves `/config/www/natural-admin` behind owner-only Authentik. The header Sign Out button uses `/outpost.goauthentik.io/sign_out`.

`resume.naturalcarr.com` has an active SWAG block proxying to `192.168.1.253:3000`. Configuration checked on 2026-09-18; upstream availability/authorization weren't retested.
