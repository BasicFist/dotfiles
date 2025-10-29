#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Competition Mode
# ═══════════════════════════════════════════════════════════
# Agents compete to solve challenges - best solution wins

set -euo pipefail

SESSION=${KITTY_AI_SESSION:-ai-agents}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/colors.sh"

CHALLENGE="${1:-No challenge specified}"
TIME_LIMIT="${2:-30}"  # Default 30 minutes
MODE_STATE="/tmp/ai-mode-${SESSION}/competition.json"

# Initialize mode
cat > "$MODE_STATE" <<EOF
{
  "mode": "competition",
  "started": "$(date -Iseconds)",
  "challenge": "$CHALLENGE",
  "time_limit_minutes": $TIME_LIMIT,
  "submissions": {
    "Agent1": null,
    "Agent2": null
  },
  "scores": {
    "Agent1": 0,
    "Agent2": 0
  },
  "criteria": {
    "correctness": 0,
    "performance": 0,
    "code_quality": 0,
    "innovation": 0
  },
  "winner": null,
  "completed": false
}
EOF

# Clear shared communication
> /tmp/ai-agents-shared.txt

# Announce mode start
"${SCRIPT_DIR}/../ai-agent-send-enhanced.sh" System INFO "🏆 Competition Mode Started" --notify
"${SCRIPT_DIR}/../ai-agent-send-enhanced.sh" System INFO "   Challenge: $CHALLENGE"
"${SCRIPT_DIR}/../ai-agent-send-enhanced.sh" System INFO "   Time Limit: $TIME_LIMIT minutes"
echo "" >> /tmp/ai-agents-shared.txt

# Show protocol
cat >> /tmp/ai-agents-shared.txt <<EOF
$(success_color "═══════════════════════════════════════")
$(success_color " Competition Protocol")
$(success_color "═══════════════════════════════════════")

$(warning_color "Challenge: $CHALLENGE")
$(warning_color "Time Limit: $TIME_LIMIT minutes")

$(info_color "Phase 1: Planning (5 min)")
  Understand the problem
  Design your approach
  **No coding yet!**

$(info_color "Phase 2: Implementation ($((TIME_LIMIT - 10)) min)")
  Code your solution
  Test thoroughly
  Optimize for criteria

$(info_color "Phase 3: Submission (5 min)")
  Submit final solution
  Explain your approach
  Highlight innovations

$(shared_color "Judging Criteria (25 points each):")
  • **Correctness**: Does it work? All edge cases?
  • **Performance**: Speed, memory efficiency
  • **Code Quality**: Readability, maintainability
  • **Innovation**: Creative approach, elegance

$(shared_color "Commands:")
  • Submit: ai-compete-submit.sh <agent> "<solution_path>" "<explanation>"
  • Score: ai-compete-score.sh <agent> <criterion> <points>
  • Winner: ai-compete-winner.sh <agent> "<reason>"

$(agent1_color "Agent1: Ready to compete!")
$(agent2_color "Agent2: Let's do this!")

$(warning_color "⏱️  Timer starts NOW - ${TIME_LIMIT} minutes!")

═══════════════════════════════════════
EOF

success_color "✅ Competition mode active"
info_color "   Challenge: $CHALLENGE"
info_color "   Time Limit: $TIME_LIMIT minutes"
echo ""
echo "Start planning your approaches!"
echo ""
echo "When ready, submit with:"
echo "  ai-compete-submit.sh Agent1 \"path/to/solution.py\" \"My approach uses...\""
echo "  ai-compete-submit.sh Agent2 \"path/to/solution.py\" \"Alternative method...\""
echo ""
echo "May the best solution win! 🏆"
