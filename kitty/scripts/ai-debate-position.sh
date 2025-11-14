#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Debate Mode - State Position
# ═══════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/colors.sh"
source "${SCRIPT_DIR}/lib/constants.sh"

MODE_STATE="$AI_AGENTS_STATE_DEBATE"
AGENT="${1:-}"
POSITION="${2:-}"

if [[ ! -f "$MODE_STATE" ]]; then
    error_color "❌ Debate mode not active!"
    exit 1
fi

if [[ -z "$AGENT" || -z "$POSITION" ]]; then
    error_color "Usage: ai-debate-position.sh <agent> \"<position>\""
    echo "Example: ai-debate-position.sh Agent1 \"I propose approach A because it's more scalable\""
    exit 1
fi

# Update state with position
jq --arg agent "$AGENT" \
   --arg position "$POSITION" \
   '.positions[$agent] = $position' \
   "$MODE_STATE" > "${MODE_STATE}.tmp" && mv "${MODE_STATE}.tmp" "$MODE_STATE"

# Determine agent color
if [[ "$AGENT" == "Agent1" ]]; then
    AGENT_COLOR="$AGENT1_COLOR"
else
    AGENT_COLOR="$AGENT2_COLOR"
fi

# Announce position
cat >> "$AI_AGENTS_SHARED_FILE" <<EOF

${AGENT_COLOR}═══════════════════════════════════════${RESET}
${AGENT_COLOR}📢 ${AGENT} - Opening Statement${RESET}
${AGENT_COLOR}═══════════════════════════════════════${RESET}

$(success_color "$POSITION")

${AGENT_COLOR}═══════════════════════════════════════${RESET}

EOF

"${SCRIPT_DIR}/ai-agent-send-enhanced.sh" "$AGENT" INFO "📢 Position stated"

success_color "✅ Position recorded for $AGENT"

# Check if both positions are in
AGENT1_POS=$(jq -r '.positions.Agent1' "$MODE_STATE")
AGENT2_POS=$(jq -r '.positions.Agent2' "$MODE_STATE")

if [[ "$AGENT1_POS" != "null" && "$AGENT2_POS" != "null" ]]; then
    cat >> "$AI_AGENTS_SHARED_FILE" <<EOF
$(success_color "════════════════════════════════════════")
$(success_color " ✅ Both positions stated!")
$(success_color "════════════════════════════════════════")

$(info_color "Round 1 Complete - Moving to Round 2: Arguments")
$(info_color "Present supporting evidence and reasoning")

$(shared_color "Use: ai-debate-argue.sh <agent> \"<argument>\" [evidence]")

EOF
    "${SCRIPT_DIR}/ai-agent-send-enhanced.sh" System INFO "🎯 Ready for arguments!" --notify
fi
