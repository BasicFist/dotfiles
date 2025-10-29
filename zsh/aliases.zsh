# ============================================================================
# aliases.zsh - All command aliases (modern tools and shortcuts)
# ============================================================================

# --- cat/ls/grep replacements (modern tools) ---
if command -v batcat >/dev/null 2>&1; then
  alias bat='batcat'
  alias cat='batcat --style=plain --paging=never'
elif command -v bat >/dev/null 2>&1; then
  alias cat='bat --style=plain --paging=never'
fi

if command -v eza >/dev/null 2>&1; then
  alias ls='eza --group-directories-first --icons=auto --git -al'
  alias ll='eza -la --git'
  alias la='eza -a'
  alias lt='eza --tree --level=2 --icons=auto'
  alias ltr='eza --tree --icons=auto'
fi

if command -v rg >/dev/null 2>&1; then
  alias grep='rg --hidden --smart-case'
fi

if command -v dust >/dev/null 2>&1; then
  alias du='dust'
fi

# --- git aliases (enhanced with delta if available) ---
alias g='git'
alias ga='git add'
alias gb='git branch'
alias gco='git checkout'
alias gcom='git checkout main'
alias gc='git commit -m'
alias gca='git commit -am'
alias gs='git status'
alias gd='git diff'
alias gl='git log --oneline -10'
alias gp='git push'
alias gpl='git pull'
alias grm='git rm'

# --- zoxide aliases (if installed) ---
if command -v zoxide >/dev/null 2>&1; then
  alias z='__zoxide_z'
  alias zi='__zoxide_zi'
fi

# --- Utility aliases ---
alias mkdir='mkdir -p'
alias sudo='sudo '  # Enable alias expansion after sudo
alias top='btop || top'
alias ps='procs || ps'
alias ping='ping -c 5'
alias wget='wget -c'
alias df='df -h'
alias free='free -h'
alias update='sudo apt update && sudo apt upgrade'
alias search='rg --color=always'
alias clip='wl-copy 2>/dev/null || xclip -selection clipboard'

# --- Quick navigation ---
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias home='cd ~'
alias root='cd /'
alias desktop='cd ~/Desktop'
alias downloads='cd ~/Downloads'
alias documents='cd ~/Documents'

# --- Zsh configuration management ---
alias zsh-config='${EDITOR:-nvim} ~/.zshrc'
alias zsh-modules='ls -lh ~/.config/zsh/*.zsh'
alias zsh-reload='source ~/.zshrc && echo "✓ ZSH configuration reloaded"'
alias zsh-edit-aliases='${EDITOR:-nvim} ~/.config/zsh/aliases.zsh'
alias zsh-edit-functions='${EDITOR:-nvim} ~/.config/zsh/functions.zsh'

# ============================================================================
