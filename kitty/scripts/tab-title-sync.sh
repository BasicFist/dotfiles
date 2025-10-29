#!/usr/bin/env bash
# Update kitty tab title to the current directory and active command.
# Intended to be called from PROMPT_COMMAND or precmd hook.
set -euo pipefail

WINDOW_ID=${KITTY_WINDOW_ID:-}
if [[ -z "$WINDOW_ID" ]]; then
    if ! command -v python3 >/dev/null 2>&1; then
        exit 0
    fi
    WINDOW_ID=$(kitty @ ls 2>/dev/null | python3 -c 'import json, sys
data = json.load(sys.stdin)
for os_window in data:
    for tab in os_window.get("tabs", []):
        for window in tab.get("windows", []):
            if window.get("is_focused"):
                print(window.get("id", ""))
                raise SystemExit
' || true)
    WINDOW_ID=${WINDOW_ID%%$'\n'*}
fi

if [[ -z "$WINDOW_ID" ]]; then
    exit 0
fi

PWD_TITLE=${PWD##*/}
CMD_TITLE=${1:-}
TITLE="$PWD_TITLE"
if [[ -n "$CMD_TITLE" ]]; then
    TITLE="$TITLE — $CMD_TITLE"
fi
kitty @ set-tab-title --match id:"$WINDOW_ID" "$TITLE" >/dev/null
