#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Competition Mode - Declare Winner
# ═══════════════════════════════════════════════════════════

set -euo pipefail

SESSION=${KITTY_AI_SESSION:-ai-agents}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/colors.sh"

MODE_STATE="/tmp/ai-mode-${SESSION}/competition.json"
WINNER="${1:-}"
REASON="${2:-}"

if [[ ! -f "$MODE_STATE" ]]; then
    error_color "❌ Competition mode not active!"
    exit 1
fi

if [[ -z "$WINNER" || -z "$REASON" ]]; then
    error_color "Usage: ai-compete-winner.sh <agent> \"<reason>\""
    echo "Example: ai-compete-winner.sh Agent1 \"Best balance of correctness and performance\""
    exit 1
fi

if [[ "$WINNER" != "Agent1" && "$WINNER" != "Agent2" ]]; then
    error_color "Winner must be Agent1 or Agent2"
    exit 1
fi

# Update state
jq --arg winner "$WINNER" \
   --arg reason "$REASON" \
   '.winner = $winner | .winner_reason = $reason | .completed = true' \
   "$MODE_STATE" > "${MODE_STATE}.tmp" && mv "${MODE_STATE}.tmp" "$MODE_STATE"

# Read final stats
CHALLENGE=$(jq -r '.challenge' "$MODE_STATE")
STARTED=$(jq -r '.started' "$MODE_STATE")
TIME_LIMIT=$(jq -r '.time_limit_minutes' "$MODE_STATE")
AGENT1_SCORE=$(jq -r '.scores.Agent1' "$MODE_STATE")
AGENT2_SCORE=$(jq -r '.scores.Agent2' "$MODE_STATE")
AGENT1_PATH=$(jq -r '.submissions.Agent1.path' "$MODE_STATE")
AGENT2_PATH=$(jq -r '.submissions.Agent2.path' "$MODE_STATE")
DURATION=$(($(date +%s) - $(date -d "$STARTED" +%s)))
MINUTES=$((DURATION / 60))

# Determine winner color
if [[ "$WINNER" == "Agent1" ]]; then
    WINNER_COLOR="$AGENT1_COLOR"
    LOSER="Agent2"
else
    WINNER_COLOR="$AGENT2_COLOR"
    LOSER="Agent1"
fi

# Grand finale announcement
cat >> /tmp/ai-agents-shared.txt <<EOF

$(success_color "★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★")
$(success_color "★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★")
$(success_color " ")
$(success_color "           🏆 WINNER: ${WINNER}! 🏆")
$(success_color " ")
$(success_color "★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★")
$(success_color "★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★")

$(info_color "═══════════════════════════════════════")
$(info_color " Competition Results")
$(info_color "═══════════════════════════════════════")

$(warning_color "Challenge:")
$(shared_color "$CHALLENGE")

$(info_color "Duration: ${MINUTES}/${TIME_LIMIT} minutes")

$(info_color "─────────────────────────────────────────")

${WINNER_COLOR}🥇 ${WINNER}: ${AGENT1_SCORE}/100 points${RESET}
   Solution: $(jq -r --arg w "$WINNER" '.submissions[$w].path' "$MODE_STATE")

$(agent2_color "🥈 ${LOSER}: $(jq -r --arg l "$LOSER" '.scores[$l]' "$MODE_STATE")/100 points")
   Solution: $(jq -r --arg l "$LOSER" '.submissions[$l].path' "$MODE_STATE")

$(info_color "─────────────────────────────────────────")

$(success_color "Winning Factor:")
$(success_color "$REASON")

$(info_color "─────────────────────────────────────────")

$(shared_color "Both agents competed well!")
$(shared_color "Great work from everyone! 🎉")

$(warning_color "Save this competition:")
$(warning_color "  ai-session-save.sh \"compete-$(date +%Y%m%d-%H%M)\" \"Competition: $CHALLENGE\"")

$(success_color "═══════════════════════════════════════")

EOF

"${SCRIPT_DIR}/ai-agent-send-enhanced.sh" System RESULT "🏆 ${WINNER} WINS!" --notify --blink

success_color "🏆 Competition completed!"
echo ""
info_color "Challenge: $CHALLENGE"
info_color "Duration: ${MINUTES}/${TIME_LIMIT} minutes"
echo ""
success_color "🥇 Winner: ${WINNER} (${AGENT1_SCORE}/100)"
info_color "🥈 Runner-up: ${LOSER} ($(jq -r --arg l "$LOSER" '.scores[$l]' "$MODE_STATE")/100)"
echo ""
info_color "Reason: $REASON"
echo ""
echo "Save this competition? Run:"
echo "  ai-session-save.sh \"compete-$(date +%Y%m%d-%H%M)\" \"Competition: $CHALLENGE\""
