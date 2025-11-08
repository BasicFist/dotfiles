```bash
SHARED_FILE="${AI_AGENTS_SHARED_FILE:-/tmp/ai-agents-shared.txt}"
```

- Created automatically by the shared-state library with `0600` permissions.
- Files larger than 1 MB are rotated into `~/.ai-agents/logs/ai-shared-*.log`.
- Removed/recreated safely by rerunning the AI agents launcher.
- Never relax permissions (avoid `chmod 666`), otherwise tmux helpers will refuse to use the file.
