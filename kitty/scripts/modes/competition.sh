#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Competition Mode
# ═══════════════════════════════════════════════════════════
# Agents compete to solve challenges - best solution wins

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/mode-framework.sh"
source "${SCRIPT_DIR}/../lib/constants.sh"

CHALLENGE="${1:-No challenge specified}"
TIME_LIMIT="${2:-30}"

STATE_JSON=$(cat <<EOF
{
  "mode": "competition",
  "started": "$(date -Iseconds)",
  "challenge": "$CHALLENGE",
  "time_limit_minutes": $TIME_LIMIT,
  "submissions": {
    "Agent1": null,
    "Agent2": null
  },
  "scores": {
    "Agent1": 0,
    "Agent2": 0
  },
  "criteria": {
    "correctness": 0,
    "performance": 0,
    "code_quality": 0,
    "innovation": 0
  },
  "winner": null,
  "completed": false
}
EOF
)

if ! mode_init "competition" "$STATE_JSON" "protocols/competition-protocol.txt"; then
    error_color "❌ Failed to initialize competition mode"
    exit 1
fi

mode_blank_line
mode_announce "System" "INFO" "🏆 Competition Mode Started" --notify
mode_announce "System" "INFO" "   Challenge: $CHALLENGE"
mode_announce "System" "INFO" "   Time Limit: $TIME_LIMIT minutes"
mode_blank_line

success_color "✅ Competition mode active"
info_color "   Challenge: $CHALLENGE"
info_color "   Time Limit: $TIME_LIMIT minutes"

mode_show_commands "competition" \
    "ai-compete-submit.sh <agent> \"<solution>\" \"<notes>\"  # Submit" \
    "ai-compete-score.sh <agent> <criterion> <points>      # Judge" \
    "ai-compete-winner.sh <agent> \"<reason>\"            # Announce winner"

mode_blank_line
info_color "Timer starts now. Use planning time wisely!"
