# ============================================================================
# completion.zsh - Completion system configuration
# ============================================================================

# Initialize completion system with caching
autoload -Uz compinit

# Check if .zcompdump needs rebuild (24h cycle)
if [[ -n ${HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit -d "$HOME/.zcompdump"      # Rebuild if >24h old
else
  compinit -C -d "$HOME/.zcompdump"   # Use cache if fresh
fi

# Completion styling
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Discover new executables immediately
zstyle ':completion:*:commands' rehash 1

# Cache settings
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.zsh/cache"
mkdir -p "$HOME/.zsh/cache"

# Custom function completions
# Directory completions for mkcd, cdf
compdef _directories mkcd cdf
# File/directory completions for mkcp, mkmv
compdef _files mkcp mkmv
# Archive file completions for extract
compdef '_files -g "*.{tar,gz,tgz,bz2,tbz2,xz,txz,zip,rar,7z}"' extract
# Process completions for fkill
compdef _pids fkill

# FZF completion integration (multi-distro support)
for fzf_completion in \
  /usr/share/doc/fzf/examples/completion.zsh \
  /usr/share/fzf/shell/completion.zsh \
  /usr/local/opt/fzf/shell/completion.zsh \
  ~/.fzf/shell/completion.zsh; do
  if [[ -r "$fzf_completion" ]]; then
    source "$fzf_completion"
    break
  fi
done
unset fzf_completion

# ============================================================================
