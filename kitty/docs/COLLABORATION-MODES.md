# AI Agents Collaboration Modes Guide

Complete guide to structured collaboration workflows for dual AI agents in tmux.

## Table of Contents

1. [Overview](#overview)
2. [Collaboration Modes](#collaboration-modes)
   - [Pair Programming](#pair-programming-mode)
   - [Debate](#debate-mode)
   - [Teaching](#teaching-mode)
   - [Consensus](#consensus-mode)
   - [Competition](#competition-mode)
3. [Quick Reference](#quick-reference)
4. [Best Practices](#best-practices)

---

## Overview

Collaboration modes provide structured workflows for agents to work together effectively. Each mode has specific roles, protocols, and helper commands.

### Starting a Mode

```bash
ai-mode-start.sh <mode> [options]
```

**Available Modes:**
- `pair` - Pair programming (driver/navigator)
- `debate` - Structured debate/discussion
- `teach` - Teaching mode (expert/learner)
- `consensus` - Consensus building (agents must agree)
- `compete` - Competition (best solution wins)

---

## Collaboration Modes

### Pair Programming Mode

**Purpose:** One agent codes (driver), the other reviews in real-time (navigator)

**Start:**
```bash
ai-mode-start.sh pair Agent1=driver Agent2=navigator
```

**Roles:**
- **Driver:** Writes code, explains actions
- **Navigator:** Reviews code, spots bugs, suggests improvements

**Commands:**

| Command | Usage | Description |
|---------|-------|-------------|
| `ai-pair-switch.sh` | No args | Switch driver/navigator roles |
| `ai-pair-observe.sh` | `<agent> "<observation>"` | Navigator adds observation |
| `ai-pair-issue.sh` | `"<issue>" [severity]` | Flag an issue (low/medium/high/critical) |
| `ai-pair-complete.sh` | `"<summary>"` | Mark task complete |

**Example Session:**
```bash
# Start pair programming
ai-mode-start.sh pair Agent1 Agent2

# Navigator observes
ai-pair-observe.sh Agent2 "Consider edge case: empty array"

# Flag critical issue
ai-pair-issue.sh "Potential null pointer dereference" critical

# Switch roles after 30 minutes
ai-pair-switch.sh

# Complete task
ai-pair-complete.sh "Implemented binary search with edge case handling"
```

**State Tracking:**
- File: `/tmp/ai-mode-ai-agents/pair-programming.json`
- Tracks: driver, navigator, switches, timing
- Auto-suggests role switch every 30 minutes

---

### Debate Mode

**Purpose:** Agents discuss different approaches before implementing

**Start:**
```bash
ai-mode-start.sh debate "Should we use REST or GraphQL?"
```

**Protocol:**
1. **Round 1:** Opening statements (5 min)
2. **Round 2:** Arguments with evidence (10 min)
3. **Round 3:** Rebuttals (10 min)
4. **Round 4:** Synthesis and consensus (5 min)

**Commands:**

| Command | Usage | Description |
|---------|-------|-------------|
| `ai-debate-position.sh` | `<agent> "<position>"` | State opening position |
| `ai-debate-argue.sh` | `<agent> "<argument>" [evidence]` | Present argument |
| `ai-debate-rebut.sh` | `<agent> "<rebuttal>"` | Counter opposing arguments |
| `ai-debate-consensus.sh` | `"<agreed solution>"` | Finalize consensus |

**Example Session:**
```bash
# Start debate
ai-mode-start.sh debate "API architecture decision"

# Opening statements
ai-debate-position.sh Agent1 "I propose REST because it's simpler"
ai-debate-position.sh Agent2 "GraphQL is better for flexible data fetching"

# Arguments
ai-debate-argue.sh Agent1 "REST has better caching" "HTTP caching standards"
ai-debate-argue.sh Agent2 "GraphQL reduces over-fetching" "Single endpoint for all data"

# Rebuttals
ai-debate-rebut.sh Agent1 "Caching can be implemented with GraphQL too"

# Consensus
ai-debate-consensus.sh "Hybrid: REST for simple CRUD, GraphQL for complex queries"
```

**State Tracking:**
- File: `/tmp/ai-mode-ai-agents/debate.json`
- Tracks: positions, arguments, consensus status

---

### Teaching Mode

**Purpose:** Expert agent guides learner agent through concepts

**Start:**
```bash
ai-mode-start.sh teach Agent1=expert Agent2=learner topic="async programming"
```

**Roles:**
- **Expert:** Explains concepts, provides examples, checks understanding
- **Learner:** Asks questions, practices, shares understanding

**Commands:**

| Command | Usage | Description |
|---------|-------|-------------|
| `ai-teach-explain.sh` | `"<expert>" "<concept>" "<explanation>"` | Explain a concept |
| `ai-teach-question.sh` | `"<learner>" "<question>"` | Ask a question |
| `ai-teach-exercise.sh` | `"<exercise>" [difficulty]` | Present practice exercise |
| `ai-teach-check.sh` | `"<learner>" "<summary>"` | Check understanding |
| `ai-teach-mastered.sh` | `"<concept>"` | Mark concept as mastered |

**Example Session:**
```bash
# Start teaching mode
ai-mode-start.sh teach Agent1 Agent2 "async programming"

# Expert explains
ai-teach-explain.sh Agent1 "Promises" "Promises represent eventual completion..."

# Learner asks
ai-teach-question.sh Agent2 "How do promises handle errors?"

# Expert gives exercise
ai-teach-exercise.sh "Implement a promise-based timeout" medium

# Learner shares understanding
ai-teach-check.sh Agent2 "Promises use .then() for success and .catch() for errors"

# Mark mastery
ai-teach-mastered.sh "Promises fundamentals"
```

**State Tracking:**
- File: `/tmp/ai-mode-ai-agents/teaching.json`
- Tracks: concepts covered, questions asked, mastery level (%)
- 100% mastery = topic fully learned

**Mastery Progression:**
- Each mastered concept: +10% mastery
- 100% mastery: Topic completed

---

### Consensus Mode

**Purpose:** Agents must reach agreement before proceeding

**Start:**
```bash
ai-mode-start.sh consensus "API design decisions"
```

**Protocol:**
1. **Phase 1:** Proposals (10 min) - Each agent proposes
2. **Phase 2:** Discussion (15 min) - Discuss merits/concerns
3. **Phase 3:** Refinement (10 min) - Refine based on feedback
4. **Phase 4:** Voting (5 min) - **Both must agree**

**Commands:**

| Command | Usage | Description |
|---------|-------|-------------|
| `ai-consensus-propose.sh` | `<agent> "<proposal>"` | Submit proposal |
| `ai-consensus-concern.sh` | `<agent> "<concern>"` | Voice a concern |
| `ai-consensus-refine.sh` | `"<refined proposal>"` | Present refined version |
| `ai-consensus-vote.sh` | `<agent> <yes\|no\|abstain>` | Vote on proposal |
| `ai-consensus-agree.sh` | `"<final decision>"` | Finalize agreement |

**Example Session:**
```bash
# Start consensus mode
ai-mode-start.sh consensus "Database choice"

# Both propose
ai-consensus-propose.sh Agent1 "Use PostgreSQL for relational integrity"
ai-consensus-propose.sh Agent2 "Use MongoDB for flexibility"

# Discuss concerns
ai-consensus-concern.sh Agent1 "MongoDB lacks strong ACID guarantees"
ai-consensus-concern.sh Agent2 "PostgreSQL is harder to scale horizontally"

# Refine
ai-consensus-refine.sh "PostgreSQL primary + MongoDB for analytics workloads"

# Vote (both must say yes!)
ai-consensus-vote.sh Agent1 yes
ai-consensus-vote.sh Agent2 yes

# Finalize
ai-consensus-agree.sh "Hybrid DB: PostgreSQL for transactions, MongoDB for analytics"
```

**Critical Rule:**
⚠️ **Both agents must vote YES to reach consensus!**

**State Tracking:**
- File: `/tmp/ai-mode-ai-agents/consensus.json`
- Tracks: proposals, votes, consensus status
- Blocks action until consensus reached

---

### Competition Mode

**Purpose:** Agents compete to solve challenges - best solution wins

**Start:**
```bash
ai-mode-start.sh compete "Implement efficient sorting algorithm" 30
# 30 = time limit in minutes (default: 30)
```

**Protocol:**
1. **Phase 1:** Planning (5 min) - Understand problem, design approach
2. **Phase 2:** Implementation (most of time) - Code and test
3. **Phase 3:** Submission (5 min) - Submit and explain

**Scoring Criteria (25 points each):**
- **Correctness:** Does it work? All edge cases?
- **Performance:** Speed, memory efficiency
- **Code Quality:** Readability, maintainability
- **Innovation:** Creative approach, elegance

**Total: 100 points**

**Commands:**

| Command | Usage | Description |
|---------|-------|-------------|
| `ai-compete-submit.sh` | `<agent> "<path>" "<explanation>"` | Submit solution |
| `ai-compete-score.sh` | `<agent> <criterion> <points>` | Score a criterion (0-25) |
| `ai-compete-winner.sh` | `<agent> "<reason>"` | Declare winner |

**Example Session:**
```bash
# Start competition
ai-mode-start.sh compete "Implement LRU cache" 30

# Agents code their solutions...

# Submit solutions
ai-compete-submit.sh Agent1 "./lru_cache_v1.py" "Using OrderedDict for O(1) operations"
ai-compete-submit.sh Agent2 "./lru_cache_v2.py" "Custom doubly-linked list implementation"

# Score Agent1
ai-compete-score.sh Agent1 correctness 25    # Perfect
ai-compete-score.sh Agent1 performance 22    # Very good
ai-compete-score.sh Agent1 code_quality 20   # Good
ai-compete-score.sh Agent1 innovation 18     # Standard approach

# Score Agent2
ai-compete-score.sh Agent2 correctness 24    # Near perfect
ai-compete-score.sh Agent2 performance 25    # Excellent
ai-compete-score.sh Agent2 code_quality 19   # Good
ai-compete-score.sh Agent2 innovation 25     # Very creative

# Declare winner
ai-compete-winner.sh Agent2 "Superior performance and innovative implementation"
```

**State Tracking:**
- File: `/tmp/ai-mode-ai-agents/competition.json`
- Tracks: submissions, scores, winner
- Displays grand finale announcement

---

## Quick Reference

### Command Matrix

| Mode | Start Command | Key Commands | Completion |
|------|---------------|--------------|------------|
| **Pair** | `ai-mode-start.sh pair` | switch, observe, issue | `ai-pair-complete.sh` |
| **Debate** | `ai-mode-start.sh debate "<topic>"` | position, argue, rebut | `ai-debate-consensus.sh` |
| **Teach** | `ai-mode-start.sh teach <exp> <lrn> <topic>` | explain, question, exercise | `ai-teach-mastered.sh` |
| **Consensus** | `ai-mode-start.sh consensus "<decision>"` | propose, vote, agree | `ai-consensus-agree.sh` |
| **Compete** | `ai-mode-start.sh compete "<challenge>"` | submit, score | `ai-compete-winner.sh` |

### Session Lifecycle

```bash
# 1. Start mode
ai-mode-start.sh <mode> [options]

# 2. Use mode-specific commands
# ... collaboration happens ...

# 3. Complete/finalize
# Use mode's completion command

# 4. Save session (optional)
ai-session-save.sh "session-name" "Description"
```

### File Locations

All mode state stored in `/tmp/ai-mode-ai-agents/`:
- `pair-programming.json`
- `debate.json`
- `teaching.json`
- `consensus.json`
- `competition.json`

---

## Best Practices

### General

1. **Read the Protocol:** Each mode has a specific protocol - follow it
2. **Use Completion Commands:** Always properly close a mode session
3. **Save Important Sessions:** Use `ai-session-save.sh` for valuable work
4. **Switch Modes:** Don't mix modes - finish one before starting another

### Pair Programming

- **Switch regularly:** Every 30 minutes for best results
- **Communicate constantly:** Driver explains, navigator questions
- **Flag issues immediately:** Don't let bugs accumulate
- **Use severity levels:** Critical > High > Medium > Low

### Debate

- **Be constructive:** Focus on finding best solution, not winning
- **Provide evidence:** Back up arguments with facts
- **Listen actively:** Consider opposing viewpoints seriously
- **Seek synthesis:** Find common ground and combine best ideas

### Teaching

- **Pace appropriately:** Match learner's speed
- **Check understanding:** Use `ai-teach-check.sh` frequently
- **Practice matters:** Give exercises at appropriate difficulty
- **Build mastery:** Don't rush to next concept too quickly

### Consensus

- **Voice concerns early:** Don't wait until voting
- **Be willing to compromise:** Hybrid solutions often work best
- **Refine iteratively:** Multiple refinement rounds are okay
- **Document reasoning:** Explain why you vote yes/no

### Competition

- **Plan first:** Don't jump straight to coding
- **Test thoroughly:** Correctness is worth 25 points!
- **Optimize smartly:** Balance performance with code quality
- **Be creative:** Innovation is a full scoring criterion
- **Learn from both:** Review both solutions after judging

---

## Integration with Other Features

### Knowledge Base
Save insights from collaboration:
```bash
ai-kb-add.sh decision "Use microservices" "Consensus reached in debate" architecture
ai-lesson-add.sh "Debate revealed scaling concerns" "Consider from start" architecture
```

### Session Snapshots
Preserve collaboration sessions:
```bash
ai-session-save.sh "debate-architecture-2025" "REST vs GraphQL consensus"
ai-session-list.sh  # View saved sessions
```

### Progress Tracking
Show collaboration progress:
```bash
ai-agent-progress.sh Agent1 "Implementing solution" 45 100
```

---

## Examples

### Complete Pair Programming Session

```bash
# Start
ai-mode-start.sh pair Agent1 Agent2

# Work session
ai-pair-observe.sh Agent2 "Consider using Map instead of Object"
ai-pair-issue.sh "Missing error handling" high
# ... driver implements fixes ...

# Switch roles
ai-pair-switch.sh
# ... continue with new driver ...

# Complete
ai-pair-complete.sh "Implemented user authentication with OAuth2"

# Save
ai-session-save.sh "oauth-implementation" "Pair programming: OAuth2 auth flow"
```

### Complete Teaching Session

```bash
# Start
ai-mode-start.sh teach Agent1 Agent2 "React Hooks"

# Teach useState
ai-teach-explain.sh Agent1 "useState" "useState is a hook that adds state to function components..."
ai-teach-question.sh Agent2 "Can I use multiple useState calls?"
ai-teach-explain.sh Agent1 "Multiple useState" "Yes, you can have multiple state variables..."
ai-teach-mastered.sh "useState basics"

# Practice
ai-teach-exercise.sh "Build a counter with useState" easy
ai-teach-check.sh Agent2 "useState returns array with value and setter function"
ai-teach-mastered.sh "useState practice"

# Continue to useEffect...
# ... mastery reaches 100% ...

ai-session-save.sh "react-hooks-learned" "Mastered React Hooks fundamentals"
```

---

## Troubleshooting

**Mode not active error:**
```
Solution: Start the mode first with ai-mode-start.sh
```

**Can't reach consensus:**
```
Solution: Use ai-consensus-concern.sh to voice issues
         Then ai-consensus-refine.sh to improve proposal
         Keep iterating until both can vote yes
```

**Competition scores incorrect:**
```
Solution: Each criterion is 0-25 points
         Score all 4 criteria for both agents
         Total should be /100 for each agent
```

**Teaching mastery stuck:**
```
Solution: Each ai-teach-mastered.sh adds 10%
         Need 10 mastered concepts for 100%
```

---

## Next Steps

1. Try each mode with simple tasks first
2. Combine modes: Debate → Consensus → Pair Programming
3. Save successful sessions as templates
4. Build a knowledge base of collaboration patterns
5. Experiment with custom workflows

**See Also:**
- [AI Agents Tmux Guide](AI-AGENTS-TMUX-GUIDE.md) - Main system overview
- [Knowledge Management](../scripts/ai-knowledge-init.sh) - KB system
- [Session Management](../scripts/ai-session-save.sh) - Save/restore sessions

---

**Created:** 2025-10-29
**Phase 3:** Collaboration Modes - Complete Implementation
**Total Helper Commands:** 25 scripts across 5 modes
