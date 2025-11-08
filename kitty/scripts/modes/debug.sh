#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Debug Session Mode
# ═══════════════════════════════════════════════════════════
# Collaborative debugging - one has the bug, another helps solve it
#
# Usage:
#   debug.sh [bug_reporter] [debugger] [bug_description]
#
# Arguments:
#   bug_reporter - Agent with the bug (default: Agent1)
#   debugger     - Agent helping debug (default: Agent2)
#   bug_desc     - Brief bug description (optional)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/mode-framework.sh"
source "${SCRIPT_DIR}/../lib/constants.sh"

# Parse arguments
BUG_REPORTER="${1:-Agent1}"
DEBUGGER="${2:-Agent2}"
BUG_DESC="${3:-Not specified}"

# Build initial state
STATE_JSON=$(cat <<EOF
{
  "mode": "debug",
  "started": "$(date -Iseconds)",
  "bug_reporter": "$BUG_REPORTER",
  "debugger": "$DEBUGGER",
  "bug_description": "$BUG_DESC",
  "findings": [],
  "hypotheses": [],
  "solution": null,
  "status": "investigating",
  "resolved": false
}
EOF
)

# Initialize mode with framework
if ! mode_init "debug" "$STATE_JSON" "protocols/debug-protocol.txt"; then
    error_color "❌ Failed to initialize debug mode"
    exit 1
fi

# Send announcements
mode_blank_line
mode_announce "System" "INFO" "🐛 Debug Session Started" --notify
mode_announce "System" "INFO" "   Reporter: $BUG_REPORTER (has the bug)"
mode_announce "System" "INFO" "   Debugger: $DEBUGGER (helps solve it)"
if [[ "$BUG_DESC" != "Not specified" ]]; then
    mode_announce "System" "INFO" "   Bug: $BUG_DESC"
fi
mode_blank_line

# Display success and commands
success_color "✅ Debug session active"
info_color "   Reporter: $BUG_REPORTER"
info_color "   Debugger: $DEBUGGER"

mode_show_commands "debug" \
    "ai-debug-log.sh \"<finding>\"       # Log a finding" \
    "ai-debug-hypothesis.sh \"<theory>\"  # Propose hypothesis" \
    "ai-debug-solution.sh \"<fix>\"       # Propose solution" \
    "ai-debug-verify.sh \"<result>\"      # Verify fix worked"
