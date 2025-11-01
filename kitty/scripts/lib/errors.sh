#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Error Handling Library for AI Agents
# ═══════════════════════════════════════════════════════════

set -euo pipefail

# Source color library if available
_ERRORS_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "${_ERRORS_LIB_DIR}/colors.sh" ]]; then
    source "${_ERRORS_LIB_DIR}/colors.sh"
fi

# Default color functions if not defined
if ! declare -f error_color >/dev/null 2>&1; then
    error_color() { echo -e "\033[0;31m$*\033[0m" >&2; }
fi

if ! declare -f warning_color >/dev/null 2>&1; then
    warning_color() { echo -e "\033[0;33m$*\033[0m" >&2; }
fi

if ! declare -f info_color >/dev/null 2>&1; then
    info_color() { echo -e "\033[0;36m$*\033[0m"; }
fi

# Log error messages to stderr with timestamp
log_error() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    error_color "[$timestamp] ERROR: $message" >&2
}

# Log warning messages
log_warning() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    warning_color "[$timestamp] WARNING: $message" >&2
}

# Log info messages
log_info() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    info_color "[$timestamp] INFO: $message"
}

# Safely exit with cleanup
safe_exit() {
    local exit_code="${1:-0}"
    local message="${2:-}"
    
    if [[ -n "$message" ]]; then
        if [[ $exit_code -eq 0 ]]; then
            log_info "$message"
        else
            log_error "$message"
        fi
    fi
    
    # Cleanup temporary files if they exist
    if [[ -n "${TEMP_FILES:-}" ]]; then
        rm -f $TEMP_FILES 2>/dev/null || true
    fi
    
    exit $exit_code
}

# Sanitize input to prevent command injection
sanitize_input() {
    local input="$1"
    
    # Remove dangerous characters
    local sanitized="${input//[^a-zA-Z0-9_.@:\/\\ ()-]/}"
    
    # Additional validation for specific patterns
    if [[ "$sanitized" =~ \.\./  ]] || [[ "$sanitized" =~ \$ ]] || [[ "$sanitized" =~ \; ]] || [[ "$sanitized" =~ \` ]] || [[ "$sanitized" =~ \| ]] || [[ "$sanitized" =~ \& ]]; then
        log_error "Potentially dangerous input detected: $input"
        safe_exit 1 "Invalid input parameter"
    fi
    
    echo "$sanitized"
}

# Validate file paths to prevent directory traversal
validate_path() {
    local path="$1"
    local base_dir="${2:-$HOME}"
    
    # Resolve to absolute path
    local abs_path
    if [[ "$path" == /* ]]; then
        abs_path="$path"
    else
        abs_path="$(realpath "$base_dir/$path" 2>/dev/null)" || {
            log_error "Invalid path: $path"
            return 1
        }
    fi
    
    # Check if path is within allowed directory
    if [[ ! "$abs_path" =~ ^"$base_dir" ]]; then
        log_error "Path traversal attempt detected: $path"
        return 1
    fi
    
    # Check if file exists (if required)
    if [[ "${3:-}" == "must_exist" ]] && [[ ! -e "$abs_path" ]]; then
        log_error "File not found: $abs_path"
        return 1
    fi
    
    echo "$abs_path"
    return 0
}

# Export functions
export -f log_error
export -f log_warning
export -f log_info
export -f safe_exit
export -f sanitize_input
export -f validate_path
