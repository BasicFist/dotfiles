#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Consensus Mode - Finalize Agreement
# ═══════════════════════════════════════════════════════════

set -euo pipefail

SESSION=${KITTY_AI_SESSION:-ai-agents}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/colors.sh"

MODE_STATE="/tmp/ai-mode-${SESSION}/consensus.json"
FINAL_DECISION="${1:-}"

if [[ ! -f "$MODE_STATE" ]]; then
    error_color "❌ Consensus mode not active!"
    exit 1
fi

if [[ -z "$FINAL_DECISION" ]]; then
    error_color "Usage: ai-consensus-agree.sh \"<final decision>\""
    echo "Example: ai-consensus-agree.sh \"Implement hybrid architecture with microservices for core, monolith for admin\""
    exit 1
fi

# Check if consensus was reached
CONSENSUS=$(jq -r '.consensus_reached' "$MODE_STATE")

if [[ "$CONSENSUS" != "true" ]]; then
    error_color "❌ Cannot finalize - consensus not yet reached!"
    echo "Both agents must vote YES first:"
    echo "  ai-consensus-vote.sh Agent1 yes"
    echo "  ai-consensus-vote.sh Agent2 yes"
    exit 1
fi

# Record final decision
jq --arg decision "$FINAL_DECISION" \
   '.final_decision = $decision' \
   "$MODE_STATE" > "${MODE_STATE}.tmp" && mv "${MODE_STATE}.tmp" "$MODE_STATE"

# Read session stats
DECISION_TOPIC=$(jq -r '.decision' "$MODE_STATE")
STARTED=$(jq -r '.started' "$MODE_STATE")
NUM_PROPOSALS=$(jq '.proposals | length' "$MODE_STATE")
DURATION=$(($(date +%s) - $(date -d "$STARTED" +%s)))
MINUTES=$((DURATION / 60))

# Announce final agreement
cat >> /tmp/ai-agents-shared.txt <<EOF

$(success_color "═══════════════════════════════════════")
$(success_color " 🏆 FINAL AGREEMENT RECORDED")
$(success_color "═══════════════════════════════════════")

$(info_color "Original Decision Topic:")
$(shared_color "$DECISION_TOPIC")

$(info_color "Final Agreed Decision:")
$(success_color "$FINAL_DECISION")

$(info_color "Consensus Building Stats:")
  • Duration: ${MINUTES} minutes
  • Proposals discussed: ${NUM_PROPOSALS}
  • Both agents in agreement ✅

$(success_color "─────────────────────────────────────────")
$(success_color "Ready to implement! 🚀")

$(warning_color "Save this consensus session:")
$(warning_color "  ai-session-save.sh \"consensus-$(date +%Y%m%d-%H%M)\" \"Agreement on $DECISION_TOPIC\"")

$(success_color "═══════════════════════════════════════")

EOF

"${SCRIPT_DIR}/ai-agent-send-enhanced.sh" System RESULT "🏆 Agreement Finalized!" --notify

success_color "✅ Final agreement recorded!"
info_color "   Topic: $DECISION_TOPIC"
info_color "   Duration: ${MINUTES} minutes"
info_color "   Proposals: ${NUM_PROPOSALS}"
echo ""
echo "Decision:"
success_color "$FINAL_DECISION"
echo ""
echo "Save this consensus session? Run:"
echo "  ai-session-save.sh \"consensus-$(date +%Y%m%d-%H%M)\" \"Agreement on $DECISION_TOPIC\""
