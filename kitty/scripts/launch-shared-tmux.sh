#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Kitty Shared Tmux Session Helper (minimal)
# ═══════════════════════════════════════════════════════════
# Attach the current terminal to a shared tmux session, creating
# it with two vertically split panes the first time it runs.

set -euo pipefail

SESSION=${KITTY_TMUX_SESSION:-kitty-shared}
LAYOUT=${KITTY_TMUX_LAYOUT:-even-vertical}

# Source shared utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

if ! command -v tmux >/dev/null 2>&1; then
    echo "Error: tmux is required for launch-shared-tmux.sh" >&2
    echo "Install with: sudo apt install tmux" >&2
    exit 1
fi

# Check if session exists and create if needed
if ! tmux has-session -t "$SESSION" 2>/dev/null; then
    notify_title "📦 Creating tmux session: $SESSION" 2

    if ! tmux new-session -d -s "$SESSION" "$SHELL" 2>/dev/null; then
        echo "Error: Failed to create tmux session '$SESSION'" >&2
        exit 1
    fi

    tmux split-window -v -t "$SESSION":0 2>/dev/null || true
    tmux select-layout -t "$SESSION":0 "$LAYOUT" >/dev/null 2>&1 || true

    notify_title "✅ Created tmux session: $SESSION" 1
fi

# Attach to session
notify_title "🔗 Attaching to tmux: $SESSION" 1
exec tmux attach -t "$SESSION"
