#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# AI Agents - fzf Session Browser
# ═══════════════════════════════════════════════════════════
# Interactive session browsing with fuzzy finding and previews

set -euo pipefail

SNAPSHOT_DIR="${HOME}/.ai-agents/snapshots"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if fzf is installed
if ! command -v fzf &>/dev/null; then
    echo "❌ fzf not installed!"
    echo "Install with: sudo apt install fzf"
    echo "Or: git clone https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install"
    exit 1
fi

# Check if snapshot directory exists
if [[ ! -d "$SNAPSHOT_DIR" ]]; then
    echo "📁 No saved sessions found."
    echo "Save a session first with: ai-session-save.sh"
    exit 0
fi

# List sessions with metadata
list_sessions() {
    for dir in "$SNAPSHOT_DIR"/*/; do
        [[ ! -d "$dir" ]] && continue

        name=$(basename "$dir")
        meta="${dir}metadata.json"

        if [[ -f "$meta" ]]; then
            desc=$(jq -r '.description // "No description"' "$meta" 2>/dev/null || echo "No description")
            date=$(jq -r '.timestamp // "Unknown"' "$meta" 2>/dev/null || echo "Unknown")
            mode=$(jq -r '.mode // "unknown"' "$meta" 2>/dev/null || echo "unknown")
        else
            desc="No metadata"
            date="Unknown"
            mode="unknown"
        fi

        # Format: name | date | mode | description
        printf "%-30s  %s  %-15s  %s\n" "$name" "$date" "[$mode]" "$desc"
    done
}

# Preview function
preview_session() {
    local line="$1"
    local session=$(echo "$line" | awk '{print $1}')
    local meta="${SNAPSHOT_DIR}/${session}/metadata.json"
    local pane0="${SNAPSHOT_DIR}/${session}/pane-0.txt"
    local pane1="${SNAPSHOT_DIR}/${session}/pane-1.txt"

    echo "═══════════════════════════════════════════════════════"
    echo "Session: $session"
    echo "═══════════════════════════════════════════════════════"
    echo ""

    if [[ -f "$meta" ]]; then
        echo "📋 Metadata:"
        echo "────────────────────────────────────────────────────"

        if command -v jq &>/dev/null; then
            jq -C '.' "$meta" 2>/dev/null || cat "$meta"
        else
            cat "$meta"
        fi

        echo ""
        echo "────────────────────────────────────────────────────"
    fi

    if [[ -f "$pane0" ]]; then
        echo ""
        echo "📄 Agent 1 Pane Preview (first 15 lines):"
        echo "────────────────────────────────────────────────────"
        head -n 15 "$pane0"
        echo "────────────────────────────────────────────────────"
    fi

    if [[ -f "$pane1" ]]; then
        echo ""
        echo "📄 Agent 2 Pane Preview (first 15 lines):"
        echo "────────────────────────────────────────────────────"
        head -n 15 "$pane1"
        echo "────────────────────────────────────────────────────"
    fi
}

export -f preview_session
export SNAPSHOT_DIR

# Count sessions
session_count=$(find "$SNAPSHOT_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)

if [[ $session_count -eq 0 ]]; then
    echo "📁 No saved sessions found."
    echo "Save a session first with: ai-session-save.sh"
    exit 0
fi

# Build fzf options
FZF_OPTS=(
    --preview 'bash -c "preview_session {}"'
    --preview-window 'right:60%:wrap'
    --header "📦 AI Agents Session Browser ($session_count sessions) | Enter=Restore | Ctrl-C=Cancel"
    --border rounded
    --height 90%
    --layout reverse
    --prompt "🔍 Search sessions: "
    --pointer "▶"
    --marker "✓"
    --color 'fg:#f8f8f2,bg:#282a36,hl:#bd93f9'
    --color 'fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9'
    --color 'info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6'
    --color 'marker:#ff79c6,spinner:#ffb86c,header:#6272a4'
    --bind 'ctrl-d:preview-half-page-down'
    --bind 'ctrl-u:preview-half-page-up'
    --bind 'ctrl-f:preview-page-down'
    --bind 'ctrl-b:preview-page-up'
)

# If in tmux and version 3.2+, use popup
if [[ -n "${TMUX:-}" ]]; then
    tmux_version=$(tmux -V | grep -oP '\d+\.\d+')
    if awk "BEGIN {exit !($tmux_version >= 3.2)}"; then
        # Use tmux popup
        selected=$(list_sessions | fzf-tmux -p 90%,90% "${FZF_OPTS[@]}")
    else
        # Fall back to regular fzf
        selected=$(list_sessions | fzf "${FZF_OPTS[@]}")
    fi
else
    # Not in tmux, use regular fzf
    selected=$(list_sessions | fzf "${FZF_OPTS[@]}")
fi

# Process selection
if [[ -n "$selected" ]]; then
    session_name=$(echo "$selected" | awk '{print $1}')

    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo "Selected session: $session_name"
    echo "═══════════════════════════════════════════════════════"
    echo ""

    # Check if restore script exists
    if [[ -f "${SCRIPT_DIR}/ai-session-restore.sh" ]]; then
        echo "🔄 Restoring session..."
        "${SCRIPT_DIR}/ai-session-restore.sh" "$session_name"
    else
        echo "ℹ️  Session restore not yet implemented."
        echo "Selected: $session_name"
        echo ""
        echo "You can manually view session files at:"
        echo "  ${SNAPSHOT_DIR}/${session_name}/"
    fi
else
    echo ""
    echo "❌ No session selected. Cancelled."
    exit 0
fi
