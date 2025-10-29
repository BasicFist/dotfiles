#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Stop System Monitor (Enhanced)
# ═══════════════════════════════════════════════════════════
# Safely kills only system-monitor.sh processes for current user
#
# HARDENED v2.1: User-scoped pkill with verification

# Strict error handling
set -euo pipefail

MONITOR_SCRIPT="system-monitor.sh"
PIDS=$(pgrep -u "$USER" -f "$MONITOR_SCRIPT" 2>/dev/null || true)

if [[ -n "$PIDS" ]]; then
    echo "🛑 Stopping system monitor processes: $PIDS"
    pkill -u "$USER" -f "$MONITOR_SCRIPT"
    sleep 0.5

    # Verify termination
    if pgrep -u "$USER" -f "$MONITOR_SCRIPT" >/dev/null 2>&1; then
        echo "⚠️  Some processes still running, forcing termination..."
        pkill -9 -u "$USER" -f "$MONITOR_SCRIPT"
    fi

    # Reset window title to default
    printf '\033]0;kitty\007'

    echo "✅ System monitor stopped successfully"
else
    echo "ℹ️  No system monitor processes found"
    # Reset window title anyway (in case monitor crashed)
    printf '\033]0;kitty\007'
fi
