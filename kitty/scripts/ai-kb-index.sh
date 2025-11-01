#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# AI Agents - Knowledge Base Indexer
# ═══════════════════════════════════════════════════════════
# Create and manage indexes for faster KB searches

set -euo pipefail

# Source required libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/colors.sh"
source "${SCRIPT_DIR}/lib/errors.sh"
source "${SCRIPT_DIR}/lib/config.sh"
source "${SCRIPT_DIR}/lib/progress.sh"

# Configuration
KB_ROOT="${AI_AGENTS_KB_ROOT:-$HOME/.ai-agents}"
INDEX_DIR="$KB_ROOT/.index"
INDEX_FILE="$INDEX_DIR/kb.index"
METADATA_FILE="$INDEX_DIR/metadata.json"

# Create index directory
mkdir -p "$INDEX_DIR"

usage() {
    cat <<EOF
Usage: ai-kb-index.sh [OPTIONS] COMMAND

Index management for AI Agents Knowledge Base.

COMMANDS:
  build           Build or rebuild the knowledge base index
  update          Update index with new/modified entries
  search QUERY    Search using the index (faster than direct search)
  list            List all indexed entries
  stats           Show index statistics
  validate        Validate index integrity
  clean           Remove index files

OPTIONS:
  -h, --help      Show this help message
  -v, --verbose   Enable verbose output
  -f, --force     Force operation (overwrite existing index)

EXAMPLES:
  ai-kb-index.sh build
  ai-kb-index.sh search "machine learning"
  ai-kb-index.sh update
  ai-kb-index.sh stats

ENVIRONMENT:
  AI_AGENTS_KB_ROOT  Knowledge base root directory (default: ~/.ai-agents)

EOF
}

# Build knowledge base index
build_index() {
    local force="${1:-false}"
    local verbose="${2:-false}"
    
    info_color "Building knowledge base index..."
    
    # Check if index exists and force flag not set
    if [[ -f "$INDEX_FILE" && "$force" != "true" ]]; then
        warning_color "Index already exists. Use --force to rebuild."
        return 1
    fi
    
    # Backup existing index if it exists
    if [[ -f "$INDEX_FILE" ]]; then
        cp "$INDEX_FILE" "${INDEX_FILE}.backup.$(date +%s)" 2>/dev/null || true
    fi
    
    # Clear index directory
    rm -f "$INDEX_FILE" "$METADATA_FILE" 2>/dev/null || true
    
    # Create index directory
    mkdir -p "$INDEX_DIR"
    
    # Initialize index file
    echo "# AI Agents Knowledge Base Index" > "$INDEX_FILE"
    echo "# Generated: $(date -Iseconds)" >> "$INDEX_FILE"
    echo "# Format: path|title|type|tags|last_modified|size" >> "$INDEX_FILE"
    echo "" >> "$INDEX_FILE"
    
    # Track statistics
    local entry_count=0
    local total_size=0
    
    # Find all KB files
    local kb_files=()
    while IFS= read -r -d '' file; do
        kb_files+=("$file")
    done < <(find "$KB_ROOT/knowledge" -type f \( -name "*.md" -o -name "*.txt" \) -print0 2>/dev/null || true)
    
    local total_files=${#kb_files[@]}
    
    if [[ $total_files -eq 0 ]]; then
        warning_color "No knowledge base files found in $KB_ROOT/knowledge"
        return 0
    fi
    
    info_color "Found $total_files files to index..."
    
    # Process each file
    local i=0
    for file in "${kb_files[@]}"; do
        ((i++))
        
        # Show progress
        if [[ "$verbose" == "true" ]]; then
            show_progress "$i" "$total_files" "Indexing files"
        fi
        
        # Get file information
        local relative_path="${file#$KB_ROOT/knowledge/}"
        local file_size=$(stat -c%s "$file" 2>/dev/null || echo "0")
        local last_modified=$(stat -c%Y "$file" 2>/dev/null || date +%s)
        local file_type=$(file -b "$file" 2>/dev/null | cut -d' ' -f1 | tr '[:upper:]' '[:lower:]')
        
        # Extract title from file (first line or filename)
        local title=""
        if [[ -r "$file" ]]; then
            title=$(head -n1 "$file" 2>/dev/null | sed 's/^#\+ *//' | cut -c1-100)
        fi
        [[ -z "$title" ]] && title="$(basename "$file" .md)"
        
        # Extract tags (look for tags in file)
        local tags=""
        if command -v grep >/dev/null 2>&1; then
            tags=$(grep -i "tags:" "$file" 2>/dev/null | head -1 | sed 's/.*tags:[[:space:]]*//' | tr '\n' ',' | sed 's/,$//')
        fi
        [[ -z "$tags" ]] && tags="untagged"
        
        # Add to index
        echo "$relative_path|$title|$file_type|$tags|$last_modified|$file_size" >> "$INDEX_FILE"
        
        ((entry_count++))
        ((total_size += file_size))
        
        # Add to shared communication if verbose
        if [[ "$verbose" == "true" ]]; then
            log_progress "Indexed: $relative_path"
        fi
    done
    
    # Create metadata
    cat > "$METADATA_FILE" <<EOF
{
  "generated": "$(date -Iseconds)",
  "entries": $entry_count,
  "total_size": $total_size,
  "kb_root": "$KB_ROOT",
  "index_version": "1.0"
}
EOF
    
    # Show completion
    if [[ "$verbose" == "true" ]]; then
        printf "\n"
    fi
    success_color "✅ Index built successfully!"
    info_color "   Entries: $entry_count"
    info_color "   Total size: $(numfmt --to=iec $total_size 2>/dev/null || echo "${total_size} bytes")"
    info_color "   Index file: $INDEX_FILE"
}

# Update index with new/modified entries
update_index() {
    local verbose="${1:-false}"
    
    info_color "Updating knowledge base index..."
    
    # Check if index exists
    if [[ ! -f "$INDEX_FILE" ]]; then
        warning_color "No existing index found. Building new index..."
        build_index "false" "$verbose"
        return $?
    fi
    
    # Get last index update time
    local last_index_time=$(stat -c%Y "$INDEX_FILE" 2>/dev/null || echo "0")
    
    # Find files modified since last index update
    local updated_files=()
    while IFS= read -r -d '' file; do
        local file_mtime=$(stat -c%Y "$file" 2>/dev/null || echo "0")
        if [[ $file_mtime -gt $last_index_time ]]; then
            updated_files+=("$file")
        fi
    done < <(find "$KB_ROOT/knowledge" -type f \( -name "*.md" -o -name "*.txt" \) -newer "$INDEX_FILE" -print0 2>/dev/null || true)
    
    local update_count=${#updated_files[@]}
    
    if [[ $update_count -eq 0 ]]; then
        success_color "✅ Index is up to date. No changes needed."
        return 0
    fi
    
    info_color "Found $update_count files to update..."
    
    # Process updated files
    local i=0
    for file in "${updated_files[@]}"; do
        ((i++))
        
        # Show progress
        if [[ "$verbose" == "true" ]]; then
            show_progress "$i" "$update_count" "Updating index"
        fi
        
        # Get file information
        local relative_path="${file#$KB_ROOT/knowledge/}"
        local file_size=$(stat -c%s "$file" 2>/dev/null || echo "0")
        local last_modified=$(stat -c%Y "$file" 2>/dev/null || date +%s)
        local file_type=$(file -b "$file" 2>/dev/null | cut -d' ' -f1 | tr '[:upper:]' '[:lower:]')
        
        # Extract title
        local title=""
        if [[ -r "$file" ]]; then
            title=$(head -n1 "$file" 2>/dev/null | sed 's/^#\+ *//' | cut -c1-100)
        fi
        [[ -z "$title" ]] && title="$(basename "$file" .md)"
        
        # Extract tags
        local tags=""
        if command -v grep >/dev/null 2>&1; then
            tags=$(grep -i "tags:" "$file" 2>/dev/null | head -1 | sed 's/.*tags:[[:space:]]*//' | tr '\n' ',' | sed 's/,$//')
        fi
        [[ -z "$tags" ]] && tags="untagged"
        
        # Remove old entry if it exists
        if grep -q "^$relative_path|" "$INDEX_FILE" 2>/dev/null; then
            sed -i "\|^$relative_path|.*|.*|.*|.*|.*|.*|d" "$INDEX_FILE"
        fi
        
        # Add updated entry
        echo "$relative_path|$title|$file_type|$tags|$last_modified|$file_size" >> "$INDEX_FILE"
        
        # Log progress
        if [[ "$verbose" == "true" ]]; then
            log_progress "Updated index entry: $relative_path"
        fi
    done
    
    # Update metadata
    local current_entries=$(grep -c "^[^#]" "$INDEX_FILE" 2>/dev/null || echo "0")
    local total_size=0
    if command -v awk >/dev/null 2>&1; then
        total_size=$(awk -F'|' 'NR>4 {sum+=$6} END {print sum+0}' "$INDEX_FILE")
    fi
    
    # Update metadata file
    cat > "$METADATA_FILE" <<EOF
{
  "generated": "$(date -Iseconds)",
  "entries": $current_entries,
  "total_size": $total_size,
  "kb_root": "$KB_ROOT",
  "index_version": "1.0",
  "last_updated": "$(date -Iseconds)"
}
EOF
    
    # Show completion
    if [[ "$verbose" == "true" ]]; then
        printf "\n"
    fi
    success_color "✅ Index updated successfully!"
    info_color "   Updated entries: $update_count"
    info_color "   Total entries: $current_entries"
}

# Search using index
search_index() {
    local query="$1"
    local limit="${2:-10}"
    
    # Check if index exists
    if [[ ! -f "$INDEX_FILE" ]]; then
        error_color "No index found. Please build index first with: ai-kb-index.sh build"
        return 1
    fi
    
    # Validate query
    if [[ -z "$query" ]]; then
        error_color "Query cannot be empty"
        return 1
    fi
    
    # Sanitize query for grep
    local sanitized_query=$(printf '%s' "$query" | sed 's/[[\.*^$()+?{|]/\\&/g')
    
    # Search index using grep
    local results
    if command -v grep >/dev/null 2>&1; then
        results=$(grep -i "$sanitized_query" "$INDEX_FILE" 2>/dev/null | head -n "$limit")
    else
        # Fallback to simple search
        results=$(cat "$INDEX_FILE" | tr '[:upper:]' '[:lower:]' | grep "$(echo "$sanitized_query" | tr '[:upper:]' '[:lower:]')" 2>/dev/null | head -n "$limit")
    fi
    
    # Display results
    if [[ -n "$results" ]]; then
        local result_count=$(echo "$results" | wc -l)
        info_color "Found $result_count results for query: $query"
        echo ""
        
        # Parse and display results
        while IFS='|' read -r path title type tags last_modified size; do
            # Skip header lines
            [[ "$path" =~ ^#.* ]] && continue
            [[ -z "$path" ]] && continue
            
            echo "📁 $(success_color "$title")"
            echo "   Path: $path"
            echo "   Type: $type | Tags: $tags | Size: $(numfmt --to=iec $size 2>/dev/null || echo "${size} bytes")"
            echo "   Modified: $(date -d @$last_modified 2>/dev/null || echo "$last_modified")"
            echo ""
        done <<< "$results"
    else
        warning_color "No results found for query: $query"
    fi
}

# List all indexed entries
list_index() {
    # Check if index exists
    if [[ ! -f "$INDEX_FILE" ]]; then
        error_color "No index found. Please build index first with: ai-kb-index.sh build"
        return 1
    fi
    
    # Get entry count
    local entry_count=$(($(wc -l < "$INDEX_FILE" 2>/dev/null || echo "0") - 4)) # Subtract header lines
    
    if [[ $entry_count -le 0 ]]; then
        warning_color "Index is empty"
        return 0
    fi
    
    info_color "Knowledge Base Index Entries ($entry_count total):"
    echo ""
    
    # Skip header and display entries
    tail -n +5 "$INDEX_FILE" | while IFS='|' read -r path title type tags last_modified size; do
        # Skip empty lines
        [[ -z "$path" ]] && continue
        [[ "$path" =~ ^#.* ]] && continue
        
        echo "📁 $(success_color "$title")"
        echo "   Path: $path"
        echo "   Type: $type | Tags: $tags | Size: $(numfmt --to=iec $size 2>/dev/null || echo "${size} bytes")"
        echo ""
    done
}

# Show index statistics
show_stats() {
    # Check if index exists
    if [[ ! -f "$INDEX_FILE" ]]; then
        error_color "No index found. Please build index first with: ai-kb-index.sh build"
        return 1
    fi
    
    # Check if metadata exists
    if [[ ! -f "$METADATA_FILE" ]]; then
        error_color "Index metadata not found"
        return 1
    fi
    
    # Display statistics
    info_color "Knowledge Base Index Statistics:"
    echo ""
    
    # Read from metadata if jq available
    if command -v jq >/dev/null 2>&1; then
        echo "Generated: $(jq -r '.generated // "Unknown"' "$METADATA_FILE")"
        echo "Entries: $(jq -r '.entries // 0' "$METADATA_FILE")"
        echo "Total Size: $(numfmt --to=iec $(jq -r '.total_size // 0' "$METADATA_FILE") 2>/dev/null || echo "$(jq -r '.total_size // 0' "$METADATA_FILE") bytes")"
        echo "KB Root: $(jq -r '.kb_root // "Unknown"' "$METADATA_FILE")"
        echo "Index Version: $(jq -r '.index_version // "Unknown"' "$METADATA_FILE")"
        [[ "$(jq -r '.last_updated // null' "$METADATA_FILE")" != "null" ]] && \
            echo "Last Updated: $(jq -r '.last_updated' "$METADATA_FILE")"
    else
        # Fallback to basic stats
        local entry_count=$(($(wc -l < "$INDEX_FILE" 2>/dev/null || echo "0") - 4))
        echo "Entries: $entry_count"
        echo "Index File: $INDEX_FILE"
        echo "Metadata File: $METADATA_FILE"
    fi
    
    echo ""
    echo "Index File Size: $(numfmt --to=iec $(stat -c%s "$INDEX_FILE" 2>/dev/null || echo "0") 2>/dev/null || echo "$(stat -c%s "$INDEX_FILE" 2>/dev/null || echo "0") bytes")"
    echo "Index Last Modified: $(date -d @$(stat -c%Y "$INDEX_FILE" 2>/dev/null || echo "0") 2>/dev/null || echo "Unknown")"
}

# Validate index integrity
validate_index() {
    info_color "Validating knowledge base index..."
    
    # Check if index exists
    if [[ ! -f "$INDEX_FILE" ]]; then
        warning_color "No index found. Nothing to validate."
        return 0
    fi
    
    # Check file permissions
    local perms=$(stat -c%a "$INDEX_FILE" 2>/dev/null || echo "unknown")
    if [[ "$perms" != "644" && "$perms" != "600" ]]; then
        warning_color "Index file has unusual permissions: $perms"
    fi
    
    # Check if file is readable
    if [[ ! -r "$INDEX_FILE" ]]; then
        error_color "Index file is not readable"
        return 1
    fi
    
    # Check basic structure
    local line_count=$(wc -l < "$INDEX_FILE" 2>/dev/null || echo "0")
    if [[ $line_count -lt 4 ]]; then
        warning_color "Index file appears to be incomplete ($line_count lines)"
    fi
    
    # Check header
    local first_line=$(head -n1 "$INDEX_FILE" 2>/dev/null || echo "")
    if [[ ! "$first_line" =~ "AI Agents Knowledge Base Index" ]]; then
        warning_color "Index file header is missing or corrupted"
    fi
    
    # Validate metadata if it exists
    if [[ -f "$METADATA_FILE" ]]; then
        if command -v jq >/dev/null 2>&1; then
            if ! jq empty "$METADATA_FILE" 2>/dev/null; then
                warning_color "Metadata file contains invalid JSON"
            fi
        fi
    else
        warning_color "Metadata file not found"
    fi
    
    success_color "✅ Index validation completed"
    info_color "   Index file: $INDEX_FILE"
    info_color "   Status: Valid structure"
}

# Clean index files
clean_index() {
    local force="${1:-false}"
    
    if [[ "$force" != "true" ]]; then
        read -r -p "Are you sure you want to remove the index files? (y/N): " confirm
        [[ ! "$confirm" =~ ^[Yy]$ ]] && return 0
    fi
    
    # Remove index files
    rm -f "$INDEX_FILE" "$METADATA_FILE" 2>/dev/null || true
    rmdir "$INDEX_DIR" 2>/dev/null || true
    
    success_color "✅ Index files cleaned successfully"
    info_color "   Removed: $INDEX_FILE"
    info_color "   Removed: $METADATA_FILE"
    [[ -d "$INDEX_DIR" ]] && info_color "   Directory: $INDEX_DIR (not empty, not removed)"
}

# Main function
main() {
    local command=""
    local force=false
    local verbose=false
    local limit=10
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -f|--force)
                force=true
                shift
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            -l|--limit)
                limit="$2"
                shift 2
                ;;
            build|update|list|stats|validate|clean)
                command="$1"
                shift
                ;;
            search)
                command="search"
                shift
                ;;
            *)
                if [[ -z "$command" ]]; then
                    # First unrecognized argument is treated as command
                    command="$1"
                else
                    # Subsequent arguments are treated as parameters
                    break
                fi
                shift
                ;;
        esac
    done
    
    # Validate command
    case "$command" in
        build)
            build_index "$force" "$verbose"
            ;;
        update)
            update_index "$verbose"
            ;;
        search)
            local query="$1"
            search_index "$query" "$limit"
            ;;
        list)
            list_index
            ;;
        stats)
            show_stats
            ;;
        validate)
            validate_index
            ;;
        clean)
            clean_index "$force"
            ;;
        "")
            usage
            exit 1
            ;;
        *)
            error_color "Unknown command: $command"
            usage
            exit 1
            ;;
    esac
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
