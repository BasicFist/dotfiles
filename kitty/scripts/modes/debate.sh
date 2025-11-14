#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Debate Mode
# ═══════════════════════════════════════════════════════════
# Agents discuss different approaches before implementing

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/mode-framework.sh"
source "${SCRIPT_DIR}/../lib/constants.sh"

TOPIC="${1:-No topic specified}"

STATE_JSON=$(cat <<EOF
{
  "mode": "debate",
  "started": "$(date -Iseconds)",
  "topic": "$TOPIC",
  "positions": {
    "Agent1": null,
    "Agent2": null
  },
  "arguments": [],
  "consensus_reached": false
}
EOF
)

if ! mode_init "debate" "$STATE_JSON" "protocols/debate-protocol.txt"; then
    error_color "❌ Failed to initialize debate mode"
    exit 1
fi

mode_blank_line
mode_announce "System" "INFO" "💭 Debate Mode Started" --notify
mode_announce "System" "INFO" "   Topic: $TOPIC"
mode_blank_line

success_color "✅ Debate mode active"
info_color "   Topic: $TOPIC"

mode_show_commands "debate" \
    "ai-debate-position.sh <agent> \"<position>\"   # Record opening statement" \
    "ai-debate-argue.sh <agent> \"<argument>\"     # Submit supporting argument" \
    "ai-debate-rebut.sh <agent> \"<rebuttal>\"     # Rebut the other agent" \
    "ai-debate-consensus.sh \"<solution>\"          # Capture synthesis decision"

mode_blank_line
info_color "Start by capturing positions:"
info_color "  ai-debate-position.sh Agent1 \"Approach A because...\""
info_color "  ai-debate-position.sh Agent2 \"Approach B because...\""
