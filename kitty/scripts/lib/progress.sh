#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Progress Feedback Library for AI Agents
# ═══════════════════════════════════════════════════════════

set -euo pipefail

# Source color library if available
_PROGRESS_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "${_PROGRESS_LIB_DIR}/colors.sh" ]]; then
    source "${_PROGRESS_LIB_DIR}/colors.sh"
fi

# Default color functions if not defined
if ! declare -f info_color >/dev/null 2>&1; then
    info_color() { echo -e "\033[0;36m$*\033[0m"; }
fi

if ! declare -f success_color >/dev/null 2>&1; then
    success_color() { echo -e "\033[0;32m$*\033[0m"; }
fi

# Progress bar characters
PROGRESS_FILL="${PROGRESS_FILL:-█}"
PROGRESS_EMPTY="${PROGRESS_EMPTY:-░}"
SPINNER_CHARS=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
DEFAULT_WIDTH=40

# Display a progress bar
show_progress() {
    local current="$1"
    local total="${2:-100}"
    local label="${3:-}"
    local width="${4:-$DEFAULT_WIDTH}"
    
    # Calculate percentage
    local percent=0
    if [[ $total -gt 0 ]]; then
        percent=$((current * 100 / total))
    fi
    
    # Clamp percentage between 0 and 100
    [[ $percent -lt 0 ]] && percent=0
    [[ $percent -gt 100 ]] && percent=100
    
    # Calculate filled and empty segments
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    # Clamp values
    [[ $filled -lt 0 ]] && filled=0
    [[ $filled -gt $width ]] && filled=$width
    [[ $empty -lt 0 ]] && empty=0
    [[ $empty -gt $width ]] && empty=$width
    
    # Build progress bar
    local bar=""
    local i
    for ((i=0; i<filled; i++)); do
        bar+="$PROGRESS_FILL"
    done
    for ((i=0; i<empty; i++)); do
        bar+="$PROGRESS_EMPTY"
    done
    
    # Display progress
    if [[ -n "$label" ]]; then
        printf "\r%s [%s] %d%% (%d/%d)" "$label" "$bar" "$percent" "$current" "$total"
    else
        printf "\r[%s] %d%% (%d/%d)" "$bar" "$percent" "$current" "$total"
    fi
}

# Display a simple progress indicator (dots)
show_dots() {
    local count="${1:-0}"
    local max_dots="${2:-10}"
    
    local dots=""
    local i
    for ((i=0; i<count && i<max_dots; i++)); do
        dots+="."
    done
    
    printf "\r%s" "$dots"
}

# Display a spinner animation
show_spinner() {
    local message="$1"
    local frame="${2:-0}"
    
    local char="${SPINNER_CHARS[$((frame % ${#SPINNER_CHARS[@]}))]}"
    printf "\r%s %s" "$char" "$message"
}

# Animated spinner that runs in background
start_spinner() {
    local message="$1"
    local pid_file="${2:-/tmp/ai-spinner-$$.pid}"
    
    # Function to animate spinner
    (
        local frame=0
        while true; do
            show_spinner "$message" "$frame"
            ((frame++))
            sleep 0.1
        done
    ) &
    
    # Save spinner PID
    echo $! > "$pid_file"
    
    # Return PID file path
    echo "$pid_file"
}

# Stop background spinner
stop_spinner() {
    local pid_file="${1:-/tmp/ai-spinner-$$.pid}"
    
    if [[ -f "$pid_file" ]]; then
        local pid=$(cat "$pid_file")
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid" 2>/dev/null || true
        fi
        rm -f "$pid_file" 2>/dev/null || true
    fi
    
    # Clear line
    printf "\r\033[K"
}

# Log progress to shared communication file
log_progress() {
    local message="$1"
    local shared_file="${AI_AGENTS_SHARED_FILE:-/tmp/ai-agents-shared.txt}"
    
    if [[ -w "$shared_file" ]]; then
        local timestamp=$(date '+%H:%M:%S')
        echo "[$timestamp] [PROGRESS] $message" >> "$shared_file"
    fi
}

# Display completion message
show_completion() {
    local message="$1"
    local duration="${2:-}"
    
    if [[ -n "$duration" ]]; then
        success_color "✅ $message (completed in ${duration}s)"
    else
        success_color "✅ $message"
    fi
}

# Display ETA (Estimated Time of Arrival)
show_eta() {
    local elapsed="$1"
    local progress="$2"
    local total="${3:-100}"
    
    if [[ $progress -gt 0 && $total -gt 0 ]]; then
        local eta_seconds=$((elapsed * (total - progress) / progress))
        local eta_minutes=$((eta_seconds / 60))
        local eta_seconds_remain=$((eta_seconds % 60))
        
        if [[ $eta_minutes -gt 0 ]]; then
            printf "ETA: %dm %ds" "$eta_minutes" "$eta_seconds_remain"
        else
            printf "ETA: %ds" "$eta_seconds"
        fi
    fi
}

# Export functions
export -f show_progress
export -f show_dots
export -f show_spinner
export -f start_spinner
export -f stop_spinner
export -f log_progress
export -f show_completion
export -f show_eta
