#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Code Review - Approve Changes
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

# Optional approval message
MESSAGE="${1:-Looks good to me! LGTM 👍}"

# Read current state
REVIEWER=$(json_read "$MODE_STATE" '.reviewer')
AUTHOR=$(json_read "$MODE_STATE" '.author')

# Update state - mark as approved
if ! json_write "$MODE_STATE" \
    '.status = $status | .approved = true' \
    --arg status "approved"; then
    error_color "❌ Failed to update mode state"
    exit 1
fi

# Announce approval
"${SCRIPT_DIR}/ai-agent-send-enhanced.sh" "$REVIEWER" "APPROVE" "✅ Code Approved!" --notify --blink

cat >> /tmp/ai-agents-shared.txt <<EOF

$(success_color "═══════════════════════════════════════")
$(success_color " ✅ CODE REVIEW APPROVED")
$(success_color "═══════════════════════════════════════")

$(agent2_color "Reviewer: $REVIEWER")
$(agent1_color "Author: $AUTHOR")

$(success_color "Approval Message:")
  $MESSAGE

$(success_color "✓ Review complete - ready to merge!")

═══════════════════════════════════════

EOF

success_color "✅ Code review approved!"
info_color "   Reviewer: $REVIEWER"
info_color "   Message: $MESSAGE"
