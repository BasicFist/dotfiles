#!/usr/bin/env bash
# Toggle kitty background opacity between configured presets.
set -euo pipefail

STATE_DIR="${KITTY_TOGGLE_STATE_DIR:-${HOME}/.config/kitty/.state}"
STATE_FILE="${STATE_DIR}/opacity"
HIGH_OPACITY=${HIGH_OPACITY:-0.98}
LOW_OPACITY=${LOW_OPACITY:-0.85}
TARGET=${1:-}

mkdir -p "$STATE_DIR"

apply_opacity() {
    local value="$1"
    kitty @ set-background-opacity "$value" >/dev/null
    printf '%s' "$value" >"$STATE_FILE"
    printf 'Background opacity: %s\n' "$value"
}

get_state() {
    if [[ -n "$TARGET" ]]; then
        printf '%s' "$TARGET"
        return
    fi
    if [[ -f "$STATE_FILE" ]]; then
        cat "$STATE_FILE"
    else
        printf '%s' "$HIGH_OPACITY"
    fi
}

CURRENT=$(get_state)
NEXT="$LOW_OPACITY"
if [[ "$CURRENT" == "$LOW_OPACITY" ]]; then
    NEXT="$HIGH_OPACITY"
fi
apply_opacity "$NEXT"
