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

# Detect GPU backend once to avoid repeated command lookups
GPU_BACKEND="none"
GPU_LABEL=""

detect_gpu_backend() {
    if command -v nvidia-smi >/dev/null 2>&1; then
        GPU_BACKEND="nvidia"
        GPU_LABEL="NVIDIA"
    elif command -v rocm-smi >/dev/null 2>&1; then
        GPU_BACKEND="amd"
        GPU_LABEL="AMD"
    elif command -v intel_gpu_top >/dev/null 2>&1; then
        GPU_BACKEND="intel"
        GPU_LABEL="Intel"
    else
        GPU_BACKEND="none"
        GPU_LABEL=""
    fi
}

detect_gpu_backend

# Function to get GPU usage
get_gpu_usage() {
    case "$GPU_BACKEND" in
        nvidia)
            nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -n1 || echo "N/A"
            ;;
        amd)
            local payload
            payload=$(rocm-smi --showuse 2>/dev/null || true)
            if [[ -z "$payload" ]]; then
                echo "N/A"
            else
                awk -F ':' '/GPU use/ {gsub(/[^0-9]/, "", $2); print $2; exit}' <<<"$payload"
            fi
            ;;
        intel)
            if ! command -v python3 >/dev/null 2>&1; then
                echo "N/A"
                return
            fi
            local json
            if command -v timeout >/dev/null 2>&1; then
                json=$(timeout 2 intel_gpu_top -J 2>/dev/null || true)
            else
                json=$(intel_gpu_top -J 2>/dev/null || true)
            fi
            if [[ -z "$json" ]]; then
                echo "N/A"
            else
                python3 - <<'PY' 2>/dev/null <<<"$json" || echo "N/A"
import json, sys
try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(1)
samples = []
engines = data.get("engines", []) if isinstance(data, dict) else []
for engine in engines:
    busy = engine.get("busy")
    if isinstance(busy, (int, float)):
        samples.append(float(busy))
if not samples:
    sys.exit(1)
print(int(sum(samples) / len(samples)))
PY
            fi
            ;;
        *)
            echo "N/A"
            ;;
    esac
}

# Function to get GPU temperature
get_gpu_temp() {
    case "$GPU_BACKEND" in
        nvidia)
            nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null | head -n1 || echo "N/A"
            ;;
        amd)
            local payload
            payload=$(rocm-smi --showtemp 2>/dev/null || true)
            if [[ -z "$payload" ]]; then
                echo "N/A"
            else
                awk -F ':' '/GPU \[/ {gsub(/[^0-9]/, "", $2); print $2; exit}' <<<"$payload"
            fi
            ;;
        intel)
            echo "N/A"
            ;;
        *)
            echo "N/A"
            ;;
    esac
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
        if [[ -n "$GPU_LABEL" ]]; then
            STATUS="⚡ CPU: ${CPU}% (${CPU_TEMP}°C) | 🎮 ${GPU_LABEL}: ${GPU}% (${GPU_TEMP}°C)"
        else
            STATUS="⚡ CPU: ${CPU}% (${CPU_TEMP}°C) | 🎮 GPU: ${GPU}% (${GPU_TEMP}°C)"
        fi
    fi

    # Update window title using OSC escape sequence
    # This works in Kitty and most modern terminals
    printf '\033]0;%s\007' "$STATUS"

    sleep "$UPDATE_INTERVAL"
done
