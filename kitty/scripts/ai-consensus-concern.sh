#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Consensus Mode - Voice Concern
# ═══════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/colors.sh"
source "${SCRIPT_DIR}/lib/constants.sh"

MODE_STATE="$AI_AGENTS_STATE_CONSENSUS"
AGENT="${1:-}"
CONCERN="${2:-}"

if [[ ! -f "$MODE_STATE" ]]; then
    error_color "❌ Consensus mode not active!"
    exit 1
fi

if [[ -z "$AGENT" || -z "$CONCERN" ]]; then
    error_color "Usage: ai-consensus-concern.sh <agent> \"<concern>\""
    echo "Example: ai-consensus-concern.sh Agent2 \"Microservices may add too much operational complexity\""
    exit 1
fi

# Determine agent color
if [[ "$AGENT" == "Agent1" ]]; then
    AGENT_COLOR="$AGENT1_COLOR"
else
    AGENT_COLOR="$AGENT2_COLOR"
fi

# Present concern
cat >> "$AI_AGENTS_SHARED_FILE" <<EOF

${AGENT_COLOR}▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼${RESET}
${AGENT_COLOR} ⚠️  ${AGENT} - Concern${RESET}
${AGENT_COLOR}▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼${RESET}

$(warning_color "$CONCERN")

${AGENT_COLOR}▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲${RESET}

EOF

"${SCRIPT_DIR}/ai-agent-send-enhanced.sh" "$AGENT" WARNING "⚠️  Concern raised"

success_color "✅ Concern voiced by $AGENT"
echo ""
info_color "Other agent should address this concern or refine the proposal"
