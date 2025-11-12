#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Shared Utility Functions for Kitty Scripts
# ═══════════════════════════════════════════════════════════
# Common functions used across multiple Kitty utility scripts.
# Source this file to access shared functionality.

# Validate that a path is safe (doesn't contain dangerous patterns)
# Args:
#   $1: Path to validate
# Returns: 0 if safe, 1 if unsafe
validate_path() {
    local path="$1"

    # Check for dangerous patterns
    if [[ "$path" =~ \.\.\/ || "$path" =~ \.\.\\ || "$path" =~ \$\( || "$path" =~ \` ]]; then
        return 1
    fi

    # Resolve to absolute path to prevent traversal
    local abs_path
    abs_path="$(realpath -q "$path" 2>/dev/null)" || return 1

    # Ensure path is under expected root (HOME, /tmp for ai-agents, or /app for sandbox)
    if [[ "$abs_path" != "$HOME"* && "$abs_path" != "/tmp/ai-agents"* && "$abs_path" != "/app"* ]]; then
        return 1
    fi

    return 0
}

# Display a temporary notification in the window title bar
# Args:
#   $1: Message to display
#   $2: Duration in seconds (default: 2)
# Returns: None (runs in background)
notify_title() {
    local message="$1"
    local duration="${2:-2}"
    (
        kitty @ set-window-title "$message" 2>/dev/null || true
        sleep "$duration"
        kitty @ set-window-title --reset 2>/dev/null || true
    ) &
}

# Export functions so they're available to sourcing scripts
export -f validate_path
export -f notify_title
