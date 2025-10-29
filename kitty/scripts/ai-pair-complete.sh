#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Pair Programming - Complete Task
# ═══════════════════════════════════════════════════════════

set -euo pipefail

SESSION=${KITTY_AI_SESSION:-ai-agents}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/colors.sh"

MODE_STATE="/tmp/ai-mode-${SESSION}/pair-programming.json"
SUMMARY="${1:-}"

if [[ ! -f "$MODE_STATE" ]]; then
    error_color "❌ Pair programming mode not active!"
    exit 1
fi

if [[ -z "$SUMMARY" ]]; then
    error_color "Usage: ai-pair-complete.sh \"<summary>\""
    echo "Example: ai-pair-complete.sh \"Implemented binary search with edge case handling\""
    exit 1
fi

# Read final state
DRIVER=$(jq -r '.driver' "$MODE_STATE")
NAVIGATOR=$(jq -r '.navigator' "$MODE_STATE")
SWITCHES=$(jq -r '.switches' "$MODE_STATE")
STARTED=$(jq -r '.started' "$MODE_STATE")
DURATION=$(($(date +%s) - $(date -d "$STARTED" +%s)))
MINUTES=$((DURATION / 60))

# Create completion report
cat >> /tmp/ai-agents-shared.txt <<EOF

$(success_color "═══════════════════════════════════════")
$(success_color " ✅ TASK COMPLETED!")
$(success_color "═══════════════════════════════════════")

$(info_color "Summary:")
$(success_color "$SUMMARY")

$(info_color "Session Stats:")
  • Duration: ${MINUTES} minutes
  • Role switches: ${SWITCHES}
  • Final driver: ${DRIVER}
  • Final navigator: ${NAVIGATOR}

$(shared_color "Great collaboration! 🎉")

$(warning_color "Run ai-session-save.sh to preserve this session!")

═══════════════════════════════════════

EOF

# Send completion notification
"${SCRIPT_DIR}/ai-agent-send-enhanced.sh" System RESULT "✅ Task Complete: $SUMMARY" --notify

# Offer to save session
cat <<EOF

$(success_color "✅ Pair programming task completed!")
$(info_color "   Duration: ${MINUTES} minutes")
$(info_color "   Role switches: ${SWITCHES}")
echo ""
echo "Save this session? Run:"
echo "  ai-session-save.sh \"pair-$(date +%Y%m%d-%H%M)\" \"$SUMMARY\""
echo ""
echo "Or start a new task:"
echo "  ai-mode-start.sh pair"
EOF
