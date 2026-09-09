# SWAG Edge

Verified: 2026-09-07

## Purpose

SWAG is the shared HTTPS edge. It terminates TLS, selects the host, serves static roots, proxies application traffic, handles Authentik forward auth, and feeds nginx logs to Fail2ban.

## Source of truth

- Windows: `R:\dockers\appdata\swag\nginx`
- UNC: `\\TOWER\addonfiles\dockers\appdata\swag\nginx`
- Unraid: `/mnt/cache_addons/addonfiles/dockers/appdata/swag/nginx`
- Container: `/config/nginx`

Current host files:

- `site-confs/default.conf` - B.Ross, Natural Carr, home IT, and service proxy hosts.
- `site-confs/auth.bross.cloud.conf` - Authentik host.
- `ssl.conf` - shared TLS settings and HSTS.
- `proxy.conf` - shared proxy headers and behavior.
- `resolver.conf` - Docker resolver settings for applicable upstreams.
- `authentik-server.conf` - outpost and authorization subrequest locations.
- `authentik-location.conf` - per-request Authentik check and identity headers.

`hire-site/deploy/default.conf` is an old copy. It is not live nginx configuration.

## Static roots

| nginx root | Hosts |
|---|---|
| `/config/www/bross` | `bross.cloud`, `admin.bross.cloud`, `new.bross.cloud` |
| `/config/www/natural` | `naturalcarr.com` |
| `/config/www/hire` | `bross.naturalcarr.com` |

Absolute browser paths such as `/assets/...` resolve inside the requesting host's root.

## Catch-all behavior

- Port 80 catch-all returns a 301 redirect to the same host over HTTPS.
- The default undeclared HTTPS server returns nginx status 444.
- The default HTTPS block has no public web root.

## TLS

The shared configuration:

- Enables TLS 1.2 and TLS 1.3.
- Disables session tickets.
- Uses a one-day session timeout.
- Sends one-year HSTS.
- Uses shared certificate files under `/config/keys/letsencrypt`.

`bross.naturalcarr.com` names certificate paths directly instead of including the full `ssl.conf`. It may miss shared TLS directives or headers, so retest that host after every TLS baseline change.

## Authentication includes

Protected servers include `authentik-server.conf` and `authentik-location.conf` at server scope.

The server include:

- Exposes the Authentik outpost path without forward auth.
- Makes the authorization subrequest route internal.
- Sends unauthenticated users to the Authentik start route.

The location include:

- Runs `auth_request`.
- Preserves the returned session cookie.
- passes verified identity headers to the upstream.

## Proxy patterns

- Static sites use `try_files`.
- B.Ross API and membership routes proxy to fixed LAN addresses.
- Media-server routes disable buffering where streaming requires it.
- Plex receives its `X-Plex-*` headers.
- MeshCentral uses HTTPS to the upstream, WebSocket upgrade headers, and 330-second timeouts.
- Jellyfin passes Range headers and has a WebSocket location.
- Nextcloud disables proxy buffering and hides upstream security headers that conflict with SWAG.

## Reload procedure

```sh
docker exec swag nginx -t
docker exec swag nginx -s reload
```

If `nginx -t` fails, stop. Do not reload.

## Validation set

After a route change:

1. Test HTTP-to-HTTPS.
2. Test the intended hostname.
3. Test an undeclared hostname.
4. Test the specific path and HTTP method.
5. Test signed-out and signed-in behavior if Authentik applies.
6. Test the upstream directly on LAN when safe.
7. Check nginx error and access logs.
8. Check Fail2ban for unintended bans.
