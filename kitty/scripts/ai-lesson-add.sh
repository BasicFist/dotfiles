#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# AI Agents - Add Lesson Learned
# ═══════════════════════════════════════════════════════════

set -euo pipefail

KB_ROOT="${AI_AGENTS_KB_ROOT:-$HOME/.ai-agents}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/colors.sh"

usage() {
    cat <<EOF
Usage: ai-lesson-add.sh <problem> <solution> [tags] [--agent AGENT]

Arguments:
  problem      The problem or challenge faced
  solution     The solution or insight discovered
  tags         Optional comma-separated tags
  --agent      Agent(s) involved (default: current session)

Examples:
  ai-lesson-add.sh "Memory leak in loop" "Use generator instead" python,performance
  ai-lesson-add.sh "Slow API calls" "Add caching layer" api,optimization --agent Agent1
EOF
}

if [[ $# -lt 2 ]]; then
    usage
    exit 1
fi

PROBLEM="$1"
SOLUTION="$2"
TAGS="${3:-}"
shift 2
[[ $# -gt 0 ]] && shift || true

AGENT="Unknown"
SESSION_ID="${AI_SESSION_ID:-unknown}"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --agent)
            AGENT="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

# Create KB if not exists
if [[ ! -d "$KB_ROOT" ]]; then
    "${SCRIPT_DIR}/ai-knowledge-init.sh" >/dev/null
fi

# Generate lesson ID
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LESSON_ID="lesson_${TIMESTAMP}"
LESSON_FILE="$KB_ROOT/lessons/${LESSON_ID}.md"

# Create lesson entry
cat > "$LESSON_FILE" <<EOF
---
id: $LESSON_ID
timestamp: $(date -Iseconds)
session: $SESSION_ID
agent: $AGENT
tags: $TAGS
---

# Lesson Learned: $LESSON_ID

## Problem/Challenge

$PROBLEM

## Solution/Insight

$SOLUTION

## Applicability

Tags: $TAGS
Context: AI Agent collaboration session
Agent(s): $AGENT

## Related

- Session: $SESSION_ID
- Timestamp: $(date)

---
*Captured by AI Agents Knowledge Management System*
EOF

success_color "✅ Lesson learned captured: $LESSON_ID"
info_color "   Problem: $PROBLEM"
info_color "   Solution: $SOLUTION"

# Log to shared file if in session
if [[ -f "/tmp/ai-agents-shared.txt" ]]; then
    echo -e "$(format_message INFO "$AGENT" "💡 Lesson learned captured: $LESSON_ID")" >> /tmp/ai-agents-shared.txt
fi

# Add to index
echo "$(date -Iseconds)|$LESSON_ID|$AGENT|$TAGS" >> "$KB_ROOT/lessons/.index.txt"

echo ""
echo "View with: cat $LESSON_FILE"
echo "Search with: ai-lesson-search.sh <tag>"
