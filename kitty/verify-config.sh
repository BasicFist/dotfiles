#!/bin/bash
# ⚡ Kitty HARDENED v2.1 Configuration Verification Script
# Validates modular architecture, dependencies, and security settings
#
# HARDENED v2.1: Added proper exit codes for CI/CD integration

set -uo pipefail

version_ge() {
    local v1="$1"
    local v2="$2"
    python3 - "$v1" "$v2" <<'PY' >/dev/null 2>&1
import sys
from itertools import zip_longest

def parse(version):
    parts = []
    for token in version.replace('-', '.').split('.'):
        if not token:
            continue
        numeric = ''.join(ch for ch in token if ch.isdigit())
        if numeric:
            parts.append(int(numeric))
        else:
            parts.append(0)
    return parts or [0]

left = parse(sys.argv[1])
right = parse(sys.argv[2])

for l, r in zip_longest(left, right, fillvalue=0):
    if l > r:
        sys.exit(0)
    if l < r:
        sys.exit(1)

sys.exit(0)
PY
}

# Exit code & warning tracking
EXIT_CODE=0
WARNINGS=()

KITTY_ROOT="${KITTY_ROOT:-$HOME/.config/kitty}"
KITTY_CONF="$KITTY_ROOT/kitty.conf"
KITTY_MODULE_DIR="$KITTY_ROOT/kitty.d"

if [[ ! -d "$KITTY_ROOT" ]]; then
    echo "Kitty directory not found: $KITTY_ROOT" >&2
    exit 1
fi

add_warning() {
    WARNINGS+=("$1")
}

check_command() {
    local cmd="$1"
    local description="$2"
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "   ✅ $description ($cmd)"
        return 0
    fi
    echo "   ⚠️  Missing: $description ($cmd)"
    add_warning "$description not available ($cmd)"
    return 1
}

check_any_command() {
    local description="$1"
    shift
    local cmds=("$@")
    for cmd in "${cmds[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            echo "   ✅ $description ($cmd)"
            return 0
        fi
    done
    local joined=""
    for cmd in "${cmds[@]}"; do
        joined+="$cmd, "
    done
    joined=${joined%, }
    echo "   ⚠️  Missing: $description ($joined)"
    add_warning "$description not available ($joined)"
    return 1
}

echo "⚡ Kitty HARDENED v2.1 Configuration Verification"
echo "Target directory: $KITTY_ROOT"
echo ""

# Check Kitty version
echo "1. Kitty version check..."
KITTY_VER=$(kitty --version 2>/dev/null | grep -oE '[0-9]+(\.[0-9]+)*' | head -1)
if [[ -n "$KITTY_VER" ]]; then
    REQUIRED_VER="0.37.0"
    if command -v python3 >/dev/null 2>&1 && version_ge "$KITTY_VER" "$REQUIRED_VER"; then
        echo "   ✅ Kitty $KITTY_VER (cursor_trail supported)"
    elif command -v python3 >/dev/null 2>&1; then
        echo "   ⚠️  Kitty $KITTY_VER (upgrade to $REQUIRED_VER+ for cursor_trail)"
        add_warning "Kitty version $KITTY_VER < $REQUIRED_VER"
    elif command -v bc >/dev/null 2>&1; then
        if [[ $(echo "$KITTY_VER >= $REQUIRED_VER" | bc) -eq 1 ]]; then
            echo "   ✅ Kitty $KITTY_VER (cursor_trail supported)"
        else
            echo "   ⚠️  Kitty $KITTY_VER (upgrade to $REQUIRED_VER+ for cursor_trail)"
            add_warning "Kitty version $KITTY_VER < $REQUIRED_VER"
        fi
    else
        echo "   ✅ Kitty $KITTY_VER detected"
    fi
else
    echo "   ❌ Kitty not found or version check failed"
    EXIT_CODE=1
fi
echo ""

# Dependency checks
echo "2. Dependency checks..."
check_command bc "bc (numeric comparisons)"
check_any_command "Clipboard utility (Ctrl+Shift+Alt+P menu)" wl-paste xclip
check_command python3 "python3 (JSON parsing for overlays)"
check_command mpstat "mpstat (CPU telemetry for Ctrl+Alt+M monitor)"
check_command sensors "sensors (CPU temps for Ctrl+Alt+M / Ctrl+Shift+S)"
check_command nvidia-smi "nvidia-smi (GPU telemetry for Ctrl+Shift+G)"
check_command tmux "tmux (shared session helper Ctrl+Alt+X)"
echo ""

# Check paste_actions (CRITICAL SECURITY)
echo "3. Security: paste_actions..."
if grep -q "paste_actions" "$KITTY_MODULE_DIR/security.conf" 2>/dev/null; then
    echo "   ✅ paste_actions enabled in security.conf"
else
    echo "   ❌ CRITICAL: paste_actions MISSING"
    EXIT_CODE=1
fi

# Check remote control
echo "4. Security: remote_control..."
if grep -q "allow_remote_control socket-only" "$KITTY_MODULE_DIR/security.conf" 2>/dev/null; then
    echo "   ✅ Remote control: socket-only"
else
    echo "   ⚠️  Remote control not configured as socket-only"
    add_warning "Remote control not constrained to socket-only"
fi

# Check modular architecture
echo "5. Modular architecture..."
MODULES=(
    "security.conf"
    "core.conf"
    "perf-balanced.conf"
    "perf-lowlatency.conf"
    "theme-neon.conf"
    "theme-matrix-ops.conf"
    "visual-effects-base.conf"
    "visual-effects-tabs.conf"
    "visual-effects-neon.conf"
    "visual-effects-matrix.conf"
    "mouse.conf"
    "keybindings.conf"
)
MISSING_MODULES=()

for module in "${MODULES[@]}"; do
    if [[ -f "$KITTY_MODULE_DIR/$module" ]]; then
        LINES=$(wc -l < "$KITTY_MODULE_DIR/$module")
        echo "   ✅ $module exists ($LINES lines)"
    else
        echo "   ❌ $module MISSING"
        MISSING_MODULES+=("$module")
    fi
done

# Check main config includes
echo "6. Configuration includes..."
if grep -q "include kitty.d/security.conf" "$KITTY_CONF" 2>/dev/null; then
    echo "   ✅ security.conf included"
else
    echo "   ❌ security.conf NOT included in kitty.conf"
    EXIT_CODE=1
fi

# Theme include presence (at least one primary theme)
if grep -q "include kitty.d/theme-neon.conf" "$KITTY_CONF" 2>/dev/null || \
   grep -q "include kitty.d/theme-matrix-ops.conf" "$KITTY_CONF" 2>/dev/null; then
    echo "   ✅ Theme include detected"
else
    echo "   ⚠️  No theme include found"
    add_warning "No theme include active"
fi

# Sanity check for active profiles/themes
echo "7. Profile/theme sanity..."
ACTIVE_PERF=$(grep -Ec '^[[:space:]]*include kitty\.d/perf-.*\.conf' "$KITTY_CONF" || true)
if [[ $ACTIVE_PERF -eq 0 ]]; then
    echo "   ⚠️  No performance profile included"
    add_warning "No performance profile active (perf-balanced or perf-lowlatency)"
elif [[ $ACTIVE_PERF -gt 1 ]]; then
    echo "   ❌ Multiple performance profiles included ($ACTIVE_PERF)"
    EXIT_CODE=1
else
    echo "   ✅ Single performance profile active"
fi

ACTIVE_THEME=$(grep -Ec '^[[:space:]]*include kitty\.d/theme-.*\.conf' "$KITTY_CONF" || true)
if [[ $ACTIVE_THEME -eq 0 ]]; then
    echo "   ⚠️  No theme included"
    add_warning "No theme active (theme-neon or theme-matrix-ops)"
elif [[ $ACTIVE_THEME -gt 1 ]]; then
    echo "   ❌ Multiple themes included ($ACTIVE_THEME)"
    EXIT_CODE=1
else
    echo "   ✅ Single theme active"
fi

# Check for deprecated files
echo "8. Deprecated files cleanup..."
if [[ -f "$KITTY_ROOT/glitch.conf.DEPRECATED" ]]; then
    echo "   ✅ glitch.conf properly deprecated"
else
    if [[ -f "$KITTY_ROOT/glitch.conf" ]]; then
        echo "   ⚠️  glitch.conf exists (not deprecated)"
        add_warning "Legacy glitch.conf still present"
    else
        echo "   ℹ️  glitch.conf not found"
    fi
fi

# Check backups exist
echo "9. Backup verification..."
BACKUP_COUNT=$(find "$KITTY_ROOT" -name "*.backup-*" 2>/dev/null | wc -l)
if [[ $BACKUP_COUNT -gt 0 ]]; then
    echo "   ✅ Found $BACKUP_COUNT backup files"
else
    echo "   ⚠️  No backup files found"
    add_warning "No kitty.conf backups detected"
fi

# Validate configuration syntax
echo "10. Configuration syntax validation..."
if KITTY_CONFIG_DIRECTORY="$KITTY_ROOT" kitty +runpy "from kitty.config import load_config; print('OK')" 2>/dev/null | grep -q "OK"; then
    echo "   ✅ Configuration loads successfully"
else
    echo "   ❌ Configuration has syntax errors"
    EXIT_CODE=1
fi

# Summary
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "VERIFICATION SUMMARY"
echo "═══════════════════════════════════════════════════════════"

if [[ ${#MISSING_MODULES[@]} -eq 0 ]]; then
    echo "✅ All modular components present"
else
    echo "❌ Missing modules: ${MISSING_MODULES[*]}"
    EXIT_CODE=1
fi

if [[ ${#WARNINGS[@]} -gt 0 ]]; then
    echo ""
    echo "Warnings:"
    for warning in "${WARNINGS[@]}"; do
        echo "  - $warning"
    done
fi

echo ""
if [[ $EXIT_CODE -eq 0 ]]; then
    echo "🎉 Verification PASSED - Configuration is healthy"
else
    echo "⚠️  Verification FAILED - Fix issues above"
fi

echo ""
echo "Next steps:"
echo "  - Reload configuration: Ctrl+Shift+F5 or 'kitty @ load-config'"
echo "  - Test security: Copy malicious text and paste to verify quoting"
echo "  - Switch themes: Edit kitty.conf include statements"
echo "  - Switch profiles: Comment/uncomment perf-*.conf includes"
echo ""

exit $EXIT_CODE
