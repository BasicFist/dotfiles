#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# AI Agents - Start Collaboration Mode
# ═══════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/constants.sh"
source "${SCRIPT_DIR}/lib/colors.sh"

usage() {
    cat <<EOF
Usage: ai-mode-start.sh <mode> [options]

Core Modes (Recommended for Daily Use):
  pair            Pair programming (driver/navigator)
  code-review     Code review session (author/reviewer)
  debug           Debug session (reporter/debugger)
  brainstorm      Brainstorm ideas (free-form, no judgment)

Legacy Modes (Kept for Compatibility):
  debate          Structured debate/discussion
  teach           Teaching mode (expert/learner)
  consensus       Consensus building (agents must agree)
  compete         Competition (best solution wins)

Examples:
  # Core modes
  ai-mode-start.sh pair Agent1 Agent2
  ai-mode-start.sh code-review Alice Bob "src/api.js"
  ai-mode-start.sh debug Alice Bob "TypeError on line 42"
  ai-mode-start.sh brainstorm "How to improve performance"

  # Legacy modes
  ai-mode-start.sh debate "Should we use REST or GraphQL?"
  ai-mode-start.sh teach Expert Learner "async programming"
  ai-mode-start.sh consensus "API design decisions"
  ai-mode-start.sh compete "Implement sorting algorithm"

See NEW-MODES-GUIDE.md for detailed usage and benefits.
EOF
}

if [[ $# -lt 1 ]]; then
    usage
    exit 1
fi

MODE="$1"
shift

# Create mode state directory (use constant from constants.sh)
ensure_directories

case "$MODE" in
    # Core practical modes
    pair|pairing|pair-programming)
        exec "${SCRIPT_DIR}/modes/pair-programming.sh" "$@"
        ;;
    code-review|review)
        exec "${SCRIPT_DIR}/modes/code-review.sh" "$@"
        ;;
    debug|debugging)
        exec "${SCRIPT_DIR}/modes/debug.sh" "$@"
        ;;
    brainstorm|ideas)
        exec "${SCRIPT_DIR}/modes/brainstorm.sh" "$@"
        ;;
    # Legacy modes (kept for compatibility)
    debate|discuss)
        exec "${SCRIPT_DIR}/modes/debate.sh" "$@"
        ;;
    teach|teaching)
        exec "${SCRIPT_DIR}/modes/teaching.sh" "$@"
        ;;
    consensus)
        exec "${SCRIPT_DIR}/modes/consensus.sh" "$@"
        ;;
    compete|competition)
        exec "${SCRIPT_DIR}/modes/competition.sh" "$@"
        ;;
    *)
        error_color "Unknown mode: $MODE"
        usage
        exit 1
        ;;
esac
