#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# ADR Browser - Fuzzy Find Architecture Decision Records
# ═══════════════════════════════════════════════════════════

set -euo pipefail

# Source required libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/colors.sh"
source "${SCRIPT_DIR}/lib/errors.sh"

# Configuration
ADR_DIR="${AI_AGENTS_KB_DECISIONS:-$HOME/.ai-agents/knowledge/decisions}"

usage() {
    cat <<EOF
Usage: ai-adr-browse-fzf.sh [OPTIONS]

Browse Architecture Decision Records with fuzzy search.

OPTIONS:
  -s, --status STATUS    Filter by status (Proposed|Accepted|Deprecated|Superseded|all)
  -d, --date-from DATE   Filter from date (YYYY-MM-DD)
  -t, --date-to DATE     Filter to date (YYYY-MM-DD)
  -h, --help            Show this help message

KEYBOARD SHORTCUTS:
  Enter         - Open ADR in editor
  Ctrl-E        - Edit ADR
  Ctrl-U        - Update status
  Ctrl-S        - Supersede ADR
  Ctrl-L        - Link to another ADR
  Ctrl-G        - Show graph visualization
  Ctrl-R        - Reload list
  Ctrl-/        - Toggle preview
  ESC           - Exit

EXAMPLES:
  # Browse all ADRs
  ai-adr-browse-fzf.sh

  # Filter by status
  ai-adr-browse-fzf.sh --status Accepted

  # Filter by date range
  ai-adr-browse-fzf.sh --date-from 2025-01-01 --date-to 2025-12-31

EOF
}

# Check dependencies
check_dependencies() {
    local missing_deps=()

    if ! command -v fzf >/dev/null 2>&1; then
        missing_deps+=("fzf")
    fi

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        error_color "❌ Missing required dependencies: ${missing_deps[*]}"
        error_color ""
        error_color "Install with:"
        for dep in "${missing_deps[@]}"; do
            case "$dep" in
                fzf)
                    error_color "  - fzf: https://github.com/junegunn/fzf#installation"
                    ;;
            esac
        done
        return 1
    fi

    return 0
}

# Parse ADR metadata
parse_adr_metadata() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        return 1
    fi

    local number=$(basename "$file" | sed 's/ADR-\([0-9]*\).*/\1/')
    local title=$(grep "^# ADR-" "$file" | head -1 | sed 's/# ADR-[0-9]*: //' || echo "Untitled")
    local status=$(grep "^\*\*Status:\*\*" "$file" | sed 's/.*: //' || echo "Unknown")
    local date=$(grep "^\*\*Date:\*\*" "$file" | grep -oP '\d{4}-\d{2}-\d{2}' | head -1 || echo "Unknown")
    local decision_makers=$(grep "^\*\*Decision Makers:\*\*" "$file" | sed 's/.*: //' || echo "Unknown")

    # Get related ADRs count
    local related_count=0
    if grep -q "^## Related Decisions" "$file"; then
        related_count=$(sed -n '/^## Related Decisions$/,/^##/p' "$file" | grep -c "^- ADR-" || echo "0")
    fi

    # Status emoji
    local status_emoji="📔"
    case "$status" in
        Accepted) status_emoji="📗" ;;
        Proposed) status_emoji="📘" ;;
        Superseded) status_emoji="📙" ;;
        Deprecated) status_emoji="📕" ;;
    esac

    echo "$number|$status|$date|$title|$file|$decision_makers|$related_count|$status_emoji"
}

# Build ADR list
build_adr_list() {
    local status_filter="$1"
    local date_from="$2"
    local date_to="$3"

    if [[ ! -d "$ADR_DIR" ]]; then
        error_color "❌ ADR directory not found: $ADR_DIR"
        return 1
    fi

    local adr_files=("$ADR_DIR"/ADR-*.md)
    if [[ ! -f "${adr_files[0]}" ]]; then
        warn_color "⚠️  No ADRs found in $ADR_DIR"
        return 1
    fi

    for file in "${adr_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            continue
        fi

        local metadata=$(parse_adr_metadata "$file")
        if [[ -z "$metadata" ]]; then
            continue
        fi

        local status=$(echo "$metadata" | cut -d'|' -f2)
        local date=$(echo "$metadata" | cut -d'|' -f3)

        # Apply filters
        if [[ "$status_filter" != "all" ]] && [[ "$status" != "$status_filter" ]]; then
            continue
        fi

        if [[ -n "$date_from" ]] && [[ "$date" < "$date_from" ]]; then
            continue
        fi

        if [[ -n "$date_to" ]] && [[ "$date" > "$date_to" ]]; then
            continue
        fi

        echo "$metadata"
    done | sort -t'|' -k1 -rn
}

# Format ADR for display
format_adr_line() {
    local line="$1"

    local number=$(echo "$line" | cut -d'|' -f1)
    local status=$(echo "$line" | cut -d'|' -f2)
    local date=$(echo "$line" | cut -d'|' -f3)
    local title=$(echo "$line" | cut -d'|' -f4)
    local related_count=$(echo "$line" | cut -d'|' -f7)
    local emoji=$(echo "$line" | cut -d'|' -f8)

    # Format with padding
    local padded_num=$(printf "ADR-%04d" "$number")
    local padded_status=$(printf "%-11s" "$status")

    echo "$emoji $padded_num  $padded_status  $date  $title  (${related_count} links)"
}

# Preview ADR
preview_adr() {
    local line="$1"
    local file=$(echo "$line" | cut -d'|' -f5)

    if [[ ! -f "$file" ]]; then
        echo "File not found: $file"
        return 1
    fi

    # Use bat if available, otherwise cat with basic formatting
    if command -v bat >/dev/null 2>&1; then
        bat --style=numbers,grid --color=always --line-range=:100 "$file"
    else
        echo "========================================="
        echo "$(basename "$file")"
        echo "========================================="
        head -100 "$file"
        echo ""
        echo "💡 Install 'bat' for syntax highlighting"
    fi

    # Show related ADRs at the bottom
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Related ADRs:"
    if grep -q "^## Related Decisions" "$file"; then
        sed -n '/^## Related Decisions$/,/^##/p' "$file" | grep "^- ADR-" | sed 's/^/  /'
    else
        echo "  None"
    fi
}

# Browse ADRs with fzf
browse_adrs() {
    local status_filter="${1:-all}"
    local date_from="${2:-}"
    local date_to="${3:-}"

    # Check dependencies
    if ! check_dependencies; then
        return 1
    fi

    # Build list
    local adr_list
    if ! adr_list=$(build_adr_list "$status_filter" "$date_from" "$date_to"); then
        return 1
    fi

    if [[ -z "$adr_list" ]]; then
        warn_color "⚠️  No ADRs match the filter criteria"
        return 0
    fi

    # Create temp file for mapping
    local tmp_map=$(mktemp)
    local tmp_display=$(mktemp)
    trap "rm -f '$tmp_map' '$tmp_display'" EXIT

    # Build display and mapping
    while IFS= read -r line; do
        local display_line=$(format_adr_line "$line")
        local file=$(echo "$line" | cut -d'|' -f5)

        echo "$display_line" >> "$tmp_display"
        echo "$file" >> "$tmp_map"
    done <<< "$adr_list"

    # fzf with preview - use line numbers for mapping
    local selected=$(cat "$tmp_display" | \
        nl -v 1 -w 1 -s '|' | \
        fzf --ansi \
            --with-nth=2.. \
            --delimiter='|' \
            --preview="awk -v n={1} 'NR==n' '$tmp_map' | xargs -I{} sh -c 'if command -v bat >/dev/null 2>&1; then bat --style=numbers,grid --color=always --line-range=:50 \"{}\"; else cat \"{}\"; fi'" \
            --preview-window='right:60%:wrap' \
            --header='🔍 Browse ADRs | Enter: Edit | Ctrl-G: Show Graph | Ctrl-/: Toggle Preview | ESC: Exit' \
            --bind="ctrl-g:execute(bash '$SCRIPT_DIR/ai-adr-graph.sh' | less -R)" \
            --bind='ctrl-/:toggle-preview')

    if [[ -n "$selected" ]]; then
        local line_num=$(echo "$selected" | cut -d'|' -f1)
        local file=$(sed -n "${line_num}p" "$tmp_map")

        if [[ -f "$file" ]]; then
            ${EDITOR:-vi} "$file"
        fi
    fi

    rm -f "$tmp_map" "$tmp_display"
}

# Main function
main() {
    local status_filter="all"
    local date_from=""
    local date_to=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -s|--status)
                status_filter="$2"
                shift 2
                ;;
            -d|--date-from)
                date_from="$2"
                shift 2
                ;;
            -t|--date-to)
                date_to="$2"
                shift 2
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                error_color "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done

    info_color "🔍 ADR Browser"
    info_color ""

    browse_adrs "$status_filter" "$date_from" "$date_to"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
