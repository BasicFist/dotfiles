#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Debate Mode - Present Argument
# ═══════════════════════════════════════════════════════════

set -euo pipefail

SESSION=${KITTY_AI_SESSION:-ai-agents}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/colors.sh"

MODE_STATE="/tmp/ai-mode-${SESSION}/debate.json"
AGENT="${1:-}"
ARGUMENT="${2:-}"
EVIDENCE="${3:-}"

if [[ ! -f "$MODE_STATE" ]]; then
    error_color "❌ Debate mode not active!"
    exit 1
fi

if [[ -z "$AGENT" || -z "$ARGUMENT" ]]; then
    error_color "Usage: ai-debate-argue.sh <agent> \"<argument>\" [evidence]"
    echo "Example: ai-debate-argue.sh Agent1 \"This approach scales better\" \"Benchmarks show 3x improvement\""
    exit 1
fi

# Add argument to state
TIMESTAMP=$(date -Iseconds)
jq --arg agent "$AGENT" \
   --arg argument "$ARGUMENT" \
   --arg evidence "$EVIDENCE" \
   --arg timestamp "$TIMESTAMP" \
   '.arguments += [{agent: $agent, argument: $argument, evidence: $evidence, timestamp: $timestamp}]' \
   "$MODE_STATE" > "${MODE_STATE}.tmp" && mv "${MODE_STATE}.tmp" "$MODE_STATE"

# Determine agent color
if [[ "$AGENT" == "Agent1" ]]; then
    AGENT_COLOR="$AGENT1_COLOR"
else
    AGENT_COLOR="$AGENT2_COLOR"
fi

# Present argument
cat >> /tmp/ai-agents-shared.txt <<EOF

${AGENT_COLOR}─────────────────────────────────────────${RESET}
${AGENT_COLOR}💬 ${AGENT} - Argument${RESET}
${AGENT_COLOR}─────────────────────────────────────────${RESET}

$(info_color "$ARGUMENT")

EOF

if [[ -n "$EVIDENCE" ]]; then
    cat >> /tmp/ai-agents-shared.txt <<EOF
$(shared_color "Evidence:")
$(success_color "$EVIDENCE")

EOF
fi

cat >> /tmp/ai-agents-shared.txt <<EOF
${AGENT_COLOR}─────────────────────────────────────────${RESET}

EOF

"${SCRIPT_DIR}/ai-agent-send-enhanced.sh" "$AGENT" INFO "💬 Argument presented"

success_color "✅ Argument recorded for $AGENT"
