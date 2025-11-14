#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Teaching Mode - Present Exercise
# ═══════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/colors.sh"
source "${SCRIPT_DIR}/lib/constants.sh"

MODE_STATE="$AI_AGENTS_STATE_TEACHING"
EXERCISE="${1:-}"
DIFFICULTY="${2:-medium}"

if [[ ! -f "$MODE_STATE" ]]; then
    error_color "❌ Teaching mode not active!"
    exit 1
fi

if [[ -z "$EXERCISE" ]]; then
    error_color "Usage: ai-teach-exercise.sh \"<exercise>\" [difficulty]"
    echo "Difficulty: easy | medium | hard"
    echo "Example: ai-teach-exercise.sh \"Implement a promise-based timeout function\" medium"
    exit 1
fi

EXPERT=$(jq -r '.expert' "$MODE_STATE")
LEARNER=$(jq -r '.learner' "$MODE_STATE")

# Determine symbol by difficulty
case "$DIFFICULTY" in
    easy)
        SYMBOL="🟢"
        COLOR="$SUCCESS_COLOR"
        ;;
    medium)
        SYMBOL="🟡"
        COLOR="$WARNING_COLOR"
        ;;
    hard)
        SYMBOL="🔴"
        COLOR="$ERROR_COLOR"
        ;;
    *)
        SYMBOL="🟡"
        COLOR="$WARNING_COLOR"
        DIFFICULTY="medium"
        ;;
esac

# Present exercise
cat >> "$AI_AGENTS_SHARED_FILE" <<EOF

${COLOR}█████████████████████████████████████████${RESET}
${COLOR} 📝 PRACTICE EXERCISE${RESET}
${COLOR}█████████████████████████████████████████${RESET}

$(info_color "Difficulty: ${SYMBOL} ${DIFFICULTY^^}")

$(success_color "$EXERCISE")

${COLOR}─────────────────────────────────────────${RESET}

$(shared_color "Instructions:")
  • ${LEARNER}: Try to solve this
  • Take your time to think through it
  • Ask questions if you need clarification
  • ${EXPERT} will review your solution

${COLOR}█████████████████████████████████████████${RESET}

EOF

"${SCRIPT_DIR}/ai-agent-send-enhanced.sh" System TASK "${SYMBOL} Exercise: $EXERCISE" --notify

success_color "✅ Exercise presented"
info_color "   Difficulty: $DIFFICULTY"
echo ""
echo "Learner ($LEARNER) should attempt the exercise!"
