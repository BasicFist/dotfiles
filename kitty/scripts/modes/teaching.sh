#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Teaching Mode
# ═══════════════════════════════════════════════════════════
# Expert agent guides learner agent through concepts

set -euo pipefail

SESSION=${KITTY_AI_SESSION:-ai-agents}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/colors.sh"

EXPERT="${1:-Agent1}"
LEARNER="${2:-Agent2}"
TOPIC="${3:-General programming concepts}"
MODE_STATE="/tmp/ai-mode-${SESSION}/teaching.json"

# Initialize mode
cat > "$MODE_STATE" <<EOF
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

# Clear shared communication
> /tmp/ai-agents-shared.txt

# Announce mode start
"${SCRIPT_DIR}/../ai-agent-send-enhanced.sh" System INFO "🎓 Teaching Mode Started" --notify
"${SCRIPT_DIR}/../ai-agent-send-enhanced.sh" System INFO "   Expert: $EXPERT"
"${SCRIPT_DIR}/../ai-agent-send-enhanced.sh" System INFO "   Learner: $LEARNER"
"${SCRIPT_DIR}/../ai-agent-send-enhanced.sh" System INFO "   Topic: $TOPIC"
echo "" >> /tmp/ai-agents-shared.txt

# Show protocol
cat >> /tmp/ai-agents-shared.txt <<EOF
$(success_color "═══════════════════════════════════════")
$(success_color " Teaching Protocol")
$(success_color "═══════════════════════════════════════")

$(warning_color "Topic: $TOPIC")

$(agent1_color "Expert ($EXPERT):")
  • Explain concepts clearly
  • Provide examples
  • Check for understanding
  • Adapt to learner's pace
  • Encourage questions

$(agent2_color "Learner ($LEARNER):")
  • Ask questions freely
  • Try exercises
  • Share your understanding
  • Request clarification
  • Practice new concepts

$(shared_color "Commands:")
  • Explain: ai-teach-explain.sh "$EXPERT" "<concept>" "<explanation>"
  • Question: ai-teach-question.sh "$LEARNER" "<question>"
  • Exercise: ai-teach-exercise.sh "<exercise>" [difficulty]
  • Check understanding: ai-teach-check.sh "$LEARNER" "<summary>"
  • Mark mastered: ai-teach-mastered.sh "<concept>"

$(info_color "Flow:")
  1. Expert explains concept
  2. Learner asks questions
  3. Expert provides examples
  4. Learner practices
  5. Check understanding
  6. Move to next concept

═══════════════════════════════════════
EOF

success_color "✅ Teaching mode active"
info_color "   Expert: $EXPERT"
info_color "   Learner: $LEARNER"
info_color "   Topic: $TOPIC"
echo ""
echo "Start teaching:"
echo "  ai-teach-explain.sh $EXPERT \"Concept\" \"Explanation...\""
echo "  ai-teach-question.sh $LEARNER \"How does X work?\""
