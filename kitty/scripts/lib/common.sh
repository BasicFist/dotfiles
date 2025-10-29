#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Shared Utility Functions for Kitty Scripts
# ═══════════════════════════════════════════════════════════
# Common functions used across multiple Kitty utility scripts.
# Source this file to access shared functionality.

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
export -f notify_title
