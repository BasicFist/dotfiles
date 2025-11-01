#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Pair Programming - Switch Roles
# ═══════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/constants.sh"
source "${SCRIPT_DIR}/lib/colors.sh"
source "${SCRIPT_DIR}/lib/json-utils.sh"

MODE_STATE="$AI_AGENTS_STATE_PAIR"

if [[ ! -f "$MODE_STATE" ]]; then
    error_color "❌ Pair programming mode not active!"
    echo "Start with: ai-mode-start.sh pair"
    exit 1
fi

# Read current state with error handling
DRIVER=$(json_read "$MODE_STATE" '.driver') || {
    error_color "❌ Failed to read driver from mode state"
    exit 1
}
NAVIGATOR=$(json_read "$MODE_STATE" '.navigator') || {
    error_color "❌ Failed to read navigator from mode state"
    exit 1
}
SWITCHES=$(json_read "$MODE_STATE" '.switches') || {
    error_color "❌ Failed to read switches from mode state"
    exit 1
}

# Log current state for visibility
info_color "Current state: Driver=$DRIVER, Navigator=$NAVIGATOR, Switches=$SWITCHES"

# Swap roles
if [[ "$DRIVER" == "Agent1" ]]; then
    NEW_DRIVER="Agent2"
    NEW_NAVIGATOR="Agent1"
else
    NEW_DRIVER="Agent1"
    NEW_NAVIGATOR="Agent2"
fi

# Update state with error handling
if ! json_write "$MODE_STATE" \
    '.driver = $driver | .navigator = $navigator | .switches = ($switches | tonumber)' \
    --arg driver "$NEW_DRIVER" \
    --arg navigator "$NEW_NAVIGATOR" \
    --arg switches "$((SWITCHES + 1))"; then
    error_color "❌ Failed to update mode state"
    exit 1
fi

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
