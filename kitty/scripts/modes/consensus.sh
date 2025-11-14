#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Consensus Mode
# ═══════════════════════════════════════════════════════════
# Agents must reach agreement before proceeding

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/mode-framework.sh"
source "${SCRIPT_DIR}/../lib/constants.sh"

DECISION="${1:-Decision not specified}"

STATE_JSON=$(cat <<EOF
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
)

if ! mode_init "consensus" "$STATE_JSON" "protocols/consensus-protocol.txt"; then
    error_color "❌ Failed to initialize consensus mode"
    exit 1
fi

mode_blank_line
mode_announce "System" "INFO" "🤝 Consensus Mode Started" --notify
mode_announce "System" "INFO" "   Decision: $DECISION"
mode_blank_line

success_color "✅ Consensus mode active"
info_color "   Decision: $DECISION"

mode_show_commands "consensus" \
    "ai-consensus-propose.sh <agent> \"<proposal>\"    # Add proposal" \
    "ai-consensus-concern.sh <agent> \"<concern>\"    # Log concern" \
    "ai-consensus-refine.sh \"<refined plan>\"         # Refine proposal" \
    "ai-consensus-vote.sh <agent> <yes|no|abstain>  # Record vote" \
    "ai-consensus-agree.sh \"<final decision>\"       # Finalize"

mode_blank_line
info_color "Start by submitting proposals:"
info_color "  ai-consensus-propose.sh Agent1 \"Let's build service A\""
info_color "  ai-consensus-propose.sh Agent2 \"Alternative approach...\""
warning_color "⚠️  Work pauses until both agents vote yes."
