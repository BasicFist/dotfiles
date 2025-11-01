#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Dependency Validation Library
# ═══════════════════════════════════════════════════════════
# Validates required and optional dependencies with version checking

set -euo pipefail

# Required dependencies with minimum versions
declare -A REQUIRED_DEPS=(
    [jq]="1.5"
    [tmux]="2.0"
)

# Optional dependencies (enhance functionality but not required)
declare -A OPTIONAL_DEPS=(
    [fzf]="0.20.0"
    [bat]="0.12.0"
    [dialog]=""
    [whiptail]=""
)

# Check if a command exists and meets version requirements
#
# Args:
#   $1 - Command name
#   $2 - Minimum version (optional)
#
# Returns:
#   0 if dependency is satisfied
#   1 if command not found
#   2 if version too old
#
check_dependency() {
    local cmd="$1"
    local min_version="${2:-}"

    # Check if command exists
    if ! command -v "$cmd" &>/dev/null; then
        return 1
    fi

    # Skip version check if not specified
    [[ -z "$min_version" ]] && return 0

    # Try to get version (different tools use different formats)
    local current_version=""
    case "$cmd" in
        jq)
            current_version=$(jq --version 2>/dev/null | grep -oP 'jq-\K[\d.]+' | head -1)
            ;;
        tmux)
            current_version=$(tmux -V 2>/dev/null | grep -oP 'tmux \K[\d.]+' | head -1)
            ;;
        fzf)
            current_version=$(fzf --version 2>/dev/null | grep -oP '^\K[\d.]+' | head -1)
            ;;
        bat)
            current_version=$(bat --version 2>/dev/null | grep -oP 'bat \K[\d.]+' | head -1)
            ;;
        *)
            # Generic version extraction
            current_version=$("$cmd" --version 2>/dev/null | head -1 | grep -oP '\d+\.\d+(\.\d+)?' | head -1)
            ;;
    esac

    # If we got a version, compare it
    if [[ -n "$current_version" ]]; then
        if ! version_gte "$current_version" "$min_version"; then
            return 2  # Version too old
        fi
    fi

    return 0
}

# Compare versions (semantic versioning)
#
# Args:
#   $1 - Current version
#   $2 - Minimum version
#
# Returns:
#   0 if current >= minimum
#   1 if current < minimum
#
version_gte() {
    local current="$1"
    local minimum="$2"

    # If versions are identical, return success
    [[ "$current" == "$minimum" ]] && return 0

    # Use sort -V for version comparison
    local sorted
    sorted=$(printf '%s\n%s\n' "$minimum" "$current" | sort -V | head -1)

    [[ "$sorted" == "$minimum" ]]
}

# Check all required dependencies
#
# Returns:
#   0 if all dependencies satisfied
#   1 if any required dependency missing or too old
#
check_dependencies() {
    local missing=()
    local old_version=()
    local status=0

    # Check required dependencies
    for dep in "${!REQUIRED_DEPS[@]}"; do
        local min_ver="${REQUIRED_DEPS[$dep]}"
        local check_result=0

        check_dependency "$dep" "$min_ver" || check_result=$?

        case $check_result in
            1)
                missing+=("$dep")
                status=1
                ;;
            2)
                old_version+=("$dep (need $min_ver+)")
                status=1
                ;;
        esac
    done

    # Report missing dependencies
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "❌ Missing required dependencies:" >&2
        for dep in "${missing[@]}"; do
            echo "  - $dep" >&2
        done
        echo "" >&2
        echo "Install with: sudo apt install ${missing[*]}" >&2
    fi

    # Report outdated versions
    if [[ ${#old_version[@]} -gt 0 ]]; then
        echo "⚠️  Outdated dependencies:" >&2
        for dep in "${old_version[@]}"; do
            echo "  - $dep" >&2
        done
        echo "" >&2
        echo "Update with: sudo apt install --upgrade ${old_version[*]%% *}" >&2
    fi

    return $status
}

# Check optional dependencies and report availability
#
# This doesn't fail, just informs about available enhancements
#
check_optional_dependencies() {
    local available=()
    local missing=()

    for dep in "${!OPTIONAL_DEPS[@]}"; do
        local min_ver="${OPTIONAL_DEPS[$dep]}"

        if check_dependency "$dep" "$min_ver"; then
            available+=("$dep")
        else
            missing+=("$dep")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "ℹ️  Optional enhancements available:" >&2
        for dep in "${missing[@]}"; do
            case "$dep" in
                fzf)
                    echo "  - $dep: Fuzzy finding for sessions, KB, modes" >&2
                    ;;
                bat)
                    echo "  - $dep: Syntax highlighting in previews" >&2
                    ;;
                dialog|whiptail)
                    echo "  - $dep: Interactive TUI menus" >&2
                    ;;
                *)
                    echo "  - $dep: Enhanced functionality" >&2
                    ;;
            esac
        done
        echo "" >&2
        echo "Install with: sudo apt install ${missing[*]}" >&2
    fi
}

# Quick check for a single dependency with helpful error message
#
# Args:
#   $1 - Command name
#   $2 - Feature name (for error message)
#
# Returns:
#   0 if dependency exists
#   1 if missing (with error message)
#
# Example:
#   require_command "jq" "JSON processing" || exit 1
#
require_command() {
    local cmd="$1"
    local feature="${2:-$cmd}"

    if ! command -v "$cmd" &>/dev/null; then
        echo "❌ Error: $cmd is required for $feature" >&2
        echo "Install with: sudo apt install $cmd" >&2
        return 1
    fi

    return 0
}

# Export functions for use in other scripts
export -f check_dependency
export -f version_gte
export -f check_dependencies
export -f check_optional_dependencies
export -f require_command

# If sourced with --check flag, run dependency check
if [[ "${BASH_SOURCE[0]}" != "${0}" ]] && [[ "${1:-}" == "--check" ]]; then
    check_dependencies
fi
