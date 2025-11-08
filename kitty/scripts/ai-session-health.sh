#!/usr/bin/env bash
# Print a short status indicator for the AI agents tmux status bar.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/shared-state.sh"

SHARED_FILE="${AI_AGENTS_SHARED_FILE}"

if [[ ! -f "$SHARED_FILE" ]]; then
    echo "AI: no-log"
    exit 0
fi

now=$(date +%s)
mtime=$(stat -c %Y "$SHARED_FILE" 2>/dev/null || echo "$now")
delta=$((now - mtime))

if (( delta < 30 )); then
    status="ACTIVE"
    color="#[fg=colour46]"
elif (( delta < 300 )); then
    status="IDLE"
    color="#[fg=colour226]"
else
    status="STALE"
    color="#[fg=colour196]"
fi

human=""
if (( delta < 60 )); then
    human="${delta}s"
elif (( delta < 3600 )); then
    human="$((delta / 60))m"
else
    human="$((delta / 3600))h"
fi

printf "%sAI:%s %s #[default]" "$color" "$status" "$human"
