#!/usr/bin/env bash
#
# restart-container-stack.sh
#
# Restarts a container stack where one container provides network for others
# (the common "gateway + dependents" pattern — e.g. a VPN container that
# downstream containers attach to with `network_mode: container:<gateway>`).
#
# Those dependents cannot survive the gateway restarting: their network
# namespace disappears underneath them. So the order matters:
#
#   1. stop dependents
#   2. restart the gateway
#   3. poll the gateway's Docker healthcheck until it reports healthy
#   4. brief buffer for routing/DNS to settle inside the namespace
#   5. start dependents
#
# Step 3 is the point of the script. Sleeping a fixed interval and hoping is
# the usual approach and it fails intermittently — either wasting time when
# the tunnel comes up fast, or starting dependents into a half-open network
# when it comes up slow.
#
# Usage:
#   ./restart-container-stack.sh
#   GATEWAY=gluetun DEPENDENTS="app1 app2" ./restart-container-stack.sh
#
# Exit codes: 0 ok · 1 gateway failed to restart or never became healthy

set -euo pipefail

# ---- Configuration ---------------------------------------------------------
GATEWAY="${GATEWAY:-gluetun}"          # container that owns the network namespace
DEPENDENTS="${DEPENDENTS:-}"           # space-separated containers riding on it
LOG="${LOG:-/var/log/restart-container-stack.log}"

POLL_INTERVAL="${POLL_INTERVAL:-15}"   # seconds between health polls
MAX_ATTEMPTS="${MAX_ATTEMPTS:-40}"     # give up after this many (40 * 15s = 10m)
BUFFER_SECONDS="${BUFFER_SECONDS:-10}" # settle time after healthy, before restart

# ---- Logging ---------------------------------------------------------------
log() { printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" | tee -a "$LOG"; }

# ---- Preflight -------------------------------------------------------------
command -v docker >/dev/null 2>&1 || { log "ERROR: docker not found"; exit 1; }

if [ -z "$DEPENDENTS" ]; then
    log "ERROR: DEPENDENTS is empty — nothing to restart. Set it and re-run."
    exit 1
fi

log "=== stack restart: gateway=$GATEWAY dependents=[$DEPENDENTS] ==="

# ---- 1. Stop dependents ----------------------------------------------------
# A dependent that is already stopped is fine; don't let that abort the run.
for c in $DEPENDENTS; do
    log "[1/4] stopping $c"
    if docker stop "$c" >>"$LOG" 2>&1; then
        log "      $c stopped"
    else
        log "      WARN: $c stop returned non-zero (already stopped?)"
    fi
done

# ---- 2. Restart the gateway ------------------------------------------------
log "[2/4] restarting $GATEWAY"
if ! docker restart "$GATEWAY" >>"$LOG" 2>&1; then
    log "ERROR: failed to restart $GATEWAY — aborting, dependents left down"
    exit 1
fi

# ---- 3. Wait for the gateway to be healthy ---------------------------------
# Requires a HEALTHCHECK on the gateway image. Without one, .State.Health is
# empty and this loop would spin until MAX_ATTEMPTS — so treat that as fatal
# rather than silently waiting ten minutes.
log "[3/4] polling $GATEWAY health (max $((MAX_ATTEMPTS * POLL_INTERVAL))s)"

attempt=0
while [ "$attempt" -lt "$MAX_ATTEMPTS" ]; do
    health="$(docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' \
              "$GATEWAY" 2>/dev/null || echo unknown)"

    if [ "$health" = "none" ]; then
        log "ERROR: $GATEWAY has no healthcheck defined — cannot verify it is up"
        exit 1
    fi

    attempt=$((attempt + 1))
    log "      attempt $attempt/$MAX_ATTEMPTS: health=$health"

    [ "$health" = "healthy" ] && break

    if [ "$attempt" -ge "$MAX_ATTEMPTS" ]; then
        log "ERROR: $GATEWAY never became healthy — leaving dependents down"
        exit 1
    fi

    sleep "$POLL_INTERVAL"
done

log "      $GATEWAY healthy"

# Healthy means the tunnel answered, not that routing and DNS have settled
# inside the namespace. Dependents that start too early fail to resolve.
log "[3b/4] ${BUFFER_SECONDS}s buffer for routing/DNS to settle"
sleep "$BUFFER_SECONDS"

# ---- 4. Start dependents ---------------------------------------------------
failed=0
for c in $DEPENDENTS; do
    log "[4/4] starting $c"
    if docker start "$c" >>"$LOG" 2>&1; then
        log "      $c started"
    else
        log "      ERROR: failed to start $c"
        failed=1
    fi
done

log "=== done (exit $failed) ==="
exit "$failed"
