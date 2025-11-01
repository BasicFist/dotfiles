#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Dual AI Agents Tmux Session Launcher
# ═══════════════════════════════════════════════════════════
# Creates a tmux session with optimized layout for two AI agents
# that can communicate through shared panes.
#
# Layout:
#   ┌─────────────────────────────────────┐
#   │  Agent 1 Input                      │
#   ├─────────────────────────────────────┤
#   │  Agent 2 Input                      │
#   ├─────────────────────────────────────┤
#   │  Shared Output / Communication      │
#   └─────────────────────────────────────┘

set -euo pipefail

# Source shared utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/constants.sh"
source "${SCRIPT_DIR}/lib/common.sh"

# Use constants
SESSION="$AI_AGENTS_SESSION"
SHARED_FILE="$AI_AGENTS_SHARED_FILE"

if ! command -v tmux >/dev/null 2>&1; then
    echo "Error: tmux is required for launch-ai-agents-tmux.sh" >&2
    echo "Install with: sudo apt install tmux" >&2
    exit 1
fi

# Create shared communication file
touch "$SHARED_FILE"
chmod 666 "$SHARED_FILE" 2>/dev/null || true

# Check if session exists and create if needed
if ! tmux has-session -t "$SESSION" 2>/dev/null; then
    notify_title "🤖 Creating AI agents session: $SESSION" 2

    # Create session with first window
    if ! tmux new-session -d -s "$SESSION" -n "AI-Agents" "$SHELL" 2>/dev/null; then
        echo "Error: Failed to create tmux session '$SESSION'" >&2
        exit 1
    fi

    # Enable mouse support (click to select pane, scroll, etc.)
    tmux set-option -t "$SESSION" -g mouse on

    # Split horizontally for Agent 2 (top/bottom)
    tmux split-window -v -t "$SESSION":0 "$SHELL"

    # Split the bottom pane horizontally for shared output
    tmux split-window -v -t "$SESSION":0.1 "$SHELL"

    # Adjust pane sizes (30% Agent 1, 30% Agent 2, 40% Shared)
    tmux select-layout -t "$SESSION":0 even-vertical
    tmux resize-pane -t "$SESSION":0.0 -y 30%
    tmux resize-pane -t "$SESSION":0.1 -y 30%

    # Set pane titles with color coding
    tmux select-pane -t "$SESSION":0.0 -T "🤖 Agent-1 (Cyan)"
    tmux select-pane -t "$SESSION":0.1 -T "🦾 Agent-2 (Magenta)"
    tmux select-pane -t "$SESSION":0.2 -T "💬 Shared (Green)"

    # Color-code pane borders (requires tmux 3.2+)
    tmux select-pane -t "$SESSION":0.0 -P 'fg=colour51'   # Electric Cyan
    tmux select-pane -t "$SESSION":0.1 -P 'fg=colour201'  # Hot Pink/Magenta
    tmux select-pane -t "$SESSION":0.2 -P 'fg=colour46'   # Bright Green

    # Send welcome messages to each pane
    tmux send-keys -t "$SESSION":0.0 "# 🤖 Agent 1 Terminal (Cyan)" C-m
    tmux send-keys -t "$SESSION":0.0 "# Enhanced Commands:" C-m
    tmux send-keys -t "$SESSION":0.0 "#   ai-agent-send-enhanced.sh Agent1 TASK \"message\" [--notify] [--blink]" C-m
    tmux send-keys -t "$SESSION":0.0 "#   ai-agent-progress.sh Agent1 \"task\" current total" C-m
    tmux send-keys -t "$SESSION":0.0 "# Message Types: TASK, QUESTION, RESULT, ERROR, WARNING, INFO" C-m
    tmux send-keys -t "$SESSION":0.0 "clear" C-m

    tmux send-keys -t "$SESSION":0.1 "# 🦾 Agent 2 Terminal (Magenta)" C-m
    tmux send-keys -t "$SESSION":0.1 "# Enhanced Commands:" C-m
    tmux send-keys -t "$SESSION":0.1 "#   ai-agent-send-enhanced.sh Agent2 RESULT \"message\" [--notify] [--blink]" C-m
    tmux send-keys -t "$SESSION":0.1 "#   ai-agent-progress.sh Agent2 \"task\" current total" C-m
    tmux send-keys -t "$SESSION":0.1 "# Message Types: TASK, QUESTION, RESULT, ERROR, WARNING, INFO" C-m
    tmux send-keys -t "$SESSION":0.1 "clear" C-m

    tmux send-keys -t "$SESSION":0.2 "# 💬 Shared Output / Communication Pane (Green)" C-m
    tmux send-keys -t "$SESSION":0.2 "# Live feed with color-coded messages and progress bars" C-m
    tmux send-keys -t "$SESSION":0.2 "tail -f $SHARED_FILE" C-m

    # Focus on Agent 1 pane
    tmux select-pane -t "$SESSION":0.0

    notify_title "✅ AI agents session ready: $SESSION" 1
else
    # If session already exists, ensure mouse support is enabled
    tmux set-option -t "$SESSION" -g mouse on
    # Focus on Agent 1 pane
    tmux select-pane -t "$SESSION":0.0
fi

# Attach to session
notify_title "🔗 Attaching to AI agents: $SESSION" 1
exec tmux attach -t "$SESSION"
