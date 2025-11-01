#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Secure Temporary File Management Library
# ═══════════════════════════════════════════════════════════
# Provides secure temporary file and directory creation with
# automatic cleanup and proper permissions.
#
# Functions:
#   temp_file         - Create secure temporary file
#   temp_dir          - Create secure temporary directory
#   temp_cleanup      - Clean up all registered temp resources
#   temp_register     - Register external temp resource for cleanup
#   temp_unregister   - Remove resource from cleanup list

set -euo pipefail

# Global array to track temporary resources for cleanup
declare -a _TEMP_RESOURCES=()

# Cleanup flag to prevent double cleanup
_TEMP_CLEANUP_DONE=false

# ───────────────────────────────────────────────────────────
# Register cleanup handler on script exit
# ───────────────────────────────────────────────────────────
_temp_init() {
    # Only register once
    if [[ "${_TEMP_CLEANUP_REGISTERED:-false}" != "true" ]]; then
        trap 'temp_cleanup' EXIT INT TERM
        export _TEMP_CLEANUP_REGISTERED=true
    fi
}

# ───────────────────────────────────────────────────────────
# Create secure temporary file
# ───────────────────────────────────────────────────────────
# Args:
#   $1 - (Optional) Template suffix (e.g., ".json")
#   $2 - (Optional) "noregister" to skip auto-cleanup registration
# Returns:
#   Prints path to temp file on stdout
#   Returns 0 on success, 1 on failure
# Example:
#   tmpfile=$(temp_file ".json")
#   tmpfile=$(temp_file "" "noregister")  # Manual cleanup
# ───────────────────────────────────────────────────────────
temp_file() {
    local suffix="${1:-}"
    local register="${2:-register}"

    # Initialize cleanup handler
    _temp_init

    # Create secure temp file with mktemp
    local tmpfile
    if [[ -n "$suffix" ]]; then
        tmpfile=$(mktemp --suffix="$suffix" 2>/dev/null) || {
            echo "❌ Failed to create temporary file" >&2
            return 1
        }
    else
        tmpfile=$(mktemp 2>/dev/null) || {
            echo "❌ Failed to create temporary file" >&2
            return 1
        }
    fi

    # Set secure permissions (only owner can read/write)
    chmod 600 "$tmpfile" 2>/dev/null || {
        echo "❌ Failed to set permissions on temp file" >&2
        rm -f "$tmpfile"
        return 1
    }

    # Register for cleanup unless explicitly disabled
    if [[ "$register" != "noregister" ]]; then
        temp_register "$tmpfile"
    fi

    echo "$tmpfile"
    return 0
}

# ───────────────────────────────────────────────────────────
# Create secure temporary directory
# ───────────────────────────────────────────────────────────
# Args:
#   $1 - (Optional) Template suffix
#   $2 - (Optional) "noregister" to skip auto-cleanup registration
# Returns:
#   Prints path to temp directory on stdout
#   Returns 0 on success, 1 on failure
# Example:
#   tmpdir=$(temp_dir)
#   tmpdir=$(temp_dir "my-app" "noregister")
# ───────────────────────────────────────────────────────────
temp_dir() {
    local suffix="${1:-}"
    local register="${2:-register}"

    # Initialize cleanup handler
    _temp_init

    # Create secure temp directory with mktemp
    local tmpdir
    if [[ -n "$suffix" ]]; then
        tmpdir=$(mktemp -d --suffix="-$suffix" 2>/dev/null) || {
            echo "❌ Failed to create temporary directory" >&2
            return 1
        }
    else
        tmpdir=$(mktemp -d 2>/dev/null) || {
            echo "❌ Failed to create temporary directory" >&2
            return 1
        }
    fi

    # Set secure permissions (only owner can access)
    chmod 700 "$tmpdir" 2>/dev/null || {
        echo "❌ Failed to set permissions on temp directory" >&2
        rm -rf "$tmpdir"
        return 1
    }

    # Register for cleanup unless explicitly disabled
    if [[ "$register" != "noregister" ]]; then
        temp_register "$tmpdir"
    fi

    echo "$tmpdir"
    return 0
}

# ───────────────────────────────────────────────────────────
# Register external temp resource for automatic cleanup
# ───────────────────────────────────────────────────────────
# Args:
#   $1 - Path to temp file or directory
# Returns:
#   0 on success
# Example:
#   temp_register "/tmp/my-temp-file"
# ───────────────────────────────────────────────────────────
temp_register() {
    local path="$1"

    # Initialize cleanup handler
    _temp_init

    # Validate path exists
    if [[ ! -e "$path" ]]; then
        echo "⚠️  Warning: Registering non-existent path for cleanup: $path" >&2
    fi

    # Add to cleanup list if not already registered
    if [[ ! " ${_TEMP_RESOURCES[*]} " =~ " ${path} " ]]; then
        _TEMP_RESOURCES+=("$path")
    fi

    return 0
}

# ───────────────────────────────────────────────────────────
# Unregister temp resource from automatic cleanup
# ───────────────────────────────────────────────────────────
# Args:
#   $1 - Path to temp file or directory
# Returns:
#   0 on success
# Example:
#   temp_unregister "/tmp/my-temp-file"
# ───────────────────────────────────────────────────────────
temp_unregister() {
    local path="$1"
    local new_array=()

    # Remove path from array
    for resource in "${_TEMP_RESOURCES[@]}"; do
        if [[ "$resource" != "$path" ]]; then
            new_array+=("$resource")
        fi
    done

    _TEMP_RESOURCES=("${new_array[@]}")
    return 0
}

# ───────────────────────────────────────────────────────────
# Clean up all registered temporary resources
# ───────────────────────────────────────────────────────────
# This is automatically called on script exit via trap
# Can also be called manually for explicit cleanup
# ───────────────────────────────────────────────────────────
temp_cleanup() {
    # Prevent double cleanup
    if [[ "$_TEMP_CLEANUP_DONE" == "true" ]]; then
        return 0
    fi
    _TEMP_CLEANUP_DONE=true

    # Clean up all registered resources
    for resource in "${_TEMP_RESOURCES[@]}"; do
        if [[ -e "$resource" ]]; then
            if [[ -d "$resource" ]]; then
                rm -rf "$resource" 2>/dev/null || true
            else
                rm -f "$resource" 2>/dev/null || true
            fi
        fi
    done

    # Clear the array
    _TEMP_RESOURCES=()
}

# ───────────────────────────────────────────────────────────
# Create a secure temporary file for atomic write operations
# ───────────────────────────────────────────────────────────
# Args:
#   $1 - Target file path (the .tmp will be created for atomic write)
# Returns:
#   Prints path to temp file on stdout (target.tmp.XXXXXX)
#   Returns 0 on success, 1 on failure
# Example:
#   tmpfile=$(temp_atomic "/etc/config.json")
#   echo "data" > "$tmpfile"
#   mv "$tmpfile" "/etc/config.json"  # Atomic!
# ───────────────────────────────────────────────────────────
temp_atomic() {
    local target="$1"

    # Initialize cleanup handler
    _temp_init

    # Validate target path
    if [[ -z "$target" ]]; then
        echo "❌ Target file path required" >&2
        return 1
    fi

    # Create temp file in same directory as target for atomic mv
    local target_dir
    target_dir="$(dirname "$target")"

    if [[ ! -d "$target_dir" ]]; then
        echo "❌ Target directory does not exist: $target_dir" >&2
        return 1
    fi

    # Create secure temp file in target directory
    local tmpfile
    tmpfile=$(mktemp "${target}.tmp.XXXXXX" 2>/dev/null) || {
        echo "❌ Failed to create atomic temp file" >&2
        return 1
    }

    # Set secure permissions
    chmod 600 "$tmpfile" 2>/dev/null || {
        echo "❌ Failed to set permissions on atomic temp file" >&2
        rm -f "$tmpfile"
        return 1
    }

    # Register for cleanup
    temp_register "$tmpfile"

    echo "$tmpfile"
    return 0
}

# ───────────────────────────────────────────────────────────
# Get or create secure app-specific temp directory
# ───────────────────────────────────────────────────────────
# Args:
#   $1 - App name (e.g., "ai-agents", "ai-mode")
# Returns:
#   Prints path to app temp directory on stdout
#   Returns 0 on success, 1 on failure
# Example:
#   app_tmpdir=$(temp_app_dir "ai-agents")
# Note:
#   This creates a persistent temp directory that is NOT
#   automatically cleaned up. Use for session-level state.
# ───────────────────────────────────────────────────────────
temp_app_dir() {
    local app_name="$1"

    # Validate app name
    if [[ -z "$app_name" || "$app_name" =~ [^a-zA-Z0-9_-] ]]; then
        echo "❌ Invalid app name: must contain only alphanumeric, dash, underscore" >&2
        return 1
    fi

    local app_tmpdir="/tmp/${app_name}"

    # Create directory if it doesn't exist
    if [[ ! -d "$app_tmpdir" ]]; then
        mkdir -p "$app_tmpdir" 2>/dev/null || {
            echo "❌ Failed to create app temp directory: $app_tmpdir" >&2
            return 1
        }
        chmod 700 "$app_tmpdir" 2>/dev/null || {
            echo "❌ Failed to set permissions on app temp directory" >&2
            return 1
        }
    fi

    # Verify permissions are secure
    local perms
    perms=$(stat -c '%a' "$app_tmpdir" 2>/dev/null)
    if [[ "$perms" != "700" ]]; then
        echo "⚠️  Warning: App temp directory has insecure permissions: $perms" >&2
        chmod 700 "$app_tmpdir" 2>/dev/null || true
    fi

    echo "$app_tmpdir"
    return 0
}

# ───────────────────────────────────────────────────────────
# Export functions for use in other scripts
# ───────────────────────────────────────────────────────────
export -f temp_file
export -f temp_dir
export -f temp_register
export -f temp_unregister
export -f temp_cleanup
export -f temp_atomic
export -f temp_app_dir

# ───────────────────────────────────────────────────────────
# Self-test when run directly
# ───────────────────────────────────────────────────────────
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Running temp-files utility self-test..."
    echo ""

    # Test 1: Create temp file
    echo "Test 1: temp_file creates secure file"
    tmpfile=$(temp_file "" "noregister")
    if [[ -f "$tmpfile" ]]; then
        perms=$(stat -c '%a' "$tmpfile")
        if [[ "$perms" == "600" ]]; then
            echo "✅ temp_file: correct permissions ($perms)"
        else
            echo "❌ temp_file: wrong permissions ($perms, expected 600)"
            exit 1
        fi
    else
        echo "❌ temp_file: file not created"
        exit 1
    fi

    # Test 2: Create temp file with suffix
    echo "Test 2: temp_file with suffix"
    tmpfile2=$(temp_file ".json" "noregister")
    if [[ "$tmpfile2" =~ \.json$ ]]; then
        echo "✅ temp_file with suffix: correct"
    else
        echo "❌ temp_file with suffix: wrong suffix"
        rm -f "$tmpfile" "$tmpfile2"
        exit 1
    fi

    # Test 3: Create temp directory
    echo "Test 3: temp_dir creates secure directory"
    tmpdir=$(temp_dir "" "noregister")
    if [[ -d "$tmpdir" ]]; then
        perms=$(stat -c '%a' "$tmpdir")
        if [[ "$perms" == "700" ]]; then
            echo "✅ temp_dir: correct permissions ($perms)"
        else
            echo "❌ temp_dir: wrong permissions ($perms, expected 700)"
            rm -f "$tmpfile" "$tmpfile2"
            rm -rf "$tmpdir"
            exit 1
        fi
    else
        echo "❌ temp_dir: directory not created"
        rm -f "$tmpfile" "$tmpfile2"
        exit 1
    fi

    # Test 4: Atomic temp file
    echo "Test 4: temp_atomic for atomic writes"
    test_target="/tmp/test-atomic-$$"
    tmpatomic=$(temp_atomic "$test_target")
    temp_unregister "$tmpatomic"  # Unregister to test manually
    if [[ "$tmpatomic" =~ ${test_target}\.tmp\. ]]; then
        echo "✅ temp_atomic: correct pattern"
    else
        echo "❌ temp_atomic: wrong pattern ($tmpatomic)"
        rm -f "$tmpfile" "$tmpfile2" "$tmpatomic"
        rm -rf "$tmpdir"
        exit 1
    fi

    # Test 5: App temp directory
    echo "Test 5: temp_app_dir creates app directory"
    app_dir=$(temp_app_dir "test-app-$$")
    if [[ -d "$app_dir" ]]; then
        perms=$(stat -c '%a' "$app_dir")
        if [[ "$perms" == "700" ]]; then
            echo "✅ temp_app_dir: correct permissions ($perms)"
        else
            echo "❌ temp_app_dir: wrong permissions ($perms, expected 700)"
            rm -f "$tmpfile" "$tmpfile2" "$tmpatomic"
            rm -rf "$tmpdir" "$app_dir"
            exit 1
        fi
    else
        echo "❌ temp_app_dir: directory not created"
        rm -f "$tmpfile" "$tmpfile2" "$tmpatomic"
        rm -rf "$tmpdir"
        exit 1
    fi

    # Test 6: Manual cleanup
    echo "Test 6: Manual cleanup of test resources"
    rm -f "$tmpfile" "$tmpfile2" "$tmpatomic"
    rm -rf "$tmpdir" "$app_dir"

    echo ""
    echo "✅ All 6 tests passed!"
fi
