#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Shared State Management Library
# ═══════════════════════════════════════════════════════════
# Creates and secures the shared collaboration files used by
# the AI Agents tmux/TUI workflows. Prevents symlink and
# ownership attacks against predictable /tmp paths.

set -euo pipefail

_SHARED_STATE_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default locations (set only if not provided)
if [[ -z ${AI_AGENTS_SHARED_FILE+x} ]]; then
    AI_AGENTS_SHARED_FILE="/tmp/ai-agents-shared.txt"
fi
if [[ -z ${AI_AGENTS_SHARED_LOG_FILE+x} ]]; then
    AI_AGENTS_SHARED_LOG_FILE="${AI_AGENTS_SHARED_FILE}.log"
fi
if [[ -z ${AI_AGENTS_SHARED_MAX_BYTES+x} ]]; then
    AI_AGENTS_SHARED_MAX_BYTES=1048576
fi
if [[ -z ${AI_AGENTS_LOG_DIR+x} ]]; then
    AI_AGENTS_LOG_DIR="$HOME/.ai-agents/logs"
fi

# Ensure a directory exists with secure permissions
_ensure_private_dir() {
    local dir="$1"

    if [[ -d "$dir" ]]; then
        return 0
    fi

    mkdir -p "$dir" 2>/dev/null || {
        echo "❌ Failed to create directory: $dir" >&2
        return 1
    }

    chmod 700 "$dir" 2>/dev/null || {
        echo "❌ Failed to secure directory: $dir" >&2
        return 1
    }
}

# Ensure a file exists, is owned by the current user, and is not a symlink
_ensure_secure_file() {
    local file="$1"
    local perms="${2:-600}"
    local dir
    dir="$(dirname "$file")"

    _ensure_private_dir "$dir" || return 1

    if [[ -e "$file" ]]; then
        if [[ -h "$file" ]]; then
            # Attempt to remove hostile symlink (may fail due to sticky bit)
            if ! rm -f "$file" 2>/dev/null; then
                echo "❌ Refusing to use symlinked shared file: $file" >&2
                echo "   Remove it manually and rerun the command." >&2
                return 1
            fi
        elif [[ ! -O "$file" ]]; then
            echo "❌ Shared file owned by another user: $file" >&2
            echo "   Remove it (rm $file) and rerun the command." >&2
            return 1
        elif [[ ! -f "$file" ]]; then
            echo "❌ Shared file must be a regular file: $file" >&2
            return 1
        fi
    fi

    if [[ ! -e "$file" ]]; then
        local old_umask
        old_umask=$(umask)
        umask 077
        : > "$file" 2>/dev/null || {
            echo "❌ Failed to create shared file: $file" >&2
            umask "$old_umask"
            return 1
        }
        umask "$old_umask"
    fi

    chmod "$perms" "$file" 2>/dev/null || {
        echo "❌ Failed to set permissions on shared file: $file" >&2
        return 1
    }

    return 0
}

# Rotate shared transcript if it exceeds the configured max size
_rotate_shared_file() {
    local file="$1"
    local max_bytes="$2"

    if [[ ! -f "$file" ]]; then
        return 0
    fi

    local size
    size=$(stat -c %s "$file" 2>/dev/null || echo 0)

    if (( size < max_bytes )); then
        return 0
    fi

    local timestamp
    timestamp=$(date +%Y%m%d-%H%M%S)
    local archive
    archive="${AI_AGENTS_LOG_DIR}/ai-shared-${timestamp}.log"

    mkdir -p "$AI_AGENTS_LOG_DIR" 2>/dev/null || true
    mv "$file" "$archive" 2>/dev/null || return 1
    : > "$file"
    chmod 600 "$file" 2>/dev/null || true
}

# Public: ensure shared files exist securely
ensure_shared_state_paths() {
    _ensure_secure_file "$AI_AGENTS_SHARED_FILE" 600 || return 1
    _ensure_secure_file "$AI_AGENTS_SHARED_LOG_FILE" 600 || return 1
    _rotate_shared_file "$AI_AGENTS_SHARED_FILE" "$AI_AGENTS_SHARED_MAX_BYTES"
}

# Initialize on first load
if [[ "${AI_AGENTS_SHARED_STATE_INITIALIZED:-false}" != "true" ]]; then
    ensure_shared_state_paths
    export AI_AGENTS_SHARED_STATE_INITIALIZED=true
fi

# Helper getters (for readability in other scripts)
get_shared_file() {
    echo "$AI_AGENTS_SHARED_FILE"
}

get_shared_log_file() {
    echo "$AI_AGENTS_SHARED_LOG_FILE"
}

export AI_AGENTS_SHARED_FILE
export AI_AGENTS_SHARED_LOG_FILE
export -f ensure_shared_state_paths
export -f get_shared_file
export -f get_shared_log_file
