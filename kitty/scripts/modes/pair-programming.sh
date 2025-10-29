#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Pair Programming Mode
# ═══════════════════════════════════════════════════════════
# One agent codes (driver), other reviews in real-time (navigator)

set -euo pipefail

SESSION=${KITTY_AI_SESSION:-ai-agents}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/colors.sh"

DRIVER="${1:-Agent1}"
NAVIGATOR="${2:-Agent2}"
MODE_STATE="/tmp/ai-mode-${SESSION}/pair-programming.json"

# Initialize mode
cat > "$MODE_STATE" <<EOF
{
  "mode": "pair-programming",
  "started": "$(date -Iseconds)",
  "driver": "$DRIVER",
  "navigator": "$NAVIGATOR",
  "switch_interval": 1800,
  "switches": 0
}
EOF

# Clear shared communication
> /tmp/ai-agents-shared.txt

# Announce mode start
"${SCRIPT_DIR}/../ai-agent-send-enhanced.sh" System INFO "🔀 Pair Programming Mode Started" --notify
"${SCRIPT_DIR}/../ai-agent-send-enhanced.sh" System INFO "   Driver: $DRIVER (writes code)"
"${SCRIPT_DIR}/../ai-agent-send-enhanced.sh" System INFO "   Navigator: $NAVIGATOR (reviews & guides)"
echo "" >> /tmp/ai-agents-shared.txt

# Show protocol
cat >> /tmp/ai-agents-shared.txt <<EOF
$(success_color "═══════════════════════════════════════")
$(success_color " Pair Programming Protocol")
$(success_color "═══════════════════════════════════════")

$(agent1_color "Driver ($DRIVER):")
  • Write code and make changes
  • Explain what you're doing
  • Listen to navigator's feedback
  • Ask for clarification when needed

$(agent2_color "Navigator ($NAVIGATOR):")
  • Review code as it's written
  • Spot bugs and suggest improvements
  • Think ahead about edge cases
  • Ask questions to clarify intent

$(shared_color "Commands:")
  • Switch roles: ai-pair-switch.sh
  • Add observation: ai-pair-observe.sh <agent> "<observation>"
  • Mark issue: ai-pair-issue.sh "<issue>" <severity>
  • Complete task: ai-pair-complete.sh "<summary>"

$(warning_color "Switch roles every 30 minutes for best results!")

═══════════════════════════════════════
EOF

success_color "✅ Pair programming mode active"
info_color "   Driver: $DRIVER"
info_color "   Navigator: $NAVIGATOR"
echo ""
echo "Commands available:"
echo "  ai-pair-switch.sh       # Switch driver/navigator roles"
echo "  ai-pair-observe.sh      # Navigator adds observation"
echo "  ai-pair-issue.sh        # Flag an issue"
echo "  ai-pair-complete.sh     # Mark task complete"
