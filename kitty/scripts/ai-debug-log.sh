#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Debug Session - Log Finding
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
    error_color "Usage: $0 <finding>"
    echo ""
    echo "Examples:"
    echo "  $0 'Error occurs only when user has no profile picture'"
    echo "  $0 'Stack trace shows null pointer in line 42'"
    exit 1
fi

FINDING="$1"

# Read current state
DEBUGGER=$(json_read "$MODE_STATE" '.debugger')
REPORTER=$(json_read "$MODE_STATE" '.bug_reporter')
FINDINGS=$(json_read "$MODE_STATE" '.findings') || FINDINGS=0

# Update state
if ! json_write "$MODE_STATE" \
    '.findings = ($findings | tonumber)' \
    --arg findings "$((FINDINGS + 1))"; then
    error_color "❌ Failed to update mode state"
    exit 1
fi

# Announce finding
"${SCRIPT_DIR}/ai-agent-send-enhanced.sh" "$DEBUGGER" "DEBUG" "🔍 Debug Finding" --notify

cat >> /tmp/ai-agents-shared.txt <<EOF

$(info_color "═══════════════════════════════════════")
$(info_color " 🔍 Debug Finding #$((FINDINGS + 1))")
$(info_color "═══════════════════════════════════════")

$(agent2_color "Debugger: $DEBUGGER")

$(warning_color "Finding:")
  $FINDING

$(dim_color "Total findings: $((FINDINGS + 1))")

═══════════════════════════════════════

EOF

success_color "✅ Finding logged!"
info_color "   Finding: $FINDING"
info_color "   Total findings: $((FINDINGS + 1))"
