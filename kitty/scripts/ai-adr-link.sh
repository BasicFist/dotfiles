#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# ADR (Architecture Decision Record) Linker
# ═══════════════════════════════════════════════════════════
# Links ADRs by status (e.g., supersedes, amends)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/colors.sh"
source "${SCRIPT_DIR}/lib/errors.sh"

ADR_DIR="${ADR_DIR:-${HOME}/.ai-agents/knowledge/decisions}"

# ═══════════════════════════════════════════════════════════
# Helper Functions
# ═══════════════════════════════════════════════════════════

find_adr_by_number() {
    local adr_num="$1"
    local padded
    padded=$(printf "%04d" "$adr_num" 2>/dev/null || echo "$adr_num")
    local pattern="${ADR_DIR}/ADR-${padded}-*.md"

    local files=()
    readarray -t files < <(find "$ADR_DIR" -type f -name "ADR-${padded}-*.md")

    if [[ ${#files[@]} -eq 0 ]]; then
        error_exit "ADR with number $adr_num not found."
    elif [[ ${#files[@]} -gt 1 ]]; then
        error_exit "Multiple ADRs found for number $adr_num. Please resolve manually."
    fi

    echo "${files[0]}"
}

get_adr_info() {
    local filepath="$1"
    if [[ ! -f "$filepath" ]]; then
        echo "unknown|Untitled"
        return
    fi
    local num
    num=$(basename "$filepath" | sed 's/ADR-\([0-9]*\).*/\1/')
    local title
    title=$(grep "^# ADR-" "$filepath" | head -1 | sed 's/.*: //')
    echo "$num|$title"
}

# ═══════════════════════════════════════════════════════════
# Main Logic
# ═══════════════════════════════════════════════════════════

link_adrs() {
    local source_num="$1"
    local link_type="$2"
    local target_num="$3"

    local source_file
    source_file=$(find_adr_by_number "$source_num")
    local target_file
    target_file=$(find_adr_by_number "$target_num")

    local info1
    info1=$(get_adr_info "$source_file")
    local info2
    info2=$(get_adr_info "$target_file")

    local num1
    num1=$(echo "$info1" | cut -d'|' -f1)
    local title1
    title1=$(echo "$info1" | cut -d'|' -f2)
    local num2
    num2=$(echo "$info2" | cut -d'|' -f1)
    local title2
    title2=$(echo "$info2" | cut -d'|' -f2)

    local link_text
    link_text="* This ADR ${link_type} [ADR-${num2}: ${title2}]($(basename "$target_file"))"

    # Add link to source file
    if grep -q "Status" "$source_file"; then
        sed -i "/Status/a \\$link_text" "$source_file"
    else
        echo -e "\n$link_text" >> "$source_file"
    fi

    success_color "Linked ADR-$num1 to ADR-$num2 ($link_type)."
}

show_help() {
    cat << EOF
ADR Linker

Usage: $(basename "$0") <source_adr> <link_type> <target_adr>

Arguments:
  source_adr   Number of the source ADR.
  link_type    Type of link (e.g., 'supersedes', 'amends', 'relates to').
  target_adr   Number of the target ADR.

Example:
  $(basename "$0") 5 'supersedes' 2
EOF
}

# Entry point
main() {
    if [[ "$#" -ne 3 || "$1" == "--help" ]]; then
        show_help
        exit 0
    fi

    if [[ ! -d "$ADR_DIR" ]]; then
        error_exit "ADR directory not found at: $ADR_DIR"
    fi

    link_adrs "$1" "$2" "$3"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
