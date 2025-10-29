# Kitty Terminal Configuration Map

## Overview
Your Kitty terminal uses a **"Glitch Neon" theme** with advanced visual effects and highly customized keyboard shortcuts. The configuration is organized into modular files with a source in dotfiles and active configs in `~/.config/kitty/`.

---

## Directory Structure

```
~/.config/kitty/
├── kitty.conf                    # Main entry point (includes other configs)
├── glitch.conf                   # Primary theme: Glitch Neon palette & behavior
├── aesthetics.conf               # Override file (safe to edit, preserved on updates)
├── glitch-effects.sh             # Visual effects script (pulse, flicker, scanline, chaos)
├── glitch-toggle                 # Interactive effects control utility
├── kitty.d/
│   └── theme-matrix-ops.conf     # Alternative theme: Matrix-inspired (commented out by default)
└── wallpapers/                   # Background images (for potential future use)
```

---

## Configuration Files Detailed

### 1. **kitty.conf** (Main Entry Point)
**Path:** `~/.config/kitty/kitty.conf`
**Size:** 866 bytes
**Purpose:** Master configuration file that orchestrates all other configs

**Key Settings:**
- ✅ `allow_remote_control yes` - Enables Kitty remote control (required for effects scripts)
- 📝 Includes: `glitch.conf`, `aesthetics.conf`
- 💾 `scrollback_lines 10000` - Terminal history buffer

**Notable Configuration:**
```conf
allow_remote_control yes              # Required for all neon-* scripts
include glitch.conf                   # Load Glitch Neon theme
include aesthetics.conf               # Load user overrides
```

---

### 2. **glitch.conf** (Primary Theme)
**Path:** `~/.config/kitty/glitch.conf`
**Size:** 5.4K
**Purpose:** Defines complete Glitch Neon theme including colors, fonts, keyboard shortcuts, and visual behavior

**Theme Identity:**
- **Font:** JetBrains Mono (11pt)
- **Background:** Deep purple (#05010A) at 90% opacity
- **Foreground:** Light lavender (#F0F0FF)
- **Cursor:** Magenta (#FF00CC) with 220px trail
- **Accent Colors:** Cyan (#00FFF0), Green (#00FF88)

**Color Palette (16-color base):**
```
Primary:    #05010A (bg), #F0F0FF (fg), #FF00CC (cursor)
Accents:    #00FFCC (cyan), #400040 (purple), #FF0088 (red)
Full 16:    16 distinct colors for terminal applications
```

**Keyboard Shortcuts (Custom - All Mapped):**

| Shortcut | Action |
|----------|--------|
| **Window Management** |
| `Ctrl+Shift+Enter` | New window |
| `Ctrl+Shift+W` | Close window |
| `Ctrl+Shift+-` | Horizontal split |
| `Ctrl+Shift+=` | Vertical split |
| `Ctrl+Shift+↑/↓/←/→` | Navigate windows |
| **Tab Management** |
| `Ctrl+Shift+T` | New tab |
| `Ctrl+Shift+Q` | Close tab |
| `Ctrl+Shift+]` / `[` | Next/Previous tab |
| `Ctrl+1-5` | Go to tab 1-5 |
| **Scrolling** |
| `Ctrl+Shift+K` / `J` | Scroll line up/down |
| `Ctrl+Shift+PgUp/Dn` | Scroll page |
| `Ctrl+Shift+Home/End` | Scroll to top/bottom |
| **Font Size** |
| `Ctrl+Shift++` / `-` | Increase/decrease size ±2pt |
| `Ctrl+Shift+Backspace` | Reset to default (11pt) |
| **Opacity Control** |
| `Ctrl+Alt+.` / `,` | Increase/decrease opacity ±2% |
| `Ctrl+Alt+0` | Reset opacity to 90% |
| **Cursor Effects** |
| `Ctrl+Alt+T` | Enable cursor trail (220px) |
| `Ctrl+Alt+Shift+T` | Disable cursor trail |
| **Glitch Effects (External Scripts)** |
| `Ctrl+Alt+G` | Start PULSE effect |
| `Ctrl+Alt+F` | Start FLICKER effect |
| `Ctrl+Alt+P` | Stop all effects |
| **Monitoring & Tools** |
| `Ctrl+Shift+G` | GPU monitor (nvidia-smi) |
| `Ctrl+Shift+S` | Sensors monitor |
| `Ctrl+Shift+I` | Image viewer |
| `Ctrl+Shift+Space` | Command palette |
| **Copy/Paste** |
| `Ctrl+Shift+C` / `V` | Copy/Paste |
| **Misc** |
| `Ctrl+Shift+F11` | Toggle fullscreen |
| `Ctrl+Shift+U` | Unicode input |
| `Ctrl+Shift+Escape` | Kitty shell |

**Performance Tuning:**
```conf
repaint_delay 3           # Frame rate
sync_to_monitor yes       # Sync with display
scrollback_lines 10000    # History buffer
enable_audio_bell no      # Disable bell sound
```

**Security Settings:**
```conf
allow_remote_control socket-only           # Only local socket access
listen_on unix:/tmp/kitty-{kitty_pid}      # Socket path
clipboard_control write-clipboard write-primary read-clipboard-ask read-primary-ask
clipboard_max_size 32     # Limit clipboard size
```

---

### 3. **aesthetics.conf** (User Overrides)
**Path:** `~/.config/kitty/aesthetics.conf`
**Size:** 1.8K
**Purpose:** Safe customization layer for personal preferences (preserved during updates)

**Currently Empty (All Commented):**
- Font overrides
- Color scheme customization
- Opacity adjustments
- Tab bar styling
- Custom keybindings

**Example Uncommenting:**
```conf
# Uncomment to override Glitch Neon defaults:
background_opacity 0.95
font_family Fira Code
tab_bar_style fade
```

---

### 4. **glitch-effects.sh** (Visual Effects Engine)
**Path:** `~/.config/kitty/glitch-effects.sh`
**Size:** 6.3K
**Permissions:** Executable (`rwx--x--x`)
**Purpose:** Bash script providing 4 visual effects modes for the terminal

**Invocation:**
```bash
/home/miko/.config/kitty/glitch-effects.sh {pulse|flicker|scanline|chaos}
```

**Effects Available:**

| Effect | Description | Visual |
|--------|-------------|--------|
| **pulse** | Smooth breathing opacity (85%-95%) | Calming, meditative |
| **flicker** | Rapid color tint cycling | Intense, active |
| **scanline** | CRT scanline simulation | Retro, nostalgic |
| **chaos** | Random combination of all effects | Unpredictable, wild |

**Key Features:**
- ✅ Lock file management (prevents multiple instances)
- ✅ Kitty remote control integration (requires `allow_remote_control yes`)
- ✅ 5-minute automatic timeout (safety feature)
- ✅ Graceful cleanup on exit (Ctrl+C)
- ✅ Error handling for connection failures

**Keybindings to Trigger:**
- `Ctrl+Alt+G` → Start pulse
- `Ctrl+Alt+F` → Start flicker
- `Ctrl+Alt+P` → Stop all

**Technical Implementation:**
```bash
# Uses Kitty remote control protocol
kitty @ --to "unix:/tmp/kitty-${KITTY_PID}" set-background-opacity 0.90
```

---

### 5. **glitch-toggle** (Interactive Control UI)
**Path:** `~/.config/kitty/glitch-toggle`
**Size:** 5.3K
**Permissions:** Executable (`rwx--x--x`)
**Purpose:** Command-line utility for managing visual effects interactively

**Usage:**
```bash
~/.config/kitty/glitch-toggle <command> [effect]
```

**Commands:**
```bash
# Start specific effect
glitch-toggle start pulse      # Smooth breathing
glitch-toggle start flicker    # Color cycling
glitch-toggle start scanline   # CRT effect
glitch-toggle start chaos      # Random mix

# Manage running effects
glitch-toggle stop             # Stop all effects
glitch-toggle restart pulse    # Stop & start new effect
glitch-toggle status           # Show current status
glitch-toggle list             # List available effects
glitch-toggle help             # Show menu
```

**Features:**
- 🎨 Colored output with status indicators
- 🔍 Process monitoring (checks if effects are running)
- 🧹 Auto-cleanup of lock files
- 🔄 Graceful shutdown (SIGTERM → SIGKILL)
- ✅ Opacity/color reset on stop

---

### 6. **theme-matrix-ops.conf** (Alternative Theme)
**Path:** `~/.config/kitty/kitty.d/theme-matrix-ops.conf`
**Size:** 35 lines
**Purpose:** Matrix-inspired alternative theme (currently disabled)

**Theme Details:**
- **Colors:** Classic Matrix green (#00FF80) on black
- **Font:** Same JetBrains Mono 11pt
- **Style:** "Ops" theme with different cursor trail (140px)
- **Activation:** Uncomment `include kitty.d/theme-matrix-ops.conf` in `kitty.conf`

**Color Scheme:**
```conf
foreground:  #cfeccb (soft green)
background:  #000000 (pure black)
cursor:      #00ff80 (bright green)
accent:      #00ffaa, #66ff99 (various greens)
```

**To Switch to Matrix Theme:**
1. Edit `kitty.conf`
2. Uncomment line 10: `# include kitty.d/theme-matrix-ops.conf`
3. Comment line 34: `include glitch.conf`
4. Reload: `Ctrl+Shift+F5`

---

## Behavior Configuration Summary

### Remote Control (Critical)
```conf
allow_remote_control yes  # In kitty.conf (main)
allow_remote_control socket-only  # In glitch.conf (hardened)
listen_on unix:/tmp/kitty-{kitty_pid}
```
- **Purpose:** Enables scripts to control terminal appearance
- **Security:** Socket-only access (local machine only)
- **Dependencies:** Both effects scripts depend on this

### Visual Effects
- **Default Cursor Trail:** 220px with magenta color
- **Opacity:** 90% background (30% visible through)
- **Inactive Text Alpha:** 85% (slightly dimmed)
- **Font:** JetBrains Mono 11pt (crisp, monospace)

### Performance
- **Repaint Delay:** 3ms (fast but stable)
- **Input Delay:** 0ms (no lag)
- **Sync to Monitor:** Yes (tear-free)
- **Scrollback:** 10,000 lines

### Security
- **Clipboard Control:** Ask before read (privacy)
- **Clipboard Max Size:** 32KB (prevent abuse)
- **Remote Control:** Socket-only (local access)

---

## Dotfiles Source

**Original Source Location:**
```
/home/miko/.local/share/dotfiles/kitty-neon/
├── glitch.conf
├── aesthetics.conf
├── glitch-effects.sh
└── glitch-toggle
```

**Relationship:**
- Dotfiles are the **source of truth**
- `~/.config/kitty/` has **active working copies**
- Changes to dotfiles should sync to config directory
- Local modifications go in `aesthetics.conf` (preserved)

---

## Configuration Flow

```
[kitty.conf] → Main entry point
    ├─→ [glitch.conf] → Theme + keyboard shortcuts
    │       └─→ Uses allow_remote_control for effects
    └─→ [aesthetics.conf] → User overrides

[glitch-effects.sh] → Visual effects engine
    ├─→ Called by keyboard shortcuts (Ctrl+Alt+G/F/P)
    ├─→ Uses kitty remote control protocol
    └─→ Can also be invoked via glitch-toggle

[glitch-toggle] → Interactive control UI
    └─→ Start/stop/restart/status effects
        └─→ Calls glitch-effects.sh in background
```

---

## Behavior Summary

### Current Theme: Glitch Neon
- **Style:** Cyberpunk/Neon aesthetic
- **Colors:** Purple/Magenta/Cyan palette
- **Effects:** Cursor trail, opacity control, visual effects
- **Shortcuts:** 30+ custom keybindings
- **Performance:** Optimized for modern displays

### Available Actions
1. **Visual Effects:** Pulse, Flicker, Scanline, Chaos
2. **Theme Switching:** Matrix theme available (commented out)
3. **Customization:** Edit `aesthetics.conf` for personal tweaks
4. **Monitoring:** GPU & Sensor dashboards available
5. **Control:** Full keyboard shortcut customization

### Key Dependencies
- `allow_remote_control` enabled (required for effects)
- JetBrains Mono font (or compatible monospace)
- Kitty ≥ 0.37.0 (for cursor_trail feature)
- Bash shell (for effect scripts)
- Optional: nvidia-smi (for GPU monitor), sensors (for system monitor)

---

## Quick Reference: File Responsibilities

| File | Responsibility |
|------|-----------------|
| `kitty.conf` | Master orchestration, includes other configs |
| `glitch.conf` | Theme colors, fonts, keyboard shortcuts, behavior |
| `aesthetics.conf` | User customization layer (safe to edit) |
| `glitch-effects.sh` | Pulse/Flicker/Scanline/Chaos visual effects |
| `glitch-toggle` | Interactive effects control UI |
| `theme-matrix-ops.conf` | Alternative Matrix-inspired theme |

---

## How to Modify Behavior

### Change Colors
→ Edit `aesthetics.conf` (uncomment color lines)

### Add Keybindings
→ Add to `aesthetics.conf` (bottom section)

### Disable Effects
→ Comment out lines 149-151 in `glitch.conf`

### Switch Themes
→ Modify includes in `kitty.conf` (swap `glitch.conf` ↔ `theme-matrix-ops.conf`)

### Adjust Font
→ Edit `aesthetics.conf`: `font_family`, `font_size`

### Customize Effects
→ Edit `glitch-effects.sh` (modify opacity ranges, durations)

### Reload Config
→ Press `Ctrl+Shift+F5` or run `kitty @ load-config`

---

## Status: Fully Configured ✅
- ✅ Theme: Glitch Neon active
- ✅ Effects: Enabled and working
- ✅ Shortcuts: All mapped
- ✅ Remote control: Enabled
- ✅ Customization: Ready for personal tweaks
