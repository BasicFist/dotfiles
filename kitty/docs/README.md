# Kitty Configuration Documentation

**LAB Repository** - Comprehensive Kitty Terminal Documentation
**Last Updated**: 2025-10-29

---

## 📚 Documentation Index

### Configuration Analysis
- **[KEYBINDINGS-ANALYSIS.md](../KEYBINDINGS-ANALYSIS.md)** - Complete analysis of current keybindings with AZERTY compatibility assessment, issues, and recommendations

### Official Guidelines
- **[OFFICIAL-KITTY-GUIDELINES.md](./OFFICIAL-KITTY-GUIDELINES.md)** - Comprehensive reference compiled from official Kitty documentation covering:
  - Keyboard mapping syntax and patterns
  - Complete mappable actions reference
  - Remote control API and security
  - Custom kitten development
  - Best practices and common patterns

---

## 🎯 Quick Start

### For Daily Use
1. **Press F12** - Open shortcuts palette with search, clipboard copy, and help features
2. **Check keybindings** - Read `KEYBINDINGS-ANALYSIS.md` for current configuration status
3. **Test new features**:
   - **Ctrl+Alt+X** - Shared tmux session launcher
   - **Ctrl+Alt+A** - Agent terminal overlay

### For Configuration
1. **Read official guidelines** - Start with `OFFICIAL-KITTY-GUIDELINES.md`
2. **Understand current setup** - Review `KEYBINDINGS-ANALYSIS.md`
3. **Make changes** - Edit files in `/home/miko/LAB/lab/dotfiles/kitty/`
4. **Sync to live** - Run `make sync-push` from kitty directory
5. **Reload config** - Press `Ctrl+Shift+F5` or run `kitty @ load-config`

### For Development
1. **Study patterns** - See "Common Patterns" in `OFFICIAL-KITTY-GUIDELINES.md`
2. **Learn kitten development** - Follow "Custom Kitten Development" section
3. **Understand remote control** - Read "Remote Control" section for automation

---

## 📋 Document Summaries

### KEYBINDINGS-ANALYSIS.md

**Purpose**: Current configuration analysis with AZERTY-specific issues

**Key Sections**:
- Executive Summary - Quick overview of all issues
- Category-by-Category Analysis - Detailed breakdown of all 55 keybindings
- AZERTY-Specific Issues - Problems with number keys, symbols, and special characters
- Recommendations - HIGH/MEDIUM/LOW priority fixes
- Testing Checklist - What to test after fixes
- Script Dependency Map - Verification of all referenced files

**Use When**:
- Troubleshooting non-working keybindings
- Understanding AZERTY compatibility issues
- Planning configuration improvements
- Verifying script dependencies

### OFFICIAL-KITTY-GUIDELINES.md

**Purpose**: Authoritative reference from official Kitty documentation

**Key Sections**:
1. **Keyboard Mapping** - Complete syntax reference with examples
2. **Mappable Actions Reference** - All available actions organized by category
3. **Remote Control** - Security, setup, commands, and best practices
4. **Custom Kitten Development** - Complete development guide with examples
5. **Best Practices** - Recommended patterns for configuration
6. **Common Patterns** - 8 real-world examples with code

**Use When**:
- Learning new Kitty features
- Writing custom kittens
- Setting up remote control
- Understanding advanced mapping techniques
- Finding official action names and syntax

---

## 🔧 Configuration Structure

```
/home/miko/LAB/lab/dotfiles/kitty/
├── kitty.conf                 # Main configuration (includes modules)
├── kitty.d/                   # Modular configuration
│   ├── core.conf             # Core settings
│   ├── keybindings.conf      # All keyboard shortcuts
│   ├── theme-neon.conf       # Color scheme
│   ├── visual-effects-*.conf # Visual effects
│   └── ...
├── kittens/                   # Custom kittens
│   └── shortcuts_menu/
│       └── main.py           # Interactive shortcuts palette
├── scripts/                   # Automation scripts
│   ├── lib/
│   │   └── common.sh         # Shared functions
│   ├── agent-terminal.sh     # Agent overlay management
│   ├── launch-shared-tmux.sh # Tmux session launcher
│   └── ...
├── docs/                      # Documentation (this directory)
│   ├── README.md             # This file
│   ├── OFFICIAL-KITTY-GUIDELINES.md
│   └── ...
├── KEYBINDINGS-ANALYSIS.md   # Current config analysis
├── Makefile                  # Build and sync commands
└── verify-config.sh          # Configuration validator
```

---

## 🚀 Common Tasks

### Reload Configuration
```bash
# Method 1: Keyboard shortcut
Ctrl+Shift+F5

# Method 2: Remote control
kitty @ load-config

# Method 3: Edit and reload
Ctrl+Shift+F2  # Opens kitty.conf in editor
# Save file, then:
Ctrl+Shift+F5  # Reload
```

### Sync Repository to Live Config
```bash
cd /home/miko/LAB/lab/dotfiles/kitty
make sync-push
kitty @ load-config
```

### Test Keybindings
```bash
# See what key system sends
kitty --debug-input

# See what terminal receives
kitten show-key

# List all current windows/tabs
kitty @ ls

# Check if remote control is working
kitty @ get-colors
```

### Develop Custom Kitten
```bash
# 1. Create kitten file
nano ~/.config/kitty/kittens/my_kitten.py

# 2. Add to keybindings.conf
echo "map f1 kitten ~/.config/kitty/kittens/my_kitten.py" >> kitty.d/keybindings.conf

# 3. Reload config
kitty @ load-config

# 4. Test kitten
# Press F1 or run directly:
kitty +kitten ~/.config/kitty/kittens/my_kitten.py
```

### Debug Issues
```bash
# Check configuration syntax
kitty --debug-config

# View effective configuration
kitty @ debug-config

# Check environment variables
kitty @ show-kitty-env-vars

# View all keybindings
grep '^map ' ~/.config/kitty/kitty.d/keybindings.conf
```

---

## 🐛 Known Issues & Fixes

### Issue: Keybinding Not Working on AZERTY

**Problem**: Many keybindings use symbols or numbers in different positions on AZERTY

**Solution**: See `KEYBINDINGS-ANALYSIS.md` Section "AZERTY-Specific Issues"

**Quick Fixes**:
- Use `Ctrl+F1-F5` instead of `Ctrl+1-5` for tab switching
- Use `Ctrl+Alt+H/V` instead of `Ctrl+Shift+Minus/Backslash` for splits
- Use `F12` for shortcuts menu (universal)

### Issue: Remote Control "Permission Denied"

**Problem**: Remote control commands fail with permission errors

**Solution**: Check `remote_control_password` configuration in `kitty.conf`

```conf
# Enable password-based remote control
remote_control_password "mypass" *
```

See `OFFICIAL-KITTY-GUIDELINES.md` Section "Remote Control > Setup & Security"

### Issue: Custom Kitten Not Found

**Problem**: `map f1 kitten my_kitten.py` gives "No such file or directory"

**Solutions**:
1. **Use full path**: `map f1 kitten ~/.config/kitty/kittens/my_kitten.py`
2. **Make executable**: `chmod +x ~/.config/kitty/kittens/my_kitten.py`
3. **Check syntax**: Don't use `launch` with `kitten` command

See `OFFICIAL-KITTY-GUIDELINES.md` Section "Custom Kitten Development"

---

## 📖 Learning Path

### Beginner
1. Read "Quick Start" section above
2. Skim `KEYBINDINGS-ANALYSIS.md` to understand current setup
3. Learn basic keybindings (press F12 for shortcuts palette)
4. Practice using existing features

### Intermediate
1. Read `OFFICIAL-KITTY-GUIDELINES.md` Section "Keyboard Mapping"
2. Customize keybindings in `kitty.d/keybindings.conf`
3. Learn remote control basics
4. Create simple no-UI kittens

### Advanced
1. Study "Common Patterns" in `OFFICIAL-KITTY-GUIDELINES.md`
2. Develop custom kittens with UI
3. Set up remote control automation
4. Create modal keyboard modes
5. Write custom authorization scripts

---

## 🔗 External Resources

### Official Kitty
- **Main Site**: https://sw.kovidgoyal.net/kitty/
- **GitHub**: https://github.com/kovidgoyal/kitty
- **Issue Tracker**: https://github.com/kovidgoyal/kitty/issues

### Community
- **Discussions**: https://github.com/kovidgoyal/kitty/discussions
- **Awesome Kitty**: https://github.com/awesome-kitty (community resources)

### Related
- **Tmux Documentation**: https://github.com/tmux/tmux/wiki
- **Python curses**: https://docs.python.org/3/howto/curses.html (for kitten development)

---

## 📝 Contributing to This Documentation

### Adding New Documentation

1. Create markdown file in `docs/` directory
2. Add entry to this README.md index
3. Follow existing formatting style
4. Include examples and use cases

### Updating Existing Documentation

1. Make changes to relevant `.md` file
2. Update "Last Updated" date
3. Add entry to changelog if significant
4. Sync to live config if needed

### Documentation Standards

- Use clear headings and sections
- Include code examples for all features
- Provide both simple and advanced examples
- Link to official documentation sources
- Keep AZERTY compatibility notes where relevant

---

## 🎓 Changelog

### 2025-10-29
- Created comprehensive documentation system
- Added `KEYBINDINGS-ANALYSIS.md` with AZERTY compatibility analysis
- Added `OFFICIAL-KITTY-GUIDELINES.md` compiled from official sources
- Fixed shortcuts menu kitten (F12 now working)
- Fixed tmux launcher (Ctrl+Alt+X)
- Fixed agent terminal (Ctrl+Alt+A)
- Created shared utility library (`scripts/lib/common.sh`)

---

**Maintained By**: LAB Repository
**Last Updated**: 2025-10-29
