#!/usr/bin/env bash
#
# ramdisk-load.sh   —   run at array start, before containers come up
#
# Restores each service's databases from last night's backup into a tmpfs RAM
# disk, then bind-mounts the RAM directory over the path the container expects.
# The container is unaware: it opens its database at the usual location and
# gets RAM-backed storage.
#
# Ordering matters — this must complete before the Docker service starts, or
# containers will open the on-disk copy and the bind mount will be shadowed.
#
# Pairs with ramdisk-backup.sh (nightly flush) and ramdisk-unload.sh (array stop).
#
# Usage:
#   ./ramdisk-load.sh
#   RAMDISK=/tmp/RAMDISK SERVICES="plex ombi" ./ramdisk-load.sh

set -euo pipefail

# ---- Configuration ---------------------------------------------------------
RAMDISK="${RAMDISK:-/tmp/RAMDISK}"
APPDATA="${APPDATA:-/mnt/cache_addons/addonfiles/dockers/appdata}"
LOG="${LOG:-/var/log/ramdisk-load.log}"
SERVICES="${SERVICES:-plex}"

# Where inside each service's appdata the live database directory sits. Plex
# buries it; most others don't. Override per deployment.
PLEX_DB_SUBPATH="${PLEX_DB_SUBPATH:-Library/Application Support/Plex Media Server/Plug-in Support/Databases}"

SEP="=============================="

log() { printf '%b\n' "$*" | tee -a "$LOG"; }
now() { date '+%Y-%m-%d %H:%M:%S'; }

script_start=$(date +%s)
log "$SEP\nRAM disk load starting @ $(now)"

# Resolve the on-disk database directory for a service.
db_path_for() {
    case "$1" in
        plex) printf '%s/%s/%s' "$APPDATA" "plex" "$PLEX_DB_SUBPATH" ;;
        *)    printf '%s/%s/databases' "$APPDATA" "$1" ;;
    esac
}

load_service() {
    local svc="$1"
    local ram_db="$RAMDISK/$svc/databases"
    local disk_db backups
    disk_db="$(db_path_for "$svc")"
    backups="$APPDATA/$svc/backups"

    if [ ! -d "$backups/backup_daily" ]; then
        log "  SKIP $svc — no backup at $backups/backup_daily"
        return 0
    fi

    log "\n$svc — loading databases into RAM @ $(now)"
    local start copy_start copy_end
    start=$(date +%s)

    mkdir -p "$ram_db" "$backups/backup_on_boot"

    copy_start=$(date +%s)
    cp "$backups"/backup_daily/*.db "$ram_db"/
    copy_end=$(date +%s)

    # Keep a separate copy of what we booted with. If the RAM disk is later
    # corrupted, backup_daily may already have been overwritten by the nightly
    # job — this is the known-good state the service actually started from.
    cp "$backups"/backup_daily/*.* "$backups"/backup_on_boot/ 2>/dev/null || true

    # Bind-mount RAM over the path the container opens.
    mkdir -p "$disk_db"
    mount -B "$ram_db" "$disk_db"
    chmod -R 777 "$RAMDISK/$svc"

    log "  $svc loaded @ $(now)"
    log "    disk -> RAM copy: $((copy_end - copy_start))s"
    log "    total:            $(( $(date +%s) - start ))s"
    log "    mounted:          $ram_db -> $disk_db"
}

failed=0
for svc in $SERVICES; do
    load_service "$svc" || { log "  ERROR: $svc load failed"; failed=1; }
done

log "$SEP\nRAM disk load finished @ $(now) — total $(( $(date +%s) - script_start ))s"
exit "$failed"
