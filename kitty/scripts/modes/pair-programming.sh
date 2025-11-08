#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Pair Programming Mode
# ═══════════════════════════════════════════════════════════
# One agent codes (driver), other reviews in real-time (navigator)
#
# Usage:
#   pair-programming.sh [driver] [navigator]
#
# Arguments:
#   driver    - Agent acting as driver (default: Agent1)
#   navigator - Agent acting as navigator (default: Agent2)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/mode-framework.sh"
source "${SCRIPT_DIR}/../lib/constants.sh"

# Parse arguments
DRIVER="${1:-Agent1}"
NAVIGATOR="${2:-Agent2}"

# Build initial state
STATE_JSON=$(cat <<EOF
{
  "mode": "pair-programming",
  "started": "$(date -Iseconds)",
  "driver": "$DRIVER",
  "navigator": "$NAVIGATOR",
  "switch_interval": $AI_AGENTS_PAIR_SWITCH_INTERVAL,
  "switches": 0,
  "status": "active"
}
EOF
)

# Initialize mode with framework
if ! mode_init "pair" "$STATE_JSON" "protocols/pair-protocol.txt"; then
    error_color "❌ Failed to initialize pair programming mode"
    exit 1
fi

# Send announcements
mode_blank_line
mode_announce "System" "INFO" "🔀 Pair Programming Mode Started" --notify
mode_announce "System" "INFO" "   Driver: $DRIVER (writes code)"
mode_announce "System" "INFO" "   Navigator: $NAVIGATOR (reviews & guides)"
mode_blank_line

# Display success and commands
success_color "✅ Pair programming mode active"
info_color "   Driver: $DRIVER"
info_color "   Navigator: $NAVIGATOR"

mode_show_commands "pair" \
    "ai-pair-switch.sh              # Switch driver/navigator roles" \
    "ai-pair-observe.sh <agent> \"<observation>\"  # Navigator adds observation" \
    "ai-pair-issue.sh \"<issue>\" <severity>        # Flag an issue" \
    "ai-pair-complete.sh \"<summary>\"              # Mark task complete"
