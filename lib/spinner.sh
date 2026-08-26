#!/usr/bin/env bash
#
# spinner.sh
#
# Runs a command in the background and shows a spinner until it finishes.
# For long jobs on an interactive terminal where silence is indistinguishable
# from a hang.
#
# Usage:
#   ./spinner.sh long-running-command --with args
#   MESSAGE="Indexing" ./spinner.sh du -sh /mnt/user/media
#
# Exits with the wrapped command's exit code, so it stays usable in a pipeline:
#   ./spinner.sh make build && echo ok

set -uo pipefail

MESSAGE="${MESSAGE:-Processing}"
DELAY="${DELAY:-0.35}"

[ $# -gt 0 ] || { echo "usage: $0 <command> [args...]" >&2; exit 2; }

# Non-interactive (cron, CI, piped): run the command plainly. A spinner in a
# log file is thousands of lines of control characters.
if [ ! -t 1 ]; then
    exec "$@"
fi

show_spinner() {
    local pid="$1"
    local spinstr='|/-\'
    local temp
    local width
    width="$(tput cols 2>/dev/null || echo 80)"
    local blank
    blank="$(printf '%*s' "$width" '')"

    # kill -0 tests whether the PID is still alive without signalling it —
    # more reliable than grepping ps output, which can match unrelated PIDs.
    while kill -0 "$pid" 2>/dev/null; do
        temp="${spinstr#?}"
        printf '%s %c\r' "$MESSAGE" "$spinstr"
        spinstr="${temp}${spinstr%"$temp"}"
        sleep "$DELAY"
    done

    printf '%s\r' "$blank"
}

# Restore the cursor and clear the line even if interrupted.
cleanup() { printf '\033[?25h'; printf '%*s\r' "$(tput cols 2>/dev/null || echo 80)" ''; }
trap cleanup EXIT INT TERM

printf '\033[?25l'      # hide cursor

"$@" &
cmd_pid=$!

show_spinner "$cmd_pid"

wait "$cmd_pid"
exit $?
