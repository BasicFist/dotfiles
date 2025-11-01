#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Configuration Management Library for AI Agents
# ═══════════════════════════════════════════════════════════

set -euo pipefail

# Source JSON utilities for safe operations
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/json-utils.sh"

# Configuration file locations
CONFIG_DIR="${AI_AGENTS_CONFIG_DIR:-$HOME/.config/ai-agents}"
CONFIG_FILE="$CONFIG_DIR/config.json"
BACKUP_DIR="$CONFIG_DIR/backups"

# Default configuration values
DEFAULT_CONFIG='{
  "version": "1.0.0",
  "system": {
    "shared_file": "/tmp/ai-agents-shared.txt",
    "shared_file_permissions": "644",
    "kb_root": "~/.ai-agents",
    "session_root": "~/.ai-agents/sessions"
  },
  "security": {
    "input_sanitization": true,
    "path_validation": true,
    "max_file_size": "100M",
    "allowed_paths": ["~/.ai-agents", "~/.config"]
  },
  "performance": {
    "kb_indexing": true,
    "session_cache": true,
    "max_concurrent_searches": 5
  },
  "ui": {
    "progress_indicators": true,
    "color_output": true,
    "animation_speed": "normal"
  }
}'

# Initialize configuration directory and file
init_config() {
    mkdir -p "$CONFIG_DIR" "$BACKUP_DIR"

    # Create default config if it doesn't exist
    if [[ ! -f "$CONFIG_FILE" ]]; then
        if ! json_create "$CONFIG_FILE" "$DEFAULT_CONFIG"; then
            echo "❌ Failed to create config file: $CONFIG_FILE" >&2
            return 1
        fi
        chmod 600 "$CONFIG_FILE"
    fi
}

# Get configuration value by key (dot notation supported)
get_config() {
    local key="$1"
    local default_value="${2:-}"

    if [[ ! -f "$CONFIG_FILE" ]]; then
        init_config
    fi

    # Use json_read for safe extraction
    if command -v jq >/dev/null 2>&1; then
        local value
        value=$(json_read "$CONFIG_FILE" ".${key}" "$default_value") || {
            echo "$default_value"
            return 1
        }
        echo "$value"
    else
        # Fallback to grep/sed for simple key-value pairs
        local simple_key="${key//./_}"
        local value=$(grep "\"${simple_key}\":" "$CONFIG_FILE" 2>/dev/null | sed -E 's/.*"([^"]+)".*/\1/' | head -1)
        echo "${value:-$default_value}"
    fi
}

# Set configuration value
set_config() {
    local key="$1"
    local value="$2"

    if [[ ! -f "$CONFIG_FILE" ]]; then
        init_config
    fi

    # Backup current config
    cp "$CONFIG_FILE" "$BACKUP_DIR/config.backup.$(date +%s)" 2>/dev/null || true

    # Update config using json_write if jq available
    if command -v jq >/dev/null 2>&1; then
        if ! json_write "$CONFIG_FILE" '
            if ($key | contains(".")) then
                .[($key | split("."))[0]][($key | split(".")[1])] = $value
            else
                .[$key] = $value
            end
        ' --arg key "$key" --arg value "$value"; then
            echo "❌ Failed to update config: $key = $value" >&2
            return 1
        fi
    else
        # Simple replacement for basic keys
        local simple_key="${key//./_}"
        if grep -q "\"${simple_key}\":" "$CONFIG_FILE" 2>/dev/null; then
            sed -i "s|\"${simple_key}\": \"[^\"]*\"|\"${simple_key}\": \"${value}\"|" "$CONFIG_FILE"
        else
            # Add new key-value pair
            sed -i "/^{/a\  \"${simple_key}\": \"${value}\"," "$CONFIG_FILE"
        fi
    fi
}

# List all configuration values
list_config() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        init_config
    fi
    
    if command -v jq >/dev/null 2>&1; then
        jq '.' "$CONFIG_FILE"
    else
        cat "$CONFIG_FILE"
    fi
}

# Validate configuration
validate_config() {
    local errors=0
    
    # Check if config file is readable
    if [[ ! -r "$CONFIG_FILE" ]]; then
        echo "ERROR: Config file not readable: $CONFIG_FILE" >&2
        ((errors++))
    fi
    
    # Validate JSON format if jq is available
    if command -v jq >/dev/null 2>&1; then
        if ! jq empty "$CONFIG_FILE" 2>/dev/null; then
            echo "ERROR: Invalid JSON in config file: $CONFIG_FILE" >&2
            ((errors++))
        fi
    fi
    
    # Validate required paths
    local kb_root=$(get_config "system.kb_root" "~/.ai-agents")
    local session_root=$(get_config "system.session_root" "~/.ai-agents/sessions")
    
    # Expand ~ to $HOME
    kb_root="${kb_root/#\~/$HOME}"
    session_root="${session_root/#\~/$HOME}"
    
    if [[ ! -d "$kb_root" ]] && [[ "$kb_root" != "~/.ai-agents" ]]; then
        echo "WARNING: KB root directory does not exist: $kb_root" >&2
    fi
    
    if [[ ! -d "$session_root" ]] && [[ "$session_root" != "~/.ai-agents/sessions" ]]; then
        echo "WARNING: Session root directory does not exist: $session_root" >&2
    fi
    
    return $errors
}

# Reset to default configuration
reset_config() {
    local confirm="${1:-no}"
    
    if [[ "$confirm" != "yes" ]]; then
        echo "This will reset all configuration to defaults."
        echo "Are you sure? (Type 'yes' to confirm): "
        read -r confirm
        [[ "$confirm" != "yes" ]] && return 1
    fi
    
    # Backup current config
    cp "$CONFIG_FILE" "$BACKUP_DIR/config.reset.$(date +%s)" 2>/dev/null || true
    
    # Write default config
    echo "$DEFAULT_CONFIG" > "$CONFIG_FILE"
    chmod 600 "$CONFIG_FILE"
    
    echo "Configuration reset to defaults."
}

# Export functions
export -f init_config
export -f get_config
export -f set_config
export -f list_config
export -f validate_config
export -f reset_config

# Initialize config on load
init_config
