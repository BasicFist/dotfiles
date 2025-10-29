#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Competition Mode - Score Solution
# ═══════════════════════════════════════════════════════════

set -euo pipefail

SESSION=${KITTY_AI_SESSION:-ai-agents}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/colors.sh"

MODE_STATE="/tmp/ai-mode-${SESSION}/competition.json"
AGENT="${1:-}"
CRITERION="${2:-}"
POINTS="${3:-}"

if [[ ! -f "$MODE_STATE" ]]; then
    error_color "❌ Competition mode not active!"
    exit 1
fi

if [[ -z "$AGENT" || -z "$CRITERION" || -z "$POINTS" ]]; then
    error_color "Usage: ai-compete-score.sh <agent> <criterion> <points>"
    echo "Criteria: correctness | performance | code_quality | innovation"
    echo "Points: 0-25 for each criterion"
    echo "Example: ai-compete-score.sh Agent1 correctness 25"
    exit 1
fi

# Validate criterion
CRITERION=$(echo "$CRITERION" | tr '[:upper:]' '[:lower:]' | tr '-' '_')
if [[ ! "$CRITERION" =~ ^(correctness|performance|code_quality|innovation)$ ]]; then
    error_color "Invalid criterion: $CRITERION"
    error_color "Must be: correctness, performance, code_quality, or innovation"
    exit 1
fi

# Validate points
if ! [[ "$POINTS" =~ ^[0-9]+$ ]] || [[ "$POINTS" -lt 0 ]] || [[ "$POINTS" -gt 25 ]]; then
    error_color "Invalid points: $POINTS"
    error_color "Must be between 0 and 25"
    exit 1
fi

# Add score to agent's total
CURRENT_SCORE=$(jq -r --arg agent "$AGENT" '.scores[$agent]' "$MODE_STATE")
NEW_SCORE=$((CURRENT_SCORE + POINTS))

jq --arg agent "$AGENT" \
   --arg criterion "$CRITERION" \
   --arg points "$POINTS" \
   --arg total "$NEW_SCORE" \
   '.scores[$agent] = ($total | tonumber) | .criteria[$criterion] += ($points | tonumber)' \
   "$MODE_STATE" > "${MODE_STATE}.tmp" && mv "${MODE_STATE}.tmp" "$MODE_STATE"

# Determine agent color
if [[ "$AGENT" == "Agent1" ]]; then
    AGENT_COLOR="$AGENT1_COLOR"
else
    AGENT_COLOR="$AGENT2_COLOR"
fi

# Determine score symbol
if [[ "$POINTS" -ge 23 ]]; then
    SYMBOL="🌟"
    COLOR="$SUCCESS_COLOR"
elif [[ "$POINTS" -ge 20 ]]; then
    SYMBOL="⭐"
    COLOR="$INFO_COLOR"
elif [[ "$POINTS" -ge 15 ]]; then
    SYMBOL="✓"
    COLOR="$WARNING_COLOR"
else
    SYMBOL="○"
    COLOR="$ERROR_COLOR"
fi

# Announce score
cat >> /tmp/ai-agents-shared.txt <<EOF

${AGENT_COLOR}─────────────────────────────────────────${RESET}
${COLOR}${SYMBOL} ${AGENT} - ${CRITERION^}: ${POINTS}/25 points${RESET}
${AGENT_COLOR}─────────────────────────────────────────${RESET}

EOF

"${SCRIPT_DIR}/ai-agent-send-enhanced.sh" "$AGENT" INFO "${SYMBOL} ${CRITERION^}: ${POINTS}/25"

success_color "✅ Score recorded: $AGENT - ${CRITERION^}: ${POINTS}/25"
info_color "   Total score: ${NEW_SCORE}/100"

# Check if all criteria have been scored for both agents
AGENT1_SCORE=$(jq -r '.scores.Agent1' "$MODE_STATE")
AGENT2_SCORE=$(jq -r '.scores.Agent2' "$MODE_STATE")

# If both have scores >= 100, competition is complete
if [[ "$AGENT1_SCORE" -ge 100 || "$AGENT2_SCORE" -ge 100 ]]; then
    cat >> /tmp/ai-agents-shared.txt <<EOF
$(success_color "════════════════════════════════════════")
$(success_color " 📊 All criteria scored!")
$(success_color "════════════════════════════════════════")

$(info_color "Final Scores:")
  • Agent1: ${AGENT1_SCORE}/100
  • Agent2: ${AGENT2_SCORE}/100

$(warning_color "Declare the winner:")
  ai-compete-winner.sh <agent> "<reason>"

EOF
    "${SCRIPT_DIR}/ai-agent-send-enhanced.sh" System INFO "📊 Ready to declare winner!" --notify

    echo ""
    info_color "Final Scores:"
    echo "  Agent1: ${AGENT1_SCORE}/100"
    echo "  Agent2: ${AGENT2_SCORE}/100"
    echo ""
    echo "Declare winner with:"
    echo "  ai-compete-winner.sh <agent> \"<reason>\""
fi
