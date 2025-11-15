# Deep & Extensive Audit Report

**Repository:** dotfiles
**Audit Date:** 2025-11-15
**Auditor:** ChatGPT (gpt-5-codex)
**Scope:** Root dotfiles plus kitty/zsh subsystems with emphasis on AI Agents workflows, installer, and automation tooling.

---

## 1. Methodology

1. Enumerated repository topology (kitty scripts, zsh modules, installer entrypoints).
2. Reviewed foundational shell libraries (`lib/constants.sh`, `lib/mode-framework.sh`, `lib/shared-state.sh`, `lib/file-locking.sh`).
3. Sampled collaboration mode entrypoints (`kitty/scripts/modes/*.sh`) and supporting commands (ai-agent-send, ai-pair-issue, ai-consensus-*).
4. Collected `rg` statistics for hard-coded paths, then traced representative files for validation.
5. Inspected automation (`lint.sh`, `verify-modes.sh`) and installer surfaces for coverage gaps.

---

## 2. Executive Summary

| Severity | Finding | Impact | Fix Effort |
| --- | --- | --- | --- |
| **Critical** | Configuration constants ignored across 70+ scripts | Environment/path changes require editing dozens of files and risk desynchronization | 1–2 days to build bootstrap & apply replacements |
| **High** | Legacy mode scripts bypass shared framework & input escaping | Behavior drift plus JSON corruption when topics contain quotes; duplicated initialization logic | 1 day (refactor modes onto `mode-framework.sh`) |
| **High** | Shared transcript/state writes happen without locking or secure helpers | Race conditions and tampering possible despite existing locking + shared-state libraries | 0.5–1 day to enforce shared-state + locking wrappers |
| **Medium** | Lint/test automation covers <15% of scripts | Hidden regressions; documentation claims 80+ scripts but lint touches 9 | 0.5 day to expand script discovery |
| **Medium** | User-controlled strings interpolated into JSON/ANSI without sanitization | Broken JSON, rendering glitches, potential code execution if logs are re-sourced | 0.5 day (centralized escaping helpers) |

---

## 3. Detailed Findings

### 3.1 Critical — Configuration Constants Bypassed

* `kitty/scripts/lib/constants.sh` exposes `AI_AGENTS_SHARED_FILE`, `AI_AGENTS_MODE_DIR`, and helper `get_mode_state_path`, yet most scripts still construct `/tmp/…` paths manually.
* `rg` shows 70 direct references to `/tmp/ai-agents-shared` and 28 to `/tmp/ai-mode` despite the constants module.
* Representative evidence: `ai-agent-send-enhanced.sh` hard-codes the shared transcript path; `ai-pair-issue.sh` and the debate/consensus helpers define `MODE_STATE="/tmp/ai-mode-${SESSION}/…"`; `modes/debate.sh` rebuilds paths that `mode-framework.sh` already manages.

**Why it matters:** Changing storage location (e.g., moving into `/run/user/$UID`) or adding per-session isolation requires hand-editing dozens of files. The duplication also reintroduces security issues (predictable /tmp file names) that the shared-state library already solved.

**Remediation:** Create a `lib/bootstrap.sh` that exports `SCRIPT_DIR`, sources `constants.sh`, and sets `AI_AGENTS_SHARED_FILE`. Mechanically replace literal `/tmp` strings with the exported constants/`get_mode_state_path`, then add a lint check (`rg '/tmp/ai-'`) to gate future merges.

### 3.2 High — Legacy Modes Skip Framework & Duplicate Initialization

* `kitty/scripts/modes/pair-programming.sh` sources `mode-framework.sh` and delegates initialization plus announcements to shared helpers.
* `modes/debate.sh`, `modes/consensus.sh`, `modes/competition.sh`, and `modes/teaching.sh` still inline JSON creation, shared file clearing, and command lists.

**Impact:** These modes miss JSON validation, directory bootstrapping, and consistent notifications. Enhancements (e.g., new announcement formatting) require modifying each mode separately, increasing maintenance cost and bug surface.

**Remediation:** Port every `modes/*.sh` file to call `mode_init`, `mode_announce`, and `mode_show_commands`. Once migrated, delete the bespoke heredocs and rely on shared protocol templates.

### 3.3 High — Shared Transcript & State Writes Lack Locking

* Libraries already provide advisory locks and secure shared-file creation (`lib/file-locking.sh`, `lib/shared-state.sh`), yet most scripts append with `cat >> /tmp/ai-agents-shared.txt` or `echo >>` without coordination.
* Only `ai-session-health.sh` sources `shared-state.sh`; core writers (`ai-agent-send-enhanced.sh`, `ai-pair-issue.sh`, etc.) do not.

**Impact:** Concurrent writers corrupt transcripts, and attackers can pre-create `/tmp/ai-agents-shared.txt` as a symlink. This undermines the safety claims made in the docs.

**Remediation:** Require scripts that touch shared files to source `lib/shared-state.sh` and use a helper (`shared_append`) that internally calls `file-locking.sh`. Consider storing transcripts inside `~/.ai-agents/logs` with rotation enabled by default.

### 3.4 Medium — User Input Injected Without Escaping

* Debate mode interpolates `$TOPIC` directly into JSON and colored protocol text; `ai-pair-issue.sh` inserts `$ISSUE` inside ANSI heredocs and tmux notifications.
* If a topic contains quotes or `$()`, JSON breaks and future commands crash. Control characters can also poison tmux panes or logs when re-sourced.

**Remediation:** Provide escaping helpers (`json_escape`, `ansi_escape`) and enforce them for every user-supplied string. Add regression tests feeding malicious strings through debate/pair commands to ensure safe rendering.

### 3.5 Medium — Lint/Test Coverage Gap

* `kitty/scripts/lint.sh` manually lists nine scripts for shellcheck, ignoring the majority of executables in `kitty/scripts`, `kitty/scripts/modes`, `zsh/`, and repo root.
* As a result, syntax errors in collaboration scripts or installer changes can slip through unnoticed.

**Remediation:** Update lint automation to discover all `*.sh` files (with allowlist exclusions) and integrate it with CI. Consider adding lightweight smoke tests (`verify-modes.sh`) to catch runtime regressions.

---

## 4. Recommendations Roadmap

1. **Week 1:** Implement bootstrap sourcing and refactor hard-coded paths to the constants/shared-state helpers.
2. **Week 2:** Port legacy modes to `mode-framework.sh` and introduce escaping utilities.
3. **Week 3:** Expand lint/test automation and add transcript append helper that enforces locking.
4. **Continuous:** Update documentation and ADRs so contributors follow the new conventions automatically.

---

## 5. Positive Observations

* Library code (`json-utils`, `mode-framework`, `shared-state`) already demonstrates strong engineering discipline.
* Installer and documentation are comprehensive and user-friendly.
* Addressing the findings mostly requires wiring existing high-quality primitives into the older scripts, making the remediation path straightforward.
