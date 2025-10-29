#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# AI Agents - fzf Knowledge Base Search
# ═══════════════════════════════════════════════════════════
# Interactive KB browsing with fuzzy finding and previews

set -euo pipefail

KB_DIR="${HOME}/.ai-agents/knowledge"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if fzf is installed
if ! command -v fzf &>/dev/null; then
    echo "❌ fzf not installed!"
    echo "Install with: sudo apt install fzf"
    exit 1
fi

# Check if KB exists
if [[ ! -d "$KB_DIR" ]]; then
    echo "📚 Knowledge base not initialized."
    echo "Initialize with: ai-knowledge-init.sh"
    exit 0
fi

# Find all KB entries with metadata
find_entries() {
    find "$KB_DIR" -name "*.md" -type f 2>/dev/null | while read -r file; do
        # Extract metadata from frontmatter
        title=$(head -n 10 "$file" | grep '^title:' | cut -d: -f2- | xargs || echo "")
        type=$(head -n 10 "$file" | grep '^type:' | cut -d: -f2- | xargs || echo "")
        tags=$(head -n 10 "$file" | grep '^tags:' | cut -d: -f2- | xargs || echo "")
        created=$(head -n 10 "$file" | grep '^created:' | cut -d: -f2- | xargs || echo "")

        # Fallbacks
        [[ -z "$title" ]] && title=$(basename "$file" .md)
        [[ -z "$type" ]] && type="unknown"
        [[ -z "$tags" ]] && tags="untagged"

        # Determine icon by type
        case "$type" in
            doc) icon="📄" ;;
            snippet) icon="💻" ;;
            decision) icon="⚖️" ;;
            pattern) icon="🔷" ;;
            *) icon="📝" ;;
        esac

        # Format: icon | type | title | tags | path
        printf "%s  %-10s  %-40s  [%s]  %s\n" "$icon" "$type" "$title" "$tags" "$file"
    done
}

# Preview function
preview_kb() {
    local line="$1"
    local file=$(echo "$line" | awk -F'  ' '{print $NF}')

    if [[ ! -f "$file" ]]; then
        echo "File not found: $file"
        return
    fi

    # Use bat if available for syntax highlighting
    if command -v bat &>/dev/null; then
        bat --style=numbers,changes \
            --color=always \
            --line-range :100 \
            "$file"
    elif command -v batcat &>/dev/null; then
        batcat --style=numbers,changes \
               --color=always \
               --line-range :100 \
               "$file"
    else
        # Fallback to cat with basic formatting
        echo "═══════════════════════════════════════════════════════"
        echo "File: $(basename "$file")"
        echo "═══════════════════════════════════════════════════════"
        cat "$file" | head -n 100
    fi
}

export -f preview_kb

# Count entries
entry_count=$(find "$KB_DIR" -name "*.md" -type f 2>/dev/null | wc -l)

if [[ $entry_count -eq 0 ]]; then
    echo "📚 Knowledge base is empty."
    echo "Add entries with: ai-kb-add.sh"
    exit 0
fi

# Build fzf options
FZF_OPTS=(
    --ansi
    --preview 'bash -c "preview_kb {}"'
    --preview-window 'right:60%:wrap'
    --header "📚 Knowledge Base Browser ($entry_count entries) | Tab=Multi-Select | Ctrl-O=Open | Enter=View"
    --border rounded
    --height 90%
    --layout reverse
    --prompt "🔍 Search KB: "
    --pointer "▶"
    --marker "✓"
    --multi
    --color 'fg:#f8f8f2,bg:#282a36,hl:#bd93f9'
    --color 'fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9'
    --color 'info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6'
    --color 'marker:#ff79c6,spinner:#ffb86c,header:#6272a4'
    --bind 'ctrl-d:preview-half-page-down'
    --bind 'ctrl-u:preview-half-page-up'
    --bind 'ctrl-f:preview-page-down'
    --bind 'ctrl-b:preview-page-up'
    --bind "ctrl-o:execute(${EDITOR:-vim} {-1})+abort"
    --bind 'ctrl-y:execute-silent(echo {-1} | xargs cat | xclip -selection clipboard)+abort'
)

# If in tmux and version 3.2+, use popup
if [[ -n "${TMUX:-}" ]]; then
    tmux_version=$(tmux -V | grep -oP '\d+\.\d+' || echo "0.0")
    if awk "BEGIN {exit !($tmux_version >= 3.2)}" 2>/dev/null; then
        # Use tmux popup
        selected=$(find_entries | fzf-tmux -p 90%,90% "${FZF_OPTS[@]}")
    else
        # Fall back to regular fzf
        selected=$(find_entries | fzf "${FZF_OPTS[@]}")
    fi
else
    # Not in tmux, use regular fzf
    selected=$(find_entries | fzf "${FZF_OPTS[@]}")
fi

# Process selection(s)
if [[ -n "$selected" ]]; then
    # Extract file paths
    files=$(echo "$selected" | awk -F'  ' '{print $NF}')

    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo "Selected KB Entries:"
    echo "═══════════════════════════════════════════════════════"

    # Display each file
    echo "$files" | while read -r file; do
        echo ""
        echo "📄 $(basename "$file")"
        echo "───────────────────────────────────────────────────"

        if command -v bat &>/dev/null; then
            bat --style=plain --color=always "$file"
        elif command -v batcat &>/dev/null; then
            batcat --style=plain --color=always "$file"
        else
            cat "$file"
        fi

        echo ""
    done

    echo "═══════════════════════════════════════════════════════"
    echo ""
    echo "To edit: ${EDITOR:-vim} <file>"
    echo ""
else
    echo ""
    echo "❌ No entries selected. Cancelled."
    exit 0
fi
