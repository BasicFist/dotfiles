#!/usr/bin/env bash
# Debug script to diagnose TUI launch issues
# Run this to test what the TUI actually does

set -x  # Enable debug output

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/tmp/tui-launch-debug.log"

exec 2>> "$LOG_FILE"  # Redirect stderr to log file

echo "=== TUI Launch Debug ===" | tee -a "$LOG_FILE"
echo "Timestamp: $(date)" | tee -a "$LOG_FILE"
echo "SCRIPT_DIR: $SCRIPT_DIR" | tee -a "$LOG_FILE"
echo "PWD: $PWD" | tee -a "$LOG_FILE"
echo "USER: $USER" | tee -a "$LOG_FILE"
echo "TMUX: ${TMUX:-NOT_SET}" | tee -a "$LOG_FILE"
echo "KITTY_WINDOW_ID: ${KITTY_WINDOW_ID:-NOT_SET}" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Test the exact command that TUI runs
driver="Agent1"
navigator="Agent2"
cmd="${SCRIPT_DIR}/ai-mode-start.sh pair \"$driver\" \"$navigator\""

echo "Command to execute:" | tee -a "$LOG_FILE"
echo "$cmd" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Run it and capture ALL output
echo "=== Executing command ===" | tee -a "$LOG_FILE"
bash -c "$cmd 2>&1" | tee -a "$LOG_FILE"
EXIT_CODE=$?

echo "" | tee -a "$LOG_FILE"
echo "Exit code: $EXIT_CODE" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Now test what happens with exec bash
echo "=== Testing with exec bash ===" | tee -a "$LOG_FILE"
echo "This is what launch_in_terminal does:" | tee -a "$LOG_FILE"
echo "bash -c \"\$cmd; exec bash\"" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

echo "Press Ctrl+C to exit, or wait 5 seconds..."
( bash -c "$cmd; echo 'exec bash would start here'; sleep 5" 2>&1 ) | tee -a "$LOG_FILE"

echo "" | tee -a "$LOG_FILE"
echo "=== Debug complete ===" | tee -a "$LOG_FILE"
echo "Log saved to: $LOG_FILE"
cat "$LOG_FILE"
