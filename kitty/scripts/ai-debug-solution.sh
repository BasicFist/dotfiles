#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Debug Session - Propose Solution
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
    error_color "Usage: $0 <solution>"
    echo ""
    echo "Examples:"
    echo "  $0 'Add null check before accessing user.profile'"
    echo "  $0 'Run database migration: npm run migrate'"
    exit 1
fi

SOLUTION="$1"

# Read current state
DEBUGGER=$(json_read "$MODE_STATE" '.debugger')
REPORTER=$(json_read "$MODE_STATE" '.bug_reporter')

# Update state - record solution
if ! json_write "$MODE_STATE" \
    '.solution = $solution | .status = $status' \
    --arg solution "$SOLUTION" \
    --arg status "solution_proposed"; then
    error_color "❌ Failed to update mode state"
    exit 1
fi

# Announce solution
"${SCRIPT_DIR}/ai-agent-send-enhanced.sh" "$DEBUGGER" "SOLUTION" "🔧 Solution Proposed" --notify

cat >> /tmp/ai-agents-shared.txt <<EOF

$(success_color "═══════════════════════════════════════")
$(success_color " 🔧 SOLUTION PROPOSED")
$(success_color "═══════════════════════════════════════")

$(agent2_color "Debugger: $DEBUGGER")
$(agent1_color "Reporter: $REPORTER")

$(success_color "Proposed Solution:")
  $SOLUTION

$(info_color "⚙️  Test the solution and verify it fixes the bug")

═══════════════════════════════════════

EOF

success_color "✅ Solution proposed!"
info_color "   Solution: $SOLUTION"
info_color "   Next: Verify the fix works"
