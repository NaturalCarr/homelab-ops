# Platform Overview

Verified: 2026-09-07

## Purpose

Two public-facing parts share the same infrastructure:

- B.Ross provides media, cloud, hosting, support, and membership services.
- Natural Carr provides the professional portfolio, role-specific pages, job-specific pages, resumes, and freelance home IT services.

SWAG sits in front of both. It terminates TLS, selects the host, serves static files, and proxies application traffic back to Tower.

## Request flow

```text
Public client
    |
    v
DNS and HTTPS
    |
    v
SWAG / nginx on Tower
    |
    +-- Static roots
    |     +-- /config/www/bross   -> bross.cloud
    |     +-- /config/www/natural -> naturalcarr.com
    |     +-- /config/www/hire    -> bross.naturalcarr.com
    |
    +-- Node services
    |     +-- 192.168.1.253:3100 -> B.Ross API
    |     +-- 192.168.1.253:3110 -> membership gateway
    |
    +-- Identity gate
    |     +-- Authentik outpost -> admin.bross.cloud and new.bross.cloud
    |
    +-- Product services
          +-- Plex / Plex2 / Jellyfin
          +-- Nextcloud / Navidrome / Ubooquity
          +-- Ombi / Tautulli / Wizarr / MeshCentral
```

## Main components

| Component | Technology | Purpose |
|---|---|---|
| SWAG | nginx, Let's Encrypt integration | TLS termination, static hosting, reverse proxy, Authentik integration |
| B.Ross site | Static HTML, CSS, JavaScript | Media and cloud service launcher, background media, audio player, donations, VPS quote UI |
| B.Ross admin | Static HTML, CSS, JavaScript | Playlist, default-media, preview, scrub, and rename controls |
| B.Ross API | Node.js 22, Express 4, `music-metadata` | Media index, admin writes, visitor counts, Tautulli stats, and long-term uptime |
| Membership gateway | Node.js 22, Express 5, PostgreSQL 16 | Payment-provider intake, supporter portal, identity matching, review, and controlled access enforcement |
| Natural Carr site | Static HTML, CSS, JavaScript | Portfolio pages, targeted role pages, targeted job pages, and live platform metrics |
| Dataviz | Static HTML, CSS, JavaScript, SVG | Container and Plex activity dashboard with live account and uptime updates |
| Home IT site | React 19, TypeScript, vinext/Vite; deployed as static HTML | Freelance home IT and smart-home services |
| Authentik | Separate Compose stack | Identity provider and forward-auth control for protected SWAG hosts |

## Data flow

### Media library

1. The B.Ross API scans `/assets/sound` and the configured background-video directory.
2. It reads audio metadata with `music-metadata`.
3. The B.Ross front end reads `/api/songs` and `/api/backgrounds`.
4. The admin page reads `/api/admin/*` and can update playlist JSON, default selections, and file names.
5. nginx serves the audio and video bytes as static assets.

### Published platform statistics

1. The B.Ross API queries Tautulli and the published Uptime Kuma status page.
2. The API writes `stats.json` and `uptime-history.json` to the Natural Carr data directory.
3. Natural Carr loads `/assets/data/stats.json` with cache disabled.
4. Dataviz loads `/api/stats` and `/api/uptime` when opened from a compatible HTTP origin. It uses `https://bross.cloud/api` when opened from a local file.

### Long-term uptime

Kuma doesn't keep the full history used by the portfolio. The B.Ross API polls it, stores daily totals, and maintains a rolling 365-day file. Once Kuma removes old heartbeats, that file is the only complete copy. Back it up.

The API publishes two long-term values:

- `uptimeMean` gives each monitor equal weight. The sites use this value for the user-facing uptime figure.
- `uptime` pools every heartbeat. A monitor with more historical heartbeats has more weight in this value.

The `stats.json` field named `uptime` is the current 24-hour mean from Kuma. It is not the accumulated 365-day mean. The accumulated pooled value is in `uptimePooled`.

### Membership

1. Stripe, PayPal, and Patreon send signed events to public webhook routes.
2. The gateway verifies each provider signature and normalizes the membership state in PostgreSQL.
3. Supporters use `/manage` for sign-in, status, and link requests.
4. Administrators use a private dashboard and review queues.
5. Plex remains the media-access authority. The gateway applies strict review and enforcement gates before any write.

## Deployment boundaries

- Static SWAG files become active after a file copy. A browser hard refresh can be required.
- B.Ross API source is built into a container. A source change needs a Compose rebuild.
- Membership source is built from the flash-drive repository. A source change needs a Compose rebuild.
- An nginx configuration change needs `nginx -t` before reload.
- Authentik policy and provider changes are separate from these files.

## Current status snapshot

Read-only checks on 2026-09-07 found:

- B.Ross API health: HTTP 200; 58 indexed tracks.
- Membership health: HTTP 200; database status `ok`.
- Natural Carr role pages: HTTP 200.
- B.Ross main, support, manage, and API health routes: HTTP 200.
- `admin.bross.cloud` and `new.bross.cloud`: redirected to Authentik.
- `jellyfin.bross.cloud`: HTTP 502 during the check.
- `letme.in.bross.cloud`: no HTTP result during the check; `invitation.bross.cloud` redirected to Wizarr admin.

This was a point-in-time check. It is not monitoring history.
