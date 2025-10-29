# Dual AI Agents Tmux - Complete Guide

**Purpose**: Run two AI agents simultaneously with shared communication capabilities
**Keybinding**: **Ctrl+Alt+Shift+X**
**Session Name**: `ai-agents`

---

## 🎯 Overview

This specialized tmux session creates an optimized layout for running two AI agents that can communicate through shared panes and files.

### Layout Design

```
┌─────────────────────────────────────┐
│  Agent 1 Input Terminal      (30%) │  ← Run Agent 1 (Claude Code, etc.)
├─────────────────────────────────────┤
│  Agent 2 Input Terminal      (30%) │  ← Run Agent 2 (Claude Code, etc.)
├─────────────────────────────────────┤
│  Shared Output / Communication (40%)│  ← Live tail of shared messages
└─────────────────────────────────────┘
```

---

## 🚀 Quick Start

### Launch the Session

**Method 1: Keyboard Shortcut**
```
Press: Ctrl+Alt+Shift+X
```

**Method 2: Direct Command**
```bash
~/.config/kitty/scripts/launch-ai-agents-tmux.sh
```

**Method 3: From Existing Kitty**
```bash
kitty @ launch --type=tab ~/.config/kitty/scripts/launch-ai-agents-tmux.sh
```

### First Time Setup

When the session launches, you'll see three panes:

1. **Agent 1 Pane** (Top) - Ready for first AI agent
2. **Agent 2 Pane** (Middle) - Ready for second AI agent
3. **Shared Output Pane** (Bottom) - Shows real-time communication

Each agent pane shows welcome messages with usage instructions.

---

## 💬 Communication Methods

### Method 1: Shared File (Automatic)

**Location**: `/tmp/ai-agents-shared.txt`

**From Agent 1**:
```bash
echo "Agent 1: Task completed successfully" > /tmp/ai-agents-shared.txt
```

**From Agent 2**:
```bash
# Read all messages
cat /tmp/ai-agents-shared.txt

# Or append your response
echo "Agent 2: Acknowledged, starting next task" >> /tmp/ai-agents-shared.txt
```

**Shared Pane**: Automatically displays with `tail -f /tmp/ai-agents-shared.txt`

### Method 2: Helper Scripts (Recommended)

#### Send Message with Timestamp

```bash
# Syntax
ai-agent-send.sh <agent-id> <message>

# Examples
ai-agent-send.sh Agent1 "Analysis complete: found 42 issues"
ai-agent-send.sh Agent2 "Reviewing code in src/main.py"
ai-agent-send.sh Coordinator "Both agents ready"
```

Output format: `[HH:MM:SS] [Agent-ID] Message`

#### Broadcast to Both Agents

```bash
# Syntax
ai-agent-broadcast.sh <message>

# Example
ai-agent-broadcast.sh "Starting new task: code review"
```

This sends the message to:
- Agent 1 terminal (as comment)
- Agent 2 terminal (as comment)
- Shared output pane (with timestamp)

---

## 🎮 Tmux Navigation

### Pane Navigation

| Command | Action |
|---------|--------|
| **Ctrl+B, ↑** | Move to pane above |
| **Ctrl+B, ↓** | Move to pane below |
| **Ctrl+B, ;** | Toggle last active pane |
| **Ctrl+B, O** | Rotate through panes |
| **Ctrl+B, Q** | Show pane numbers (type number to jump) |

### Session Management

| Command | Action |
|---------|--------|
| **Ctrl+B, D** | Detach from session (keeps running) |
| **Ctrl+B, $** | Rename session |
| **Ctrl+B, ?** | Show all keybindings |

### Scrollback Mode

| Command | Action |
|---------|--------|
| **Ctrl+B, [** | Enter scroll/copy mode |
| **↑/↓** | Scroll up/down |
| **Page Up/Down** | Scroll by page |
| **Q** | Exit scroll mode |

### Window Management

| Command | Action |
|---------|--------|
| **Ctrl+B, C** | Create new window in session |
| **Ctrl+B, N** | Next window |
| **Ctrl+B, P** | Previous window |
| **Ctrl+B, ,** | Rename current window |

---

## 🤖 Use Cases

### Use Case 1: Parallel Code Review

**Agent 1** - Reviews code structure and architecture
**Agent 2** - Reviews code quality and bug detection
**Shared Pane** - Aggregates findings from both

```bash
# In Agent 1 pane
cd ~/project
ai-agent-send.sh Architect "Analyzing project structure..."
# Run architecture analysis

# In Agent 2 pane
cd ~/project
ai-agent-send.sh QualityCheck "Running linters and bug detection..."
# Run quality checks

# Both agents post findings to shared pane
```

### Use Case 2: Research & Implementation

**Agent 1** - Researches best practices and solutions
**Agent 2** - Implements based on research findings
**Shared Pane** - Communication channel for questions/answers

```bash
# Agent 1 finds solution
ai-agent-send.sh Researcher "Found solution: use AsyncIO for concurrency"

# Agent 2 acknowledges and implements
ai-agent-send.sh Developer "Implementing AsyncIO solution in main.py"
```

### Use Case 3: Test-Driven Development

**Agent 1** - Writes tests
**Agent 2** - Implements code to pass tests
**Shared Pane** - Test results and status updates

```bash
# Agent 1
ai-agent-send.sh Tester "Writing test for user authentication..."

# Agent 2 waits for test
ai-agent-send.sh Developer "Waiting for test specification..."

# Agent 1 signals ready
ai-agent-send.sh Tester "Test ready: test_user_login()"

# Agent 2 implements
ai-agent-send.sh Developer "Implementing user_login() function..."
```

### Use Case 4: Multi-Language Translation

**Agent 1** - Translates documentation to Language A
**Agent 2** - Translates documentation to Language B
**Shared Pane** - Progress tracking

```bash
# Both agents report progress
ai-agent-send.sh FR-Translator "Completed: README.md → README.fr.md"
ai-agent-send.sh DE-Translator "Completed: README.md → README.de.md"
```

---

## 🔧 Advanced Configuration

### Custom Session Name

Set environment variable before launching:

```bash
export KITTY_AI_SESSION=my-custom-session
```

Then launch with **Ctrl+Alt+Shift+X** or script.

### Custom Shared File Location

Edit the script `/home/miko/.config/kitty/scripts/launch-ai-agents-tmux.sh`:

```bash
SHARED_FILE="/path/to/my/shared/file.txt"
```

### Adjust Pane Sizes

The default layout uses:
- Agent 1: 30%
- Agent 2: 30%
- Shared: 40%

To customize, edit the script and modify:

```bash
tmux resize-pane -t "$SESSION":0.0 -y 40%  # Increase Agent 1 to 40%
tmux resize-pane -t "$SESSION":0.1 -y 40%  # Increase Agent 2 to 40%
# Shared pane automatically takes remaining space (20%)
```

### Different Layouts

You can modify the layout in the script:

**Vertical Split (Side-by-Side)**:
```bash
# Replace in script:
tmux split-window -h -t "$SESSION":0 "$SHELL"  # Horizontal becomes -h
```

**Four Panes (Grid)**:
```bash
# Add after creating Agent 2:
tmux split-window -h -t "$SESSION":0.0 "$SHELL"  # Split Agent 1 horizontally
tmux split-window -h -t "$SESSION":0.1 "$SHELL"  # Split Agent 2 horizontally
tmux select-layout -t "$SESSION":0 tiled
```

---

## 📊 Monitoring & Debugging

### Check Session Status

```bash
# List all tmux sessions
tmux list-sessions

# Check if ai-agents session exists
tmux has-session -t ai-agents && echo "Running" || echo "Not running"

# List all panes in session
tmux list-panes -t ai-agents

# View session info
tmux display-message -p -t ai-agents
```

### View Shared Communication

From outside the session:

```bash
# Watch live updates
tail -f /tmp/ai-agents-shared.txt

# View all messages
cat /tmp/ai-agents-shared.txt

# Count messages
wc -l /tmp/ai-agents-shared.txt

# Search messages
grep "Agent1" /tmp/ai-agents-shared.txt
```

### Clear Shared Communication

```bash
# Clear the shared file
> /tmp/ai-agents-shared.txt

# Or from within session
echo "=== CLEARED AT $(date) ===" > /tmp/ai-agents-shared.txt
```

---

## 🛠️ Troubleshooting

### Issue: Session Already Exists

**Problem**: Script says session exists but you can't see it

**Solution**:
```bash
# List all sessions
tmux list-sessions

# Attach to existing session
tmux attach -t ai-agents

# Or kill and recreate
tmux kill-session -t ai-agents
# Then press Ctrl+Alt+Shift+X again
```

### Issue: Shared Pane Not Updating

**Problem**: Shared pane doesn't show new messages

**Solution**:
```bash
# The tail -f should be running in pane 2
# Check by switching to pane 2 (Ctrl+B, ↓ ↓)
# You should see: tail -f /tmp/ai-agents-shared.txt

# If not running, restart it:
tail -f /tmp/ai-agents-shared.txt
```

### Issue: Permission Denied on Shared File

**Problem**: Can't write to `/tmp/ai-agents-shared.txt`

**Solution**:
```bash
# Check permissions
ls -la /tmp/ai-agents-shared.txt

# Fix permissions
chmod 666 /tmp/ai-agents-shared.txt

# Or recreate the file
rm /tmp/ai-agents-shared.txt
touch /tmp/ai-agents-shared.txt
chmod 666 /tmp/ai-agents-shared.txt
```

### Issue: Helper Scripts Not Found

**Problem**: `ai-agent-send.sh` command not found

**Solution**:
```bash
# Add to PATH or use full path
~/.config/kitty/scripts/ai-agent-send.sh Agent1 "message"

# Or add to ~/.bashrc or ~/.zshrc:
export PATH="$PATH:$HOME/.config/kitty/scripts"
```

---

## 🎓 Best Practices

### 1. Clear Agent Identification

Always use clear agent IDs:

```bash
ai-agent-send.sh Frontend "Completed React component"
ai-agent-send.sh Backend "API endpoint ready"
ai-agent-send.sh Database "Schema migration applied"
```

### 2. Use Timestamps for Context

The helper scripts automatically add timestamps. Use them to track progress:

```bash
[14:32:15] [Agent1] Starting task A
[14:35:42] [Agent2] Starting task B
[14:40:18] [Agent1] Task A complete
[14:42:05] [Agent2] Task B complete
```

### 3. Coordinate Dependencies

Use shared communication to coordinate:

```bash
# Agent 1 signals completion
ai-agent-send.sh Agent1 "READY: database schema created"

# Agent 2 waits and acknowledges
ai-agent-send.sh Agent2 "ACK: starting data import"
```

### 4. Regular Status Updates

Post regular progress updates:

```bash
ai-agent-send.sh Agent1 "Progress: 45% (23/51 files processed)"
ai-agent-send.sh Agent2 "Progress: 78% (156/200 tests passed)"
```

### 5. Error Reporting

Use clear error markers:

```bash
ai-agent-send.sh Agent1 "ERROR: Missing dependency 'requests'"
ai-agent-send.sh Agent2 "WARNING: Found 3 security vulnerabilities"
```

---

## 🔗 Integration with Claude Code

### Running Claude Code in Both Agents

**Agent 1 Pane**:
```bash
cd ~/project1
claude  # Start Claude Code
```

**Agent 2 Pane**:
```bash
cd ~/project2
claude  # Start Claude Code
```

Both Claude Code instances can communicate via the shared file!

### Example Workflow

**Scenario**: Two Claude Code agents collaborating on a project

**Agent 1** (in pane 1):
```bash
claude
# User prompt: "Analyze the backend architecture and document findings"
# Claude posts to shared: ai-agent-send.sh Backend "Found 5 API endpoints..."
```

**Agent 2** (in pane 2):
```bash
claude
# User prompt: "Review the frontend code and check API integration"
# Claude reads shared file: cat /tmp/ai-agents-shared.txt
# Claude posts: ai-agent-send.sh Frontend "All endpoints properly integrated"
```

---

## 📚 Related Documentation

- **Tmux Documentation**: https://github.com/tmux/tmux/wiki
- **Kitty Remote Control**: `docs/OFFICIAL-KITTY-GUIDELINES.md`
- **Shared Tmux Session**: `Ctrl+Alt+X` (simpler 2-pane version)
- **Agent Terminal**: `Ctrl+Alt+A` (single overlay agent)

---

## 🎯 Quick Reference Card

### Essential Commands

| Task | Command |
|------|---------|
| **Launch session** | `Ctrl+Alt+Shift+X` |
| **Send message** | `ai-agent-send.sh AgentX "msg"` |
| **Broadcast** | `ai-agent-broadcast.sh "msg"` |
| **Switch panes** | `Ctrl+B, Arrow Keys` |
| **Detach session** | `Ctrl+B, D` |
| **Scroll mode** | `Ctrl+B, [` (q to exit) |
| **View shared file** | `cat /tmp/ai-agents-shared.txt` |
| **Clear shared file** | `> /tmp/ai-agents-shared.txt` |

### File Locations

| File | Path |
|------|------|
| **Launcher Script** | `~/.config/kitty/scripts/launch-ai-agents-tmux.sh` |
| **Send Helper** | `~/.config/kitty/scripts/ai-agent-send.sh` |
| **Broadcast Helper** | `~/.config/kitty/scripts/ai-agent-broadcast.sh` |
| **Shared File** | `/tmp/ai-agents-shared.txt` |

---

**Created**: 2025-10-29
**Last Updated**: 2025-10-29
**Maintainer**: LAB Repository
