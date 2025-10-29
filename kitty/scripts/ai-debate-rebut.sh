#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Debate Mode - Present Rebuttal
# ═══════════════════════════════════════════════════════════

set -euo pipefail

SESSION=${KITTY_AI_SESSION:-ai-agents}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/colors.sh"

MODE_STATE="/tmp/ai-mode-${SESSION}/debate.json"
AGENT="${1:-}"
REBUTTAL="${2:-}"

if [[ ! -f "$MODE_STATE" ]]; then
    error_color "❌ Debate mode not active!"
    exit 1
fi

if [[ -z "$AGENT" || -z "$REBUTTAL" ]]; then
    error_color "Usage: ai-debate-rebut.sh <agent> \"<rebuttal>\""
    echo "Example: ai-debate-rebut.sh Agent2 \"While scalability is important, reliability is critical here\""
    exit 1
fi

# Determine agent color
if [[ "$AGENT" == "Agent1" ]]; then
    AGENT_COLOR="$AGENT1_COLOR"
else
    AGENT_COLOR="$AGENT2_COLOR"
fi

# Present rebuttal
cat >> /tmp/ai-agents-shared.txt <<EOF

${AGENT_COLOR}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${RESET}
${AGENT_COLOR}🔥 ${AGENT} - Rebuttal${RESET}
${AGENT_COLOR}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${RESET}

$(warning_color "$REBUTTAL")

${AGENT_COLOR}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${RESET}

EOF

"${SCRIPT_DIR}/ai-agent-send-enhanced.sh" "$AGENT" WARNING "🔥 Rebuttal presented"

success_color "✅ Rebuttal recorded for $AGENT"
