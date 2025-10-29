# ============================================================================
# functions.zsh - Utility functions for productivity
# ============================================================================

# --- Directory management ---
# Create directory and cd into it
mkcd() {
  [[ -z "$1" ]] && { echo "Usage: mkcd <dir>" >&2; return 1; }
  mkdir -p -- "$1" && cd -- "$1"
}

# Copy with auto-mkdir
mkcp() {
  [[ -z "$2" ]] && { echo "Usage: mkcp <source> <dest>" >&2; return 1; }
  mkdir -p "$(dirname "$2")" && cp -r -- "$1" "$2"
}

# Move with auto-mkdir
mkmv() {
  [[ -z "$2" ]] && { echo "Usage: mkmv <source> <dest>" >&2; return 1; }
  mkdir -p "$(dirname "$2")" && mv -- "$1" "$2"
}

# FZF directory navigation
cdf() {
  if ! command -v fd >/dev/null 2>&1; then
    echo "fd not installed. Install: sudo apt install fd-find" >&2
    return 1
  fi
  local dir
  dir=$(fd -t d . 2>/dev/null | fzf --prompt 'cd> ') || return
  cd "$dir"
}

# --- File operations ---
# Universal archive extractor with validation
extract() {
  if [[ -z "$1" ]]; then
    echo "Usage: extract <archive>" >&2
    return 1
  fi

  if [[ ! -f "$1" ]]; then
    echo "Error: File '$1' not found" >&2
    return 1
  fi

  case "$1" in
    *.tar.gz|*.tgz) tar xzf "$1" ;;
    *.tar.bz2|*.tbz2) tar xjf "$1" ;;
    *.tar.xz|*.txz) tar xJf "$1" ;;
    *.tar) tar xf "$1" ;;
    *.zip) unzip "$1" ;;
    *.rar) unrar x "$1" 2>/dev/null || { echo "unrar not installed" >&2; return 1; } ;;
    *.7z) 7z x "$1" 2>/dev/null || { echo "7z not installed" >&2; return 1; } ;;
    *.gz) gunzip "$1" ;;
    *.bz2) bunzip2 "$1" ;;
    *.xz) unxz "$1" ;;
    *) echo "Unknown archive format: $1" >&2; return 1 ;;
  esac

  if [[ $? -eq 0 ]]; then
    echo "✓ Extracted: $1"
  else
    echo "✗ Extraction failed: $1" >&2
    return 1
  fi
}

# FZF file search and preview
ff() {
  if ! command -v fd >/dev/null 2>&1; then
    echo "fd not installed. Install: sudo apt install fd-find" >&2
    return 1
  fi
  local f
  f=$(fd . 2>/dev/null | fzf --preview 'batcat --color=always --style=numbers --line-range=:500 {} 2>/dev/null || cat {}') || return
  ${EDITOR:-nvim} -- "$f"
}

# FZF history search
fh() {
  local cmd
  cmd=$(fc -l 1 | sed 's/^ *[0-9]* *//' | fzf --prompt 'hist> ' --tac) || return
  print -z -- "$cmd"
}

# Find process and kill (with confirmation)
fkill() {
  local pid process_info
  process_info=$(ps aux | fzf --prompt 'kill> ') || return
  pid=$(echo "$process_info" | awk '{print $2}')

  if [[ -n "$pid" ]]; then
    echo "About to kill: $(echo "$process_info" | awk '{for(i=11;i<=NF;i++) printf $i" "; print ""}')"
    echo -n "Confirm kill PID $pid? [y/N] "
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
      # Try graceful SIGTERM first, then SIGKILL if needed
      if kill "$pid" 2>/dev/null; then
        echo "Sent SIGTERM to PID $pid"
      else
        kill -9 "$pid" 2>/dev/null && echo "Sent SIGKILL to PID $pid"
      fi
    else
      echo "Cancelled."
    fi
  fi
}

# --- Git utilities ---
# Smart git clone with organized directory
gcl() {
  if [[ -z "$1" ]]; then
    echo "Usage: gcl <repo-url> [directory]" >&2
    return 1
  fi

  local repo="$1" dir="${2:-.}"

  # Validate URL format (support https, git, ssh, and git@ protocols)
  if [[ ! "$repo" =~ ^(https?://|git://|ssh://|git@) ]]; then
    echo "Error: Invalid repository URL format" >&2
    echo "Supported formats: https://, git://, ssh://, git@" >&2
    return 1
  fi

  local name="${repo##*/}"
  name="${name%.git}"
  git clone "$repo" "$dir/$name" && cd "$dir/$name"
}

# Git log with graph
glog() {
  git log --graph --oneline --all --decorate "${@:-}" | head -20
}

# Show git status with colors
gst() {
  git status --short | awk '{
    if ($1 ~ /A/) print "\033[32m" $0 "\033[0m"  # Green for added
    else if ($1 ~ /M/) print "\033[33m" $0 "\033[0m"  # Yellow for modified
    else if ($1 ~ /D/) print "\033[31m" $0 "\033[0m"  # Red for deleted
    else print $0
  }'
}

# --- System utilities ---
# Quick weather lookup with timeout and validation
weather() {
  if ! command -v curl >/dev/null 2>&1; then
    echo "curl not found" >&2
    return 1
  fi

  local location="${1:-}"
  # Basic input sanitization - allow only alphanumeric, spaces, commas, and hyphens
  if [[ -n "$location" && ! "$location" =~ ^[a-zA-Z0-9\ ,\-]+$ ]]; then
    echo "Invalid location format. Use only letters, numbers, spaces, commas, and hyphens." >&2
    return 1
  fi

  # Use HTTPS and add timeout
  curl --max-time 5 -sf "https://wttr.in/${location}?format=3" || {
    echo "Failed to fetch weather data. Check your connection or location." >&2
    return 1
  }
}

# Process search (renamed to avoid shadowing /usr/bin/pgrep)
psgrep() {
  if [[ -z "$1" ]]; then
    echo "Usage: psgrep <pattern>" >&2
    return 1
  fi
  ps aux | /usr/bin/grep -E "$1" | grep -v grep
}

# Disk usage summary with error handling
dusort() {
  if ! command -v sort >/dev/null 2>&1; then
    echo "sort command not found" >&2
    return 1
  fi

  local target_dir="${1:-.}"
  if [[ ! -d "$target_dir" ]]; then
    echo "Error: Directory '$target_dir' not found" >&2
    return 1
  fi

  du -sh "$target_dir"/*/ "$target_dir"/.* 2>/dev/null | sort -h | tail -20
}

# Find large files with validation
bigfiles() {
  if ! command -v find >/dev/null 2>&1; then
    echo "find command not found" >&2
    return 1
  fi

  local search_path="${1:-.}"
  if [[ ! -d "$search_path" ]]; then
    echo "Error: Directory '$search_path' not found" >&2
    return 1
  fi

  echo "Searching for large files in: $search_path"
  find "$search_path" -type f -printf '%s %p\n' 2>/dev/null | sort -rn | head -20 | awk '
    {
      size=$1/1024/1024
      printf "%.1fM %s\n", size, substr($0, index($0, $2))
    }'
}

# ============================================================================
