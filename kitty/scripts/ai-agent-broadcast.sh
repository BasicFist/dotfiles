#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# AI Agent Broadcast Helper
# ═══════════════════════════════════════════════════════════
# Broadcast a message to both AI agents via tmux

set -euo pipefail

SESSION=${KITTY_AI_SESSION:-ai-agents}
MESSAGE="${1:-}"

if [[ -z "$MESSAGE" ]]; then
    echo "Usage: ai-agent-broadcast.sh <message>" >&2
    echo "Example: ai-agent-broadcast.sh 'Starting new task'" >&2
    exit 1
fi

if ! tmux has-session -t "$SESSION" 2>/dev/null; then
    echo "Error: AI agents session '$SESSION' not running" >&2
    exit 1
fi

# Send message to Agent 1 pane
tmux send-keys -t "$SESSION":0.0 "# BROADCAST: $MESSAGE" C-m

# Send message to Agent 2 pane
tmux send-keys -t "$SESSION":0.1 "# BROADCAST: $MESSAGE" C-m

# Also send to shared file
TIMESTAMP=$(date '+%H:%M:%S')
echo "[$TIMESTAMP] [BROADCAST] $MESSAGE" >> /tmp/ai-agents-shared.txt
