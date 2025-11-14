#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Shell Script Linter (Shellcheck Integration)
# ═══════════════════════════════════════════════════════════
# Validates all shell scripts in Kitty configuration
#
# HARDENED v2.1: Automated code quality validation

# Strict error handling
set -euo pipefail

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KITTY_ROOT="${KITTY_ROOT:-$SCRIPT_ROOT}"

if [[ ! -d "$KITTY_ROOT" ]]; then
    echo "Kitty directory not found: $KITTY_ROOT" >&2
    exit 1
fi

mapfile -t SCRIPTS < <(
    cd "$KITTY_ROOT" >/dev/null 2>&1 && \
    find . -type d \( -name '.git' -o -name '.serena' -o -name '.cache' -o -name '.state' \) -prune -o \
        -type f -name '*.sh' -print | sort
)

if [[ ${#SCRIPTS[@]} -eq 0 ]]; then
    echo -e "${RED}❌ No shell scripts found under $KITTY_ROOT${NC}"
    exit 1
fi

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🔍 Kitty Shell Script Linter${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Target directory: $KITTY_ROOT"
echo ""

# Check if shellcheck is installed
if ! command -v shellcheck >/dev/null 2>&1; then
    echo -e "${RED}❌ shellcheck not installed${NC}"
    echo ""
    echo "Install with:"
    echo "  Ubuntu/Debian: sudo apt install shellcheck"
    echo "  Arch:          sudo pacman -S shellcheck"
    echo ""
    exit 1
fi

SHELLCHECK_VER=$(shellcheck --version | grep "version:" | awk '{print $2}')
echo "Using shellcheck version: $SHELLCHECK_VER"
echo ""

ERRORS=0
WARNINGS=0
PASSED=0

for script in "${SCRIPTS[@]}"; do
    local_rel="${script#./}"
    rel_path="$local_rel"
    SCRIPT_PATH="$KITTY_ROOT/$rel_path"

    if [[ ! -f "$SCRIPT_PATH" ]]; then
        echo -e "${RED}⚠️  $rel_path: NOT FOUND${NC}"
        continue
    fi

    echo "Checking $rel_path..."

    # Run shellcheck with severity levels
    if OUTPUT=$(shellcheck -S style "$SCRIPT_PATH" 2>&1); then
        echo -e "  ${GREEN}✅ PASSED${NC}"
        ((PASSED++))
    else
        # Check severity of issues
        if echo "$OUTPUT" | grep -q "error:"; then
            echo -e "  ${RED}❌ ERRORS FOUND${NC}"
            ((ERRORS++))
        else
            echo -e "  ${RED}⚠️  WARNINGS FOUND${NC}"
            ((WARNINGS++))
        fi

        # Show first few issues
        echo "$OUTPUT" | head -n 10
        echo ""
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "LINTING SUMMARY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ Passed:  $PASSED${NC}"

if [[ $WARNINGS -gt 0 ]]; then
    echo -e "${RED}⚠️  Warnings: $WARNINGS${NC}"
fi

if [[ $ERRORS -gt 0 ]]; then
    echo -e "${RED}❌ Errors:   $ERRORS${NC}"
fi

echo ""

if [[ $ERRORS -eq 0 && $WARNINGS -eq 0 ]]; then
    echo -e "${GREEN}🎉 All scripts passed linting!${NC}"
    exit 0
elif [[ $ERRORS -eq 0 ]]; then
    echo "⚠️  Some warnings detected (review recommended)"
    exit 0
else
    echo "❌ Linting failed (fix errors above)"
    exit 1
fi
