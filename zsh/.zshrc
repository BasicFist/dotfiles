# ====================== ZSH — NEON CORE v2.0 (Ubuntu 24.04) ======================
# Modularized configuration with enhanced productivity features
# Architecture: Modular organization with separate concerns
# Performance: <0.02s startup with bytecode compilation

# Initialize timing for performance analysis (optional)
# Set DEBUG_STARTUP=1 to see startup times
if [[ "$DEBUG_STARTUP" == "1" ]]; then
  zmodload zsh/datetime
  PS4=$'%D{%M:%S%.} %N:%i> '
  exec 2> >(tee /tmp/zsh_debug_${EPOCHSECONDS})
  setopt XTRACE
fi

# --- Core Shell Options -------------------------------------------------------
setopt NOCLOBBER         # '>|' to force overwrite
setopt IGNOREEOF         # Prevent Ctrl-D from exiting
setopt NO_BEEP

# History options
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_REDUCE_BLANKS HIST_VERIFY INC_APPEND_HISTORY

# Navigation and globbing
setopt AUTO_CD EXTENDED_GLOB NO_CASE_GLOB NO_FLOW_CONTROL
autoload -Uz select-word-style && select-word-style bash

# --- Modular Configuration Loading --------------------------------------------
# Load configuration modules in order
ZCONFIG_DIR="$HOME/.config/zsh"

# Ensure config directory exists
[[ ! -d "$ZCONFIG_DIR" ]] && mkdir -p "$ZCONFIG_DIR"

# Load modules (order matters for dependencies)
[[ -f "$ZCONFIG_DIR/environment.zsh" ]] && source "$ZCONFIG_DIR/environment.zsh"
[[ -f "$ZCONFIG_DIR/completion.zsh" ]] && source "$ZCONFIG_DIR/completion.zsh"
[[ -f "$ZCONFIG_DIR/aliases.zsh" ]] && source "$ZCONFIG_DIR/aliases.zsh"
[[ -f "$ZCONFIG_DIR/functions.zsh" ]] && source "$ZCONFIG_DIR/functions.zsh"
[[ -f "$ZCONFIG_DIR/keybindings.zsh" ]] && source "$ZCONFIG_DIR/keybindings.zsh"

# Plugins MUST be loaded last (syntax-highlighting especially)
[[ -f "$ZCONFIG_DIR/plugins.zsh" ]] && source "$ZCONFIG_DIR/plugins.zsh"

# --- Prompt Configuration ----------------------------------------------------
# Use Starship if available, otherwise use built-in neon prompt
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
else
  # Fallback minimal neon prompt
  autoload -Uz colors && colors
  PROMPT='%{$fg_bold[magenta]%}⟪%n@%m⟫%{$reset_color%} %{$fg[cyan]%}%~%{$reset_color%} %{$fg_bold[magenta]%}❯%{$reset_color%} '
fi

# --- Utility Functions -------------------------------------------------------
# Command timing
precmd() {
  print -Pn '\e]0;%n@%m: %~\a'  # Set terminal title
  [[ "$DEBUG_STARTUP" == "1" ]] && print "Prompt redraw at $(date '+%s.%3N')"
}

# --- Local Overrides ---------------------------------------------------------
# Allow user customizations without editing main config
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
if [[ -f "$HOME/.zshenv.local" && -O "$HOME/.zshenv.local" ]]; then
  source "$HOME/.zshenv.local"
fi

# --- Performance Logging (optional) ------------------------------------------
if [[ "$DEBUG_STARTUP" == "1" ]]; then
  echo "Zsh configuration loaded"
  unsetopt XTRACE
  exec 2>&3 3>&-
fi

# ============================================================================
# Startup complete. Type 'help' for command reference.
# Try: z, cdf, ff, fh, mkcd, extract, weather
# Keybindings: Ctrl-R (history), Ctrl-T (files), Alt-C (dirs)
# ============================================================================
alias config='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
