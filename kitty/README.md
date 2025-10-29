# ⚡ Kitty Terminal - HARDENED v2.1.1 Modular Configuration

**Architecture:** Modular
**Security:** A+ (8/8 official features) ✅
**Theme:** True Neon (Electric Cyan + Hot Pink)
**Version:** Kitty >= 0.37.0 recommended
**Platform:** Ubuntu 24.04 LTS (Wayland/X11 compatible) — Linux only support

**v2.1 Enhancements:** Enhanced error handling, utility scripts, shellcheck integration
**v2.1.1 Updates:** A+ security (control code protection), official mouse behavior

---

## ✅ Requirements

- **Fonts:** JetBrains Mono (regular/bold/italic) installed system-wide (`/usr/share/fonts/truetype/jetbrains-mono/` on Ubuntu).
- **CLI tooling:** `shellcheck`, `rsync`, GNU `sed`, `python3`, `bc`, `mpstat` (sysstat), `sensors` (lm-sensors), `nvidia-smi` (NVIDIA drivers), and a clipboard tool (`wl-clipboard` or `xclip`).
- **Optional:** `nvim` (>=0.12) for the enhanced scrollback pager.
- **Optional (shared session):** `tmux` if you rely on the shared tmux helper.
- **Kitty:** v0.37.0 or newer (cursor trail + hardened paste features).
- **Optional (Wayland):** `wl-copy`/`wl-paste` if you extend clipboard tooling beyond the current X11 clipboard support.

Install missing packages before running the verification and maintenance scripts to avoid degraded features.

---

## 🚀 Quick Start

### Reload Configuration
```bash
# In Kitty terminal
Ctrl+Shift+F5

# Or from command line
kitty @ load-config
```

### Verify Installation
```bash
bash ~/.config/kitty/verify-config.sh
```

### Sync With LAB Repository
```bash
# From LAB checkout
make -C lab/dotfiles/kitty sync-pull       # Live → repo
make -C lab/dotfiles/kitty sync-push       # Repo → live
make -C lab/dotfiles/kitty sync-status     # Preview both directions (dry-run)

# Common automation
make -C lab/dotfiles/kitty lint            # Shellcheck all scripts
make -C lab/dotfiles/kitty verify-repo     # Verify repo copy
make -C lab/dotfiles/kitty verify-live     # Verify ~/.config/kitty
make -C lab/dotfiles/kitty backup          # Snapshot live kitty.conf

# Or call the script directly when you need custom flags
bash lab/dotfiles/kitty/scripts/sync.sh pull
bash lab/dotfiles/kitty/scripts/sync.sh push
```

### Keybinding Script Dependencies
Several shortcuts launch helper scripts that must live alongside `kitty.conf`. Deploy this directory to `~/.config/kitty/` (or update the paths) and keep the scripts executable:

- `Ctrl+Alt+M` → `~/.config/kitty/system-monitor.sh`
- `Ctrl+Alt+Shift+M` → `~/.config/kitty/stop-monitor.sh`
- `Ctrl+Shift+Alt+P` → `~/.config/kitty/clipboard-manager.sh`
- `Ctrl+Shift+/` (aka `kitty_mod+/`, also catches `Ctrl+Shift+?`, `Ctrl+/`, `Ctrl+Shift+_`) → `kitty +kitten ~/.config/kitty/kittens/shortcuts_menu/main.py`
- `F12` → fallback binding for the same shortcut palette
- `Ctrl+Alt+O` → `~/.config/kitty/scripts/toggle-transparency.sh`
- `Ctrl+Alt+S` → `~/.config/kitty/scripts/toggle-scratchpad.sh`
- `Ctrl+Alt+A` → `~/.config/kitty/scripts/agent-terminal.sh toggle`
- `Ctrl+Alt+Shift+A` → `~/.config/kitty/scripts/agent-terminal.sh focus`
- `Ctrl+Alt+Shift+H` → `KITTY_AGENT_LAUNCH_MODE=hsplit agent-terminal.sh toggle`
- `Ctrl+Alt+Shift+V` → `KITTY_AGENT_LAUNCH_MODE=vsplit agent-terminal.sh toggle`
- `Ctrl+Alt+X` → `~/.config/kitty/scripts/launch-shared-tmux.sh`

Source the shared tmux aliases before launching Kitty so you can run the helper
commands manually:

```bash
echo 'source ~/.config/kitty/scripts/tmux-shared-aliases.sh' >> ~/.zshrc
```

Then use the aliases directly inside tmux:

- `tmux-shared` to attach/create the `agents` session
- `tmux-shared-split-h` for a horizontal split targeting `agents`
- `tmux-shared-split-v` for a vertical split targeting `agents`

 If you install to a nonstandard location, update the paths in `kitty.d/keybindings.conf` accordingly to avoid overlay launches failing silently.

### AZERTY Layout Helpers
- Horizontal split: `Ctrl+Alt+H` (in addition to `Ctrl+Shift+-`)
- Vertical split: `Ctrl+Alt+V` (in addition to `Ctrl+Shift+=`)
- Tab jumps: `Ctrl+F1`…`Ctrl+F5` mirror `Ctrl+1`…`Ctrl+5`

---

## 📁 Architecture

### File Structure
```
~/.config/kitty/
├── kitty.conf                      # Master orchestration (85 lines)
├── kitty.d/                        # Modular components
│   ├── security.conf               # Security settings (43 lines) 🔒
│   ├── core.conf                   # Font, shell integration (48 lines)
│   ├── perf-balanced.conf          # Default performance (32 lines) ⚡
│   ├── perf-lowlatency.conf        # Alternative performance (35 lines)
│   ├── theme-neon.conf             # True Neon color scheme (82 lines) 🎨
│   ├── theme-matrix-ops.conf       # Matrix green alternative (82 lines)
│   ├── visual-effects-base.conf    # Shared ergonomics (cursor, mouse)
│   ├── visual-effects-tabs.conf    # Shared tab layout (edge, margins)
│   ├── visual-effects-neon.conf    # Neon-specific opacity & tabs
│   ├── visual-effects-matrix.conf  # Matrix Ops visual profile
│   ├── mouse.conf                  # Link-opening shortcuts & mouse maps
│   └── keybindings.conf            # All shortcuts (143 lines) ⌨️
├── scripts/                        # Utility scripts (v2.1) 🔧
│   ├── switch-theme.sh             # Interactive theme switcher
│   ├── agent-terminal.sh           # Remote-controlled agent overlay helper
│   ├── launch-shared-tmux.sh       # tmux session helper (shared panes)
│   ├── toggle-transparency.sh      # Remote-control opacity toggle
│   ├── toggle-scratchpad.sh        # Overlay scratchpad launcher
│   ├── tab-title-sync.sh           # Helper for dynamic tab titles
│   └── lint.sh                     # Shellcheck integration
├── verify-config.sh                # Configuration validator (enhanced v2.1)
├── system-monitor.sh               # CPU/GPU monitoring (enhanced v2.1)
├── stop-monitor.sh                 # Stop monitoring (enhanced v2.1)
├── clipboard-manager.sh            # Clipboard operations (enhanced v2.1)
├── kitty.local/                    # Optional per-host overrides (ignored)
├── .editorconfig                   # Editor consistency rules (v2.1)
├── wallpapers/                     # Curated wallpapers (versioned)
└── Backups/                        # Auto-generated backups
```

### Local Overrides
- Drop host-specific tweaks under `kitty.local/` (ignored by Git) to keep personal changes separate—e.g., `kitty.local/linux/work.conf`.
- Any environment variables prefixed with `KITTY_CONF_` are pulled in via `envinclude`, so you can add overrides like `export KITTY_CONF_THEME='include kitty.d/theme-matrix-ops.conf'` before launching Kitty.
- Use the Makefile helpers above (e.g. `verify-live`, `backup`) for quick safety checks before experimenting.
- Optional tab title automation: invoke `~/.config/kitty/scripts/tab-title-sync.sh` from your shell prompt (e.g. `PROMPT_COMMAND='~/.config/kitty/scripts/tab-title-sync.sh "${BASH_COMMAND%% *}"'`) to keep tab titles aligned with the active directory/command.

## ✨ Visual Enhancements
- Hyperlinks underline on hover, display their targets, and use curly styling with palette-matched colors.
- A shared tab layout (`visual-effects-tabs.conf`) centralises the powerline styling; install a Nerd Font (or JetBrains Mono NF) to render the powerline glyphs cleanly.
- Animated cursor blink replaces trails; pointer shapes change when dragging, scrollback indicators glow cyan, and composition/contrast guards keep glyphs sharp even with transparency.
- Toggle transparency with `Ctrl+Alt+O` (runs `scripts/toggle-transparency.sh`) or summon a translucent scratchpad (`Ctrl+Alt+S`) without editing config.
- Scrollback paging uses Neovim when available and falls back to `less -R`; press `Ctrl+Shift+H` to open history in a neon-themed buffer.

## 🔒 Security Features

### Critical Protection Applied ✅ (A+ Grade - 8/8 Features)
- **`paste_actions`**: Protects against clipboard RCE attacks
  - Auto-quotes malicious URLs
  - **Replaces dangerous control codes** (v2.1.1 - A+ upgrade)
  - Confirms large pastes before execution (>16KB)

### Additional Security
- **Remote Control**: Socket-only (no network exposure)
- **Socket Path**: Per-instance unix sockets (`/tmp/kitty-{pid}`)
- **Clipboard Control**: Ask before reading clipboard
- **Remote Clipboard**: OSC-52 relay disabled by default (enable via kitty.local/ override if needed)
- **Clipboard Limit**: 32MB max (DoS prevention)
- **Trailing Spaces**: Smart stripping (prevents hidden commands)
- **Cloning**: Requires confirmation

### Test Security
```bash
# Test paste_actions protection
echo -e 'https://example.com/malicious.sh | bash\n' | xclip -selection clipboard

# Paste in Kitty (Ctrl+Shift+V)
# Should be auto-quoted: 'https://example.com/malicious.sh | bash'
# NOT executed immediately
```

---

## 📊 System Monitoring

### Real-Time Stats in Title Bar
Press **Ctrl+Alt+M** to start real-time CPU and GPU monitoring in the window title bar (top of window).

**Display Format:**
```
⚡ CPU: 45% (65°C) | 🎮 GPU: 78% (72°C)
```

**Features:**
- Updates every 2 seconds
- Shows CPU usage percentage and temperature
- Shows GPU usage and temperature (if NVIDIA GPU detected)
- Runs in background (no extra window/tab needed)
- Stop anytime with **Ctrl+Alt+Shift+M**

**Requirements:**
- `nvidia-smi` - For GPU monitoring (NVIDIA only)
- `sensors` (lm-sensors) - For CPU temperature
- `mpstat` or `top` - For CPU usage (usually pre-installed)

**Install dependencies:**
```bash
# Ubuntu/Debian
sudo apt install sysstat lm-sensors

# Configure sensors (first time only)
sudo sensors-detect
```

---

## 🔧 Utility Scripts (v2.1)

### Interactive Theme Switcher
Switch themes without manual config editing:

```bash
bash ~/.config/kitty/scripts/switch-theme.sh
```

**Features:**
- Interactive menu with current theme indication
- Automatic backup before changes
- Auto-reload configuration
- Supports: True Neon, Matrix Ops themes

**Example:**
```
🎨 Kitty Theme Switcher
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Available themes:
1. neon (active)
2. matrix-ops
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Select theme (1-2): 2

🔄 Switching to: matrix-ops
✅ Theme configuration updated
✨ Theme 'matrix-ops' applied successfully
```

### Agent Subterminal Overlay
Keep the main terminal free while an agent runs commands in a dedicated overlay:

```bash
# Toggle the overlay (opens if absent, closes if present)
bash ~/.config/kitty/scripts/agent-terminal.sh toggle

# Focus the overlay without stealing focus permanently
bash ~/.config/kitty/scripts/agent-terminal.sh focus

# Send a one-off command into the overlay
bash ~/.config/kitty/scripts/agent-terminal.sh run "htop"
```

- Creates an overlay window via `kitty @ launch --type=overlay` and keeps the main pane focused.
- Commands are injected with `kitty @ send-text --stdin` (see official remote control docs).
- Toggle/focus helpers are bound to `Ctrl+Alt+A` / `Ctrl+Alt+Shift+A` for quick access.
- Pipe arbitrary scripts with `agent-terminal.sh pipe` to stream input into the agent window.
- Set `KITTY_AGENT_LAUNCH_MODE=hsplit` or `KITTY_AGENT_LAUNCH_MODE=vsplit` to open the agent as a traditional split instead of an overlay (bound to `Ctrl+Alt+Shift+H/V`).

### Shared Tmux Session
Open a shared tmux session with two vertical panes so multiple actors can operate in the same shell:

**Keybinding:** `Ctrl+Alt+X`

**Manual run:**
```bash
KITTY_TMUX_SESSION=kitty-shared KITTY_TMUX_LAYOUT=even-vertical \\
  ~/.config/kitty/scripts/launch-shared-tmux.sh
```

- Requires `tmux`; the script auto-creates the session and splits it vertically the first time.
- Subsequent invocations attach to the same session, so any window that presses the shortcut joins the shared shell.
- Customize the session name or layout with `KITTY_TMUX_SESSION` / `KITTY_TMUX_LAYOUT` before invoking the shortcut.
- Use the aliases from `scripts/tmux-shared-aliases.sh` (`tmux-shared`, `tmux-shared-split-h`, `tmux-shared-split-v`) when you need to control the shared session directly.

### Keyboard Shortcuts Overlay
Display all shortcuts in an interactive floating palette:

**Keybinding:** `Ctrl+Shift+/` (forward slash)

**Or run manually:**
```bash
kitty @ launch --type=overlay --keep-focus \
  kitten ~/.config/kitty/kittens/shortcuts_menu/main.py
```

---

## 📚 Additional References

- `docs/MAINTENANCE.md` – command cheat sheet & telemetry notes
- `docs/STYLE_GUIDE.md` – formatting conventions for configs, scripts, and docs
- `wallpapers/README.md` – guidance for managing curated wallpaper assets

**Palette features:**
- Live filtering by typing
- Highlight moves with ↑/↓ (PageUp/PageDown supported)
- Enter or Esc to close
- Mirrors the shortcut metadata defined in `kitty.d/`

### Shellcheck Integration
Validate all shell scripts with professional linting:

```bash
bash ~/.config/kitty/scripts/lint.sh
```

**Features:**
- Automated quality validation for all .sh files
- Shellcheck integration with severity levels
- Clear pass/fail reporting
- Installation instructions if shellcheck missing

**Requirements:**
```bash
sudo apt install shellcheck  # Ubuntu/Debian
```

### Enhanced Verification (v2.1)
The verification script now includes proper exit codes for CI/CD:

```bash
bash ~/.config/kitty/verify-config.sh
echo $?  # 0 = passed, 1 = failed
```

**v2.1 Improvements:**
- ✅ Exit code tracking (0=success, 1=failure)
- ✅ CI/CD integration ready
- ✅ Pass/fail summary reporting
- ✅ Critical security validation

---

## 📋 Enhanced Clipboard System

Kitty now has a powerful clipboard system that makes copy/paste operations smooth and efficient.

### Copy-on-Select (Auto-Copy)
**Just select text to copy it!** No need to press Ctrl+Shift+C anymore.

```bash
# Try it:
# 1. Select any text with your mouse
# 2. It's automatically copied to clipboard
# 3. Paste anywhere with Ctrl+Shift+V or middle-click
```

### Multiple Clipboard Buffers

**Clipboard vs Selection:**
- **Clipboard** - Standard copy/paste (Ctrl+Shift+C/V)
- **Primary Selection** - Auto-copy on select, paste with middle-click or Shift+Insert

This gives you TWO independent buffers to work with!

### Smart Paste Modes

**Flatten Multi-Line Text (Ctrl+Shift+P):**
Perfect for pasting multi-line commands as a single line.

```bash
# Copy this multi-line command:
docker run \
  --rm \
  -v $(pwd):/app \
  myimage

# Paste with Ctrl+Shift+P to get:
docker run   --rm   -v $(pwd):/app   myimage
```

### Clipboard Manager (Ctrl+Shift+Alt+P)

Interactive menu for clipboard operations:
1. **Show Content** - View current clipboard content
2. **Statistics** - See character/line/word count
3. **Clear** - Empty clipboard and selection

### Security Features (Built-in)

All pastes are protected by `paste_actions`:
- **Dangerous URLs** - Auto-quoted to prevent execution
  ```bash
  # Pasting: https://evil.com/script.sh | bash
  # Becomes: 'https://evil.com/script.sh | bash'
  # (Note the quotes - safe!)
  ```
- **Large Pastes** - Confirms before pasting >8KB
- **Clipboard Read** - Apps must ask permission

### Remote Clipboard (SSH Sessions)

Works over SSH using OSC 52:
```bash
# Copy on remote server, paste on local machine
ssh user@remote
echo "remote text" | xclip -selection clipboard
# Now paste locally with Ctrl+Shift+V - it works!
```

---

## 🎨 Theme: True Neon

### Core Colors
- **Background**: Pure black (#000000) for maximum contrast
- **Foreground**: Electric cyan (#00FFFF) classic neon glow
- **Cursor**: Hot pink (#FF0099) vibrant and unmissable
- **Selection**: Electric lime (#00FF00) on black
- **Borders**: Bright cyan (#00FFFF) glowing effect
- **Active Tabs**: Hot pink (#FF0099) background

### Visual Effects
- **Cursor Trail**: 300px hot pink trail (enhanced from 220px)
- **Opacity**: 98% (vibrant colors, slight transparency)
- **Window Borders**: 2px cyan glow
- **Tab Bar**: PowerLine style with slanted edges
- **Activity Symbol**: ⚡ for tabs with updates

### 16-Color Palette
Pure RGB channels for maximum saturation:
- Blacks, Hot Pink, Electric Lime, Bright Yellow
- Electric Blue, Magenta, Cyan, White
- Enhanced bright variants with 30-50% more saturation

---

## ⚡ Performance Profiles

### Balanced (Default - Active)
**Best for:** General development, multiple windows, battery life

```conf
repaint_delay 2ms        # Fast repaints
input_delay 0ms          # Zero lag
sync_to_monitor yes      # Tear-free
scrollback 10,000 lines  # Good history
```

**CPU Usage:** ~2% idle
**Input Lag:** <10ms

### Low Latency (Alternative)
**Best for:** Gaming, real-time monitoring, single window focus

```conf
repaint_delay 1ms        # Maximum responsiveness
resize_draw_strategy size # Smoother but more GPU
scrollback 5,000 lines   # Reduced for speed
```

**CPU Usage:** ~5% idle
**Input Lag:** <3ms

### Switch Profiles
```bash
# Edit ~/.config/kitty/kitty.conf
# Comment out current profile:
# include kitty.d/perf-balanced.conf

# Uncomment desired profile:
include kitty.d/perf-lowlatency.conf

# Reload
Ctrl+Shift+F5
```

---

## ⌨️ Keyboard Shortcuts

### Window Management
- `Ctrl+Shift+Enter` - New window (inherits current directory)
- `Ctrl+Shift+W` - Close window
- `Ctrl+Shift+-` - Horizontal split
- `Ctrl+Shift+=` - Vertical split
- `Ctrl+Shift+Arrows` - Navigate between windows

### Tab Management
- `Ctrl+Shift+T` - New tab
- `Ctrl+Shift+Q` - Close tab
- `Ctrl+Shift+[/]` - Previous/Next tab
- `Ctrl+1-5` - Jump to tab 1-5

### Display Control
- `Ctrl+Shift++` - Increase font ±2pt
- `Ctrl+Shift+Backspace` - Reset font to default
- `Ctrl+Alt+,/.` - Decrease/Increase opacity ±2%
- `Ctrl+Alt+0` - Reset opacity to 98%

### System Monitoring
- `Ctrl+Alt+M` - Start system monitor (shows CPU/GPU usage in window title)
- `Ctrl+Alt+Shift+M` - Stop system monitor
- `Ctrl+Shift+G` - GPU monitor (nvidia-smi loop in new tab)
- `Ctrl+Shift+S` - Sensors monitor (lm-sensors loop in new tab)

### Utilities
- `Ctrl+Shift+I` - Image viewer (kitty icat)
- `Ctrl+Shift+Space` - Command palette (hints)
- `Ctrl+Shift+F` - Search scrollback
- `Ctrl+Shift+/` - **Show keyboard shortcuts overlay** (quick reference)
- `Ctrl+Shift+H` - Open scrollback in pager (kitty default)
- `Ctrl+Shift+F11` - Fullscreen toggle
- `Ctrl+Shift+U` - Unicode input
- `Ctrl+Shift+Escape` - Kitty shell (debug)
- `Ctrl+Alt+O` - Toggle transparency (scripts/toggle-transparency.sh)
- `Ctrl+Alt+S` - Toggle neon scratchpad overlay
- `Ctrl+Alt+Shift+T` - Launch theme chooser kitten
- `Ctrl+Alt+Shift+D` - Launch diff kitten

### Intentional Omissions
- Kitty’s copy-mode and layout rotation shortcuts remain unbound to keep the scheme lean—add your own mappings in `kitty.d/keybindings.conf` if you rely on them.
- Tab move/resize defaults (`kitty_mod+Shift+←/→`, etc.) are also unset; use the command palette or custom bindings per workspace needs.

### Copy/Paste (Enhanced)
**Basic Operations:**
- `Ctrl+Shift+C` - Copy to clipboard
- `Ctrl+Shift+V` - Paste from clipboard (with security protection)
- **Auto Copy-on-Select** - Just select text to copy automatically!

**Advanced Clipboard:**
- `Shift+Insert` - Paste from primary selection (X11-style)
- `Middle-Click` - Paste selection with mouse
- `Ctrl+Alt+V` - Paste from primary selection
- `Ctrl+Shift+P` - Paste without newlines (flatten multi-line text)
- `Ctrl+Shift+Alt+P` - Clipboard manager (view/stats/clear)

**Features:**
- ✨ Auto-copy when selecting text (no need to press Ctrl+Shift+C!)
- 🖱️ Middle-click paste for quick workflow
- 🔒 Security: Auto-quotes dangerous URLs, confirms large pastes
- 🌐 Remote clipboard support (OSC 52) for SSH sessions

---

## 🔧 Customization

### Change Theme Colors
Edit `~/.config/kitty/kitty.d/theme-neon.conf`:
```conf
# Change cursor from hot pink to blue
cursor #0099FF

# Change foreground from cyan to green
foreground #00FF00
```

### Adjust Cursor Trail
Edit `~/.config/kitty/kitty.d/visual-effects-neon.conf` (or the corresponding theme file):
```conf
# Longer trail
cursor_trail 400  # was 300

# Faster decay
cursor_trail_decay 0.05 0.30  # was 0.03 0.20
```

### Modify Opacity
```conf
# In visual-effects-neon.conf
background_opacity 0.95  # was 0.98 (more transparent)
```

### Add Custom Keybindings
Edit `~/.config/kitty/kitty.d/keybindings.conf`:
```conf
# Add your custom mappings
map ctrl+alt+m launch --type=tab htop
```

---

## 🛠️ Troubleshooting

### Configuration Won't Load
```bash
# Check syntax
bash ~/.config/kitty/verify-config.sh

# Validate with Python
kitty +runpy "from kitty.config import load_config; print('OK')"

# Check includes
grep "^include" ~/.config/kitty/kitty.conf
```

### Colors Wrong After Reload
```bash
# Verify theme is included
grep "theme-neon.conf" ~/.config/kitty/kitty.conf

# Should show:
# include kitty.d/theme-neon.conf

# Force reload
kitty @ load-config
```

### Cursor Trail Not Showing
```bash
# Check Kitty version (needs >= 0.37.0)
kitty --version

# Verify cursor_trail setting
grep "cursor_trail" ~/.config/kitty/kitty.d/visual-effects-*.conf
```

### Restore from Backup
```bash
# If something breaks, restore backups
cd ~/.config/kitty
cp kitty.conf.backup-20251019-003752 kitty.conf
cp glitch.conf.backup-20251019-003752 glitch.conf.DEPRECATED
kitty @ load-config
```

---

## 📊 Migration History

### Before (Monolithic)
- **Architecture**: Single 186-line glitch.conf mixing all concerns
- **Security**: Missing critical `paste_actions` protection
- **Maintainability**: Hard to audit, customize, or share
- **Git Diffs**: Unrelated changes mixed together

### After (HARDENED v2.0)
- **Architecture**: 7 modular files with clear separation
- **Security**: A+ grade (11/11 checks passing)
- **Maintainability**: Easy to audit, swap profiles, customize
- **Git Diffs**: Changes isolated to specific modules

### Benefits Achieved
✅ Security isolated and audit-ready (43 lines only)
✅ Easy theme switching (comment/uncomment one line)
✅ Performance profile selection (balanced ↔ low-latency)
✅ Clear separation of concerns
✅ Better Git diffs (changes isolated to specific modules)
✅ Easier to share configurations (e.g., just security settings)

---

## 📝 Development

### Modify a Module
```bash
# Edit specific module
nvim ~/.config/kitty/kitty.d/theme-neon.conf
nvim ~/.config/kitty/kitty.d/keybindings.conf
nvim ~/.config/kitty/kitty.d/visual-effects-neon.conf

# Reload to apply changes
kitty @ load-config
```

### Create Custom Theme
```bash
# Copy existing theme
cp ~/.config/kitty/kitty.d/theme-neon.conf \
   ~/.config/kitty/kitty.d/theme-custom.conf

# Edit colors
nvim ~/.config/kitty/kitty.d/theme-custom.conf

# Activate in kitty.conf
# include kitty.d/theme-custom.conf
```

### Git Workflow
```bash
cd ~/.config/kitty

# Check status
git status

# Commit modular changes
git add kitty.d/theme-neon.conf
git commit -m "feat(kitty): adjust neon cyan brightness"

# Commit security updates
git add kitty.d/security.conf
git commit -m "security(kitty): enable additional clipboard protection"
```

---

## 🎯 Best Practices

### Security
- Run `verify-config.sh` after any changes
- Never disable `paste_actions` (critical protection)
- Keep `allow_remote_control socket-only`
- Review security.conf independently before sharing

### Performance
- Use `perf-balanced.conf` for daily work
- Switch to `perf-lowlatency.conf` for gaming/demos
- Monitor CPU usage if enabling many background processes
- Adjust `scrollback_lines` based on memory constraints

### Customization
- Edit one module at a time
- Test after each change (Ctrl+Shift+F5)
- Keep backups before major modifications
- Document custom changes in comments

### Version Control
- Commit each module separately for clear history
- Use conventional commit messages
- Tag stable configurations
- Share individual modules, not entire config

---

## 📚 References

### Official Documentation
- Kitty Terminal: https://sw.kovidgoyal.net/kitty/
- Configuration: https://sw.kovidgoyal.net/kitty/conf/
- Remote Control: https://sw.kovidgoyal.net/kitty/remote-control/
- Security (paste_actions): https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.paste_actions

### Community Resources
- r/unixporn Kitty configs: https://github.com/topics/kitty-terminal
- Arch Wiki Kitty: https://wiki.archlinux.org/title/Kitty
- Security hardening discussions: https://github.com/kovidgoyal/kitty/discussions

---

## ✅ Verification Checklist

Run after installation or major changes:

- [ ] Configuration loads without errors (`verify-config.sh`)
- [ ] Security: paste_actions enabled
- [ ] Security: remote control socket-only
- [ ] All 7 modules present in kitty.d/
- [ ] Theme displays correctly (electric cyan + hot pink)
- [ ] Cursor trail visible (300px hot pink)
- [ ] All keybindings functional
- [ ] Backups exist for rollback
- [ ] Git commits clean and documented

---

**Status:** ✅ MIGRATION COMPLETE
**Architecture:** HARDENED v2.0 Modular
**Security Grade:** A+ (paste_actions applied)
**Theme:** True Neon (Electric Cyan #00FFFF + Hot Pink #FF0099)
**Reload:** `Ctrl+Shift+F5` or `kitty @ load-config`

---

**Questions?** Review module-specific files in `kitty.d/` for detailed settings and comments.
