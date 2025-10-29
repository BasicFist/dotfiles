# AI Agents Management TUI Guide

**Interactive terminal interface for managing AI agent collaboration**

## Quick Start

### Launch TUI

**Keyboard Shortcut:**
```
Ctrl+Alt+M
```

**Command Line:**
```bash
~/.config/kitty/scripts/ai-agents-tui.sh
```

The TUI will launch in an overlay window on top of your current terminal.

---

## Main Menu

### 1. 🚀 Start Collaboration Mode

Launch any of the 5 collaboration modes with guided prompts:

**Pair Programming:**
- Prompts: Driver agent, Navigator agent
- Starts pair programming mode with driver/navigator roles
- Auto-launches with color-coded panes

**Debate:**
- Prompt: Debate topic
- Starts structured 4-round debate
- Agents discuss and reach consensus

**Teaching:**
- Prompts: Expert agent, Learner agent, Topic
- Expert teaches learner the specified topic
- Tracks mastery level (0-100%)

**Consensus:**
- Prompt: Decision topic
- Both agents must agree before proceeding
- Multi-phase consensus building

**Competition:**
- Prompts: Challenge, Time limit (minutes)
- Agents compete to solve challenge
- Judged on 4 criteria (100 points total)

### 2. 💾 Session Management

**View Current Mode Status:**
- Shows active collaboration mode
- Displays mode-specific stats (driver/navigator, votes, scores, etc.)
- Real-time state information

**Save Current Session:**
- Prompts: Session name, Description
- Saves complete tmux session state
- Includes pane contents, mode state, communication history
- Stored in `~/.ai-agents/snapshots/`

**List Saved Sessions:**
- Browse all saved sessions
- Shows name and description
- Select to view details

**Session History:**
- View chronological session list
- Shows timestamps and metadata

### 3. 📚 Knowledge Base

**Add KB Entry:**
- Choose type: Documentation, Code Snippet, Decision, Pattern
- Enter: Title, Content, Tags
- Stored in organized KB structure

**Search Knowledge Base:**
- Enter search query
- Searches across all KB entries
- Shows matching results with context

**Add Lesson Learned:**
- Enter: Problem/Challenge, Solution/Learning, Tags
- Creates structured lesson record
- Builds institutional knowledge

### 4. ⚡ Quick Actions

**Launch Tmux Session:**
- Confirms then launches AI Agents tmux
- Opens full 3-pane layout
- Ready for agent collaboration

**System Status:**
- Shows tmux session status
- Active collaboration mode
- Knowledge base statistics
- Saved session count

**Help & Documentation:**
- Quick reference guide
- Keyboard shortcuts
- Usage tips

---

## Navigation

### Keyboard Controls

| Key | Action |
|-----|--------|
| **Arrow Keys** | Navigate menu items |
| **Enter** | Select highlighted option |
| **Esc / Cancel** | Go back / Exit dialog |
| **Tab** | Switch between form fields |
| **Space** | Toggle checkboxes (if any) |

### Menu Flow

```
Main Menu
├── Start Collaboration Mode
│   ├── Pair Programming → [prompts] → Launch
│   ├── Debate → [prompts] → Launch
│   ├── Teaching → [prompts] → Launch
│   ├── Consensus → [prompts] → Launch
│   └── Competition → [prompts] → Launch
├── Session Management
│   ├── View Current Mode → Display Status
│   ├── Save Session → [prompts] → Save
│   ├── List Sessions → [select] → View Details
│   └── Session History → Display List
├── Knowledge Base
│   ├── Add Entry → [type selection] → [prompts] → Save
│   ├── Search → [query] → Results
│   └── Add Lesson → [prompts] → Save
└── Quick Actions
    ├── Launch Tmux → Confirm → Launch
    ├── System Status → Display Info
    └── Help → Show Guide
```

---

## Features

### Guided Setup

All mode launches include guided prompts:
- Clear field labels
- Default values suggested
- Validation before launch
- Success confirmation messages

### Error Handling

The TUI provides helpful error messages:
- Empty required fields
- Invalid input
- Missing dependencies (dialog/whiptail)
- Mode conflicts

### Visual Feedback

- **Success messages:** Green checkmarks, clear confirmations
- **Error messages:** Red X, helpful suggestions
- **Info boxes:** Context and explanations
- **Status displays:** Real-time mode state

### Integration

The TUI seamlessly integrates with:
- All 5 collaboration modes
- 25 helper command scripts
- Knowledge base system
- Session snapshot functionality
- Tmux session management

---

## Requirements

### System Dependencies

The TUI requires ONE of:
- `dialog` (recommended) - Full-featured TUI
- `whiptail` (fallback) - Lighter alternative

**Install on Ubuntu/Debian:**
```bash
sudo apt install dialog
# or
sudo apt install whiptail
```

**Check installed:**
```bash
command -v dialog && echo "✅ dialog available"
command -v whiptail && echo "✅ whiptail available"
```

### First-Time Setup

On first launch, TUI will offer to initialize knowledge base:
- Creates `~/.ai-agents/` directory structure
- Sets up docs, snippets, decisions, patterns folders
- Prepares lessons and sessions directories

---

## Examples

### Example 1: Start Pair Programming

1. Launch TUI: `Ctrl+Alt+M`
2. Select: `1 - Start Collaboration Mode`
3. Select: `1 - Pair Programming`
4. Enter driver: `Agent1` (or accept default)
5. Enter navigator: `Agent2` (or accept default)
6. Press OK → Mode starts!
7. See success message with summary
8. TUI closes, tmux pane shows pair programming protocol

### Example 2: Save a Session

1. Launch TUI: `Ctrl+Alt+M`
2. Select: `2 - Session Management`
3. Select: `2 - Save Current Session`
4. Enter name: `oauth-implementation`
5. Enter description: `Completed OAuth2 flow with error handling`
6. Press OK → Session saved!
7. See confirmation with save location

### Example 3: Add Knowledge

1. Launch TUI: `Ctrl+Alt+M`
2. Select: `3 - Knowledge Base`
3. Select: `1 - Add KB Entry`
4. Select type: `1 - Documentation`
5. Enter title: `Python Async Best Practices`
6. Enter content: `Always use asyncio.create_task() for...`
7. Enter tags: `python,async,best-practices`
8. Press OK → KB entry saved!

### Example 4: Start Competition

1. Launch TUI: `Ctrl+Alt+M`
2. Select: `1 - Start Collaboration Mode`
3. Select: `5 - Competition`
4. Enter challenge: `Implement LRU cache with O(1) operations`
5. Enter time limit: `30` (minutes)
6. Press OK → Competition starts!
7. Timer begins, agents start planning phase

---

## Troubleshooting

### TUI doesn't launch

**Error:** "Neither dialog nor whiptail found!"

**Solution:**
```bash
sudo apt install dialog
# or
sudo apt install whiptail
```

### Empty menus or missing options

**Cause:** Scripts not executable or missing

**Solution:**
```bash
cd ~/LAB/lab/dotfiles/kitty
chmod +x scripts/*.sh
chmod +x scripts/modes/*.sh
rsync -av scripts/ ~/.config/kitty/scripts/
```

### KB initialization fails

**Cause:** Permissions or disk space

**Solution:**
```bash
# Check permissions
ls -la ~/.ai-agents/

# Check disk space
df -h ~

# Manual initialization
~/.config/kitty/scripts/ai-knowledge-init.sh
```

### Mode doesn't start

**Cause:** Missing mode script or tmux session

**Solution:**
```bash
# Verify scripts
~/.config/kitty/scripts/verify-modes.sh

# Check tmux
tmux has-session -t ai-agents 2>/dev/null && echo "Running" || echo "Not running"

# Launch tmux first
~/.config/kitty/scripts/launch-ai-agents-tmux.sh
```

---

## Tips & Best Practices

### 1. Use TUI for Complex Setups

TUI is perfect for:
- First-time users learning the system
- Modes requiring multiple parameters (teaching, competition)
- Browsing sessions and knowledge base
- Quick status checks

### 2. Switch to CLI for Speed

Once comfortable, use direct commands:
```bash
# Fast mode start
ai-mode-start.sh pair

# Quick save
ai-session-save.sh "quick-save" "Work in progress"

# Direct KB add
ai-kb-add.sh doc "Title" "Content" "tags"
```

### 3. Combine TUI and CLI

Use TUI for:
- Starting modes (guided prompts)
- Browsing KB and sessions
- System status checks

Use CLI for:
- In-mode helper commands (ai-pair-switch.sh, etc.)
- Quick KB searches
- Rapid lesson adds

### 4. Keyboard Shortcuts

Memorize key combos:
- `Ctrl+Alt+M` - Launch TUI (fast access)
- `Ctrl+Alt+Shift+X` - Direct tmux launch (skip TUI)
- `F12` - Shortcuts menu (see all keybindings)

### 5. Save Frequently

Use TUI's session save after:
- Completing a collaboration mode
- Reaching consensus or winner
- Teaching sessions at 100% mastery
- Any significant work

---

## Advanced Usage

### Custom Session Names

Use descriptive names with dates:
```
pair-auth-20251029
debate-architecture-api
teach-python-async-20251029
consensus-database-choice
compete-sorting-algorithms
```

### Tagging Strategy

For KB entries and lessons:
- **Language tags:** python, javascript, rust
- **Domain tags:** async, database, api, security
- **Type tags:** best-practice, gotcha, optimization
- **Project tags:** auth-service, analytics, ui

### Workflow Integration

**Daily workflow:**
1. Launch TUI → Check system status
2. Start appropriate mode for task
3. Work in mode (using helper commands)
4. Save session before switching
5. Add lessons learned at end of day

**Review workflow:**
1. Launch TUI → List saved sessions
2. Browse sessions by date/topic
3. Extract patterns → Add to KB
4. Create summary lessons

---

## Related Documentation

- **Collaboration Modes:** `COLLABORATION-MODES.md` - Full mode reference
- **AI Agents Guide:** `AI-AGENTS-TMUX-GUIDE.md` - Complete system overview
- **Keyboard Shortcuts:** Press `F12` in Kitty - All keybindings
- **Helper Commands:** Each mode's documentation in collaboration modes guide

---

## TUI Architecture

**Built with:**
- `dialog` or `whiptail` for TUI widgets
- Bash script orchestration
- Integration with all 27 collaboration scripts
- jq for JSON state parsing

**Features:**
- Auto-detection of dialog tool
- Graceful fallback to whiptail
- Error handling and validation
- Clear user feedback
- Exit cleanup (removes temp files)

**File:** `~/.config/kitty/scripts/ai-agents-tui.sh`

---

## Future Enhancements

Potential future features:
- Live mode monitoring dashboard
- KB entry editing interface
- Session replay/restore
- Statistics and analytics
- Custom mode templates
- Bulk operations

---

**Created:** 2025-10-29
**TUI Version:** 1.0
**Keybinding:** `Ctrl+Alt+M`
**Status:** ✅ Fully Operational
