#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Clipboard Manager for Kitty
# ═══════════════════════════════════════════════════════════
# Enhanced clipboard operations and visual feedback
#
# HARDENED v2.1: Improved error handling and utility detection

# Strict error handling (allow manual handling for missing clipboard tools)
set -uo pipefail

ACTION="${1:-menu}"

# Colors for feedback
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# --- Clipboard Utility Functions ---

clipboard_missing() {
    echo -e "${RED}❌ Error: No clipboard utility found (install wl-clipboard or xclip)${NC}"
    read -r -p "Press Enter to continue..." _
}

# Get clipboard content with proper fallback detection
get_clipboard() {
    if command -v wl-paste >/dev/null 2>&1; then
        wl-paste --no-newline 2>/dev/null || echo ""
    elif command -v xclip >/dev/null 2>&1; then
        xclip -o -selection clipboard 2>/dev/null || echo ""
    else
        clipboard_missing
        return 1
    fi
}

# Get primary selection content
get_primary() {
    if command -v wl-paste >/dev/null 2>&1; then
        wl-paste --primary --no-newline 2>/dev/null || echo ""
    elif command -v xclip >/dev/null 2>&1; then
        xclip -o -selection primary 2>/dev/null || echo ""
    else
        echo ""
    fi
}

case "$ACTION" in
    show)
        # Show current clipboard content
        if ! CONTENT=$(get_clipboard); then
            exit 0
        fi
        if [ -n "$CONTENT" ]; then
            echo -e "${CYAN}📋 Clipboard content:${NC}"
            echo "$CONTENT" | head -n 10
            LINES=$(echo "$CONTENT" | wc -l)
            if [ "$LINES" -gt 10 ]; then
                echo -e "${CYAN}... (${LINES} lines total)${NC}"
            fi
        else
            echo "Clipboard is empty"
        fi
        read -r -p "Press Enter to continue..."
        ;;

    copy-notify)
        # Copy with visual notification
        if ! CONTENT=$(get_clipboard); then
            exit 0
        fi
        CHARS=${#CONTENT}
        LINES=$(printf '%s\n' "$CONTENT" | wc -l)
        echo -e "${GREEN}✓ Copied ${CHARS} characters (${LINES} lines)${NC}"
        sleep 1
        ;;

    clear)
        # Clear clipboard
        if command -v wl-copy >/dev/null 2>&1; then
            wl-copy --clear >/dev/null 2>&1 || true
            wl-copy --primary --clear >/dev/null 2>&1 || true
        elif command -v xclip >/dev/null 2>&1; then
            printf '' | xclip -selection clipboard
            printf '' | xclip -selection primary
        fi
        echo -e "${GREEN}✓ Clipboard cleared${NC}"
        sleep 1
        ;;

    stats)
        # Show clipboard statistics
        if ! CLIP=$(get_clipboard); then
            exit 0
        fi
        PRIMARY=$(get_primary)

        echo -e "${CYAN}📊 Clipboard Statistics${NC}"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

        if [ -n "$CLIP" ]; then
            echo -e "${GREEN}Clipboard:${NC}"
            echo "  Characters: ${#CLIP}"
            echo "  Lines: $(printf '%s\n' "$CLIP" | wc -l)"
            echo "  Words: $(printf '%s\n' "$CLIP" | wc -w)"
        else
            echo "Clipboard: empty"
        fi

        echo ""
        if [ -n "$PRIMARY" ]; then
            echo -e "${GREEN}Primary Selection:${NC}"
            echo "  Characters: ${#PRIMARY}"
            echo "  Lines: $(printf '%s\n' "$PRIMARY" | wc -l)"
        else
            echo "Primary Selection: empty"
        fi

        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        read -r -p "Press Enter to continue..."
        ;;

    menu)
        # Interactive menu
        echo -e "${CYAN}📋 Clipboard Manager${NC}"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "1. Show clipboard content"
        echo "2. Show statistics"
        echo "3. Clear clipboard"
        echo "4. Exit"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        read -r -p "Select option: " choice

        case "$choice" in
            1) $0 show ;;
            2) $0 stats ;;
            3) $0 clear ;;
            *) exit 0 ;;
        esac
        ;;

    *)
        echo "Usage: clipboard-manager.sh [show|stats|clear|copy-notify|menu]"
        exit 1
        ;;
esac
