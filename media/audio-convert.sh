#!/usr/bin/env bash
#
# audio-convert.sh
#
# Transcodes audio to MP3 — one file, or every convertible file in a directory.
#
# Runs ffmpeg either natively or inside a container, so the same script works
# on a workstation and on a host where ffmpeg only exists as an image.
#
# Usage:
#   ./audio-convert.sh track.flac              # single file
#   ./audio-convert.sh /music                  # whole directory
#   ./audio-convert.sh                         # current directory
#   QUALITY=0 ./audio-convert.sh track.flac    # higher quality (0 = best)
#   FFMPEG_CONTAINER=ffmpeg-nvidia ./audio-convert.sh /music
#
# QUALITY is libmp3lame's -qscale:a — VBR, 0 (best) to 9. Default 2 is roughly
# 190 kbps average and transparent for most material.

set -euo pipefail

# ---- Configuration ---------------------------------------------------------
QUALITY="${QUALITY:-2}"
FFMPEG_CONTAINER="${FFMPEG_CONTAINER:-}"   # empty = use ffmpeg on PATH
CONTAINER_MOUNT="${CONTAINER_MOUNT:-/data}"
EXTENSIONS="${EXTENSIONS:-ogg m4a wav flac aac wma opus}"
OVERWRITE="${OVERWRITE:-0}"

target="${1:-.}"

# ---- ffmpeg invocation -----------------------------------------------------
# Containerised ffmpeg sees paths relative to its bind mount, not the host's,
# so the path is rewritten when a container is configured.
run_ffmpeg() {
    local in="$1" out="$2"
    if [ -n "$FFMPEG_CONTAINER" ]; then
        docker exec -i "$FFMPEG_CONTAINER" \
            ffmpeg -nostdin -loglevel error -y \
                   -i "$CONTAINER_MOUNT/$(basename "$in")" \
                   -codec:a libmp3lame -qscale:a "$QUALITY" \
                   "$CONTAINER_MOUNT/$(basename "$out")"
    else
        ffmpeg -nostdin -loglevel error -y \
               -i "$in" -codec:a libmp3lame -qscale:a "$QUALITY" "$out"
    fi
}

convert_one() {
    local in="$1"
    local out="${in%.*}.mp3"

    if [ -e "$out" ] && [ "$OVERWRITE" -ne 1 ]; then
        echo "skip (exists): $out"
        return 0
    fi

    echo "converting: $in -> $out"
    if run_ffmpeg "$in" "$out"; then
        echo "  ok"
    else
        echo "  FAILED: $in" >&2
        return 1
    fi
}

# ---- Preflight -------------------------------------------------------------
if [ -n "$FFMPEG_CONTAINER" ]; then
    docker inspect "$FFMPEG_CONTAINER" >/dev/null 2>&1 \
        || { echo "ERROR: container '$FFMPEG_CONTAINER' not found" >&2; exit 1; }
else
    command -v ffmpeg >/dev/null 2>&1 \
        || { echo "ERROR: ffmpeg not found on PATH (set FFMPEG_CONTAINER?)" >&2; exit 1; }
fi

# ---- Dispatch --------------------------------------------------------------
failed=0

if [ -f "$target" ]; then
    convert_one "$target" || failed=1

elif [ -d "$target" ]; then
    # Build a find expression from the extension list rather than globbing, so
    # an extension with no matches doesn't produce a literal unexpanded pattern.
    args=()
    for ext in $EXTENSIONS; do
        [ ${#args[@]} -gt 0 ] && args+=( -o )
        args+=( -iname "*.${ext}" )
    done

    count=0
    while IFS= read -r -d '' f; do
        convert_one "$f" || failed=1
        count=$((count + 1))
    done < <(find "$target" -maxdepth 1 -type f \( "${args[@]}" \) -print0)

    echo "processed $count file(s)"

else
    echo "ERROR: not a file or directory: $target" >&2
    exit 1
fi

exit "$failed"
