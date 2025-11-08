#!/usr/bin/env bash
# Shared helpers for launching AI collaboration modes.

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    echo "mode-launch.sh is a library and should not be executed directly." >&2
    exit 1
fi

_MODE_LAUNCH_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

AI_MODE_BOOTSTRAP="${_MODE_LAUNCH_LIB_DIR}/../ai-mode-bootstrap.sh"

if [[ ! -x "$AI_MODE_BOOTSTRAP" ]]; then
    echo "Mode launch bootstrap not found: $AI_MODE_BOOTSTRAP" >&2
    return 1
fi

LAUNCH_LOG_FILE=""

launch_ai_mode() {
    local title="$1"
    shift || true

    local sanitized_title
    sanitized_title=$(echo "$title" | tr '[:space:]' '-' | tr -cd '[:alnum:]-')
    local log_file
    log_file=$(mktemp "/tmp/ai-mode-${sanitized_title}.XXXX.log")
    LAUNCH_LOG_FILE="$log_file"

    if [[ -n "${TMUX:-}" ]]; then
        _launch_in_tmux "$title" "$log_file" "$@" || return 1
    elif [[ -n "${KITTY_WINDOW_ID:-}" ]] && command -v kitty &>/dev/null; then
        local cmd_parts=("${AI_MODE_BOOTSTRAP}" "$log_file" "$@")
        local launch_cmd
        printf -v launch_cmd '%q ' "${cmd_parts[@]}"
        if ! kitty @ launch --type=tab --title="$title" bash -lc "$launch_cmd"; then
            echo "Failed to launch kitty tab for $title" >&2
            return 1
        fi
        printf 'Log: %s\n' "$log_file"
    else
        echo "Launching mode in current terminal (log: $log_file)"
        "${AI_MODE_BOOTSTRAP}" "$log_file" "$@"
    fi

    return 0
}

_launch_in_tmux() {
    local title="$1"
    local log_file="$2"
    shift 2

    local window_ref
    if ! window_ref=$(TMUX='' tmux new-window -P -F "#{session_name}:#{window_index}" -n "$title" "${AI_MODE_BOOTSTRAP}" "$log_file" "$@"); then
        echo "Failed to create tmux window for $title" >&2
        return 1
    fi

    TMUX='' tmux split-window -v -t "$window_ref" "tail -F $log_file"
    TMUX='' tmux setw -t "$window_ref" remain-on-exit on
    TMUX='' tmux select-pane -t "$window_ref".0
    TMUX='' tmux display-message -t "$window_ref" "Log: $log_file"

    return 0
}

export LAUNCH_LOG_FILE
export -f launch_ai_mode
