#!/usr/bin/env bash
# Synchronize documentation snippet blocks with their canonical sources.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SNIPPET_DIR="${ROOT_DIR}/docs/snippets"

if [[ ! -d "$SNIPPET_DIR" ]]; then
    echo "Snippet directory not found: $SNIPPET_DIR" >&2
    exit 1
fi

update_snippet() {
    local snippet_name="$1"
    local snippet_file="${SNIPPET_DIR}/${snippet_name}.md"
    local replacement

    if [[ ! -f "$snippet_file" ]]; then
        echo "Snippet source missing: $snippet_file" >&2
        return 1
    fi

    replacement="$(<"$snippet_file")"
    # Escape delimiter for perl
    replacement="${replacement//\\/\\\\}"
    replacement="${replacement//\//\\/}"
    replacement="${replacement//$'\n'/\\n}"

    # Find all files containing the snippet marker
    local files
    IFS=$'\n' read -r -d '' -a files < <(rg -l "<!-- snippet:${snippet_name} -->" "$ROOT_DIR" && printf '\0')

    for file in "${files[@]}"; do
        perl -0pi -e "s/<!-- snippet:${snippet_name} -->.*?<!-- \\/snippet -->/<!-- snippet:${snippet_name} -->\\n${replacement}\\n<!-- \\/snippet -->/s" "$file"
        echo "Updated snippet '${snippet_name}' in ${file#$ROOT_DIR/}"
    done
}

main() {
    local snippets=()
    while IFS= read -r -d '' path; do
        snippets+=("${path##*/}")
    done < <(find "$SNIPPET_DIR" -type f -name '*.md' -print0)

    for snippet in "${snippets[@]}"; do
        update_snippet "${snippet%.md}"
    done
}

main "$@"
