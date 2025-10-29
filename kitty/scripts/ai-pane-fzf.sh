#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# AI Agents - fzf Tmux Pane Switcher
# ═══════════════════════════════════════════════════════════
# Interactive pane switching with live content previews

set -euo pipefail

# Check if in tmux
if [[ -z "${TMUX:-}" ]]; then
    echo "❌ Not in a tmux session!"
    echo "This tool only works inside tmux."
    exit 1
fi

# Check if fzf is installed
if ! command -v fzf &>/dev/null; then
    echo "❌ fzf not installed!"
    echo "Install with: sudo apt install fzf"
    exit 1
fi

# Get pane information
list_panes() {
    # Format: pane_id | pane_index | window_name | pane_current_command | pane_width x pane_height | active
    tmux list-panes -a -F "#{pane_id}|#{pane_index}|#{window_name}|#{pane_current_command}|#{pane_width}x#{pane_height}|#{pane_active}" | while IFS='|' read -r pane_id pane_idx window_name cmd size active; do
        # Determine status indicator
        if [[ "$active" == "1" ]]; then
            indicator="▶"
            status="[ACTIVE]"
        else
            indicator=" "
            status="       "
        fi

        # Format line for fzf
        printf "%s %-8s %-20s %-15s %-12s %s %s\n" \
            "$indicator" \
            "$pane_id" \
            "$window_name" \
            "$cmd" \
            "$size" \
            "$status" \
            "$pane_idx"
    done
}

# Preview pane content
preview_pane() {
    local line="$1"
    local pane_id=$(echo "$line" | awk '{print $2}')

    if [[ -z "$pane_id" ]]; then
        echo "No pane selected"
        return
    fi

    echo "═══════════════════════════════════════════════════════"
    echo "Pane: $pane_id"
    echo "═══════════════════════════════════════════════════════"
    echo ""

    # Capture pane content (last 50 lines)
    tmux capture-pane -t "$pane_id" -p -S -50 2>/dev/null || echo "Unable to capture pane content"
}

export -f preview_pane

# Count panes
pane_count=$(tmux list-panes -a | wc -l)

if [[ $pane_count -eq 0 ]]; then
    echo "📦 No tmux panes found."
    exit 0
fi

# Build fzf options
FZF_OPTS=(
    --ansi
    --preview 'bash -c "preview_pane {}"'
    --preview-window 'right:60%:wrap'
    --header "🗔 Tmux Pane Switcher ($pane_count panes) | Enter=Switch | Ctrl-C=Cancel"
    --border rounded
    --height 90%
    --layout reverse
    --prompt "🔍 Search panes: "
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
    --bind 'ctrl-r:reload(bash -c "list_panes")'
)

export -f list_panes

# Check tmux version for popup support
tmux_version=$(tmux -V | grep -oP '\d+\.\d+' || echo "0.0")
if awk "BEGIN {exit !($tmux_version >= 3.2)}" 2>/dev/null; then
    # Use tmux popup for even better UX
    selected=$(list_panes | fzf-tmux -p 90%,90% "${FZF_OPTS[@]}")
else
    # Fall back to regular fzf
    selected=$(list_panes | fzf "${FZF_OPTS[@]}")
fi

# Process selection
if [[ -n "$selected" ]]; then
    pane_id=$(echo "$selected" | awk '{print $2}')

    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo "Switching to pane: $pane_id"
    echo "═══════════════════════════════════════════════════════"

    # Switch to selected pane
    tmux select-pane -t "$pane_id"

    echo "✅ Switched to pane $pane_id"
else
    echo ""
    echo "❌ No pane selected. Cancelled."
    exit 0
fi
