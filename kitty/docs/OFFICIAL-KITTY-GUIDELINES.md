# Kitty Terminal - Official Configuration Guidelines

**Source**: Official Kitty Documentation (https://sw.kovidgoyal.net/kitty/)
**Date Compiled**: 2025-10-29
**Purpose**: Reference guide for proper Kitty configuration based on official documentation

---

## Table of Contents

1. [Keyboard Mapping](#keyboard-mapping)
2. [Mappable Actions Reference](#mappable-actions-reference)
3. [Remote Control](#remote-control)
4. [Custom Kitten Development](#custom-kitten-development)
5. [Best Practices](#best-practices)
6. [Common Patterns](#common-patterns)

---

## Keyboard Mapping

### Basic Syntax

**Source**: https://sw.kovidgoyal.net/kitty/mapping/

The fundamental mapping structure:

```conf
map modifier+key action
```

**Components**:
- **Modifiers**: `ctrl`, `shift`, `alt`, `super`, `opt`, `cmd`
- **Keys**: Lowercase Unicode characters (`a`, `[`), functional keys (`enter`, `escape`, `f1`-`f12`)
- **kitty_mod**: Alias that defaults to `ctrl+shift`

### Multi-Action Mappings

Combine multiple actions with the `combine` directive:

```conf
map key combine : action1 : action2 : action3
```

**Example**:
```conf
map kitty_mod+e combine : new_window : next_layout
```

This creates a window and switches layouts simultaneously.

### Multi-Key Sequences

Chain keypresses using the `>` operator:

```conf
map key1>key2>key3 action
```

**Example**:
```conf
map ctrl+a>c new_window
map ctrl+a>n next_window
```

Press Ctrl+A, release, then press C to create new window.

### Conditional Mappings

Restrict mappings based on window state:

```conf
map --when-focus-on title:window_title kitty_mod+t
map --when-focus-on var:in_editor kitty_mod+c
```

**Use Cases**:
- Disable copy in text editors to pass command through to editor
- Context-sensitive shortcuts based on window title or environment variables

### Modal Mappings

Define custom keyboard modes similar to Vim:

```conf
# Create new mode 'mw' (window management)
map --new-mode mw kitty_mod+f7

# Bindings active only in 'mw' mode
map --mode mw left neighboring_window left
map --mode mw right neighboring_window right
map --mode mw up neighboring_window up
map --mode mw down neighboring_window down
map --mode mw esc pop_keyboard_mode
```

**Control options**:
- `--on-unknown` (beep, ignore, end, passthrough): Behavior for unmapped keys
- `--on-action` (end, ignore): What happens after action execution

### Sending Text and Keys

Send literal text or key sequences:

```conf
# Send text (supports ANSI-C escape sequences)
map f1 send_text normal,application Hello, world!\r

# Send key combinations
map alt+s send_key ctrl+s
```

### Unmapping Defaults

Remove default shortcuts:

```conf
# Unmap a single key
map kitty_mod+enter

# Clear all default mappings
clear_all_shortcuts yes
```

**Note**: Leaving the action empty unmaps the key.

### Debugging Keybindings

**Debug system events**:
```bash
kitty --debug-input
```

**Debug terminal events**:
```bash
kitten show-key
```

---

## Mappable Actions Reference

**Source**: https://sw.kovidgoyal.net/kitty/actions/

Complete list of all actions that can be mapped to keys. Organized by category:

### Copy/Paste Actions

| Action | Description |
|--------|-------------|
| `copy_to_clipboard` | Copy the selected text from the active window to the clipboard |
| `paste_from_clipboard` | Insert clipboard contents |
| `paste_from_selection` | Insert primary selection or clipboard fallback |
| `copy_or_interrupt` | Copy text or send Ctrl+C if nothing is selected |
| `copy_and_clear_or_interrupt` | Copy selection and clear it, or send interrupt signal |
| `copy_ansi_to_clipboard` | Copy selected text preserving ANSI formatting codes |
| `paste` | Insert specified text (with ANSI C escape decoding) |
| `pass_selection_to_program` | Route selected text to a specified external program |
| `copy_to_buffer` | Store selection in a designated buffer |
| `paste_from_buffer` | Retrieve text from a specified paste buffer |

### Window Management

| Action | Description |
|--------|-------------|
| `new_window` | Create additional window in current tab |
| `new_window_with_cwd` | Create new window with same working directory |
| `close_window` | Close active window |
| `close_window_with_confirmation` | Close active window after confirmation |
| `neighboring_window left/right/up/down` | Focus adjacent window |
| `next_window` | Focus the next window in the current tab |
| `previous_window` | Focus preceding window |
| `nth_window` | Focus specific window by position or history |
| `move_window left/right/up/down` | Relocate window directionally within layout |
| `move_window_forward` / `move_window_backward` | Swap window position sequentially |
| `move_window_to_top` | Move active window to the top (first position) |
| `resize_window taller/shorter/wider/narrower` | Adjust window dimensions |
| `reset_window_sizes` | Undo dynamic window resizing |
| `start_resizing_window` | Initiate interactive window resizing |
| `swap_with_window` | Exchange current window with visually selected window |
| `focus_visible_window` | Enable numbered selection mode for window focus |

### Tab Management

| Action | Description |
|--------|-------------|
| `new_tab` | Create additional tab |
| `new_tab_with_cwd` | Create new tab with same working directory |
| `close_tab` | Close current tab |
| `next_tab` | Activate subsequent tab |
| `previous_tab` | Activate preceding tab |
| `goto_tab N` | Switch to numbered tab (1-indexed) |
| `move_tab_forward` / `move_tab_backward` | Reorder tab position |
| `set_tab_title` | Change tab name interactively or via argument |
| `toggle_tab` | Switch between current and previously viewed tab |
| `detach_tab` | Move tab to different OS window |

### Layout Management

| Action | Description |
|--------|-------------|
| `goto_layout NAME` | Switch to the named layout |
| `next_layout` | Advance through enabled layouts |
| `last_used_layout` | Go to the previously used layout |
| `toggle_layout NAME` | Alternate between named layout and previous layout |
| `layout_action` | Execute layout-specific operations |

### Scrolling Actions

| Action | Description |
|--------|-------------|
| `scroll_line_up` / `scroll_line_down` | Move view by single line |
| `scroll_page_up` / `scroll_page_down` | Move view by full page |
| `scroll_home` / `scroll_end` | Jump to buffer extremes |
| `scroll_to_prompt -1/+1` | Scroll to previous/next shell command prompt |
| `show_scrollback` | Display scrollback using a pager interface |
| `show_last_command_output` | Show output from the last shell command in pager |

### Display & Appearance

| Action | Description |
|--------|-------------|
| `change_font_size all +2.0` | Modify text size (supports +/- values) |
| `set_background_opacity +0.05` | Adjust transparency level |
| `toggle_fullscreen` | Alternate fullscreen mode |
| `toggle_maximized` | Alternate maximized state |
| `set_window_title` | Change window name interactively or via argument |

### Program Launch

| Action | Description |
|--------|-------------|
| `launch` | Launch the specified program in a new window/tab/etc |
| `open_url` | Open specified URL |
| `open_url_with_hints` | Click a URL using the keyboard |

### Configuration & Utility

| Action | Description |
|--------|-------------|
| `edit_config_file` | Open kitty.conf in default editor |
| `load_config_file` | Reload configuration (replaces all settings) |
| `debug_config` | Show the effective configuration kitty is running with |
| `kitty_shell` | Run the kitty shell to control kitty with commands |
| `kitten NAME` | Run the specified kitten |

### Keyboard Mode Actions

| Action | Description |
|--------|-------------|
| `push_keyboard_mode NAME` | Switch to the specified keyboard mode, pushing onto stack |
| `pop_keyboard_mode` | End the current keyboard mode, switching to previous |
| `grab_keyboard` | Intercept global OS shortcuts (platform limitations apply) |
| `ungrab_keyboard` | Release keyboard grab |

### Remote Control

| Action | Description |
|--------|-------------|
| `remote_control COMMAND` | Execute remote control command without enabling full remote access |
| `remote_control_script PATH` | Run remote control script file with arguments |

### Terminal Control

| Action | Description |
|--------|-------------|
| `clear_terminal reset` | Reset terminal to initial state |
| `clear_terminal clear` | Clear screen (preserves scrollback) |
| `clear_terminal scrollback` | Clear scrollback buffer only |
| `signal_child SIGNAME` | Send the specified SIGNAL to the foreground process |

### Miscellaneous

| Action | Description |
|--------|-------------|
| `combine` | Combine multiple actions and map to a single keypress |
| `no_op` | Unbind a shortcut (passes keystroke to terminal) |
| `discard_event` | Ignore keystroke completely |
| `quit` | Quit, closing all windows |
| `sleep 1.5s` | Pause execution (supports s/m/h/d suffixes) |

---

## Remote Control

**Source**: https://sw.kovidgoyal.net/kitty/remote-control/

### Setup & Security

#### Basic Configuration

Enable remote control in `kitty.conf`:

```conf
allow_remote_control yes
```

**WARNING**: This allows any process to control kitty. Use only in trusted environments.

#### Socket-Based Control (Recommended)

Start kitty with a socket for external control:

```bash
kitty --listen-on unix:/tmp/mykitty
```

Then control from outside:

```bash
kitten @ --to unix:/tmp/mykitty ls
```

#### Password-Protected Access (Most Secure)

Configure password-based authentication in `kitty.conf`:

```conf
# Allow specific commands with password
remote_control_password "control colors" get-colors set-colors

# Allow all commands with password
remote_control_password "full access" *
```

Use the password:

```bash
kitten @ --password="control colors" set-colors background=red
```

**Password Storage**:
- Environment variable: `KITTY_RC_PASSWORD`
- File-based: `~/.config/kitty/rc-pass`
- Interactive prompts for unknown passwords

#### Custom Authorization Scripts

For fine-grained control, create `~/.config/kitty/my_rc_auth.py`:

```python
def is_cmd_allowed(pcmd, window, from_socket, extra_data):
    """
    Args:
        pcmd: Dict with 'cmd' (command name) and 'payload' (arguments)
        window: Current window object (None if from socket)
        from_socket: Boolean, True if command from socket
        extra_data: User-provided data from command

    Returns:
        bool: True to allow, False to deny
    """
    cmd_name = pcmd['cmd']

    # Example: Block dangerous commands from socket
    if from_socket and cmd_name in ['launch', 'send-text']:
        return False

    # Example: Allow only specific windows
    if window and window.title != 'trusted':
        return False

    return True
```

Configure in `kitty.conf`:
```conf
remote_control_password "custom" my_rc_auth.py
```

### Core Commands

#### Window Management

```bash
# Create new window
kitten @ launch --title "Output" --cwd ~/projects

# Focus specific window
kitten @ focus-window --match title:Output

# Close windows matching criteria
kitten @ close-window --match state:focused
```

#### Text Operations

```bash
# Send text to window
kitten @ send-text --match title:Output "Hello, world!\n"

# Send text from stdin
echo "Command output" | kitten @ send-text --match title:Output --stdin

# Get text from window
kitten @ get-text --match title:Output
```

#### Configuration

```bash
# Change colors dynamically
kitten @ set-colors background=red foreground=white

# Get current colors
kitten @ get-colors

# Change font size
kitten @ set-font-size 14
```

#### Information Gathering

```bash
# List all windows/tabs/OS windows (JSON output)
kitten @ ls

# Parse with jq
kitten @ ls | jq '.[] | .tabs[].windows[] | {id, title}'

# Show environment variables
kitten @ show-kitty-env-vars
```

### Window & Tab Matching

Matching uses expressions like `field:query`:

**Window Fields**:
- `id`: Window ID number
- `title`: Window title (regex supported)
- `pid`: Process ID
- `cwd`: Current working directory
- `cmdline`: Command line
- `num`: Window number in tab
- `env:VAR`: Environment variable value
- `var:NAME`: User-defined variable
- `state`: Window state (focused, parent_active, etc.)
- `neighbor`: Relative position (left, right, top, bottom)
- `recent`: Recently focused window (0 = current, 1 = previous)

**Tab Fields**:
- `id`: Tab ID
- `index`: Tab index
- `title`: Tab title
- `window_id`: ID of window in tab
- `window_title`: Title of window in tab
- `pid`, `cwd`, `cmdline`, `env`, `var`, `state`: Same as window fields

**Boolean Operators**:
```bash
# AND operator
kitten @ focus-window --match 'title:bash and env:USER=kovid'

# OR operator
kitten @ close-tab --match 'title:Output or title:Debug'

# NOT operator
kitten @ close-tab --match 'not state:focused and state:parent_focused'
```

### Usage Patterns

#### Within Kitty Windows

Commands work directly without `--to`:

```bash
kitten @ launch --title Output --keep-focus cat
ls | kitten @ send-text --match 'title:^Output' --stdin
```

#### From External Scripts

Use socket addressing:

```bash
kitten @ --to unix:/tmp/mykitty new-window --title External
```

#### Keyboard Shortcuts

Map remote control to keybindings in `kitty.conf`:

```conf
# Execute remote control command
map f1 remote_control set-spacing margin=30

# Run remote control script
map f2 remote_control_script /path/to/script.sh

# Launch program with remote control enabled
map f3 launch --allow-remote-control my_program
```

### Remote Control Best Practices

1. **Security First**
   - Use password-based authentication for untrusted environments
   - Avoid blanket `allow_remote_control` in multi-user systems
   - Use custom authorization scripts for fine-grained control
   - Prefer socket-only mode over network sockets

2. **Match Specificity**
   - Use precise field matching rather than broad patterns
   - Prevent unintended window selection with specific IDs or titles
   - Test matches with `kitten @ ls` before destructive operations

3. **Error Handling**
   - Prefix commands with `!` to suppress errors in keybindings:
     ```conf
     map f1 remote_control !focus-window --match INVALID
     ```
   - Check exit codes in scripts for error handling

4. **JSON Parsing**
   - The `ls` command outputs parseable JSON
   - Use tools like `jq` for scripting:
     ```bash
     kitten @ ls | jq '.[] | .tabs[].id'
     ```

5. **Over SSH**
   - Commands work transparently over SSH when inside kitty windows
   - Use the ssh kitten for automatic setup
   - Remote control requires no special configuration for SSH

---

## Custom Kitten Development

**Source**: https://sw.kovidgoyal.net/kitty/kittens/custom/

### Overview

Kittens are Python-based terminal programs that extend kitty's functionality. They run in overlay windows and can access kitty's internal APIs.

### Basic Structure

A minimal kitten requires two functions:

```python
from kitty.boss import Boss

def main(args: list[str]) -> str:
    """
    Main entry point - runs in overlay window.

    Args:
        args: Command-line arguments

    Returns:
        Data to pass to handle_result()
    """
    answer = input('Enter some text: ')
    return answer

def handle_result(args: list[str], answer: str,
                  target_window_id: int, boss: Boss) -> None:
    """
    Result handler - runs in kitty process after main() completes.

    Args:
        args: Command-line arguments
        answer: Return value from main()
        target_window_id: ID of the window that launched the kitten
        boss: Kitty instance for performing actions
    """
    w = boss.window_id_map.get(target_window_id)
    if w is not None:
        w.paste_text(answer)
```

**Add to kitty.conf**:
```conf
map ctrl+k kitten ~/.config/kitty/kittens/mykitten.py
```

### Remote Control API Access

Access kitty's remote control commands within kittens:

```python
def handle_result(args: list[str], answer: str,
                  target_window_id: int, boss: Boss) -> None:
    w = boss.window_id_map.get(target_window_id)
    if w is not None:
        # Call remote control command
        boss.call_remote_control(w, ('send-text',
                                     f'--match=id:{w.id}',
                                     'Hello from kitten!'))
```

### Passing Arguments

Arguments from keybindings are available as `args` parameter:

```conf
map ctrl+k kitten mykitten.py arg1 arg2
```

**Special token** `@selection` inserts currently selected text:

```conf
map ctrl+k kitten mykitten.py @selection
```

### Screen Content Access

Access window content by annotating `handle_result()`:

```python
from kittens.tui.handler import result_handler

@result_handler(type_of_input='text')
def handle_result(args: list[str], stdin_data: str,
                  target_window_id: int, boss: Boss) -> None:
    """stdin_data contains the active window's screen content"""
    lines = stdin_data.split('\n')
    # Process screen content
    pass
```

**Available Input Types**:
- `text` - Active window content (plain text)
- `ansi` - Active window content (with ANSI formatting)
- `history` - Content with scrollback (plain text)
- `ansi-history` - Content with scrollback (ANSI)
- `output` - Last command output (plain text)
- `output-ansi` - Last command output (ANSI)
- `selection` - Currently selected text

### UI-Free Scripting

Run `handle_result()` directly without displaying a terminal window:

```python
from kittens.tui.handler import result_handler

@result_handler(no_ui=True)
def handle_result(args: list[str], answer: str,
                  target_window_id: int, boss: Boss) -> None:
    """Runs immediately without showing overlay window"""
    tab = boss.active_tab
    if tab is not None:
        tab.goto_layout('stack')
```

**Use Case**: Quick actions that don't need user input.

### Remote Control in main()

Enable remote control access within the main function:

```python
from kittens.tui.handler import kitten_ui

@kitten_ui(allow_remote_control=True)
def main(args: list[str]) -> str:
    """Can call remote control commands from within overlay"""
    cp = main.remote_control(['ls'], capture_output=True)
    return cp.stdout
```

### Mouse Event Simulation

Simulate mouse clicks programmatically:

```python
from kitty.fast_data_types import send_mouse_event, PRESS, RELEASE
from kitty.constants import mod_mask

# Send left click at position (10, 5)
send_mouse_event(boss.active_window.screen,
                 x=10, y=5,
                 button=1,  # 1=left, 2=middle, 3=right, 4=scroll_up, 5=scroll_down
                 action=PRESS,
                 mods=0)  # mod_mask.CTRL | mod_mask.SHIFT for modifiers

# Release the button
send_mouse_event(boss.active_window.screen,
                 x=10, y=5,
                 button=1,
                 action=RELEASE,
                 mods=0)
```

### Configuration Options

Create configurable kittens using `kitten_options_definition.py`:

```python
from kitty.conf.types import Option

# Define options
options = (
    Option('my_option', '42', option_type='int',
           help_text='Description of my_option'),
    Option('my_color', '#ffffff', option_type='color',
           help_text='A color option'),
)
```

Generate option modules:

```bash
kitty +runpy 'from kitty.conf.generate import main; main()' \
  /path/to/kitten_options_definition.py
```

### Debugging

**In main() function**:
- Use `print()` statements (visible in kitten window)
- Output appears in the overlay terminal

**In handle_result() function**:
- Use the debug function:
  ```python
  from kittens.tui.loop import debug
  debug('This appears in kitty process STDOUT')
  ```

### Development Tips

1. **Study Built-in Kittens**
   - Examine kittens in the [kitty GitHub repository](https://github.com/kovidgoyal/kitty/tree/master/kittens)
   - The diff kitten is a good advanced example

2. **File Location**
   - Place custom kittens in `~/.config/kitty/kittens/`
   - Reference them in kitty.conf as `kitten ~/.config/kitty/kittens/name.py`

3. **Testing**
   - Test kittens directly: `kitty +kitten mykitten.py`
   - Use `--debug-keyboard` to see key events in overlay

4. **Error Handling**
   - Wrap main() code in try/except for graceful error messages
   - Use `handle_result()` to show errors in kitty process

### Example: Advanced Kitten Template

```python
from typing import List
from kitty.boss import Boss
from kittens.tui.handler import result_handler

@result_handler(type_of_input='text', no_ui=False)
def handle_result(args: List[str], screen_text: str,
                  target_window_id: int, boss: Boss) -> None:
    """
    Process screen content and perform actions.

    Args:
        args: Command-line arguments
        screen_text: Content from active window
        target_window_id: ID of launching window
        boss: Kitty instance
    """
    try:
        w = boss.window_id_map.get(target_window_id)
        if w is None:
            return

        # Process screen content
        lines = screen_text.split('\n')

        # Perform action based on content
        if 'ERROR' in screen_text:
            boss.call_remote_control(w, ('set-colors', 'background=red'))
        else:
            boss.call_remote_control(w, ('set-colors', 'background=green'))

    except Exception as e:
        from kittens.tui.loop import debug
        debug(f'Kitten error: {e}')

def main(args: List[str]) -> str:
    """
    Optional main function for user interaction.
    If omitted with no_ui=True, handle_result runs immediately.
    """
    return input('Enter action: ')
```

---

## Best Practices

### Keybinding Design

1. **Use Semantic Grouping**
   - Group related functions under similar key patterns
   - Example: All window operations use Ctrl+Shift, tab operations use Ctrl+Alt

2. **Avoid Conflicts**
   - Check `kitty --debug-input` to see what keys are being sent
   - Test on your specific keyboard layout (QWERTY vs AZERTY)
   - Don't rely on symbols that move between layouts

3. **Provide Alternatives**
   - Map important functions to multiple keys
   - Use F-keys as universal fallbacks
   - Create keyboard layout-specific alternatives

4. **Document Keybindings**
   - Add comments in kitty.conf explaining non-obvious bindings
   - Create a shortcuts kitten or documentation for users
   - Keep a reference of modal mode bindings

### Configuration Management

1. **Modular Configuration**
   ```conf
   # Main kitty.conf
   include ./kitty.d/core.conf
   include ./kitty.d/keybindings.conf
   include ./kitty.d/theme.conf
   ```

2. **Version Control**
   - Keep kitty config in git repository
   - Use separate branches for experimental changes
   - Document changes in commit messages

3. **Sync Across Machines**
   - Create sync scripts for repository ↔ live config
   - Use Makefile for common operations
   - Test changes before syncing to live config

### Remote Control Security

1. **Never use `allow_remote_control yes` in production**
2. **Always use password-based authentication or custom scripts**
3. **Use socket-only mode (unix sockets, not TCP)**
4. **Restrict commands with password glob patterns**
5. **Audit remote control usage periodically**

### Kitten Development

1. **Start Simple**
   - Begin with `no_ui=True` for script-like kittens
   - Add UI only when user interaction needed
   - Test handle_result() logic before adding main()

2. **Error Handling**
   - Always check if window exists before accessing
   - Use try/except blocks in handle_result()
   - Provide useful error messages with debug()

3. **Performance**
   - Minimize work in handle_result() (runs in main kitty process)
   - Do heavy processing in main() (runs in separate process)
   - Use remote control API instead of direct boss manipulation when possible

---

## Common Patterns

### Pattern 1: Context-Aware Keybindings

```conf
# Copy works normally in terminal
map ctrl+shift+c copy_to_clipboard

# But in vim, pass through to vim
map --when-focus-on var:in_vim ctrl+shift+c no_op
```

Set `in_vim` variable from vim config:
```vim
let &t_ti = "\e]1337;SetUserVar=in_vim=MQo\x07" . &t_ti
let &t_te = "\e]1337;SetUserVar=in_vim\x07" . &t_te
```

### Pattern 2: Scratchpad/Dropdown Terminal

```conf
# Toggle scratchpad window
map f12 launch --type=overlay --title Scratchpad
```

Or with a script for persistent scratchpad:

```bash
#!/bin/bash
# toggle-scratchpad.sh
if kitty @ ls | grep -q "Scratchpad"; then
    kitty @ close-window --match title:Scratchpad
else
    kitty @ launch --type=overlay --title Scratchpad --cwd ~
fi
```

```conf
map f12 launch --type=background toggle-scratchpad.sh
```

### Pattern 3: Smart Copy/Paste

```conf
# Copy selection, or if nothing selected, send Ctrl+C (interrupt)
map ctrl+c copy_or_interrupt

# Copy and clear selection, or send interrupt
map ctrl+shift+c copy_and_clear_or_interrupt

# Paste without newlines (useful for multi-line commands)
map ctrl+shift+v combine : paste_from_clipboard : send_text all \x20
```

### Pattern 4: Project-Specific Layouts

```conf
# Development layout
map f1 combine : new_tab : launch --title Editor : launch --location=hsplit --title Terminal : launch --location=vsplit --title Logs

# Quick switch to project
map f2 launch --type=tab --title MyProject --cwd ~/projects/myproject
```

### Pattern 5: Enhanced Scrollback Search

```conf
# Search scrollback
map ctrl+shift+f search

# Quick scroll to last command output
map ctrl+shift+g show_last_command_output

# Show scrollback in pager
map ctrl+shift+h show_scrollback
```

### Pattern 6: Agent/Assistant Terminal

```bash
#!/bin/bash
# agent-terminal.sh
TITLE="Agent"
MATCH="title:^${TITLE}$"

if kitty @ ls --match "$MATCH" 2>/dev/null | grep -q "title"; then
    kitty @ close-window --match "$MATCH"
else
    kitty @ launch --type=overlay --title "$TITLE" --keep-focus
fi
```

```conf
map ctrl+alt+a launch --type=background agent-terminal.sh
```

Send commands to agent:

```bash
echo "git status" | kitty @ send-text --match 'title:^Agent$' --stdin
```

### Pattern 7: Dynamic Theme Switching

```bash
#!/bin/bash
# toggle-dark-light.sh
current_bg=$(kitty @ get-colors | grep '^background' | cut -d' ' -f2)

if [[ "$current_bg" =~ ^#[0-9a-f]{2}[0-9a-f]{2}[0-9a-f]{2}$ ]]; then
    # Convert hex to decimal RGB
    r=$((16#${current_bg:1:2}))
    g=$((16#${current_bg:3:2}))
    b=$((16#${current_bg:5:2}))

    # Calculate luminance
    lum=$(( (r * 299 + g * 587 + b * 114) / 1000 ))

    if (( lum > 128 )); then
        # Light theme, switch to dark
        kitty @ set-colors --all ~/.config/kitty/themes/dark.conf
    else
        # Dark theme, switch to light
        kitty @ set-colors --all ~/.config/kitty/themes/light.conf
    fi
fi
```

```conf
map f9 launch --type=background toggle-dark-light.sh
```

### Pattern 8: Window Management Mode

```conf
# Enter window management mode
map --new-mode window_mgmt ctrl+w

# Window management bindings (active only in window_mgmt mode)
map --mode window_mgmt h neighboring_window left
map --mode window_mgmt l neighboring_window right
map --mode window_mgmt k neighboring_window up
map --mode window_mgmt j neighboring_window down

map --mode window_mgmt shift+h move_window left
map --mode window_mgmt shift+l move_window right
map --mode window_mgmt shift+k move_window up
map --mode window_mgmt shift+j move_window down

map --mode window_mgmt n new_window
map --mode window_mgmt c close_window
map --mode window_mgmt r start_resizing_window

map --mode window_mgmt esc pop_keyboard_mode
map --mode window_mgmt enter pop_keyboard_mode
```

Usage: Press Ctrl+W, then use H/J/K/L for navigation. Press Esc to exit mode.

---

## Reference Links

### Official Documentation
- **Main Documentation**: https://sw.kovidgoyal.net/kitty/
- **Configuration Reference**: https://sw.kovidgoyal.net/kitty/conf/
- **Keyboard Mapping**: https://sw.kovidgoyal.net/kitty/mapping/
- **Mappable Actions**: https://sw.kovidgoyal.net/kitty/actions/
- **Remote Control**: https://sw.kovidgoyal.net/kitty/remote-control/
- **Remote Control Protocol**: https://sw.kovidgoyal.net/kitty/rc_protocol/
- **Custom Kittens**: https://sw.kovidgoyal.net/kitty/kittens/custom/
- **Built-in Kittens**: https://sw.kovidgoyal.net/kitty/kittens_intro/

### Community Resources
- **GitHub Repository**: https://github.com/kovidgoyal/kitty
- **Issue Tracker**: https://github.com/kovidgoyal/kitty/issues
- **Discussions**: https://github.com/kovidgoyal/kitty/discussions

---

**Document Version**: 1.0
**Last Updated**: 2025-10-29
**Maintained By**: LAB Repository
