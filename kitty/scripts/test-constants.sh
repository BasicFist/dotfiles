#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Configuration Constants Test
# ═══════════════════════════════════════════════════════════

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/constants.sh"
source "${SCRIPT_DIR}/lib/colors.sh"

echo "Testing configuration constants..."
echo ""

# Test 1: Verify session constants
echo "Test 1: Session constants"
if [[ "$AI_AGENTS_SESSION_DEFAULT" == "ai-agents" ]]; then
    success_color "✅ Session default is correct"
else
    error_color "❌ Session default mismatch: $AI_AGENTS_SESSION_DEFAULT"
    exit 1
fi

if [[ -n "$AI_AGENTS_SESSION" ]]; then
    success_color "✅ Session name is set: $AI_AGENTS_SESSION"
else
    error_color "❌ Session name not set"
    exit 1
fi

# Test 2: Verify path constants
echo ""
echo "Test 2: Path constants"
if [[ "$AI_AGENTS_KB_ROOT" =~ \.ai-agents$ ]]; then
    success_color "✅ KB root path is correct"
else
    error_color "❌ KB root path incorrect: $AI_AGENTS_KB_ROOT"
    exit 1
fi

if [[ "$AI_AGENTS_SHARED_FILE" == "/tmp/ai-agents-shared.txt" ]]; then
    success_color "✅ Shared file path is correct"
else
    error_color "❌ Shared file path incorrect: $AI_AGENTS_SHARED_FILE"
    exit 1
fi

# Test 3: Verify mode state paths
echo ""
echo "Test 3: Mode state paths"
if [[ "$AI_AGENTS_STATE_PAIR" =~ pair-programming\.json$ ]]; then
    success_color "✅ Pair state path is correct"
else
    error_color "❌ Pair state path incorrect: $AI_AGENTS_STATE_PAIR"
    exit 1
fi

if [[ "$AI_AGENTS_STATE_DEBATE" =~ debate\.json$ ]]; then
    success_color "✅ Debate state path is correct"
else
    error_color "❌ Debate state path incorrect: $AI_AGENTS_STATE_DEBATE"
    exit 1
fi

# Test 4: Verify timeout constants
echo ""
echo "Test 4: Timeout constants"
if [[ "$AI_AGENTS_LOCK_TIMEOUT_READ" == "5" ]]; then
    success_color "✅ Read lock timeout is correct"
else
    error_color "❌ Read lock timeout incorrect: $AI_AGENTS_LOCK_TIMEOUT_READ"
    exit 1
fi

if [[ "$AI_AGENTS_LOCK_TIMEOUT_WRITE" == "10" ]]; then
    success_color "✅ Write lock timeout is correct"
else
    error_color "❌ Write lock timeout incorrect: $AI_AGENTS_LOCK_TIMEOUT_WRITE"
    exit 1
fi

# Test 5: Helper function - get_mode_state_path
echo ""
echo "Test 5: Helper function - get_mode_state_path"

pair_path=$(get_mode_state_path "pair")
if [[ "$pair_path" == "$AI_AGENTS_STATE_PAIR" ]]; then
    success_color "✅ get_mode_state_path('pair') works"
else
    error_color "❌ get_mode_state_path('pair') failed: $pair_path"
    exit 1
fi

debate_path=$(get_mode_state_path "debate")
if [[ "$debate_path" == "$AI_AGENTS_STATE_DEBATE" ]]; then
    success_color "✅ get_mode_state_path('debate') works"
else
    error_color "❌ get_mode_state_path('debate') failed: $debate_path"
    exit 1
fi

# Test 6: Helper function - ensure_directories
echo ""
echo "Test 6: Helper function - ensure_directories"

ensure_directories

if [[ -d "$AI_AGENTS_MODE_DIR" ]]; then
    success_color "✅ Mode directory created: $AI_AGENTS_MODE_DIR"
else
    error_color "❌ Mode directory not created"
    exit 1
fi

if [[ -d "$AI_AGENTS_LOCK_DIR" ]]; then
    success_color "✅ Lock directory created: $AI_AGENTS_LOCK_DIR"
else
    error_color "❌ Lock directory not created"
    exit 1
fi

# Test 7: Verify constants are readonly
echo ""
echo "Test 7: Constants are readonly"

if readonly -p | grep -q "AI_AGENTS_SESSION_DEFAULT"; then
    success_color "✅ Constants are marked readonly"
else
    error_color "❌ Constants are not readonly"
    exit 1
fi

echo ""
success_color "✅ All 7 configuration constants tests passed!"
