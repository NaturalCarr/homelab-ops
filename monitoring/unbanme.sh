#!/usr/bin/env bash
#
# unbanme — remove my own public IP from every fail2ban jail.
#
# Replaces the old f2bclear, which deleted fail2ban's entire state directory
# and restarted SWAG. That worked, but it threw away every ban on the server
# to fix one — and lost the ban database in the process.
#
# Finding the right IP is the actual problem. The public address is dynamic,
# and asking DNS is unreliable because the records are proxied — a lookup
# returns the proxy, not the origin. But ddns-updater already tracks the real
# address in its own state file, so that's the authoritative local source.
#
# Order of preference:
#   1. an IP passed as an argument
#   2. the newest entry in ddns-updater's updates.json   (no network needed)
#   3. an external IP echo service                       (fallback)
#
# Usage:
#   unbanme                 # detect and unban
#   unbanme 1.2.3.4         # unban a specific address
#   unbanme --dry-run       # show what would happen
#   unbanme --status        # just report where I'm banned

set -uo pipefail

# ---- Configuration ---------------------------------------------------------
CONTAINER="${CONTAINER:-swag}"
UPDATES_JSON="${UPDATES_JSON:-/mnt/cache_addons/addonfiles/dockers/appdata/ddns-updater/updates.json}"
IP_ECHO_URL="${IP_ECHO_URL:-https://api.ipify.org}"

DRY_RUN=0
STATUS_ONLY=0
IP_ARG=""

for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=1 ;;
        --status)  STATUS_ONLY=1 ;;
        -h|--help) sed -n '2,26p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *)         IP_ARG="$arg" ;;
    esac
done

die() { printf 'error: %s\n' "$*" >&2; exit 1; }

# ---- IP helpers ------------------------------------------------------------

# Reject anything that isn't a well-formed IPv4 address. This value is passed
# to a command, so it must never be taken on trust.
valid_ipv4() {
    local ip="$1" o
    [[ "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || return 1
    for o in ${ip//./ }; do
        [ "$o" -le 255 ] || return 1
    done
    return 0
}

# Newest address recorded by ddns-updater. Its ips[] arrays are chronological
# with the newest last; jq sorts across all records by timestamp, and the grep
# fallback takes the last match in file order (equivalent here, since the file
# is only ever appended to).
ip_from_ddns() {
    [ -r "$UPDATES_JSON" ] || return 1
    if command -v jq >/dev/null 2>&1; then
        jq -r '[.records[].ips[]] | sort_by(.time) | last | .ip' "$UPDATES_JSON" 2>/dev/null
    else
        grep -oE '"ip"[[:space:]]*:[[:space:]]*"[0-9]+(\.[0-9]+){3}"' "$UPDATES_JSON" \
            | tail -n1 | grep -oE '[0-9]+(\.[0-9]+){3}'
    fi
}

ip_from_echo() {
    command -v curl >/dev/null 2>&1 || return 1
    curl -fsS --max-time 10 "$IP_ECHO_URL" 2>/dev/null
}

# ---- fail2ban helpers ------------------------------------------------------
f2b() { docker exec "$CONTAINER" fail2ban-client "$@" 2>/dev/null; }

jail_list() {
    f2b status | sed -n 's/.*Jail list:[[:space:]]*//p' | tr ',' ' ' | tr -s ' '
}

# Every jail currently holding this address.
jails_banning() {
    local ip="$1" jail
    for jail in $(jail_list); do
        if f2b status "$jail" | grep -qE "Banned IP list:.*(^|[[:space:]])${ip//./\\.}([[:space:]]|$)"; then
            printf '%s\n' "$jail"
        fi
    done
}

# ---- Preflight -------------------------------------------------------------
command -v docker >/dev/null 2>&1 || die "docker not found"
docker inspect "$CONTAINER" >/dev/null 2>&1 || die "container '$CONTAINER' not found"
f2b ping >/dev/null 2>&1 || die "fail2ban is not responding inside '$CONTAINER'"

# ---- Resolve the address ---------------------------------------------------
if [ -n "$IP_ARG" ]; then
    IP="$IP_ARG"; SOURCE="argument"
elif IP="$(ip_from_ddns)" && [ -n "$IP" ]; then
    SOURCE="ddns-updater ($UPDATES_JSON)"
elif IP="$(ip_from_echo)" && [ -n "$IP" ]; then
    SOURCE="$IP_ECHO_URL"
else
    die "could not determine public IP — pass one explicitly: unbanme <ip>"
fi

valid_ipv4 "$IP" || die "not a valid IPv4 address: '$IP'"

printf 'public IP : %s\n' "$IP"
printf 'source    : %s\n' "$SOURCE"

# ---- Report ----------------------------------------------------------------
mapfile -t BANNED < <(jails_banning "$IP")

if [ "${#BANNED[@]}" -eq 0 ]; then
    printf 'status    : not banned in any jail\n'
    [ "$STATUS_ONLY" -eq 1 ] && exit 0
    # Still worth running the unban: it is a harmless no-op, and it clears any
    # stale entry the status output didn't surface.
else
    printf 'status    : banned in %d jail(s): %s\n' "${#BANNED[@]}" "${BANNED[*]}"
fi

[ "$STATUS_ONLY" -eq 1 ] && exit 0

# ---- Unban -----------------------------------------------------------------
if [ "$DRY_RUN" -eq 1 ]; then
    printf 'dry run   : would run  docker exec %s fail2ban-client unban %s\n' "$CONTAINER" "$IP"
    exit 0
fi

# `unban <ip>` clears the address from every jail at once, and is a no-op when
# it isn't banned — no need to iterate.
if f2b unban "$IP" >/dev/null; then
    printf 'result    : unbanned %s across all jails\n' "$IP"
else
    die "fail2ban-client unban failed for $IP"
fi

# Confirm rather than assume.
mapfile -t STILL < <(jails_banning "$IP")
if [ "${#STILL[@]}" -eq 0 ]; then
    printf 'verified  : no longer banned\n'
else
    printf 'WARNING   : still present in: %s\n' "${STILL[*]}"
    exit 1
fi
