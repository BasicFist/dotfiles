# Kitty Terminal - Quick Reference Card

**AZERTY Keyboard** | **Kitty 2.1.1** | **Last Updated: 2025-10-29**

---

## 🔥 Most Important (Learn These First)

| Shortcut | Action |
|----------|--------|
| **F12** | Shortcuts Palette (search, copy, help) |
| **Ctrl+Shift+F5** | Reload Configuration |
| **Ctrl+Shift+C** | Copy to Clipboard |
| **Ctrl+Shift+V** | Paste from Clipboard |
| **Ctrl+Shift+F** | Search Scrollback |

---

## 🪟 Windows & Splits

| Shortcut | Action |
|----------|--------|
| **Ctrl+Shift+Enter** | New Window (same directory) |
| **Ctrl+Alt+H** | Horizontal Split *(AZERTY-friendly)* |
| **Ctrl+Alt+V** | Vertical Split *(AZERTY-friendly)* |
| **Ctrl+Shift+W** | Close Window |
| **Ctrl+Shift+Arrows** | Navigate Windows |

---

## 📑 Tabs

| Shortcut | Action |
|----------|--------|
| **Ctrl+Shift+T** | New Tab |
| **Ctrl+Shift+Q** | Close Tab |
| **Ctrl+Shift+]** | Next Tab |
| **Ctrl+Shift+[** | Previous Tab |
| **Ctrl+F1** - **Ctrl+F5** | Jump to Tab 1-5 *(AZERTY-compatible)* |

---

## 📜 Scrolling

| Shortcut | Action |
|----------|--------|
| **Ctrl+Shift+K** | Scroll Line Up |
| **Ctrl+Shift+J** | Scroll Line Down |
| **Ctrl+Shift+PageUp/Down** | Scroll Page |
| **Ctrl+Shift+Home/End** | Jump to Start/End |
| **Ctrl+Shift+H** | Open Scrollback in Pager |

---

## 🎨 Display

| Shortcut | Action |
|----------|--------|
| **Ctrl+Shift+Plus** | Increase Font Size (+2pt) |
| **Ctrl+Shift+Backspace** | Reset Font Size |
| **Ctrl+Alt+Period** | Increase Opacity (+2%) |
| **Ctrl+Alt+Comma** | Decrease Opacity (-2%) |
| **Ctrl+Alt+0** | Reset Opacity (98%) |
| **Ctrl+Shift+F11** | Toggle Fullscreen |

---

## 🚀 Special Features (New!)

| Shortcut | Action |
|----------|--------|
| **Ctrl+Alt+X** | Launch Shared Tmux Session |
| **Ctrl+Alt+A** | Toggle Agent Overlay Terminal |
| **Ctrl+Alt+Shift+A** | Focus Agent Terminal |
| **Ctrl+Shift+Alt+P** | Clipboard Manager Overlay |

---

## 📊 Monitoring

| Shortcut | Action |
|----------|--------|
| **Ctrl+Alt+M** | Start System Monitor (title bar) |
| **Ctrl+Alt+Shift+M** | Stop System Monitor |
| **Ctrl+Shift+G** | GPU Monitor (nvidia-smi loop) |
| **Ctrl+Shift+S** | Sensors Monitor (lm-sensors loop) |

---

## 🛠️ Utilities

| Shortcut | Action |
|----------|--------|
| **Ctrl+Shift+I** | Image Viewer (overlay) |
| **Ctrl+Shift+Space** | Command Palette (hints) |
| **Ctrl+Shift+U** | Unicode Input |
| **Ctrl+Shift+Escape** | Kitty Shell (debug) |
| **Ctrl+Alt+O** | Toggle Transparency Preset |
| **Ctrl+Alt+S** | Toggle Scratchpad Overlay |

---

## 📋 Advanced Copy/Paste

| Shortcut | Action |
|----------|--------|
| **Ctrl+Shift+C** | Copy to Clipboard (standard) |
| **Ctrl+Shift+V** | Paste from Clipboard (standard) |
| **Shift+Insert** | Paste from Selection (X11-style) |
| **Middle-Click** | Paste from Selection (mouse) |
| **Ctrl+Shift+P** | Paste Without Newlines |
| **Ctrl+Shift+Alt+C** | Copy and Clear/Send Interrupt |
| **Ctrl+Shift+Alt+V** | Force Clipboard Paste |

---

## 🎯 Shortcuts Palette Features (F12)

Once opened with **F12**:

- **Type to search** - Filter shortcuts by name or description
- **Press 'c'** - Copy selected shortcut to clipboard
- **Press '?'** - View extended help for shortcuts with documentation
- **Arrow Keys** - Navigate up/down
- **Page Up/Down** - Navigate by page
- **Enter/Esc** - Exit palette

---

## ⚠️ AZERTY-Specific Notes

### ❌ Don't Use (Broken on AZERTY)
- ~~Ctrl+1-5~~ (use **Ctrl+F1-F5** instead)
- ~~Ctrl+Shift+Minus~~ (use **Ctrl+Alt+H** instead)

### ✅ Use These Alternatives
- **Ctrl+F1-F5** for tab switching (not Ctrl+1-5)
- **Ctrl+Alt+H** for horizontal split (not Ctrl+Shift+Minus)
- **Ctrl+Alt+V** for vertical split (not Ctrl+Shift+Backslash)
- **F12** for shortcuts menu (universal)

---

## 🔧 Configuration Commands

| Command | Action |
|---------|--------|
| `kitty @ load-config` | Reload configuration |
| `kitty @ ls` | List all windows/tabs (JSON) |
| `kitty @ get-colors` | Show current colors |
| `kitty --debug-input` | Debug keyboard input |
| `kitten show-key` | Show terminal key events |

---

## 📁 File Locations

| Path | Description |
|------|-------------|
| `~/.config/kitty/kitty.conf` | Main configuration |
| `~/.config/kitty/kitty.d/` | Modular config files |
| `~/.config/kitty/kittens/` | Custom kittens |
| `~/.config/kitty/scripts/` | Automation scripts |
| `/home/miko/LAB/lab/dotfiles/kitty/` | Repository (source of truth) |

---

## 🚨 Emergency Commands

```bash
# Reset to default keybindings
kitty --config NONE

# Reload configuration after bad edit
kitty @ load-config

# Force quit if frozen
pkill -9 kitty

# Sync repository to live config
cd /home/miko/LAB/lab/dotfiles/kitty && make sync-push
```

---

## 📚 Documentation

- **Quick Reference**: This file
- **Full Analysis**: `KEYBINDINGS-ANALYSIS.md`
- **Official Guidelines**: `docs/OFFICIAL-KITTY-GUIDELINES.md`
- **Documentation Index**: `docs/README.md`

---

## 🎓 Learn More

1. Press **F12** and explore the shortcuts palette
2. Read `docs/README.md` for full documentation index
3. Check `KEYBINDINGS-ANALYSIS.md` for current configuration details
4. Study `docs/OFFICIAL-KITTY-GUIDELINES.md` for advanced features

---

**Print This Reference** | **Keep It Handy** | **Press F12 for Interactive Help**
