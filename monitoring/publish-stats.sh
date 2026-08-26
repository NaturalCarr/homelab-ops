#!/usr/bin/env bash
#
# publish-stats.sh
#
# Polls the platform's own /api/stats endpoint and writes a small JSON file
# into the portfolio's web root, where the page loads it same-origin.
#
# Why a snapshot rather than a live browser fetch:
#   - the portfolio and the platform are different origins (no CORS dance)
#   - no monitoring endpoint is exposed to the public internet
#   - a visitor's page load never depends on the homelab being reachable;
#     if this script stops running, the site serves the last good snapshot
#
# Uptime accounting:
#   Uptime Kuma's status-page API reports a 24-hour figure, and it only knows
#   what it has observed since monitoring began. Rather than claim a longer
#   history that was never measured, this script keeps a running tally in the
#   output file — total checks, successful checks, and the date it started.
#   The reported window therefore grows honestly from day one, and the page
#   states the observation period alongside the number.
#
# Usage:
#   ./publish-stats.sh
#   API_URL=http://127.0.0.1:3100/api/stats OUT=/path/stats.json ./publish-stats.sh
#   ./publish-stats.sh --dry-run
#
# Schedule every 15 minutes (Unraid User Scripts):  */15 * * * *

set -euo pipefail

# ---- Configuration ---------------------------------------------------------
API_URL="${API_URL:-http://127.0.0.1:3100/api/stats}"
OUT="${OUT:-/mnt/cache_addons/addonfiles/dockers/appdata/swag/www/natural/assets/data/stats.json}"
LOG="${LOG:-/var/log/publish-stats.log}"

DRY_RUN=0
[ "${1:-}" = "--dry-run" ] && DRY_RUN=1

log() { printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" | tee -a "$LOG"; }

command -v jq >/dev/null 2>&1 || { log "ERROR: jq is required"; exit 1; }

# ---- Fetch -----------------------------------------------------------------
raw="$(curl -fsS --max-time 15 "$API_URL")" || { log "ERROR: could not reach $API_URL"; exit 1; }
echo "$raw" | jq -e . >/dev/null 2>&1     || { log "ERROR: response was not valid JSON"; exit 1; }

# ---- Carry forward the running tally ---------------------------------------
# Read prior state so uptime is measured over the whole observation period
# rather than only the last 24 hours, and so the peak session count persists.
prev_checks=0; prev_ok=0; prev_peak=0
since="$(date -u '+%Y-%m-%d')"

if [ -f "$OUT" ] && jq -e . "$OUT" >/dev/null 2>&1; then
    prev_checks=$(jq -r '.uptimeChecks     // 0' "$OUT")
    prev_ok=$(    jq -r '.uptimeOk         // 0' "$OUT")
    prev_peak=$(  jq -r '.peakSessions     // 0' "$OUT")
    since=$(      jq -r '.observedSince    // empty' "$OUT")
    [ -z "$since" ] && since="$(date -u '+%Y-%m-%d')"
fi

# This check counts as "up" only if every monitor Kuma reports is up. A null
# reading (Kuma unreachable) is recorded as neither up nor down — an outage of
# the monitoring system is not an outage of the platform, and counting it as
# one would understate uptime just as much as ignoring a real outage overstates it.
up_now=$(   echo "$raw" | jq -r '.monitorsUp    // "null"')
total_now=$(echo "$raw" | jq -r '.monitorsTotal // "null"')

checks="$prev_checks"; ok="$prev_ok"
if [ "$up_now" != "null" ] && [ "$total_now" != "null" ] && [ "$total_now" -gt 0 ]; then
    checks=$((prev_checks + 1))
    [ "$up_now" -eq "$total_now" ] && ok=$((prev_ok + 1)) || log "monitor down: $up_now/$total_now up"
else
    log "WARN: Kuma unreachable — uptime tally not advanced"
fi

# Peak concurrent sessions is a high-water mark, so it only ever climbs.
now_sessions=$(echo "$raw" | jq -r '.sessionsNow // 0')
peak="$prev_peak"
[ "$now_sessions" -gt "$peak" ] && peak="$now_sessions"

# ---- Build the display payload ---------------------------------------------
# Values are pre-formatted for direct insertion into the page, so the frontend
# stays a dumb renderer with no unit or rounding logic of its own.
uptime_pct="null"
if [ "$checks" -gt 0 ]; then
    uptime_pct=$(awk -v o="$ok" -v c="$checks" 'BEGIN{printf "%.2f", (o/c)*100}')
fi

payload=$(echo "$raw" | jq \
    --arg since   "$since" \
    --argjson checks "$checks" \
    --argjson ok     "$ok" \
    --argjson peak   "$peak" \
    --arg uptime  "$uptime_pct" \
    '{
        generatedAt:    .collectedAt,
        sources:        .sources,
        observedSince:  $since,
        uptimeChecks:   $checks,
        uptimeOk:       $ok,
        peakSessions:   $peak,

        # Display-ready fields consumed by [data-metric] in the page.
        uptime:         (if $uptime == "null" then null else ($uptime + "%") end),
        services:       (if .monitorsTotal then (.monitorsTotal | tostring) else null end),
        accounts:       (if .accounts      then (.accounts      | tostring) else null end),
        sessionsPeak:   ($peak | tostring),
        libraryItems:   (if .libraryItems  then (.libraryItems  | tostring) else null end)
     }')

if [ "$DRY_RUN" -eq 1 ]; then
    echo "$payload" | jq .
    log "dry run — nothing written"
    exit 0
fi

# ---- Publish atomically ----------------------------------------------------
# Write to a temp file on the same filesystem and rename, so a visitor can
# never fetch a half-written file.
mkdir -p "$(dirname "$OUT")"
tmp="$(mktemp "${OUT}.XXXXXX")"
trap 'rm -f "$tmp"' EXIT
echo "$payload" > "$tmp"
chmod 644 "$tmp"
mv "$tmp" "$OUT"
trap - EXIT

log "published $OUT — uptime ${uptime_pct}% over ${checks} checks since ${since}"
