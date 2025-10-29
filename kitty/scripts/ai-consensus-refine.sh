#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Consensus Mode - Refine Proposal
# ═══════════════════════════════════════════════════════════

set -euo pipefail

SESSION=${KITTY_AI_SESSION:-ai-agents}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/colors.sh"

MODE_STATE="/tmp/ai-mode-${SESSION}/consensus.json"
REFINED_PROPOSAL="${1:-}"

if [[ ! -f "$MODE_STATE" ]]; then
    error_color "❌ Consensus mode not active!"
    exit 1
fi

if [[ -z "$REFINED_PROPOSAL" ]]; then
    error_color "Usage: ai-consensus-refine.sh \"<refined proposal>\""
    echo "Example: ai-consensus-refine.sh \"Hybrid approach: microservices for core services, monolith for admin\""
    exit 1
fi

# Present refined proposal
cat >> /tmp/ai-agents-shared.txt <<EOF

$(shared_color "╔═══════════════════════════════════════╗")
$(shared_color "║  🔄 REFINED PROPOSAL                  ║")
$(shared_color "╚═══════════════════════════════════════╝")

$(success_color "$REFINED_PROPOSAL")

$(info_color "─────────────────────────────────────────")
$(info_color "This refined proposal addresses concerns from both agents")

$(shared_color "Next Steps:")
  • Review the refinement
  • Vote when ready: ai-consensus-vote.sh <agent> <yes|no|abstain>
  • **Both must vote YES to proceed**

$(shared_color "╚═══════════════════════════════════════╝")

EOF

"${SCRIPT_DIR}/ai-agent-send-enhanced.sh" System INFO "🔄 Proposal refined" --notify

success_color "✅ Refined proposal presented"
echo ""
echo "Agents should now vote:"
echo "  ai-consensus-vote.sh Agent1 yes"
echo "  ai-consensus-vote.sh Agent2 yes"
