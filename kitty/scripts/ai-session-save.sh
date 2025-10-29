#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# AI Agents - Save Session Snapshot
# ═══════════════════════════════════════════════════════════

set -euo pipefail

KB_ROOT="${AI_AGENTS_KB_ROOT:-$HOME/.ai-agents}"
SESSION=${KITTY_AI_SESSION:-ai-agents}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/colors.sh"

usage() {
    cat <<EOF
Usage: ai-session-save.sh <snapshot-name> [description]

Arguments:
  snapshot-name    Name for the snapshot (will be slugified)
  description      Optional description

Examples:
  ai-session-save.sh "code-review-progress"
  ai-session-save.sh "bug-fix-session" "Before implementing fix"
EOF
}

if [[ $# -lt 1 ]]; then
    usage
    exit 1
fi

SNAPSHOT_NAME="$1"
DESCRIPTION="${2:-No description provided}"

# Create KB if not exists
if [[ ! -d "$KB_ROOT" ]]; then
    "${SCRIPT_DIR}/ai-knowledge-init.sh" >/dev/null
fi

# Slugify name
SLUG=$(echo "$SNAPSHOT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SNAPSHOT_ID="${SLUG}_${TIMESTAMP}"
SNAPSHOT_DIR="$KB_ROOT/snapshots/$SNAPSHOT_ID"

mkdir -p "$SNAPSHOT_DIR"

info_color "💾 Saving session snapshot: $SNAPSHOT_ID"

# Save tmux session state if exists
if tmux has-session -t "$SESSION" 2>/dev/null; then
    # Capture tmux layout
    tmux list-panes -t "$SESSION" -F "#{pane_index}:#{pane_current_command}:#{pane_current_path}:#{pane_width}x#{pane_height}" > "$SNAPSHOT_DIR/tmux_layout.txt"

    # Capture pane contents
    for pane in 0 1 2; do
        tmux capture-pane -t "$SESSION:0.$pane" -p > "$SNAPSHOT_DIR/pane_${pane}_content.txt" 2>/dev/null || true
    done

    success_color "  ✓ Saved tmux session state"
else
    warning_color "  ! Tmux session not running"
fi

# Save communication history
if [[ -f "/tmp/ai-agents-shared.txt" ]]; then
    cp /tmp/ai-agents-shared.txt "$SNAPSHOT_DIR/communication.txt"
    success_color "  ✓ Saved communication history"
fi

if [[ -f "/tmp/ai-agents-shared.txt.log" ]]; then
    cp /tmp/ai-agents-shared.txt.log "$SNAPSHOT_DIR/communication.log"
    success_color "  ✓ Saved structured log"
fi

# Create metadata
cat > "$SNAPSHOT_DIR/metadata.json" <<EOF
{
  "snapshot_id": "$SNAPSHOT_ID",
  "name": "$SNAPSHOT_NAME",
  "description": "$DESCRIPTION",
  "timestamp": "$(date -Iseconds)",
  "session": "$SESSION",
  "tmux_running": $(tmux has-session -t "$SESSION" 2>/dev/null && echo "true" || echo "false"),
  "kb_root": "$KB_ROOT"
}
EOF

# Create README
cat > "$SNAPSHOT_DIR/README.md" <<EOF
# Session Snapshot: $SNAPSHOT_NAME

**ID**: $SNAPSHOT_ID
**Created**: $(date)
**Description**: $DESCRIPTION

## Contents

- \`tmux_layout.txt\` - Tmux pane layout configuration
- \`pane_*_content.txt\` - Captured content from each pane
- \`communication.txt\` - Agent communication history
- \`communication.log\` - Structured message log
- \`metadata.json\` - Snapshot metadata

## Restore

\`\`\`bash
ai-session-restore.sh "$SNAPSHOT_ID"
\`\`\`

## Files

\`\`\`
$(ls -lh "$SNAPSHOT_DIR" | tail -n +2)
\`\`\`
EOF

success_color "✅ Snapshot saved: $SNAPSHOT_ID"
info_color "   Location: $SNAPSHOT_DIR"
info_color "   Size: $(du -sh "$SNAPSHOT_DIR" | cut -f1)"
echo ""
echo "Restore with: ai-session-restore.sh $SNAPSHOT_ID"

# Log to shared file
if [[ -f "/tmp/ai-agents-shared.txt" ]]; then
    echo -e "$(format_message INFO System "💾 Session snapshot saved: $SNAPSHOT_ID")" >> /tmp/ai-agents-shared.txt
fi
