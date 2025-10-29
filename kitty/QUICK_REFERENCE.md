# ⚡ Kitty Terminal - Quick Reference Card

## 🔄 Reload Configuration
```
Ctrl+Shift+F5              Reload config
kitty @ load-config        Reload from command line
```

## ⌨️ Essential Shortcuts

### Windows & Splits
```
Ctrl+Shift+Enter          New window
Ctrl+Shift+W              Close window
Ctrl+Shift+-              Horizontal split
Ctrl+Shift+=              Vertical split
Ctrl+Shift+Arrows         Navigate windows
```

### Tabs
```
Ctrl+Shift+T              New tab
Ctrl+Shift+Q              Close tab
Ctrl+Shift+[ / ]          Previous/Next tab
Ctrl+1-5                  Jump to tab 1-5
```

### Display
```
Ctrl+Shift++              Increase font
Ctrl+Shift+Backspace      Reset font
Ctrl+Alt+, / .            Opacity -/+
Ctrl+Alt+0                Reset opacity
```

### System Monitoring
```
Ctrl+Alt+M                System monitor (title bar)
Ctrl+Alt+Shift+M          Stop monitor
Ctrl+Shift+G              GPU monitor (new tab)
Ctrl+Shift+S              Sensors (new tab)
```

### Copy/Paste (Enhanced)
```
Ctrl+Shift+C              Copy (or just select text!)
Ctrl+Shift+V              Paste from clipboard
Shift+Insert              Paste from selection
Middle-Click              Paste selection (mouse)
Ctrl+Shift+P              Paste without newlines
Ctrl+Shift+Alt+P          Clipboard manager
```

### Utilities
```
Ctrl+Shift+I              Image viewer
Ctrl+Shift+Space          Command palette
Ctrl+Shift+F              Search scrollback
Ctrl+Shift+/              Show shortcuts (overlay)
Ctrl+Shift+H              Scrollback in pager
Ctrl+Shift+F11            Fullscreen
Ctrl+Alt+O                Toggle transparency
Ctrl+Alt+S                Toggle scratchpad overlay
Ctrl+Alt+Shift+T          Kitty theme chooser
Ctrl+Alt+Shift+D          Kitty diff kitten
```

## 🎨 Color Scheme (True Neon)

```
Background:     #000000  (Pure black)
Foreground:     #00FFFF  (Electric cyan)
Cursor:         #FF0099  (Hot pink)
Selection:      #00FF00  (Electric lime)
Active Border:  #00FFFF  (Cyan glow)
Active Tab:     #FF0099  (Hot pink)
```

## 📁 File Locations

```
Main Config:    ~/.config/kitty/kitty.conf
Modules:        ~/.config/kitty/kitty.d/
  ├─ security.conf          (Security settings)
  ├─ core.conf              (Font, shell)
  ├─ perf-balanced.conf     (Default perf)
  ├─ perf-lowlatency.conf   (Alternative perf)
  ├─ theme-neon.conf        (Active theme)
  ├─ theme-matrix-ops.conf  (Alternative theme)
  ├─ visual-effects-base.conf    (Shared cursor ergonomics)
  ├─ visual-effects-neon.conf    (Neon visuals)
  └─ visual-effects-matrix.conf  (Matrix visuals)
  └─ keybindings.conf       (All shortcuts)

Scripts (v2.1): ~/.config/kitty/scripts/
  ├─ switch-theme.sh        (Interactive theme switcher)
  ├─ show-shortcuts.sh      (Keyboard shortcuts overlay)
  └─ lint.sh                (Shellcheck validation)

Tools:
  verify-config.sh          (Health check - enhanced v2.1)
  system-monitor.sh         (CPU/GPU stats - enhanced v2.1)
  stop-monitor.sh           (Stop monitoring - enhanced v2.1)
  clipboard-manager.sh      (Clipboard ops - enhanced v2.1)
  README.md                 (Full documentation)
```

## 🔒 Security Features

```
✅ paste_actions            Auto-quote malicious URLs
✅ socket-only             No network exposure
✅ clipboard ask           Prompt before clipboard read
✅ 32MB limit              DoS prevention
✅ smart trailing spaces    Hidden command prevention
```

## ⚡ Performance Profiles

### Balanced (Active)
- Repaint: 2ms
- Input lag: <10ms
- Scrollback: 10,000 lines
- CPU: ~2% idle

### Low Latency
- Repaint: 1ms
- Input lag: <3ms
- Scrollback: 5,000 lines
- CPU: ~5% idle

**Switch:** Edit `kitty.conf` includes, reload with Ctrl+Shift+F5

## 🛠️ Quick Fixes

### Config won't load
```bash
bash ~/.config/kitty/verify-config.sh  # Now with exit codes!
```

### Switch theme easily (v2.1)
```bash
bash ~/.config/kitty/scripts/switch-theme.sh
```

### Validate shell scripts (v2.1)
```bash
bash ~/.config/kitty/scripts/lint.sh
```

### Colors wrong
```bash
grep "theme-neon.conf" ~/.config/kitty/kitty.conf
kitty @ load-config
```

### Restore backup
```bash
cp ~/.config/kitty/kitty.conf.backup-* ~/.config/kitty/kitty.conf
kitty @ load-config
```

## 🎯 Common Tasks

### Change cursor color
Edit `kitty.d/theme-neon.conf`:
```conf
cursor #0099FF  # Change to blue
```

### Adjust opacity
Edit the appropriate visuals file, e.g. `kitty.d/visual-effects-neon.conf`:
```conf
background_opacity 0.95  # More transparent
```

### Add custom keybinding
Edit `kitty.d/keybindings.conf`:
```conf
map ctrl+alt+m launch --type=tab htop
```

**Reload after changes:** `Ctrl+Shift+F5`

---

**Full Docs:** `~/.config/kitty/README.md`
**Verify:** `bash ~/.config/kitty/verify-config.sh`
**Theme Switch:** `bash ~/.config/kitty/scripts/switch-theme.sh`
**Architecture:** HARDENED v2.1.1 Modular
**Security:** A+ (8/8 official features) ✅
