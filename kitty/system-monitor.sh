#!/bin/bash
# ═══════════════════════════════════════════════════════════
# System Monitor - CPU & GPU Usage Display
# ═══════════════════════════════════════════════════════════
# Updates Kitty window title with real-time system stats
# Run in background: bash ~/.config/kitty/system-monitor.sh &
#
# HARDENED v2.1: Enhanced error handling and graceful shutdown

# Strict error handling
set -euo pipefail

# Trap for clean shutdown
cleanup() {
    printf '\033]0;kitty\007'  # Reset window title
    echo "System monitor stopped gracefully"
    exit 0
}
trap cleanup EXIT INT TERM

UPDATE_INTERVAL=2  # seconds

# Function to get CPU usage
get_cpu_usage() {
    # Get CPU usage percentage (average across all cores)
    if command -v mpstat >/dev/null 2>&1; then
        # Use mpstat if available (more accurate)
        mpstat 1 1 | awk '/Average:/ {print int(100 - $NF)}'
    else
        # Fallback to top
        top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print int(100 - $1)}'
    fi
}

# Function to get GPU usage
get_gpu_usage() {
    if command -v nvidia-smi >/dev/null 2>&1; then
        # NVIDIA GPU
        nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | head -n1
    else
        echo "N/A"
    fi
}

# Function to get GPU temperature
get_gpu_temp() {
    if command -v nvidia-smi >/dev/null 2>&1; then
        nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits | head -n1
    else
        echo "N/A"
    fi
}

# Function to get CPU temperature
get_cpu_temp() {
    if command -v sensors >/dev/null 2>&1; then
        # More robust temperature extraction with multiple fallbacks
        local temp
        temp=$(sensors 2>/dev/null | grep -E "Package id 0:|Tdie:|Tctl:" | head -1 | grep -oP '\+?\d+' | head -1 || echo "")
        if [[ -n "$temp" ]]; then
            echo "$temp"
        else
            echo "N/A"
        fi
    else
        echo "N/A"
    fi
}

# Main monitoring loop
while true; do
    CPU=$(get_cpu_usage)
    GPU=$(get_gpu_usage)
    CPU_TEMP=$(get_cpu_temp)
    GPU_TEMP=$(get_gpu_temp)

    # Format the status string
    if [ "$GPU" = "N/A" ]; then
        STATUS="⚡ CPU: ${CPU}% (${CPU_TEMP}°C)"
    else
        STATUS="⚡ CPU: ${CPU}% (${CPU_TEMP}°C) | 🎮 GPU: ${GPU}% (${GPU_TEMP}°C)"
    fi

    # Update window title using OSC escape sequence
    # This works in Kitty and most modern terminals
    printf '\033]0;%s\007' "$STATUS"

    sleep "$UPDATE_INTERVAL"
done
