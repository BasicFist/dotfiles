# ZSH NEON CORE v2.0 - Architecture Documentation

**Target Platform**: Ubuntu 24.04 (portable to other Linux distributions)
**Performance Goal**: <0.02s startup time
**Design Philosophy**: Modular, secure, high-performance shell environment

---

## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [File Structure](#file-structure)
3. [Load Order & Dependencies](#load-order--dependencies)
4. [Security Features](#security-features)
5. [Performance Optimizations](#performance-optimizations)
6. [Module Descriptions](#module-descriptions)
7. [Customization Guide](#customization-guide)
8. [Troubleshooting](#troubleshooting)

---

## Architecture Overview

### Design Principles
- **Modularity**: Separate concerns into distinct configuration files
- **Performance**: Lazy loading, caching, and bytecode compilation
- **Security**: Input validation, ownership checks, safe defaults
- **Portability**: Multi-distro support with graceful fallbacks
- **Extensibility**: Local override system without editing core files

### Component Hierarchy
```
~/.zshrc (Entry Point)
  ├── Core Options (shell behavior)
  ├── Module Loader (ordered sourcing)
  │   ├── environment.zsh (ENV, PATH, tools)
  │   ├── completion.zsh (completion system)
  │   ├── aliases.zsh (modern tool aliases)
  │   ├── functions.zsh (utility functions)
  │   ├── keybindings.zsh (Emacs-mode bindings)
  │   └── plugins.zsh (autosuggestions, syntax-highlighting)
  ├── Prompt (Starship or fallback)
  └── Local Overrides (.zshrc.local, .zshenv.local)
```

---

## File Structure

### Core Files
```
~/.zshrc                        # Main entry point (80 lines)
~/.zshrc.zwc                    # Compiled bytecode (auto-generated)
~/.zsh_history                  # Command history
~/.zcompdump                    # Completion cache
```

### Module Directory
```
~/.config/zsh/
├── environment.zsh             # ENV vars, PATH, tool configs (75 lines)
├── completion.zsh              # Completion system & caching (50 lines)
├── aliases.zsh                 # Modern tool aliases (81 lines)
├── functions.zsh               # Utility functions (215 lines)
├── keybindings.zsh             # Emacs keybindings (48 lines)
├── plugins.zsh                 # Plugins configuration (33 lines)
├── ARCHITECTURE.md             # This file
└── README.md                   # User-facing documentation
```

### Plugin Directory
```
~/.config/zsh/
├── zsh-autosuggestions/        # Command suggestions from history
└── zsh-syntax-highlighting/    # Real-time syntax highlighting
```

---

## Load Order & Dependencies

**Critical**: Order matters for proper initialization!

### 1. Core Shell Options (`.zshrc`)
```zsh
setopt NOCLOBBER IGNOREEOF NO_BEEP
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_REDUCE_BLANKS
setopt AUTO_CD EXTENDED_GLOB NO_CASE_GLOB
```

### 2. Environment Variables (`environment.zsh`)
- Locale settings (LANG, LC_ALL)
- History configuration
- PATH setup with uniqueness
- FZF configuration
- Tool initialization (zoxide, starship, delta)

### 3. Completion System (`completion.zsh`)
- Must load after environment setup
- Initializes with 24h caching
- Custom function completions
- FZF integration

### 4. Aliases (`aliases.zsh`)
- Modern tool replacements
- Git shortcuts
- Navigation helpers

### 5. Functions (`functions.zsh`)
- Utility functions (mkcd, extract, ff, etc.)
- Git utilities (gcl, glog, gst)
- System utilities (weather, fkill, bigfiles)

### 6. Keybindings (`keybindings.zsh`)
- Emacs-mode configuration
- FZF keybindings (Ctrl-T, Alt-C, Ctrl-R)

### 7. Plugins (`plugins.zsh`) - **MUST BE LAST**
- zsh-autosuggestions
- zsh-syntax-highlighting (especially must be last)

---

## Security Features

### Input Validation
- **weather()**: Regex validation for location input
- **gcl()**: URL protocol validation (https, git, ssh, git@)
- **extract()**: File existence and type validation

### Safe Defaults
- **NOCLOBBER**: Requires `>|` to overwrite files
- **IGNOREEOF**: Prevents accidental Ctrl-D exit
- **Ownership check**: `.zshenv.local` must be owned by user

### Safe Operations
- **Argument injection prevention**: `--` in mkcd, mkcp, mkmv
- **Proper quoting**: All variables quoted: `"$variable"`
- **Error redirection**: `2>/dev/null` for expected errors
- **Confirmation prompts**: fkill() requires user confirmation

### History Protection
- **HIST_FCNTL_LOCK**: File locking prevents multi-session corruption
- **Separate history file**: Isolated from other shells

---

## Performance Optimizations

### Startup Performance (<0.02s target)

#### 1. Bytecode Compilation
```bash
# Compile all zsh files for faster loading
zcompile ~/.zshrc
zcompile ~/.config/zsh/*.zsh
```

#### 2. Completion Caching
- **24-hour cache cycle**: Rebuilds `.zcompdump` daily
- **Cache reuse**: Uses cached data for <24h files
- **Completion cache directory**: `~/.zsh/cache/`

#### 3. Lazy Loading
- **Conditional initialization**: Tools only loaded if installed
- **Command availability checks**: `command -v tool`
- **Deferred plugin loading**: Plugins loaded last

#### 4. Debug Mode
```bash
# Enable startup profiling
DEBUG_STARTUP=1 zsh
# Output: /tmp/zsh_debug_<timestamp>
```

### Runtime Performance

#### Tool Integration
- **Modern alternatives**: bat > cat, eza > ls, rg > grep
- **FZF with fd**: Fast file/directory searching
- **zoxide**: Smart directory jumping with frecency

#### History Management
- **100,000 entries**: Large history for better suggestions
- **Incremental append**: History saved immediately
- **Duplicate reduction**: Automatic deduplication

---

## Module Descriptions

### environment.zsh - Environment Setup
**Purpose**: Initialize environment variables and external tools

**Key Features**:
- Locale configuration (UTF-8)
- PATH management with uniqueness
- FZF theming (Neon color scheme)
- Clipboard integration (Wayland + X11)
- Tool initialization (zoxide, starship, delta)
- Editor defaults (nvim)

**Dependencies**: None (first to load)

### completion.zsh - Completion System
**Purpose**: Configure intelligent command completion

**Key Features**:
- Menu-driven completion with colors
- Case-insensitive matching
- 24-hour completion cache
- Custom function completions
- FZF integration for fuzzy completion

**Dependencies**: environment.zsh (for FZF paths)

### aliases.zsh - Command Shortcuts
**Purpose**: Modern tool aliases and shortcuts

**Key Features**:
- Modern replacements: bat, eza, rg, dust
- Git workflow shortcuts (g, ga, gc, gp, etc.)
- Navigation helpers (.., ..., ....
- Zsh config management (zsh-reload, zsh-edit-*)
- Utility wrappers (mkdir -p, sudo with alias expansion)

**Dependencies**: None (tools checked with command -v)

### functions.zsh - Utility Functions
**Purpose**: Productivity-enhancing shell functions

**Categories**:
1. **Directory Management**: mkcd, mkcp, mkmv, cdf
2. **File Operations**: extract, ff, fh
3. **Process Management**: fkill, psgrep
4. **Git Utilities**: gcl, glog, gst
5. **System Utilities**: weather, dusort, bigfiles

**Dependencies**: fd, fzf, bat for full functionality

### keybindings.zsh - Keyboard Shortcuts
**Purpose**: Emacs-style line editing

**Key Bindings**:
- Navigation: Ctrl-A (start), Ctrl-E (end), Ctrl-B/F (char), Alt-B/F (word)
- Editing: Ctrl-K (kill line), Ctrl-U (kill whole), Ctrl-W (backward kill)
- History: Ctrl-R (search backward), Ctrl-S (search forward)
- FZF: Ctrl-T (files), Alt-C (directories), Ctrl-R (history)

**Dependencies**: FZF for enhanced bindings

### plugins.zsh - Plugin Configuration
**Purpose**: Load and configure zsh plugins

**Plugins**:
1. **zsh-autosuggestions**: Suggest commands from history
   - Strategy: history + completion
   - Buffer limit: 20 characters
   - Styling: Subtle gray suggestions

2. **zsh-syntax-highlighting**: Real-time syntax coloring
   - Command highlighting (blue)
   - Alias/builtin (cyan)
   - Functions (purple)
   - Errors (red)

**Critical**: Must load last, especially syntax-highlighting!

---

## Customization Guide

### Local Overrides (Recommended Method)

**Never edit core files directly!** Use local overrides:

#### User-Specific Customizations
```bash
# Create ~/.zshrc.local for custom settings
nvim ~/.zshrc.local

# Examples:
export MY_CUSTOM_VAR="value"
alias my-alias='my command'
function my-function() { ... }
```

#### Environment-Specific Settings
```bash
# Create ~/.zshenv.local for environment variables
nvim ~/.zshenv.local

# Examples:
export API_KEY="your-key"
export CUSTOM_PATH="/custom/path"
```

### Adding New Modules
```bash
# Create new module
nvim ~/.config/zsh/my-module.zsh

# Add to ~/.zshrc after line 35:
[[ -f "$ZCONFIG_DIR/my-module.zsh" ]] && source "$ZCONFIG_DIR/my-module.zsh"
```

### Disabling Features
```bash
# Comment out in ~/.zshrc:
# [[ -f "$ZCONFIG_DIR/plugins.zsh" ]] && source "$ZCONFIG_DIR/plugins.zsh"
```

---

## Troubleshooting

### Slow Startup
```bash
# Enable profiling
DEBUG_STARTUP=1 zsh

# Check loaded modules
zsh -x -c exit 2>&1 | less

# Rebuild completions
rm ~/.zcompdump && compinit

# Recompile bytecode
zcompile ~/.zshrc
for f in ~/.config/zsh/*.zsh; do zcompile $f; done
```

### Completion Not Working
```bash
# Clear completion cache
rm -rf ~/.zsh/cache/* ~/.zcompdump

# Reload configuration
zsh-reload

# Check completion system
autoload -Uz compinit && compinit -d ~/.zcompdump
```

### Plugin Issues
```bash
# Update plugins
cd ~/.config/zsh/zsh-autosuggestions && git pull
cd ~/.config/zsh/zsh-syntax-highlighting && git pull

# Reinstall plugins
rm -rf ~/.config/zsh/zsh-{autosuggestions,syntax-highlighting}
# Follow installation instructions
```

### FZF Not Working
```bash
# Check FZF installation
command -v fzf || sudo apt install fzf

# Check keybindings loaded
typeset -f __fzf_select__ >/dev/null || echo "FZF bindings not loaded"

# Manual source (debug)
source /usr/share/doc/fzf/examples/key-bindings.zsh
```

### Syntax Errors
```bash
# Validate all files
zsh -n ~/.zshrc
for f in ~/.config/zsh/*.zsh; do
  zsh -n "$f" && echo "✓ $f" || echo "✗ $f"
done
```

---

## Maintenance

### Regular Tasks

#### Weekly
```bash
# Update plugins
cd ~/.config/zsh/zsh-autosuggestions && git pull
cd ~/.config/zsh/zsh-syntax-highlighting && git pull
```

#### Monthly
```bash
# Clean old backups
find ~ -name ".zshrc.backup.*" -mtime +30 -delete

# Clear completion cache
rm -rf ~/.zsh/cache/*

# Recompile bytecode
zcompile ~/.zshrc
for f in ~/.config/zsh/*.zsh; do zcompile $f; done
```

### Backup Strategy
```bash
# Automatic timestamped backups
timestamp=$(date +%Y%m%d-%H%M%S)
cp ~/.zshrc ~/.zshrc.backup.$timestamp
cp -r ~/.config/zsh ~/.config/zsh.backup.$timestamp
```

---

## Version History

### v2.0 (2025-10-18)
- ✅ Added HIST_FCNTL_LOCK for multi-session safety
- ✅ Multi-distro FZF path support (Ubuntu, Fedora, macOS, manual install)
- ✅ URL validation in gcl() function
- ✅ Custom function completion definitions
- ✅ Architecture documentation
- ✅ Security audit and hardening

### v1.0 (Initial Release)
- Modular configuration architecture
- Modern tool integration
- FZF theming and integration
- Plugin system (autosuggestions, syntax-highlighting)
- Performance optimizations

---

## Support & Resources

### Getting Help
```bash
# List available functions
typeset -f | grep '^[a-z]'

# Show function definition
typeset -f function_name

# Check alias
alias alias_name

# View loaded modules
ls -lh ~/.config/zsh/*.zsh
```

### Useful Commands
```bash
zsh-reload          # Reload configuration
zsh-config          # Edit main config
zsh-modules         # List all modules
zsh-edit-aliases    # Edit aliases
zsh-edit-functions  # Edit functions
```

### External Resources
- [ZSH Documentation](https://zsh.sourceforge.io/Doc/)
- [FZF GitHub](https://github.com/junegunn/fzf)
- [Starship Prompt](https://starship.rs/)
- [Modern Unix Tools](https://github.com/ibraheemdev/modern-unix)

---

**Maintained by**: miko
**Last Updated**: 2025-10-18
**License**: MIT
