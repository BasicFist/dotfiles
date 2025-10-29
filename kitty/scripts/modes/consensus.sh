#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Consensus Mode
# ═══════════════════════════════════════════════════════════
# Agents must reach agreement before proceeding

set -euo pipefail

SESSION=${KITTY_AI_SESSION:-ai-agents}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/colors.sh"

DECISION="${1:-Decision not specified}"
MODE_STATE="/tmp/ai-mode-${SESSION}/consensus.json"

# Initialize mode
cat > "$MODE_STATE" <<EOF
{
  "mode": "consensus",
  "started": "$(date -Iseconds)",
  "decision": "$DECISION",
  "votes": {
    "Agent1": null,
    "Agent2": null
  },
  "proposals": [],
  "consensus_reached": false,
  "final_decision": null
}
EOF

# Clear shared communication
> /tmp/ai-agents-shared.txt

# Announce mode start
"${SCRIPT_DIR}/../ai-agent-send-enhanced.sh" System INFO "🤝 Consensus Mode Started" --notify
"${SCRIPT_DIR}/../ai-agent-send-enhanced.sh" System INFO "   Decision: $DECISION"
echo "" >> /tmp/ai-agents-shared.txt

# Show protocol
cat >> /tmp/ai-agents-shared.txt <<EOF
$(success_color "═══════════════════════════════════════")
$(success_color " Consensus Building Protocol")
$(success_color "═══════════════════════════════════════")

$(warning_color "Decision: $DECISION")

$(info_color "Phase 1: Proposals (10 min)")
  Each agent proposes a solution

$(info_color "Phase 2: Discussion (15 min)")
  Discuss merits and concerns
  Identify common ground

$(info_color "Phase 3: Refinement (10 min)")
  Refine proposals based on feedback
  Combine best aspects

$(info_color "Phase 4: Voting (5 min)")
  Vote on refined proposals
  **Both agents must agree**

$(shared_color "Commands:")
  • Propose: ai-consensus-propose.sh <agent> "<proposal>"
  • Concern: ai-consensus-concern.sh <agent> "<concern>"
  • Refine: ai-consensus-refine.sh "<refined proposal>"
  • Vote: ai-consensus-vote.sh <agent> <yes|no|abstain>
  • Agree: ai-consensus-agree.sh "<final decision>"

$(error_color "⚠️  No action taken until BOTH agents agree!")

═══════════════════════════════════════
EOF

success_color "✅ Consensus mode active"
info_color "   Decision: $DECISION"
echo ""
echo "Start proposing solutions:"
echo "  ai-consensus-propose.sh Agent1 \"I propose we...\""
echo "  ai-consensus-propose.sh Agent2 \"Alternative approach:...\""
echo ""
echo "Both agents must agree before proceeding!"
