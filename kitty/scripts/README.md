# AI Agents Collaboration Scripts

**Version**: 1.0 (Phase 0 Complete, Phase 1: 4/5 Issues Complete)
**Last Updated**: 2025-11-01

---

## Quick Start

### Launch Mode Selector
```bash
./ai-mode-fzf.sh
# Interactive mode selection with statistics and favorites
```

### Launch Specific Mode
```bash
./ai-mode-start.sh pair         # Pair programming
./ai-mode-start.sh debate       # Structured debate
./ai-mode-start.sh teach        # Teaching mode
./ai-mode-start.sh consensus    # Consensus building
./ai-mode-start.sh compete      # Competition
```

### Manage ADRs
```bash
./ai-adr-add.sh "Use React for Frontend"
./ai-adr-update.sh 1 --status Accepted
./ai-adr-browse-fzf.sh          # Browse all ADRs
./ai-adr-graph.sh               # Visualize relationships
```

### Run Tests
```bash
./ai-self-test.sh               # Full test suite
./ai-self-test.sh --quick       # Quick tests only
```

---

## Documentation

- **[ARCHITECTURE.md](../docs/scripts/ARCHITECTURE.md)** - System design and architecture
- **API.md** (Coming soon) - Function reference
- **TESTING.md** (Coming soon) - Testing guide

---

## Phase 1 Progress

**Completed** (4/5):
- ✅ Issue #10: Complete Test Suite (PR #7) - 82% coverage
- ✅ Issue #9: ADR Support (PR #8) - Full ADR system
- ✅ Issue #8: ADR Browser (PR #9) - Interactive browsing
- ✅ Issue #7: Mode Launcher Enhancement (PR #10) - Statistics & favorites

**Remaining** (1/5):
- ⏳ Issue #11: Documentation Consolidation (In Progress)

---

## Key Features

### Phase 0 Foundation (Complete)
- ✅ File locking for concurrent safety
- ✅ Secure temp file creation (chmod 700)
- ✅ JSON error handling with validation
- ✅ Configuration constants centralization
- ✅ Dependency checking
- ✅ ShellCheck compliance (zero warnings)

### Phase 1 Enhancements
- ✅ Comprehensive test suite (18/22 tests passing, 82% coverage)
- ✅ ADR system with graph visualization
- ✅ Interactive fzf browsers for modes and ADRs
- ✅ Mode statistics tracking (usage, favorites, sorting)
- 📝 Documentation consolidation (in progress)

---

## Directory Structure

```
scripts/
├── lib/                    # Core libraries
│   ├── colors.sh          # ANSI colors
│   ├── errors.sh          # Error handling
│   ├── config.sh          # Configuration
│   ├── progress.sh        # Progress bars
│   ├── constants.sh       # Path constants
│   ├── json-utils.sh      # JSON operations
│   ├── temp-files.sh      # Secure temp files
│   └── file-locking.sh    # Concurrency control
│
├── modes/                  # Collaboration modes
│   ├── pair-programming.sh
│   ├── debate.sh
│   ├── teaching.sh
│   ├── consensus.sh
│   └── competition.sh
│
├── ai-mode-start.sh       # Mode launcher
├── ai-mode-fzf.sh         # Interactive selector
│
├── ai-adr-*.sh            # ADR management (5 scripts)
├── ai-self-test.sh        # Test suite
│
└── [55+ utility scripts]
```

---

## Common Tasks

### Browse and Launch Modes
```bash
# Interactive selection with stats
./ai-mode-fzf.sh

# Sort by most frequent
./ai-mode-fzf.sh --sort frequent

# Sort by recently used
./ai-mode-fzf.sh --sort recent
```

### Create and Manage ADRs
```bash
# Create new ADR
./ai-adr-add.sh "Decision Title"

# Update status
./ai-adr-update.sh 0001 --status Accepted

# Link two ADRs
./ai-adr-link.sh 1 2 relates-to

# Supersede old ADR
./ai-adr-supersede.sh 1 5

# Browse interactively
./ai-adr-browse-fzf.sh

# Visualize relationships
./ai-adr-graph.sh --format text
./ai-adr-graph.sh --format dot | dot -Tpng > graph.png
```

### Testing
```bash
# Run all tests
./ai-self-test.sh

# Quick sanity check
./ai-self-test.sh --quick

# Verbose output
./ai-self-test.sh --verbose
```

---

## Development

### Adding a New Mode
1. Create `modes/my-mode.sh`
2. Add case to `ai-mode-start.sh`
3. Add metadata to `ai-mode-fzf.sh`
4. Add tests to `ai-self-test.sh`

### Adding a New Library
1. Create `lib/my-lib.sh`
2. Add header guard
3. Document functions
4. Add tests

### Running Tests
```bash
# All tests
./ai-self-test.sh

# Specific category
./ai-self-test.sh test_concurrent_state_updates
```

---

## Troubleshooting

### Mode Not Launching
- Check if mode script exists in `modes/`
- Verify script is executable: `chmod +x modes/*.sh`
- Check logs in `~/.ai-agents/logs/`

### JSON Errors
- Validate JSON: `jq . ~/.ai-agents/state/mode-state.json`
- Check file permissions
- Verify file locking isn't stuck

### Tests Failing
- Check dependencies: `jq`, `fzf`, `tmux`, `dialog`
- Verify paths in `lib/constants.sh`
- Check test logs in temp directory

---

**For detailed architecture information, see [ARCHITECTURE.md](../docs/scripts/ARCHITECTURE.md)**

**Maintained By**: LAB Repository
**Last Updated**: 2025-11-01
