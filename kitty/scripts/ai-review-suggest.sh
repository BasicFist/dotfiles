#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Code Review - Suggest Improvement
# ═══════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/constants.sh"
source "${SCRIPT_DIR}/lib/colors.sh"
source "${SCRIPT_DIR}/lib/json-utils.sh"

MODE_STATE="$AI_AGENTS_STATE_CODE_REVIEW"

if [[ ! -f "$MODE_STATE" ]]; then
    error_color "❌ Code review mode not active!"
    echo "Start with: ai-mode-start.sh code-review"
    exit 1
fi

if [[ $# -lt 1 ]]; then
    error_color "Usage: $0 <suggestion>"
    echo ""
    echo "Examples:"
    echo "  $0 'Extract this logic into a separate function'"
    echo "  $0 'Consider using async/await instead of callbacks'"
    exit 1
fi

SUGGESTION="$1"

# Read current state
REVIEWER=$(json_read "$MODE_STATE" '.reviewer')
SUGGESTIONS=$(json_read "$MODE_STATE" '.suggestions') || SUGGESTIONS=0

# Update state
if ! json_write "$MODE_STATE" \
    '.suggestions = ($suggestions | tonumber)' \
    --arg suggestions "$((SUGGESTIONS + 1))"; then
    error_color "❌ Failed to update mode state"
    exit 1
fi

# Announce suggestion
"${SCRIPT_DIR}/ai-agent-send-enhanced.sh" "$REVIEWER" "SUGGEST" "💡 Suggestion" --notify

cat >> /tmp/ai-agents-shared.txt <<EOF

$(success_color "═══════════════════════════════════════")
$(success_color " 💡 Improvement Suggestion #$((SUGGESTIONS + 1))")
$(success_color "═══════════════════════════════════════")

$(agent2_color "Reviewer: $REVIEWER")

$(warning_color "Suggestion:")
  $SUGGESTION

$(dim_color "Total suggestions: $((SUGGESTIONS + 1))")

═══════════════════════════════════════

EOF

success_color "✅ Suggestion added!"
info_color "   Suggestion: $SUGGESTION"
info_color "   Total suggestions: $((SUGGESTIONS + 1))"
