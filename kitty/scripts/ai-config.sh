#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# AI Agents - Configuration Manager
# ═══════════════════════════════════════════════════════════
# Manage AI Agents system configuration

set -euo pipefail

# Source required libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/colors.sh"
source "${SCRIPT_DIR}/lib/errors.sh"
source "${SCRIPT_DIR}/lib/config.sh"

usage() {
    cat <<EOF
Usage: ai-config.sh [OPTIONS] COMMAND [ARGS...]

Manage AI Agents system configuration.

COMMANDS:
  list                    List all configuration values
  get KEY                 Get configuration value by key
  set KEY VALUE           Set configuration value
  reset                   Reset configuration to defaults
  validate                Validate configuration integrity
  backup                  Create configuration backup
  restore TIMESTAMP       Restore from backup
  edit                    Edit configuration file directly

OPTIONS:
  -h, --help              Show this help message
  -v, --verbose           Enable verbose output

EXAMPLES:
  ai-config.sh list
  ai-config.sh get system.shared_file
  ai-config.sh set system.shared_file_permissions 644
  ai-config.sh reset

ENVIRONMENT:
  AI_AGENTS_CONFIG_DIR    Configuration directory (default: ~/.config/ai-agents)

EOF
}

# List all configuration values
list_config_values() {
    info_color "AI Agents Configuration:"
    echo ""
    list_config
}

# Get configuration value
get_config_value() {
    local key="$1"
    
    if [[ -z "$key" ]]; then
        error_color "Key cannot be empty"
        return 1
    fi
    
    local value=$(get_config "$key")
    if [[ -n "$value" ]]; then
        echo "$value"
    else
        warning_color "Configuration key not found: $key"
        return 1
    fi
}

# Set configuration value
set_config_value() {
    local key="$1"
    local value="$2"
    
    if [[ -z "$key" ]]; then
        error_color "Key cannot be empty"
        return 1
    fi
    
    if [[ -z "$value" ]]; then
        error_color "Value cannot be empty"
        return 1
    fi
    
    # Sanitize input
    key=$(sanitize_input "$key")
    value=$(sanitize_input "$value")
    
    # Set configuration
    set_config "$key" "$value"
    
    success_color "✅ Configuration updated successfully"
    info_color "   Key: $key"
    info_color "   Value: $value"
}

# Reset configuration to defaults
reset_configuration() {
    info_color "Resetting configuration to defaults..."
    reset_config "yes"
    success_color "✅ Configuration reset to defaults"
}

# Validate configuration
validate_configuration() {
    info_color "Validating configuration..."
    if validate_config; then
        success_color "✅ Configuration is valid"
    else
        error_color "❌ Configuration validation failed"
        return 1
    fi
}

# Backup configuration
backup_configuration() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="$BACKUP_DIR/config.backup.$timestamp"
    
    if [[ ! -f "$CONFIG_FILE" ]]; then
        error_color "No configuration file found to backup"
        return 1
    fi
    
    cp "$CONFIG_FILE" "$backup_file"
    chmod 600 "$backup_file"
    
    success_color "✅ Configuration backed up successfully"
    info_color "   Backup: $backup_file"
    info_color "   Timestamp: $timestamp"
}

# Restore configuration from backup
restore_configuration() {
    local timestamp="$1"
    
    if [[ -z "$timestamp" ]]; then
        error_color "Timestamp cannot be empty"
        error_color "Available backups:"
        ls -1 "$BACKUP_DIR"/config.backup.* 2>/dev/null | sort -r || echo "No backups found"
        return 1
    fi
    
    local backup_file="$BACKUP_DIR/config.backup.$timestamp"
    
    if [[ ! -f "$backup_file" ]]; then
        error_color "Backup file not found: $backup_file"
        error_color "Available backups:"
        ls -1 "$BACKUP_DIR"/config.backup.* 2>/dev/null | sort -r || echo "No backups found"
        return 1
    fi
    
    # Backup current config
    cp "$CONFIG_FILE" "${CONFIG_FILE}.restore.$(date +%s)" 2>/dev/null || true
    
    # Restore from backup
    cp "$backup_file" "$CONFIG_FILE"
    chmod 600 "$CONFIG_FILE"
    
    success_color "✅ Configuration restored successfully"
    info_color "   From: $backup_file"
    info_color "   To: $CONFIG_FILE"
}

# Edit configuration file directly
edit_configuration() {
    local editor="${EDITOR:-nano}"
    
    if [[ ! -f "$CONFIG_FILE" ]]; then
        error_color "Configuration file not found: $CONFIG_FILE"
        return 1
    fi
    
    info_color "Opening configuration file with: $editor"
    "$editor" "$CONFIG_FILE"
    
    # Validate after edit
    info_color "Validating configuration after edit..."
    if validate_config; then
        success_color "✅ Configuration is valid"
    else
        warning_color "⚠️  Configuration validation failed after edit"
        read -r -p "Continue anyway? (y/N): " confirm
        [[ ! "$confirm" =~ ^[Yy]$ ]] && return 1
    fi
}

# Main function
main() {
    local command=""
    local verbose=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            list|get|set|reset|validate|backup|restore|edit)
                command="$1"
                shift
                ;;
            *)
                if [[ -z "$command" ]]; then
                    command="$1"
                else
                    break
                fi
                shift
                ;;
        esac
    done
    
    # Execute command
    case "$command" in
        list)
            list_config_values
            ;;
        get)
            local key="$1"
            get_config_value "$key"
            ;;
        set)
            local key="$1"
            local value="$2"
            set_config_value "$key" "$value"
            ;;
        reset)
            reset_configuration
            ;;
        validate)
            validate_configuration
            ;;
        backup)
            backup_configuration
            ;;
        restore)
            local timestamp="$1"
            restore_configuration "$timestamp"
            ;;
        edit)
            edit_configuration
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