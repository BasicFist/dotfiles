#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# AI Agents - List Session Snapshots
# ═══════════════════════════════════════════════════════════

set -euo pipefail

KB_ROOT="${AI_AGENTS_KB_ROOT:-$HOME/.ai-agents}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/colors.sh"

if [[ ! -d "$KB_ROOT/snapshots" ]]; then
    error_color "No snapshots found. Create one with: ai-session-save.sh <name>"
    exit 1
fi

info_color "📚 Available Session Snapshots"
echo "================================"
echo ""

COUNT=0
for SNAPSHOT_DIR in "$KB_ROOT"/snapshots/*/; do
    if [[ ! -d "$SNAPSHOT_DIR" ]]; then
        continue
    fi

    COUNT=$((COUNT + 1))
    SNAPSHOT_ID=$(basename "$SNAPSHOT_DIR")

    # Read metadata if available
    if [[ -f "$SNAPSHOT_DIR/metadata.json" ]]; then
        NAME=$(grep '"name"' "$SNAPSHOT_DIR/metadata.json" | cut -d'"' -f4)
        DESC=$(grep '"description"' "$SNAPSHOT_DIR/metadata.json" | cut -d'"' -f4)
        TIMESTAMP=$(grep '"timestamp"' "$SNAPSHOT_DIR/metadata.json" | cut -d'"' -f4)
    else
        NAME="$SNAPSHOT_ID"
        DESC="(no description)"
        TIMESTAMP="unknown"
    fi

    SIZE=$(du -sh "$SNAPSHOT_DIR" 2>/dev/null | cut -f1)

    echo -e "$(success_color "[$COUNT]") $(agent1_color "$NAME")"
    echo "    ID: $SNAPSHOT_ID"
    echo "    Created: $TIMESTAMP"
    echo "    Description: $DESC"
    echo "    Size: $SIZE"
    echo "    Restore: ai-session-restore.sh $SNAPSHOT_ID"
    echo ""
done

if [[ $COUNT -eq 0 ]]; then
    warning_color "No snapshots found."
    echo ""
    echo "Create a snapshot with:"
    echo "  ai-session-save.sh <snapshot-name> [description]"
else
    success_color "Total snapshots: $COUNT"
fi
