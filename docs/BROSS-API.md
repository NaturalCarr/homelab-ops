# B.Ross API

Verified: 2026-09-07

## Purpose

The B.Ross API carries the shared data and control work for `bross.cloud`, its admin page, `naturalcarr.com`, and the standalone dataviz page.

It handles:

- Audio and background-video discovery.
- Audio metadata and cover art.
- Playlist and default-media administration.
- Media-file rename.
- Private aggregate visitor tracking.
- Tautulli account, activity, and library statistics.
- Uptime Kuma status and 365-day retained history.
- Published JSON for the Natural Carr portfolio.

## Runtime

| Item | Value |
|---|---|
| Container | `bross-api` |
| Runtime | Node.js 22 Alpine |
| Framework | Express 4.19.2 |
| Metadata parser | `music-metadata` 10 |
| Module format | ES modules |
| Host port | 3100 |
| Container user | `99:100` |
| Restart policy | `unless-stopped` |
| Root filesystem | Read-only, with `/tmp` as tmpfs |
| Security option | `no-new-privileges:true` |
| Log rotation | Three 10 MB JSON files |

Source:

- Windows: `R:\dockers\appdata\bross-api`
- UNC: `\\TOWER\addonfiles\dockers\appdata\bross-api`
- Unraid: `/mnt/cache_addons/addonfiles/dockers/appdata/bross-api`

Compose:

- Windows: `O:\config\plugins\compose.manager\projects\bross-api\docker-compose.yml`
- Unraid: `/boot/config/plugins/compose.manager/projects/bross-api/docker-compose.yml`

## Volumes

| Container path | Host source | Mode and purpose |
|---|---|---|
| `/assets` | SWAG `www/bross/assets` | Read/write; scan media, write playlists/defaults, rename media |
| `/data` | SWAG `www/natural/assets/data` | Read/write; publish `stats.json` and retain `uptime-history.json` |
| `/tracking` | SWAG appdata `tracking` | Read/write; private page counters outside web roots |

## Configuration

Compose sets:

- `PORT`
- `ASSET_ROOT`
- `SOUND_DIR`
- `VIDEO_DIR`
- `CACHE_TTL_MS`
- `TZ`
- `KUMA_URL`
- `KUMA_SLUG`
- `TAUTULLI_URL`
- `STATS_TTL_MS`
- `DATA_DIR`
- `PUBLISH_INTERVAL_MS`
- `UPTIME_WINDOW_DAYS`
- `TRACKING_DIR`

The code also reads:

- `STATS_FILE`
- `UPTIME_FILE`
- `VIDEO_PLAYLIST`
- `TAUTULLI_API_KEY`

`TAUTULLI_API_KEY` comes from the private appdata `.env` file. Do not copy or document its value.

Current mismatch: the code hardcodes `bg/videos` and never reads `VIDEO_DIR`, even though Compose sets `VIDEO_DIR=bg/fall`.

## Public endpoints

### `GET /api/songs`

Returns the playable audio list as a JSON array. It uses the active/default music playlist when configured. The public music player consumes this route.

### `GET /api/backgrounds`

Returns background-video URLs as a JSON array. The public page rotates through the list.

### `GET /api/playlist`

Returns the active background-video playlist data.

### `GET /api/defaults`

Returns the saved default selections for video and music.

### `POST /api/playlist/reload`

Invalidates playlist/library state so the next request reloads it.

### `POST /api/visit?p=<path>`

Records a private aggregate page-view event. The public site uses `sendBeacon` where supported and a keepalive fetch otherwise. The route accepts a path truncated to 200 characters by the browser client.

The route is public and has no rate limit. It writes to disk. Keep the tracking path outside all nginx public roots.

### `GET /api/tracks`

Returns the indexed track objects and their parsed metadata.

### `GET /api/tracks/:file/art`

Returns embedded art for a track when present. The parameter is one path segment. Tracks in nested audio directories cannot use this route.

### `GET /api/stats`

Returns the current published statistics. The response includes source state, monitor window details, current uptime, accumulated pooled uptime, account count, session peak, and library count.

The public CORS helper is enabled for this route so a standalone local dataviz file can read it.

### `GET /api/uptime?days=<n>`

Returns the retained uptime aggregate and per-monitor values for the requested period, bounded by the configured window.

Main fields:

- `generatedAt`
- `observedSince`
- `windowDays`
- `daysCovered`
- `complete`
- `checks`
- `ok`
- `uptime` - pooled heartbeat result
- `uptimeMean` - equal-weight mean of monitor results
- `uptime7d`
- `uptime30d`
- `gapDays`
- `monitors`

The public sites use `uptimeMean`. The pooled value can be dominated by a monitor with more retained beats.

The public CORS helper is enabled for this route.

### `GET /api/health`

Checks the API and media index. On 2026-09-07 it returned:

```json
{"status":"ok","tracks":58,"indexedAt":"2026-09-07T22:32:30.915Z"}
```

## Admin endpoints

These routes are intended only for `admin.bross.cloud`, behind Authentik.

The source defines these routes, but direct and public checks returned 404 on 2026-09-07. The running image is behind the source. A rebuild will activate the routes, so retest every access boundary immediately afterward.

| Method | Route | Purpose |
|---|---|---|
| GET | `/api/admin/videos` | List available background videos |
| GET | `/api/admin/songs` | List available audio files |
| PATCH | `/api/admin/media/:type` | Rename a video or music file |
| GET | `/api/admin/playlists/video/:name` | Read a video playlist |
| PUT | `/api/admin/playlists/video/:name` | Create or replace a video playlist |
| DELETE | `/api/admin/playlists/video/:name` | Delete a video playlist |
| GET | `/api/admin/playlists/music/:name` | Read a music playlist |
| PUT | `/api/admin/playlists/music/:name` | Create or replace a music playlist |
| DELETE | `/api/admin/playlists/music/:name` | Delete a music playlist |
| GET | `/api/admin/defaults` | Read default selections |
| PUT | `/api/admin/defaults` | Replace default selections |

Collection routes for video and music playlists are also used by the admin page:

- `GET /api/admin/playlists/video`
- `GET /api/admin/playlists/music`

Rename validation rejects:

- Directory traversal.
- Invalid characters.
- Extension changes.
- Unsupported media types.
- Existing destination names.

A successful rename updates playlist and default references. Rollback is best effort if a later write fails.

## Media index and cache

- Library cache lifetime: 10 minutes.
- Scan concurrency: 8 files.
- Filesystem watching invalidates the cache after changes.
- Audio tags are parsed once per cached index.
- Admin audio listing supports one level of subdirectories.
- Public metadata indexing is flat. Nested songs do not appear in `/api/tracks`.

## Statistics

The Tautulli client calls user, activity, and library endpoints. Its cache lifetime is five minutes and its upstream timeout is eight seconds.

The service publishes:

- Current Plex account count.
- Peak concurrent sessions.
- Library item count.
- Kuma source state.
- Tautulli source state.
- Current and accumulated uptime figures.

Each Tautulli call catches its own failure. A partial response can still mark the top-level source as available, so check missing values separately from that flag.

## Long-term uptime collector

The publisher runs every five minutes.

At each cycle it:

1. Reads the published Kuma status-page data.
2. Deduplicates new heartbeats by each monitor's `lastBeat`.
3. Counts `UP` as good.
4. Counts `DOWN` and `PENDING` as bad.
5. Excludes `MAINTENANCE`.
6. Writes daily UTC records to `uptime-history.json`.
7. Detects missing collection days.
8. Prunes data older than 365 days.
9. Writes a fresh `stats.json`.

The history file on 2026-09-07 contained:

- 135 day records.
- Data from 2026-02-19 through 2026-09-07.
- 11 monitors.
- 538,168 checks in the latest published stats.
- 503,609 good checks.
- Two gap days in the API snapshot checked earlier that day.

This file is the only retained long-term record. Kuma cannot rebuild heartbeats it has already removed. Back it up with appdata.

## Write behavior

JSON writes use a temporary file and rename for atomic replacement. The temporary name is fixed per target. Concurrent writes to the same target can collide.

Playlist writes do not currently serialize concurrent requests. They also need stronger validation of playlist names and member file references. Authentik reduces exposure but does not replace application-side validation.

## Tests

The source currently has 23 Node tests in three files:

- 18 uptime tests.
- Four visitor-tracker tests.
- One media-rename integration test.

Run from the API source directory:

```sh
npm test
```

## Build and operations

Source changes need a rebuild because the source is copied into the image:

```sh
cd /boot/config/plugins/compose.manager/projects/bross-api
docker compose up -d --build
```

Verify:

```sh
docker compose ps
docker compose logs --tail=100 bross-api
curl -sS http://127.0.0.1:3100/api/health
```

## Known issues

- The main public host currently proxies all `/api/` routes. The admin subroutes must be blocked there and kept on the Authentik-protected admin host.
- Direct LAN access to port 3100 bypasses Authentik.
- `POST /api/visit` has no rate limit.
- Admin playlist names and file members need stricter validation.
- Concurrent JSON writes can collide on the fixed temporary path.
- The publisher queries Kuma more than once per cycle.
- The root has zero-byte files created from an earlier malformed Docker command. They are harmless but should be removed after confirming they are not needed.
- There is no lockfile in the API root. Container dependency builds can change over time.
- The API README is stale on routes, mount permissions, tests, and the video-directory setting. Use this document and the current source instead.
