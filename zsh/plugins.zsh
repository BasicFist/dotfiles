# ============================================================================
# plugins.zsh - Plugin configuration (autosuggestions, syntax highlighting)
# ============================================================================

# zsh-autosuggestions configuration
if [[ -d "$HOME/.config/zsh/zsh-autosuggestions" ]]; then
  source "$HOME/.config/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"

  # Autosuggestions styling
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#414868'
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
fi

# zsh-syntax-highlighting configuration (must be last plugin sourced)
if [[ -d "$HOME/.config/zsh/zsh-syntax-highlighting" ]]; then
  source "$HOME/.config/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

  # Syntax highlighting styles
  ZSH_HIGHLIGHT_STYLES[command]='fg=#7AA2F7,bold'
  ZSH_HIGHLIGHT_STYLES[alias]='fg=#00FFFF'
  ZSH_HIGHLIGHT_STYLES[builtin]='fg=#00FFFF'
  ZSH_HIGHLIGHT_STYLES[function]='fg=#BB9AF7'
  ZSH_HIGHLIGHT_STYLES[arg0]='fg=#F0F8FF'
  ZSH_HIGHLIGHT_STYLES[path]='fg=#00FFFF'
  ZSH_HIGHLIGHT_STYLES[path_pathseparator]='fg=#414868'
  ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#FF00FF,bold'
  ZSH_HIGHLIGHT_STYLES[comment]='fg=#414868,italic'
  ZSH_HIGHLIGHT_STYLES[error]='fg=#FF0000,bold'
fi

# ============================================================================
