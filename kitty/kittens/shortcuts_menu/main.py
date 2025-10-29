"""Kitty kitten that shows an interactive shortcut palette."""

from __future__ import annotations

import curses
import subprocess
import sys
from typing import Iterable, List, Sequence, Tuple


Shortcut = Tuple[str, str]


# Extended help database
HELP_DATABASE = {
    "Ctrl+Alt+X": """Shared Tmux Session Launcher

Creates or attaches to a shared tmux session with two vertical panes.
Multiple Kitty windows can join the same session for collaborative work.

Session name: kitty-shared (configurable via KITTY_TMUX_SESSION)
Layout: even-vertical (configurable via KITTY_TMUX_LAYOUT)

To detach: Ctrl+B, then D
To create new window in tmux: Ctrl+B, then C""",

    "Ctrl+Alt+A": """Agent Terminal Overlay

Opens a dedicated overlay window for running agent commands without
interrupting your main terminal workflow.

Commands can be sent to the agent via:
- agent-terminal.sh run "command"
- agent-terminal.sh pipe < script.sh

Toggle modes with environment variables:
- KITTY_AGENT_LAUNCH_MODE=overlay (default)
- KITTY_AGENT_LAUNCH_MODE=hsplit
- KITTY_AGENT_LAUNCH_MODE=vsplit""",

    "Ctrl+Shift+/": """Shortcuts Palette

This interactive menu! Features:
- Live search by typing
- Copy shortcut with 'c' key
- View extended help with '?' key
- Navigate with arrow keys or Page Up/Down""",

    "Ctrl+Alt+M": """AI Agents Management TUI

Interactive terminal user interface for managing all AI agent features.

MAIN MENU:
1. 🚀 Start Collaboration Mode
   - Pair Programming (driver/navigator)
   - Debate (structured discussion)
   - Teaching (expert/learner)
   - Consensus (agreement required)
   - Competition (best solution wins)

2. 💾 Session Management
   - View current mode status
   - Save current session
   - Browse saved sessions
   - View session history

3. 📚 Knowledge Base
   - Add docs/snippets/decisions/patterns
   - Search knowledge base
   - Record lessons learned

4. ⚡ Quick Actions
   - Launch tmux session
   - View system status
   - Help & documentation

NAVIGATION:
• Arrow keys - Navigate menus
• Enter - Select option
• Esc/Cancel - Go back
• Tab - Switch fields in forms

FEATURES:
• Guided mode setup with prompts
• Visual status indicators
• Integration with all helper commands
• Session snapshot management
• Knowledge base browser

This TUI simplifies managing all AI agent collaboration features
through an intuitive menu-driven interface.""",

    "Ctrl+Alt+F": """fzf Session Browser (⭐ NEW!)

Interactive fuzzy finder for browsing and restoring saved AI agent sessions.

FEATURES:
• Fuzzy matching - typo-tolerant search
• Live preview - see metadata + pane contents
• Tmux popup - non-intrusive overlay (tmux 3.2+)
• Syntax highlighting - with bat/batcat
• Keyboard navigation - Ctrl-D/U/F/B

SESSION PREVIEW:
Shows session metadata (name, date, mode, description) and
first 15 lines of each agent pane.

NAVIGATION:
• Type to search (fuzzy matching)
• Arrow keys to navigate
• Enter to restore session
• Ctrl-D/U - scroll preview half-page
• Ctrl-F/B - scroll preview full-page
• Esc to cancel

EXAMPLE USAGE:
1. Press Ctrl+Alt+F
2. Type "pair prog" to find pair programming sessions
3. Arrow keys to preview different sessions
4. Enter to restore selected session

10x faster than manual ls + cat workflow!""",

    "Ctrl+Alt+K": """fzf Knowledge Base Search (⭐ NEW!)

Interactive fuzzy finder for searching and browsing the AI agents
knowledge base with syntax highlighting.

FEATURES:
• Fuzzy matching - find entries despite typos
• Live preview - syntax highlighted with bat
• Multi-select - Tab to select multiple entries
• Metadata extraction - title, type, tags from frontmatter
• Icon coding - 📄 doc, 💻 snippet, ⚖️ decision, 🔷 pattern
• Custom actions - Ctrl-O to edit, Ctrl-Y to copy

ENTRY TYPES:
📄 doc - Documentation and guides
💻 snippet - Code snippets and examples
⚖️ decision - Architecture Decision Records
🔷 pattern - Design patterns and best practices

NAVIGATION:
• Type to search (fuzzy matching)
• Arrow keys to navigate
• Tab to multi-select
• Enter to view selected entries
• Ctrl-O - open in editor
• Ctrl-Y - copy to clipboard
• Ctrl-D/U/F/B - scroll preview

EXAMPLE USAGE:
1. Press Ctrl+Alt+K
2. Type "tmux" to find tmux-related entries
3. Tab to select multiple entries
4. Enter to view all selected

Perfect for quickly finding patterns, decisions, and snippets!""",

    "Ctrl+Alt+P": """fzf Tmux Pane Switcher (⭐ NEW!)

Interactive fuzzy finder for switching between tmux panes with
live content preview.

FEATURES:
• Shows all panes across all windows
• Live preview of pane content (last 50 lines)
• Active pane indicator
• Pane metadata (window name, command, size)
• Quick switching with Enter
• Keyboard navigation

PANE INFORMATION:
• Pane ID (e.g., %0, %1, %2)
• Window name
• Current command running in pane
• Pane dimensions (width x height)
• Active status indicator (▶)

NAVIGATION:
• Type to search panes by window/command
• Arrow keys to navigate
• Enter to switch to selected pane
• Ctrl-D/U/F/B - scroll preview
• Ctrl-R - refresh pane list
• Esc to cancel

EXAMPLE USAGE:
1. Press Ctrl+Alt+P (in tmux session)
2. Type "vim" to find panes running vim
3. Arrow keys to preview pane contents
4. Enter to switch to that pane

REQUIREMENTS:
• Must be run inside a tmux session
• Works with any tmux layout
• Supports multiple windows and sessions

Perfect for quickly navigating complex tmux layouts!""",

    "Ctrl+Alt+L": """fzf Mode Quick Launcher (⭐ NEW!)

Interactive fuzzy finder for selecting and launching AI collaboration
modes with comprehensive descriptions and examples.

AVAILABLE MODES:
🎯 pair-programming - Driver/Navigator collaboration
💬 debate - Structured thesis-antithesis-synthesis
🎓 teaching - Expert teaches learner
🤝 consensus - Agreement-based collaboration
⚔️  competition - Independent solutions compared

MODE PREVIEWS:
Each mode shows:
• Concept explanation
• Role descriptions
• Best use cases
• Detailed workflow
• Example scenarios
• Launch commands

NAVIGATION:
• Type to search modes
• Arrow keys to browse
• Enter to launch selected mode
• Ctrl-D/U/F/B - scroll preview
• Esc to cancel

EXAMPLE USAGE:
1. Press Ctrl+Alt+L
2. Type "pair" to find pair programming
3. Read the preview with workflow details
4. Enter to launch the mode

MODE DESCRIPTIONS:
• Pair Programming: Real-time code review
• Debate: Explore multiple perspectives
• Teaching: Knowledge transfer session
• Consensus: Build agreement on decisions
• Competition: Compare independent solutions

Launches ai-mode-start.sh with selected mode automatically!""",

    "Ctrl+Alt+Shift+X": """Dual AI Agents Tmux Session

Creates a specialized tmux layout for running two AI agents with
shared communication capabilities.

Layout (3 panes):
  ┌─────────────────────────────────┐
  │  Agent 1 Input Terminal (30%)  │
  ├─────────────────────────────────┤
  │  Agent 2 Input Terminal (30%)  │
  ├─────────────────────────────────┤
  │  Shared Output/Comm (40%)       │
  └─────────────────────────────────┘

Communication Methods:
1. Shared File: /tmp/ai-agents-shared.txt
   - Agent 1: echo "message" > /tmp/ai-agents-shared.txt
   - Agent 2: cat /tmp/ai-agents-shared.txt
   - Shared pane shows: tail -f /tmp/ai-agents-shared.txt

2. Helper Scripts:
   - ai-agent-send.sh <agent-id> <message>
   - ai-agent-broadcast.sh <message>

Tmux Navigation:
- Ctrl+B, Arrow Keys - Switch between panes
- Ctrl+B, D - Detach from session
- Ctrl+B, [ - Enter scroll mode (q to exit)
- Ctrl+B, : - Enter tmux command mode""",
}


SHORTCUT_SECTIONS: Sequence[Tuple[str, Sequence[Shortcut]]] = (
    (
        "Reload",
        (
            ("Ctrl+Shift+F5", "Reload Kitty configuration"),
        ),
    ),
    (
        "Windows & Splits",
        (
            ("Ctrl+Shift+Enter", "New window in current directory"),
            ("Ctrl+Shift+W", "Close current window"),
            ("Ctrl+Shift+-", "Horizontal split"),
            ("Ctrl+Alt+H", "Horizontal split (AZERTY helper)"),
            ("Ctrl+Shift+=", "Vertical split"),
            ("Ctrl+Alt+V", "Vertical split (AZERTY helper)"),
            ("Ctrl+Shift+Arrow Keys", "Focus neighbouring window"),
        ),
    ),
    (
        "Tabs",
        (
            ("Ctrl+Shift+T", "Open new tab"),
            ("Ctrl+Shift+Q", "Close current tab"),
            ("Ctrl+Shift+[ / ]", "Previous / Next tab"),
            ("Ctrl+1 … Ctrl+5", "Jump directly to tab 1-5"),
            ("Ctrl+F1 … Ctrl+F5", "AZERTY tab selection"),
        ),
    ),
    (
        "Scrollback & Search",
        (
            ("Ctrl+Shift+K / J", "Scroll one line up / down"),
            ("Ctrl+Shift+PageUp / PageDown", "Scroll a full page"),
            ("Ctrl+Shift+Home / End", "Jump to start / end"),
            ("Ctrl+Shift+F", "Search scrollback"),
            ("Ctrl+Shift+H", "Open scrollback in pager"),
        ),
    ),
    (
        "Display & Appearance",
        (
            ("Ctrl+Shift++", "Increase font size"),
            ("Ctrl+Shift+Backspace", "Reset font size"),
            ("Ctrl+Alt+, / .", "Adjust opacity"),
            ("Ctrl+Alt+0", "Reset opacity to 98%"),
            ("Ctrl+Shift+F11", "Toggle fullscreen"),
            ("Ctrl+Alt+O", "Toggle transparency preset"),
            ("Ctrl+Alt+S", "Toggle scratchpad overlay"),
        ),
    ),
    (
        "System Monitoring",
        (
            ("Ctrl+Alt+M", "Start title-bar system monitor"),
            ("Ctrl+Alt+Shift+M", "Stop title-bar system monitor"),
            ("Ctrl+Shift+G", "GPU monitor (nvidia-smi loop)"),
            ("Ctrl+Shift+S", "Sensors monitor (lm-sensors loop)"),
        ),
    ),
    (
        "Clipboard",
        (
            ("Ctrl+Shift+C", "Copy to clipboard"),
            ("Ctrl+Shift+V", "Paste from clipboard"),
            ("Shift+Insert", "Paste from selection"),
            ("Middle Click", "Paste selection (mouse)"),
            ("Ctrl+Alt+V", "Paste selection (keyboard)"),
            ("Ctrl+Shift+Alt+V", "Force clipboard paste"),
            ("Ctrl+Shift+Alt+C", "Copy and clear / send interrupt"),
            ("Ctrl+Shift+P", "Paste without newlines"),
            ("Ctrl+Shift+Alt+P", "Clipboard manager overlay"),
        ),
    ),
    (
        "Utilities",
        (
            ("Ctrl+Shift+I", "Image viewer overlay"),
            ("Ctrl+Shift+Space", "Command palette (hints kitten)"),
            ("Ctrl+Shift+/", "Show shortcut palette"),
            ("Ctrl+Shift+Escape", "Kitty shell window"),
            ("Ctrl+Shift+U", "Unicode input"),
            ("Ctrl+Alt+A", "Toggle agent overlay"),
            ("Ctrl+Alt+Shift+A", "Focus agent overlay"),
            ("Ctrl+Alt+Shift+H", "Toggle agent split (horizontal)"),
            ("Ctrl+Alt+Shift+V", "Toggle agent split (vertical)"),
            ("Ctrl+Alt+X", "Launch shared tmux session"),
            ("Ctrl+Alt+M", "AI Agents Management TUI"),
            ("Ctrl+Alt+F", "fzf Session Browser ⭐"),
            ("Ctrl+Alt+K", "fzf Knowledge Base Search ⭐"),
            ("Ctrl+Alt+P", "fzf Tmux Pane Switcher ⭐"),
            ("Ctrl+Alt+L", "fzf Mode Quick Launcher ⭐"),
            ("Ctrl+Alt+Shift+X", "Launch dual AI agents tmux"),
        ),
    ),
    (
        "Metadata",
        (
            ("Theme", "True Neon (Electric Cyan / Hot Pink)"),
            ("Security", "A+ hardened paste / remote control"),
        ),
    ),
)


def flattened_entries(query: str) -> Tuple[List[Tuple[str, str, str]], List[int]]:
    """Return (entries, item_indices).

    entries: list of tuples (kind, title, subtitle) where kind is "category" or "item".
    item_indices: indices into entries for selectable rows.
    """

    q = query.casefold()
    entries: List[Tuple[str, str, str]] = []
    item_positions: List[int] = []

    for category, shortcuts in SHORTCUT_SECTIONS:
        matches: List[Shortcut]
        if q:
            matches = [s for s in shortcuts if q in s[0].casefold() or q in s[1].casefold()]
            if not matches:
                continue
        else:
            matches = list(shortcuts)

        entries.append(("category", category, ""))
        for combo, description in matches:
            entries.append(("item", combo, description))
            item_positions.append(len(entries) - 1)

    if not entries:
        entries.append(("empty", "No shortcuts found", ""))

    return entries, item_positions


def copy_to_clipboard(text: str) -> bool:
    """Copy text to system clipboard using available tools."""
    try:
        # Try wl-copy first (Wayland)
        try:
            subprocess.run(['wl-copy'], input=text.encode(), check=True, timeout=2)
            return True
        except (FileNotFoundError, subprocess.TimeoutExpired):
            pass

        # Try xclip (X11)
        try:
            subprocess.run(['xclip', '-selection', 'clipboard'],
                          input=text.encode(), check=True, timeout=2)
            return True
        except (FileNotFoundError, subprocess.TimeoutExpired):
            pass

        # Try xsel (X11 fallback)
        try:
            subprocess.run(['xsel', '--clipboard', '--input'],
                          input=text.encode(), check=True, timeout=2)
            return True
        except (FileNotFoundError, subprocess.TimeoutExpired):
            pass

        return False
    except Exception:
        return False


def show_help_overlay(stdscr, combo: str) -> None:
    """Show extended help for a shortcut in full-screen overlay."""
    help_text = HELP_DATABASE.get(combo, "No extended help available for this shortcut.")

    while True:
        stdscr.erase()
        height, width = stdscr.getmaxyx()

        # Title
        title = f" Help: {combo} "
        if len(title) < width:
            stdscr.addstr(0, max(0, (width - len(title)) // 2), title, curses.A_BOLD)

        # Draw separator
        if height > 2:
            stdscr.hline(1, 0, curses.ACS_HLINE, width)

        # Display help text
        lines = help_text.strip().split('\n')
        start_y = 3
        for i, line in enumerate(lines):
            if start_y + i < height - 3:
                display_line = line[:width-2]
                try:
                    stdscr.addstr(start_y + i, 1, display_line)
                except curses.error:
                    pass  # Ignore if we run out of screen space

        # Footer
        if height > 2:
            stdscr.hline(height - 2, 0, curses.ACS_HLINE, width)
            footer = "Press any key to return"
            if len(footer) < width:
                stdscr.addstr(height - 1, max(0, (width - len(footer)) // 2),
                             footer, curses.A_DIM)

        stdscr.refresh()

        # Wait for any key
        try:
            stdscr.getch()
            break
        except KeyboardInterrupt:
            break


def draw_menu(
    stdscr,
    entries: List[Tuple[str, str, str]],
    item_positions: List[int],
    selection_idx: int,
    query: str,
    top: int,
) -> int:
    stdscr.erase()
    stdscr.nodelay(False)
    stdscr.keypad(True)

    height, width = stdscr.getmaxyx()
    box_width = min(90, max(50, width - 4))
    box_height = min(max(12, len(entries) + 5), height - 2)
    offset_y = max(0, (height - box_height) // 2)
    offset_x = max(0, (width - box_width) // 2)

    window = stdscr.derwin(box_height, box_width, offset_y, offset_x)
    window.box()
    title = " Kitty Shortcut Palette "
    window.addstr(0, max(1, (box_width - len(title)) // 2), title, curses.A_BOLD)

    filter_line = f"Filter: {query}" if query else "Filter: (type to search)"
    window.addstr(1, 2, filter_line[: box_width - 4], curses.A_DIM)
    window.hline(2, 1, curses.ACS_HLINE, box_width - 2)

    viewport_height = box_height - 5
    start_line = max(0, min(top, max(0, len(entries) - viewport_height)))
    end_line = min(len(entries), start_line + viewport_height)

    line_y = 3
    for idx in range(start_line, end_line):
        kind, primary, secondary = entries[idx]
        text_y = line_y + (idx - start_line)
        if kind == "category":
            display = f" {primary} "
            window.addstr(text_y, 2, display[: box_width - 4], curses.A_BOLD | curses.color_pair(2))
            continue
        if kind == "empty":
            window.addstr(text_y, 2, primary[: box_width - 4], curses.A_DIM)
            continue

        combo = primary
        desc = secondary
        line = f"{combo:<24} {desc}"
        attr = curses.A_NORMAL
        if item_positions:
            selected_line = item_positions[selection_idx]
            if idx == selected_line:
                attr = curses.A_REVERSE | curses.A_BOLD
        window.addstr(text_y, 2, line[: box_width - 4], attr)

    window.hline(box_height - 2, 1, curses.ACS_HLINE, box_width - 2)
    footer = "↑/↓ Navigate  •  c Copy  •  ? Help  •  Enter/Esc Exit"
    window.addstr(box_height - 2, max(1, (box_width - len(footer)) // 2), footer[: box_width - 2], curses.A_DIM)

    stdscr.refresh()
    return viewport_height


def run_palette(stdscr) -> None:
    curses.curs_set(0)
    curses.start_color()
    curses.use_default_colors()
    curses.init_pair(1, curses.COLOR_BLACK, curses.COLOR_CYAN)
    curses.init_pair(2, curses.COLOR_CYAN, -1)

    query = ""
    entries, item_positions = flattened_entries(query)
    selection_idx = 0
    top = 0

    while True:
        if item_positions:
            selection_idx = max(0, min(selection_idx, len(item_positions) - 1))
            selected_line = item_positions[selection_idx]
        else:
            selected_line = 0

        viewport_height = draw_menu(
            stdscr,
            entries,
            item_positions,
            selection_idx,
            query,
            top,
        )
        if selected_line < top:
            top = selected_line
        elif selected_line >= top + viewport_height:
            top = selected_line - viewport_height + 1


        key = stdscr.get_wch()

        if isinstance(key, str):
            if key in ("\n", "\r"):
                break
            if key in ("\x1b", "\u001b"):
                if query:
                    query = ""
                    entries, item_positions = flattened_entries(query)
                    selection_idx = 0
                    top = 0
                    continue
                break

            # Copy shortcut combo to clipboard
            if key in ('c', 'C') and item_positions:
                selected_line = item_positions[selection_idx]
                kind, combo, desc = entries[selected_line]
                if kind == "item":
                    if copy_to_clipboard(combo):
                        # Flash success message
                        try:
                            height, width = stdscr.getmaxyx()
                            msg = "✓ Copied to clipboard!"
                            stdscr.addstr(height - 1, max(0, (width - len(msg)) // 2),
                                        msg, curses.A_BOLD | curses.color_pair(2))
                            stdscr.refresh()
                            curses.napms(800)  # 0.8 second flash
                        except curses.error:
                            pass
                continue

            # Show extended help
            if key in ('?',) and item_positions:
                selected_line = item_positions[selection_idx]
                kind, combo, desc = entries[selected_line]
                if kind == "item":
                    show_help_overlay(stdscr, combo)
                continue
            if key in ("\x7f", "\b"):
                query = query[:-1]
                entries, item_positions = flattened_entries(query)
                selection_idx = 0
                top = 0
                continue
            if key.isprintable():
                query += key
                entries, item_positions = flattened_entries(query)
                selection_idx = 0
                top = 0
                continue
        else:  # numeric keys (curses key codes)
            if key in (curses.KEY_UP,):
                if item_positions:
                    selection_idx = (selection_idx - 1) % len(item_positions)
                continue
            if key in (curses.KEY_DOWN,):
                if item_positions:
                    selection_idx = (selection_idx + 1) % len(item_positions)
                continue
            if key == curses.KEY_PPAGE:
                if item_positions:
                    selection_idx = max(0, selection_idx - 5)
                continue
            if key == curses.KEY_NPAGE:
                if item_positions:
                    selection_idx = min(len(item_positions) - 1, selection_idx + 5)
                continue
            if key in (curses.KEY_BACKSPACE,):
                query = query[:-1]
                entries, item_positions = flattened_entries(query)
                selection_idx = 0
                top = 0
                continue


def main(args: Iterable[str]) -> None:
    curses.wrapper(run_palette)


def handle_result(*args, **kwargs):  # pragma: no cover - required entry point
    """Compatibility shim for kitty's kitten loader."""
    return None
