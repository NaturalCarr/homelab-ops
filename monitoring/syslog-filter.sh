#!/usr/bin/env bash
#
# syslog-filter.sh
#
# Strips a known-noisy hardware message from syslog and tails the log with it
# suppressed going forward.
#
# Context: a flaky USB device was emitting a reset message several times a
# second, burying everything else. The device works; the log spam is the only
# symptom. Filtering the noise is what makes the rest of the log readable.
#
# Note on the rewrite: syslog is being appended to continuously, so it is
# filtered into a temp file and moved into place rather than edited in situ.
# Writing directly would race with rsyslog's own writes.
#
# Usage:
#   ./syslog-filter.sh                       # strip + follow
#   ./syslog-filter.sh --strip-only          # strip, don't follow
#   PATTERN='some other noise' ./syslog-filter.sh

set -euo pipefail

# ---- Configuration ---------------------------------------------------------
SYSLOG="${SYSLOG:-/var/log/syslog}"
PATTERN="${PATTERN:-usb 2-1.2.2: reset low-speed USB device number 60 using ehci-pci}"
TAIL_LINES="${TAIL_LINES:-90}"

STRIP_ONLY=0
[ "${1:-}" = "--strip-only" ] && STRIP_ONLY=1

[ -f "$SYSLOG" ] || { echo "ERROR: $SYSLOG not found" >&2; exit 1; }
[ -w "$SYSLOG" ] || { echo "ERROR: $SYSLOG not writable (need root?)" >&2; exit 1; }

# ---- Strip existing occurrences --------------------------------------------
# mktemp on the same filesystem so the mv is atomic — a cross-device mv is a
# copy+delete, which would briefly truncate the live log.
tmp="$(mktemp "${SYSLOG}.XXXXXX")"
trap 'rm -f "$tmp"' EXIT

before=$(wc -l < "$SYSLOG")

# grep -F: the pattern is a literal string, not a regex. The original escaped
# it into an awk regex, which broke on any message containing regex characters.
grep -Fv -- "$PATTERN" "$SYSLOG" > "$tmp" || true

after=$(wc -l < "$tmp")

# Preserve ownership and mode — rsyslog will keep writing to this inode.
chown --reference="$SYSLOG" "$tmp"
chmod --reference="$SYSLOG" "$tmp"
mv "$tmp" "$SYSLOG"
trap - EXIT

echo "removed $((before - after)) matching lines from $SYSLOG"

[ "$STRIP_ONLY" -eq 1 ] && exit 0

# ---- Follow, filtered ------------------------------------------------------
# --line-buffered so output appears immediately rather than in 4 KB blocks.
exec tail -f -n "$TAIL_LINES" "$SYSLOG" | grep --line-buffered -Fv -- "$PATTERN"
