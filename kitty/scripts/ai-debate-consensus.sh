#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Debate Mode - Reach Consensus
# ═══════════════════════════════════════════════════════════

set -euo pipefail

SESSION=${KITTY_AI_SESSION:-ai-agents}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/colors.sh"

MODE_STATE="/tmp/ai-mode-${SESSION}/debate.json"
SOLUTION="${1:-}"

if [[ ! -f "$MODE_STATE" ]]; then
    error_color "❌ Debate mode not active!"
    exit 1
fi

if [[ -z "$SOLUTION" ]]; then
    error_color "Usage: ai-debate-consensus.sh \"<agreed solution>\""
    echo "Example: ai-debate-consensus.sh \"Hybrid approach: use REST for simple endpoints, GraphQL for complex queries\""
    exit 1
fi

# Update state
jq --arg solution "$SOLUTION" \
   '.consensus_reached = true | .final_solution = $solution' \
   "$MODE_STATE" > "${MODE_STATE}.tmp" && mv "${MODE_STATE}.tmp" "$MODE_STATE"

# Read debate stats
TOPIC=$(jq -r '.topic' "$MODE_STATE")
STARTED=$(jq -r '.started' "$MODE_STATE")
NUM_ARGUMENTS=$(jq '.arguments | length' "$MODE_STATE")
DURATION=$(($(date +%s) - $(date -d "$STARTED" +%s)))
MINUTES=$((DURATION / 60))

# Announce consensus
cat >> /tmp/ai-agents-shared.txt <<EOF

$(success_color "═══════════════════════════════════════")
$(success_color " 🤝 CONSENSUS REACHED!")
$(success_color "═══════════════════════════════════════")

$(info_color "Topic:")
$(shared_color "$TOPIC")

$(info_color "Agreed Solution:")
$(success_color "$SOLUTION")

$(info_color "Debate Stats:")
  • Duration: ${MINUTES} minutes
  • Arguments presented: ${NUM_ARGUMENTS}
  • Both agents contributed

$(success_color "Excellent collaboration! 🎉")

$(warning_color "Run ai-session-save.sh to preserve this debate!")

═══════════════════════════════════════

EOF

"${SCRIPT_DIR}/ai-agent-send-enhanced.sh" System RESULT "🤝 Consensus: $SOLUTION" --notify

success_color "✅ Debate concluded with consensus!"
info_color "   Duration: ${MINUTES} minutes"
info_color "   Arguments: ${NUM_ARGUMENTS}"
echo ""
echo "Save this debate? Run:"
echo "  ai-session-save.sh \"debate-$(date +%Y%m%d-%H%M)\" \"Consensus on: $TOPIC\""
