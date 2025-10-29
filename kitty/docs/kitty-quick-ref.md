# Kitty Terminal - Quick Reference Guide

## File Locations

```
~/.config/kitty/
├── kitty.conf              ← Master config (includes others, enables remote control)
├── glitch.conf             ← Theme, colors, 30+ keyboard shortcuts
├── aesthetics.conf         ← Your customization layer (safe to edit)
├── glitch-effects.sh       ← Visual effects script (pulse/flicker/scanline/chaos)
├── glitch-toggle           ← Interactive effects control UI
├── kitty.d/
│   └── theme-matrix-ops.conf  ← Alternative Matrix theme
└── wallpapers/             ← Background images
```

**Source:** `/home/miko/.local/share/dotfiles/kitty-neon/`

---

## What Each File Does

| File | Size | Purpose | Editable? |
|------|------|---------|-----------|
| `kitty.conf` | 866B | Orchestrates all configs, enables remote control | ⚠️ Rarely |
| `glitch.conf` | 5.4K | Theme colors, fonts, 30+ keyboard shortcuts, behavior | ⚠️ Don't edit directly |
| `aesthetics.conf` | 1.8K | User customization layer | ✅ **Edit here!** |
| `glitch-effects.sh` | 6.3K | Pulse/flicker/scanline/chaos effects engine | ⚠️ Advanced |
| `glitch-toggle` | 5.3K | Interactive effects control (start/stop/restart) | ⚠️ Advanced |
| `theme-matrix-ops.conf` | 35L | Alternative Matrix green theme | ⚠️ For switching |

---

## Visual Effects

### How to Trigger Effects

**From Keyboard (in Kitty):**
```
Ctrl+Alt+G      → Start PULSE effect (breathing opacity)
Ctrl+Alt+F      → Start FLICKER effect (color cycling)
Ctrl+Alt+P      → STOP all effects
```

**From Command Line:**
```bash
~/.config/kitty/glitch-toggle start pulse
~/.config/kitty/glitch-toggle start flicker
~/.config/kitty/glitch-toggle start scanline
~/.config/kitty/glitch-toggle start chaos
~/.config/kitty/glitch-toggle stop
~/.config/kitty/glitch-toggle status
```

### Available Effects

| Effect | Description | Feel |
|--------|-------------|------|
| **pulse** | Smooth breathing (85%-95% opacity) | Calm, meditative |
| **flicker** | Rapid color tint cycling | Intense, active |
| **scanline** | CRT scanline simulation | Retro, nostalgic |
| **chaos** | Random mix of all effects | Unpredictable, wild |

---

## Customization Examples

### Change Color Scheme
Edit `~/.config/kitty/aesthetics.conf`:
```conf
# Uncomment and change:
background #000000
foreground #FFFFFF
cursor #00FF00
```

### Add Custom Keybinding
Add to `~/.config/kitty/aesthetics.conf`:
```conf
map ctrl+alt+e launch --type=tab nvim
map ctrl+alt+d launch --type=tab ranger
```

### Change Font
Edit `~/.config/kitty/aesthetics.conf`:
```conf
font_family Fira Code
font_size 12.0
```

### Adjust Opacity
Edit `~/.config/kitty/aesthetics.conf`:
```conf
background_opacity 0.95
```

### Disable Visual Effects
Edit `~/.config/kitty/glitch.conf`, comment lines 148-151:
```conf
# map ctrl+alt+g launch --type=overlay /home/$USER/.config/kitty/glitch-effects.sh pulse
# map ctrl+alt+f launch --type=overlay /home/$USER/.config/kitty/glitch-effects.sh flicker
# map ctrl+alt+p ...
```

### Switch to Matrix Theme
Edit `~/.config/kitty/kitty.conf`:
```conf
# Comment this line:
# include glitch.conf

# Uncomment this line:
include kitty.d/theme-matrix-ops.conf

# Also uncomment:
include aesthetics.conf
```

---

## Common Tasks

### Reload Config
```bash
# In Kitty:
Ctrl+Shift+F5

# Or from terminal:
kitty @ load-config
```

### Check if Effects are Running
```bash
~/.config/kitty/glitch-toggle status
```

### Stop All Effects
```bash
~/.config/kitty/glitch-toggle stop
# Or: Ctrl+Alt+P in Kitty
```

### View Color Palette
Open `glitch.conf` and look at lines 15-52 (color definitions)

### Reset to Defaults
1. Delete your changes in `aesthetics.conf`
2. Press `Ctrl+Shift+F5` to reload

---

## Keyboard Shortcuts (Main Categories)

### Window/Tab Management
```
Ctrl+Shift+Enter   New window
Ctrl+Shift+W       Close window
Ctrl+Shift+T       New tab
Ctrl+Shift+Q       Close tab
Ctrl+1-5           Go to tab 1-5
```

### Font Size
```
Ctrl+Shift++       Increase ±2pt
Ctrl+Shift+-       Decrease ±2pt
Ctrl+Shift+BS      Reset to default
```

### Opacity
```
Ctrl+Alt+.         Increase ±2%
Ctrl+Alt+,         Decrease ±2%
Ctrl+Alt+0         Reset to 90%
```

### Visual Effects
```
Ctrl+Alt+T         Enable cursor trail
Ctrl+Alt+Shift+T   Disable cursor trail
Ctrl+Alt+G         Pulse effect
Ctrl+Alt+F         Flicker effect
Ctrl+Alt+P         Stop effects
```

### Monitoring (if tools installed)
```
Ctrl+Shift+G       GPU monitor (nvidia-smi)
Ctrl+Shift+S       Sensors monitor
Ctrl+Shift+I       Image viewer
```

---

## Theme Details

### Active Theme: Glitch Neon
- **Color Scheme:** Purple/Magenta/Cyan palette
- **Font:** JetBrains Mono 11pt
- **Background:** #05010A (deep purple) at 90% opacity
- **Foreground:** #F0F0FF (light lavender)
- **Cursor:** #FF00CC (magenta) with 220px trail

### Alternative Theme: Matrix Ops
- **Color Scheme:** Green palette (classic Matrix style)
- **Background:** #000000 (pure black) at 92% opacity
- **Foreground:** #cfeccb (soft green)
- **Cursor:** #00ff80 (bright green)

---

## Troubleshooting

### Effects Not Working
**Problem:** Effects don't start or error
**Solution:**
1. Check: `kitty @ ls` (should list windows)
2. Verify: `allow_remote_control yes` in `glitch.conf`
3. Reload: `Ctrl+Shift+F5`
4. Restart Kitty

### Config Won't Reload
**Problem:** Changes don't apply after pressing `Ctrl+Shift+F5`
**Solution:**
1. Check syntax in edited file
2. Restart Kitty completely
3. Check `~/.config/kitty/kitty.conf` for include errors

### Keybindings Not Working
**Problem:** Custom shortcuts don't work
**Solution:**
1. Add to `aesthetics.conf` (not `glitch.conf`)
2. Make sure format is: `map key action`
3. Reload config with `Ctrl+Shift+F5`

### Effects Stuck Running
**Problem:** Can't stop running effect
**Solution:**
```bash
pkill -f "glitch-effects.sh"
# Or: Ctrl+Alt+P keybinding
# Or: ~/.config/kitty/glitch-toggle stop
```

---

## File Modification Priority

**Safe to edit (won't break things):**
1. ✅ `aesthetics.conf` - User overrides layer
2. ✅ Custom additions to `aesthetics.conf`

**Advanced (know what you're doing):**
2. ⚠️ `glitch.conf` - Theme definition
3. ⚠️ `glitch-effects.sh` - Effects script

**Don't touch unless necessary:**
4. 🚫 `kitty.conf` - Master orchestration
5. 🚫 `glitch-toggle` - Control utility

---

## Remote Control Feature

The `allow_remote_control` setting in `kitty.conf` enables:
- Visual effects scripts to work
- Dynamic opacity changes
- Color changes at runtime
- External process control

**Security:** Set to `socket-only` (local access only) in `glitch.conf`

---

## Performance Tuning

Current settings in `glitch.conf`:
```conf
repaint_delay 3        # 3ms refresh (fast)
input_delay 0          # No keyboard lag
sync_to_monitor yes    # Tear-free
scrollback_lines 10000 # 10K line history
```

To adjust, edit `aesthetics.conf`:
```conf
# For high refresh displays:
repaint_delay 2
input_delay 0

# For Wayland stability:
resize_in_steps no
resize_draw_strategy size
```

---

## Status Summary

✅ **Theme:** Glitch Neon (active)
✅ **Effects:** All 4 modes working
✅ **Shortcuts:** 30+ custom bindings
✅ **Remote Control:** Enabled
✅ **Security:** Hardened
✅ **Performance:** Optimized

**Ready for:** Personal customization via `aesthetics.conf`

---

## Documentation Files

- **kitty-config-map.md** - Comprehensive detailed reference
- **kitty-visual-map.txt** - ASCII architecture diagrams
- **kitty-quick-ref.md** - This file (quick lookup)

---

**Last Updated:** 2025-10-19
**Platform:** Ubuntu 24.04 LTS (Wayland/X11)
**Kitty Version:** 0.37.0+ (cursor_trail feature)
