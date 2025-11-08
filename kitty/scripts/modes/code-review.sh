#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Code Review Mode
# ═══════════════════════════════════════════════════════════
# One agent submits code for review, another provides feedback
#
# Usage:
#   code-review.sh [author] [reviewer] [file_or_description]
#
# Arguments:
#   author   - Agent submitting code (default: Agent1)
#   reviewer - Agent reviewing code (default: Agent2)
#   file     - File being reviewed or description (optional)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/mode-framework.sh"
source "${SCRIPT_DIR}/../lib/constants.sh"

# Parse arguments
AUTHOR="${1:-Agent1}"
REVIEWER="${2:-Agent2}"
TARGET="${3:-unspecified}"

# Build initial state
STATE_JSON=$(cat <<EOF
{
  "mode": "code-review",
  "started": "$(date -Iseconds)",
  "author": "$AUTHOR",
  "reviewer": "$REVIEWER",
  "target": "$TARGET",
  "comments": [],
  "suggestions": [],
  "status": "in_review",
  "approved": false
}
EOF
)

# Initialize mode with framework
if ! mode_init "code-review" "$STATE_JSON" "protocols/code-review-protocol.txt"; then
    error_color "❌ Failed to initialize code review mode"
    exit 1
fi

# Send announcements
mode_blank_line
mode_announce "System" "INFO" "📝 Code Review Mode Started" --notify
mode_announce "System" "INFO" "   Author: $AUTHOR (submits code)"
mode_announce "System" "INFO" "   Reviewer: $REVIEWER (provides feedback)"
if [[ "$TARGET" != "unspecified" ]]; then
    mode_announce "System" "INFO" "   Target: $TARGET"
fi
mode_blank_line

# Display success and commands
success_color "✅ Code review mode active"
info_color "   Author: $AUTHOR"
info_color "   Reviewer: $REVIEWER"

mode_show_commands "code-review" \
    "ai-review-comment.sh <file> <line> \"<comment>\"  # Add review comment" \
    "ai-review-suggest.sh \"<suggestion>\"              # Suggest improvement" \
    "ai-review-approve.sh                              # Approve changes" \
    "ai-review-changes.sh \"<summary>\"                 # Request changes"
