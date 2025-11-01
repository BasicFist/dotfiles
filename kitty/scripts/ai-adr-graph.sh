#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# ADR Management - Visualize Decision Dependencies
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
Usage: ai-adr-graph.sh [OPTIONS]

Visualize Architecture Decision Record relationships and dependencies.

OPTIONS:
  -f, --format FORMAT   Output format: text (default), dot, mermaid
  -o, --output FILE     Save to file instead of stdout
  -s, --status STATUS   Filter by status (Proposed, Accepted, etc.)
  -h, --help           Show this help message

OUTPUT FORMATS:
  text     - Simple text tree (default)
  dot      - Graphviz DOT format
  mermaid  - Mermaid diagram format

EXAMPLES:
  # Text view
  ai-adr-graph.sh

  # Graphviz format
  ai-adr-graph.sh --format dot | dot -Tpng > adr-graph.png

  # Mermaid format
  ai-adr-graph.sh --format mermaid > adr-graph.mmd

EOF
}

# Parse ADR file for metadata
parse_adr() {
    local filepath="$1"

    local num=$(basename "$filepath" | sed 's/ADR-\([0-9]*\).*/\1/')
    local title=$(grep "^# ADR-" "$filepath" | head -1 | sed 's/.*: //')
    local status=$(grep "^\*\*Status:\*\*" "$filepath" | sed 's/.*: //')
    local supersedes=$(grep "^\*\*Supersedes:\*\*" "$filepath" | sed 's/.*: //')
    local superseded_by=$(grep "^\*\*Superseded by:\*\*" "$filepath" | sed 's/.*: //')

    # Get related decisions
    local related=""
    if grep -q "^## Related Decisions" "$filepath"; then
        related=$(sed -n '/^## Related Decisions$/,/^##/p' "$filepath" | grep "^- ADR-" | sed 's/^- ADR-\([0-9]*\).*/\1/' || echo "")
    fi

    echo "$num|$title|$status|$supersedes|$superseded_by|$related"
}

# Generate text format
generate_text() {
    local filter_status="$1"

    info_color "Architecture Decision Records Relationship Graph"
    info_color "==============================================="
    echo ""

    for file in "$ADR_DIR"/ADR-*.md; do
        if [[ ! -f "$file" ]]; then
            continue
        fi

        local info=$(parse_adr "$file")
        local num=$(echo "$info" | cut -d'|' -f1)
        local title=$(echo "$info" | cut -d'|' -f2)
        local status=$(echo "$info" | cut -d'|' -f3)
        local supersedes=$(echo "$info" | cut -d'|' -f4)
        local superseded_by=$(echo "$info" | cut -d'|' -f5)
        local related=$(echo "$info" | cut -d'|' -f6)

        # Filter by status if specified
        if [[ -n "$filter_status" ]] && [[ "$status" != "$filter_status" ]]; then
            continue
        fi

        # Display ADR
        case "$status" in
            Accepted)
                success_color "📗 ADR-$num: $title [$status]"
                ;;
            Proposed)
                info_color "📘 ADR-$num: $title [$status]"
                ;;
            Superseded)
                warn_color "📙 ADR-$num: $title [$status]"
                ;;
            Deprecated)
                error_color "📕 ADR-$num: $title [$status]"
                ;;
            *)
                echo "📔 ADR-$num: $title [$status]"
                ;;
        esac

        # Show relationships
        if [[ "$supersedes" != "N/A" ]] && [[ -n "$supersedes" ]]; then
            echo "   ├─ Supersedes: $supersedes"
        fi

        if [[ "$superseded_by" != "N/A" ]] && [[ -n "$superseded_by" ]]; then
            echo "   ├─ Superseded by: $superseded_by"
        fi

        if [[ -n "$related" ]]; then
            for rel in $related; do
                echo "   ├─ Related to: ADR-$rel"
            done
        fi

        echo ""
    done
}

# Generate Graphviz DOT format
generate_dot() {
    echo "digraph ADR {"
    echo "  rankdir=LR;"
    echo "  node [shape=box, style=rounded];"
    echo ""

    for file in "$ADR_DIR"/ADR-*.md; do
        if [[ ! -f "$file" ]]; then
            continue
        fi

        local info=$(parse_adr "$file")
        local num=$(echo "$info" | cut -d'|' -f1)
        local title=$(echo "$info" | cut -d'|' -f2)
        local status=$(echo "$info" | cut -d'|' -f3)
        local supersedes=$(echo "$info" | cut -d'|' -f4)
        local superseded_by=$(echo "$info" | cut -d'|' -f5)
        local related=$(echo "$info" | cut -d'|' -f6)

        # Node with color based on status
        local color="lightblue"
        case "$status" in
            Accepted) color="lightgreen" ;;
            Superseded) color="lightyellow" ;;
            Deprecated) color="lightcoral" ;;
        esac

        echo "  ADR$num [label=\"ADR-$num\\n$title\", fillcolor=\"$color\", style=filled];"

        # Edges
        if [[ "$supersedes" =~ ADR-([0-9]+) ]]; then
            local old_num="${BASH_REMATCH[1]}"
            echo "  ADR$num -> ADR$old_num [label=\"supersedes\", style=bold, color=red];"
        fi

        if [[ -n "$related" ]]; then
            for rel in $related; do
                echo "  ADR$num -> ADR$rel [label=\"relates\", style=dashed];"
            done
        fi
    done

    echo "}"
}

# Generate Mermaid format
generate_mermaid() {
    echo "graph LR"

    for file in "$ADR_DIR"/ADR-*.md; do
        if [[ ! -f "$file" ]]; then
            continue
        fi

        local info=$(parse_adr "$file")
        local num=$(echo "$info" | cut -d'|' -f1)
        local title=$(echo "$info" | cut -d'|' -f2)
        local status=$(echo "$info" | cut -d'|' -f3)
        local supersedes=$(echo "$info" | cut -d'|' -f4)
        local related=$(echo "$info" | cut -d'|' -f6)

        # Clean title for Mermaid
        local clean_title=$(echo "$title" | tr ' ' '_' | tr -cd '[:alnum:]_')

        echo "  ADR$num[$clean_title]"

        # Edges
        if [[ "$supersedes" =~ ADR-([0-9]+) ]]; then
            local old_num="${BASH_REMATCH[1]}"
            echo "  ADR$num -->|supersedes| ADR$old_num"
        fi

        if [[ -n "$related" ]]; then
            for rel in $related; do
                echo "  ADR$num -.->|relates| ADR$rel"
            done
        fi
    done
}

# Main function
main() {
    local format="text"
    local output=""
    local filter_status=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -f|--format)
                format="$2"
                shift 2
                ;;
            -o|--output)
                output="$2"
                shift 2
                ;;
            -s|--status)
                filter_status="$2"
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

    # Check ADR directory
    if [[ ! -d "$ADR_DIR" ]] || [[ -z "$(ls -A "$ADR_DIR"/ADR-*.md 2>/dev/null)" ]]; then
        warn_color "⚠️  No ADRs found in $ADR_DIR"
        exit 0
    fi

    # Generate graph
    local graph_output=""
    case "$format" in
        text)
            graph_output=$(generate_text "$filter_status")
            ;;
        dot)
            graph_output=$(generate_dot)
            ;;
        mermaid)
            graph_output=$(generate_mermaid)
            ;;
        *)
            error_color "❌ Unknown format: $format"
            usage
            exit 1
            ;;
    esac

    # Output
    if [[ -n "$output" ]]; then
        echo "$graph_output" > "$output"
        success_color "✅ Graph saved to: $output"
    else
        echo "$graph_output"
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
