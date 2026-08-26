#!/usr/bin/env bash
#
# ramdisk-unload.sh   —   run at array stop, after containers are down
#
# tmpfs does not survive a reboot. This is the last chance to get the day's
# database state onto persistent storage, so it runs on the shutdown hook.
#
# Order is the reverse of ramdisk-load.sh:
#   1. stop the container (it must not be holding the database open)
#   2. unmount the bind mount, exposing the real on-disk directory again
#   3. copy the RAM contents down to persistent storage
#
# Step 2 before step 3 is the part that's easy to get wrong: copying while the
# bind mount is still active writes RAM onto RAM and silently accomplishes
# nothing, and the loss only shows up after the next reboot.
#
# Usage:
#   ./ramdisk-unload.sh
#   RAMDISK=/tmp/RAMDISK SERVICES="plex ombi" ./ramdisk-unload.sh

set -euo pipefail

# ---- Configuration ---------------------------------------------------------
RAMDISK="${RAMDISK:-/tmp/RAMDISK}"
APPDATA="${APPDATA:-/mnt/cache_addons/addonfiles/dockers/appdata}"
LOG="${LOG:-/var/log/ramdisk-unload.log}"
SERVICES="${SERVICES:-plex}"
STOP_TIMEOUT="${STOP_TIMEOUT:-30}"

PLEX_DB_SUBPATH="${PLEX_DB_SUBPATH:-Library/Application Support/Plex Media Server/Plug-in Support/Databases}"

SEP="=============================="

log() { printf '%b\n' "$*" | tee -a "$LOG"; }
now() { date '+%Y-%m-%d %H:%M:%S'; }

script_start=$(date +%s)
log "$SEP\nRAM disk unload starting @ $(now)"

db_path_for() {
    case "$1" in
        plex) printf '%s/%s/%s' "$APPDATA" "plex" "$PLEX_DB_SUBPATH" ;;
        *)    printf '%s/%s/databases' "$APPDATA" "$1" ;;
    esac
}

unload_service() {
    local svc="$1"
    local ram_db="$RAMDISK/$svc/databases"
    local disk_db dest
    disk_db="$(db_path_for "$svc")"
    dest="$APPDATA/$svc/backups/backup_daily"

    if [ ! -d "$ram_db" ]; then
        log "  SKIP $svc — no RAM disk at $ram_db"
        return 0
    fi

    log "\n$svc — shutdown copy @ $(now)"
    local start
    start=$(date +%s)

    # 1. Stop the container so nothing holds the database open. Graceful stop
    #    first; SQLite needs the chance to checkpoint and release its lock.
    if [ -n "$(docker ps -q -f "name=^${svc}$" -f status=running)" ]; then
        log "  stopping $svc (timeout ${STOP_TIMEOUT}s)"
        docker stop -t "$STOP_TIMEOUT" "$svc" >/dev/null
    else
        log "  $svc already stopped"
    fi

    # 2. Unmount BEFORE copying, or the copy writes RAM onto RAM.
    if mountpoint -q "$disk_db"; then
        umount "$disk_db"
        log "  unmounted $disk_db"
    else
        log "  WARN: $disk_db was not a mountpoint — copying anyway"
    fi

    # 3. Flush RAM to persistent storage.
    mkdir -p "$dest"
    cp "$ram_db"/*.db "$dest"/
    log "  $svc flushed to $dest — $(( $(date +%s) - start ))s"
}

failed=0
for svc in $SERVICES; do
    unload_service "$svc" || { log "  ERROR: $svc unload failed"; failed=1; }
done

log "$SEP\nRAM disk unload finished @ $(now) — total $(( $(date +%s) - script_start ))s"
exit "$failed"
