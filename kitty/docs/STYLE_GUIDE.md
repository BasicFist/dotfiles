# Kitty Style Guide

This guide distills the conventions used across the HARDENED v2.1.1 kitty configuration. Follow it when proposing changes or authoring new modules/scripts.

## Configuration Files (.conf)

- **File names**: lowercase, hyphen separated (e.g. `perf-balanced.conf`).
- **Section headers**: emoji title surrounded by `═` separators.
- **Subsections**: start with `# --- Title ---`.
- **Inline comments**: concise, placed immediately above the setting they describe.
- **Load order**: security → core → performance profile → theme → visual effects → keybindings.
- **Alternatives**: keep mutually exclusive options commented with clear labels.

```conf
# ═══════════════════════════════════════════════════════════
# 🔒 SECURITY
# ═══════════════════════════════════════════════════════════
# Hardened clipboard guard rails

# --- Control code protection ---
paste_actions quote-urls-at-prompt,replace-dangerous-control-codes,confirm-if-large
```

## Shell Scripts (.sh)

- `#!/bin/bash` + `set -euo pipefail` required.
- Treat uppercase variables as constants, lowercase for locals.
- Provide emoji status markers (`✅`, `⚠️`, `❌`, `ℹ️`) for user feedback.
- Validate external dependencies before use (`command -v …`).
- Exit with non-zero status on failure; include a brief summary block.
- Support overriding paths via `KITTY_ROOT`/`KITTY_LIVE_DIR` when practical.

## Documentation (.md)

- Start with quick metadata (architecture, security grade, version, platform).
- Prefer emoji-labelled sections and short paragraphs.
- Provide copy-paste friendly command blocks.
- Capture migration history or major milestones in separate docs under `docs/`.

## Modular Architecture Principles

1. **Security First** – load hardened settings before anything else.
2. **Single Responsibility** – each module should cover one concern.
3. **Readable Diffs** – keep modules focused (≈30–150 lines) and heavily commented.
4. **Version Awareness** – annotate module headers when behaviour changes materially.

Adhering to this style keeps the kitty configuration auditable, easy to maintain, and pleasant to review.*** End Patch
