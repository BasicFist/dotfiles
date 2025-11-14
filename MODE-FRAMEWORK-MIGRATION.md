# Mode Framework Migration Guide

**Date:** 2025-11-08
**Purpose:** Guide for migrating remaining collaboration modes to use the new mode framework

---

## Overview

The mode framework (`lib/mode-framework.sh`) centralizes common initialization logic, eliminating 400+ lines of duplication across mode scripts. This guide shows how to migrate the remaining 4 modes.

### Already Migrated
- ✅ **pair-programming.sh** - Reduced from 83 lines → 60 lines
- ✅ **debate.sh** - Uses framework + `protocols/debate-protocol.txt`
- ✅ **teaching.sh** - Uses framework + `protocols/teaching-protocol.txt`
- ✅ **consensus.sh** - Uses framework + `protocols/consensus-protocol.txt`
- ✅ **competition.sh** - Uses framework + `protocols/competition-protocol.txt`

All legacy collaboration modes are now on the shared framework. The "To Migrate" section is intentionally left empty for future modes.

---

## Benefits of Migration

1. **Less Code:** Each mode reduces from ~80 lines to ~50 lines
2. **Consistency:** All modes use same initialization pattern
3. **Validation:** Built-in state transition validation
4. **Maintainability:** Changes to init logic only in one place
5. **External Protocols:** Documentation separated from code

---

## Migration Steps

### Step 1: Create Protocol File

Extract the protocol section (lines with `cat >> /tmp/ai-agents-shared.txt <<EOF`) to a separate file:

```bash
# Create protocol file
vim kitty/scripts/protocols/debate-protocol.txt
```

**Example from debate.sh lines 40-69:**
```text
═══════════════════════════════════════
 Debate Protocol
═══════════════════════════════════════

Topic: [will be inserted dynamically]

Round 1: Opening Statements (5 min)
  Each agent presents their position

Round 2: Arguments (10 min)
  Present supporting evidence and reasoning

Round 3: Rebuttals (10 min)
  Address counter-arguments

Round 4: Synthesis (5 min)
  Find common ground
  Identify best combined approach

Commands:
  • Position: ai-debate-position.sh <agent> "<position>"
  • Argument: ai-debate-argue.sh <agent> "<argument>" [evidence]
  • Rebuttal: ai-debate-rebut.sh <agent> "<rebuttal>"
  • Consensus: ai-debate-consensus.sh "<agreed solution>"

Goal: Find the best solution through discussion!

═══════════════════════════════════════
```

### Step 2: Refactor Mode Script

**Before (debate.sh - 77 lines):**
```bash
#!/usr/bin/env bash
set -euo pipefail

SESSION=${KITTY_AI_SESSION:-ai-agents}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/colors.sh"

TOPIC="${1:-No topic specified}"
MODE_STATE="/tmp/ai-mode-${SESSION}/debate.json"

# Initialize mode
cat > "$MODE_STATE" <<EOF
{
  "mode": "debate",
  "started": "$(date -Iseconds)",
  "topic": "$TOPIC",
  "positions": {
    "Agent1": null,
    "Agent2": null
  },
  "arguments": [],
  "consensus_reached": false
}
EOF

# Clear shared communication
> /tmp/ai-agents-shared.txt

# Announce mode start
"${SCRIPT_DIR}/../ai-agent-send-enhanced.sh" System INFO "💭 Debate Mode Started" --notify
"${SCRIPT_DIR}/../ai-agent-send-enhanced.sh" System INFO "   Topic: $TOPIC"
echo "" >> /tmp/ai-agents-shared.txt

# Show protocol (40 lines of embedded text)
cat >> /tmp/ai-agents-shared.txt <<EOF
...
EOF

success_color "✅ Debate mode active"
info_color "   Topic: $TOPIC"
echo ""
echo "Start by stating positions:"
echo "  ai-debate-position.sh Agent1 \"I propose approach A because...\""
echo "  ai-debate-position.sh Agent2 \"I prefer approach B because...\""
```

**After (debate.sh - ~48 lines):**
```bash
#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Debate Mode
# ═══════════════════════════════════════════════════════════
# Agents discuss different approaches before implementing
#
# Usage:
#   debate.sh [topic]
#
# Arguments:
#   topic - Topic to debate (required)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/mode-framework.sh"
source "${SCRIPT_DIR}/../lib/constants.sh"

# Parse arguments
TOPIC="${1:-No topic specified}"

# Build initial state
STATE_JSON=$(cat <<EOF
{
  "mode": "debate",
  "started": "$(date -Iseconds)",
  "topic": "$TOPIC",
  "positions": {
    "Agent1": null,
    "Agent2": null
  },
  "arguments": [],
  "consensus_reached": false,
  "status": "initialized"
}
EOF
)

# Initialize mode with framework
if ! mode_init "debate" "$STATE_JSON" "protocols/debate-protocol.txt"; then
    error_color "❌ Failed to initialize debate mode"
    exit 1
fi

# Send announcements
mode_blank_line
mode_announce "System" "INFO" "💭 Debate Mode Started" --notify
mode_announce "System" "INFO" "   Topic: $TOPIC"
mode_blank_line

# Display success and commands
success_color "✅ Debate mode active"
info_color "   Topic: $TOPIC"

mode_show_commands "debate" \
    "ai-debate-position.sh <agent> \"<position>\"   # State your position" \
    "ai-debate-argue.sh <agent> \"<argument>\"      # Present argument" \
    "ai-debate-rebut.sh <agent> \"<rebuttal>\"      # Counter-argue" \
    "ai-debate-consensus.sh \"<solution>\"          # Reach consensus"
```

**Key Changes:**
1. ✅ Source `mode-framework.sh` instead of individual libs
2. ✅ Remove hardcoded paths (`/tmp/ai-mode-${SESSION}/debate.json` → use framework)
3. ✅ Remove hardcoded `SHARED_FILE` references
4. ✅ Replace `cat > "$MODE_STATE"` with `mode_init()`
5. ✅ Replace direct script calls with `mode_announce()`
6. ✅ Replace manual echo with `mode_show_commands()`
7. ✅ Add `status` field to JSON state

---

## Step 3: Test the Migrated Mode

```bash
# Test the mode script directly
cd /home/user/dotfiles/kitty/scripts/modes
bash debate.sh "REST vs GraphQL"

# Verify:
# 1. State file created at correct path
jq . /tmp/ai-mode-ai-agents/debate.json

# 2. Protocol file loaded into shared file
cat /tmp/ai-agents-shared.txt

# 3. No errors in output
```

---

## Common Patterns & Solutions

### Pattern 1: Hardcoded Paths
```bash
# ❌ OLD
MODE_STATE="/tmp/ai-mode-${SESSION}/teaching.json"
> /tmp/ai-agents-shared.txt

# ✅ NEW
# Use framework - paths handled automatically
mode_init "teaching" "$STATE_JSON" "protocols/teaching-protocol.txt"
```

### Pattern 2: Direct Script Calls
```bash
# ❌ OLD
"${SCRIPT_DIR}/../ai-agent-send-enhanced.sh" System INFO "Message" --notify

# ✅ NEW
mode_announce "System" "INFO" "Message" --notify
```

### Pattern 3: Manual State Creation
```bash
# ❌ OLD
cat > "$MODE_STATE" <<EOF
{
  "mode": "teaching",
  ...
}
EOF

# ✅ NEW
STATE_JSON=$(cat <<EOF
{
  "mode": "teaching",
  ...,
  "status": "active"
}
EOF
)
mode_init "teaching" "$STATE_JSON" "protocols/teaching-protocol.txt"
```

### Pattern 4: Protocol Embedding
```bash
# ❌ OLD (30-50 lines in script)
cat >> /tmp/ai-agents-shared.txt <<EOF
═══════════════════════════════════════
 Teaching Protocol
═══════════════════════════════════════
...
EOF

# ✅ NEW (external file)
# Protocol loaded automatically by mode_init()
```

### Pattern 5: Command Display
```bash
# ❌ OLD
echo ""
echo "Commands available:"
echo "  ai-teach-explain.sh <topic>     # Explain concept"
echo "  ai-teach-exercise.sh <exercise> # Give exercise"
...

# ✅ NEW
mode_show_commands "teaching" \
    "ai-teach-explain.sh <topic>        # Explain concept" \
    "ai-teach-exercise.sh <exercise>    # Give exercise" \
    ...
```

---

## Checklist for Each Mode

When migrating a mode, ensure:

- [ ] Protocol file created in `protocols/`
- [ ] Mode script sources `mode-framework.sh`
- [ ] No hardcoded paths (use framework)
- [ ] State includes `status` field
- [ ] Uses `mode_init()` for initialization
- [ ] Uses `mode_announce()` for messages
- [ ] Uses `mode_show_commands()` for command list
- [ ] Uses constants from `constants.sh`
- [ ] Tested and works correctly
- [ ] Original script backed up (`.bak`)

---

## Protocol Files to Create

### 1. debate-protocol.txt (NEXT)
Extract from `modes/debate.sh` lines 40-69

### 2. teaching-protocol.txt
Extract from `modes/teaching.sh` lines 54-93

### 3. consensus-protocol.txt
Extract from `modes/consensus.sh` lines 52-90

### 4. competition-protocol.txt
Extract from `modes/competition.sh` lines 45-90

---

## Mode-Specific Notes

### Debate Mode
- **Lines:** 77 → ~48 (38% reduction)
- **Unique:** Round-based structure
- **State:** Add `current_round` field for tracking

### Teaching Mode
- **Lines:** 90 → ~52 (42% reduction)
- **Unique:** Expert/Learner roles
- **State:** Add `exercises_completed` tracking

### Consensus Mode
- **Lines:** 83 → ~50 (40% reduction)
- **Unique:** Voting mechanism
- **State:** Add `votes` array

### Competition Mode
- **Lines:** 106 → ~58 (45% reduction)
- **Unique:** Scoring system
- **State:** Add `scores` object

---

## Expected Results

### Before Migration
```
Total lines in 5 modes: 439
Duplication: High (~70% overlap)
Maintainability: Low (5 places to change)
```

### After Migration
```
Total lines in 5 modes: ~268 (-39%)
Duplication: Minimal (<10% overlap)
Maintainability: High (change framework once)
Protocol files: 5 × ~30 lines = 150 lines
Framework: 1 × 478 lines = 478 lines
Net total: 268 + 150 + 478 = 896 lines
  vs. before: 439 + (protocols embedded) = ~1100 lines
  Reduction: ~200 lines (18%)
```

### Code Quality Improvements
- ✅ Consistent error handling
- ✅ Validated state transitions
- ✅ Centralized path management
- ✅ External documentation
- ✅ Easier to test
- ✅ Easier to extend

---

## Migration Order (Recommended)

1. ✅ **pair-programming.sh** (DONE - reference implementation)
2. **debate.sh** (simplest remaining mode)
3. **teaching.sh** (medium complexity)
4. **competition.sh** (has scoring logic)
5. **consensus.sh** (most complex - has voting)

---

## Testing Strategy

After each migration:

```bash
# 1. Syntax check
bash -n modes/debate.sh

# 2. Run mode
cd modes
bash debate.sh "Test topic"

# 3. Verify state file
jq . /tmp/ai-mode-ai-agents/debate.json

# 4. Verify shared file
cat /tmp/ai-agents-shared.txt | head -20

# 5. Test a command
bash ../ai-debate-position.sh Agent1 "Test position"

# 6. Verify state update
jq '.positions' /tmp/ai-mode-ai-agents/debate.json
```

---

## Rollback Plan

If issues occur:

```bash
# Each mode should have a .bak backup
cp modes/debate.sh.bak modes/debate.sh

# Or revert git commit
git revert <commit-hash>
```

---

## Framework Functions Reference

### Core Functions

```bash
# Initialize mode
mode_init "mode-name" "$STATE_JSON" "protocols/file.txt"
  Returns: 0 on success, 1 on failure

# Send announcement
mode_announce "Target" "TYPE" "Message" [--notify] [--blink]
  Target: Agent1|Agent2|System|Shared
  Type: INFO|TASK|RESULT|WARNING|ERROR

# Show commands
mode_show_commands "mode-name" "cmd1  # desc1" "cmd2  # desc2" ...

# Get state path
path=$(mode_get_state_path "mode-name")

# Append to shared file
mode_append_shared "Text content"
mode_blank_line  # Add blank line
```

### State Transition Functions

```bash
# Validate transition
mode_validate_transition "mode" "current_state" "new_state"

# Perform validated transition
mode_transition "$MODE_STATE_FILE" "new_state"

# Get current mode
current=$(mode_get_current "$MODE_STATE_FILE")
```

---

## Next Steps

1. Create remaining protocol files (debate, teaching, consensus, competition)
2. Migrate debate.sh (easiest next)
3. Test thoroughly
4. Migrate remaining modes one by one
5. Update documentation to reference new structure
6. Remove old backup files after confirmation

---

## Questions?

See:
- `lib/mode-framework.sh` - Framework implementation with self-tests
- `modes/pair-programming.sh` - Reference implementation
- `protocols/pair-protocol.txt` - Example protocol file
- `CODE-QUALITY-DEEP-REVIEW.md` - Original refactoring plan

---

**Author:** Claude Code
**Date:** 2025-11-08
**Status:** In Progress (1/5 modes migrated)
