# B.Ross API

Node/Express service backing the [bross.cloud](https://bross.cloud) front-end.

It replaces two PHP endpoints that re-scanned the disk on every page load and
could only report filenames. This service reads ID3/container tags once, caches
the index in memory, and invalidates it when the library changes on disk.

## Architecture

```
              ┌──────────────────────────────────┐
  :443 ──────►│ SWAG (nginx)                     │
              │ TLS · fail2ban · vhosts          │
              └───┬──────────────────┬───────────┘
                  │                  │
     /  /assets/* │                  │ /api/*
                  ▼                  ▼
          static files          bross-api :3100
          (nginx)               (this service)
```

Static files stay on nginx — it handles `sendfile` and range requests for
audio/video far better than Node, and the split means a crash here cannot take
the website down.

## Endpoints

| Method | Path | Returns |
|---|---|---|
| `GET` | `/api/songs` | `["track.mp3", ...]` — drop-in for the old `listSongs.php` |
| `GET` | `/api/backgrounds` | Shuffled clip URLs — drop-in for the old `getVideos.php` |
| `GET` | `/api/tracks` | Full metadata index: title, artist, album, year, duration, `hasArt` |
| `GET` | `/api/tracks/:file/art` | Embedded cover art (`404` when absent) |
| `GET` | `/api/stats` | Platform metrics from Uptime Kuma + Tautulli, cached (see below). A different origin can read it |
| `GET` | `/api/uptime` | The rolling uptime history: the primary value, the totals for each monitor and the value for each day. The option `?days=n` gives fewer days. A different origin can read it |
| `POST` | `/api/visit` | Invisible page-view beacon; writes a private log and total counter when `TRACKING_DIR` is configured |
| `GET` | `/api/health` | Liveness probe with track count and index timestamp |

## Configuration

All environment-overridable; defaults suit the container layout.

| Variable | Default | Purpose |
|---|---|---|
| `PORT` | `3100` | Listen port |
| `ASSET_ROOT` | `/assets` | Mount point of the site's asset tree |
| `SOUND_DIR` | `sound` | Audio directory, relative to `ASSET_ROOT` |
| `VIDEO_DIR` | `bg/fall` | Background clips, relative to `ASSET_ROOT` |
| `CACHE_TTL_MS` | `600000` | Index lifetime; the fs watcher usually invalidates sooner |
| `TRACKING_DIR` | - | Private visitor-log directory. Empty disables tracking writes |

`TRACKING_DIR` must be a dedicated writable mount outside every nginx web root. In
production, mount the SWAG tracking directory into the API container:

```yaml
environment:
  TRACKING_DIR: /tracking
volumes:
  - /mnt/cache_addons/addonfiles/dockers/appdata/swag/tracking:/tracking
```

The service writes `visits.log` and `count.txt`. Do not publish this directory.

### `/api/stats` sources

Every source is optional. One that is unreachable or unconfigured yields `null` for its
metrics and reports itself under `sources`; it never fails the response.

| Variable | Default | Purpose |
|---|---|---|
| `KUMA_URL` | — | Uptime Kuma base URL, reached over the LAN |
| `KUMA_SLUG` | — | Slug of a **published** status page. Its monitors define the reported service count |
| `TAUTULLI_URL` | — | Tautulli base URL |
| `TAUTULLI_API_KEY` | — | Supplied via `env_file` from `.env` — see below |
| `STATS_TTL_MS` | `300000` | Cache lifetime; upstreams are polled at most this often |

`TAUTULLI_API_KEY` is deliberately **not** listed under `environment:` in the compose file.
Compose gives `environment` precedence over `env_file`, so declaring it in both places
would let an empty value silently win and Tautulli would report as unavailable.

### Uptime history

Kuma gives the status now and the uptime for the last 24 hours. It does not give a longer
period. The status page API shows a 24-hour period only. Kuma also removes its old
heartbeats on a schedule. You cannot read a one-year value from Kuma. A different system
must collect that data.

The collector (`src/lib/publish.js`) reads Kuma at each interval of `PUBLISH_INTERVAL_MS`.
It adds the new heartbeats to a day-by-day history. It then writes two files into
`DATA_DIR`:

| File | Purpose |
|---|---|
| `uptime-history.json` | The collected record. It holds one record for each day, to a maximum of `UPTIME_WINDOW_DAYS`. **This is the only copy.** Kuma cannot supply the data again. Include the file in the backup of appdata |
| `stats.json` | The small summary for the portfolio page, which reads it as `assets/data/stats.json`. Nginx sends this file. The page operates when this service is stopped |

| Variable | Default | Purpose |
|---|---|---|
| `DATA_DIR` | — | The directory for the two files. **If it has no value, the collector writes no file.** A test on a laptop thus cannot change the live site |
| `PUBLISH_INTERVAL_MS` | `300000` | The interval between the reads |
| `UPTIME_WINDOW_DAYS` | `365` | The rolling period. The collector removes the older days |
| `STATS_FILE` / `UPTIME_FILE` | `stats.json` / `uptime-history.json` | The file names in `DATA_DIR` |

#### The two uptime values

The summary gives two values, because they answer two questions:

| Field | Meaning |
|---|---|
| `uptimeMean` | The mean of the monitors. Each service has the same weight. **The sites show this value.** |
| `uptime` | All the heartbeats together. This is the correct value for "how many checks were good" |

A monitor with more months of data supplies more heartbeats. It thus controls the value
`uptime`. On 2026-08-16, one monitor gave 71.9% of all the heartbeats: `SoulSeek (slskd)`,
with data from February and a value of 83.6%. The ten other monitors had data from August
and values between 99.6% and 100%. The two results were 88.2% together and 98.4% as a mean.
The mean describes the platform. The other value describes the sample.

A monitor with no heartbeat in the period has no value. It stays out of the mean. It does
not count as 0% or as 100%.

These rules keep the value correct:

- **The collector counts heartbeats. It does not count samples.** Each read gets the last 50
  heartbeats for each monitor. The collector records only the new heartbeats. It thus counts
  an outage between two reads. The Kuma check interval is 60 seconds, and each response holds
  approximately 50 minutes of data. The interval of 5 minutes gives a large margin.
- **The collector records each heartbeat one time.** The reads overlap. The value `lastBeat`
  for each monitor prevents a second record of the same heartbeat.
- **The collector adds no data.** A day with no data is not in the file. Its value is not
  zero. The summary gives `daysCovered` and `complete`. The sites thus show the correct
  period: "since Aug 2026" before one full year, and "last 12 months" after one full year.
- **The collector removes the maintenance periods** from the two totals. A heartbeat with the
  status `PENDING` counts as a failed check. If the collector misses too many intervals, Kuma
  removes the heartbeats between the two reads. The collector then records a gap (`gaps`) for
  that day.

#### Backfill from the Kuma database

The collector records only the heartbeats from the time that it started. Kuma recorded
heartbeats from the time that you made each monitor. Kuma keeps them for
`keepDataPeriodDays` days. The file `kuma.db` thus holds measured data that the history file
does not have. The tool `src/tools/backfill-kuma.js` imports that data.

The tool does not open the live database. It makes a copy of `kuma.db` and the two files
`-wal` and `-shm`. It reads the copy. The tool thus cannot lock the Kuma database or write
to it.

Imported days **replace** the days that are also in the history. The tool does not add the
two values together (refer to `mergeHistories`). An addition counts each heartbeat two times.
The tool keeps the days that Kuma removed, because the history file is the only record of
them.

Stop the collector first. The collector keeps the history in memory and writes the file again
at each interval. It removes the imported data at the next interval. The tool stops if the
system wrote the file in the last 10 minutes.

```bash
docker stop bross-api

docker run --rm --user 99:100 \
  -v /mnt/cache_addons/addonfiles/dockers/appdata/bross-api/src:/app/src:ro \
  -v /mnt/cache_addons/addonfiles/dockers/appdata/uptimekuma:/kuma:ro \
  -v /mnt/cache_addons/addonfiles/dockers/appdata/swag/www/natural/assets/data:/data \
  node:22-alpine \
  node /app/src/tools/backfill-kuma.js --slug alluserfacingservices --dry-run

# If the values are correct, use the same command without --dry-run. Then:
docker start bross-api
```

The option `--dry-run` shows the values before and after the merge. It also shows the value
for each monitor. It writes no file.

Read the values for each monitor. The primary value uses all the heartbeats together. A
monitor with more months of data thus controls that value. The report shows this value and
also the mean of the monitors. A large difference between the two values shows that one
monitor controls the primary value. Examine this before the value goes on the site.

A run without `--dry-run` first makes a backup of the file as
`uptime-history.json.bak-<timestamp>`.

The two routes `/api/stats` and `/api/uptime` send `Access-Control-Allow-Origin: *`. No other
route sends this header. The two routes give the same public values that the sites show to
all visitors. The dataviz page can thus read the data from a local file. A `file://` page
sends `Origin: null`, and a relative path to the same origin has no meaning. The requests use
GET only. They have no credentials and no special headers. The browser thus sends no
preflight request.

`DATA_DIR` is the only mount with write permission. The service operates as `99:100`
(nobody:users), because this user is the owner of appdata. If the log shows `EACCES`, correct
the owner of that directory. The tool writes to a temporary file and then moves it. Only the
permission of the directory is important.

## Running

The stack is managed by Unraid's **Docker Compose Manager** plugin, which keeps compose
files on the flash drive. This directory is therefore the *build context and secret store*,
not the deploy directory — there is no `docker-compose.yml` here:

```
compose file  ->  /boot/config/plugins/compose.manager/projects/bross-api/
build context ->  /mnt/cache_addons/addonfiles/dockers/appdata/bross-api/   (this dir)
secrets       ->  ./.env                                                    (never on flash)
```

The compose file references both paths absolutely, so it works regardless of where compose
is invoked from.

```bash
# Production — GUI:  Docker tab -> Compose -> bross-api -> Up
# Production — terminal equivalent:
docker compose -f /boot/config/plugins/compose.manager/projects/bross-api/docker-compose.yml up -d --build

# Local
npm install
ASSET_ROOT=/path/to/www/bross/assets npm run dev

# The tests (node:test, no dependencies). They examine the uptime history. No
# other system can make that data again.
npm test
```

`.env` stays in appdata rather than beside the compose file because the flash drive is
FAT32 and cannot carry restrictive file permissions.

## Design notes

- **Read-only asset mount.** The service only lists directories and reads tags,
  so it is given no write access to the website. There is one exception:
  `DATA_DIR`. This directory holds the published statistics.
- **The history file is more important than the service.** A restart makes all
  the other data again: the service scans the tracks and reads the statistics
  from the sources. It cannot make one year of uptime again, because Kuma
  removed those heartbeats. For this reason the collector writes to a temporary
  file and then moves it. It starts again with an empty history if the file has
  incorrect data. It also reads Kuma more frequently than necessary.
- **Bounded scan concurrency.** Tag reads are I/O bound, but unbounded
  parallelism against a spinning array is counterproductive; batches of 8.
- **Cache invalidation is belt-and-braces.** `fs.watch` handles the normal case;
  a TTL covers network filesystems that drop watch events.
- **Graceful shutdown.** SIGTERM stops new connections and drains in-flight
  requests before exit, so restarts don't sever live responses.
- **`unhandledRejection` is trapped.** Node's single process is the one real
  operational regression versus PHP-FPM's per-request isolation; an unhandled
  rejection would otherwise kill every endpoint at once.
- **Path traversal is rejected at the route boundary** — `:file` is the only
  untrusted input that reaches the filesystem.

## Licence

MIT
