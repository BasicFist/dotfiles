#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Debug Session - Record Hypothesis
# ═══════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/constants.sh"
source "${SCRIPT_DIR}/lib/colors.sh"
source "${SCRIPT_DIR}/lib/json-utils.sh"

MODE_STATE="$AI_AGENTS_STATE_DEBUG"

if [[ ! -f "$MODE_STATE" ]]; then
    error_color "❌ Debug session not active!"
    echo "Start with: ai-mode-start.sh debug"
    exit 1
fi

if [[ $# -lt 1 ]]; then
    error_color "Usage: $0 <hypothesis>"
    echo ""
    echo "Examples:"
    echo "  $0 'The bug is caused by race condition in async code'"
    echo "  $0 'Database migration didnt run on production'"
    exit 1
fi

HYPOTHESIS="$1"

# Read current state
DEBUGGER=$(json_read "$MODE_STATE" '.debugger')
HYPOTHESES=$(json_read "$MODE_STATE" '.hypotheses') || HYPOTHESES=0

# Update state
if ! json_write "$MODE_STATE" \
    '.hypotheses = ($hypotheses | tonumber)' \
    --arg hypotheses "$((HYPOTHESES + 1))"; then
    error_color "❌ Failed to update mode state"
    exit 1
fi

# Announce hypothesis
"${SCRIPT_DIR}/ai-agent-send-enhanced.sh" "$DEBUGGER" "HYPOTHESIS" "💭 Hypothesis" --notify

cat >> /tmp/ai-agents-shared.txt <<EOF

$(success_color "═══════════════════════════════════════")
$(success_color " 💭 Hypothesis #$((HYPOTHESES + 1))")
$(success_color "═══════════════════════════════════════")

$(agent2_color "Debugger: $DEBUGGER")

$(warning_color "Hypothesis:")
  $HYPOTHESIS

$(info_color "🧪 Test this hypothesis to verify")
$(dim_color "Total hypotheses: $((HYPOTHESES + 1))")

═══════════════════════════════════════

EOF

success_color "✅ Hypothesis recorded!"
info_color "   Hypothesis: $HYPOTHESIS"
info_color "   Total hypotheses: $((HYPOTHESES + 1))"
