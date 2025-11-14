#!/usr/bin/env bash

# Library for installer logic

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

run_pre_flight_checks() {
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
}

backup_file() {
    local file="$1"
    if [[ -e "$file" ]]; then
        local backup="${file}.backup.$(date +%Y%m%d-%H%M%S)"
        cp -r "$file" "$backup"
        warning "Backed up: $file → $backup"
    fi
}

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
