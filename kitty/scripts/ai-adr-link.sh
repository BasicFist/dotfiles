#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# ADR Management - Link Related Architecture Decision Records
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
Usage: ai-adr-link.sh ADR1 ADR2 [RELATIONSHIP]

Create a bidirectional link between two ADRs.

ARGUMENTS:
  ADR1          First ADR number (e.g., 0001 or 1)
  ADR2          Second ADR number (e.g., 0005 or 5)
  RELATIONSHIP  Link type (optional, default: "relates to")

RELATIONSHIP TYPES:
  relates-to    - General relationship (default)
  depends-on    - ADR1 depends on ADR2
  conflicts     - ADR1 conflicts with ADR2
  extends       - ADR1 extends ADR2

EFFECTS:
  - Adds ADR2 to ADR1's "Related Decisions" section
  - Adds ADR1 to ADR2's "Related Decisions" section
  - Bidirectional link maintained

EXAMPLES:
  # Simple link
  ai-adr-link.sh 1 5

  # Dependency link
  ai-adr-link.sh 3 2 depends-on

EOF
}

# Find ADR file by number
find_adr_file() {
    local adr_num="$1"
    local padded=$(printf "%04d" "$adr_num" 2>/dev/null || echo "$adr_num")
    local pattern="$ADR_DIR/ADR-${padded}*.md"
    local files=($pattern)

    if [[ ${#files[@]} -eq 0 ]] || [[ ! -f "${files[0]}" ]]; then
        error_color "❌ ADR-$padded not found"
        return 1
    fi

    echo "${files[0]}"
}

# Get ADR number and title
get_adr_info() {
    local filepath="$1"
    local num=$(basename "$filepath" | sed 's/ADR-\([0-9]*\).*/\1/')
    local title=$(grep "^# ADR-" "$filepath" | head -1 | sed 's/.*: //')
    echo "$num|$title"
}

# Add related decision
add_related_decision() {
    local filepath="$1"
    local related_num="$2"
    local related_title="$3"
    local relationship="$4"

    # Check if already linked
    if grep -q "ADR-$related_num" "$filepath"; then
        warn_color "⚠️  Link already exists in $(basename "$filepath")"
        return 0
    fi

    # Find "Related Decisions" section and add entry
    if grep -q "^## Related Decisions" "$filepath"; then
        # Add after the section header
        sed -i.bak "/^## Related Decisions$/a - ADR-$related_num: $related_title ($relationship)" "$filepath"
        rm -f "${filepath}.bak"
    else
        error_color "❌ Related Decisions section not found"
        return 1
    fi
}

# Main function
main() {
    if [[ $# -lt 2 ]]; then
        usage
        exit 1
    fi

    local adr1="$1"
    local adr2="$2"
    local relationship="${3:-relates-to}"

    # Validate relationship
    case "$relationship" in
        relates-to|depends-on|conflicts|extends)
            ;;
        *)
            warn_color "⚠️  Unknown relationship: $relationship (using 'relates-to')"
            relationship="relates-to"
            ;;
    esac

    # Find both files
    local file1
    local file2

    if ! file1=$(find_adr_file "$adr1"); then
        exit 1
    fi

    if ! file2=$(find_adr_file "$adr2"); then
        exit 1
    fi

    # Get info
    local info1=$(get_adr_info "$file1")
    local info2=$(get_adr_info "$file2")

    local num1=$(echo "$info1" | cut -d'|' -f1)
    local title1=$(echo "$info1" | cut -d'|' -f2)
    local num2=$(echo "$info2" | cut -d'|' -f1)
    local title2=$(echo "$info2" | cut -d'|' -f2)

    info_color "Linking ADR-$num1 ↔ ADR-$num2 ($relationship)"

    # Create bidirectional links
    add_related_decision "$file1" "$num2" "$title2" "$relationship"
    add_related_decision "$file2" "$num1" "$title1" "$relationship"

    success_color ""
    success_color "✅ Link created successfully!"
    info_color "   ADR-$num1: $title1"
    info_color "   ADR-$num2: $title2"
    info_color "   Relationship: $relationship"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
