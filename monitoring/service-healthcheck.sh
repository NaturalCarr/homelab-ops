#!/usr/bin/env bash
#
# service-healthcheck.sh
#
# Probes an HTTP endpoint and restarts its container if it stops responding.
# Intended for cron, every few minutes.
#
# The distinction that matters is between "timed out" and "returned an error".
# A service can answer with a 500 while still being alive and recovering; a
# timeout means it is wedged. Only the timeout justifies a restart, so this
# checks curl's exit code rather than treating any non-zero as dead:
#
#   0   responded            -> healthy, do nothing
#   28  operation timed out  -> wedged, restart
#   *   other (DNS, refused) -> log it, but don't restart on a transient
#
# A breaker file suppresses the restart without editing cron — useful when
# you're already working on the service and don't want automation fighting you.
#
# Usage:
#   ./service-healthcheck.sh
#   SERVICE=plex URL=http://127.0.0.1:32400/web ./service-healthcheck.sh

set -uo pipefail   # no -e: a failing probe is the normal path, not an error

# ---- Configuration ---------------------------------------------------------
SERVICE="${SERVICE:-plex}"
URL="${URL:-http://127.0.0.1:32400/web}"
TIMEOUT="${TIMEOUT:-10}"
SAFETYBOX="${SAFETYBOX:-/boot/scripts/SAFETYBOX}"
LOG="${LOG:-/var/log/service-healthcheck.log}"

log() { printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" | tee -a "$LOG"; }

# ---- Breaker ---------------------------------------------------------------
if [ -f "$SAFETYBOX/$SERVICE" ]; then
    log "$SERVICE check aborted — breaker file present in $SAFETYBOX"
    exit 0
fi

# ---- Probe -----------------------------------------------------------------
curl --silent --show-error --max-time "$TIMEOUT" --output /dev/null "$URL" 2>/dev/null
result=$?

case "$result" in
    0)
        log "$SERVICE responding normally at $URL"
        ;;
    28)
        log "$SERVICE UNREACHABLE (timeout after ${TIMEOUT}s) — restarting"
        if docker restart "$SERVICE" >>"$LOG" 2>&1; then
            log "$SERVICE restarted"
        else
            log "ERROR: failed to restart $SERVICE"
            exit 1
        fi
        ;;
    *)
        # Connection refused, DNS failure, TLS error. Often transient, and
        # restarting on these tends to cause more outages than it fixes.
        log "$SERVICE unexpected curl exit [$result] — not restarting"
        ;;
esac

exit 0
