#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# AI Agents - TPM Installation & Configuration
# ═══════════════════════════════════════════════════════════
# Automated setup for Tmux Plugin Manager and AI Agents config

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ───────────────────────────────────────────────────────────
# Helper Functions
# ───────────────────────────────────────────────────────────

print_header() {
    echo ""
    echo -e "${PURPLE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${PURPLE}  $1${NC}"
    echo -e "${PURPLE}═══════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_step() {
    echo -e "${CYAN}▶${NC} $1"
}

print_success() {
    echo -e "${GREEN}✅${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️${NC}  $1"
}

print_error() {
    echo -e "${RED}❌${NC} $1"
}

# ───────────────────────────────────────────────────────────
# Preflight Checks
# ───────────────────────────────────────────────────────────

print_header "🚀 AI Agents - TPM Setup Script"

# Check if tmux is installed
if ! command -v tmux &>/dev/null; then
    print_error "tmux is not installed!"
    echo ""
    echo "Install tmux first:"
    echo "  Ubuntu/Debian: sudo apt install tmux"
    echo "  Fedora: sudo dnf install tmux"
    echo "  Arch: sudo pacman -S tmux"
    echo "  macOS: brew install tmux"
    echo ""
    exit 1
fi

# Check tmux version (need 1.9+)
tmux_version=$(tmux -V | grep -oP '\d+\.\d+' | head -1)
if awk "BEGIN {exit !($tmux_version >= 1.9)}"; then
    print_success "tmux version $tmux_version (>= 1.9 required)"
else
    print_error "tmux version $tmux_version is too old (need 1.9+)"
    exit 1
fi

# Check if git is installed
if ! command -v git &>/dev/null; then
    print_error "git is not installed!"
    echo ""
    echo "Install git first:"
    echo "  sudo apt install git"
    echo ""
    exit 1
fi

print_success "All prerequisites met!"

# ───────────────────────────────────────────────────────────
# Backup Existing Config
# ───────────────────────────────────────────────────────────

print_header "📦 Backup & Preparation"

# Backup existing tmux.conf if it exists
if [[ -f ~/.tmux.conf ]]; then
    backup_file=~/.tmux.conf.backup.$(date +%Y%m%d-%H%M%S)
    print_step "Backing up existing ~/.tmux.conf to $backup_file"
    cp ~/.tmux.conf "$backup_file"
    print_success "Backup created"
else
    print_step "No existing ~/.tmux.conf found"
fi

# ───────────────────────────────────────────────────────────
# Install TPM
# ───────────────────────────────────────────────────────────

print_header "🔌 Installing TPM (Tmux Plugin Manager)"

TPM_DIR=~/.tmux/plugins/tpm

if [[ -d "$TPM_DIR" ]]; then
    print_warning "TPM already installed at $TPM_DIR"
    read -r -p "Update TPM? [y/N] " response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        print_step "Updating TPM..."
        cd "$TPM_DIR"
        git pull
        print_success "TPM updated"
    else
        print_step "Skipping TPM update"
    fi
else
    print_step "Cloning TPM repository..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    print_success "TPM installed to $TPM_DIR"
fi

# ───────────────────────────────────────────────────────────
# Deploy Configuration
# ───────────────────────────────────────────────────────────

print_header "⚙️  Deploying AI Agents Tmux Configuration"

# Copy tmux.conf to home directory
if [[ -f "${DOTFILES_DIR}/tmux.conf" ]]; then
    print_step "Copying tmux.conf to ~/.tmux.conf"
    cp "${DOTFILES_DIR}/tmux.conf" ~/.tmux.conf
    print_success "Configuration deployed"
else
    print_error "Configuration file not found: ${DOTFILES_DIR}/tmux.conf"
    exit 1
fi

# Create layouts directory
print_step "Creating ~/.tmux/layouts directory"
mkdir -p ~/.tmux/layouts
print_success "Layouts directory created"

# ───────────────────────────────────────────────────────────
# Install Plugins
# ───────────────────────────────────────────────────────────

print_header "📥 Installing Tmux Plugins"

echo ""
echo -e "${YELLOW}The following plugins will be installed:${NC}"
echo "  • tmux-sensible - Sensible defaults"
echo "  • tmux-resurrect - Session persistence"
echo "  • tmux-continuum - Auto-save/restore"
echo "  • tmux-yank - Clipboard integration"
echo "  • tmux-open - Open files/URLs"
echo "  • tmux-copycat - Enhanced search"
echo "  • tmux-prefix-highlight - Prefix indicator"
echo ""

# Check if tmux is running
if tmux info &>/dev/null; then
    print_step "Installing plugins in existing tmux session..."

    # Reload tmux config
    tmux source-file ~/.tmux.conf

    # Install plugins
    ~/.tmux/plugins/tpm/bin/install_plugins

    print_success "Plugins installed!"
else
    print_step "Installing plugins (tmux not running)..."

    # Start tmux in background, install plugins, then kill
    tmux new-session -d -s tpm-install
    tmux send-keys -t tpm-install "~/.tmux/plugins/tpm/bin/install_plugins" C-m
    sleep 3
    tmux kill-session -t tpm-install 2>/dev/null || true

    print_success "Plugins installed!"
fi

# ───────────────────────────────────────────────────────────
# Create Session Templates
# ───────────────────────────────────────────────────────────

print_header "📝 Creating AI Agents Session Templates"

# Pair Programming Layout
print_step "Creating pair-programming template..."
cat > ~/.tmux/layouts/pair-programming.conf <<'EOF'
# AI Agents - Pair Programming Layout
# Usage: tmux source-file ~/.tmux/layouts/pair-programming.conf

# Split into 3 panes: Driver (top), Navigator (middle), Shared (bottom)
split-window -v -p 66
split-window -v -p 50

# Select top pane (Driver)
select-pane -t 0
send-keys "echo '🚗 Driver Pane - Implementation Focus'" C-m

# Select middle pane (Navigator)
select-pane -t 1
send-keys "echo '🧭 Navigator Pane - Review & Guide'" C-m

# Select bottom pane (Shared)
select-pane -t 2
send-keys "echo '📊 Shared Output & Communication'" C-m

# Focus on driver pane
select-pane -t 0
EOF
print_success "Pair programming template created"

# Debate Layout
print_step "Creating debate template..."
cat > ~/.tmux/layouts/debate.conf <<'EOF'
# AI Agents - Debate Layout
# Usage: tmux source-file ~/.tmux/layouts/debate.conf

# Split into 2 vertical panes: Agent 1 (left), Agent 2 (right)
split-window -h -p 50

# Select left pane (Agent 1 - Thesis)
select-pane -t 0
send-keys "echo '📜 Agent 1 - Thesis Presenter'" C-m

# Select right pane (Agent 2 - Antithesis)
select-pane -t 1
send-keys "echo '🔄 Agent 2 - Antithesis Presenter'" C-m

# Focus on left pane
select-pane -t 0
EOF
print_success "Debate template created"

# Teaching Layout
print_step "Creating teaching template..."
cat > ~/.tmux/layouts/teaching.conf <<'EOF'
# AI Agents - Teaching Layout
# Usage: tmux source-file ~/.tmux/layouts/teaching.conf

# Split into 2 panes: Expert (large top), Learner (smaller bottom)
split-window -v -p 30

# Select top pane (Expert)
select-pane -t 0
send-keys "echo '👨‍🏫 Expert - Teaching & Explaining'" C-m

# Select bottom pane (Learner)
select-pane -t 1
send-keys "echo '🎓 Learner - Asking Questions'" C-m

# Focus on expert pane
select-pane -t 0
EOF
print_success "Teaching template created"

# ───────────────────────────────────────────────────────────
# Final Instructions
# ───────────────────────────────────────────────────────────

print_header "✨ Setup Complete!"

echo ""
echo -e "${GREEN}TPM and AI Agents tmux configuration successfully installed!${NC}"
echo ""
echo -e "${CYAN}📖 Quick Start:${NC}"
echo ""
echo "1. Start a new tmux session:"
echo "   ${YELLOW}tmux new -s ai-agents${NC}"
echo ""
echo "2. Install/update plugins (inside tmux):"
echo "   ${YELLOW}prefix + I${NC} (capital I)"
echo ""
echo "3. Load a collaboration layout:"
echo "   ${YELLOW}tmux source-file ~/.tmux/layouts/pair-programming.conf${NC}"
echo ""
echo -e "${CYAN}⌨️  Key Bindings:${NC}"
echo "   prefix + |      - Split vertically"
echo "   prefix + -      - Split horizontally"
echo "   Alt + arrows    - Navigate panes (no prefix)"
echo "   Shift + arrows  - Switch windows (no prefix)"
echo "   prefix + S      - Sync panes (broadcast mode)"
echo "   prefix + r      - Reload config"
echo ""
echo -e "${CYAN}🔌 Plugin Management:${NC}"
echo "   prefix + I      - Install plugins"
echo "   prefix + U      - Update plugins"
echo "   prefix + Alt+u  - Uninstall unused plugins"
echo ""
echo -e "${CYAN}💾 Session Persistence:${NC}"
echo "   prefix + Ctrl+s - Save session manually"
echo "   prefix + Ctrl+r - Restore session manually"
echo "   Auto-save: Every 15 minutes (tmux-continuum)"
echo "   Auto-restore: On tmux start"
echo ""
echo -e "${CYAN}📚 Documentation:${NC}"
echo "   Config: ~/.tmux.conf"
echo "   Layouts: ~/.tmux/layouts/"
echo "   Plugins: ~/.tmux/plugins/"
echo ""
echo -e "${PURPLE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${PURPLE}  Happy collaborating! 🤖${NC}"
echo -e "${PURPLE}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Offer to start tmux
read -r -p "Start a new tmux session now? [y/N] " response
if [[ "$response" =~ ^[Yy]$ ]]; then
    exec tmux new-session -s ai-agents
fi
