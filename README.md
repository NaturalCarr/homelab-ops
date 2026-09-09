# homelab-ops

The scripts and operating notes behind my Unraid homelab.

I've run some version of this server since 2016. It handles media, cloud storage,
virtual machines, Docker services, monitoring, and the nginx edge in front of
it all. These aren't tutorial samples. They're cleaned-up versions of jobs that
run on the server.

This repo is curated. It isn't a copy of `/boot/scripts`, and it doesn't contain
credentials or private runtime data. Server-specific paths and container names
are variables where that makes sense.

## Scripts

| Directory | Script | Purpose |
|---|---|---|
| `ramdisk/` | [`ramdisk-load.sh`](ramdisk/ramdisk-load.sh) | Restores database backups into tmpfs and bind-mounts them over the normal container paths at array start. |
| | [`ramdisk-backup.sh`](ramdisk/ramdisk-backup.sh) | Pauses a container for the RAM-to-RAM copy, unpauses it, then writes the backup to disk. |
| | [`ramdisk-unload.sh`](ramdisk/ramdisk-unload.sh) | Unmounts the RAM-backed databases and flushes them to disk at array stop. |
| `docker/` | [`restart-container-stack.sh`](docker/restart-container-stack.sh) | Restarts a VPN gateway and its dependent containers in the correct order. |
| `monitoring/` | [`service-healthcheck.sh`](monitoring/service-healthcheck.sh) | Checks an HTTP endpoint and restarts its container after a timeout. Includes a circuit breaker. |
| | [`publish-stats.sh`](monitoring/publish-stats.sh) | Publishes an atomic JSON stats snapshot for a public site. |
| | [`syslog-filter.sh`](monitoring/syslog-filter.sh) | Removes a known noisy hardware error from syslog. |
| | [`unbanme.sh`](monitoring/unbanme.sh) | Finds my current public IP and removes it from every fail2ban jail without clearing other bans. |
| `plex/` | [`pmsDB.sh`](plex/pmsDB.sh) | Checks the Plex SQLite database, makes dated backups, and can dump/rebuild a damaged database. |
| `media/` | [`transcode.py`](media/transcode.py) | Runs HDR10, HLG, or SDR video transcodes with ffmpeg, Vulkan, libplacebo, and x265. |
| | [`audio-convert.sh`](media/audio-convert.sh) | Converts a file or directory of audio files to MP3. |
| `lib/` | [`spinner.sh`](lib/spinner.sh) | Small progress spinner for foreground shell jobs. |

## RAM disk database backups

Plex database activity used to compete with streaming and other array I/O. I
moved the active SQLite databases into tmpfs and bind-mounted them over the
paths Plex expects.

```text
[ARRAY START]  disk backup --> RAM disk --> bind mount --> start container

[NIGHTLY]      pause container
               live DB --> RAM backup cache
               unpause container
               RAM backup cache --> disk

[ARRAY STOP]   stop container --> unmount --> RAM disk --> disk backup
```

The nightly job pauses the container only for the RAM-to-RAM copy. Plex comes
back up before the slower write to disk starts. Every stage is timed and logged.

Tmpfs isn't persistent. A power failure can lose database changes made since
the last disk backup. Make sure you understand and accept that risk before
using this setup.

## Before you run anything

Review the variables near the top of each script. Defaults may reference Unraid
paths such as:

```text
/boot/scripts
/mnt/cache_addons
/tmp/RAMDISK
/var/log
```

Most values can also come from environment variables. Check every container
name, path, permission, health check, and backup location against your server.

Requirements vary by script. Common dependencies are Bash 4+, Docker, `curl`,
`jq`, `sqlite3`, and standard GNU/Linux tools. The media scripts need a suitable
ffmpeg build. RAM disk and syslog work needs root-level permissions.

## WARNING

Some scripts stop containers, change mounts, edit syslog, or touch live
SQLite databases. Read the script first. Test with copied data. Keep a current,
verified backup before pointing anything at production.

## Documentation

The current platform map, routes, deployment steps, and security notes live in
[`docs/`](docs/README.md). Historical handoffs are kept under
[`docs/reference/`](docs/reference/README.md) and aren't current source of truth.

## License

[MIT](LICENSE)
