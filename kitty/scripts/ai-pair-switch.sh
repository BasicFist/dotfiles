#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Pair Programming - Switch Roles
# ═══════════════════════════════════════════════════════════

set -euo pipefail

SESSION=${KITTY_AI_SESSION:-ai-agents}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/colors.sh"

MODE_STATE="/tmp/ai-mode-${SESSION}/pair-programming.json"

if [[ ! -f "$MODE_STATE" ]]; then
    error_color "❌ Pair programming mode not active!"
    echo "Start with: ai-mode-start.sh pair"
    exit 1
fi

# Read current state
DRIVER=$(jq -r '.driver' "$MODE_STATE")
NAVIGATOR=$(jq -r '.navigator' "$MODE_STATE")
SWITCHES=$(jq -r '.switches' "$MODE_STATE")

# Swap roles
if [[ "$DRIVER" == "Agent1" ]]; then
    NEW_DRIVER="Agent2"
    NEW_NAVIGATOR="Agent1"
else
    NEW_DRIVER="Agent1"
    NEW_NAVIGATOR="Agent2"
fi

# Update state
jq --arg driver "$NEW_DRIVER" \
   --arg navigator "$NEW_NAVIGATOR" \
   --arg switches "$((SWITCHES + 1))" \
   '.driver = $driver | .navigator = $navigator | .switches = ($switches | tonumber)' \
   "$MODE_STATE" > "${MODE_STATE}.tmp" && mv "${MODE_STATE}.tmp" "$MODE_STATE"

# Announce switch
"${SCRIPT_DIR}/ai-agent-send-enhanced.sh" System INFO "🔄 Roles Switched!" --notify --blink

cat >> /tmp/ai-agents-shared.txt <<EOF

$(success_color "═══════════════════════════════════════")
$(success_color " 🔄 Role Switch #$((SWITCHES + 1))")
$(success_color "═══════════════════════════════════════")

$(agent1_color "Driver: $NEW_DRIVER")
  • Write code and make changes
  • Explain what you're doing

$(agent2_color "Navigator: $NEW_NAVIGATOR")
  • Review code as it's written
  • Spot bugs and suggest improvements

$(warning_color "Switch complete - continue working!")

═══════════════════════════════════════

EOF

success_color "✅ Roles switched!"
info_color "   Driver: $NEW_DRIVER"
info_color "   Navigator: $NEW_NAVIGATOR"
info_color "   Total switches: $((SWITCHES + 1))"
