#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Centralized Configuration Constants
# ═══════════════════════════════════════════════════════════
# Central location for all configuration values used across
# AI Agents scripts. Modify values here to change behavior
# across the entire system.
#
# Usage:
#   source "${SCRIPT_DIR}/lib/constants.sh"
#   echo "$AI_AGENTS_SESSION_DEFAULT"

# Prevent re-sourcing (constants are readonly)
[[ -n "${AI_AGENTS_CONSTANTS_LOADED:-}" ]] && return 0
readonly AI_AGENTS_CONSTANTS_LOADED=true

set -euo pipefail

# ═══════════════════════════════════════════════════════════
# Session Configuration
# ═══════════════════════════════════════════════════════════

# Default session name (can be overridden by KITTY_AI_SESSION env var)
readonly AI_AGENTS_SESSION_DEFAULT="ai-agents"

# Session name (respects environment variable)
readonly AI_AGENTS_SESSION="${KITTY_AI_SESSION:-${AI_AGENTS_SESSION_DEFAULT}}"

# ═══════════════════════════════════════════════════════════
# Paths & Directories
# ═══════════════════════════════════════════════════════════

# Knowledge Base root directory (can be overridden by AI_AGENTS_KB_ROOT env var)
readonly AI_AGENTS_KB_ROOT="${AI_AGENTS_KB_ROOT:-$HOME/.ai-agents}"

# Subdirectories within KB root
readonly AI_AGENTS_KB_DIR="${AI_AGENTS_KB_ROOT}/knowledge"
readonly AI_AGENTS_SNAPSHOTS_DIR="${AI_AGENTS_KB_ROOT}/snapshots"
readonly AI_AGENTS_SESSIONS_DIR="${AI_AGENTS_KB_ROOT}/sessions"
readonly AI_AGENTS_LESSONS_DIR="${AI_AGENTS_KB_ROOT}/lessons"

# Temporary directories
readonly AI_AGENTS_TMP_ROOT="/tmp"
readonly AI_AGENTS_MODE_DIR="${AI_AGENTS_TMP_ROOT}/ai-mode-${AI_AGENTS_SESSION}"
readonly AI_AGENTS_SHARED_FILE="${AI_AGENTS_TMP_ROOT}/ai-agents-shared.txt"

# Lock files directory
readonly AI_AGENTS_LOCK_DIR="${AI_AGENTS_TMP_ROOT}/ai-agents-locks"

# ═══════════════════════════════════════════════════════════
# Mode State Files
# ═══════════════════════════════════════════════════════════

# Mode-specific state file paths
# Core modes (useful)
readonly AI_AGENTS_STATE_PAIR="${AI_AGENTS_MODE_DIR}/pair-programming.json"
readonly AI_AGENTS_STATE_CODE_REVIEW="${AI_AGENTS_MODE_DIR}/code-review.json"
readonly AI_AGENTS_STATE_DEBUG="${AI_AGENTS_MODE_DIR}/debug.json"
readonly AI_AGENTS_STATE_BRAINSTORM="${AI_AGENTS_MODE_DIR}/brainstorm.json"

# Legacy modes (less practical, kept for compatibility)
readonly AI_AGENTS_STATE_DEBATE="${AI_AGENTS_MODE_DIR}/debate.json"
readonly AI_AGENTS_STATE_TEACHING="${AI_AGENTS_MODE_DIR}/teaching.json"
readonly AI_AGENTS_STATE_CONSENSUS="${AI_AGENTS_MODE_DIR}/consensus.json"
readonly AI_AGENTS_STATE_COMPETITION="${AI_AGENTS_MODE_DIR}/competition.json"

# ═══════════════════════════════════════════════════════════
# File Extensions & Formats
# ═══════════════════════════════════════════════════════════

readonly AI_AGENTS_JSON_EXT=".json"
readonly AI_AGENTS_MD_EXT=".md"
readonly AI_AGENTS_LOG_EXT=".log"

# ═══════════════════════════════════════════════════════════
# Timeouts & Intervals (in seconds)
# ═══════════════════════════════════════════════════════════

# Lock acquisition timeouts
readonly AI_AGENTS_LOCK_TIMEOUT_READ=5
readonly AI_AGENTS_LOCK_TIMEOUT_WRITE=10
readonly AI_AGENTS_LOCK_TIMEOUT_DEFAULT=10

# Mode-specific intervals
readonly AI_AGENTS_PAIR_SWITCH_INTERVAL=1800  # 30 minutes

# General timeouts
readonly AI_AGENTS_COMMAND_TIMEOUT=120  # 2 minutes
readonly AI_AGENTS_NETWORK_TIMEOUT=30   # 30 seconds

# ═══════════════════════════════════════════════════════════
# Agent Names & Identifiers
# ═══════════════════════════════════════════════════════════

readonly AI_AGENTS_AGENT1="Agent1"
readonly AI_AGENTS_AGENT2="Agent2"
readonly AI_AGENTS_SYSTEM="System"

# ═══════════════════════════════════════════════════════════
# File Permissions
# ═══════════════════════════════════════════════════════════

readonly AI_AGENTS_FILE_PERMS_PRIVATE=600  # Owner read/write only
readonly AI_AGENTS_FILE_PERMS_PUBLIC=644   # Owner RW, others read
readonly AI_AGENTS_DIR_PERMS_PRIVATE=700   # Owner full access only
readonly AI_AGENTS_DIR_PERMS_PUBLIC=755    # Owner full, others read/exec

# ═══════════════════════════════════════════════════════════
# Defaults & Limits
# ═══════════════════════════════════════════════════════════

# Maximum file sizes
readonly AI_AGENTS_MAX_LOG_SIZE_MB=100
readonly AI_AGENTS_MAX_KB_ENTRY_SIZE_MB=10

# Backup settings
readonly AI_AGENTS_BACKUP_KEEP_COUNT=5

# UI/Display settings
readonly AI_AGENTS_DIALOG_HEIGHT=20
readonly AI_AGENTS_DIALOG_WIDTH=70
readonly AI_AGENTS_MENU_HEIGHT=12

# ═══════════════════════════════════════════════════════════
# Helper Functions
# ═══════════════════════════════════════════════════════════

# Get mode-specific state file path
# Args:
#   $1 - Mode name (pair, debate, teaching, consensus, competition)
# Returns:
#   Path to mode state file
get_mode_state_path() {
    local mode="$1"

    case "$mode" in
        pair|pairing|pair-programming)
            echo "$AI_AGENTS_STATE_PAIR"
            ;;
        debate|discuss|discussion)
            echo "$AI_AGENTS_STATE_DEBATE"
            ;;
        teach|teaching)
            echo "$AI_AGENTS_STATE_TEACHING"
            ;;
        consensus)
            echo "$AI_AGENTS_STATE_CONSENSUS"
            ;;
        compete|competition)
            echo "$AI_AGENTS_STATE_COMPETITION"
            ;;
        *)
            echo "${AI_AGENTS_MODE_DIR}/${mode}.json"
            ;;
    esac
}

# Ensure required directories exist
# Creates all necessary directories with proper permissions
ensure_directories() {
    # KB directories
    mkdir -p "$AI_AGENTS_KB_ROOT" 2>/dev/null || true
    mkdir -p "$AI_AGENTS_KB_DIR" 2>/dev/null || true
    mkdir -p "$AI_AGENTS_SNAPSHOTS_DIR" 2>/dev/null || true
    mkdir -p "$AI_AGENTS_SESSIONS_DIR" 2>/dev/null || true
    mkdir -p "$AI_AGENTS_LESSONS_DIR" 2>/dev/null || true

    # Temp directories
    mkdir -p "$AI_AGENTS_MODE_DIR" 2>/dev/null || true
    mkdir -p "$AI_AGENTS_LOCK_DIR" 2>/dev/null || true

    # Set permissions
    chmod "$AI_AGENTS_DIR_PERMS_PRIVATE" "$AI_AGENTS_KB_ROOT" 2>/dev/null || true
    chmod "$AI_AGENTS_DIR_PERMS_PRIVATE" "$AI_AGENTS_MODE_DIR" 2>/dev/null || true
    chmod "$AI_AGENTS_DIR_PERMS_PUBLIC" "$AI_AGENTS_LOCK_DIR" 2>/dev/null || true
}

# Export constants (readonly variables are automatically inherited)
# Export helper functions
export -f get_mode_state_path
export -f ensure_directories

# ═══════════════════════════════════════════════════════════
# Self-test when run directly
# ═══════════════════════════════════════════════════════════

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "AI Agents Configuration Constants"
    echo "═════════════════════════════════════"
    echo ""
    echo "Session:"
    echo "  Default:  $AI_AGENTS_SESSION_DEFAULT"
    echo "  Current:  $AI_AGENTS_SESSION"
    echo ""
    echo "Paths:"
    echo "  KB Root:     $AI_AGENTS_KB_ROOT"
    echo "  Knowledge:   $AI_AGENTS_KB_DIR"
    echo "  Snapshots:   $AI_AGENTS_SNAPSHOTS_DIR"
    echo "  Mode Dir:    $AI_AGENTS_MODE_DIR"
    echo "  Shared File: $AI_AGENTS_SHARED_FILE"
    echo ""
    echo "Timeouts:"
    echo "  Lock Read:   ${AI_AGENTS_LOCK_TIMEOUT_READ}s"
    echo "  Lock Write:  ${AI_AGENTS_LOCK_TIMEOUT_WRITE}s"
    echo "  Command:     ${AI_AGENTS_COMMAND_TIMEOUT}s"
    echo ""
    echo "Mode State Files:"
    echo "  Pair:        $AI_AGENTS_STATE_PAIR"
    echo "  Debate:      $AI_AGENTS_STATE_DEBATE"
    echo "  Teaching:    $AI_AGENTS_STATE_TEACHING"
    echo "  Consensus:   $AI_AGENTS_STATE_CONSENSUS"
    echo "  Competition: $AI_AGENTS_STATE_COMPETITION"
    echo ""
    echo "Helper function test:"
    echo "  get_mode_state_path 'pair': $(get_mode_state_path 'pair')"
    echo "  get_mode_state_path 'debate': $(get_mode_state_path 'debate')"
fi
