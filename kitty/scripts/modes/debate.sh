#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Debate Mode
# ═══════════════════════════════════════════════════════════
# Agents discuss different approaches before implementing

set -euo pipefail

SESSION=${KITTY_AI_SESSION:-ai-agents}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/colors.sh"

TOPIC="${1:-No topic specified}"
MODE_STATE="/tmp/ai-mode-${SESSION}/debate.json"

# Initialize mode
cat > "$MODE_STATE" <<EOF
{
  "mode": "debate",
  "started": "$(date -Iseconds)",
  "topic": "$TOPIC",
  "positions": {
    "Agent1": null,
    "Agent2": null
  },
  "arguments": [],
  "consensus_reached": false
}
EOF

# Clear shared communication
> /tmp/ai-agents-shared.txt

# Announce mode start
"${SCRIPT_DIR}/../ai-agent-send-enhanced.sh" System INFO "💭 Debate Mode Started" --notify
"${SCRIPT_DIR}/../ai-agent-send-enhanced.sh" System INFO "   Topic: $TOPIC"
echo "" >> /tmp/ai-agents-shared.txt

# Show protocol
cat >> /tmp/ai-agents-shared.txt <<EOF
$(success_color "═══════════════════════════════════════")
$(success_color " Debate Protocol")
$(success_color "═══════════════════════════════════════")

$(warning_color "Topic: $TOPIC")

$(info_color "Round 1: Opening Statements (5 min)")
  Each agent presents their position

$(info_color "Round 2: Arguments (10 min)")
  Present supporting evidence and reasoning

$(info_color "Round 3: Rebuttals (10 min)")
  Address counter-arguments

$(info_color "Round 4: Synthesis (5 min)")
  Find common ground
  Identify best combined approach

$(shared_color "Commands:")
  • Position: ai-debate-position.sh <agent> "<position>"
  • Argument: ai-debate-argue.sh <agent> "<argument>" [evidence]
  • Rebuttal: ai-debate-rebut.sh <agent> "<rebuttal>"
  • Consensus: ai-debate-consensus.sh "<agreed solution>"

$(warning_color "Goal: Find the best solution through discussion!")

═══════════════════════════════════════
EOF

success_color "✅ Debate mode active"
info_color "   Topic: $TOPIC"
echo ""
echo "Start by stating positions:"
echo "  ai-debate-position.sh Agent1 \"I propose approach A because...\""
echo "  ai-debate-position.sh Agent2 \"I prefer approach B because...\""
