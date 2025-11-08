# New Practical Modes Guide

**Date:** 2025-11-08
**Purpose:** Guide to new, practical collaboration modes that replace academic/theoretical ones

---

## 🎯 Philosophy Change

**Old Approach:** Academic, theoretical collaboration patterns
**New Approach:** Practical, day-to-day development workflows

---

## 📊 Mode Comparison

### Core Modes (Recommended for Daily Use)

| Mode | Use Case | When to Use | Key Benefits |
|------|----------|-------------|--------------|
| **pair-programming** | Write code together | Building new features | Real-time collaboration, knowledge sharing |
| **code-review** | Review code quality | Before merging PR | Catch bugs, improve quality, share knowledge |
| **debug** | Fix bugs together | Stuck on a bug | Fresh perspective, systematic approach |
| **brainstorm** | Generate ideas | Planning, architecture | Creative thinking, no judgment |

### Legacy Modes (Kept for Compatibility)

| Mode | Replaced By | Why Changed |
|------|-------------|-------------|
| **debate** | brainstorm | Too formal, rigid structure |
| **consensus** | brainstorm | Too heavy for most decisions |
| **competition** | code-review | Review more practical than competition |
| **teaching** | pair-programming | Learning happens naturally in pairing |

---

## 🚀 New Modes Deep Dive

### 1. Code Review Mode

**Command:**
```bash
ai-mode-start.sh code-review [author] [reviewer] [file]
# or
bash modes/code-review.sh Author Reviewer "src/api.ts"
```

**Workflow:**
1. Author presents code for review
2. Reviewer examines code systematically
3. Reviewer provides feedback
4. Author addresses comments
5. Approve or request changes

**Review Checklist (Built-in):**
- ✓ Correctness - Does it work?
- ✓ Edge Cases - What can break?
- ✓ Performance - Is it efficient?
- ✓ Security - Any vulnerabilities?
- ✓ Style - Follows conventions?
- ✓ Tests - Adequate coverage?
- ✓ Docs - Clear documentation?

**Available Commands:**
```bash
ai-review-comment.sh <file> <line> "<comment>"  # Add review comment
ai-review-suggest.sh "<suggestion>"              # Suggest improvement
ai-review-approve.sh                             # Approve changes
ai-review-changes.sh "<summary>"                 # Request changes
```

**Example Session:**
```bash
# Start review
ai-mode-start.sh code-review Alice Bob "auth.js"

# Bob reviews
ai-review-comment.sh auth.js 42 "This could cause null pointer"
ai-review-suggest.sh "Add input validation before processing"
ai-review-comment.sh auth.js 58 "Consider using bcrypt instead of MD5"

# Alice responds
ai-review-changes.sh "Will add validation and upgrade hashing"
```

**Best For:**
- Pre-merge code reviews
- Learning from others' code
- Catching bugs before production
- Sharing best practices

---

### 2. Debug Mode

**Command:**
```bash
ai-mode-start.sh debug [reporter] [debugger] [bug_description]
# or
bash modes/debug.sh Alice Bob "TypeError in user login"
```

**Workflow:**
1. **Reproduce** - Can we replicate it?
2. **Isolate** - What's the minimal case?
3. **Investigate** - What's happening?
4. **Hypothesize** - What could cause this?
5. **Test** - Try potential solutions
6. **Verify** - Did it fix the issue?

**Debugging Process (Systematic):**
```
Reporter: Describes bug + error messages + context
Debugger: Asks questions, proposes hypotheses
Both: Work through debugging steps
Debugger: Guides investigation
Reporter: Tests solutions
Both: Verify fix
```

**Available Commands:**
```bash
ai-debug-log.sh "<finding>"       # Log a finding
ai-debug-hypothesis.sh "<theory>"  # Propose hypothesis
ai-debug-solution.sh "<fix>"       # Propose solution
ai-debug-verify.sh "<result>"      # Verify fix worked
```

**Example Session:**
```bash
# Start debug session
ai-mode-start.sh debug Alice Bob "Users can't login after deployment"

# Alice reports
ai-debug-log.sh "Getting 500 error on POST /api/login"
ai-debug-log.sh "Error: Cannot read property 'hash' of undefined"

# Bob investigates
ai-debug-hypothesis.sh "User object might be null before hash check"
ai-debug-log.sh "Checked DB - users exist, but password field is missing"

# Alice tests
ai-debug-solution.sh "Migration wasn't run on production DB"
ai-debug-verify.sh "Ran migration - login works now"
```

**Best For:**
- Stuck on a bug for >30 minutes
- Need fresh eyes on problem
- Complex, hard-to-reproduce bugs
- Learning debugging techniques

---

### 3. Brainstorm Mode

**Command:**
```bash
ai-mode-start.sh brainstorm "<topic>"
# or
bash modes/brainstorm.sh "How to handle API rate limiting"
```

**Workflow:**
1. **Diverge** (10 min) - Generate ideas freely, no criticism
2. **Group** (5 min) - Cluster similar ideas into themes
3. **Converge** (10 min) - Evaluate and prioritize
4. **Refine** (5 min) - Detail the top ideas

**Brainstorm Rules:**
- ✓ All ideas welcome
- ✓ Defer judgment
- ✓ Encourage wild ideas
- ✓ Build on each other
- ✓ Stay focused on topic
- ✗ No criticism during diverge phase

**Available Commands:**
```bash
ai-brainstorm-idea.sh "<idea>"                    # Add an idea
ai-brainstorm-group.sh "<theme>" <id1> <id2> ... # Group ideas
ai-brainstorm-vote.sh <idea_number>                # Vote for idea
ai-brainstorm-refine.sh <idea_number> "<details>" # Refine idea
```

**Example Session:**
```bash
# Start brainstorm
ai-mode-start.sh brainstorm "Improve app performance"

# Diverge - generate ideas
ai-brainstorm-idea.sh "Add Redis caching layer"
ai-brainstorm-idea.sh "Lazy load images"
ai-brainstorm-idea.sh "Use CDN for static assets"
ai-brainstorm-idea.sh "Database query optimization"
ai-brainstorm-idea.sh "Code splitting for bundles"
ai-brainstorm-idea.sh "Server-side rendering"

# Group ideas
ai-brainstorm-group.sh "Frontend" 2 5 6
ai-brainstorm-group.sh "Backend" 1 4
ai-brainstorm-group.sh "Infrastructure" 3

# Vote on best ideas
ai-brainstorm-vote.sh 1  # Redis caching
ai-brainstorm-vote.sh 4  # Query optimization

# Refine top ideas
ai-brainstorm-refine.sh 1 "Use Redis for user sessions and API responses. TTL: 5 min for API, session for users."
```

**Best For:**
- Planning new features
- Architecture decisions
- Problem-solving
- Exploring alternatives
- Quick decision-making

---

## 🔧 Migration from Legacy Modes

### From Debate → Brainstorm

**Before (debate):**
```bash
ai-mode-start.sh debate "REST vs GraphQL"
# 4 formal rounds, rigid structure
```

**After (brainstorm):**
```bash
ai-mode-start.sh brainstorm "API design: REST vs GraphQL"
# Flexible, focuses on ideas not argumentation
```

**Why:** Debate is too formal. Brainstorm gets to solutions faster.

---

### From Competition → Code Review

**Before (competition):**
```bash
ai-mode-start.sh compete "Implement user auth" 30
# Agents compete, submit solutions, scored
```

**After (code-review):**
```bash
ai-mode-start.sh pair-programming  # Write together
# Then:
ai-mode-start.sh code-review Alice Bob "auth.js"  # Review together
```

**Why:** Competition creates duplicate work. Collaboration is more efficient.

---

### From Consensus → Brainstorm

**Before (consensus):**
```bash
ai-mode-start.sh consensus "Database choice"
# Formal voting, proposals, concerns
```

**After (brainstorm):**
```bash
ai-mode-start.sh brainstorm "Choose database for project"
# Generate options, discuss pros/cons, vote
```

**Why:** Consensus is heavy. Brainstorm achieves same goal faster.

---

## 📈 Usage Recommendations

### Daily Development Workflow

**Morning:**
```bash
# Plan the day
ai-mode-start.sh brainstorm "Today's priorities"
```

**During Development:**
```bash
# Build features together
ai-mode-start.sh pair-programming

# Stuck on bug
ai-mode-start.sh debug Alice Bob "Bug description"
```

**Before Commit:**
```bash
# Quick self-review
ai-mode-start.sh code-review Self Reviewer "changes.js"
```

**PR Review:**
```bash
# Thorough review
ai-mode-start.sh code-review Author TeamMember "pr-diff"
```

---

## 🎯 Mode Selection Guide

**Choose Code Review when:**
- ✓ You have code to review
- ✓ Need quality assurance
- ✓ Learning code patterns
- ✓ Before merging PR

**Choose Debug when:**
- ✓ Stuck on a bug >30 min
- ✓ Bug is hard to reproduce
- ✓ Need systematic approach
- ✓ Want fresh perspective

**Choose Brainstorm when:**
- ✓ Need to generate ideas
- ✓ Making decisions
- ✓ Planning architecture
- ✓ Exploring options

**Choose Pair Programming when:**
- ✓ Building new feature
- ✓ Complex implementation
- ✓ Want to collaborate
- ✓ Teaching/learning

---

## 🔗 Quick Reference

### All Modes at a Glance

```bash
# Core modes (use these!)
ai-mode-start.sh pair-programming [driver] [navigator]
ai-mode-start.sh code-review [author] [reviewer] [file]
ai-mode-start.sh debug [reporter] [debugger] [bug]
ai-mode-start.sh brainstorm "<topic>"

# Legacy modes (for compatibility)
ai-mode-start.sh debate "<topic>"
ai-mode-start.sh teach [expert] [learner] [topic]
ai-mode-start.sh consensus "<decision>"
ai-mode-start.sh compete "<challenge>" [time]
```

### State Files

```bash
# Core modes
/tmp/ai-mode-ai-agents/pair-programming.json
/tmp/ai-mode-ai-agents/code-review.json
/tmp/ai-mode-ai-agents/debug.json
/tmp/ai-mode-ai-agents/brainstorm.json

# Legacy modes
/tmp/ai-mode-ai-agents/debate.json
/tmp/ai-mode-ai-agents/teaching.json
/tmp/ai-mode-ai-agents/consensus.json
/tmp/ai-mode-ai-agents/competition.json
```

### Protocol Files

```bash
# Core protocols
kitty/scripts/protocols/pair-protocol.txt
kitty/scripts/protocols/code-review-protocol.txt
kitty/scripts/protocols/debug-protocol.txt
kitty/scripts/protocols/brainstorm-protocol.txt

# Legacy protocols (to create if needed)
kitty/scripts/protocols/debate-protocol.txt
kitty/scripts/protocols/teaching-protocol.txt
kitty/scripts/protocols/consensus-protocol.txt
kitty/scripts/protocols/competition-protocol.txt
```

---

## 💡 Pro Tips

### Code Review
- Be specific in comments (line numbers help)
- Praise good code, not just critique
- Suggest solutions, not just problems
- Review in small chunks

### Debug
- Start with reproduction steps
- Use scientific method (hypothesis → test)
- Keep track of what you've tried
- Take breaks when stuck

### Brainstorm
- Set a timer for each phase
- Write down ALL ideas first
- Don't self-censor in diverge phase
- Build on others' ideas

### All Modes
- Use shared file for communication
- Keep modes focused (30-60 min max)
- Document decisions/learnings
- Complete mode when done (don't leave hanging)

---

## 📚 See Also

- `MODE-FRAMEWORK-MIGRATION.md` - How to migrate legacy modes
- `CODE-QUALITY-DEEP-REVIEW.md` - Full architecture analysis
- `lib/mode-framework.sh` - Framework implementation
- `kitty/docs/AI-AGENTS-TMUX-GUIDE.md` - Complete AI agents guide

---

**Last Updated:** 2025-11-08
**Status:** 3 new modes implemented, 4 legacy modes kept for compatibility
**Next:** Update TUI and fzf mode launcher to highlight new modes

