#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Consensus Mode - Vote on Proposal
# ═══════════════════════════════════════════════════════════

set -euo pipefail

SESSION=${KITTY_AI_SESSION:-ai-agents}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/colors.sh"

MODE_STATE="/tmp/ai-mode-${SESSION}/consensus.json"
AGENT="${1:-}"
VOTE="${2:-}"

if [[ ! -f "$MODE_STATE" ]]; then
    error_color "❌ Consensus mode not active!"
    exit 1
fi

if [[ -z "$AGENT" || -z "$VOTE" ]]; then
    error_color "Usage: ai-consensus-vote.sh <agent> <yes|no|abstain>"
    echo "Example: ai-consensus-vote.sh Agent1 yes"
    exit 1
fi

# Validate vote
VOTE=$(echo "$VOTE" | tr '[:upper:]' '[:lower:]')
if [[ ! "$VOTE" =~ ^(yes|no|abstain)$ ]]; then
    error_color "Invalid vote: $VOTE"
    error_color "Must be: yes, no, or abstain"
    exit 1
fi

# Record vote
jq --arg agent "$AGENT" \
   --arg vote "$VOTE" \
   '.votes[$agent] = $vote' \
   "$MODE_STATE" > "${MODE_STATE}.tmp" && mv "${MODE_STATE}.tmp" "$MODE_STATE"

# Determine vote symbol and color
case "$VOTE" in
    yes)
        SYMBOL="✅"
        VOTE_COLOR="$SUCCESS_COLOR"
        ;;
    no)
        SYMBOL="❌"
        VOTE_COLOR="$ERROR_COLOR"
        ;;
    abstain)
        SYMBOL="🤷"
        VOTE_COLOR="$WARNING_COLOR"
        ;;
esac

# Announce vote
cat >> /tmp/ai-agents-shared.txt <<EOF

$(shared_color "─────────────────────────────────────────")
${VOTE_COLOR}${SYMBOL} ${AGENT} votes: ${VOTE^^}${RESET}
$(shared_color "─────────────────────────────────────────")

EOF

"${SCRIPT_DIR}/ai-agent-send-enhanced.sh" "$AGENT" INFO "${SYMBOL} Vote: ${VOTE}"

success_color "✅ Vote recorded for $AGENT: ${VOTE}"

# Check if both agents have voted
AGENT1_VOTE=$(jq -r '.votes.Agent1' "$MODE_STATE")
AGENT2_VOTE=$(jq -r '.votes.Agent2' "$MODE_STATE")

if [[ "$AGENT1_VOTE" != "null" && "$AGENT2_VOTE" != "null" ]]; then
    # Both voted - check consensus
    if [[ "$AGENT1_VOTE" == "yes" && "$AGENT2_VOTE" == "yes" ]]; then
        # CONSENSUS REACHED!
        DECISION=$(jq -r '.decision' "$MODE_STATE")

        jq '.consensus_reached = true' \
           "$MODE_STATE" > "${MODE_STATE}.tmp" && mv "${MODE_STATE}.tmp" "$MODE_STATE"

        cat >> /tmp/ai-agents-shared.txt <<EOF

$(success_color "★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★")
$(success_color " 🤝 CONSENSUS REACHED!")
$(success_color "★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★")

$(info_color "Decision: $DECISION")
$(success_color "Both agents agree - proceeding with implementation!")

$(warning_color "Next: Record final decision with ai-consensus-agree.sh")

$(success_color "★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★")

EOF
        "${SCRIPT_DIR}/ai-agent-send-enhanced.sh" System RESULT "🤝 CONSENSUS!" --notify --blink

        echo ""
        success_color "🤝 CONSENSUS REACHED!"
        echo ""
        echo "Record the final decision with:"
        echo "  ai-consensus-agree.sh \"<final decision text>\""

    else
        # No consensus
        cat >> /tmp/ai-agents-shared.txt <<EOF

$(warning_color "════════════════════════════════════════")
$(warning_color " ⚠️  No Consensus Yet")
$(warning_color "════════════════════════════════════════")

$(info_color "Votes:")
  • Agent1: ${AGENT1_VOTE}
  • Agent2: ${AGENT2_VOTE}

$(warning_color "Both agents must vote YES to reach consensus")

$(info_color "Next steps:")
  • Discuss concerns further
  • Refine the proposal: ai-consensus-refine.sh
  • Vote again

EOF
        "${SCRIPT_DIR}/ai-agent-send-enhanced.sh" System WARNING "⚠️  No consensus - continue discussion"

        warning_color "⚠️  No consensus yet"
        info_color "   Agent1: ${AGENT1_VOTE}"
        info_color "   Agent2: ${AGENT2_VOTE}"
        echo ""
        echo "Continue discussion and refine the proposal!"
    fi
fi
