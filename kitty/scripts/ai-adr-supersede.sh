#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# ADR Management - Supersede Architecture Decision Record
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
Usage: ai-adr-supersede.sh OLD_ADR NEW_ADR

Mark an ADR as superseded by another ADR.

ARGUMENTS:
  OLD_ADR    ADR number being superseded (e.g., 0001 or 1)
  NEW_ADR    ADR number that supersedes it (e.g., 0005 or 5)

EFFECTS:
  - Sets OLD_ADR status to "Superseded"
  - Updates OLD_ADR "Superseded by" field
  - Updates NEW_ADR "Supersedes" field
  - Bidirectional link maintained

EXAMPLES:
  # ADR-0005 supersedes ADR-0001
  ai-adr-supersede.sh 1 5

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

# Get ADR number from file
get_adr_number() {
    local filepath="$1"
    basename "$filepath" | sed 's/ADR-\([0-9]*\).*/\1/'
}

# Main function
main() {
    if [[ $# -lt 2 ]]; then
        usage
        exit 1
    fi

    local old_adr="$1"
    local new_adr="$2"

    # Find both files
    local old_file
    local new_file

    if ! old_file=$(find_adr_file "$old_adr"); then
        exit 1
    fi

    if ! new_file=$(find_adr_file "$new_adr"); then
        exit 1
    fi

    local old_num=$(get_adr_number "$old_file")
    local new_num=$(get_adr_number "$new_file")

    info_color "Superseding ADR-$old_num with ADR-$new_num"

    # Update old ADR
    sed -i.bak "s/^\*\*Status:\*\* .*$/\*\*Status:\*\* Superseded/" "$old_file"
    sed -i.bak "s/^\*\*Superseded by:\*\* .*$/\*\*Superseded by:\*\* ADR-$new_num/" "$old_file"
    rm -f "${old_file}.bak"

    # Update new ADR
    sed -i.bak "s/^\*\*Supersedes:\*\* .*$/\*\*Supersedes:\*\* ADR-$old_num/" "$new_file"
    rm -f "${new_file}.bak"

    success_color ""
    success_color "✅ Supersession complete!"
    info_color "   Old ADR: $(basename "$old_file") → Status: Superseded"
    info_color "   New ADR: $(basename "$new_file") → Supersedes: ADR-$old_num"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
