#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Dotfiles Installer
# ═══════════════════════════════════════════════════════════
# Automated installation script for enterprise-grade dotfiles
# Last Updated: 2025-10-29

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Functions
info() { echo -e "${CYAN}ℹ️  $*${NC}"; }
success() { echo -e "${GREEN}✅ $*${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $*${NC}"; }
error() { echo -e "${RED}❌ $*${NC}"; }

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

info "🔍 Checking prerequisites..."
echo ""

# Check OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    success "OS: Linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    success "OS: macOS"
else
    warning "OS: $OSTYPE (untested, may work)"
fi

# Check required commands
MISSING=()

check_command() {
    if command -v "$1" &> /dev/null; then
        success "$1 installed"
    else
        error "$1 not found"
        MISSING+=("$1")
    fi
}

check_command git
check_command kitty
check_command tmux
check_command fzf

# Optional but recommended
if command -v xclip &> /dev/null || command -v xsel &> /dev/null; then
    success "Clipboard tool installed (xclip/xsel)"
else
    warning "Clipboard tool not found (optional: xclip or xsel)"
fi

if command -v zoxide &> /dev/null; then
    success "zoxide installed (optional)"
else
    warning "zoxide not found (optional for sessionx)"
fi

if command -v bat &> /dev/null || command -v batcat &> /dev/null; then
    success "bat installed (optional)"
else
    warning "bat not found (optional for syntax highlighting)"
fi

echo ""

# Exit if missing required tools
if [[ ${#MISSING[@]} -gt 0 ]]; then
    error "Missing required tools: ${MISSING[*]}"
    echo ""
    info "Install missing tools:"
    echo ""
    echo "Ubuntu/Debian:"
    echo "  sudo apt update"
    echo "  sudo apt install -y ${MISSING[*]}"
    echo ""
    echo "Arch Linux:"
    echo "  sudo pacman -S ${MISSING[*]}"
    echo ""
    echo "macOS:"
    echo "  brew install ${MISSING[*]}"
    echo ""
    exit 1
fi

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
# Backup Function
# ═══════════════════════════════════════════════════════════

backup_file() {
    local file="$1"
    if [[ -e "$file" ]]; then
        local backup="${file}.backup.$(date +%Y%m%d-%H%M%S)"
        cp -r "$file" "$backup"
        warning "Backed up: $file → $backup"
    fi
}

# ═══════════════════════════════════════════════════════════
# Installation Functions
# ═══════════════════════════════════════════════════════════

install_kitty() {
    info "Installing Kitty configuration..."

    # Backup existing config
    backup_file ~/.config/kitty

    # Create directory
    mkdir -p ~/.config/kitty

    # Copy assets (scripts, docs, etc.)
    cp -r kitty/* ~/.config/kitty/

    # Copy configuration files
    cp -r kitty_config/* ~/.config/kitty/

    # Make scripts executable
    chmod +x ~/.config/kitty/scripts/*.sh 2>/dev/null || true

    success "Kitty configuration installed"

    # Show next steps
    echo ""
    info "Next steps for Kitty:"
    echo "  1. Restart Kitty or reload config: Ctrl+Shift+F5"
    echo "  2. Open shortcuts menu: F12"
    echo "  3. Launch AI Agents TUI: Ctrl+Alt+M"
}

install_tmux() {
    info "Installing Tmux configuration..."

    # Backup existing config
    backup_file ~/.tmux.conf
    backup_file ~/.tmux

    # Copy tmux.conf
    cp kitty/tmux.conf ~/.tmux.conf

    # Install TPM if not present
    if [[ ! -d ~/.tmux/plugins/tpm ]]; then
        info "Installing TPM (Tmux Plugin Manager)..."
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
        success "TPM installed"
    else
        success "TPM already installed"
    fi

    # Create logging directory
    mkdir -p ~/tmux-logs

    success "Tmux configuration installed"

    # Show next steps
    echo ""
    info "Next steps for Tmux:"
    echo "  1. Start tmux: tmux"
    echo "  2. Install plugins: Ctrl+B then Shift+I"
    echo "  3. Wait for installation (~1-2 minutes)"
    echo "  4. Verify: Ctrl+Alt+M → System Status"
}

install_zsh() {
    info "Installing Zsh configuration (optional)..."

    if [[ ! -d zsh ]]; then
        warning "Zsh config not found, skipping"
        return
    fi

    # Backup existing config
    backup_file ~/.zshrc
    backup_file ~/.zsh

    # Copy configuration
    cp -r zsh ~/.config/ 2>/dev/null || true
    cp zsh/.zshrc ~/ 2>/dev/null || true

    success "Zsh configuration installed (if present)"
}

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
