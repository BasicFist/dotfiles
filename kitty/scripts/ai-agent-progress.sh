#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# AI Agent Progress Indicator
# ═══════════════════════════════════════════════════════════
# Display progress bars and status updates

set -euo pipefail

SHARED_FILE="/tmp/ai-agents-shared.txt"

# Source color library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/colors.sh"
source "${SCRIPT_DIR}/lib/temp-files.sh"

usage() {
    cat <<EOF
Usage: ai-agent-progress.sh <agent-id> <task> <current> <total> [--update]

Arguments:
  agent-id    Agent identifier (Agent1, Agent2, etc.)
  task        Task description
  current     Current progress value
  total       Total/target value

Options:
  --update    Update existing progress line (use same task name)

Examples:
  ai-agent-progress.sh Agent1 "Analyzing files" 45 100
  ai-agent-progress.sh Agent2 "Running tests" 12 50 --update
  ai-agent-progress.sh Agent1 "Processing" 750 1000

Output Format:
  [HH:MM:SS] 📋 [Agent1] Analyzing files [████████░░░░░░░░░░░░] 45%
EOF
}

if [[ $# -lt 4 ]]; then
    usage
    exit 1
fi

AGENT_ID="$1"
TASK="$2"
CURRENT="$3"
TOTAL="$4"
shift 4

UPDATE_MODE=false
if [[ $# -gt 0 ]] && [[ "$1" == "--update" ]]; then
    UPDATE_MODE=true
fi

# Calculate percentage
PERCENT=$((CURRENT * 100 / TOTAL))

# Generate progress bar
BAR=$(progress_bar "$CURRENT" "$TOTAL" 20)

# Format message
TIMESTAMP=$(date '+%H:%M:%S')
AGENT_COLORED=$(agent_color "$AGENT_ID")

if [[ "$PERCENT" -eq 100 ]]; then
    # Completed - use success symbol
    MESSAGE="${DIM}[${TIMESTAMP}]${RESET} ${SYMBOL_RESULT} ${AGENT_COLORED} ${TASK} ${BAR} ${SUCCESS_COLOR}COMPLETE${RESET}"
elif [[ "$PERCENT" -ge 75 ]]; then
    # Almost done - green
    MESSAGE="${DIM}[${TIMESTAMP}]${RESET} ${SYMBOL_PROGRESS} ${AGENT_COLORED} ${TASK} ${BAR}"
elif [[ "$PERCENT" -ge 50 ]]; then
    # Halfway - cyan
    MESSAGE="${DIM}[${TIMESTAMP}]${RESET} ${SYMBOL_PROGRESS} ${AGENT_COLORED} ${TASK} ${BAR}"
elif [[ "$PERCENT" -ge 25 ]]; then
    # Getting started - yellow
    MESSAGE="${DIM}[${TIMESTAMP}]${RESET} ${SYMBOL_PROGRESS} ${AGENT_COLORED} ${TASK} ${BAR}"
else
    # Just started - normal
    MESSAGE="${DIM}[${TIMESTAMP}]${RESET} ${SYMBOL_PROGRESS} ${AGENT_COLORED} ${TASK} ${BAR}"
fi

# Write to shared file
if [[ "$UPDATE_MODE" == true ]]; then
    # Try to update last matching line (requires GNU sed)
    if command -v sed >/dev/null 2>&1; then
        # Remove ANSI codes for matching
        TASK_PLAIN=$(echo "$TASK" | sed 's/\x1B\[[0-9;]*[JKmsu]//g')

        # Create temp file with updated line
        if grep -q "$TASK_PLAIN" "$SHARED_FILE" 2>/dev/null; then
            # Update existing line (secure temp file with auto-cleanup)
            TMP_FILE=$(temp_file)
            tac "$SHARED_FILE" | awk -v task="$TASK_PLAIN" -v msg="$MESSAGE" '
                !found && $0 ~ task { print msg; found=1; next }
                { print }
            ' | tac > "$TMP_FILE"
            cat "$TMP_FILE" > "$SHARED_FILE"
        else
            # No existing line, append
            echo -e "$MESSAGE" >> "$SHARED_FILE"
        fi
    else
        # Fallback: just append
        echo -e "$MESSAGE" >> "$SHARED_FILE"
    fi
else
    # Normal mode: append
    echo -e "$MESSAGE" >> "$SHARED_FILE"
fi

# Also log to structured log
echo "[$TIMESTAMP] [$AGENT_ID] [PROGRESS] $TASK: $CURRENT/$TOTAL ($PERCENT%)" >> "${SHARED_FILE}.log"
