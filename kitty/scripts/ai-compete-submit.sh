#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Competition Mode - Submit Solution
# ═══════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/colors.sh"
source "${SCRIPT_DIR}/lib/constants.sh"

MODE_STATE="$AI_AGENTS_STATE_COMPETITION"
AGENT="${1:-}"
SOLUTION_PATH="${2:-}"
EXPLANATION="${3:-}"

if [[ ! -f "$MODE_STATE" ]]; then
    error_color "❌ Competition mode not active!"
    exit 1
fi

if [[ -z "$AGENT" || -z "$SOLUTION_PATH" ]]; then
    error_color "Usage: ai-compete-submit.sh <agent> \"<solution_path>\" \"<explanation>\""
    echo "Example: ai-compete-submit.sh Agent1 \"./my_solution.py\" \"My approach uses dynamic programming...\""
    exit 1
fi

# Validate solution file exists
if [[ ! -f "$SOLUTION_PATH" ]]; then
    warning_color "⚠️  Solution file not found: $SOLUTION_PATH"
    warning_color "    Continuing with submission anyway..."
fi

# Record submission
TIMESTAMP=$(date -Iseconds)
jq --arg agent "$AGENT" \
   --arg path "$SOLUTION_PATH" \
   --arg explanation "$EXPLANATION" \
   --arg timestamp "$TIMESTAMP" \
   '.submissions[$agent] = {path: $path, explanation: $explanation, timestamp: $timestamp}' \
   "$MODE_STATE" > "${MODE_STATE}.tmp" && mv "${MODE_STATE}.tmp" "$MODE_STATE"

# Determine agent color
if [[ "$AGENT" == "Agent1" ]]; then
    AGENT_COLOR="$AGENT1_COLOR"
else
    AGENT_COLOR="$AGENT2_COLOR"
fi

# Announce submission
cat >> "$AI_AGENTS_SHARED_FILE" <<EOF

${AGENT_COLOR}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${RESET}
${AGENT_COLOR} 📤 ${AGENT} - Solution Submitted!${RESET}
${AGENT_COLOR}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${RESET}

$(info_color "Solution: $SOLUTION_PATH")
$(info_color "Submitted: $(date '+%H:%M:%S')")

$(shared_color "Approach:")
$(success_color "$EXPLANATION")

${AGENT_COLOR}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${RESET}

EOF

"${SCRIPT_DIR}/ai-agent-send-enhanced.sh" "$AGENT" RESULT "📤 Solution submitted!" --notify

success_color "✅ Solution submitted for $AGENT"
info_color "   File: $SOLUTION_PATH"
echo ""

# Check if both have submitted
AGENT1_SUB=$(jq -r '.submissions.Agent1' "$MODE_STATE")
AGENT2_SUB=$(jq -r '.submissions.Agent2' "$MODE_STATE")

if [[ "$AGENT1_SUB" != "null" && "$AGENT2_SUB" != "null" ]]; then
    CHALLENGE=$(jq -r '.challenge' "$MODE_STATE")

    cat >> "$AI_AGENTS_SHARED_FILE" <<EOF
$(success_color "════════════════════════════════════════")
$(success_color " ✅ Both solutions submitted!")
$(success_color "════════════════════════════════════════")

$(info_color "Challenge: $CHALLENGE")

$(warning_color "Time to judge!")

$(shared_color "Scoring criteria (25 points each):")
  • Correctness: Does it work? All edge cases?
  • Performance: Speed, memory efficiency
  • Code Quality: Readability, maintainability
  • Innovation: Creative approach, elegance

$(shared_color "Score each criterion:")
  ai-compete-score.sh <agent> <criterion> <points>

$(shared_color "Example:")
  ai-compete-score.sh Agent1 correctness 25
  ai-compete-score.sh Agent1 performance 20
  ai-compete-score.sh Agent2 correctness 24
  ...

EOF
    "${SCRIPT_DIR}/ai-agent-send-enhanced.sh" System INFO "⚖️  Ready for judging!" --notify

    echo ""
    success_color "✅ Both solutions submitted - time to judge!"
    echo ""
    echo "Score the solutions using:"
    echo "  ai-compete-score.sh <agent> <criterion> <points>"
fi
