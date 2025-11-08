#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Code Review - Add Comment
# ═══════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/constants.sh"
source "${SCRIPT_DIR}/lib/colors.sh"
source "${SCRIPT_DIR}/lib/json-utils.sh"

MODE_STATE="$AI_AGENTS_STATE_CODE_REVIEW"

# Check if mode is active
if [[ ! -f "$MODE_STATE" ]]; then
    error_color "❌ Code review mode not active!"
    echo "Start with: ai-mode-start.sh code-review"
    exit 1
fi

# Parse arguments
if [[ $# -lt 3 ]]; then
    error_color "Usage: $0 <file> <line> <comment>"
    echo ""
    echo "Examples:"
    echo "  $0 src/auth.js 42 'Add null check here'"
    echo "  $0 lib/utils.py 15 'Consider using list comprehension'"
    exit 1
fi

FILE="$1"
LINE="$2"
COMMENT="$3"

# Read current state
REVIEWER=$(json_read "$MODE_STATE" '.reviewer') || {
    error_color "❌ Failed to read reviewer from mode state"
    exit 1
}
AUTHOR=$(json_read "$MODE_STATE" '.author') || {
    error_color "❌ Failed to read author from mode state"
    exit 1
}
COMMENTS=$(json_read "$MODE_STATE" '.comments') || COMMENTS=0

# Update state - increment comment count
if ! json_write "$MODE_STATE" \
    '.comments = ($comments | tonumber)' \
    --arg comments "$((COMMENTS + 1))"; then
    error_color "❌ Failed to update mode state"
    exit 1
fi

# Announce comment
"${SCRIPT_DIR}/ai-agent-send-enhanced.sh" "$REVIEWER" "REVIEW" "💬 Review Comment" --notify

cat >> /tmp/ai-agents-shared.txt <<EOF

$(info_color "═══════════════════════════════════════")
$(info_color " 💬 Code Review Comment #$((COMMENTS + 1))")
$(info_color "═══════════════════════════════════════")

$(agent2_color "Reviewer: $REVIEWER")
$(agent1_color "File: $FILE:$LINE")

$(warning_color "Comment:")
  $COMMENT

$(dim_color "Total comments: $((COMMENTS + 1))")

═══════════════════════════════════════

EOF

success_color "✅ Comment added!"
info_color "   File: $FILE:$LINE"
info_color "   Comment: $COMMENT"
info_color "   Total comments: $((COMMENTS + 1))"
