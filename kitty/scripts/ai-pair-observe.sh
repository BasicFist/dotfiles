#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Pair Programming - Navigator Observation
# ═══════════════════════════════════════════════════════════

set -euo pipefail

SESSION=${KITTY_AI_SESSION:-ai-agents}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/colors.sh"

MODE_STATE="/tmp/ai-mode-${SESSION}/pair-programming.json"
AGENT="${1:-}"
OBSERVATION="${2:-}"

if [[ ! -f "$MODE_STATE" ]]; then
    error_color "❌ Pair programming mode not active!"
    exit 1
fi

if [[ -z "$AGENT" || -z "$OBSERVATION" ]]; then
    error_color "Usage: ai-pair-observe.sh <agent> \"<observation>\""
    echo "Example: ai-pair-observe.sh Agent2 \"Consider edge case: empty array\""
    exit 1
fi

NAVIGATOR=$(jq -r '.navigator' "$MODE_STATE")

if [[ "$AGENT" != "$NAVIGATOR" ]]; then
    warning_color "⚠️  $AGENT is not the current navigator ($NAVIGATOR)"
    warning_color "    Only the navigator should make observations"
fi

# Send observation
"${SCRIPT_DIR}/ai-agent-send-enhanced.sh" "$AGENT" INFO "💡 $OBSERVATION"

cat >> /tmp/ai-agents-shared.txt <<EOF
$(shared_color "────────────────────────────────────────")
$(shared_color "Navigator Observation:")
$(info_color "$OBSERVATION")
$(shared_color "────────────────────────────────────────")

EOF

success_color "✅ Observation logged"
