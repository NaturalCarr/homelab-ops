# homelab-ops

Operations scripts from a self-hosted Linux platform I have run since 2016 —
an Unraid host serving containerized media, cloud, and virtualization services
behind an nginx reverse proxy.

These are the scripts that keep it running: minimal-downtime database backups,
dependency-ordered container restarts, service health checks, and media
transcoding pipelines. Everything here has run in production against real users.

This is a curated selection, not a dump. Each script has been generalized so
paths and container names are configurable rather than hardcoded to my
environment.

## Contents

| Script | What it does |
|---|---|
| [`ramdisk/ramdisk-load.sh`](ramdisk/ramdisk-load.sh) | Restores databases from disk into a tmpfs RAM disk and bind-mounts them over the container's data directory at array start |
| [`ramdisk/ramdisk-backup.sh`](ramdisk/ramdisk-backup.sh) | Nightly backup that pauses each container only for a RAM-to-RAM copy, then flushes to disk while the service is running again |
| [`ramdisk/ramdisk-unload.sh`](ramdisk/ramdisk-unload.sh) | Flushes the RAM disk back to persistent storage at array stop |
| [`docker/restart-container-stack.sh`](docker/restart-container-stack.sh) | Restarts a VPN-gated container stack in dependency order, polling the gateway's healthcheck before bringing dependents back up |
| [`monitoring/service-healthcheck.sh`](monitoring/service-healthcheck.sh) | HTTP health probe with timeout detection, automatic container restart, and a circuit-breaker file to suppress action |
| [`monitoring/syslog-filter.sh`](monitoring/syslog-filter.sh) | Strips a known-noisy hardware error from syslog and suppresses it going forward |
| [`monitoring/unbanme.sh`](monitoring/unbanme.sh) | Clears my own dynamic public IP from every fail2ban jail, resolving the address from the DDNS client's state file rather than DNS |
| [`monitoring/publish-stats.sh`](monitoring/publish-stats.sh) | Snapshots platform metrics to a static JSON file for a public site to read, keeping a growing-window uptime tally rather than claiming unmeasured history |
| [`media/transcode.py`](media/transcode.py) | HDR10 / HLG / SDR tone-mapping transcode pipeline using ffmpeg with Vulkan hardware acceleration and tuned x265 parameters |
| [`media/audio-convert.sh`](media/audio-convert.sh) | Batch audio transcode to MP3, single-file or whole-directory |
| [`lib/spinner.sh`](lib/spinner.sh) | Progress spinner for long-running foreground jobs |

## The RAM disk pattern

The three `ramdisk/` scripts are the most interesting thing here, so they're
worth explaining.

Plex's SQLite databases are the hot spot on a media server — every library scan,
every playback state update, every metadata refresh hits them. On array storage
that is slow, and the I/O competes with streaming.

So the databases live in a tmpfs RAM disk, bind-mounted over the container's
expected path:

```
array start  ──► copy last night's backup from disk into /tmp/RAMDISK
                 bind-mount RAM dir over the container's database dir
                 container starts, runs entirely out of RAM

nightly      ──► pause container
                 copy DB → RAM cache      (fast: RAM to RAM)
                 unpause container         ← pause window ends here
                 copy RAM cache → disk     (slow, but service is live)

array stop   ──► stop container, unmount, flush RAM back to disk
```

The backup script exists to make the pause window as short as possible. A naive
backup pauses the container for the whole RAM-to-disk copy. This one pauses only
for the RAM-to-RAM copy — typically well under a second — then releases the
container and does the slow write while it's serving again. Every stage is timed
and logged so the pause duration is measurable rather than assumed.

Losing power means losing at most one day of metadata, which is an acceptable
trade for the I/O reduction. The databases are reconstructable; that's the bet.

## Locking yourself out

`unbanme.sh` exists because of a recurring problem: fail2ban does its job, and
sometimes the address it bans is mine.

The public IP is dynamic. The obvious fix — whitelist it — goes stale the moment
the lease changes, and the obvious way to find the current address (a DNS lookup
of my own domain) returns the CDN proxy rather than the origin.

The DDNS client already solves this. It tracks the real public address in its
own state file in order to push updates, so that file is the authoritative
local answer, available without a network round trip:

```
ddns-updater/updates.json  ──►  newest recorded IP  ──►  fail2ban-client unban
        (authoritative)              (validated)            (all jails)
```

An external IP echo service is the fallback, and an explicit argument overrides
both. The address is validated as well-formed IPv4 before it reaches a command,
and the script verifies the unban actually took effect rather than assuming it.

The script it replaced deleted fail2ban's entire state directory and restarted
the reverse proxy — which worked, at the cost of dropping every other ban on the
server and losing the ban database.

## Conventions

Scripts here follow a few rules that the originals did not:

- **`set -euo pipefail`** — fail fast rather than continuing past an error.
  Several originals would happily proceed after a failed copy.
- **Configuration at the top, environment-overridable.** No `/mnt/user/...`
  buried in the middle of a function.
- **A circuit-breaker file.** Any script that takes automated action checks for
  a marker file first (`SAFETYBOX/<name>`), so automation can be disabled
  without editing crontabs — useful mid-incident.
- **Timed, logged stages.** If a script has a maintenance window, its length is
  recorded.

## Requirements

Bash 4+, Docker, and `ffmpeg` for the media scripts. The RAM disk scripts assume
Unraid's array start/stop hooks but the pattern is portable to any host with
tmpfs and systemd.

## Licence

MIT
