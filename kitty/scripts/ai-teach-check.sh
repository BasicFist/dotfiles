#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Teaching Mode - Check Understanding
# ═══════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/colors.sh"
source "${SCRIPT_DIR}/lib/constants.sh"

MODE_STATE="$AI_AGENTS_STATE_TEACHING"
LEARNER="${1:-}"
SUMMARY="${2:-}"

if [[ ! -f "$MODE_STATE" ]]; then
    error_color "❌ Teaching mode not active!"
    exit 1
fi

if [[ -z "$LEARNER" || -z "$SUMMARY" ]]; then
    error_color "Usage: ai-teach-check.sh \"<learner>\" \"<summary>\""
    echo "Example: ai-teach-check.sh Agent2 \"Async functions return promises and allow await keyword inside\""
    exit 1
fi

CURRENT_LEARNER=$(jq -r '.learner' "$MODE_STATE")
EXPERT=$(jq -r '.expert' "$MODE_STATE")

if [[ "$LEARNER" != "$CURRENT_LEARNER" ]]; then
    warning_color "⚠️  $LEARNER is not the current learner ($CURRENT_LEARNER)"
fi

# Present understanding summary
cat >> "$AI_AGENTS_SHARED_FILE" <<EOF

$(agent2_color "╔═══════════════════════════════════════╗")
$(agent2_color "║  📋 ${LEARNER} Understanding Check   ║")
$(agent2_color "╚═══════════════════════════════════════╝")

$(info_color "My understanding:")

$(success_color "$SUMMARY")

$(shared_color "─────────────────────────────────────────")

$(warning_color "${EXPERT}: Please validate this understanding!")
  ✅ Correct? Use: ai-teach-mastered.sh "<concept>"
  ❌ Needs work? Use: ai-teach-explain.sh to clarify

EOF

"${SCRIPT_DIR}/ai-agent-send-enhanced.sh" "$LEARNER" INFO "📋 Shared understanding"

success_color "✅ Understanding check presented"
info_color "   Learner: $LEARNER"
echo ""
echo "Expert ($EXPERT) should validate!"
