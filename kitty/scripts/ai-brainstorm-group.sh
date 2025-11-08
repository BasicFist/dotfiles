#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Brainstorm - Group Ideas
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
    error_color "Usage: $0 <group_name>"
    echo ""
    echo "Examples:"
    echo "  $0 'Performance Improvements'"
    echo "  $0 'UI/UX Enhancements'"
    exit 1
fi

GROUP_NAME="$1"

# Read current state
TOPIC=$(json_read "$MODE_STATE" '.topic')
GROUPS=$(json_read "$MODE_STATE" '.groups') || GROUPS=0

# Update state - advance to group phase
if ! json_write "$MODE_STATE" \
    '.groups = ($groups | tonumber) | .phase = $phase' \
    --arg groups "$((GROUPS + 1))" \
    --arg phase "group"; then
    error_color "❌ Failed to update mode state"
    exit 1
fi

# Announce grouping
"${SCRIPT_DIR}/ai-agent-send-enhanced.sh" "System" "GROUP" "📦 Group Created" --notify

cat >> /tmp/ai-agents-shared.txt <<EOF

$(info_color "═══════════════════════════════════════")
$(info_color " 📦 Group #$((GROUPS + 1)): $GROUP_NAME")
$(info_color "═══════════════════════════════════════")

$(info_color "Topic: $TOPIC")
$(success_color "Phase: GROUP - Organizing ideas")

$(warning_color "Group:")
  $GROUP_NAME

$(dim_color "Total groups: $((GROUPS + 1))")
$(info_color "💡 Add similar ideas to this group")

═══════════════════════════════════════

EOF

success_color "✅ Group created!"
info_color "   Group: $GROUP_NAME"
info_color "   Total groups: $((GROUPS + 1))"
info_color "   Phase: GROUP"
