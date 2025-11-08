#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Code Review - Request Changes
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
    error_color "Usage: $0 <reason>"
    echo ""
    echo "Examples:"
    echo "  $0 'Please address the security issues in auth.js'"
    echo "  $0 'Add unit tests for the new feature'"
    exit 1
fi

REASON="$1"

# Read current state
REVIEWER=$(json_read "$MODE_STATE" '.reviewer')
AUTHOR=$(json_read "$MODE_STATE" '.author')

# Update state - mark as changes requested
if ! json_write "$MODE_STATE" \
    '.status = $status | .approved = false' \
    --arg status "changes_requested"; then
    error_color "❌ Failed to update mode state"
    exit 1
fi

# Announce changes request
"${SCRIPT_DIR}/ai-agent-send-enhanced.sh" "$REVIEWER" "CHANGES" "🔄 Changes Requested" --notify

cat >> /tmp/ai-agents-shared.txt <<EOF

$(warning_color "═══════════════════════════════════════")
$(warning_color " 🔄 CHANGES REQUESTED")
$(warning_color "═══════════════════════════════════════")

$(agent2_color "Reviewer: $REVIEWER")
$(agent1_color "Author: $AUTHOR")

$(warning_color "Reason:")
  $REASON

$(info_color "⚠️  Please address the feedback and update the code")

═══════════════════════════════════════

EOF

warning_color "🔄 Changes requested!"
info_color "   Reviewer: $REVIEWER"
info_color "   Reason: $REASON"
