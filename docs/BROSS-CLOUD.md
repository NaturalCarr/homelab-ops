# B.Ross Cloud

Verified: 2026-09-09

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

OnLoad, the page calls `GET /api/songs`. Playback waits for the first Click/Keypress because browsers block unattended audio.

The player supports:

- Play and pause.
- Previous and next.
- Progress display and scrubbing.
- Current and remaining time.
- Track-list expansion.
- Current-track download.
- Minimize and restore.
- Album art and track metadata.
- A canvas/Web Audio visualizer whose color follows the Media or Cloud selection.

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

`https://admin.bross.cloud/` is protected by the Authentik forward-auth includes in SWAG.

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
| Audio list | `GET /api/songs` |
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
