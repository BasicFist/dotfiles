#!/usr/bin/env bash
# Executes an AI mode, logs output, then opens a clean shell without sourcing user rc files.

set -euo pipefail

LOG_FILE="$1"
shift || true

if [[ -z "${LOG_FILE:-}" ]]; then
    echo "ai-mode-bootstrap: missing log file argument" >&2
    exit 1
fi

MODE_CMD=("$@")

if [[ ${#MODE_CMD[@]} -eq 0 ]]; then
    echo "ai-mode-bootstrap: missing mode command" >&2
    exit 1
fi

touch "$LOG_FILE"
chmod 600 "$LOG_FILE" 2>/dev/null || true

{
    echo "🚀 Executing: ${MODE_CMD[*]}"
    echo "════════════════════════════════════════"
} | tee "$LOG_FILE"

set +e
ENV_ARGS=(
    HOME="$HOME"
    PATH="$PATH"
    TERM="${TERM:-xterm-256color}"
)
[[ -n "${KITTY_AI_SESSION:-}" ]] && ENV_ARGS+=("KITTY_AI_SESSION=$KITTY_AI_SESSION")
[[ -n "${AI_AGENTS_SESSION:-}" ]] && ENV_ARGS+=("AI_AGENTS_SESSION=$AI_AGENTS_SESSION")
[[ -n "${AI_AGENTS_CONFIG_DIR:-}" ]] && ENV_ARGS+=("AI_AGENTS_CONFIG_DIR=$AI_AGENTS_CONFIG_DIR")
[[ -n "${AI_AGENTS_STATE:-}" ]] && ENV_ARGS+=("AI_AGENTS_STATE=$AI_AGENTS_STATE")
[[ -n "${AI_AGENTS_KB_ROOT:-}" ]] && ENV_ARGS+=("AI_AGENTS_KB_ROOT=$AI_AGENTS_KB_ROOT")

env -i "${ENV_ARGS[@]}" \
    "${MODE_CMD[@]}" 2>&1 | tee -a "$LOG_FILE"
STATUS=$?
set -e

{
    echo ""
    echo "════════════════════════════════════════"
    if [[ $STATUS -eq 0 ]]; then
        echo "✅ Mode initialized (exit 0)"
    else
        echo "⚠️  Mode exited with status $STATUS"
    fi
    echo "Log saved to: $LOG_FILE"
    echo "════════════════════════════════════════"
    echo ""
} | tee -a "$LOG_FILE"

# Start minimal shell that won't source user configuration
unset PROMPT_COMMAND
alias clear=true
PS1='(ai-mode) \u@\h:\w\$ '
exec env -i \
    HOME="$HOME" \
    TERM="${TERM:-xterm-256color}" \
    PATH="$PATH" \
    bash --noprofile --norc
