#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Enhanced AI Agent Communication - Send Message
# ═══════════════════════════════════════════════════════════
# Send colored, typed messages with optional visual notifications

set -euo pipefail

SHARED_FILE="/tmp/ai-agents-shared.txt"
SESSION=${KITTY_AI_SESSION:-ai-agents}

# Source color library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/colors.sh"

usage() {
    cat <<EOF
Usage: ai-agent-send-enhanced.sh <agent-id> <type> <message> [--notify] [--blink]

Arguments:
  agent-id    Agent identifier (Agent1, Agent2, Coordinator, etc.)
  type        Message type (TASK, QUESTION, RESULT, ERROR, WARNING, INFO)
  message     Message content

Options:
  --notify    Send desktop notification
  --blink     Blink the agent's pane border

Message Types:
  TASK        📋 Task assignment or action item
  QUESTION    ❓ Question requiring response
  RESULT      ✅ Completed task or successful outcome
  ERROR       ❌ Error or failure
  WARNING     ⚠️  Warning or caution
  INFO        ℹ️  General information (default)

Examples:
  ai-agent-send-enhanced.sh Agent1 TASK "Analyze codebase for bugs"
  ai-agent-send-enhanced.sh Agent2 RESULT "Found 42 issues" --notify
  ai-agent-send-enhanced.sh Agent1 ERROR "Missing dependency" --blink
  ai-agent-send-enhanced.sh Coordinator INFO "Starting code review session"
EOF
}

if [[ $# -lt 3 ]]; then
    usage
    exit 1
fi

AGENT_ID="$1"
MSG_TYPE="$2"
MESSAGE="$3"
shift 3

# Parse options
DO_NOTIFY=false
DO_BLINK=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --notify)
            DO_NOTIFY=true
            shift
            ;;
        --blink)
            DO_BLINK=true
            shift
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage
            exit 1
            ;;
    esac
done

# Format and write message
FORMATTED_MSG=$(format_message "$MSG_TYPE" "$AGENT_ID" "$MESSAGE")
echo -e "$FORMATTED_MSG" >> "$SHARED_FILE"

# Also write plain text version for parsing
TIMESTAMP=$(date '+%H:%M:%S')
echo "[$TIMESTAMP] [$AGENT_ID] [$MSG_TYPE] $MESSAGE" >> "${SHARED_FILE}.log"

# Desktop notification if requested
if [[ "$DO_NOTIFY" == true ]]; then
    if command -v notify-send >/dev/null 2>&1; then
        case "$MSG_TYPE" in
            ERROR)
                notify-send -u critical "AI Agent: $AGENT_ID" "$MESSAGE"
                ;;
            WARNING)
                notify-send -u normal "AI Agent: $AGENT_ID" "$MESSAGE"
                ;;
            RESULT)
                notify-send -u low "AI Agent: $AGENT_ID" "✅ $MESSAGE"
                ;;
            *)
                notify-send "AI Agent: $AGENT_ID" "$MESSAGE"
                ;;
        esac
    fi
fi

# Visual blink if requested and tmux session exists
if [[ "$DO_BLINK" == true ]]; then
    if tmux has-session -t "$SESSION" 2>/dev/null; then
        # Determine which pane to blink based on agent
        case "$AGENT_ID" in
            Agent1|AGENT1|agent1)
                PANE_ID="$SESSION:0.0"
                ;;
            Agent2|AGENT2|agent2)
                PANE_ID="$SESSION:0.1"
                ;;
            *)
                PANE_ID="$SESSION:0.2"  # Shared pane
                ;;
        esac

        # Blink effect: change border color temporarily
        (
            # Store original style
            tmux select-pane -t "$PANE_ID" -P 'bg=red'
            sleep 0.2
            tmux select-pane -t "$PANE_ID" -P 'bg=default'
            sleep 0.1
            tmux select-pane -t "$PANE_ID" -P 'bg=red'
            sleep 0.2
            tmux select-pane -t "$PANE_ID" -P 'bg=default'
        ) &
    fi
fi
