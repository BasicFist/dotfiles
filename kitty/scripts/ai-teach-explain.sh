#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Teaching Mode - Expert Explains Concept
# ═══════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/colors.sh"
source "${SCRIPT_DIR}/lib/constants.sh"

MODE_STATE="$AI_AGENTS_STATE_TEACHING"
EXPERT="${1:-}"
CONCEPT="${2:-}"
EXPLANATION="${3:-}"

if [[ ! -f "$MODE_STATE" ]]; then
    error_color "❌ Teaching mode not active!"
    exit 1
fi

if [[ -z "$EXPERT" || -z "$CONCEPT" || -z "$EXPLANATION" ]]; then
    error_color "Usage: ai-teach-explain.sh \"<expert>\" \"<concept>\" \"<explanation>\""
    echo "Example: ai-teach-explain.sh Agent1 \"Async/Await\" \"Async functions allow non-blocking code execution...\""
    exit 1
fi

CURRENT_EXPERT=$(jq -r '.expert' "$MODE_STATE")

if [[ "$EXPERT" != "$CURRENT_EXPERT" ]]; then
    warning_color "⚠️  $EXPERT is not the current expert ($CURRENT_EXPERT)"
fi

# Add concept to covered list
jq --arg concept "$CONCEPT" \
   '.concepts_covered += [$concept] | .concepts_covered |= unique' \
   "$MODE_STATE" > "${MODE_STATE}.tmp" && mv "${MODE_STATE}.tmp" "$MODE_STATE"

# Present explanation
cat >> "$AI_AGENTS_SHARED_FILE" <<EOF

$(agent1_color "═══════════════════════════════════════")
$(agent1_color " 🎓 ${EXPERT} Explains: ${CONCEPT}")
$(agent1_color "═══════════════════════════════════════")

$(info_color "$EXPLANATION")

$(agent1_color "═══════════════════════════════════════")

EOF

"${SCRIPT_DIR}/ai-agent-send-enhanced.sh" "$EXPERT" INFO "🎓 Explained: $CONCEPT"

success_color "✅ Concept explained: $CONCEPT"
info_color "   Expert: $EXPERT"

# Count concepts
NUM_CONCEPTS=$(jq '.concepts_covered | length' "$MODE_STATE")
info_color "   Total concepts covered: $NUM_CONCEPTS"
