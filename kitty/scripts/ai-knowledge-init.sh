#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# AI Agents Knowledge Base - Initialization
# ═══════════════════════════════════════════════════════════
# Initialize the knowledge management directory structure

set -euo pipefail

KB_ROOT="${AI_AGENTS_KB_ROOT:-$HOME/.ai-agents}"

echo "🧠 Initializing AI Agents Knowledge Base"
echo "Location: $KB_ROOT"
echo ""

# Create directory structure
mkdir -p "$KB_ROOT"/{knowledge,lessons,projects,sessions,snapshots}

# Knowledge base subdirectories
mkdir -p "$KB_ROOT"/knowledge/{docs,code-snippets,decisions,patterns}

# Create index files
cat > "$KB_ROOT/knowledge/README.md" <<'EOF'
# AI Agents Knowledge Base

## Structure

- `docs/` - Documentation and reference materials
- `code-snippets/` - Reusable code snippets with metadata
- `decisions/` - Architecture and design decisions (ADRs)
- `patterns/` - Common patterns and solutions

## Usage

Add knowledge:
```bash
ai-kb-add.sh docs "Topic" "Content"
ai-kb-add.sh snippet "Name" "Code" "Description"
```

Query knowledge:
```bash
ai-kb-search.sh "search term"
ai-kb-get.sh docs/topic-name.md
```

List all:
```bash
ai-kb-list.sh
```
EOF

cat > "$KB_ROOT/lessons/README.md" <<'EOF'
# Lessons Learned

Captured insights from AI agent collaboration sessions.

Each lesson includes:
- Timestamp
- Session ID
- Agents involved
- Problem/Challenge
- Solution/Insight
- Applicability

## Usage

```bash
ai-lesson-add.sh "Problem" "Solution" "Tags"
ai-lesson-search.sh "tag"
```
EOF

cat > "$KB_ROOT/projects/README.md" <<'EOF'
# Project Contexts

Project-specific information and context.

Each project can have:
- Goals and objectives
- Architecture notes
- Key decisions
- Dependencies
- Current status

## Usage

```bash
ai-project-create.sh "project-name"
ai-project-add.sh "project-name" "key" "value"
ai-project-get.sh "project-name"
```
EOF

cat > "$KB_ROOT/sessions/README.md" <<'EOF'
# Session History

Log of all AI agent collaboration sessions.

Each session record includes:
- Session ID
- Start/End time
- Agents used
- Tasks completed
- Messages exchanged
- Outcomes

## Usage

```bash
ai-session-list.sh
ai-session-show.sh <session-id>
```
EOF

cat > "$KB_ROOT/snapshots/README.md" <<'EOF'
# Session Snapshots

Saved states of AI agent sessions for restoration.

Each snapshot contains:
- Tmux pane layouts
- Agent states
- Communication history
- Knowledge base refs
- Project context

## Usage

```bash
ai-session-save.sh "snapshot-name"
ai-session-restore.sh "snapshot-name"
ai-session-list-snapshots.sh
```
EOF

# Create metadata file
cat > "$KB_ROOT/.metadata.json" <<EOF
{
  "version": "1.0.0",
  "created": "$(date -Iseconds)",
  "root": "$KB_ROOT",
  "components": {
    "knowledge_base": true,
    "lessons_learned": true,
    "project_contexts": true,
    "session_history": true,
    "session_snapshots": true
  }
}
EOF

echo "✅ Knowledge base initialized at: $KB_ROOT"
echo ""
echo "📁 Structure created:"
echo "  - knowledge/      (Shared knowledge base)"
echo "  - lessons/        (Lessons learned)"
echo "  - projects/       (Project contexts)"
echo "  - sessions/       (Session history)"
echo "  - snapshots/      (Session snapshots)"
echo ""
echo "🔧 Next steps:"
echo "  1. Add to ~/.bashrc or ~/.zshrc:"
echo "     export AI_AGENTS_KB_ROOT=\"$KB_ROOT\""
echo "  2. Use ai-kb-* commands to manage knowledge"
echo "  3. Use ai-session-* commands to manage sessions"
