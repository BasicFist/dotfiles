#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# JSON Utilities Library
# ═══════════════════════════════════════════════════════════
# Safe JSON operations with comprehensive error handling
#
# Functions:
#   json_validate       - Validate JSON file structure
#   json_read           - Safely read a JSON field
#   json_write          - Safely update JSON with atomic write
#   json_field_exists   - Check if a field exists
#   json_create         - Create new JSON file with validation

set -euo pipefail

# Note: error handling library integration available but optional
# Scripts can source both this and errors.sh for enhanced error handling

# ───────────────────────────────────────────────────────────
# Validate JSON file structure
# ───────────────────────────────────────────────────────────
# Args:
#   $1 - Path to JSON file
# Returns:
#   0 if valid JSON
#   1 if file missing or invalid JSON
# Example:
#   json_validate "/tmp/state.json" || die "Invalid JSON"
# ───────────────────────────────────────────────────────────
json_validate() {
    local file="$1"

    # Check file exists
    if [[ ! -f "$file" ]]; then
        echo "❌ JSON file not found: $file" >&2
        return 1
    fi

    # Check file is readable
    if [[ ! -r "$file" ]]; then
        echo "❌ JSON file not readable: $file" >&2
        return 1
    fi

    # Validate JSON structure
    if ! jq empty "$file" 2>/dev/null; then
        echo "❌ Invalid JSON in file: $file" >&2
        echo "   Run 'jq . \"$file\"' to see parse errors" >&2
        return 1
    fi

    return 0
}

# ───────────────────────────────────────────────────────────
# Safely read a JSON field
# ───────────────────────────────────────────────────────────
# Args:
#   $1 - Path to JSON file
#   $2 - jq query expression (e.g., '.field', '.nested.field')
#   $3 - (Optional) Default value if field doesn't exist
# Returns:
#   0 on success (prints value to stdout)
#   1 on error (file missing/corrupt or field missing without default)
# Example:
#   driver=$(json_read "$MODE_STATE" '.driver') || die "Failed to read driver"
#   value=$(json_read "$config" '.optional_field' "default_value")
# ───────────────────────────────────────────────────────────
json_read() {
    local file="$1"
    local query="$2"
    local default="${3:-}"

    # Validate JSON file first
    if ! json_validate "$file"; then
        return 1
    fi

    # Read the field
    local value
    if ! value=$(jq -r "$query" "$file" 2>/dev/null); then
        echo "❌ Failed to query JSON field: $query in $file" >&2
        return 1
    fi

    # Check if result is null and we have a default
    if [[ "$value" == "null" ]]; then
        if [[ -n "$default" ]]; then
            echo "$default"
            return 0
        else
            echo "❌ JSON field is null and no default provided: $query in $file" >&2
            return 1
        fi
    fi

    echo "$value"
    return 0
}

# ───────────────────────────────────────────────────────────
# Safely update JSON with atomic write
# ───────────────────────────────────────────────────────────
# Args:
#   $1 - Path to JSON file
#   $2 - jq update expression
#   $3+ - (Optional) Additional jq arguments (--arg, --argjson, etc.)
# Returns:
#   0 on success
#   1 on error (with automatic rollback)
# Example:
#   json_write "$MODE_STATE" '.driver = $driver' --arg driver "$NEW_DRIVER"
#   json_write "$config" '.count += 1'
# ───────────────────────────────────────────────────────────
json_write() {
    local file="$1"
    local update_expr="$2"
    shift 2
    local jq_args=("$@")

    # Validate input file
    if ! json_validate "$file"; then
        return 1
    fi

    # Create backup
    local backup="${file}.backup.$$"
    if ! cp "$file" "$backup" 2>/dev/null; then
        echo "❌ Failed to create backup: $backup" >&2
        return 1
    fi

    # Create temp file for atomic write
    local tmp="${file}.tmp.$$"

    # Perform update with proper cleanup on failure
    if ! jq "${jq_args[@]}" "$update_expr" "$file" > "$tmp" 2>/dev/null; then
        echo "❌ Failed to update JSON: $file" >&2
        echo "   Update expression: $update_expr" >&2
        rm -f "$tmp" "$backup"
        return 1
    fi

    # Validate the new JSON before committing
    if ! jq empty "$tmp" 2>/dev/null; then
        echo "❌ Update produced invalid JSON: $file" >&2
        echo "   Update expression: $update_expr" >&2
        echo "   Original file preserved" >&2
        rm -f "$tmp" "$backup"
        return 1
    fi

    # Atomic move (this should not fail, but handle it anyway)
    if ! mv "$tmp" "$file" 2>/dev/null; then
        echo "❌ Failed to move temp file to target: $file" >&2
        echo "   Restoring from backup..." >&2
        mv "$backup" "$file" 2>/dev/null || {
            echo "❌ CRITICAL: Failed to restore backup!" >&2
            echo "   Backup location: $backup" >&2
            echo "   Temp location: $tmp" >&2
            return 1
        }
        rm -f "$tmp"
        return 1
    fi

    # Success - remove backup
    rm -f "$backup"
    return 0
}

# ───────────────────────────────────────────────────────────
# Check if a JSON field exists
# ───────────────────────────────────────────────────────────
# Args:
#   $1 - Path to JSON file
#   $2 - jq query expression
# Returns:
#   0 if field exists (even if null)
#   1 if field doesn't exist or file invalid
# Example:
#   if json_field_exists "$MODE_STATE" '.driver'; then
#       driver=$(json_read "$MODE_STATE" '.driver')
#   fi
# ───────────────────────────────────────────────────────────
json_field_exists() {
    local file="$1"
    local query="$2"

    # Validate JSON file first
    json_validate "$file" || return 1

    # Check if field exists using 'has' for object keys
    # For nested paths, we need to check the full path
    if jq -e "$query" "$file" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# ───────────────────────────────────────────────────────────
# Create new JSON file with validation
# ───────────────────────────────────────────────────────────
# Args:
#   $1 - Path to JSON file to create
#   $2 - JSON content (string)
# Returns:
#   0 on success
#   1 on error
# Example:
#   json_create "$MODE_STATE" '{"mode": "pair", "driver": "Agent1"}'
# ───────────────────────────────────────────────────────────
json_create() {
    local file="$1"
    local content="$2"

    # Validate JSON content first
    if ! echo "$content" | jq empty 2>/dev/null; then
        echo "❌ Invalid JSON content provided" >&2
        return 1
    fi

    # Create parent directory if needed
    local dir
    dir="$(dirname "$file")"
    if [[ ! -d "$dir" ]]; then
        if ! mkdir -p "$dir" 2>/dev/null; then
            echo "❌ Failed to create directory: $dir" >&2
            return 1
        fi
    fi

    # Write with atomic operation
    local tmp="${file}.tmp.$$"
    if ! echo "$content" | jq . > "$tmp" 2>/dev/null; then
        echo "❌ Failed to format JSON content" >&2
        rm -f "$tmp"
        return 1
    fi

    if ! mv "$tmp" "$file" 2>/dev/null; then
        echo "❌ Failed to create JSON file: $file" >&2
        rm -f "$tmp"
        return 1
    fi

    return 0
}

# ───────────────────────────────────────────────────────────
# Convenience wrapper for reading with jq -r flag
# ───────────────────────────────────────────────────────────
# This is the most common pattern in the codebase
# Example:
#   driver=$(json_read_raw "$MODE_STATE" '.driver')
# ───────────────────────────────────────────────────────────
json_read_raw() {
    json_read "$@"
}

# Export functions for use in other scripts
export -f json_validate
export -f json_read
export -f json_write
export -f json_field_exists
export -f json_create
export -f json_read_raw

# Self-test when run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Running JSON utils self-test..."

    # Create test file
    test_file="/tmp/json-utils-test.$$.json"

    # Test json_create
    if json_create "$test_file" '{"test": "value", "count": 0}'; then
        echo "✅ json_create: passed"
    else
        echo "❌ json_create: failed"
        exit 1
    fi

    # Test json_validate
    if json_validate "$test_file"; then
        echo "✅ json_validate: passed"
    else
        echo "❌ json_validate: failed"
        exit 1
    fi

    # Test json_read
    value=$(json_read "$test_file" '.test')
    if [[ "$value" == "value" ]]; then
        echo "✅ json_read: passed"
    else
        echo "❌ json_read: failed (got: $value)"
        exit 1
    fi

    # Test json_read with default
    value=$(json_read "$test_file" '.missing' "default")
    if [[ "$value" == "default" ]]; then
        echo "✅ json_read with default: passed"
    else
        echo "❌ json_read with default: failed (got: $value)"
        exit 1
    fi

    # Test json_field_exists
    if json_field_exists "$test_file" '.test'; then
        echo "✅ json_field_exists (positive): passed"
    else
        echo "❌ json_field_exists (positive): failed"
        exit 1
    fi

    if ! json_field_exists "$test_file" '.nonexistent'; then
        echo "✅ json_field_exists (negative): passed"
    else
        echo "❌ json_field_exists (negative): failed"
        exit 1
    fi

    # Test json_write
    if json_write "$test_file" '.count = ($count | tonumber + 1)' --arg count "0"; then
        new_count=$(json_read "$test_file" '.count')
        if [[ "$new_count" == "1" ]]; then
            echo "✅ json_write: passed"
        else
            echo "❌ json_write: failed (count is $new_count, expected 1)"
            exit 1
        fi
    else
        echo "❌ json_write: failed"
        exit 1
    fi

    # Test error handling - invalid JSON
    echo "invalid json" > "${test_file}.bad"
    if ! json_validate "${test_file}.bad" 2>/dev/null; then
        echo "✅ json_validate error handling: passed"
    else
        echo "❌ json_validate error handling: failed"
        exit 1
    fi

    # Cleanup
    rm -f "$test_file" "${test_file}.bad" "${test_file}.backup."* "${test_file}.tmp."*

    echo ""
    echo "✅ All tests passed!"
fi
