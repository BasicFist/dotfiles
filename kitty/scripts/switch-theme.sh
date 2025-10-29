#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Interactive Theme Switcher
# ═══════════════════════════════════════════════════════════
# Automates theme switching by comment/uncomment in kitty.conf
#
# HARDENED v2.1: Safe theme switching with automatic reload

# Strict error handling
set -euo pipefail

KITTY_ROOT="${KITTY_ROOT:-$HOME/.config/kitty}"
KITTY_CONF="$KITTY_ROOT/kitty.conf"
THEMES=("theme-neon.conf" "theme-matrix-ops.conf")
VISUALS=("visual-effects-neon.conf" "visual-effects-matrix.conf")

# Portable sed handling (GNU/BSD)
SED_CMD="sed"
SED_MODE="gnu"
if [[ "$(uname -s)" == "Darwin" ]]; then
    if command -v gsed >/dev/null 2>&1; then
        SED_CMD="gsed"
    else
        SED_MODE="bsd"
    fi
fi

sed_inplace() {
    local expr="$1"
    local file="$2"
    if [[ "$SED_MODE" == "bsd" ]]; then
        "$SED_CMD" -i '' "$expr" "$file"
    else
        "$SED_CMD" -i "$expr" "$file"
    fi
}

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Verify kitty.conf exists
if [[ ! -f "$KITTY_CONF" ]]; then
    echo -e "${RED}❌ Error: $KITTY_CONF not found${NC}"
    exit 1
fi

echo -e "${CYAN}🎨 Kitty Theme Switcher${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Available themes:"

for i in "${!THEMES[@]}"; do
    THEME_NAME="${THEMES[$i]%.conf}"
    THEME_NAME="${THEME_NAME#theme-}"  # Remove 'theme-' prefix

    # Check if currently active
    if grep -q "^include kitty.d/${THEMES[$i]}" "$KITTY_CONF" 2>/dev/null; then
        echo "$((i+1)). $THEME_NAME ${GREEN}(active)${NC}"
    else
        echo "$((i+1)). $THEME_NAME"
    fi
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
read -r -p "Select theme (1-${#THEMES[@]}): " choice

# Validate input
if [[ ! "$choice" =~ ^[0-9]+$ ]] || [[ $choice -lt 1 ]] || [[ $choice -gt ${#THEMES[@]} ]]; then
    echo -e "${RED}❌ Invalid selection${NC}"
    exit 1
fi

SELECTED_THEME="${THEMES[$((choice-1))]}"
SELECTED_VISUAL="${VISUALS[$((choice-1))]}"
THEME_DISPLAY="${SELECTED_THEME%.conf}"
THEME_DISPLAY="${THEME_DISPLAY#theme-}"

echo ""
echo "🔄 Switching to: $THEME_DISPLAY"

# Create backup before modifying
BACKUP_FILE="$KITTY_CONF.bak-$(date +%Y%m%d-%H%M%S)"
cp "$KITTY_CONF" "$BACKUP_FILE"

# Comment out all themes and theme visuals
for theme in "${THEMES[@]}"; do
    sed_inplace "s|^include kitty.d/$theme|# include kitty.d/$theme|g" "$KITTY_CONF"
done
for visual in "${VISUALS[@]}"; do
    sed_inplace "s|^include kitty.d/$visual|# include kitty.d/$visual|g" "$KITTY_CONF"
done

# Uncomment selected theme + visuals
sed_inplace "s|^# include kitty.d/$SELECTED_THEME|include kitty.d/$SELECTED_THEME|g" "$KITTY_CONF"
sed_inplace "s|^# include kitty.d/$SELECTED_VISUAL|include kitty.d/$SELECTED_VISUAL|g" "$KITTY_CONF"

echo "✅ Theme configuration updated"

# Reload Kitty configuration
if [[ "$KITTY_ROOT" == "$HOME/.config/kitty" ]]; then
    if kitty @ load-config 2>/dev/null; then
        echo -e "${GREEN}✨ Theme '$THEME_DISPLAY' applied successfully${NC}"
    else
        echo -e "${RED}⚠️  Could not auto-reload (press Ctrl+Shift+F5 manually)${NC}"
    fi
else
    echo -e "${CYAN}ℹ️  Skipped live reload (KITTY_ROOT=${KITTY_ROOT})${NC}"
fi

echo ""
echo "Backup created: $BACKUP_FILE"
