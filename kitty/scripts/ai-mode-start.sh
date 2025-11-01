#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# AI Agents - Start Collaboration Mode
# ═══════════════════════════════════════════════════════════

set -euo pipefail

SESSION=${KITTY_AI_SESSION:-ai-agents}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/colors.sh"

# Check dependencies
if [[ -f "${SCRIPT_DIR}/lib/dependencies.sh" ]]; then
    source "${SCRIPT_DIR}/lib/dependencies.sh"
    if ! check_dependencies; then
        exit 1
    fi
fi

usage() {
    cat <<EOF
Usage: ai-mode-start.sh <mode> [options]

Available Modes:
  pair         Pair programming (driver/navigator)
  debate       Structured debate/discussion
  teach        Teaching mode (expert/learner)
  consensus    Consensus building (agents must agree)
  compete      Competition (best solution wins)

Examples:
  ai-mode-start.sh pair Agent1=driver Agent2=navigator
  ai-mode-start.sh debate "Should we use REST or GraphQL?"
  ai-mode-start.sh teach Agent1=expert Agent2=learner topic="async programming"
  ai-mode-start.sh consensus "API design decisions"
  ai-mode-start.sh compete "Implement sorting algorithm"
EOF
}

if [[ $# -lt 1 ]]; then
    usage
    exit 1
fi

MODE="$1"
shift

# Create mode state directory
MODE_STATE_DIR="/tmp/ai-mode-${SESSION}"
mkdir -p "$MODE_STATE_DIR"

case "$MODE" in
    pair|pairing)
        exec "${SCRIPT_DIR}/modes/pair-programming.sh" "$@"
        ;;
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
