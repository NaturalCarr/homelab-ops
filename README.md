# homelab-ops

Scripts I use to run and maintain my Unraid homelab.

This server has been running in some form since 2016. It handles media, cloud
storage, virtual machines, Docker services, and an nginx reverse proxy. These
aren't example scripts written for a tutorial. They're cleaned-up versions of
jobs that run on the server.

This is a curated repo, not a copy of `/boot/scripts`. Server-specific paths,
container names, and other values have been moved to variables where practical.

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

The nightly job only pauses the container during the RAM-to-RAM copy. The slow
write to disk happens after the container is running again. Each stage is timed
and logged.

The tradeoff is simple: tmpfs isn't persistent. A power failure can lose any
database changes made since the last disk backup. This works fine for me, but
make sure that tradeoff works for you before using it.

## Configuration

Review the variables near the top of each script before running anything.
Defaults may reference Unraid paths such as:

```text
/boot/scripts
/mnt/cache_addons
/tmp/RAMDISK
/var/log
```

Most values can also be overridden through environment variables. Check the
container names, paths, permissions, health checks, and backup locations for
your server.

## Requirements

Requirements depend on the script. Common ones are Bash 4+, Docker, `curl`,
`jq`, `sqlite3`, and GNU/Linux command-line tools. Media scripts require an
appropriate ffmpeg build. RAM disk and syslog operations need root-level
permissions.

## WARNING

Some of these scripts stop containers, change mounts, edit syslog, or work with
live databases. Read them first and test against copies of your data.

This works fine for me, but I'm not making any guarantees. I'm not responsible
for damaged or lost data (especially if you modify the scripts).

## License

[MIT](LICENSE)
