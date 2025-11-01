#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# ADR Management - Update Architecture Decision Record
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
Usage: ai-adr-update.sh ADR_NUMBER [OPTIONS]

Update an existing Architecture Decision Record.

ARGUMENTS:
  ADR_NUMBER              ADR number to update (e.g., 0001 or 1)

OPTIONS:
  -s, --status STATUS     Update status (Proposed|Accepted|Deprecated|Superseded)
  -r, --reference REF     Add reference link
  -d, --decision-maker NAME  Add decision maker
  -h, --help             Show this help message

VALID STATUSES:
  Proposed    - Initial proposal, under review
  Accepted    - Decision approved and active
  Deprecated  - No longer recommended but not superseded
  Superseded  - Replaced by another ADR

EXAMPLES:
  # Update status
  ai-adr-update.sh 1 --status Accepted

  # Add reference
  ai-adr-update.sh 0001 --reference "https://docs.example.com/arch"

  # Add decision maker
  ai-adr-update.sh 1 --decision-maker "Alice, Bob"

EOF
}

# Find ADR file by number
find_adr_file() {
    local adr_num="$1"

    # Pad number to 4 digits
    local padded=$(printf "%04d" "$adr_num" 2>/dev/null || echo "$adr_num")

    # Search for file
    local pattern="$ADR_DIR/ADR-${padded}*.md"
    local files=($pattern)

    if [[ ${#files[@]} -eq 0 ]] || [[ ! -f "${files[0]}" ]]; then
        error_color "❌ ADR-$padded not found in $ADR_DIR"
        return 1
    fi

    echo "${files[0]}"
}

# Update status in ADR file
update_status() {
    local filepath="$1"
    local new_status="$2"

    # Validate status
    case "$new_status" in
        Proposed|Accepted|Deprecated|Superseded)
            ;;
        *)
            error_color "❌ Invalid status: $new_status"
            error_color "   Valid: Proposed, Accepted, Deprecated, Superseded"
            return 1
            ;;
    esac

    # Update file
    sed -i.bak "s/^\*\*Status:\*\* .*$/\*\*Status:\*\* $new_status/" "$filepath"

    # Also update date
    sed -i.bak "s/^\*\*Date:\*\* .*$/\*\*Date:\*\* $(date +%Y-%m-%d) (updated)/" "$filepath"

    rm -f "${filepath}.bak"

    success_color "✅ Status updated to: $new_status"
}

# Add reference to ADR file
add_reference() {
    local filepath="$1"
    local reference="$2"

    # Find References section and add entry
    if grep -q "^## References" "$filepath"; then
        # Add before the closing line
        sed -i.bak "/^---$/i - $reference" "$filepath"
        rm -f "${filepath}.bak"
        success_color "✅ Reference added: $reference"
    else
        error_color "❌ References section not found"
        return 1
    fi
}

# Add decision maker
add_decision_maker() {
    local filepath="$1"
    local maker="$2"

    # Get current decision makers
    local current=$(grep "^\*\*Decision Makers:\*\*" "$filepath" | sed 's/.*: //')

    # Append new maker
    if [[ "$current" == "$(whoami)" ]] || [[ "$current" == *"$maker"* ]]; then
        local new_makers="$current"
    else
        local new_makers="$current, $maker"
    fi

    sed -i.bak "s/^\*\*Decision Makers:\*\* .*$/\*\*Decision Makers:\*\* $new_makers/" "$filepath"
    rm -f "${filepath}.bak"

    success_color "✅ Decision maker added: $maker"
}

# Main function
main() {
    if [[ $# -eq 0 ]]; then
        usage
        exit 1
    fi

    local adr_number="$1"
    shift

    # Find ADR file
    local filepath
    if ! filepath=$(find_adr_file "$adr_number"); then
        exit 1
    fi

    info_color "Updating: $(basename "$filepath")"

    # Parse options
    local updated=false
    while [[ $# -gt 0 ]]; do
        case $1 in
            -s|--status)
                update_status "$filepath" "$2"
                updated=true
                shift 2
                ;;
            -r|--reference)
                add_reference "$filepath" "$2"
                updated=true
                shift 2
                ;;
            -d|--decision-maker)
                add_decision_maker "$filepath" "$2"
                updated=true
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

    if [[ "$updated" == "false" ]]; then
        error_color "❌ No updates specified"
        usage
        exit 1
    fi

    info_color ""
    info_color "File: $filepath"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
