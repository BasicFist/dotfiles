#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Consensus Mode - Propose Solution
# ═══════════════════════════════════════════════════════════

set -euo pipefail

SESSION=${KITTY_AI_SESSION:-ai-agents}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/colors.sh"

MODE_STATE="/tmp/ai-mode-${SESSION}/consensus.json"
AGENT="${1:-}"
PROPOSAL="${2:-}"

if [[ ! -f "$MODE_STATE" ]]; then
    error_color "❌ Consensus mode not active!"
    exit 1
fi

if [[ -z "$AGENT" || -z "$PROPOSAL" ]]; then
    error_color "Usage: ai-consensus-propose.sh <agent> \"<proposal>\""
    echo "Example: ai-consensus-propose.sh Agent1 \"I propose we use microservices architecture\""
    exit 1
fi

# Add proposal to state
TIMESTAMP=$(date -Iseconds)
jq --arg agent "$AGENT" \
   --arg proposal "$PROPOSAL" \
   --arg timestamp "$TIMESTAMP" \
   '.proposals += [{agent: $agent, proposal: $proposal, timestamp: $timestamp}]' \
   "$MODE_STATE" > "${MODE_STATE}.tmp" && mv "${MODE_STATE}.tmp" "$MODE_STATE"

# Determine agent color
if [[ "$AGENT" == "Agent1" ]]; then
    AGENT_COLOR="$AGENT1_COLOR"
else
    AGENT_COLOR="$AGENT2_COLOR"
fi

# Present proposal
cat >> /tmp/ai-agents-shared.txt <<EOF

${AGENT_COLOR}╔═══════════════════════════════════════╗${RESET}
${AGENT_COLOR}║  💡 ${AGENT} - Proposal                ║${RESET}
${AGENT_COLOR}╚═══════════════════════════════════════╝${RESET}

$(success_color "$PROPOSAL")

${AGENT_COLOR}───────────────────────────────────────${RESET}

EOF

"${SCRIPT_DIR}/ai-agent-send-enhanced.sh" "$AGENT" INFO "💡 Proposal submitted"

success_color "✅ Proposal recorded for $AGENT"

# Check if both agents have proposed
NUM_PROPOSALS=$(jq '.proposals | length' "$MODE_STATE")
info_color "   Total proposals: $NUM_PROPOSALS"

if [[ $NUM_PROPOSALS -ge 2 ]]; then
    cat >> /tmp/ai-agents-shared.txt <<EOF
$(success_color "════════════════════════════════════════")
$(success_color " ✅ Both agents have proposed!")
$(success_color "════════════════════════════════════════")

$(info_color "Phase 1 Complete - Moving to Phase 2: Discussion")
$(info_color "Discuss merits and concerns")

$(shared_color "Commands:")
  • Share concerns: ai-consensus-concern.sh <agent> "<concern>"
  • Refine proposals: ai-consensus-refine.sh "<refined proposal>"

EOF
    "${SCRIPT_DIR}/ai-agent-send-enhanced.sh" System INFO "💬 Ready for discussion!" --notify
fi
