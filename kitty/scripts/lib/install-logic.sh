#!/usr/bin/env bash

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
