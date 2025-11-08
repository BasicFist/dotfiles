#!/usr/bin/env bash
# Verify critical keybindings point at the expected scripts.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KEYBINDINGS_FILE="${ROOT_DIR}/kitty.d/keybindings.conf"

declare -A EXPECTED=(
    ["ctrl\\+alt\\+x"]="launch-ai-agents-tmux.sh"
    ["ctrl\\+alt\\+shift\\+x"]="launch-shared-tmux.sh"
    ["ctrl\\+alt\\+m"]="ai-agents-tui.sh"
    ["ctrl\\+alt\\+shift\\+a"]="agent-terminal.sh focus"
)

failures=0

check_binding() {
    local combo="$1"
    local target="$2"

    if ! rg -q "map[[:space:]]+${combo}[[:space:]]+.*${target}" "$KEYBINDINGS_FILE"; then
        echo "❌ Missing or mismatched binding: ${combo} → ${target}"
        ((failures++))
    fi
}

check_script() {
    local script="$1"
    local path="${ROOT_DIR}/scripts/${script%% *}"

    if [[ ! -x "$path" ]]; then
        echo "❌ Script missing or not executable: ${path}"
        ((failures++))
    fi
}

for combo in "${!EXPECTED[@]}"; do
    check_binding "$combo" "${EXPECTED[$combo]}"
    check_script "${EXPECTED[$combo]}"
done

if (( failures == 0 )); then
    echo "✅ Keybinding audit passed (${#EXPECTED[@]} bindings verified)"
else
    echo "❌ Keybinding audit failed with ${failures} issues"
    exit 1
fi
