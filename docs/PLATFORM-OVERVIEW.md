# Platform Overview

Verified: 2026-09-18 (gateway inspection, source and installed admin files). Other service checks retain their stated dates.

## Current membership and admin state

The gateway is healthy. Owner login-link review and signed-in recovery are enabled. Member lookup remains `legacy_email`; enforcement remains `dry_run`. No gateway host ports are published. SWAG reaches `bross-membership:3110` on the dedicated edge network; PostgreSQL stays on the internal database network.

Use `https://supporter.bross.cloud/` for membership status and `GET/POST /identity-recovery` for account-link help (no portal subdirectory). Use only `https://admin.bross.cloud/` for administration: B.Ross Media and Supporter Management are tabs. Login links and recovery requests stay inside Supporter Management. Internal renderer/API routes remain necessary, but aren't separate operator entry pages. Supporter's admin paths remain denied.

Production migrations 008 (verified login links) and 009 (recovery requests) were applied and registered at operator-confirmed checkpoints. One externally verified pilot login link was confirmed. These are dated checkpoints, not a fresh database count.

The operator reports the browser checks complete. Retain that as operator evidence, not an independent live CSRF/replay/approval test. Prior signed-out forged-header checks returned 302 on protected entry routes, 403 on Supporter admin and 200 on public support. No new real link, payment or Plex operation was performed for this documentation update.

Latest recovery wording/raw-field hardening has 96 focused passing source checks (no skips). A newer running image is now observed, but its exact bundled source hasn't been compared: don't assume those source changes are either still absent or verified deployed. Payment intake still associates unknown provider accounts by normalized email; review that ownership risk before verified-link activation. Native OIDC and app-specific login appearance remain planned. See [the identity rollout](BROSS-IDENTITY-ROLLOUT.md) for evidence and remaining gates.

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
    |     +-- bross-membership:3110 -> gateway on dedicated Docker edge
    |           +-- internal database network -> PostgreSQL
    |
    +-- Identity gate
    |     +-- Authentik outpost -> B.Ross/Natural Carr admin hosts
    |     +-- Authentik outpost -> New / Request / Stats / Supporter
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
| B.Ross admin | Static HTML, CSS, JavaScript | Two-tab media administration and embedded supporter management |
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
3. Supporters use `https://supporter.bross.cloud/` for Authentik sign-in, status, and link requests (no `/manage` subdirectory).
4. The owner uses the tabs at `https://admin.bross.cloud/`; Supporter Management contains gateway review/recovery queues.
5. Plex remains the media-access authority. The gateway applies strict review and enforcement gates before any write.

## Deployment boundaries

- Static SWAG files become active after a file copy. A browser hard refresh can be required.
- B.Ross API source is built into a container. A source change needs a Compose rebuild.
- Membership source is built from `/mnt/cache_addons/addonfiles/github/bross-supporter-gateway`, not the flash-drive service copy. Rebuild/recreate only through Compose Manager's GUI.
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
