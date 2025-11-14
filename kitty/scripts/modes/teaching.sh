#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Teaching Mode
# ═══════════════════════════════════════════════════════════
# Expert agent guides learner agent through concepts

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/mode-framework.sh"
source "${SCRIPT_DIR}/../lib/constants.sh"

EXPERT="${1:-Agent1}"
LEARNER="${2:-Agent2}"
TOPIC="${3:-General programming concepts}"

STATE_JSON=$(cat <<EOF
{
  "mode": "teaching",
  "started": "$(date -Iseconds)",
  "expert": "$EXPERT",
  "learner": "$LEARNER",
  "topic": "$TOPIC",
  "concepts_covered": [],
  "questions_asked": 0,
  "mastery_level": 0
}
EOF
)

if ! mode_init "teach" "$STATE_JSON" "protocols/teaching-protocol.txt"; then
    error_color "❌ Failed to initialize teaching mode"
    exit 1
fi

mode_blank_line
mode_announce "System" "INFO" "🎓 Teaching Mode Started" --notify
mode_announce "System" "INFO" "   Expert: $EXPERT"
mode_announce "System" "INFO" "   Learner: $LEARNER"
mode_announce "System" "INFO" "   Topic: $TOPIC"
mode_blank_line

success_color "✅ Teaching mode active"
info_color "   Expert: $EXPERT"
info_color "   Learner: $LEARNER"
info_color "   Topic: $TOPIC"

mode_show_commands "teaching" \
    "ai-teach-explain.sh \"<concept>\" \"<explanation>\"   # Expert explains" \
    "ai-teach-question.sh <learner> \"<question>\"         # Learner asks" \
    "ai-teach-exercise.sh \"<exercise>\" [difficulty]      # Practice" \
    "ai-teach-check.sh <learner> \"<summary>\"            # Check mastery" \
    "ai-teach-mastered.sh \"<concept>\"                   # Mark mastered"

mode_blank_line
info_color "Kick off by explaining the first concept:"
info_color "  ai-teach-explain.sh \"Event loop\" \"Here's how it works...\""
