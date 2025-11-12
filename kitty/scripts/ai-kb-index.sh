#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Knowledge Base Indexer
# ═══════════════════════════════════════════════════════════
# Creates and manages a fast search index for the knowledge base

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"
source "${SCRIPT_DIR}/lib/colors.sh"
source "${SCRIPT_DIR}/lib/progress.sh"

KB_ROOT="${AI_AGENTS_HOME:-${HOME}/.ai-agents}"
INDEX_DIR="${AI_AGENTS_STATE:-${KB_ROOT}/state}"
INDEX_FILE="${INDEX_DIR}/kb_index.tsv"
METADATA_FILE="${INDEX_DIR}/kb_metadata.json"
LOCK_FILE="/tmp/kb_indexer.lock"

# Ensure directories exist
mkdir -p "$KB_ROOT/knowledge" "$INDEX_DIR"

# ═══════════════════════════════════════════════════════════
# Utility Functions
# ═══════════════════════════════════════════════════════════

# Simple file-based lock
acquire_lock() {
    if (set -o noclobber; echo "$$" > "$LOCK_FILE") 2> /dev/null; then
        trap 'release_lock' EXIT
        return 0
    else
        local pid
        pid=$(cat "$LOCK_FILE")
        error_color "Indexer is already running (PID: $pid)"
        return 1
    fi
}

release_lock() {
    rm -f "$LOCK_FILE"
}

# Get file metadata
get_file_metadata() {
    local file="$1"
    local relative_path
    relative_path="${file#"$KB_ROOT/knowledge/"}"
    local file_size
    file_size=$(stat -c%s "$file" 2>/dev/null || echo "0")
    local last_modified
    last_modified=$(stat -c%Y "$file" 2>/dev/null || date +%s)
    local file_type
    file_type=$(file -b "$file" 2>/dev/null | cut -d' ' -f1 | tr '[:upper:]' '[:lower:]')
    local tags
    tags=$(extract_tags "$file")

    echo "$relative_path\t$file_size\t$last_modified\t$file_type\t$tags"
}

# Extract tags from markdown frontmatter or content
extract_tags() {
    local file="$1"
    local tags=""

    # Check for frontmatter tags
    if head -n 10 "$file" | grep -q "tags:"; then
        tags=$(grep "tags:" "$file" | head -n 1 | sed 's/tags: //g' | tr -d '[]"' | tr ',' ' ' | xargs)
    fi

    # Fallback: find hashtags in content
    if [[ -z "$tags" ]]; then
        tags=$(grep -oE '#[a-zA-Z0-9_-]+' "$file" | tr -d '#' | tr '\n' ' ' | xargs)
    fi

    echo "${tags:-notags}"
}

# ═══════════════════════════════════════════════════════════
# Index Management
# ═══════════════════════════════════════════════════════════

# Full index rebuild
rebuild_index() {
    info_color "Rebuilding knowledge base index..."
    
    # Create a temporary index file
    local temp_index
    temp_index=$(mktemp)

    # Write header
    echo -e "#path\tsize\tmodified_utc\ttype\ttags" > "$temp_index"

    # Find all files to index
    local files_to_index
    files_to_index=()
    while IFS= read -r -d $'\0'; do
        files_to_index+=("$REPLY")
    done < <(find "$KB_ROOT/knowledge" -type f -print0)

    local total_files=${#files_to_index[@]}
    local indexed_files=0
    local total_size=0

    # Show progress bar
    progress_bar_start $total_files "Indexing"

    for file in "${files_to_index[@]}"; do
        local metadata
        metadata=$(get_file_metadata "$file")
        echo -e "$metadata" >> "$temp_index"
        
        local file_size
        file_size=$(echo "$metadata" | cut -f2)
        total_size=$((total_size + file_size))
        
        indexed_files=$((indexed_files + 1))
        progress_bar_update $indexed_files
    done

    progress_bar_finish

    # Atomically replace old index
    mv "$temp_index" "$INDEX_FILE"

    # Update metadata
    update_metadata "$indexed_files" "$total_size"

    success_color "Index rebuild complete."
    show_index_stats
}

# Incremental update
update_index() {
    if [[ ! -f "$INDEX_FILE" ]]; then
        rebuild_index
        return
    fi

    info_color "Updating knowledge base index..."

    local last_index_time
    last_index_time=$(stat -c%Y "$INDEX_FILE" 2>/dev/null || echo "0")
    local updated_count=0
    local new_count=0
    local total_size=0

    # Find new or modified files
    local files_to_check
    files_to_check=()
    while IFS= read -r -d $'\0'; do
        files_to_check+=("$REPLY")
    done < <(find "$KB_ROOT/knowledge" -type f -print0)

    progress_bar_start ${#files_to_check[@]} "Checking"

    for file in "${files_to_check[@]}"; do
        local file_mtime
        file_mtime=$(stat -c%Y "$file" 2>/dev/null || echo "0")
        local relative_path
        relative_path="${file#"$KB_ROOT/knowledge/"}"

        if [[ "$file_mtime" -gt "$last_index_time" ]]; then
            # File is modified, update its entry
            sed -i "\|${relative_path}|d" "$INDEX_FILE"
            local metadata
            metadata=$(get_file_metadata "$file")
            echo -e "$metadata" >> "$INDEX_FILE"
            updated_count=$((updated_count + 1))
        elif ! grep -q "	${relative_path}	" "$INDEX_FILE"; then
            # File is new
            local metadata
            metadata=$(get_file_metadata "$file")
            echo -e "$metadata" >> "$INDEX_FILE"
            new_count=$((new_count + 1))
        fi
        progress_bar_update $((updated_count + new_count))
    done

    progress_bar_finish

    # Recalculate total size
    total_size=$(awk -F'\t' 'NR>1 {sum+=$2} END {print sum}' "$INDEX_FILE")
    local current_entries
    current_entries=$(grep -c "^[^#]" "$INDEX_FILE" 2>/dev/null || echo "0")

    update_metadata "$current_entries" "$total_size"

    success_color "Index update complete. New: $new_count, Updated: $updated_count"
}

# Update metadata JSON file
update_metadata() {
    local entries="$1"
    local size="$2"
    local timestamp
    timestamp=$(date +%s)

    jq -n \
      --argjson entries "$entries" \
      --argjson size "$size" \
      --argjson updated "$timestamp" \
      '{
         "total_entries": $entries,
         "total_size": $size,
         "last_updated_utc": $updated,
         "version": "1.1.0"
       }' > "$METADATA_FILE"
}

# ═══════════════════════════════════════════════════════════
# Search & Query
# ═══════════════════════════════════════════════════════════

search_index() {
    local query="$1"
    local limit="${2:-10}"
    local sanitized_query
    sanitized_query=$(printf '%s' "$query" | sed 's/[[\.*^$()+?{|]/\\&/g')

    if [[ ! -f "$INDEX_FILE" ]]; then
        error_color "Index file not found. Run --rebuild."
        return 1
    fi

    local results
    results=$(tr '[:upper:]' '[:lower:]' < "$INDEX_FILE" | grep "$(echo "$sanitized_query" | tr '[:upper:]' '[:lower:]')" 2>/dev/null | head -n "$limit")

    if [[ -z "$results" ]]; then
        warning_color "No results found for '$query'."
        return
    fi

    local result_count
    result_count=$(echo "$results" | wc -l)
    info_color "Found $result_count results (showing top $limit):"

    echo "$results" | while IFS=$'\t' read -r path size last_modified type tags; do
        echo ""
        highlight_color "▶ Path: $path"
        echo "   Type: $type | Tags: $tags | Size: $(numfmt --to=iec "$size" 2>/dev/null || echo "${size} bytes")"
        echo "   Modified: $(date -d @"$last_modified" 2>/dev/null || echo "$last_modified")"
    done
}

# Raw output for fzf or other tools
search_raw() {
    local query="$1"
    local sanitized_query
    sanitized_query=$(printf '%s' "$query" | sed 's/[[\.*^$()+?{|]/\\&/g')

    tr '[:upper:]' '[:lower:]' < "$INDEX_FILE" | grep "$(echo "$sanitized_query" | tr '[:upper:]' '[:lower:]')" | cut -f1
}

# Get a specific entry
get_entry() {
    local path_query="$1"
    grep "	${path_query}	" "$INDEX_FILE"
}

# ═══════════════════════════════════════════════════════════
# Status & Validation
# ═══════════════════════════════════════════════════════════

show_index_stats() {
    if [[ ! -f "$METADATA_FILE" ]]; then
        info_color "No metadata found. Index may need to be built."
        return
    fi

    info_color "Knowledge Base Index Statistics:"
    jq -r '
      "  Total Entries: \(.total_entries)" +
      "  Total Size: \(.total_size)" +
      "  Last Updated: \(.last_updated_utc | tonumber | strftime("%Y-%m-%d %H:%M:%S"))" +
      "  Index Version: \(.version)"
    ' "$METADATA_FILE" | sed 's/\\n/\n/g' | (while read -r line; do
        if [[ $line == *"Size"* ]]; then
            size=$(echo "$line" | awk '{print $3}')
            formatted_size=$(numfmt --to=iec "$size" 2>/dev/null || echo "$size bytes")
            echo "  Total Size: $formatted_size"
        else
            echo "$line"
        fi
    done)
}

validate_index() {
    info_color "Validating index..."
    if [[ ! -f "$INDEX_FILE" ]]; then
        error_color "Index file not found."
        return 1
    fi

    # Check header
    if ! head -n 1 "$INDEX_FILE" | grep -q "#path	size	modified_utc	type	tags"; then
        error_color "Invalid header in index file."
        return 1
    fi

    # Check for missing files
    local missing_files=0
    tail -n +2 "$INDEX_FILE" | cut -f1 | while read -r path; do
        if [[ ! -f "$KB_ROOT/knowledge/$path" ]]; then
            warning_color "File in index not found in FS: $path"
            missing_files=$((missing_files + 1))
        fi
    done

    if [[ $missing_files -gt 0 ]]; then
        error_color "$missing_files missing files detected. Consider a rebuild."
    else
        success_color "Index validation passed."
    fi
}

# ═══════════════════════════════════════════════════════════
# Command-line Interface
# ═══════════════════════════════════════════════════════════

show_help() {
    cat << EOF
Knowledge Base Indexer

Usage: $(basename "$0") [command] [options]

Commands:
  --rebuild           Force a full rebuild of the index.
  --update            Perform an incremental update (default).
  --search QUERY      Search the index for QUERY.
  --search-raw QUERY  Search and output only file paths.
  --get PATH          Get a specific index entry by path.
  --stats             Show statistics about the index.
  --validate          Validate the index against the filesystem.
  --help              Show this help message.

If no command is given, --update is performed.
EOF
}

# Main logic
main() {
    if ! acquire_lock; then
        exit 1
    fi

    case "${1:-}" in
        --rebuild)
            rebuild_index
            ;;
        --update)
            update_index
            ;;
        --search)
            shift
            search_index "$@"
            ;;
        --search-raw)
            shift
            search_raw "$@"
            ;;
        --get)
            shift
            get_entry "$1"
            ;;
        --stats)
            show_index_stats
            ;;
        --validate)
            validate_index
            ;;
        --help)
            show_help
            ;;
        *)
            update_index
            ;;
    esac
}

# Only run main if not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
