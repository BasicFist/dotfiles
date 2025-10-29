#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Verify Collaboration Modes Installation
# ═══════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/colors.sh"

echo ""
success_color "═══════════════════════════════════════════════════════"
success_color " AI Agents Collaboration Modes - Installation Check"
success_color "═══════════════════════════════════════════════════════"
echo ""

# Check counts
TOTAL_SCRIPTS=0
EXECUTABLE_SCRIPTS=0
MISSING_SCRIPTS=0

info_color "Checking mode launchers..."
MODES=("pair-programming" "debate" "teaching" "consensus" "competition")
for mode in "${MODES[@]}"; do
    TOTAL_SCRIPTS=$((TOTAL_SCRIPTS + 1))
    if [[ -f "${SCRIPT_DIR}/modes/${mode}.sh" ]]; then
        if [[ -x "${SCRIPT_DIR}/modes/${mode}.sh" ]]; then
            echo "  ✅ ${mode}.sh"
            EXECUTABLE_SCRIPTS=$((EXECUTABLE_SCRIPTS + 1))
        else
            echo "  ⚠️  ${mode}.sh (not executable)"
        fi
    else
        echo "  ❌ ${mode}.sh (missing)"
        MISSING_SCRIPTS=$((MISSING_SCRIPTS + 1))
    fi
done

echo ""
info_color "Checking pair programming commands..."
PAIR_CMDS=("switch" "observe" "issue" "complete")
for cmd in "${PAIR_CMDS[@]}"; do
    TOTAL_SCRIPTS=$((TOTAL_SCRIPTS + 1))
    if [[ -f "${SCRIPT_DIR}/ai-pair-${cmd}.sh" ]]; then
        if [[ -x "${SCRIPT_DIR}/ai-pair-${cmd}.sh" ]]; then
            echo "  ✅ ai-pair-${cmd}.sh"
            EXECUTABLE_SCRIPTS=$((EXECUTABLE_SCRIPTS + 1))
        else
            echo "  ⚠️  ai-pair-${cmd}.sh (not executable)"
        fi
    else
        echo "  ❌ ai-pair-${cmd}.sh (missing)"
        MISSING_SCRIPTS=$((MISSING_SCRIPTS + 1))
    fi
done

echo ""
info_color "Checking debate commands..."
DEBATE_CMDS=("position" "argue" "rebut" "consensus")
for cmd in "${DEBATE_CMDS[@]}"; do
    TOTAL_SCRIPTS=$((TOTAL_SCRIPTS + 1))
    if [[ -f "${SCRIPT_DIR}/ai-debate-${cmd}.sh" ]]; then
        if [[ -x "${SCRIPT_DIR}/ai-debate-${cmd}.sh" ]]; then
            echo "  ✅ ai-debate-${cmd}.sh"
            EXECUTABLE_SCRIPTS=$((EXECUTABLE_SCRIPTS + 1))
        else
            echo "  ⚠️  ai-debate-${cmd}.sh (not executable)"
        fi
    else
        echo "  ❌ ai-debate-${cmd}.sh (missing)"
        MISSING_SCRIPTS=$((MISSING_SCRIPTS + 1))
    fi
done

echo ""
info_color "Checking teaching commands..."
TEACH_CMDS=("explain" "question" "exercise" "check" "mastered")
for cmd in "${TEACH_CMDS[@]}"; do
    TOTAL_SCRIPTS=$((TOTAL_SCRIPTS + 1))
    if [[ -f "${SCRIPT_DIR}/ai-teach-${cmd}.sh" ]]; then
        if [[ -x "${SCRIPT_DIR}/ai-teach-${cmd}.sh" ]]; then
            echo "  ✅ ai-teach-${cmd}.sh"
            EXECUTABLE_SCRIPTS=$((EXECUTABLE_SCRIPTS + 1))
        else
            echo "  ⚠️  ai-teach-${cmd}.sh (not executable)"
        fi
    else
        echo "  ❌ ai-teach-${cmd}.sh (missing)"
        MISSING_SCRIPTS=$((MISSING_SCRIPTS + 1))
    fi
done

echo ""
info_color "Checking consensus commands..."
CONSENSUS_CMDS=("propose" "concern" "refine" "vote" "agree")
for cmd in "${CONSENSUS_CMDS[@]}"; do
    TOTAL_SCRIPTS=$((TOTAL_SCRIPTS + 1))
    if [[ -f "${SCRIPT_DIR}/ai-consensus-${cmd}.sh" ]]; then
        if [[ -x "${SCRIPT_DIR}/ai-consensus-${cmd}.sh" ]]; then
            echo "  ✅ ai-consensus-${cmd}.sh"
            EXECUTABLE_SCRIPTS=$((EXECUTABLE_SCRIPTS + 1))
        else
            echo "  ⚠️  ai-consensus-${cmd}.sh (not executable)"
        fi
    else
        echo "  ❌ ai-consensus-${cmd}.sh (missing)"
        MISSING_SCRIPTS=$((MISSING_SCRIPTS + 1))
    fi
done

echo ""
info_color "Checking competition commands..."
COMPETE_CMDS=("submit" "score" "winner")
for cmd in "${COMPETE_CMDS[@]}"; do
    TOTAL_SCRIPTS=$((TOTAL_SCRIPTS + 1))
    if [[ -f "${SCRIPT_DIR}/ai-compete-${cmd}.sh" ]]; then
        if [[ -x "${SCRIPT_DIR}/ai-compete-${cmd}.sh" ]]; then
            echo "  ✅ ai-compete-${cmd}.sh"
            EXECUTABLE_SCRIPTS=$((EXECUTABLE_SCRIPTS + 1))
        else
            echo "  ⚠️  ai-compete-${cmd}.sh (not executable)"
        fi
    else
        echo "  ❌ ai-compete-${cmd}.sh (missing)"
        MISSING_SCRIPTS=$((MISSING_SCRIPTS + 1))
    fi
done

echo ""
info_color "Checking mode dispatcher..."
TOTAL_SCRIPTS=$((TOTAL_SCRIPTS + 1))
if [[ -f "${SCRIPT_DIR}/ai-mode-start.sh" ]]; then
    if [[ -x "${SCRIPT_DIR}/ai-mode-start.sh" ]]; then
        echo "  ✅ ai-mode-start.sh"
        EXECUTABLE_SCRIPTS=$((EXECUTABLE_SCRIPTS + 1))
    else
        echo "  ⚠️  ai-mode-start.sh (not executable)"
    fi
else
    echo "  ❌ ai-mode-start.sh (missing)"
    MISSING_SCRIPTS=$((MISSING_SCRIPTS + 1))
fi

echo ""
info_color "Checking documentation..."
if [[ -f "${SCRIPT_DIR}/../docs/COLLABORATION-MODES.md" ]]; then
    echo "  ✅ COLLABORATION-MODES.md"
else
    echo "  ❌ COLLABORATION-MODES.md (missing)"
fi

echo ""
success_color "═══════════════════════════════════════════════════════"
success_color " Installation Summary"
success_color "═══════════════════════════════════════════════════════"
echo ""
echo "  Total scripts expected: ${TOTAL_SCRIPTS}"
echo "  Scripts found & executable: ${EXECUTABLE_SCRIPTS}"
echo "  Scripts missing: ${MISSING_SCRIPTS}"
echo ""

if [[ $MISSING_SCRIPTS -eq 0 && $EXECUTABLE_SCRIPTS -eq $TOTAL_SCRIPTS ]]; then
    success_color "✅ ALL SYSTEMS OPERATIONAL!"
    echo ""
    echo "Ready to use collaboration modes:"
    echo ""
    echo "  Start modes with:"
    echo "    ai-mode-start.sh pair"
    echo "    ai-mode-start.sh debate \"<topic>\""
    echo "    ai-mode-start.sh teach <expert> <learner> <topic>"
    echo "    ai-mode-start.sh consensus \"<decision>\""
    echo "    ai-mode-start.sh compete \"<challenge>\""
    echo ""
    echo "  Full documentation:"
    echo "    cat ~/.config/kitty/docs/COLLABORATION-MODES.md"
    echo ""
    exit 0
else
    error_color "⚠️  INSTALLATION INCOMPLETE"
    echo ""
    echo "Some scripts are missing or not executable."
    echo "Run from repository root:"
    echo "  chmod +x lab/dotfiles/kitty/scripts/*.sh"
    echo "  chmod +x lab/dotfiles/kitty/scripts/modes/*.sh"
    echo "  rsync -av lab/dotfiles/kitty/ ~/.config/kitty/"
    echo ""
    exit 1
fi
