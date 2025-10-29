#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# AI Agents Knowledge Base - Add Entry
# ═══════════════════════════════════════════════════════════

set -euo pipefail

KB_ROOT="${AI_AGENTS_KB_ROOT:-$HOME/.ai-agents}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/colors.sh"

usage() {
    cat <<EOF
Usage: ai-kb-add.sh <type> <name> <content> [tags]

Types:
  doc          Documentation entry
  snippet      Code snippet
  decision     Architecture/design decision
  pattern      Common pattern or solution

Arguments:
  name         Entry name (will be slugified)
  content      Content (file path or string)
  tags         Optional comma-separated tags

Examples:
  ai-kb-add.sh doc "Python Best Practices" ./best-practices.md python,coding
  ai-kb-add.sh snippet "async-retry" "async def retry()..." python,async
  ai-kb-add.sh decision "Use PostgreSQL" "We chose PostgreSQL because..." database
  ai-kb-add.sh pattern "Singleton" "Implementation pattern..." design-patterns
EOF
}

if [[ $# -lt 3 ]]; then
    usage
    exit 1
fi

TYPE="$1"
NAME="$2"
CONTENT="$3"
TAGS="${4:-}"

# Validate type
case "$TYPE" in
    doc|docs|documentation)
        TYPE_DIR="docs"
        TYPE_EXT=".md"
        ;;
    snippet|code)
        TYPE_DIR="code-snippets"
        TYPE_EXT=".txt"
        ;;
    decision|adr)
        TYPE_DIR="decisions"
        TYPE_EXT=".md"
        ;;
    pattern|patterns)
        TYPE_DIR="patterns"
        TYPE_EXT=".md"
        ;;
    *)
        error_color "Unknown type: $TYPE"
        usage
        exit 1
        ;;
esac

# Create KB if not exists
if [[ ! -d "$KB_ROOT" ]]; then
    info_color "Knowledge base not initialized. Initializing now..."
    "${SCRIPT_DIR}/ai-knowledge-init.sh"
fi

# Slugify name
SLUG=$(echo "$NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')
FILENAME="${SLUG}${TYPE_EXT}"
FILEPATH="$KB_ROOT/knowledge/$TYPE_DIR/$FILENAME"

# Get content
if [[ -f "$CONTENT" ]]; then
    CONTENT_TEXT=$(cat "$CONTENT")
else
    CONTENT_TEXT="$CONTENT"
fi

# Create entry with metadata
cat > "$FILEPATH" <<EOF
---
title: $NAME
type: $TYPE
created: $(date -Iseconds)
tags: $TAGS
---

$CONTENT_TEXT
EOF

success_color "✅ Added to knowledge base: $TYPE_DIR/$FILENAME"

# Update index
INDEX_FILE="$KB_ROOT/knowledge/.index.txt"
echo "$(date -Iseconds)|$TYPE|$SLUG|$NAME|$TAGS" >> "$INDEX_FILE"

# Log to shared file if in session
if [[ -f "/tmp/ai-agents-shared.txt" ]]; then
    echo -e "$(date '+[%H:%M:%S]') 📚 Knowledge Base: Added $TYPE '$NAME' (tags: $TAGS)" >> /tmp/ai-agents-shared.txt
fi
