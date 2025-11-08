#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Debug Session - Verify Fix
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

# Optional verification result (success/failure)
RESULT="${1:-success}"

# Read current state
REPORTER=$(json_read "$MODE_STATE" '.bug_reporter')
DEBUGGER=$(json_read "$MODE_STATE" '.debugger')
SOLUTION=$(json_read "$MODE_STATE" '.solution') || SOLUTION="N/A"

if [[ "$RESULT" == "success" ]]; then
    # Mark as resolved
    if ! json_write "$MODE_STATE" \
        '.status = $status | .resolved = true' \
        --arg status "resolved"; then
        error_color "❌ Failed to update mode state"
        exit 1
    fi

    # Announce success
    "${SCRIPT_DIR}/ai-agent-send-enhanced.sh" "$REPORTER" "SUCCESS" "✅ Bug Fixed!" --notify --blink

    cat >> /tmp/ai-agents-shared.txt <<EOF

$(success_color "═══════════════════════════════════════")
$(success_color " ✅ BUG FIXED - VERIFICATION SUCCESSFUL")
$(success_color "═══════════════════════════════════════")

$(agent1_color "Reporter: $REPORTER")
$(agent2_color "Debugger: $DEBUGGER")

$(success_color "Solution:")
  $SOLUTION

$(success_color "✓ Bug has been verified as fixed!")
$(success_color "✓ Debug session complete")

═══════════════════════════════════════

EOF

    success_color "✅ Bug verified as fixed!"
    info_color "   Solution worked: $SOLUTION"
else
    # Mark as still investigating
    if ! json_write "$MODE_STATE" \
        '.status = $status | .resolved = false' \
        --arg status "investigating"; then
        error_color "❌ Failed to update mode state"
        exit 1
    fi

    # Announce need for more investigation
    "${SCRIPT_DIR}/ai-agent-send-enhanced.sh" "$DEBUGGER" "INVESTIGATE" "🔍 More Investigation Needed" --notify

    cat >> /tmp/ai-agents-shared.txt <<EOF

$(warning_color "═══════════════════════════════════════")
$(warning_color " 🔍 VERIFICATION FAILED - CONTINUE INVESTIGATING")
$(warning_color "═══════════════════════════════════════")

$(agent1_color "Reporter: $REPORTER")
$(agent2_color "Debugger: $DEBUGGER")

$(warning_color "Issue:")
  The proposed solution didn't fix the bug

$(info_color "⚙️  Continue investigation with new hypothesis")

═══════════════════════════════════════

EOF

    warning_color "⚠️  Solution didn't work - continue investigating"
    info_color "   Try a different approach or hypothesis"
fi
