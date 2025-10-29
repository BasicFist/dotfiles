#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# AI Agents - Create Project Context
# ═══════════════════════════════════════════════════════════

set -euo pipefail

KB_ROOT="${AI_AGENTS_KB_ROOT:-$HOME/.ai-agents}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/colors.sh"

usage() {
    cat <<EOF
Usage: ai-project-create.sh <project-name> [description]

Arguments:
  project-name     Project identifier (will be slugified)
  description      Optional project description

Examples:
  ai-project-create.sh "web-app-refactor"
  ai-project-create.sh "bug-fix-auth" "Fix authentication module issues"
EOF
}

if [[ $# -lt 1 ]]; then
    usage
    exit 1
fi

PROJECT_NAME="$1"
DESCRIPTION="${2:-No description provided}"

# Create KB if not exists
if [[ ! -d "$KB_ROOT" ]]; then
    "${SCRIPT_DIR}/ai-knowledge-init.sh" >/dev/null
fi

# Slugify project name
SLUG=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')
PROJECT_DIR="$KB_ROOT/projects/$SLUG"

if [[ -d "$PROJECT_DIR" ]]; then
    warning_color "Project already exists: $SLUG"
    info_color "Use: ai-project-add.sh $SLUG <key> <value>"
    exit 1
fi

mkdir -p "$PROJECT_DIR"

# Create project metadata
cat > "$PROJECT_DIR/project.json" <<EOF
{
  "name": "$PROJECT_NAME",
  "slug": "$SLUG",
  "description": "$DESCRIPTION",
  "created": "$(date -Iseconds)",
  "status": "active",
  "context": {}
}
EOF

# Create project README
cat > "$PROJECT_DIR/README.md" <<EOF
# Project: $PROJECT_NAME

**Description**: $DESCRIPTION
**Created**: $(date)
**Status**: Active

## Goals

(Add project goals here)

## Architecture Notes

(Add architecture decisions and notes)

## Key Decisions

(Document important decisions)

## Dependencies

(List project dependencies)

## Current Status

(Track progress and current state)

## Commands

Add context:
\`\`\`bash
ai-project-add.sh $SLUG goals "Implement user authentication"
ai-project-add.sh $SLUG tech-stack "Python, FastAPI, PostgreSQL"
\`\`\`

View context:
\`\`\`bash
ai-project-get.sh $SLUG
\`\`\`
EOF

# Create context files
mkdir -p "$PROJECT_DIR"/{goals,decisions,architecture,notes}

success_color "✅ Project created: $SLUG"
info_color "   Location: $PROJECT_DIR"
echo ""
echo "Next steps:"
echo "  1. Add project context: ai-project-add.sh $SLUG <key> <value>"
echo "  2. View project: ai-project-get.sh $SLUG"

# Log to shared file
if [[ -f "/tmp/ai-agents-shared.txt" ]]; then
    echo -e "$(format_message INFO System "📁 Project created: $PROJECT_NAME")" >> /tmp/ai-agents-shared.txt
fi
