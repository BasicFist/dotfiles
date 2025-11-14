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
SNAPSHOT_DIR="${KITTY_SYNC_SNAPSHOT_DIR:-$HOME/.local/share/kitty-sync-snapshots}"

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
  SYNC_ASSUME_YES  Skip confirmation prompts (set to 1)
  KITTY_SYNC_SKIP_SNAPSHOT  Skip automatic tar snapshots (set to 1)
  KITTY_SYNC_SNAPSHOT_DIR   Override snapshot destination directory

Both directions use rsync with --delete to keep directories aligned.
Before destructive syncs, the tool now asks for confirmation and creates
tarball snapshots so you can roll back accidental deletions quickly.
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

confirm_destructive() {
    local direction="$1"
    local source="$2"
    local target="$3"

    if [[ "${DRY_RUN:-0}" == "1" || "${SYNC_ASSUME_YES:-0}" == "1" ]]; then
        return
    fi

    echo "⚠️  $direction will mirror $source → $target using --delete."
    read -r -p "Proceed? [y/N] " answer
    if [[ ! "$answer" =~ ^[Yy]$ ]]; then
        echo "Aborted by user"
        exit 1
    fi
}

create_snapshot() {
    local target="$1"
    local label="$2"

    if [[ "${DRY_RUN:-0}" == "1" || "${KITTY_SYNC_SKIP_SNAPSHOT:-0}" == "1" ]]; then
        return
    fi

    if ! command -v tar >/dev/null 2>&1; then
        echo "⚠️  Snapshot skipped (tar unavailable)"
        return
    fi

    if [[ ! -d "$target" ]]; then
        echo "⚠️  Snapshot skipped (missing $target)"
        return
    fi

    mkdir -p "$SNAPSHOT_DIR"
    local timestamp
    timestamp=$(date +%Y%m%d-%H%M%S)
    local archive="$SNAPSHOT_DIR/${label}-${timestamp}.tar.gz"

    echo "🗂  Creating snapshot: $archive"
    if tar -czf "$archive" -C "$target" . >/dev/null 2>&1; then
        echo "   Snapshot ready"
    else
        echo "   ⚠️  Snapshot failed"
    fi
}

sync_pull() {
    if [[ ! -d "$LIVE_DIR" ]]; then
        echo "❌ Live kitty directory not found: $LIVE_DIR" >&2
        exit 1
    fi

    mkdir -p "$REPO_DIR"

    local flags=()
    build_rsync_flags flags

    confirm_destructive "pull" "$LIVE_DIR" "$REPO_DIR"
    create_snapshot "$REPO_DIR" "repo-before-pull"

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

    confirm_destructive "push" "$REPO_DIR" "$LIVE_DIR"
    create_snapshot "$LIVE_DIR" "live-before-push"

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
