#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# AI Agent Communication Helper - Send Message
# ═══════════════════════════════════════════════════════════
# Send a message from one agent to the shared communication pane

set -euo pipefail

SHARED_FILE="/tmp/ai-agents-shared.txt"
AGENT_ID="${1:-Unknown}"
MESSAGE="${2:-}"

if [[ -z "$MESSAGE" ]]; then
    echo "Usage: ai-agent-send.sh <agent-id> <message>" >&2
    echo "Example: ai-agent-send.sh Agent1 'Task completed'" >&2
    exit 1
fi

TIMESTAMP=$(date '+%H:%M:%S')
echo "[$TIMESTAMP] [$AGENT_ID] $MESSAGE" >> "$SHARED_FILE"
