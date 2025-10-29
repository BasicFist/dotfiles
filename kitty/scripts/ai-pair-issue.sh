#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Pair Programming - Mark Issue
# ═══════════════════════════════════════════════════════════

set -euo pipefail

SESSION=${KITTY_AI_SESSION:-ai-agents}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/colors.sh"

MODE_STATE="/tmp/ai-mode-${SESSION}/pair-programming.json"
ISSUE="${1:-}"
SEVERITY="${2:-medium}"

if [[ ! -f "$MODE_STATE" ]]; then
    error_color "❌ Pair programming mode not active!"
    exit 1
fi

if [[ -z "$ISSUE" ]]; then
    error_color "Usage: ai-pair-issue.sh \"<issue>\" [severity]"
    echo "Severity: low | medium | high | critical"
    echo "Example: ai-pair-issue.sh \"Potential null pointer\" high"
    exit 1
fi

# Determine symbol and color by severity
case "$SEVERITY" in
    low)
        SYMBOL="ℹ️"
        COLOR="$INFO_COLOR"
        ;;
    medium)
        SYMBOL="⚠️"
        COLOR="$WARNING_COLOR"
        ;;
    high)
        SYMBOL="🔥"
        COLOR="$ERROR_COLOR"
        ;;
    critical)
        SYMBOL="🚨"
        COLOR="$ERROR_COLOR"
        ;;
    *)
        SYMBOL="⚠️"
        COLOR="$WARNING_COLOR"
        SEVERITY="medium"
        ;;
esac

# Log issue
cat >> /tmp/ai-agents-shared.txt <<EOF

${COLOR}═══════════════════════════════════════${RESET}
${COLOR}${SYMBOL} ISSUE FLAGGED [${SEVERITY^^}]${RESET}
${COLOR}═══════════════════════════════════════${RESET}

$(warning_color "$ISSUE")

${COLOR}Severity: ${SEVERITY}${RESET}
${COLOR}Timestamp: $(date '+%H:%M:%S')${RESET}

${COLOR}═══════════════════════════════════════${RESET}

EOF

# Send notification for high/critical
if [[ "$SEVERITY" == "high" || "$SEVERITY" == "critical" ]]; then
    "${SCRIPT_DIR}/ai-agent-send-enhanced.sh" System ERROR "${SYMBOL} ISSUE: $ISSUE" --notify --blink
else
    "${SCRIPT_DIR}/ai-agent-send-enhanced.sh" System WARNING "${SYMBOL} Issue: $ISSUE"
fi

success_color "✅ Issue flagged: $SEVERITY"
