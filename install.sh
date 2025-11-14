#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Dotfiles Installer
# ═══════════════════════════════════════════════════════════
# Automated installation script for enterprise-grade dotfiles
# Last Updated: 2025-10-29

set -euo pipefail

# Source the installer logic
source "$(dirname "${BASH_SOURCE[0]}")/kitty/scripts/lib/installer_logic.sh"

# ═══════════════════════════════════════════════════════════
# Banner
# ═══════════════════════════════════════════════════════════

clear
cat << 'EOF'
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║              DOTFILES INSTALLATION WIZARD                 ║
║                                                           ║
║        Enterprise-Grade Terminal Configuration            ║
║              with AI Collaboration System                 ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝

EOF

info "📦 Features:"
echo "  • Kitty Terminal (modular config, A+ security)"
echo "  • Tmux Enhancement (16 plugins)"
echo "  • AI Agents System (5 collaboration modes)"
echo "  • Complete Documentation (3,000+ lines)"
echo ""

# ═══════════════════════════════════════════════════════════
# Pre-flight Checks
# ═══════════════════════════════════════════════════════════

run_pre_flight_checks

# ═══════════════════════════════════════════════════════════
# Installation Options
# ═══════════════════════════════════════════════════════════

echo ""
info "📋 Installation Options:"
echo ""
echo "1. Full Install (Kitty + Tmux + AI Agents)"
echo "2. Kitty Only"
echo "3. Tmux Only"
echo "4. Custom Selection"
echo "5. Exit"
echo ""

read -p "$(info "Select option [1-5]: ")" -n 1 -r OPTION
echo ""
echo ""

# ═══════════════════════════════════════════════════════════
# Execute Installation
# ═══════════════════════════════════════════════════════════

case $OPTION in
    1)
        echo ""
        info "🚀 Full Installation Starting..."
        echo ""
        install_kitty
        echo ""
        install_tmux
        echo ""
        install_zsh
        ;;
    2)
        echo ""
        info "🚀 Kitty Installation Starting..."
        echo ""
        install_kitty
        ;;
    3)
        echo ""
        info "🚀 Tmux Installation Starting..."
        echo ""
        install_tmux
        ;;
    4)
        echo ""
        info "Custom installation not yet implemented"
        info "Please run option 1, 2, or 3"
        exit 1
        ;;
    5)
        echo ""
        info "Installation cancelled"
        exit 0
        ;;
    *)
        error "Invalid option"
        exit 1
        ;;
esac

# ═══════════════════════════════════════════════════════════
# Post-Installation
# ═══════════════════════════════════════════════════════════

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
success "🎉 Installation Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

info "📚 Quick Start:"
echo ""
echo "Kitty Terminal:"
echo "  • Press F12 for shortcuts menu"
echo "  • Press Ctrl+Alt+M for AI Agents TUI"
echo "  • Press Ctrl+Shift+F5 to reload config"
echo ""

echo "Tmux Enhancement:"
echo "  • Start tmux: tmux"
echo "  • Install plugins: Ctrl+B then Shift+I"
echo "  • Session manager: Ctrl+B then O"
echo "  • Pane jump: Ctrl+B then j"
echo ""

echo "AI Agents:"
echo "  • Management TUI: Ctrl+Alt+M"
echo "  • Session browser: Ctrl+Alt+F"
echo "  • KB search: Ctrl+Alt+K"
echo "  • Pane switcher: Ctrl+Alt+P"
echo "  • Mode launcher: Ctrl+Alt+L"
echo ""

info "📖 Documentation:"
echo "  • Full guide: ~/.config/kitty/docs/TMUX-PLUGINS-COMPLETE-GUIDE.md"
echo "  • AI Agents: ~/.config/kitty/docs/AI-AGENTS-TMUX-GUIDE.md"
echo "  • Quick ref: ~/.config/kitty/QUICK-REFERENCE.md"
echo ""

info "🔧 Configuration Files:"
echo "  • Kitty: ~/.config/kitty/"
echo "  • Tmux: ~/.tmux.conf"
echo "  • Logs: ~/tmux-logs/"
echo ""

success "🎊 Enjoy your enterprise-grade terminal setup!"
echo ""
