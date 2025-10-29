#!/usr/bin/env bash
# Toggle a translucent scratchpad overlay in kitty.
set -euo pipefail

if ! command -v python3 >/dev/null 2>&1; then
    printf 'python3 is required for toggle-scratchpad (JSON parsing).\n' >&2
    exit 1
fi

TITLE=${KITTY_SCRATCHPAD_TITLE:-Scratchpad}
MATCH="title:^${TITLE}$"
SHELL_CMD=${KITTY_SCRATCHPAD_SHELL:-${SHELL:-/bin/sh}}

has_scratchpad() {
    kitty @ ls 2>/dev/null | python3 -c 'import json, sys
name = sys.argv[1]
for os_window in json.load(sys.stdin):
    for tab in os_window.get("tabs", []):
        for window in tab.get("windows", []):
            if window.get("title") == name:
                sys.exit(0)
sys.exit(1)' "$TITLE"
}

launch_scratchpad() {
    kitty @ launch --type=overlay --title "$TITLE" --keep-focus --cwd=current \
        --env KITTY_SCRATCHPAD=1 --override background_opacity=0.85 \
        --hold "$SHELL_CMD" -l >/dev/null
}

close_scratchpad() {
    kitty @ close-window --match "$MATCH" >/dev/null
}

if has_scratchpad; then
    close_scratchpad
else
    launch_scratchpad
fi
