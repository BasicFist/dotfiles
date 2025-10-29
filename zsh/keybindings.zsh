# ============================================================================
# keybindings.zsh - Key bindings and line editing configuration
# ============================================================================

# Use Emacs mode
bindkey -e

# History navigation
bindkey '^P' up-history
bindkey '^N' down-history
bindkey '^R' history-incremental-search-backward
bindkey '^S' history-incremental-search-forward

# Movement and editing
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^B' backward-char
bindkey '^F' forward-char
bindkey '^K' kill-line
bindkey '^U' kill-whole-line
bindkey '^W' backward-kill-word
bindkey '^[d' kill-word

# Better word navigation
bindkey '^[f' forward-word
bindkey '^[b' backward-word

# Useful shortcuts
bindkey '^L' clear-screen
bindkey '^[c' capitalize-word

# Register word case manipulation widgets explicitly for zsh-syntax-highlighting
# These are wrappers around built-in widgets
function _downcase-word() { zle .downcase-word }
function _upcase-word() { zle .upcase-word }
zle -N downcase-word _downcase-word
zle -N upcase-word _upcase-word

bindkey '^[l' downcase-word
bindkey '^[u' upcase-word

# FZF key bindings (multi-distro support)
for fzf_keybindings in \
  /usr/share/doc/fzf/examples/key-bindings.zsh \
  /usr/share/fzf/shell/key-bindings.zsh \
  /usr/local/opt/fzf/shell/key-bindings.zsh \
  ~/.fzf/shell/key-bindings.zsh; do
  if [[ -r "$fzf_keybindings" ]]; then
    source "$fzf_keybindings"
    break
  fi
done
unset fzf_keybindings

# ============================================================================
