# homelab-ops

Scripts that keep my Unraid server running. It's been up since 2016 serving media,
cloud storage, and VMs behind an nginx reverse proxy, and these are the things I
wrote so I'd stop having to babysit it.

This is a selection, not my whole scripts folder. I pulled the ones that would make
sense to somebody else and moved my hardcoded paths into variables at the top of each
file. They work fine for me, but I'm not making any guarantees (read them before you
run them, especially anything that deletes).

## Contents

| Script | What it does |
|---|---|
| [`ramdisk/ramdisk-load.sh`](ramdisk/ramdisk-load.sh) | Pulls the databases off disk into a tmpfs RAM disk at array start and bind-mounts them over the container's data directory |
| [`ramdisk/ramdisk-backup.sh`](ramdisk/ramdisk-backup.sh) | Nightly backup that pauses each container only for a RAM-to-RAM copy, then writes to disk with the service already running again |
| [`ramdisk/ramdisk-unload.sh`](ramdisk/ramdisk-unload.sh) | Flushes the RAM disk back to disk at array stop |
| [`docker/restart-container-stack.sh`](docker/restart-container-stack.sh) | Restarts a VPN-gated stack in dependency order, waiting on the gateway's healthcheck before the dependents come back |
| [`monitoring/service-healthcheck.sh`](monitoring/service-healthcheck.sh) | HTTP probe with timeout detection and an automatic container restart, plus a circuit-breaker file to shut it off |
| [`monitoring/syslog-filter.sh`](monitoring/syslog-filter.sh) | Strips a hardware error I already know about out of syslog and keeps it out |
| [`monitoring/unbanme.sh`](monitoring/unbanme.sh) | Clears my own public IP out of every fail2ban jail, getting the address from the DDNS client's state file instead of DNS |
| [`monitoring/publish-stats.sh`](monitoring/publish-stats.sh) | Snapshots platform metrics to a JSON file for a public site to read, keeping a growing uptime tally rather than claiming history it never measured |
| [`media/transcode.py`](media/transcode.py) | HDR10 / HLG / SDR tone-mapping transcode pipeline, ffmpeg with Vulkan offload and tuned x265 settings |
| [`media/audio-convert.sh`](media/audio-convert.sh) | Batch audio transcode to MP3, one file or a whole directory |
| [`lib/spinner.sh`](lib/spinner.sh) | Progress spinner for long foreground jobs |

## The RAM disk pattern

The three `ramdisk/` scripts are the interesting part, so here's what they're doing.

Plex's SQLite databases are the hot spot on a media server. Every library scan, every
playback state update, every metadata refresh hits them. On array storage that's slow,
and the I/O fights with whatever happens to be streaming.

So the databases live in a tmpfs RAM disk, bind-mounted over the path the container
expects:

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

The backup script exists to keep that pause window short. The obvious way to write it
pauses the container for the whole RAM-to-disk copy. This one pauses only for the
RAM-to-RAM copy, which is usually well under a second, then unpauses and does the slow
write while Plex is serving again. Every stage is timed and goes into the log, so I know
what the pause actually was instead of assuming.

Lose power and I lose a day of metadata at most. That's a fine trade for the I/O it
gives back, and the databases can be rebuilt if it ever comes to that.

## Locking yourself out

`unbanme.sh` exists because fail2ban does its job, and sometimes the address it bans is
mine.

My public IP is dynamic. Whitelisting it goes stale the next time the lease changes, and
looking up my own domain hands back the CDN proxy instead of the actual origin.

The DDNS client already has the answer. It tracks the real public address in its own
state file so it can push updates, which makes that file the authoritative local source
and means no network round trip:

```
ddns-updater/updates.json  ──►  newest recorded IP  ──►  fail2ban-client unban
        (authoritative)              (validated)            (all jails)
```

An IP echo service is the fallback, and passing an address as an argument overrides both.
The address gets validated as IPv4 before it goes anywhere near a command, and the script
checks that the unban actually took instead of assuming it did.

The script this replaced deleted fail2ban's entire state directory and restarted the
reverse proxy. That worked, but it dropped every other ban on the server and lost the ban
database along with them.

## Conventions

These follow a few rules the originals didn't:

- **`set -euo pipefail`** — fail immediately instead of carrying on. Several of the
  originals would happily keep going after a failed copy.
- **Configuration at the top, overridable from the environment.** No `/mnt/user/...`
  buried halfway down a function.
- **A circuit-breaker file.** Anything that takes action on its own checks for a marker
  file first (`SAFETYBOX/<name>`), so I can turn automation off without editing a
  crontab. Useful when something is already on fire.
- **Timed, logged stages.** If a script has a maintenance window, how long it lasted
  ends up in the log.

## Requirements

Bash 4+, Docker, and `ffmpeg` for the media scripts. The RAM disk scripts assume Unraid's
array start/stop hooks, but the pattern works anywhere you've got tmpfs and systemd.

## Licence

MIT
