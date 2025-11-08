#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Brainstorm - Vote on Ideas
# ═══════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/constants.sh"
source "${SCRIPT_DIR}/lib/colors.sh"
source "${SCRIPT_DIR}/lib/json-utils.sh"

MODE_STATE="$AI_AGENTS_STATE_BRAINSTORM"

if [[ ! -f "$MODE_STATE" ]]; then
    error_color "❌ Brainstorm mode not active!"
    echo "Start with: ai-mode-start.sh brainstorm"
    exit 1
fi

if [[ $# -lt 2 ]]; then
    error_color "Usage: $0 <idea_number> <voter_name>"
    echo ""
    echo "Examples:"
    echo "  $0 3 Agent1"
    echo "  $0 7 Agent2"
    exit 1
fi

IDEA_NUM="$1"
VOTER="$2"

# Read current state
TOPIC=$(json_read "$MODE_STATE" '.topic')
VOTES=$(json_read "$MODE_STATE" '.votes') || VOTES=0

# Update state - advance to converge phase
if ! json_write "$MODE_STATE" \
    '.votes = ($votes | tonumber) | .phase = $phase' \
    --arg votes "$((VOTES + 1))" \
    --arg phase "converge"; then
    error_color "❌ Failed to update mode state"
    exit 1
fi

# Announce vote
"${SCRIPT_DIR}/ai-agent-send-enhanced.sh" "$VOTER" "VOTE" "🗳️  Vote Cast" --notify

cat >> /tmp/ai-agents-shared.txt <<EOF

$(success_color "═══════════════════════════════════════")
$(success_color " 🗳️  Vote Cast")
$(success_color "═══════════════════════════════════════")

$(agent1_color "Voter: $VOTER")
$(info_color "Topic: $TOPIC")
$(success_color "Phase: CONVERGE - Evaluating ideas")

$(warning_color "Voted for:")
  Idea #$IDEA_NUM

$(dim_color "Total votes: $((VOTES + 1))")

═══════════════════════════════════════

EOF

success_color "✅ Vote recorded!"
info_color "   Voter: $VOTER"
info_color "   Idea: #$IDEA_NUM"
info_color "   Total votes: $((VOTES + 1))"
