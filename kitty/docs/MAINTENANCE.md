# Maintenance Cheatsheet

Operational notes for the HARDENED v2.1.1 kitty configuration.

## Daily Commands

```bash
# Health checks
bash ~/.config/kitty/verify-config.sh
bash ~/.config/kitty/scripts/lint.sh

# Sync repo ↔ live (from LAB checkout)
make -C lab/dotfiles/kitty sync-pull          # Live → repo
make -C lab/dotfiles/kitty sync-push          # Repo → live
make -C lab/dotfiles/kitty sync-status        # Preview changes (dry-run)
make -C lab/dotfiles/kitty lint               # Shellcheck all scripts
make -C lab/dotfiles/kitty verify-live        # Verify ~/.config/kitty
make -C lab/dotfiles/kitty backup             # Snapshot live kitty.conf
make -C lab/dotfiles/kitty sync-status        # Preview repo ↔ live changes

# Theme management
bash ~/.config/kitty/scripts/switch-theme.sh

# Reload configuration
kitty @ load-config        # or press Ctrl+Shift+F5 inside kitty
```

## Monitoring Utilities

```bash
# Start/stop CPU & GPU telemetry in the window title
bash ~/.config/kitty/system-monitor.sh &
bash ~/.config/kitty/stop-monitor.sh

# GPU stats
nvidia-smi
watch -n 1 nvidia-smi

# CPU temperatures
sensors
```

## Aesthetics & Theming

```bash
# Toggle pre-defined transparency levels
~/.config/kitty/scripts/toggle-transparency.sh   # cycles between HIGH_OPACITY / LOW_OPACITY

# Remote adjustments (examples)
kitty @ set-background-opacity 0.90
kitty @ set-tab-title 0 "Neon Ops"
```

## Backup & Inspection

```bash
# Create timestamped backup before experimentation
cp ~/.config/kitty/kitty.conf ~/.config/kitty/kitty.conf.backup-$(date +%Y%m%d-%H%M%S)

# List historical backups
find ~/.config/kitty -name "*.backup-*" -type f

# Inspect active includes
grep "^include" ~/.config/kitty/kitty.conf

# Sync curated wallpapers into repo
make -C /home/miko/LAB/lab/dotfiles/kitty sync-pull
```

## Dependencies

- `kitty >= 0.37.0`
- `shellcheck` for linting (`sudo apt install shellcheck`)
- `rsync` for sync script (handles curated wallpapers; skips `wallpapers/generated/`)
- `wl-clipboard` (Wayland) or `xclip` (X11) for clipboard helpers
- `mpstat` (from `sysstat`), `sensors` (lm-sensors), and `nvidia-smi` for telemetry
- GNU `sed` for theme switch automation
- `python3` for verify-config version checks and remote-control helpers (tab titles, agent overlay)
- `nvim` (≥0.12) for the scrollback pager integration
- `tmux` for shared-session helper (optional, vertical dual-pane)

Keep these tools available to ensure the verification scripts and monitoring helpers run smoothly.

## Local Overrides

- Place host-specific tweaks under `~/.config/kitty/kitty.local/` (directories are ignored by Git when working from the LAB repo).
- Use environment variables prefixed with `KITTY_CONF_` for ad-hoc overrides; e.g. `export KITTY_CONF_THEME='include kitty.d/theme-matrix-ops.conf'` before launching kitty.
