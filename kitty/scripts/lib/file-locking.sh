#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# File Locking Library
# ═══════════════════════════════════════════════════════════
# Provides file locking mechanisms to prevent race conditions
# when multiple processes access shared state files concurrently.
#
# Uses flock (advisory locking) for Linux systems.
#
# Functions:
#   lock_acquire       - Acquire exclusive lock on file
#   lock_acquire_shared - Acquire shared lock on file
#   lock_release       - Release lock on file
#   lock_with_timeout  - Acquire lock with timeout
#   with_lock          - Execute command with file locked

set -euo pipefail

# Global array to track lock file descriptors
declare -A _LOCK_FDS=()

# Lock file directory
LOCK_DIR="/tmp/ai-agents-locks"

# ───────────────────────────────────────────────────────────
# Initialize lock directory
# ───────────────────────────────────────────────────────────
_lock_init() {
    if [[ ! -d "$LOCK_DIR" ]]; then
        mkdir -p "$LOCK_DIR" 2>/dev/null || true
        chmod 755 "$LOCK_DIR" 2>/dev/null || true
    fi
}

# ───────────────────────────────────────────────────────────
# Get lock file path for a given resource
# ───────────────────────────────────────────────────────────
# Args:
#   $1 - Resource path (file/directory to lock)
# Returns:
#   Prints lock file path
# ───────────────────────────────────────────────────────────
_get_lock_file() {
    local resource="$1"

    # Convert path to safe lock filename
    # Replace / with _ and remove any other special chars
    local lock_name
    lock_name=$(echo "$resource" | sed 's|/|_|g' | sed 's|[^a-zA-Z0-9_.-]|_|g')

    echo "${LOCK_DIR}/${lock_name}.lock"
}

# ───────────────────────────────────────────────────────────
# Acquire exclusive lock on file
# ───────────────────────────────────────────────────────────
# Args:
#   $1 - File path to lock
#   $2 - (Optional) Timeout in seconds (default: 10)
# Returns:
#   0 on success, 1 on failure
#   Sets global FD variable for lock
# Example:
#   if lock_acquire "/tmp/state.json"; then
#       # critical section
#       lock_release "/tmp/state.json"
#   fi
# ───────────────────────────────────────────────────────────
lock_acquire() {
    local file="$1"
    local timeout="${2:-10}"

    _lock_init

    # Get lock file path
    local lockfile
    lockfile=$(_get_lock_file "$file")

    # Open lock file and get FD
    local fd
    exec {fd}>"$lockfile" || {
        echo "❌ Failed to open lock file: $lockfile" >&2
        return 1
    }

    # Try to acquire exclusive lock with timeout
    local start_time
    start_time=$(date +%s)

    while true; do
        if flock -x -n "$fd" 2>/dev/null; then
            # Lock acquired
            _LOCK_FDS["$file"]=$fd
            return 0
        fi

        # Check timeout
        local current_time
        current_time=$(date +%s)
        if (( current_time - start_time >= timeout )); then
            echo "❌ Lock acquisition timeout for: $file" >&2
            exec {fd}>&-  # Close FD
            return 1
        fi

        # Wait a bit before retry
        sleep 0.1
    done
}

# ───────────────────────────────────────────────────────────
# Acquire shared lock on file (for reading)
# ───────────────────────────────────────────────────────────
# Args:
#   $1 - File path to lock
#   $2 - (Optional) Timeout in seconds (default: 10)
# Returns:
#   0 on success, 1 on failure
# Example:
#   if lock_acquire_shared "/tmp/state.json"; then
#       # read operations
#       lock_release "/tmp/state.json"
#   fi
# ───────────────────────────────────────────────────────────
lock_acquire_shared() {
    local file="$1"
    local timeout="${2:-10}"

    _lock_init

    # Get lock file path
    local lockfile
    lockfile=$(_get_lock_file "$file")

    # Open lock file and get FD
    local fd
    exec {fd}<"$lockfile" 2>/dev/null || {
        # Lock file doesn't exist, create it
        touch "$lockfile" 2>/dev/null || true
        exec {fd}<"$lockfile" || {
            echo "❌ Failed to open lock file: $lockfile" >&2
            return 1
        }
    }

    # Try to acquire shared lock with timeout
    local start_time
    start_time=$(date +%s)

    while true; do
        if flock -s -n "$fd" 2>/dev/null; then
            # Lock acquired
            _LOCK_FDS["$file"]=$fd
            return 0
        fi

        # Check timeout
        local current_time
        current_time=$(date +%s)
        if (( current_time - start_time >= timeout )); then
            echo "❌ Shared lock acquisition timeout for: $file" >&2
            exec {fd}>&-  # Close FD
            return 1
        fi

        # Wait a bit before retry
        sleep 0.1
    done
}

# ───────────────────────────────────────────────────────────
# Release lock on file
# ───────────────────────────────────────────────────────────
# Args:
#   $1 - File path to unlock
# Returns:
#   0 on success, 1 if lock wasn't held
# Example:
#   lock_release "/tmp/state.json"
# ───────────────────────────────────────────────────────────
lock_release() {
    local file="$1"

    # Check if we have a lock FD for this file
    if [[ -z "${_LOCK_FDS[$file]:-}" ]]; then
        echo "⚠️  Warning: No lock held for: $file" >&2
        return 1
    fi

    local fd="${_LOCK_FDS[$file]}"

    # Release lock by closing FD
    exec {fd}>&- 2>/dev/null || exec {fd}<&- 2>/dev/null || true

    # Remove from tracking
    unset "_LOCK_FDS[$file]"

    return 0
}

# ───────────────────────────────────────────────────────────
# Execute command with file locked
# ───────────────────────────────────────────────────────────
# Args:
#   $1 - File path to lock
#   $2+ - Command and arguments to execute
# Returns:
#   Exit code of command
# Example:
#   with_lock "/tmp/state.json" jq '.count += 1' /tmp/state.json
# ───────────────────────────────────────────────────────────
with_lock() {
    local file="$1"
    shift
    local cmd=("$@")

    # Acquire lock
    if ! lock_acquire "$file"; then
        echo "❌ Failed to acquire lock for: $file" >&2
        return 1
    fi

    # Execute command
    local exit_code=0
    "${cmd[@]}" || exit_code=$?

    # Release lock
    lock_release "$file"

    return $exit_code
}

# ───────────────────────────────────────────────────────────
# Acquire lock with custom timeout
# ───────────────────────────────────────────────────────────
# Args:
#   $1 - File path to lock
#   $2 - Timeout in seconds
#   $3 - (Optional) "shared" for shared lock (default: exclusive)
# Returns:
#   0 on success, 1 on failure
# Example:
#   if lock_with_timeout "/tmp/state.json" 30; then
#       # have lock for up to 30 seconds wait time
#       lock_release "/tmp/state.json"
#   fi
# ───────────────────────────────────────────────────────────
lock_with_timeout() {
    local file="$1"
    local timeout="$2"
    local mode="${3:-exclusive}"

    if [[ "$mode" == "shared" ]]; then
        lock_acquire_shared "$file" "$timeout"
    else
        lock_acquire "$file" "$timeout"
    fi
}

# ───────────────────────────────────────────────────────────
# Check if flock is available
# ───────────────────────────────────────────────────────────
# Returns:
#   0 if flock available, 1 if not
# ───────────────────────────────────────────────────────────
lock_available() {
    command -v flock >/dev/null 2>&1
}

# ───────────────────────────────────────────────────────────
# Cleanup all locks (called on exit)
# ───────────────────────────────────────────────────────────
_lock_cleanup() {
    for file in "${!_LOCK_FDS[@]}"; do
        lock_release "$file" 2>/dev/null || true
    done
}

# Register cleanup handler
trap '_lock_cleanup' EXIT INT TERM

# ───────────────────────────────────────────────────────────
# Export functions for use in other scripts
# ───────────────────────────────────────────────────────────
export -f lock_acquire
export -f lock_acquire_shared
export -f lock_release
export -f with_lock
export -f lock_with_timeout
export -f lock_available

# ───────────────────────────────────────────────────────────
# Self-test when run directly
# ───────────────────────────────────────────────────────────
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Running file locking self-test..."
    echo ""

    # Check if flock is available
    if ! lock_available; then
        echo "❌ flock command not found!"
        echo "   Install with: sudo apt install util-linux"
        exit 1
    fi

    TEST_FILE="/tmp/lock-test-$$"
    echo "test" > "$TEST_FILE"

    # Test 1: Acquire and release exclusive lock
    echo "Test 1: Acquire exclusive lock"
    if lock_acquire "$TEST_FILE" 5; then
        echo "✅ Exclusive lock acquired"

        # Verify we have the lock
        if [[ -n "${_LOCK_FDS[$TEST_FILE]:-}" ]]; then
            echo "✅ Lock FD registered"
        else
            echo "❌ Lock FD not registered"
            exit 1
        fi

        lock_release "$TEST_FILE"
        echo "✅ Lock released"
    else
        echo "❌ Failed to acquire lock"
        exit 1
    fi

    # Test 2: Reacquire same lock
    echo ""
    echo "Test 2: Reacquire lock after release"
    if lock_acquire "$TEST_FILE" 5; then
        echo "✅ Lock reacquired successfully"
        lock_release "$TEST_FILE"
    else
        echo "❌ Failed to reacquire lock"
        exit 1
    fi

    # Test 3: Shared locks
    echo ""
    echo "Test 3: Multiple shared locks"

    if lock_acquire_shared "$TEST_FILE" 5; then
        echo "✅ First shared lock acquired"

        # Try to acquire another shared lock (should succeed)
        TEST_FILE2="/tmp/lock-test2-$$"
        echo "test2" > "$TEST_FILE2"

        if lock_acquire_shared "$TEST_FILE2" 5; then
            echo "✅ Second shared lock acquired"
            lock_release "$TEST_FILE2"
        else
            echo "❌ Second shared lock failed"
            lock_release "$TEST_FILE"
            rm -f "$TEST_FILE" "$TEST_FILE2"
            exit 1
        fi

        lock_release "$TEST_FILE"
    else
        echo "❌ First shared lock failed"
        rm -f "$TEST_FILE"
        exit 1
    fi

    # Test 4: with_lock helper
    echo ""
    echo "Test 4: with_lock helper function"

    if with_lock "$TEST_FILE" echo "Command executed with lock"; then
        echo "✅ with_lock executed successfully"
    else
        echo "❌ with_lock failed"
        rm -f "$TEST_FILE" "$TEST_FILE2"
        exit 1
    fi

    # Cleanup
    rm -f "$TEST_FILE" "$TEST_FILE2"

    echo ""
    echo "✅ All 4 tests passed!"
fi
