# Kitty Feature & Hardening Audit (2025-10)

## 1. Scope & Environment
- **Configuration boundary**: modular Kitty stack driven by `kitty.conf`, which loads distinct modules for security, core UX, performance profiles, visual effects, keybindings, mouse behavior, and host-specific overrides via `globinclude`/`envinclude`.【F:kitty/kitty.conf†L10-L102】
- **Operational assets**: hardened scripts alongside the config directory (verification, monitoring, clipboard tooling, remote-control helpers, sync/lint utilities) that are invoked from keybindings or maintenance tasks.【F:kitty/verify-config.sh†L1-L287】【F:kitty/scripts/sync.sh†L1-L159】【F:kitty/scripts/lint.sh†L1-L117】

## 2. Architecture & Feature Inventory

### 2.1 Modular Core & Overrides
- Fonts, terminal identity, hyperlink styling, and copy-on-select defaults live in `core.conf`, while optional OSC-52 relays stay disabled for security unless explicitly overridden per host. The same module also patches special key sequences for compatibility-sensitive apps.【F:kitty/kitty.d/core.conf†L6-L66】
- Localized tweaks are supported through host-specific files under `kitty.local/` and environment-driven includes (`KITTY_CONF_*`), keeping personal adjustments outside Git-managed state.【F:kitty/kitty.conf†L61-L69】

### 2.2 Security Stack
- Remote control is constrained to per-process Unix sockets (`/tmp/kitty-{kitty_pid}`) with socket-only access, and optional passwords are documented for multi-user hosts.【F:kitty/kitty.d/security.conf†L7-L14】
- Clipboard policy requires explicit consent before applications read clipboard or primary selections, caps clipboard data at 32 MB, strips trailing spaces smartly, and forces confirmation on clone operations.【F:kitty/kitty.d/security.conf†L15-L26】
- `paste_actions` bundle URL quoting, ANSI control-code scrubbing, and large-paste confirmation, covering Kitty’s official A+ security matrix without disabling productivity features.【F:kitty/kitty.d/security.conf†L19-L36】

### 2.3 Performance & Visual Profiles
- Balanced vs. low-latency presets control repaint/input delays, resize strategies, and scrollback limits so operators can trade responsiveness for resource usage per workflow.【F:kitty/kitty.d/perf-balanced.conf†L1-L24】【F:kitty/kitty.d/perf-lowlatency.conf†L1-L25】
- Visual baselines define cursor behavior, background opacity, pointer shapes, tab layouts, and neon-specific accents (opacity, borders, activity glyphs), while the theme modules govern palettes and 16-color tables.【F:kitty/kitty.d/visual-effects-base.conf†L1-L23】【F:kitty/kitty.d/visual-effects-neon.conf†L1-L16】【F:kitty/kitty.d/theme-neon.conf†L1-L51】

### 2.4 Input, Clipboard & Mouse Controls
- Copy-on-select and tuned word boundaries provide dual-buffer ergonomics, while keybindings layer standard clipboard shortcuts with advanced workflows (flattening pastes, selection toggles, interactive clipboard manager).【F:kitty/kitty.d/core.conf†L38-L66】【F:kitty/kitty.d/keybindings.conf†L91-L135】
- Mouse mappings deliver instant link activation (Ctrl+Shift+Click) and rectangle/word/line selections without delay penalties.【F:kitty/kitty.d/mouse.conf†L1-L12】

### 2.5 Keybinding & Overlay Ecosystem
- The keymap clears defaults, redefines splits/tabs navigation, binds monitors (GPU/Sensors loops), overlays (shortcuts palette, hints), and dispatchers for AI/fzf tooling, tmux sharing, scratchpad, opacity toggles, clipboard manager, and agent terminals.【F:kitty/kitty.d/keybindings.conf†L7-L135】
- Scratchpad, transparency toggle, and agent overlay rely on remote-control scripts to launch/focus overlays with custom opacity or shell contexts.【F:kitty/scripts/toggle-scratchpad.sh†L1-L39】【F:kitty/scripts/toggle-transparency.sh†L1-L37】【F:kitty/scripts/agent-terminal.sh†L1-L183】

### 2.6 Monitoring & Clipboard Utilities
- `system-monitor.sh` streams CPU/GPU utilization and thermals into the window title, with guarded fallbacks and a cleanup trap, while `stop-monitor.sh` scopes teardown to the current user and resets titles.【F:kitty/system-monitor.sh†L1-L89】【F:kitty/stop-monitor.sh†L1-L34】
- The clipboard manager layers wl-clipboard/xclip detection, menu-driven statistics, copy notifications, and clearing routines so the enhanced paste bindings have a UX surface.【F:kitty/clipboard-manager.sh†L1-L146】

### 2.7 Sync, Verification & Linting
- `verify-config.sh` enforces module presence, dependency health, remote-control lockdown, single active theme/profile, backup availability, and config syntax; CI pipelines can rely on exit codes.【F:kitty/verify-config.sh†L1-L287】
- `sync.sh` wraps rsync push/pull/status operations, with exclusions for generated artefacts/backups and DRY_RUN previews to keep `~/.config/kitty` aligned with the repo.【F:kitty/scripts/sync.sh†L1-L128】
- `scripts/lint.sh` gives a curated ShellCheck sweep for critical scripts (verification, monitor, clipboard, tmux helpers), blocking on missing shellcheck or script errors.【F:kitty/scripts/lint.sh†L1-L117】

## 3. Hardening Strength Highlights
1. **Defense-in-depth around paste vectors** – `paste_actions` couples URL quoting, control-code scrubbing, and large-paste confirmation while clipboard read access is confirmation-gated, reducing the attack surface for accidental command injection or DoS.【F:kitty/kitty.d/security.conf†L15-L36】
2. **Remote-control safeguards with per-instance sockets** – remote commands require local socket access and optional passwording, aligning with the heavy use of `kitty @` invocations across toggle scripts, overlays, and verification utilities.【F:kitty/kitty.d/security.conf†L7-L24】【F:kitty/scripts/toggle-scratchpad.sh†L25-L39】
3. **Operational hygiene baked in** – verify, sync, and lint scripts all use `set -euo pipefail`, dependency detection, and explicit warnings so misconfigurations or missing tooling are surfaced quickly before reaching production terminals.【F:kitty/verify-config.sh†L1-L287】【F:kitty/scripts/sync.sh†L1-L159】【F:kitty/scripts/lint.sh†L1-L117】
4. **Graceful overlays** – Agent terminal and scratchpad scripts verify prerequisites, sanitize titles, and use shared notifications to avoid intrusive focus stealing, offering safe multi-actor workflows without manual tmux juggling.【F:kitty/scripts/agent-terminal.sh†L12-L183】【F:kitty/scripts/toggle-scratchpad.sh†L1-L39】
5. **Telemetry privacy & resilience** – monitors scope process management to the invoking user, clean window titles on exit, and fall back when GPU/temperature commands are absent, preventing leaked state across sessions.【F:kitty/system-monitor.sh†L21-L89】【F:kitty/stop-monitor.sh†L12-L34】

## 4. Delivered Hardening Enhancements
1. **Remote-control password hygiene** – `verify-config.sh` now asserts that `remote_control_password` is defined (and not left at the placeholder), so multi-user deployments get an explicit red/yellow signal before exposing `kitty @` sockets.【F:kitty/verify-config.sh†L170-L211】
2. **Helper script health checks** – The verification script parses every `.sh` path referenced in `keybindings.conf`, confirming the helpers exist and carry the executable bit, which prevents overlays or AI tooling from silently breaking after refactors.【F:kitty/verify-config.sh†L213-L246】【F:kitty/kitty.d/keybindings.conf†L63-L149】
3. **Multi-vendor GPU telemetry** – `system-monitor.sh` auto-detects NVIDIA, AMD (ROCm), and Intel GPUs, gracefully falling back to `N/A` if vendor utilities are missing while still formatting the window-title status cleanly.【F:kitty/system-monitor.sh†L24-L104】
4. **Safe sync operations** – `scripts/sync.sh` now prompts before destructive rsync runs and produces tarball snapshots (unless disabled) so accidental deletions are recoverable in seconds.【F:kitty/scripts/sync.sh†L18-L129】
5. **Fleet-wide lint coverage** – `scripts/lint.sh` walks the entire Kitty tree (excluding caches) to run ShellCheck on every `.sh`, ending the drift between the tool and newly added scripts.【F:kitty/scripts/lint.sh†L18-L74】

## 5. Remaining Enhancement & Feature Opportunities
| # | Opportunity | Suggested Improvement | Source |
|---|-------------|-----------------------|--------|
| 1 | **Remote control socket permissions** | Enforce `remote_control_password` delivery (e.g., via envinclude or password files) and tighten socket directories when `listen_on` stays under `/tmp` so other users cannot snoop `kitty @` traffic.【F:kitty/kitty.d/security.conf†L7-L24】 | Security |
| 2 | **Clipboard manager fallbacks** | When neither `wl-clipboard` nor `xclip` exists, automatically disable the `Ctrl+Shift+Alt+P` binding or emit a Kitty notification so the menu does not appear frozen.【F:kitty/clipboard-manager.sh†L20-L91】【F:kitty/kitty.d/keybindings.conf†L91-L111】 | UX |
| 3 | **Overlay resource limits** | Agent and scratchpad launchers rely on remote-control sockets; add optional timeout/size guards (e.g., kill overlay after inactivity) plus logging to detect runaway overlays in multi-hour sessions.【F:kitty/scripts/agent-terminal.sh†L55-L119】【F:kitty/scripts/toggle-scratchpad.sh†L14-L39】 | Multi-actor |
| 4 | **Theme automation** | `switch-theme.sh` rewrites includes but leaves performance profile toggles manual. A single interactive TUI (fzf/choose) could bundle theme + visual + performance profile selection and store state under `.state/` for quick rollbacks.【F:kitty/scripts/switch-theme.sh†L1-L107】【F:kitty/kitty.conf†L22-L50】 | UX |
| 5 | **Clipboard risk analytics** | Track anonymized stats (size, frequency) when `paste_actions` triggers quoting or control-code removal; surfacing a notification/log would confirm the security layer is exercised and help tune thresholds.【F:kitty/kitty.d/security.conf†L19-L36】 | Security telemetry |
| 6 | **Keybinding documentation drift** | `keybindings.conf` doubles as documentation, but human-readable cheat sheets (`docs/` or the shortcuts kitten) can fall behind. Automating cheat-sheet generation from the config (e.g., parse `keybindings.conf` to Markdown) would keep reference materials synchronized.【F:kitty/kitty.d/keybindings.conf†L1-L186】 | Documentation |

## 6. Suggested Next Steps
1. Prioritize socket password delivery (Opportunity 1) and clipboard dependency UX (Opportunity 2) so shared hosts stay safe while operators get clear feedback.
2. Explore overlay lifecycle controls (Opportunity 3) alongside theme/profile automation (Opportunity 4) to keep advanced workflows lightweight.
3. Schedule telemetry/documentation investments (Opportunities 5–6) after the UI-facing backlog stabilizes.

---
*Prepared for the dotfiles Kitty stack maintainers to guide future hardening and feature planning.*
