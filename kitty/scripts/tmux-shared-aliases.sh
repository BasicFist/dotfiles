#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# tmux shared session aliases
# ═══════════════════════════════════════════════════════════
# Source this file from your shell (e.g. ~/.zshrc) to expose
# handy helpers for the shared "agents" tmux session.

# Attach to the shared session (create if missing)
alias tmux-shared='tmux attach -t agents || tmux new-session -s agents'

# Split helpers that operate on the shared session from any shell
alias tmux-shared-split-h='tmux split-window -h -t agents'
alias tmux-shared-split-v='tmux split-window -v -t agents'

# List panes in the shared session for quick targeting
alias tmux-shared-panes='tmux list-panes -t agents'
