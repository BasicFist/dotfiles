#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Brainstorm - Refine Top Ideas
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

if [[ $# -lt 2 ]]; then
    error_color "Usage: $0 <idea_number> <refinement>"
    echo ""
    echo "Examples:"
    echo "  $0 3 'Use Redis with 5min TTL for user sessions'"
    echo "  $0 7 'Implement lazy loading with Intersection Observer API'"
    exit 1
fi

IDEA_NUM="$1"
REFINEMENT="$2"

# Read current state
TOPIC=$(json_read "$MODE_STATE" '.topic')
IDEAS=$(json_read "$MODE_STATE" '.ideas') || IDEAS=0

# Update state - advance to refine phase and mark as complete
if ! json_write "$MODE_STATE" \
    '.phase = $phase | .status = $status' \
    --arg phase "refine" \
    --arg status "complete"; then
    error_color "❌ Failed to update mode state"
    exit 1
fi

# Announce refinement
"${SCRIPT_DIR}/ai-agent-send-enhanced.sh" "System" "REFINE" "✨ Idea Refined" --notify --blink

cat >> /tmp/ai-agents-shared.txt <<EOF

$(success_color "═══════════════════════════════════════")
$(success_color " ✨ Refined Idea #$IDEA_NUM")
$(success_color "═══════════════════════════════════════")

$(info_color "Topic: $TOPIC")
$(success_color "Phase: REFINE - Adding details")

$(warning_color "Refinement:")
  $REFINEMENT

$(success_color "✓ Ready for implementation!")

═══════════════════════════════════════

EOF

success_color "✅ Idea refined!"
info_color "   Idea: #$IDEA_NUM"
info_color "   Refinement: $REFINEMENT"
info_color "   Phase: REFINE"
info_color "   Status: Ready for action!"
