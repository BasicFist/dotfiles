# Kitty Terminal Keybindings

This document provides a comprehensive overview of all configured keybindings for the Kitty terminal environment.

## Window Management

| Shortcut | Action |
|---|---|
| `Ctrl+Shift+Enter` | Launch a new terminal window, inheriting the current working directory. |
| `Ctrl+Shift+W` | Close the current window. |
| `Ctrl+Shift+Minus` | Create a new window by splitting the current one horizontally. |
| `Ctrl+Shift+Backslash` | Create a new window by splitting the current one vertically. |
| `Ctrl+Alt+H` | Create a new window by splitting the current one horizontally. |
| `Ctrl+Alt+V` | Create a new window by splitting the current one vertically. |
| `Ctrl+Shift+Left` | Switch focus to the neighboring window on the left. |
| `Ctrl+Shift+Right` | Switch focus to the neighboring window on the right. |
| `Ctrl+Shift+Up` | Switch focus to the neighboring window above. |
| `Ctrl+Shift+Down` | Switch focus to the neighboring window below. |
| `Ctrl+Shift+F11` | Toggle fullscreen mode for the current window. |

## Tab Management

| Shortcut | Action |
|---|---|
| `Ctrl+Shift+T` | Open a new tab. |
| `Ctrl+Shift+Q` | Close the current tab. |
| `Ctrl+Shift+]` | Switch to the next tab. |
| `Ctrl+Shift+[` | Switch to the previous tab. |
| `Ctrl+1` - `Ctrl+5` | Switch to tabs 1 through 5 respectively. |
| `Ctrl+F1` - `Ctrl+F5` | Switch to tabs 1 through 5 respectively. |

## Scrolling

| Shortcut | Action |
|---|---|
| `Ctrl+Shift+K` | Scroll up one line. |
| `Ctrl+Shift+J` | Scroll down one line. |
| `Ctrl+Shift+Page Up` | Scroll up one page. |
| `Ctrl+Shift+Page Down` | Scroll down one page. |
| `Ctrl+Shift+Home` | Scroll to the beginning of the terminal buffer. |
| `Ctrl+Shift+End` | Scroll to the end of the terminal buffer. |

## Search & Scrollback

| Shortcut | Action |
|---|---|
| `Ctrl+Shift+F` | Search for text within the terminal scrollback. |
| `Ctrl+Shift+H` | Show the entire scrollback in a pager (e.g., `less`). |

## Font Size & Opacity

| Shortcut | Action |
|---|---|
| `Ctrl+Shift+Plus` | Increase the font size by 2.0 points. |
| `Ctrl+Shift+Backspace` | Reset the font size to the default. |
| `Ctrl+Alt+Period` | Increase the window opacity by 2%. |
| `Ctrl+Alt+Comma` | Decrease the window opacity by 2%. |
| `Ctrl+Alt+0` | Reset the window opacity to 98%. |

## AI Agents & fzf Integrations

| Shortcut | Action |
|---|---|
| `Ctrl+Alt+X` | Launch the main AI Agents tmux session. |
| `Ctrl+Alt+Shift+X` | Launch a shared tmux session. |
| `Ctrl+Alt+M` | Open the AI Agents Management TUI (Text-based User Interface). |
| `Ctrl+Alt+F` | Launch the fzf Session Browser to search and manage AI sessions. |
| `Ctrl+Alt+K` | Launch the fzf Knowledge Base Search to find information. |
| `Ctrl+Alt+P` | Launch the fzf Tmux Pane Switcher for easy navigation between panes. |
| `Ctrl+Alt+L` | Launch the fzf Mode Quick Launcher to start AI collaboration modes. |
| `Ctrl+Alt+A` / `Shift+A` | Toggle and focus the agent terminal. |

## System Monitoring

| Shortcut | Action |
|---|---|
| `Ctrl+Shift+G` | Open a new tab to monitor GPU usage (requires `nvidia-smi`). |
| `Ctrl+Shift+S` | Open a new tab to monitor system sensors (requires `lm-sensors`). |

## Copy & Paste

| Shortcut | Action |
|---|---|
| `Ctrl+Shift+C` | Copy selected text to the clipboard. |
| `Ctrl+Shift+V` | Paste text from the clipboard. |
| `Shift+Insert` | Paste from the primary selection (X11-style). |
| `Middle Mouse Click` | Paste from the primary selection. |
| `Ctrl+Shift+Alt+P` | Launch the clipboard manager overlay. |

## Miscellaneous

| Shortcut | Action |
|---|---|
| `Ctrl+Shift+I` | Launch an image viewer overlay within the terminal. |
| `Ctrl+Shift+Space` | Open the Kitty command palette for hints and options. |
| `Ctrl+Shift+U` | Input a Unicode character. |
| `Ctrl+Shift+Escape` | Open the Kitty shell for debugging and control. |
| `F12` or `Ctrl+?` | Show an overlay with a list of available shortcuts. |
| `Ctrl+Alt+O` | Toggle window transparency. |
| `Ctrl+Alt+S` | Toggle the scratchpad window. |
| `Ctrl+Alt+Shift+T` | Launch the theme chooser overlay. |
| `Ctrl+Alt+Shift+D` | Launch a diff tool overlay. |
