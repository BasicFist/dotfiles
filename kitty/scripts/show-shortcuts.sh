#!/bin/bash
# ═══════════════════════════════════════════════════════════
# 📋 KITTY SHORTCUTS DISPLAY
# ═══════════════════════════════════════════════════════════
# Shows all keyboard shortcuts in a formatted overlay window
# Part of Kitty HARDENED v2.1.1 configuration

set -euo pipefail

# Color definitions (kept for future styling hooks)
# shellcheck disable=SC2034
readonly CYAN='\033[0;36m'
# shellcheck disable=SC2034
readonly MAGENTA='\033[0;35m'
# shellcheck disable=SC2034
readonly GREEN='\033[0;32m'
# shellcheck disable=SC2034
readonly YELLOW='\033[0;33m'
# shellcheck disable=SC2034
readonly NC='\033[0m'
# shellcheck disable=SC2034
readonly BOLD='\033[1m'

# Display shortcuts in categorized format.
# Note: powerline glyphs assume a Nerd Font; Kitty falls back to plain separators otherwise.
show_shortcuts() {
    clear

    cat << 'EOF'
╔═══════════════════════════════════════════════════════════╗
║        ⚡ KITTY TERMINAL - KEYBOARD SHORTCUTS ⚡          ║
║                  HARDENED v2.1.1 Modular                  ║
╚═══════════════════════════════════════════════════════════╝

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔄 RELOAD CONFIGURATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Ctrl+Shift+F5              Reload configuration

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🪟 WINDOWS & SPLITS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Ctrl+Shift+Enter           New window (current dir)
  Ctrl+Shift+W               Close window
  Ctrl+Shift+-               Horizontal split
  Ctrl+Alt+H                 Horizontal split (AZERTY-friendly)
  Ctrl+Shift+=               Vertical split
  Ctrl+Alt+V                 Vertical split (AZERTY-friendly)
  Ctrl+Shift+Arrow Keys      Focus neighboring window

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📑 TABS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Ctrl+Shift+T               New tab
  Ctrl+Shift+Q               Close tab
  Ctrl+Shift+[ / ]           Previous / Next tab
  Ctrl+1 to Ctrl+5           Jump directly to tab 1-5
  Ctrl+F1 to Ctrl+F5         Tab selection (AZERTY-friendly)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📜 SCROLLING & SEARCH
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Ctrl+Shift+K / J           Scroll one line up / down
  Ctrl+Shift+PageUp/Down     Scroll a full page
  Ctrl+Shift+Home/End        Jump to top / bottom
  Ctrl+Shift+F               Search scrollback
  Ctrl+Shift+H               Open scrollback in pager

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎨 DISPLAY & APPEARANCE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Ctrl+Shift++               Increase font size
  Ctrl+Shift+Backspace       Reset font size
  Ctrl+Alt+, / .             Decrease / Increase opacity
  Ctrl+Alt+0                 Reset opacity to 0.98
  Ctrl+Shift+F11             Toggle fullscreen
  Ctrl+Alt+O                 Toggle configured transparency presets
  Ctrl+Alt+S                 Toggle scratchpad overlay

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 SYSTEM MONITORING
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Ctrl+Alt+M                 Title-bar system monitor (mpstat + sensors)
  Ctrl+Alt+Shift+M           Stop system monitor
  Ctrl+Shift+G               GPU monitor (nvidia-smi loop)
  Ctrl+Shift+S               Sensors monitor (lm-sensors loop)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 CLIPBOARD WORKFLOW
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Ctrl+Shift+C               Copy to clipboard (auto on select enabled)
  Ctrl+Shift+V               Paste from clipboard
  Shift+Insert               Paste from primary selection
  Middle-Click               Paste selection (mouse)
  Ctrl+Alt+V                 Paste from primary selection (keyboard)
  Ctrl+Shift+Alt+V           Paste from clipboard (force)
  Ctrl+Shift+Alt+C           Copy and clear / send interrupt
  Ctrl+Shift+P               Paste without newlines
  Ctrl+Shift+Alt+P           Clipboard manager overlay

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🛠️ UTILITIES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Ctrl+Shift+I               Image viewer overlay
  Ctrl+Shift+Space           Command palette (hints kitten)
  Ctrl+Shift+/               Show shortcuts (this window)
  Ctrl+Shift+Escape          Kitty shell window
  Ctrl+Shift+U               Unicode character input
  Ctrl+Alt+A                 Toggle agent overlay (AZERTY-friendly)
  Ctrl+Alt+Shift+A           Focus agent overlay
  Ctrl+Alt+Shift+H           Toggle agent split (horizontal)
  Ctrl+Alt+Shift+V           Toggle agent split (vertical)
  Ctrl+Alt+X                 Start/join shared tmux session (current shell)
  Ctrl+Alt+Shift+T           Theme chooser kitten
  Ctrl+Alt+Shift+D           Diff kitten overlay

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 COLOR SCHEME (True Neon)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Background:     #000000  (Pure black)
  Foreground:     #00FFFF  (Electric cyan)
  Cursor:         #FF0099  (Hot pink)
  Selection:      #00FF00  (Electric lime)
  Active Border:  #00FFFF  (Cyan glow)
  Active Tab:     #FF0099  (Hot pink)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔒 SECURITY FEATURES (A+ Grade - 8/8)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✅ Auto-quote malicious URLs
  ✅ Replace dangerous control codes (v2.1.1)
  ✅ Confirm large pastes (>16KB)
  ✅ Socket-only remote control
  ✅ Clipboard read protection
  ✅ 32MB clipboard limit
  ✅ Smart trailing spaces
  ✅ Hide mouse on typing (v2.1.1)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📁 QUICK COMMANDS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Verify config:     bash ~/.config/kitty/verify-config.sh
  Switch theme:      bash ~/.config/kitty/scripts/switch-theme.sh
  Validate scripts:  bash ~/.config/kitty/scripts/lint.sh
  Reload config:     kitty @ load-config

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        Press ANY KEY to close this window...

EOF

    # Wait for any key
    read -r -n 1 -s
}

# Main execution
show_shortcuts
