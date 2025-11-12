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

# Offer to install missing tools
if [[ ${#MISSING[@]} -gt 0 ]]; then
    error "Missing required tools: ${MISSING[*]}"
    echo ""
    read -p "$(info "Attempt to install them automatically? [Y/n] ")" -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        if command -v apt-get &>/dev/null; then
            info "Attempting to install with apt-get..."
            sudo apt-get update
            sudo apt-get install -y "${MISSING[@]}"
        elif command -v pacman &>/dev/null; then
            info "Attempting to install with pacman..."
            sudo pacman -S --noconfirm "${MISSING[@]}"
        elif command -v brew &>/dev/null; then
            info "Attempting to install with brew..."
            brew install "${MISSING[@]}"
        else
            error "Could not find a supported package manager (apt, pacman, brew)."
            info "Please install the missing tools manually and re-run the script."
            exit 1
        fi

        # Re-check after installation attempt
        STILL_MISSING=()
        for tool in "${MISSING[@]}"; do
            if ! command -v "$tool" &>/dev/null; then
                STILL_MISSING+=("$tool")
            fi
        done

        if [[ ${#STILL_MISSING[@]} -gt 0 ]]; then
            error "Failed to install: ${STILL_MISSING[*]}"
            info "Please install them manually and re-run the script."
            exit 1
        else
            success "All required tools are now installed."
        fi
    else
        info "Please install the missing tools manually and re-run the script."
        exit 1
    fi
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

BACKUP_DIR=~/.dotfiles_backup_$(date +%Y%m%d-%H%M%S)

backup_file() {
    local file="$1"
    if [[ -e "$file" || -L "$file" ]]; then
        if [ ! -d "$BACKUP_DIR" ]; then
            info "Creating backup directory at $BACKUP_DIR"
            mkdir -p "$BACKUP_DIR"
        fi
        local dest_path
        dest_path="$BACKUP_DIR/$(basename "$file")"
        cp -r "$file" "$dest_path"
        success "Backed up: $file → $dest_path"
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

    # Copy configuration
    cp -r kitty/* ~/.config/kitty/

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

    # Automatically install plugins
    info "Installing Tmux plugins..."
    if [ -f ~/.tmux/plugins/tpm/bin/install_plugins ]; then
        ~/.tmux/plugins/tpm/bin/install_plugins
        success "Tmux plugins installation script executed."
        info "Run 'tmux' and press Ctrl+B then 'I' if any plugins failed."
    else
        warning "Could not find TPM install script. Please install plugins manually."
        info "To install: start tmux, then press Ctrl+B then Shift+I"
    fi
}

install_zsh() {
    info "Installing Zsh configuration (optional)..."

    if [[ ! -d zsh ]]; then
        warning "Zsh config directory not found in repository, skipping."
        return
    fi

    local repo_zsh_dir
    repo_zsh_dir="$(pwd)/zsh" # Absolute path to zsh dir in the repo
    local config_zsh_dir="$HOME/.config/zsh"
    local user_zshrc="$HOME/.zshrc"

    info "Setting up Zsh configuration with symbolic links..."

    # Backup existing config
    backup_file "$user_zshrc"
    backup_file "$config_zsh_dir"

    # Remove existing files/links to prevent `ln` errors
    rm -rf "$user_zshrc"
    rm -rf "$config_zsh_dir"

    # Create symlinks
    info "Creating symlink for Zsh config directory..."
    ln -s "$repo_zsh_dir" "$config_zsh_dir"
    success "Symlinked $repo_zsh_dir to $config_zsh_dir"

    info "Creating symlink for .zshrc file..."
    ln -s "$config_zsh_dir/.zshrc" "$user_zshrc"
    success "Symlinked $config_zsh_dir/.zshrc to $user_zshrc"

    success "Zsh configuration installed using symbolic links."
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
        info "🔧 Custom Installation Starting..."
        echo ""
        read -p "$(info "Install Kitty configuration? [y/N] ")" -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_kitty
        fi

        echo ""
        read -p "$(info "Install Tmux configuration? [y/N] ")" -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_tmux
        fi

        echo ""
        read -p "$(info "Install Zsh configuration? [y/N] ")" -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_zsh
        fi
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
echo "  • Full guide: ~/.config/kitty/docs/TMUX-PL-GUIDE.md"
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
