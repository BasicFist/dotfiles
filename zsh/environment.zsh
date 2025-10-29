# ============================================================================
# environment.zsh - Environment variables and PATH configuration
# ============================================================================

# Locale settings
export LANG=${LANG:-en_US.UTF-8}
export LC_ALL=${LC_ALL:-en_US.UTF-8}

# History configuration
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=100000
export SAVEHIST=100000

# History file locking for multi-session safety
setopt HIST_FCNTL_LOCK  # Prevent corruption from concurrent writes

# Ensure PATH uniqueness
typeset -U PATH path
path=("$HOME/.local/bin" "$HOME/.cargo/bin" "$HOME/bin" $path)

# FZF Configuration (Neon theme)
export FZF_DEFAULT_OPTS='
  --height=42% --layout=reverse --border
  --info=inline --prompt="❯ " --pointer="▶" --marker="✓"
  --color=fg:#F0F8FF,bg:#0A001F,hl:#7AA2F7
  --color=fg+:#F0F8FF,bg+:#1E2130,hl+:#BB9AF7
  --color=border:#414868,header:#7AA2F7,spinner:#FF00FF,marker:#00FF00
  --color=pointer:#FF00FF,prompt:#BB9AF7,info:#414868
  --bind=ctrl-/:toggle-preview,ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down,ctrl-a:select-all
'

# Wayland/X11 clipboard support for FZF
if command -v wl-copy >/dev/null 2>&1; then
  export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS}"$'\n--bind=ctrl-y:execute-silent(echo -n {+} | wl-copy)'
elif command -v xclip >/dev/null 2>&1; then
  export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS}"$'\n--bind=ctrl-y:execute-silent(echo -n {+} | xclip -selection clipboard)'
fi

# FZF fd integration
if command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi

# FZF preview with bat/batcat
if command -v batcat >/dev/null 2>&1; then
  export FZF_CTRL_T_OPTS="--preview 'batcat --color=always --style=numbers --line-range=:500 {}'"
elif command -v bat >/dev/null 2>&1; then
  export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
fi

# Starship configuration
if command -v starship >/dev/null 2>&1; then
  export STARSHIP_CONFIG="$HOME/.config/starship.toml"
fi

# Editor configuration
export EDITOR=${EDITOR:-nvim}
export VISUAL=${VISUAL:-nvim}

# Pager configuration (delta if available)
if command -v delta >/dev/null 2>&1; then
  export PAGER=delta
fi

# zoxide initialization (if installed)
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# ============================================================================
