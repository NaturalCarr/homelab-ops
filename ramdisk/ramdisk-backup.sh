#!/usr/bin/env bash
#
# ramdisk-backup.sh
#
# Nightly backup of container databases that live in a tmpfs RAM disk.
#
# The naive version of this pauses the container for the whole copy to disk.
# That is a long window — array writes are slow and the databases are large.
#
# This does it in two stages instead:
#
#   pause  ──►  copy DB → RAM cache   (RAM to RAM: fast)  ──►  unpause
#                                                               │
#               copy RAM cache → disk (slow, but live)  ◄────────┘
#
# The container is only paused for the RAM-to-RAM copy — typically well under
# a second — and the slow write to persistent storage happens while it is
# serving again. Every stage is timed so the pause window is measured rather
# than assumed.
#
# Usage:
#   ./ramdisk-backup.sh
#   RAMDISK=/tmp/RAMDISK ./ramdisk-backup.sh
#
# To disable for one service without touching cron, create its breaker file:
#   touch /boot/scripts/SAFETYBOX/plex

set -euo pipefail

# ---- Configuration ---------------------------------------------------------
RAMDISK="${RAMDISK:-/tmp/RAMDISK}"
APPDATA="${APPDATA:-/mnt/cache_addons/addonfiles/dockers/appdata}"
SAFETYBOX="${SAFETYBOX:-/boot/scripts/SAFETYBOX}"
LOG="${LOG:-/var/log/ramdisk-backup.log}"

# Services to back up. Add a line per container; the layout under $RAMDISK and
# $APPDATA is assumed to follow <service>/databases and <service>/backups.
SERVICES="${SERVICES:-plex ombi}"

SEP="=============================="

# ---- Logging ---------------------------------------------------------------
log() { printf '%b\n' "$*" | tee -a "$LOG"; }
now() { date '+%Y-%m-%d %H:%M:%S'; }

script_start=$(date +%s)

# ---- Per-service backup ----------------------------------------------------
# Pauses one container, copies its databases within RAM, releases it, then
# flushes the RAM copy to persistent storage.
backup_service() {
    local svc="$1"
    local ram_db="$RAMDISK/$svc/databases"
    local dest="$APPDATA/$svc/backups/backup_daily"
    local cache="$ram_db/backup_cache"

    if [ -f "$SAFETYBOX/$svc" ]; then
        log "$SEP\n$svc backup ABORTED — breaker file present in $SAFETYBOX @ $(now)"
        return 0
    fi

    if [ ! -d "$ram_db" ]; then
        log "$SEP\n$svc backup SKIPPED — $ram_db does not exist @ $(now)"
        return 0
    fi

    log "$SEP\n$svc backup starting @ $(now)"
    local svc_start pause_start ram_start ram_end pause_end disk_start disk_end
    svc_start=$(date +%s)

    mkdir -p "$cache" "$dest"

    # --- paused window: keep this as short as possible ---
    pause_start=$(date +%s)
    docker pause "$svc" >/dev/null
    log "  $svc paused @ $(now)"

    ram_start=$(date +%s)
    cp "$ram_db"/*.db "$cache"/          # RAM to RAM
    ram_end=$(date +%s)

    docker unpause "$svc" >/dev/null
    pause_end=$(date +%s)
    # --- container is live again from here ---

    log "  $svc resumed @ $(now) — paused $((pause_end - pause_start))s"

    disk_start=$(date +%s)
    cp "$cache"/* "$dest"/               # RAM to disk, service running
    disk_end=$(date +%s)

    rm -rf "$cache"

    log "  [RAM -> disk] $svc finished @ $(now)"
    log "    paused for:        $((pause_end - pause_start))s"
    log "    RAM -> RAM copy:   $((ram_end - ram_start))s"
    log "    RAM -> disk copy:  $((disk_end - disk_start))s"
    log "    total:             $(( $(date +%s) - svc_start ))s"
}

# ---- Run -------------------------------------------------------------------
# A failure on one service should not abort the rest, so the loop tolerates it
# and reports at the end.
failed=0
for svc in $SERVICES; do
    backup_service "$svc" || { log "  ERROR: $svc backup failed"; failed=1; }
done

log "$SEP\nall backups finished @ $(now) — total $(( $(date +%s) - script_start ))s"
exit "$failed"
