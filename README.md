# Personal Dotfiles

**Enterprise-grade terminal configuration with AI collaboration system**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## 🎯 What Is This?

Production-ready terminal configuration featuring:
- **AI Agents Collaboration System** - 5 collaboration modes with 39 helper scripts
- **Kitty Terminal** - Modular configuration with custom keybindings
- **Tmux Enhancement** - 16 plugins for session management and productivity
- **Comprehensive Documentation** - 3,000+ lines of guides and references

**Total**: 22,000+ lines of code and documentation, battle-tested in real workflows.

---

## ✨ Features

### 🤖 AI Agents Collaboration System

**5 Collaboration Modes**:
- **Pair Programming** - Driver/Navigator workflow with color-coded panes
- **Debate** - Structured 4-round thesis-antithesis-synthesis discussion
- **Teaching** - Expert/Learner with exercises and progress tracking
- **Consensus** - Multi-agent agreement building with voting
- **Competition** - Independent solutions with scoring (100 points)

**Tools**:
- 39 helper scripts for modes, sessions, knowledge base management
- Interactive TUI (Management dashboard with 9 menu options)
- 4 fzf tools (session browser, KB search, pane switcher, mode launcher)
- Session snapshots and restoration
- Knowledge base with lessons learned

**Keybindings**:
- `Ctrl+Alt+M` - AI Agents Management TUI
- `Ctrl+Alt+F` - fzf Session Browser
- `Ctrl+Alt+K` - fzf Knowledge Base Search
- `Ctrl+Alt+P` - fzf Tmux Pane Switcher
- `Ctrl+Alt+L` - fzf Mode Quick Launcher

### 🖥️ Kitty Terminal

**Features**:
- Modular configuration (8 files, 85 lines master file)
- True Neon theme (Electric Cyan + Hot Pink)
- A+ security (8/8 official features, clipboard RCE protection)
- AZERTY-friendly keybindings
- Interactive shortcuts palette (F12)
- System monitoring integration

**Highlights**:
- Split windows: `Ctrl+Alt+H` (horizontal), `Ctrl+Alt+V` (vertical)
- Navigation: `Ctrl+Shift+Arrows` between windows
- Reload config: `Ctrl+Shift+F5`
- Shortcuts menu: `F12` with search, copy, help

### 🪟 Tmux Configuration

**16 Plugins** (8 core + 8 enhanced):

**Core**:
- tmux-resurrect (session save/restore)
- tmux-continuum (auto-save every 15 min)
- tmux-yank (clipboard integration)
- tmux-open (open files/URLs)
- tmux-copycat (enhanced search)
- tmux-prefix-highlight (visual indicators)
- tmux-sensible (baseline settings)

**Enhanced** (Added 2025-10-29):
- **tmux-sessionx** - Session manager with fzf (`prefix + O`)
- **tmux-jump** - Keyword pane navigation (`prefix + j`)
- **tmux-fzf** - General fzf menu (`prefix + F`)
- **extrakto** - Text extraction (`prefix + Tab`)
- **tmux-menus** - Visual TUI menu (`Ctrl + \`)
- **tmux-sessionist** - Session utilities (`prefix + g/C/X`)
- **tmux-logging** - Pane logging (`prefix + Shift+P`)
- **tmux-fingers** - Hint-based copy (`prefix + f`)

**Session Persistence**:
- Auto-saves every 15 minutes
- Survives system reboots
- Restores panes, layouts, running programs

### 📚 Documentation

**7 Major Guides** (3,000+ lines):
- AI Agents Tmux Guide
- Tmux Plugins Complete Guide (1,000+ lines)
- Tmux-fzf Integration Guide
- TPM Integration Guide
- TUI Guide
- Enhancement Roadmap
- Quick References

---

## 🚀 Quick Start

### Prerequisites

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y kitty tmux fzf git xclip zoxide

# Arch Linux
sudo pacman -S kitty tmux fzf git xclip zoxide

# macOS
brew install kitty tmux fzf git zoxide
```

### Installation

```bash
# Clone the repository
git clone https://github.com/BasicFist/dotfiles.git
cd dotfiles

# Run the installer
./install.sh

# Or manual installation:
cp -r kitty ~/.config/
cp tmux.conf ~/.tmux.conf
cp -r zsh ~/.config/ # Optional
```

### Post-Installation

**1. Install Tmux Plugins**:
```bash
# Start tmux
tmux

# Install all plugins
# Press: Ctrl+B then Shift+I

# Wait for installation (~1-2 minutes)
```

**2. Verify Installation**:
```bash
# Check AI Agents TUI
Ctrl+Alt+M → System Status

# Should show:
# ✅ 16/16 plugins installed
# ✅ 4/4 fzf tools available
```

**3. Test Key Features**:
```bash
# Session manager with fzf
Ctrl+B then O

# Pane jump by keyword
Ctrl+B then j

# AI Agents TUI
Ctrl+Alt+M
```

---

## 📖 Usage

### AI Agents Collaboration

**Launch Management TUI**:
```bash
Ctrl+Alt+M
```

**Menu Options**:
1. Dashboard (Quick Overview & Stats)
2. Start Collaboration Mode (5 modes available)
3. fzf Tools (Session/KB/Pane/Mode)
4. Session Management
5. Knowledge Base
6. Configuration Management
7. Launch Tmux Session
8. Setup TPM (Tmux Plugin Manager)
9. System Status (Detailed)
10. Help & Documentation

**Quick Mode Launch**:
```bash
# Via fzf
Ctrl+Alt+L
# Select mode, see full documentation, press Enter

# Via command line
~/.config/kitty/scripts/ai-mode-start.sh pair Agent1 Agent2
```

### Tmux Productivity

**Session Management**:
```bash
Ctrl+B then O    # Session manager with fzf preview
Ctrl+B then g    # Switch session by name
Ctrl+B then C    # Create new session
Ctrl+B then X    # Kill session without detaching
```

**Navigation**:
```bash
Ctrl+B then j    # Jump to pane by keyword
Ctrl+B then F    # General fzf menu
Ctrl+\           # Visual TUI menu
```

**Text Operations**:
```bash
Ctrl+B then Tab  # Extract paths/URLs with fzf
Ctrl+B then f    # Hint-based copy/paste
```

**Session Logging**:
```bash
Ctrl+B then Shift+P  # Toggle pane logging
# Logs saved to ~/tmux-logs/
```

### Kitty Terminal

**Window Management**:
```bash
Ctrl+Alt+H         # Split horizontal
Ctrl+Alt+V         # Split vertical
Ctrl+Shift+Arrows  # Navigate windows
Ctrl+Shift+W       # Close window
```

**Utilities**:
```bash
F12                # Shortcuts palette (search, copy, help)
Ctrl+Shift+F5      # Reload configuration
Ctrl+Alt+M         # AI Agents TUI
```

---

## 📁 Structure

```
dotfiles/
├── kitty/                           # Kitty terminal configuration
│   ├── kitty.conf                   # Master orchestration (85 lines)
│   ├── kitty.d/                     # Modular configs (8 files)
│   │   ├── core.conf
│   │   ├── security.conf            # A+ security (8/8 features)
│   │   ├── theme-neon.conf
│   │   ├── keybindings.conf
│   │   └── ...
│   ├── scripts/                     # 39+ helper scripts
│   │   ├── ai-mode-start.sh         # Mode launcher
│   │   ├── ai-agents-tui.sh         # Management TUI (700 lines)
│   │   ├── ai-*-fzf.sh              # 4 fzf tools
│   │   ├── setup-tmux-tpm.sh        # TPM installer
│   │   └── ...
│   ├── kittens/                     # Custom kittens
│   │   └── shortcuts_menu/          # Interactive shortcuts palette
│   ├── docs/                        # Documentation (3,000+ lines)
│   │   ├── TMUX-PLUGINS-COMPLETE-GUIDE.md
│   │   ├── AI-AGENTS-TMUX-GUIDE.md
│   │   ├── TMUX-FZF-INTEGRATION.md
│   │   └── ...
│   └── tmux.conf                    # Tmux configuration (391 lines)
├── zsh/                             # Zsh configuration (optional)
├── install.sh                       # Automated installer
└── README.md                        # This file
```

---

## 🎯 Highlights

### Production-Ready
- ✅ 22,000+ lines of code and documentation
- ✅ Comprehensive error handling
- ✅ Detailed troubleshooting guides
- ✅ Battle-tested in real workflows

### Well-Documented
- ✅ 3,000+ lines of documentation
- ✅ 7 major guides
- ✅ Quick reference cards
- ✅ Interactive help (F12, Ctrl+Alt+M)

### Modular Architecture
- ✅ Kitty: 8 modular config files
- ✅ Tmux: 16 plugins, 391 lines
- ✅ AI Agents: 39 scripts, 5 modes
- ✅ Easy to customize and extend

### AI-Optimized Workflows
- ✅ Collaboration modes for pair programming, debate, teaching
- ✅ Session logging and archiving
- ✅ Knowledge base management
- ✅ fzf integration everywhere

---

## 🔧 Customization

### Kitty Theme

Change theme in `kitty/kitty.conf`:
```conf
# Switch from Neon to Matrix
# include kitty.d/theme-neon.conf
include kitty.d/theme-matrix-ops.conf
```

### Tmux Plugins

Add plugins in `kitty/tmux.conf`:
```bash
# Add your plugin
set -g @plugin 'user/plugin-name'

# Install
# In tmux: Ctrl+B then Shift+I
```

### AI Collaboration Modes

Add custom mode in `kitty/scripts/modes/`:
```bash
# Create new mode
mkdir -p kitty/scripts/modes/custom-mode
# Add mode logic...
```

---

## 📊 Statistics

- **Total Lines**: 22,112 (code + docs)
- **Total Size**: ~6MB (1MB kitty + 5MB zsh plugins)
- **Files**: 108+ files
- **Scripts**: 39 helper scripts
- **Documentation**: 3,000+ lines across 7 guides
- **Tmux Plugins**: 16 configured
- **Collaboration Modes**: 5 complete workflows

---

## 🤝 Contributing

Contributions welcome! Areas of interest:
- Additional collaboration modes
- New fzf integrations
- Theme variations
- Plugin recommendations
- Documentation improvements

**Process**:
1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

---

## 📝 License

MIT License - see LICENSE file for details

---

## 🙏 Acknowledgments

**Built with**:
- [Kitty](https://sw.kovidgoyal.net/kitty/) - Fast, feature-rich terminal
- [Tmux](https://github.com/tmux/tmux) - Terminal multiplexer
- [TPM](https://github.com/tmux-plugins/tpm) - Tmux Plugin Manager
- [fzf](https://github.com/junegunn/fzf) - Fuzzy finder

**Plugins**:
- tmux-plugins organization (core plugins)
- omerxx/tmux-sessionx (session manager)
- laktak/extrakto (text extraction)
- And 12 other amazing tmux plugins

---

## 📞 Support

**Documentation**:
- Read guides in `kitty/docs/`
- Press `F12` in Kitty for shortcuts menu
- Press `Ctrl+Alt+M` for AI Agents TUI

**Issues**:
- [GitHub Issues](https://github.com/BasicFist/dotfiles/issues)

**Discussions**:
- [GitHub Discussions](https://github.com/BasicFist/dotfiles/discussions)

---

## 🎯 Quick Links

- **AI Agents Guide**: `kitty/docs/AI-AGENTS-TMUX-GUIDE.md`
- **Tmux Plugins Guide**: `kitty/docs/TMUX-PLUGINS-COMPLETE-GUIDE.md`
- **Quick Reference**: `kitty/QUICK-REFERENCE.md`
- **Installation Helper**: `kitty/scripts/install-tmux-plugins.sh`

---

**Last Updated**: 2025-10-29
**Version**: 2.0 (AI Agents + Tmux Enhancement)
**Maintained by**: BasicFist

🎉 **Enjoy your enterprise-grade terminal setup!** 🎉
