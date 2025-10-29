#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Color Library for AI Agents
# ═══════════════════════════════════════════════════════════
# ANSI color codes and formatting for agent communication

# Reset
RESET='\033[0m'

# Agent Colors (matching Kitty Neon theme)
AGENT1_COLOR='\033[38;5;51m'      # Electric Cyan
AGENT2_COLOR='\033[38;5;201m'     # Hot Pink/Magenta
SHARED_COLOR='\033[38;5;46m'      # Bright Green
COORDINATOR_COLOR='\033[38;5;226m' # Yellow

# Message Type Colors
ERROR_COLOR='\033[38;5;196m'      # Bright Red
WARNING_COLOR='\033[38;5;214m'    # Orange
INFO_COLOR='\033[38;5;117m'       # Light Blue
SUCCESS_COLOR='\033[38;5;46m'     # Bright Green
DEBUG_COLOR='\033[38;5;240m'      # Dark Gray

# Emphasis
BOLD='\033[1m'
DIM='\033[2m'
ITALIC='\033[3m'
UNDERLINE='\033[4m'
BLINK='\033[5m'

# Background Colors (for highlights)
BG_ERROR='\033[48;5;196m'
BG_WARNING='\033[48;5;214m'
BG_SUCCESS='\033[48;5;46m'

# Unicode symbols
SYMBOL_TASK='📋'
SYMBOL_QUESTION='❓'
SYMBOL_RESULT='✅'
SYMBOL_ERROR='❌'
SYMBOL_WARNING='⚠️'
SYMBOL_INFO='ℹ️'
SYMBOL_PROGRESS='⏳'
SYMBOL_AGENT1='🤖'
SYMBOL_AGENT2='🦾'
SYMBOL_SHARED='💬'

# Color helper functions
colorize() {
    local color="$1"
    local text="$2"
    echo -e "${color}${text}${RESET}"
}

agent1_color() {
    echo -e "${AGENT1_COLOR}$1${RESET}"
}

agent2_color() {
    echo -e "${AGENT2_COLOR}$1${RESET}"
}

shared_color() {
    echo -e "${SHARED_COLOR}$1${RESET}"
}

error_color() {
    echo -e "${ERROR_COLOR}$1${RESET}"
}

warning_color() {
    echo -e "${WARNING_COLOR}$1${RESET}"
}

info_color() {
    echo -e "${INFO_COLOR}$1${RESET}"
}

success_color() {
    echo -e "${SUCCESS_COLOR}$1${RESET}"
}

# Progress bar generator
progress_bar() {
    local current="$1"
    local total="$2"
    local width="${3:-20}"

    local percent=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))

    local bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done

    echo -e "${SUCCESS_COLOR}[${bar}]${RESET} ${percent}%"
}

# Message type formatter
format_message() {
    local type="$1"
    local agent="$2"
    local message="$3"
    local timestamp="$(date '+%H:%M:%S')"

    case "$type" in
        TASK)
            echo -e "${DIM}[${timestamp}]${RESET} ${SYMBOL_TASK} $(agent_color "$agent") ${message}"
            ;;
        QUESTION)
            echo -e "${DIM}[${timestamp}]${RESET} ${SYMBOL_QUESTION} $(agent_color "$agent") ${message}"
            ;;
        RESULT)
            echo -e "${DIM}[${timestamp}]${RESET} ${SYMBOL_RESULT} $(agent_color "$agent") ${SUCCESS_COLOR}${message}${RESET}"
            ;;
        ERROR)
            echo -e "${DIM}[${timestamp}]${RESET} ${SYMBOL_ERROR} $(agent_color "$agent") ${ERROR_COLOR}${message}${RESET}"
            ;;
        WARNING)
            echo -e "${DIM}[${timestamp}]${RESET} ${SYMBOL_WARNING} $(agent_color "$agent") ${WARNING_COLOR}${message}${RESET}"
            ;;
        INFO|*)
            echo -e "${DIM}[${timestamp}]${RESET} ${SYMBOL_INFO} $(agent_color "$agent") ${message}"
            ;;
    esac
}

# Agent-specific color function
agent_color() {
    local agent="$1"
    case "$agent" in
        Agent1|AGENT1|agent1)
            echo -e "${AGENT1_COLOR}[${agent}]${RESET}"
            ;;
        Agent2|AGENT2|agent2)
            echo -e "${AGENT2_COLOR}[${agent}]${RESET}"
            ;;
        Coordinator|COORDINATOR|coordinator)
            echo -e "${COORDINATOR_COLOR}[${agent}]${RESET}"
            ;;
        *)
            echo -e "${SHARED_COLOR}[${agent}]${RESET}"
            ;;
    esac
}

# Export functions
export -f colorize
export -f agent1_color
export -f agent2_color
export -f shared_color
export -f error_color
export -f warning_color
export -f info_color
export -f success_color
export -f progress_bar
export -f format_message
export -f agent_color
