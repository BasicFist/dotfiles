#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Config Sync Utility
# ═══════════════════════════════════════════════════════════
# Syncs between the version-controlled kitty directory and the
# live configuration under ~/.config/kitty.
#
# Usage:
#   sync.sh pull     # Live → repo
#   sync.sh push     # Repo → live
#   sync.sh status   # Dry-run preview in both directions

set -euo pipefail

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_DIR="$SCRIPT_ROOT"
LIVE_DIR="${KITTY_LIVE_DIR:-$HOME/.config/kitty}"

usage() {
    cat <<'EOF'
Config Sync Utility

Usage:
  sync.sh pull        # Copy live config into the repo (Live → Repo)
  sync.sh push        # Copy repo contents into the live config (Repo → Live)
  sync.sh status      # Show dry-run previews of push & pull operations

Environment:
  KITTY_LIVE_DIR   Override the live kitty config path (default: ~/.config/kitty)
  DRY_RUN=1        Preview rsync operations without copying

Both directions use rsync with --delete to keep directories aligned.
Key runtime artefacts such as wallpapers/, *.backup-*, and Serena metadata are excluded.
EOF
}

require_rsync() {
    if ! command -v rsync >/dev/null 2>&1; then
        echo "❌ rsync not found. Install rsync to continue." >&2
        exit 1
    fi
}

build_rsync_flags() {
    local -n ref=$1
    ref=(-avh --delete)
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        ref+=("--dry-run")
    fi

    local excludes=(
        ".git/"
        ".serena/"
        "Backups/"
        "*.backup-*"
        "*.dotfiles-backup-*"
        "*.glitch-backup-*"
        "wallpapers/generated/"
        "wallpapers/tmp/"
        "session-*"
        "*.tmp"
    )

    for pattern in "${excludes[@]}"; do
        ref+=("--exclude" "$pattern")
    done
}

sync_pull() {
    if [[ ! -d "$LIVE_DIR" ]]; then
        echo "❌ Live kitty directory not found: $LIVE_DIR" >&2
        exit 1
    fi

    mkdir -p "$REPO_DIR"

    local flags=()
    build_rsync_flags flags

    echo "📥 Syncing $LIVE_DIR → $REPO_DIR"
    rsync "${flags[@]}" "$LIVE_DIR"/ "$REPO_DIR"/
    echo "✅ Repo updated from live configuration."
}

sync_push() {
    if [[ ! -d "$REPO_DIR" ]]; then
        echo "❌ Repo kitty directory not found: $REPO_DIR" >&2
        exit 1
    fi

    mkdir -p "$LIVE_DIR"

    local flags=()
    build_rsync_flags flags

    echo "📤 Syncing $REPO_DIR → $LIVE_DIR"
    rsync "${flags[@]}" "$REPO_DIR"/ "$LIVE_DIR"/
    echo "✅ Live configuration updated from repo."
}

sync_status() {
    if [[ ! -d "$REPO_DIR" ]]; then
        echo "❌ Repo kitty directory not found: $REPO_DIR" >&2
        exit 1
    fi
    if [[ ! -d "$LIVE_DIR" ]]; then
        echo "❌ Live kitty directory not found: $LIVE_DIR" >&2
        exit 1
    fi

    local prev_dry="${DRY_RUN:-}"
    local flags=()
    DRY_RUN=1
    build_rsync_flags flags
    if [[ -z "$prev_dry" ]]; then
        unset DRY_RUN
    else
        DRY_RUN="$prev_dry"
    fi
    flags+=("--itemize-changes")

    echo "📊 Preview Repo → Live (push)"
    rsync "${flags[@]}" "$REPO_DIR"/ "$LIVE_DIR"/
    echo ""
    echo "📊 Preview Live → Repo (pull)"
    rsync "${flags[@]}" "$LIVE_DIR"/ "$REPO_DIR"/
    echo "ℹ️  Use DRY_RUN=1 with pull/push for single-direction previews."
}

main() {
    if [[ $# -lt 1 ]]; then
        usage
        exit 1
    fi

    require_rsync

    case "$1" in
        pull)
            sync_pull
            ;;
        push)
            sync_push
            ;;
        status)
            sync_status
            ;;
        -h|--help|help)
            usage
            ;;
        *)
            echo "Unknown command: $1" >&2
            usage
            exit 1
            ;;
    esac
}

main "$@"
