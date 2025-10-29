#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# AI Agents Knowledge Base - Search
# ═══════════════════════════════════════════════════════════

set -euo pipefail

KB_ROOT="${AI_AGENTS_KB_ROOT:-$HOME/.ai-agents}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/colors.sh"

usage() {
    cat <<EOF
Usage: ai-kb-search.sh <query> [--type TYPE] [--tag TAG]

Arguments:
  query        Search term (searches title and content)

Options:
  --type TYPE  Filter by type (doc, snippet, decision, pattern)
  --tag TAG    Filter by tag

Examples:
  ai-kb-search.sh "async"
  ai-kb-search.sh "database" --type decision
  ai-kb-search.sh "python" --tag coding
EOF
}

if [[ $# -lt 1 ]]; then
    usage
    exit 1
fi

QUERY="$1"
shift

FILTER_TYPE=""
FILTER_TAG=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --type)
            FILTER_TYPE="$2"
            shift 2
            ;;
        --tag)
            FILTER_TAG="$2"
            shift 2
            ;;
        *)
            error_color "Unknown option: $1"
            exit 1
            ;;
    esac
done

if [[ ! -d "$KB_ROOT" ]]; then
    error_color "Knowledge base not initialized. Run: ai-knowledge-init.sh"
    exit 1
fi

info_color "🔍 Searching knowledge base for: '$QUERY'"
[[ -n "$FILTER_TYPE" ]] && info_color "  Type filter: $FILTER_TYPE"
[[ -n "$FILTER_TAG" ]] && info_color "  Tag filter: $FILTER_TAG"
echo ""

FOUND=0

# Search in all knowledge directories
for TYPE_DIR in docs code-snippets decisions patterns; do
    # Skip if type filter doesn't match
    if [[ -n "$FILTER_TYPE" ]] && [[ "$TYPE_DIR" != *"$FILTER_TYPE"* ]]; then
        continue
    fi

    DIR="$KB_ROOT/knowledge/$TYPE_DIR"
    if [[ ! -d "$DIR" ]]; then
        continue
    fi

    for FILE in "$DIR"/*; do
        if [[ ! -f "$FILE" ]]; then
            continue
        fi

        # Check tag filter
        if [[ -n "$FILTER_TAG" ]]; then
            if ! grep -q "tags:.*$FILTER_TAG" "$FILE" 2>/dev/null; then
                continue
            fi
        fi

        # Check if query matches
        if grep -qi "$QUERY" "$FILE" 2>/dev/null; then
            FOUND=$((FOUND + 1))

            # Extract metadata
            TITLE=$(grep "^title:" "$FILE" | head -1 | cut -d: -f2- | xargs)
            TAGS=$(grep "^tags:" "$FILE" | head -1 | cut -d: -f2- | xargs)
            CREATED=$(grep "^created:" "$FILE" | head -1 | cut -d: -f2- | xargs)

            echo -e "$(success_color "[$TYPE_DIR]") $(agent1_color "$TITLE")"
            echo "  File: $(basename "$FILE")"
            echo "  Tags: $TAGS"
            echo "  Created: $CREATED"

            # Show matching lines (first 3)
            echo "  Matches:"
            grep -i -n "$QUERY" "$FILE" | head -3 | while read -r line; do
                echo "    $line"
            done
            echo ""
        fi
    done
done

if [[ $FOUND -eq 0 ]]; then
    warning_color "No entries found matching: '$QUERY'"
else
    success_color "✅ Found $FOUND matching entries"
fi
