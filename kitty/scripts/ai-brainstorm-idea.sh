#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Brainstorm - Add Idea
# ═══════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/constants.sh"
source "${SCRIPT_DIR}/lib/colors.sh"
source "${SCRIPT_DIR}/lib/json-utils.sh"

MODE_STATE="$AI_AGENTS_STATE_BRAINSTORM"

if [[ ! -f "$MODE_STATE" ]]; then
    error_color "❌ Brainstorm mode not active!"
    echo "Start with: ai-mode-start.sh brainstorm"
    exit 1
fi

if [[ $# -lt 1 ]]; then
    error_color "Usage: $0 <idea>"
    echo ""
    echo "Examples:"
    echo "  $0 'Use Redis for caching API responses'"
    echo "  $0 'Implement lazy loading for images'"
    exit 1
fi

IDEA="$1"
CONTRIBUTOR="${2:-System}"

# Read current state
TOPIC=$(json_read "$MODE_STATE" '.topic')
IDEAS=$(json_read "$MODE_STATE" '.ideas') || IDEAS=0
PHASE=$(json_read "$MODE_STATE" '.phase') || PHASE="diverge"

# Check if in diverge phase
if [[ "$PHASE" != "diverge" ]]; then
    warning_color "⚠️  Not in DIVERGE phase (current: $PHASE)"
    info_color "   Ideas are best added during the DIVERGE phase"
fi

# Update state
if ! json_write "$MODE_STATE" \
    '.ideas = ($ideas | tonumber)' \
    --arg ideas "$((IDEAS + 1))"; then
    error_color "❌ Failed to update mode state"
    exit 1
fi

# Announce idea
"${SCRIPT_DIR}/ai-agent-send-enhanced.sh" "$CONTRIBUTOR" "IDEA" "💡 New Idea" --notify

cat >> /tmp/ai-agents-shared.txt <<EOF

$(success_color "═══════════════════════════════════════")
$(success_color " 💡 Idea #$((IDEAS + 1))")
$(success_color "═══════════════════════════════════════")

$(agent1_color "Contributor: $CONTRIBUTOR")
$(info_color "Topic: $TOPIC")

$(warning_color "Idea:")
  $IDEA

$(dim_color "Total ideas: $((IDEAS + 1)) | Phase: $PHASE")

═══════════════════════════════════════

EOF

success_color "✅ Idea added!"
info_color "   Idea: $IDEA"
info_color "   Total ideas: $((IDEAS + 1))"
