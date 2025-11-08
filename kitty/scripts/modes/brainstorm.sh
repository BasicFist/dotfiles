#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Brainstorm Mode
# ═══════════════════════════════════════════════════════════
# Free-form idea generation - no judgment, maximum creativity
#
# Usage:
#   brainstorm.sh [topic]
#
# Arguments:
#   topic - Topic to brainstorm about (required)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/mode-framework.sh"
source "${SCRIPT_DIR}/../lib/constants.sh"

# Parse arguments
TOPIC="${1:-No topic specified}"

# Build initial state
STATE_JSON=$(cat <<EOF
{
  "mode": "brainstorm",
  "started": "$(date -Iseconds)",
  "topic": "$TOPIC",
  "ideas": [],
  "groups": {},
  "votes": {},
  "phase": "diverge",
  "status": "active"
}
EOF
)

# Initialize mode with framework
if ! mode_init "brainstorm" "$STATE_JSON" "protocols/brainstorm-protocol.txt"; then
    error_color "❌ Failed to initialize brainstorm mode"
    exit 1
fi

# Send announcements
mode_blank_line
mode_announce "System" "INFO" "💭 Brainstorm Session Started" --notify
mode_announce "System" "INFO" "   Topic: $TOPIC"
mode_announce "System" "INFO" "   Phase: DIVERGE (idea generation)"
mode_blank_line
mode_announce "System" "INFO" "🚀 No bad ideas! Share everything!" --blink

# Display success and commands
success_color "✅ Brainstorm mode active"
info_color "   Topic: $TOPIC"
warning_color "   Current Phase: DIVERGE (generate ideas freely)"

mode_show_commands "brainstorm" \
    "ai-brainstorm-idea.sh \"<idea>\"                    # Add an idea" \
    "ai-brainstorm-group.sh \"<theme>\" <id1> <id2> ... # Group ideas" \
    "ai-brainstorm-vote.sh <idea_number>                # Vote for idea" \
    "ai-brainstorm-refine.sh <idea_number> \"<details>\" # Refine idea"
