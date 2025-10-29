#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Tmux Plugins Installation Helper
# ═══════════════════════════════════════════════════════════
# Helps install all 16 configured tmux plugins
# Last Updated: 2025-10-29

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/colors.sh" 2>/dev/null || {
    # Fallback colors if lib not available
    success_color() { echo -e "\033[32m$*\033[0m"; }
    error_color() { echo -e "\033[31m$*\033[0m"; }
    info_color() { echo -e "\033[36m$*\033[0m"; }
    warning_color() { echo -e "\033[33m$*\033[0m"; }
}

# ═══════════════════════════════════════════════════════════
# Banner
# ═══════════════════════════════════════════════════════════

clear
cat << 'EOF'
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║           🔌 TMUX PLUGINS INSTALLATION HELPER             ║
║                                                           ║
║          AI Agents Collaboration System v2.0              ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝

EOF

info_color "📦 Total Plugins Configured: 16"
echo ""
info_color "🎯 Core Plugins: 7"
echo "   • tmux-sensible (baseline settings)"
echo "   • tmux-resurrect (session save/restore)"
echo "   • tmux-continuum (auto-save every 15 min)"
echo "   • tmux-yank (clipboard integration)"
echo "   • tmux-open (open files/URLs)"
echo "   • tmux-copycat (enhanced search)"
echo "   • tmux-prefix-highlight (visual prefix indicator)"
echo ""
info_color "🚀 Enhanced Plugins: 8 (Added 2025-10-29)"
echo "   • tmux-sessionx (session manager with fzf)"
echo "   • tmux-jump (keyword pane navigation)"
echo "   • tmux-fzf (general fzf integration)"
echo "   • extrakto (text extraction with fzf)"
echo "   • tmux-menus (visual TUI menu)"
echo "   • tmux-sessionist (session utilities)"
echo "   • tmux-logging (pane output logging)"
echo "   • tmux-fingers (hint-based copy/paste)"
echo ""

# ═══════════════════════════════════════════════════════════
# Checks
# ═══════════════════════════════════════════════════════════

info_color "🔍 Pre-flight Checks..."
echo ""

# Check tmux installed
if ! command -v tmux &> /dev/null; then
    error_color "❌ tmux not found!"
    echo "   Install tmux first: sudo apt install tmux"
    exit 1
fi
success_color "✅ tmux installed ($(tmux -V))"

# Check TPM installed
if [[ ! -d ~/.tmux/plugins/tpm ]]; then
    error_color "❌ TPM not found!"
    echo "   Install TPM first: Run setup-tmux-tpm.sh"
    exit 1
fi
success_color "✅ TPM installed"

# Check tmux.conf
if [[ ! -f ~/.tmux.conf ]]; then
    error_color "❌ ~/.tmux.conf not found!"
    echo "   Copy tmux.conf to home directory first"
    exit 1
fi
success_color "✅ ~/.tmux.conf exists"

# Check tmux.conf has plugins
plugin_count=$(grep -c "@plugin" ~/.tmux.conf 2>/dev/null || echo "0")
if [[ $plugin_count -lt 16 ]]; then
    warning_color "⚠️  Only $plugin_count plugins configured (expected 16)"
    echo "   You may need to update ~/.tmux.conf"
else
    success_color "✅ All 16 plugins configured"
fi

echo ""

# ═══════════════════════════════════════════════════════════
# Installation
# ═══════════════════════════════════════════════════════════

info_color "📦 Installation Options:"
echo ""
echo "1. Inside tmux (Recommended)"
echo "   - Start tmux"
echo "   - Press: Ctrl+B then Shift+I (capital I)"
echo "   - Wait for installation (~1-2 minutes)"
echo ""
echo "2. Check current status"
echo "   - Launch AI Agents TUI: Ctrl+Alt+M"
echo "   - Select: System Status"
echo "   - See plugin installation status"
echo ""

warning_color "⚠️  IMPORTANT NOTES:"
echo ""
echo "• Installation must be done inside tmux session"
echo "• First installation takes 1-2 minutes"
echo "• Some plugins require additional dependencies:"
echo "    - extrakto: fzf (already installed ✅)"
echo "    - tmux-yank: xclip or xsel"
echo "    - tmux-sessionx: zoxide (optional)"
echo ""

# Check dependencies
info_color "🔧 Dependency Check:"
echo ""

[[ -x "$(command -v fzf)" ]] && success_color "✅ fzf installed" || warning_color "⚠️  fzf not found (install: sudo apt install fzf)"
[[ -x "$(command -v xclip)" ]] || [[ -x "$(command -v xsel)" ]] && success_color "✅ clipboard tool installed" || warning_color "⚠️  xclip/xsel not found (install: sudo apt install xclip)"
[[ -x "$(command -v zoxide)" ]] && success_color "✅ zoxide installed (optional)" || info_color "ℹ️  zoxide not found (optional for sessionx)"

echo ""

# ═══════════════════════════════════════════════════════════
# Current Status
# ═══════════════════════════════════════════════════════════

info_color "📊 Current Installation Status:"
echo ""

if [[ -d ~/.tmux/plugins ]]; then
    installed_count=$(find ~/.tmux/plugins -maxdepth 1 -type d 2>/dev/null | tail -n +2 | wc -l)

    if [[ $installed_count -gt 1 ]]; then
        success_color "✅ Plugins found: $installed_count"
        echo ""
        echo "Installed plugins:"
        ls -1 ~/.tmux/plugins/ | grep -v "^tpm$" | sed 's/^/   • /'
    else
        warning_color "⚠️  No plugins installed yet (only TPM)"
    fi
else
    warning_color "⚠️  Plugin directory not found"
fi

echo ""

# ═══════════════════════════════════════════════════════════
# Next Steps
# ═══════════════════════════════════════════════════════════

info_color "🚀 Next Steps:"
echo ""
echo "1. Start tmux:"
echo "   $ tmux"
echo ""
echo "2. Install plugins:"
echo "   Press: Ctrl+B then Shift+I"
echo ""
echo "3. Wait for installation to complete"
echo "   You'll see: 'TMUX environment reloaded'"
echo ""
echo "4. Verify installation:"
echo "   Press: Ctrl+Alt+M → System Status"
echo ""
echo "5. Read documentation:"
echo "   $ cat ~/.config/kitty/docs/TMUX-PLUGINS-COMPLETE-GUIDE.md"
echo ""

# ═══════════════════════════════════════════════════════════
# Interactive Mode
# ═══════════════════════════════════════════════════════════

echo ""
read -p "$(info_color "Would you like to start tmux now? [y/N]: ")" -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    success_color "✅ Starting tmux..."
    echo ""
    info_color "Remember:"
    echo "   1. Press: Ctrl+B then Shift+I"
    echo "   2. Wait for installation"
    echo "   3. Check status: Ctrl+Alt+M"
    echo ""
    sleep 2

    # Start tmux
    tmux
else
    echo ""
    info_color "ℹ️  Run 'tmux' when ready to install plugins"
    echo ""
fi

success_color "👋 Installation helper complete!"
