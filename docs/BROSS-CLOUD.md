# B.Ross Cloud

Verified: 2026-09-18 (gateway inspection, source and installed admin files). Other service checks retain their stated dates.

## Current membership and admin state

The gateway is healthy. Owner login-link review and signed-in recovery are enabled. Member lookup remains `legacy_email`; enforcement remains `dry_run`. No gateway host ports are published. SWAG reaches `bross-membership:3110` on the dedicated edge network; PostgreSQL stays on the internal database network.

Use `https://supporter.bross.cloud/` for membership status and `GET/POST /identity-recovery` for account-link help (no portal subdirectory). Use only `https://admin.bross.cloud/` for administration: B.Ross Media and Supporter Management are tabs. Login links and recovery requests stay inside Supporter Management. Internal renderer/API routes remain necessary, but aren't separate operator entry pages. Supporter's admin paths remain denied.

Production migrations 008 (verified login links) and 009 (recovery requests) were applied and registered at operator-confirmed checkpoints. One externally verified pilot login link was confirmed. These are dated checkpoints, not a fresh database count.

The operator reports the browser checks complete. Retain that as operator evidence, not an independent live CSRF/replay/approval test. Prior signed-out forged-header checks returned 302 on protected entry routes, 403 on Supporter admin and 200 on public support. No new real link, payment or Plex operation was performed for this documentation update.

Latest recovery wording/raw-field hardening has 96 focused passing source checks (no skips). A newer running image is now observed, but its exact bundled source hasn't been compared: don't assume those source changes are either still absent or verified deployed. Payment intake still associates unknown provider accounts by normalized email; review that ownership risk before verified-link activation. Native OIDC and app-specific login appearance remain planned. See [the identity rollout](BROSS-IDENTITY-ROLLOUT.md) for evidence and remaining gates.

## Purpose

`bross.cloud` is the front door for my media and cloud services. One interface separates Media from Cloud/Hosting without splitting them into different sites.

SWAG serves the static front end. The B.Ross API supplies media, playlists, metadata, statistics, uptime, and private aggregate page counts.

## Source and deployment

| Layer | Windows path | Unraid or container path |
|---|---|---|
| Live files | `R:\dockers\appdata\swag\www\bross` | Host: `/mnt/cache_addons/addonfiles/dockers/appdata/swag/www/bross` |
| SWAG view | Same files through bind mount | `/config/www/bross` |
| Live nginx config | `R:\dockers\appdata\swag\nginx\site-confs\default.conf` | `/config/nginx/site-confs/default.conf` |

Main files:

- `index.html` - public portal.
- `admin.html` - protected administration page.
- `assets/css/main.css` - page, modal, selector, and responsive layout.
- `assets/css/musicplayer.css` - music player.
- `assets/js/site.js` - visitor beacon, backgrounds, VPS configurator, logo effects, modal system, dropdowns, and service-view transitions.
- `assets/js/music.js` - audio list, playback, progress, visualizer, track list, and downloads.
- `assets/bg/playlists.json` - named background-video playlists.
- `assets/bg/defaults.json` - selected default playlists and media.
- `assets/sound/music-playlists.json` - named music playlists.
- `tautulli/rec*.html` and `tautulli/recentlyadded.html` - generated newsletter pages. Do not hand-edit generated issues.

The legacy `listSongs.php` and `getVideos.php` files still exist. The current browser code uses the Node API instead.

## Public portal

### Header and selector

The header contains:

- An animated B.Ross logo and radial audio visualizer.
- The B.Ross V3 title and “Bob Ross Media & Virtualization Server” subtitle.
- A Media/Cloud selector.
- A service-specific navigation menu.
- A first-interaction message for browser audio playback.
- A custom music player.

The selected service group is stored in browser local storage as `bross-service-view`.

The selector uses orange for Media and blue for Cloud. Its glow is attached to a moving orb behind the labels. During a selection change, the glow condenses, travels to the new side, changes color, and expands. The two menus crossfade over one second. The glow travels in 520 milliseconds. Reduced-motion preferences remove the animated transition.

### Media menu

- Watch - dropdown for Plex, Plex2, and Jellyfin. Pressing the main Watch link opens the full `#watch` modal.
- Request - opens `request.bross.cloud`.
- Stats - opens `stats.bross.cloud`.
- Support - dropdown for the membership page and the `#donate` modal.

### Cloud menu

- Storage - opens `nextcloud.bross.cloud`.
- Hosting - dropdown for the `#virtualization` quote modal and `meshcentral.bross.cloud`.
- Support - dropdown for the membership page and the `#donate` modal.

### Background video

OnLoad, the page calls `GET /api/backgrounds`, builds the rotation, and advances when each video ends. `assets/images/bg.jpg` is the fallback.

### Music player

OnLoad, the page calls `GET /api/songs`, which returns filenames and per-track metadata (title, artist, cover-art availability). Playback waits for the first Click/Keypress because browsers block unattended audio.

The player shows the track title and artist from embedded ID3/container tags. When tags are missing, it falls back to the filename without extension. The track list uses the same metadata. Embedded cover art loads from `/api/tracks/:file/art` and displays in the album-art area of the player card. Clicking the art opens an enlarged lightbox view (click or Escape to close).

The player supports:

- Play and pause.
- Previous and next.
- Progress display and scrubbing.
- Current and remaining time.
- Track-list expansion with title and artist per row.
- Current-track download.
- Minimize and restore.
- Album art from embedded tags, with click-to-enlarge lightbox.
- A canvas/Web Audio visualizer whose color follows the Media or Cloud selection.

Drag/Release carries momentum from the last 100 ms of movement. The player
bounces off all four viewport edges and slows to a stop. Grab it again to stop
the glide. Holding still before release doesn't throw it.

Bounds update during motion, on viewport resize/zoom, and when the player changes
size (including minimize/restore and playlist expansion). If the player is larger
than the viewport, that axis stays at the viewport's starting edge. Phone drags
still use the top bar; controls and playlist scrolling keep their normal behavior.
Reduced-motion disables the release glide.

Verified on 2026-09-09: JavaScript syntax and simulated drag/bounce/resize checks
passed. Deployed JavaScript and HTML hashes match both staging and public HTTPS
responses. Interactive browser verification remains pending.

The page includes local vendor scripts for jQuery, Hammer, QR code generation, ProgressBar, and older layout helpers. WaveSurfer and Three.js load from public CDNs. The CDN URLs are not version-pinned with subresource-integrity hashes.

### Donations

The `#donate` modal builds QR codes for Cash App, PayPal, Venmo, and Zelle. The payment destinations are part of the public page source.

### VPS configurator

The `#virtualization` modal offers:

| Resource | Range or options |
|---|---|
| CPU | 2 to 16 cores, step 2 |
| RAM | 4 to 32 GB, step 4 |
| GPU | None, EVGA 1660 Ti, EVGA 1080 Ti |
| SSD | 16 to 240 GB, step 16 |
| HDD | 0 to 20 TB, step 1 |

The displayed estimate uses:

- $4 per CPU core.
- $3 per GB RAM.
- $0.10 per GB SSD.
- $5 per TB HDD.
- $25 for the 1660 Ti.
- $45 for the 1080 Ti.

Send Request doesn't submit the selected values. It displays the current-quarter capacity notice instead.

## Admin page

Tabbed administration deployed 2026-09-17: B.Ross Media retains existing controls; Supporter Management embeds the private gateway; internal renderer/API routes aren't standalone entry pages. Both inherit the unchanged owner-only Authentik rule; no Manage hostname is added. Live admin page/default proxy hashes match `/mnt/cache_addons/addonfiles/dockers/appdata/bross-membership/identity-rollout/admin-tabs-20260917`. GUI rebuild, framing header checks, real nginx validation/reload and signed-out route checks passed. Tab/syntax/history simulations passed. The operator reports owner/non-owner and sign-out/history browser checks complete. Supporter admin paths remain HTTP 403. Exact two-file backup: `/mnt/cache_addons/addonfiles/dockers/appdata/swag/nginx/identity-header-backups/admin-tabs-qnghD8G0`.

`https://admin.bross.cloud/` is protected by the Authentik forward-auth includes in SWAG.

Admin cache fix staged on 2026-09-10 (nginx validation, reload, and live sign-out
checks operator-reported complete): admin responses use private/no-store headers with ETag
and If-Modified-Since reuse disabled. The page hides before leaving and reloads
when restored from browser history, so a restored page goes through Authentik
again. The dedicated admin sign-in redirect also uses no-store and preserves
the Authentik response cookie.

The admin page manages:

- Available and selected background videos.
- Available and selected audio tracks.
- Video and music playlists.
- Default video playlist, video, music playlist, and song.
- Video preview with play, pause, mute, time, and scrubbing.
- Audio preview with play, pause, time, scrubbing, and a live frequency visualizer.
- Media-file rename.

Video and Music keep separate `Playlists` and `File Browser` views. The playlist editor shows only files that aren't already in the open playlist. Remove one and it returns to the available list.

The file-browser view is file-centric:

- It lists every available media file and shows how many playlists contain it.
- Selecting a file loads and automatically plays it in the existing preview.
- The detail pane assigns or removes the file from playlists with checkboxes.
- Each checkbox change saves immediately through the existing playlist `PUT` route and refreshes both views.
- Preview and Rename remain available, and a rename follows the selected file while refreshing playlist and file-browser state.

The audio preview bars are real. A Web Audio `AnalyserNode` feeds live frequency data into the 12 existing bars. Pause/End resets them, and reduced-motion disables the height transition.

The main maintenance anchors in `admin.html` are `renderEditorFiles()`, `switchView()`, the `renderFb*()` and `toggleFbPlaylist()` functions, `applyRenamedFile()`, and `initVisualizer()`/`startViz()`/`stopViz()`.

The page uses `/api/admin` as its API base. Rename changes the file and updates playlist and default references. The API checks traversal, file type, invalid characters, and collisions.

The admin host also exposes Authentik-protected reverse proxies for:

- `/youtube-dl` -> port 8282.
- `/youtube-dl-auto` -> port 4848.

## Recently added page

`https://new.bross.cloud/` is protected by Authentik and serves `tautulli/recentlyadded.html` from the B.Ross root. Tautulli-generated newsletter files are content output, not application source.

## Front-end API dependencies

| Browser function | API route |
|---|---|
| Background rotation | `GET /api/backgrounds` |
| Audio list and metadata | `GET /api/songs` |
| Cover art | `GET /api/tracks/:file/art` |
| Page-view beacon | `POST /api/visit?p=<path>` |
| Admin bootstrap | `GET /api/admin/playlists/video`, `/music`, `/videos`, `/songs`, and `/defaults` |
| Playlist and file-browser assignment save | `PUT /api/admin/playlists/:type/:name` |
| Playlist delete | `DELETE /api/admin/playlists/:type/:name` |
| Defaults save | `PUT /api/admin/defaults` |
| Rename | `PATCH /api/admin/media/:type` |

## Accessibility and responsive behavior

- Menus and selectors use buttons, ARIA pressed state, and grouped labels.
- The music player has explicit control labels.
- Video and audio preview stages are keyboard focusable.
- The site has mobile breakpoints and touch handling.
- `prefers-reduced-motion` is respected in the main transition logic.

## Known maintenance points

- Keep `index.html` asset version query strings in step with CSS and JavaScript deployments.
- The current HTML still contains inactive legacy articles and commented code.
- `index.html` line 193 has malformed Plex anchor markup. Browsers may recover, but it should be corrected in a separate approved content change.
- The active API video directory is hardcoded as `bg/videos`. The Compose variable says `bg/fall`, but the application does not read `VIDEO_DIR`.
- The public host must not proxy `/api/admin/*`. See the security document.
- Static file changes are live after copy. Back up the named file first and use a hard refresh to test.
