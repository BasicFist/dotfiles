#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Kitty Agent Subterminal Helper
# ═══════════════════════════════════════════════════════════
# Launches and manages an overlay window that can be driven via
# kitty's remote control API (https://sw.kovidgoyal.net/kitty/remote-control).
# Useful for letting an external agent run commands in a dedicated
# pane while you keep working in the primary terminal.

set -euo pipefail

TITLE=${KITTY_AGENT_TITLE:-Agent}
ESC_TITLE=$(python3 -c 'import re, sys; print(re.escape(sys.argv[1]))' "$TITLE")
MATCH="title:^${ESC_TITLE}$"
SHELL_CMD=${KITTY_AGENT_SHELL:-${SHELL:-/bin/sh}}
LAUNCH_MODE=${KITTY_AGENT_LAUNCH_MODE:-overlay}

# Source shared utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

case "$LAUNCH_MODE" in
    overlay)
        LAUNCH_OPTS=(--type=overlay --keep-focus)
        ;;
    hsplit)
        LAUNCH_OPTS=(--location=hsplit)
        ;;
    vsplit)
        LAUNCH_OPTS=(--location=vsplit)
        ;;
    *)
        echo "Unknown KITTY_AGENT_LAUNCH_MODE: $LAUNCH_MODE" >&2
        exit 1
        ;;
esac

if ! command -v python3 >/dev/null 2>&1; then
    echo "Error: python3 is required by agent-terminal.sh" >&2
    exit 1
fi

kitty_cmd() {
    kitty @ "$@"
}

agent_exists() {
    local output
    if ! output=$(kitty_cmd ls --match "$MATCH" 2>/dev/null); then
        return 1
    fi
    [[ "$output" != "[]" ]]
}

launch_agent() {
    if agent_exists; then
        return 0
    fi

    notify_title "🚀 Launching agent terminal..." 1

    if ! kitty_cmd launch \
        "${LAUNCH_OPTS[@]}" \
        --title "$TITLE" \
        --cwd=current \
        --env KITTY_AGENT=1 \
        "$SHELL_CMD" -l 2>&1; then
        echo "Error: Failed to launch agent window" >&2
        echo "Check: kitty @ ls (verify remote control enabled)" >&2
        return 1
    fi

    # Brief success notification
    sleep 0.3
    if agent_exists; then
        notify_title "🤖 Agent: Active" 2
    fi
}

focus_agent() {
    if agent_exists; then
        kitty_cmd focus-window --match "$MATCH" >/dev/null
    else
        launch_agent
    fi
}

close_agent() {
    if agent_exists; then
        kitty_cmd close-window --match "$MATCH" >/dev/null
        notify_title "✅ Agent closed" 1
    fi
}

send_text() {
    launch_agent
    local input="$1"
    printf '%s\n' "$input" | kitty_cmd send-text --match "$MATCH" --stdin >/dev/null
}

pipe_stdin() {
    launch_agent
    kitty_cmd send-text --match "$MATCH" --stdin >/dev/null <&0
}

status_agent() {
    if agent_exists; then
        echo "agent:active"
    else
        echo "agent:inactive"
    fi
}

toggle_agent() {
    if agent_exists; then
        close_agent
    else
        launch_agent
    fi
}

usage() {
    cat <<'EOF'
Usage: agent-terminal.sh <command> [args]

Commands:
  open|launch           Ensure the overlay agent window exists
  focus                 Focus (or create) the agent window
  close                 Close the agent window if present
  toggle                Toggle the overlay agent window
  run <cmd...>          Send a command line (with newline) to the agent
  pipe                  Read stdin and forward to the agent
  status                Print agent:active or agent:inactive
  help                  Show this message

Environment overrides:
  KITTY_AGENT_TITLE     Window title to match (default: Agent)
  KITTY_AGENT_SHELL     Shell to launch inside the agent window
EOF
}

main() {
    local action=${1:-help}
    shift || true

    case "$action" in
        open|launch)
            launch_agent
            ;;
        focus)
            focus_agent
            ;;
        close)
            close_agent
            ;;
        toggle)
            toggle_agent
            ;;
        run)
            if [[ $# -eq 0 ]]; then
                echo "Error: run requires a command" >&2
                exit 1
            fi
            send_text "$*"
            ;;
        pipe)
            pipe_stdin
            ;;
        status)
            status_agent
            ;;
        help|-h|--help)
            usage
            ;;
        *)
            echo "Unknown command: $action" >&2
            usage >&2
            exit 1
            ;;
    esac
}

main "$@"
