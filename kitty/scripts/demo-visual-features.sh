#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Visual Features Demo Script
# ═══════════════════════════════════════════════════════════
# Demonstrates the new color-coded messaging and progress features

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🎨 AI Agents Visual Features Demo"
echo "=================================="
echo ""

# Clear shared file for clean demo
> /tmp/ai-agents-shared.txt

echo "1️⃣  Testing different message types..."
echo ""

"${SCRIPT_DIR}/ai-agent-send-enhanced.sh" Agent1 INFO "Starting code analysis"
sleep 1

"${SCRIPT_DIR}/ai-agent-send-enhanced.sh" Agent1 TASK "Analyzing 150 files for bugs"
sleep 1

"${SCRIPT_DIR}/ai-agent-send-enhanced.sh" Agent2 INFO "Ready to receive tasks"
sleep 1

"${SCRIPT_DIR}/ai-agent-send-enhanced.sh" Agent2 QUESTION "Should I focus on security or performance?"
sleep 1

"${SCRIPT_DIR}/ai-agent-send-enhanced.sh" Agent1 RESULT "Analysis complete: found 12 issues"
sleep 1

"${SCRIPT_DIR}/ai-agent-send-enhanced.sh" Agent2 WARNING "High memory usage detected in module X"
sleep 1

"${SCRIPT_DIR}/ai-agent-send-enhanced.sh" Agent1 ERROR "Failed to parse file: syntax.error.js"
sleep 1

echo ""
echo "2️⃣  Testing progress indicators..."
echo ""

for i in {0..100..10}; do
    "${SCRIPT_DIR}/ai-agent-progress.sh" Agent1 "Processing files" "$i" 100 --update
    sleep 0.3
done

for i in {0..50..5}; do
    "${SCRIPT_DIR}/ai-agent-progress.sh" Agent2 "Running tests" "$i" 50 --update
    sleep 0.2
done

echo ""
echo "3️⃣  Testing notifications (if notify-send available)..."
echo ""

"${SCRIPT_DIR}/ai-agent-send-enhanced.sh" Coordinator RESULT "Code review completed successfully" --notify
sleep 1

"${SCRIPT_DIR}/ai-agent-send-enhanced.sh" Agent1 ERROR "Critical issue found in authentication module" --notify
sleep 1

echo ""
echo "4️⃣  Testing blink feature (if tmux session active)..."
echo ""

"${SCRIPT_DIR}/ai-agent-send-enhanced.sh" Agent1 TASK "Urgent: Fix authentication bug" --blink
sleep 2

"${SCRIPT_DIR}/ai-agent-send-enhanced.sh" Agent2 QUESTION "Need clarification on API endpoint" --blink
sleep 2

echo ""
echo "✅ Demo complete! Check the shared output pane in tmux to see colored messages."
echo ""
echo "📋 Shared file contents:"
echo "========================"
cat /tmp/ai-agents-shared.txt
echo ""
echo "📋 Structured log:"
echo "=================="
tail -20 /tmp/ai-agents-shared.txt.log 2>/dev/null || echo "(Log file not created yet)"
