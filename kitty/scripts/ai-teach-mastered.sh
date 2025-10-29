#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Teaching Mode - Mark Concept as Mastered
# ═══════════════════════════════════════════════════════════

set -euo pipefail

SESSION=${KITTY_AI_SESSION:-ai-agents}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/colors.sh"

MODE_STATE="/tmp/ai-mode-${SESSION}/teaching.json"
CONCEPT="${1:-}"

if [[ ! -f "$MODE_STATE" ]]; then
    error_color "❌ Teaching mode not active!"
    exit 1
fi

if [[ -z "$CONCEPT" ]]; then
    error_color "Usage: ai-teach-mastered.sh \"<concept>\""
    echo "Example: ai-teach-mastered.sh \"Async/Await fundamentals\""
    exit 1
fi

# Read current state
EXPERT=$(jq -r '.expert' "$MODE_STATE")
LEARNER=$(jq -r '.learner' "$MODE_STATE")
TOPIC=$(jq -r '.topic' "$MODE_STATE")
NUM_CONCEPTS=$(jq '.concepts_covered | length' "$MODE_STATE")
NUM_QUESTIONS=$(jq '.questions_asked' "$MODE_STATE")

# Increase mastery level
CURRENT_MASTERY=$(jq '.mastery_level' "$MODE_STATE")
NEW_MASTERY=$((CURRENT_MASTERY + 10))

jq --arg mastery "$NEW_MASTERY" \
   '.mastery_level = ($mastery | tonumber)' \
   "$MODE_STATE" > "${MODE_STATE}.tmp" && mv "${MODE_STATE}.tmp" "$MODE_STATE"

# Celebrate mastery
cat >> /tmp/ai-agents-shared.txt <<EOF

$(success_color "★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★")
$(success_color " 🎉 CONCEPT MASTERED!")
$(success_color "★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★")

$(info_color "Concept: $CONCEPT")

$(success_color "${LEARNER} has successfully mastered this concept!")

$(info_color "Session Progress:")
  • Topic: $TOPIC
  • Concepts covered: $NUM_CONCEPTS
  • Questions asked: $NUM_QUESTIONS
  • Mastery level: ${NEW_MASTERY}%

EOF

if [[ $NEW_MASTERY -ge 100 ]]; then
    cat >> /tmp/ai-agents-shared.txt <<EOF
$(success_color "╔═══════════════════════════════════════╗")
$(success_color "║   🏆 TOPIC FULLY MASTERED! 🏆        ║")
$(success_color "╚═══════════════════════════════════════╝")

$(shared_color "Congratulations ${LEARNER}!")
$(shared_color "You've achieved 100% mastery of: $TOPIC")

$(warning_color "Run ai-session-save.sh to preserve this learning session!")

EOF
    "${SCRIPT_DIR}/ai-agent-send-enhanced.sh" System RESULT "🏆 Topic Mastered: $TOPIC" --notify --blink
else
    cat >> /tmp/ai-agents-shared.txt <<EOF
$(shared_color "Great progress! Continue to next concept!")

EOF
    "${SCRIPT_DIR}/ai-agent-send-enhanced.sh" System RESULT "✅ Mastered: $CONCEPT" --notify
fi

cat >> /tmp/ai-agents-shared.txt <<EOF
$(success_color "★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★")

EOF

success_color "✅ Concept marked as mastered!"
info_color "   Concept: $CONCEPT"
info_color "   Mastery level: ${NEW_MASTERY}%"

if [[ $NEW_MASTERY -ge 100 ]]; then
    echo ""
    success_color "🏆 TOPIC FULLY MASTERED!"
    echo ""
    echo "Save this teaching session? Run:"
    echo "  ai-session-save.sh \"teaching-$(date +%Y%m%d-%H%M)\" \"Mastered: $TOPIC\""
fi
