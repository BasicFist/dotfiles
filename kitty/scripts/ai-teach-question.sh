#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Teaching Mode - Learner Asks Question
# ═══════════════════════════════════════════════════════════

set -euo pipefail

SESSION=${KITTY_AI_SESSION:-ai-agents}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/colors.sh"

MODE_STATE="/tmp/ai-mode-${SESSION}/teaching.json"
LEARNER="${1:-}"
QUESTION="${2:-}"

if [[ ! -f "$MODE_STATE" ]]; then
    error_color "❌ Teaching mode not active!"
    exit 1
fi

if [[ -z "$LEARNER" || -z "$QUESTION" ]]; then
    error_color "Usage: ai-teach-question.sh \"<learner>\" \"<question>\""
    echo "Example: ai-teach-question.sh Agent2 \"How does the event loop handle promises?\""
    exit 1
fi

CURRENT_LEARNER=$(jq -r '.learner' "$MODE_STATE")

if [[ "$LEARNER" != "$CURRENT_LEARNER" ]]; then
    warning_color "⚠️  $LEARNER is not the current learner ($CURRENT_LEARNER)"
fi

# Increment question counter
jq '.questions_asked += 1' \
   "$MODE_STATE" > "${MODE_STATE}.tmp" && mv "${MODE_STATE}.tmp" "$MODE_STATE"

# Present question
cat >> /tmp/ai-agents-shared.txt <<EOF

$(agent2_color "─────────────────────────────────────────")
$(agent2_color " ❓ ${LEARNER} Asks:")
$(agent2_color "─────────────────────────────────────────")

$(warning_color "$QUESTION")

$(agent2_color "─────────────────────────────────────────")

EOF

"${SCRIPT_DIR}/ai-agent-send-enhanced.sh" "$LEARNER" QUESTION "$QUESTION"

success_color "✅ Question asked"
info_color "   Learner: $LEARNER"

# Count questions
NUM_QUESTIONS=$(jq '.questions_asked' "$MODE_STATE")
info_color "   Total questions: $NUM_QUESTIONS"

# Encourage expert response
echo ""
info_color "Expert should respond with:"
echo "  ai-teach-explain.sh <expert> \"<concept>\" \"<answer>\""
