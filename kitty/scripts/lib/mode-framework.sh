#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Mode Framework - Shared Initialization for Collaboration Modes
# ═══════════════════════════════════════════════════════════
# Provides common functions for initializing and managing AI agent
# collaboration modes, eliminating duplication across mode scripts.
#
# Functions:
#   mode_init           - Initialize mode with state and protocol
#   mode_announce       - Send announcements to agents
#   mode_show_commands  - Display available commands
#   mode_get_state_path - Get state file path for mode
#
# Usage:
#   source "${SCRIPT_DIR}/../lib/mode-framework.sh"
#   mode_init "pair" "$STATE_JSON" "protocols/pair-protocol.txt"

set -euo pipefail

# Source dependencies
_MODE_FRAMEWORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${_MODE_FRAMEWORK_DIR}/constants.sh"
source "${_MODE_FRAMEWORK_DIR}/colors.sh"
source "${_MODE_FRAMEWORK_DIR}/json-utils.sh"

# ───────────────────────────────────────────────────────────
# Get state file path for a mode
# ───────────────────────────────────────────────────────────
# Args:
#   $1 - Mode name (pair|debate|teach|consensus|compete)
# Returns:
#   Prints state file path on stdout
#   Returns 0 on success, 1 if invalid mode
# Example:
#   state_path=$(mode_get_state_path "pair")
# ───────────────────────────────────────────────────────────
mode_get_state_path() {
    local mode_name="$1"

    case "$mode_name" in
        # Core practical modes
        pair|pair-programming)
            echo "$AI_AGENTS_STATE_PAIR"
            ;;
        code-review|review)
            echo "$AI_AGENTS_STATE_CODE_REVIEW"
            ;;
        debug|debugging)
            echo "$AI_AGENTS_STATE_DEBUG"
            ;;
        brainstorm|ideas)
            echo "$AI_AGENTS_STATE_BRAINSTORM"
            ;;
        # Legacy modes (kept for compatibility)
        debate|discussion)
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
            echo "❌ Unknown mode: $mode_name" >&2
            echo "   Core modes: pair, code-review, debug, brainstorm" >&2
            echo "   Legacy modes: debate, teach, consensus, compete" >&2
            return 1
            ;;
    esac

    return 0
}

# ───────────────────────────────────────────────────────────
# Initialize collaboration mode
# ───────────────────────────────────────────────────────────
# Args:
#   $1 - Mode name (pair|debate|teach|consensus|compete)
#   $2 - JSON state object (as string)
#   $3 - (Optional) Path to protocol file (relative to scripts/)
# Returns:
#   0 on success, 1 on failure
# Example:
#   STATE_JSON='{"mode":"pair","driver":"Agent1"}'
#   mode_init "pair" "$STATE_JSON" "protocols/pair-protocol.txt"
# ───────────────────────────────────────────────────────────
mode_init() {
    local mode_name="$1"
    local state_json="$2"
    local protocol_file="${3:-}"

    # Ensure state directory exists
    ensure_directories

    # Get state file path
    local state_file
    if ! state_file=$(mode_get_state_path "$mode_name"); then
        error_color "❌ Failed to get state path for mode: $mode_name"
        return 1
    fi

    # Create state file with validation
    if ! json_create "$state_file" "$state_json"; then
        error_color "❌ Failed to create mode state file"
        error_color "   Mode: $mode_name"
        error_color "   File: $state_file"
        return 1
    fi

    # Clear shared communication file
    if ! truncate -s 0 "$AI_AGENTS_SHARED_FILE" 2>/dev/null; then
        error_color "⚠️  Warning: Could not clear shared file"
        # Continue anyway - not fatal
        > "$AI_AGENTS_SHARED_FILE" 2>/dev/null || true
    fi

    # Display protocol if provided
    if [[ -n "$protocol_file" ]]; then
        local full_protocol_path

        # Handle both absolute and relative paths
        if [[ "$protocol_file" = /* ]]; then
            full_protocol_path="$protocol_file"
        else
            # Relative to scripts directory
            full_protocol_path="${_MODE_FRAMEWORK_DIR}/../$protocol_file"
        fi

        if [[ -f "$full_protocol_path" ]]; then
            cat "$full_protocol_path" >> "$AI_AGENTS_SHARED_FILE"
        else
            warning_color "⚠️  Protocol file not found: $full_protocol_path"
            # Not fatal - continue without protocol
        fi
    fi

    return 0
}

# ───────────────────────────────────────────────────────────
# Send announcement to agent or shared pane
# ───────────────────────────────────────────────────────────
# Args:
#   $1 - Agent/target (Agent1|Agent2|Shared|System)
#   $2 - Message type (INFO|TASK|RESULT|WARNING|ERROR)
#   $3 - Message content
#   $4+ - Optional flags (--notify, --blink)
# Returns:
#   0 on success, 1 on failure
# Example:
#   mode_announce "Agent1" "INFO" "You are the driver" --notify
#   mode_announce "System" "INFO" "Mode started"
# ───────────────────────────────────────────────────────────
mode_announce() {
    local target="$1"
    local msg_type="$2"
    local message="$3"
    shift 3
    local flags=("$@")

    # Path to send-enhanced script
    local send_script="${_MODE_FRAMEWORK_DIR}/../ai-agent-send-enhanced.sh"

    if [[ ! -x "$send_script" ]]; then
        error_color "❌ Send script not found or not executable: $send_script"
        return 1
    fi

    # Send message
    if ! "$send_script" "$target" "$msg_type" "$message" "${flags[@]}"; then
        warning_color "⚠️  Failed to send announcement to $target"
        # Not fatal - continue
        return 0
    fi

    return 0
}

# ───────────────────────────────────────────────────────────
# Display mode commands
# ───────────────────────────────────────────────────────────
# Args:
#   $1 - Mode name
#   $2+ - Command descriptions (one per argument)
# Example:
#   mode_show_commands "pair" \
#       "ai-pair-switch.sh       # Switch driver/navigator roles" \
#       "ai-pair-complete.sh     # Mark task complete"
# ───────────────────────────────────────────────────────────
mode_show_commands() {
    local mode_name="$1"
    shift
    local commands=("$@")

    echo ""
    echo "Commands available:"

    if [[ ${#commands[@]} -eq 0 ]]; then
        warning_color "  (No commands defined for $mode_name mode)"
        return 0
    fi

    for cmd in "${commands[@]}"; do
        echo "  $cmd"
    done

    echo ""
}

# ───────────────────────────────────────────────────────────
# Append content to shared file
# ───────────────────────────────────────────────────────────
# Args:
#   $1 - Content to append (supports multiline)
# Example:
#   mode_append_shared "════════════"
#   mode_append_shared "Protocol info here"
# ───────────────────────────────────────────────────────────
mode_append_shared() {
    local content="$1"
    echo "$content" >> "$AI_AGENTS_SHARED_FILE"
}

# ───────────────────────────────────────────────────────────
# Add blank line to shared file
# ───────────────────────────────────────────────────────────
mode_blank_line() {
    echo "" >> "$AI_AGENTS_SHARED_FILE"
}

# ───────────────────────────────────────────────────────────
# Get current mode from state file
# ───────────────────────────────────────────────────────────
# Args:
#   $1 - Path to mode state file
# Returns:
#   Prints mode name on stdout, returns 0 on success
# Example:
#   current_mode=$(mode_get_current "$MODE_STATE")
# ───────────────────────────────────────────────────────────
mode_get_current() {
    local state_file="$1"

    if [[ ! -f "$state_file" ]]; then
        echo "❌ Mode state file not found: $state_file" >&2
        return 1
    fi

    local mode_name
    if ! mode_name=$(json_read "$state_file" '.mode'); then
        echo "❌ Failed to read mode from state file" >&2
        return 1
    fi

    echo "$mode_name"
    return 0
}

# ───────────────────────────────────────────────────────────
# Validate mode state transition
# ───────────────────────────────────────────────────────────
# Args:
#   $1 - Mode name
#   $2 - Current state
#   $3 - New state
# Returns:
#   0 if transition valid, 1 if invalid
# Example:
#   if mode_validate_transition "pair" "active" "switched"; then
#       json_write "$MODE_STATE" '.status = "switched"'
#   fi
# ───────────────────────────────────────────────────────────
mode_validate_transition() {
    local mode="$1"
    local current_state="$2"
    local new_state="$3"

    # Define valid transitions (mode:from:to)
    local valid_transitions=(
        # Pair programming transitions
        "pair:initialized:active"
        "pair:active:switched"
        "pair:switched:active"
        "pair:active:completed"
        "pair:active:failed"

        # Debate transitions
        "debate:initialized:round1"
        "debate:round1:round2"
        "debate:round2:round3"
        "debate:round3:round4"
        "debate:round4:synthesis"
        "debate:synthesis:completed"
        "debate:*:failed"

        # Teaching transitions
        "teaching:initialized:active"
        "teaching:active:exercise"
        "teaching:exercise:review"
        "teaching:review:active"
        "teaching:active:completed"
        "teaching:*:failed"

        # Consensus transitions
        "consensus:initialized:proposing"
        "consensus:proposing:voting"
        "consensus:voting:refining"
        "consensus:refining:proposing"
        "consensus:voting:completed"
        "consensus:*:failed"

        # Competition transitions
        "competition:initialized:active"
        "competition:active:judging"
        "competition:judging:completed"
        "competition:*:failed"
    )

    local transition_key="${mode}:${current_state}:${new_state}"
    local wildcard_key="${mode}:*:${new_state}"

    # Check if transition is valid
    for valid in "${valid_transitions[@]}"; do
        if [[ "$valid" == "$transition_key" || "$valid" == "$wildcard_key" ]]; then
            return 0
        fi
    done

    # Invalid transition
    error_color "❌ Invalid state transition for $mode mode"
    error_color "   From: $current_state"
    error_color "   To:   $new_state"
    return 1
}

# ───────────────────────────────────────────────────────────
# Perform validated state transition
# ───────────────────────────────────────────────────────────
# Args:
#   $1 - Path to mode state file
#   $2 - New state
# Returns:
#   0 on success, 1 on failure
# Example:
#   mode_transition "$MODE_STATE" "switched"
# ───────────────────────────────────────────────────────────
mode_transition() {
    local state_file="$1"
    local new_state="$2"

    # Get current mode and state
    local mode_name
    if ! mode_name=$(mode_get_current "$state_file"); then
        return 1
    fi

    local current_state
    if ! current_state=$(json_read "$state_file" '.status' "initialized"); then
        warning_color "⚠️  Could not read current status, assuming 'initialized'"
        current_state="initialized"
    fi

    # Validate transition
    if ! mode_validate_transition "$mode_name" "$current_state" "$new_state"; then
        return 1
    fi

    # Perform transition
    if ! json_write "$state_file" ".status = \"$new_state\""; then
        error_color "❌ Failed to update mode state"
        return 1
    fi

    return 0
}

# ───────────────────────────────────────────────────────────
# Export functions for use in other scripts
# ───────────────────────────────────────────────────────────
export -f mode_init
export -f mode_announce
export -f mode_show_commands
export -f mode_get_state_path
export -f mode_append_shared
export -f mode_blank_line
export -f mode_get_current
export -f mode_validate_transition
export -f mode_transition

# ───────────────────────────────────────────────────────────
# Self-test when run directly
# ───────────────────────────────────────────────────────────
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Mode Framework Self-Test"
    echo "════════════════════════"
    echo ""

    # Test 1: Get state paths
    echo "Test 1: Get state paths for all modes"
    for mode in pair debate teach consensus compete; do
        if path=$(mode_get_state_path "$mode"); then
            echo "  ✅ $mode: $path"
        else
            echo "  ❌ $mode: failed"
            exit 1
        fi
    done
    echo ""

    # Test 2: Invalid mode
    echo "Test 2: Invalid mode handling"
    if mode_get_state_path "invalid" 2>/dev/null; then
        echo "  ❌ Should have rejected invalid mode"
        exit 1
    else
        echo "  ✅ Correctly rejected invalid mode"
    fi
    echo ""

    # Test 3: Transition validation
    echo "Test 3: Transition validation"
    if mode_validate_transition "pair" "active" "switched"; then
        echo "  ✅ Valid transition accepted"
    else
        echo "  ❌ Valid transition rejected"
        exit 1
    fi

    if mode_validate_transition "pair" "initialized" "switched" 2>/dev/null; then
        echo "  ❌ Invalid transition accepted"
        exit 1
    else
        echo "  ✅ Invalid transition rejected"
    fi
    echo ""

    # Test 4: Mode initialization (dry run with temp files)
    echo "Test 4: Mode initialization"
    # Note: Cannot override readonly constants, so we test with actual paths
    # In production, directories will already exist from ensure_directories()
    ensure_directories 2>/dev/null || mkdir -p "$AI_AGENTS_MODE_DIR" 2>/dev/null || true

    STATE_JSON='{"mode":"pair","driver":"Agent1","navigator":"Agent2","status":"active"}'
    if mode_init "pair" "$STATE_JSON"; then
        echo "  ✅ Mode initialization succeeded"

        # Verify state file created
        state_path=$(mode_get_state_path "pair")
        if [[ -f "$state_path" ]]; then
            echo "  ✅ State file created: $state_path"

            # Verify JSON is valid
            if jq empty "$state_path" 2>/dev/null; then
                echo "  ✅ State file contains valid JSON"
            else
                echo "  ❌ State file contains invalid JSON"
                cat "$state_path"
                exit 1
            fi
        else
            echo "  ❌ State file not created"
            exit 1
        fi

        # Verify shared file exists
        if [[ -f "$AI_AGENTS_SHARED_FILE" ]]; then
            echo "  ✅ Shared file exists"
        else
            echo "  ❌ Shared file not created"
            exit 1
        fi
    else
        echo "  ❌ Mode initialization failed"
        exit 1
    fi

    # Cleanup test artifacts
    rm -f "$state_path" 2>/dev/null || true
    echo ""

    echo "════════════════════════"
    echo "✅ All tests passed!"
    echo ""
fi
