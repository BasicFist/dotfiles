#!/usr/bin/env bash
# Verify all keybindings with launch actions are valid.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KEYBINDINGS_FILE="${ROOT_DIR}/kitty.d/keybindings.conf"

failures=0

# Extract all lines with 'launch' commands to check for scripts
SCRIPT_LINES=$(grep -E "map .* launch .*" "$KEYBINDINGS_FILE" || true)

if [[ -z "$SCRIPT_LINES" ]]; then
    echo "No script keybindings found to test."
    exit 0
fi

while read -r line; do
    # Extract the script path, which is typically the last argument on the line
    script_path=$(echo "$line" | awk '{print $NF}')
    key_combo=$(echo "$line" | awk '{print $2}')

    # We are only interested in paths that are within our project structure
    if ! [[ "$script_path" =~ (\$\{HOME\}|~)/.config/kitty/ ]]; then
        continue
    fi

    # Convert the config path to a relative path in the repo
    # e.g., ~/.config/kitty/scripts/foo.sh -> scripts/foo.sh
    repo_relative_path="${script_path#*\.config/kitty/}"
    final_path="${ROOT_DIR}/${repo_relative_path}"

    # Remove any arguments from the script path
    final_path_base="${final_path%% *}"

    if [[ ! -f "$final_path_base" ]]; then
        echo "❌ [${key_combo}]: Script file not found at '${final_path_base}' (derived from '${script_path}')"
        ((failures++))
        continue
    fi

    # Python scripts run with 'kitten' are not required to be executable
    if [[ ! -x "$final_path_base" ]]; then
        if ! [[ "$line" =~ kitten && "$final_path_base" == *.py ]]; then
            echo "❌ [${key_combo}]: Script is not executable: '${final_path_base}'"
            ((failures++))
        fi
    fi
done <<< "$SCRIPT_LINES"

if (( failures == 0 )); then
    echo "✅ All keybindings with associated scripts are valid."
else
    echo "❌ Keybinding audit failed with ${failures} issues."
    exit 1
fi
