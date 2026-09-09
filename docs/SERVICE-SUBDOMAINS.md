# B.Ross Service Subdomains

Verified: 2026-09-07

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

## Stats

Host:

`stats.bross.cloud`

Purpose:

Tautulli Plex statistics.

Upstream:

`192.168.1.253:8181`

`/stats` is passed to the upstream's `/stats` path. Other paths go to the upstream root. The live root redirected through Tautulli's own auth behavior during the check.

The B.Ross API also queries Tautulli on the LAN with a private API key.

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

Media playlist/default management, preview and rename, youtube-dl, and TubeSync.

Access:

Authentik forward auth.

Targets:

- Static admin page from `/config/www/bross/admin.html`.
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
- `resume.naturalcarr.com`.

Do not call these active until they are enabled and tested.
