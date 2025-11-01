#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# AI Agents Management TUI
# ═══════════════════════════════════════════════════════════
# Interactive terminal UI for managing AI agent collaboration

set -euo pipefail

SESSION=${KITTY_AI_SESSION:-ai-agents}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Validate required dependency
if [[ ! -f "${SCRIPT_DIR}/lib/colors.sh" ]]; then
    echo "ERROR: Required file not found: ${SCRIPT_DIR}/lib/colors.sh" >&2
    echo "Please ensure the AI Agents scripts are properly installed." >&2
    exit 1
fi
source "${SCRIPT_DIR}/lib/colors.sh"
source "${SCRIPT_DIR}/lib/temp-files.sh"

# Detect available dialog tool
if command -v dialog &> /dev/null; then
    DIALOG="dialog"
elif command -v whiptail &> /dev/null; then
    DIALOG="whiptail"
else
    error_color "❌ Neither dialog nor whiptail found!"
    echo "Install one of them:"
    echo "  sudo apt install dialog"
    echo "  sudo apt install whiptail"
    exit 1
fi

# Dialog dimensions
HEIGHT=20
WIDTH=70
MENU_HEIGHT=12

# Temp file for dialog output (auto-cleaned via temp-files.sh)
TEMP_FILE=$(temp_file)

# ═══════════════════════════════════════════════════════════
# Helper Functions
# ═══════════════════════════════════════════════════════════

show_message() {
    local title="$1"
    local message="$2"
    $DIALOG --title "$title" --msgbox "$message" 15 60
}

show_error() {
    local message="$1"
    $DIALOG --title "Error" --msgbox "$message" 10 50
}

get_input() {
    local title="$1"
    local prompt="$2"
    local default="${3:-}"

    $DIALOG --title "$title" --inputbox "$prompt" 10 60 "$default" 2> "$TEMP_FILE"

    if [[ $? -eq 0 ]]; then
        cat "$TEMP_FILE"
        return 0
    else
        return 1
    fi
}

confirm() {
    local message="$1"
    $DIALOG --title "Confirm" --yesno "$message" 8 50
}

launch_in_terminal() {
    # Launch command in proper terminal context
    # Detects environment (tmux/kitty) and launches appropriately
    local cmd="$1"

    if [[ -n "${TMUX:-}" ]]; then
        # Running in tmux - create new window with persistent shell
        tmux new-window -n "AI-Mode" bash -c "$cmd; exec bash"
    elif [[ -n "${KITTY_WINDOW_ID:-}" ]] && command -v kitty &>/dev/null; then
        # Running in kitty - launch new tab with persistent shell
        kitty @ launch --type=tab --title="AI Mode" --keep-focus bash -c "$cmd; exec bash"
    else
        # Fallback - run directly in background and notify
        bash -c "$cmd" &
        show_message "Mode Started" "Mode launched in background.\nCheck your terminal or tmux session."
    fi
}

# ═══════════════════════════════════════════════════════════
# Mode Management
# ═══════════════════════════════════════════════════════════

start_pair_programming() {
    local driver=$(get_input "Pair Programming" "Driver agent:" "Agent1") || return
    local navigator=$(get_input "Pair Programming" "Navigator agent:" "Agent2") || return

    launch_in_terminal "${SCRIPT_DIR}/ai-mode-start.sh pair \"$driver\" \"$navigator\""
    show_message "Success" "Pair programming mode started!\n\nDriver: $driver\nNavigator: $navigator"
}

start_debate() {
    local topic=$(get_input "Debate Mode" "Debate topic:") || return

    if [[ -z "$topic" ]]; then
        show_error "Topic cannot be empty!"
        return
    fi

    launch_in_terminal "${SCRIPT_DIR}/ai-mode-start.sh debate \"$topic\""
    show_message "Success" "Debate mode started!\n\nTopic: $topic"
}

start_teaching() {
    local expert=$(get_input "Teaching Mode" "Expert agent:" "Agent1") || return
    local learner=$(get_input "Teaching Mode" "Learner agent:" "Agent2") || return
    local topic=$(get_input "Teaching Mode" "Topic to teach:") || return

    if [[ -z "$topic" ]]; then
        show_error "Topic cannot be empty!"
        return
    fi

    launch_in_terminal "${SCRIPT_DIR}/ai-mode-start.sh teach \"$expert\" \"$learner\" \"$topic\""
    show_message "Success" "Teaching mode started!\n\nExpert: $expert\nLearner: $learner\nTopic: $topic"
}

start_consensus() {
    local decision=$(get_input "Consensus Mode" "Decision topic:") || return

    if [[ -z "$decision" ]]; then
        show_error "Decision topic cannot be empty!"
        return
    fi

    launch_in_terminal "${SCRIPT_DIR}/ai-mode-start.sh consensus \"$decision\""
    show_message "Success" "Consensus mode started!\n\nDecision: $decision"
}

start_competition() {
    local challenge=$(get_input "Competition Mode" "Challenge:") || return
    local time_limit=$(get_input "Competition Mode" "Time limit (minutes):" "30") || return

    if [[ -z "$challenge" ]]; then
        show_error "Challenge cannot be empty!"
        return
    fi

    launch_in_terminal "${SCRIPT_DIR}/ai-mode-start.sh compete \"$challenge\" \"$time_limit\""
    show_message "Success" "Competition started!\n\nChallenge: $challenge\nTime: $time_limit min"
}

modes_menu() {
    while true; do
        $DIALOG --title "Start Collaboration Mode" \
                --menu "Choose a mode to start:" \
                $HEIGHT $WIDTH $MENU_HEIGHT \
                "1" "Pair Programming (Driver/Navigator)" \
                "2" "Debate (Structured Discussion)" \
                "3" "Teaching (Expert/Learner)" \
                "4" "Consensus (Agreement Required)" \
                "5" "Competition (Best Solution Wins)" \
                "6" "← Back to Main Menu" \
                2> "$TEMP_FILE"

        local choice=$?
        if [[ $choice -ne 0 ]]; then
            return
        fi

        case $(cat "$TEMP_FILE") in
            1) start_pair_programming ;;
            2) start_debate ;;
            3) start_teaching ;;
            4) start_consensus ;;
            5) start_competition ;;
            6) return ;;
            *) return ;;
        esac
    done
}

# ═══════════════════════════════════════════════════════════
# Session Management
# ═══════════════════════════════════════════════════════════

view_current_mode() {
    local mode_dir="/tmp/ai-mode-${SESSION}"

    if [[ ! -d "$mode_dir" ]]; then
        show_message "No Active Mode" "No collaboration mode is currently running."
        return
    fi

    # Find active mode
    local active_mode=""
    local mode_file=""

    for file in "$mode_dir"/*.json; do
        if [[ -f "$file" ]]; then
            mode_file="$file"
            active_mode=$(basename "$file" .json)
            break
        fi
    done

    if [[ -z "$active_mode" ]]; then
        show_message "No Active Mode" "No collaboration mode is currently running."
        return
    fi

    # Read mode state
    local state=$(cat "$mode_file" | jq -r '.')
    local formatted=$(echo "$state" | jq -r '
        "Mode: \(.mode // "unknown")\n" +
        "Started: \(.started // "unknown")\n" +
        "---\n" +
        (if .driver then "Driver: \(.driver)\nNavigator: \(.navigator)\nSwitches: \(.switches)\n" else "" end) +
        (if .topic then "Topic: \(.topic)\n" else "" end) +
        (if .decision then "Decision: \(.decision)\n" else "" end) +
        (if .challenge then "Challenge: \(.challenge)\nTime Limit: \(.time_limit_minutes)min\n" else "" end) +
        (if .expert then "Expert: \(.expert)\nLearner: \(.learner)\nMastery: \(.mastery_level)%\n" else "" end) +
        (if .consensus_reached then "Consensus: YES\n" else "" end) +
        (if .winner then "Winner: \(.winner)\n" else "" end)
    ')

    show_message "Active Mode: ${active_mode}" "$formatted"
}

save_session() {
    local name=$(get_input "Save Session" "Session name:" "session-$(date +%Y%m%d-%H%M)") || return
    local description=$(get_input "Save Session" "Description:") || return

    if [[ -z "$name" ]]; then
        show_error "Session name cannot be empty!"
        return
    fi

    "${SCRIPT_DIR}/ai-session-save.sh" "$name" "$description"
    show_message "Success" "Session saved!\n\nName: $name\nDescription: $description"
}

list_sessions() {
    local snapshot_dir="${HOME}/.ai-agents/snapshots"

    if [[ ! -d "$snapshot_dir" ]] || [[ -z "$(ls -A "$snapshot_dir" 2>/dev/null)" ]]; then
        show_message "No Saved Sessions" "No sessions have been saved yet.\n\nUse 'Save Current Session' to create one."
        return
    fi

    # Build list of sessions (using safe array instead of eval)
    local menu_items=()
    local count=1

    for dir in "$snapshot_dir"/*/; do
        if [[ -d "$dir" ]]; then
            local name=$(basename "$dir")
            local meta_file="${dir}metadata.json"
            local desc="No description"

            if [[ -f "$meta_file" ]]; then
                desc=$(jq -r '.description // "No description"' "$meta_file" 2>/dev/null || echo "No description")
            fi

            menu_items+=("$count" "$name" "$desc")
            ((count++))
        fi
    done

    if [[ ${#menu_items[@]} -eq 0 ]]; then
        show_message "No Saved Sessions" "No sessions found."
        return
    fi

    $DIALOG --title "Saved Sessions" \
            --menu "Select a session to view:" \
            $HEIGHT $WIDTH $MENU_HEIGHT \
            "${menu_items[@]}" \
            2> "$TEMP_FILE"

    if [[ $? -eq 0 ]]; then
        local choice=$(cat "$TEMP_FILE")
        # Show session details would go here
        show_message "Session Browser" "Session details viewer - implementation pending"
    fi
}

sessions_menu() {
    while true; do
        $DIALOG --title "Session Management" \
                --menu "Manage collaboration sessions:" \
                $HEIGHT $WIDTH $MENU_HEIGHT \
                "1" "View Current Mode Status" \
                "2" "Save Current Session" \
                "3" "List Saved Sessions" \
                "4" "Session History" \
                "5" "← Back to Main Menu" \
                2> "$TEMP_FILE"

        local choice=$?
        if [[ $choice -ne 0 ]]; then
            return
        fi

        case $(cat "$TEMP_FILE") in
            1) view_current_mode ;;
            2) save_session ;;
            3) list_sessions ;;
            4) "${SCRIPT_DIR}/ai-session-list.sh" | $DIALOG --title "Session History" --programbox $HEIGHT $WIDTH ;;
            5) return ;;
            *) return ;;
        esac
    done
}

# ═══════════════════════════════════════════════════════════
# Knowledge Base
# ═══════════════════════════════════════════════════════════

add_kb_entry() {
    # Select type
    $DIALOG --title "Add KB Entry" \
            --menu "Entry type:" \
            15 50 4 \
            "1" "Documentation" \
            "2" "Code Snippet" \
            "3" "Decision Record" \
            "4" "Pattern" \
            2> "$TEMP_FILE"

    if [[ $? -ne 0 ]]; then
        return
    fi

    local type_choice=$(cat "$TEMP_FILE")
    local type=""

    case $type_choice in
        1) type="doc" ;;
        2) type="snippet" ;;
        3) type="decision" ;;
        4) type="pattern" ;;
        *) return ;;
    esac

    local title=$(get_input "Add $type" "Title:") || return
    local content=$(get_input "Add $type" "Content:") || return
    local tags=$(get_input "Add $type" "Tags (comma-separated):" "") || return

    if [[ -z "$title" || -z "$content" ]]; then
        show_error "Title and content cannot be empty!"
        return
    fi

    "${SCRIPT_DIR}/ai-kb-add.sh" "$type" "$title" "$content" "$tags"
    show_message "Success" "Knowledge base entry added!\n\nType: $type\nTitle: $title"
}

search_kb() {
    local query=$(get_input "Search Knowledge Base" "Search query:") || return

    if [[ -z "$query" ]]; then
        return
    fi

    local results=$("${SCRIPT_DIR}/ai-kb-search.sh" "$query")

    if [[ -z "$results" ]]; then
        show_message "No Results" "No entries found matching: $query"
    else
        echo "$results" | $DIALOG --title "Search Results: $query" --programbox $HEIGHT $WIDTH
    fi
}

add_lesson() {
    local problem=$(get_input "Add Lesson" "Problem/Challenge:") || return
    local solution=$(get_input "Add Lesson" "Solution/Learning:") || return
    local tags=$(get_input "Add Lesson" "Tags (comma-separated):" "") || return

    if [[ -z "$problem" || -z "$solution" ]]; then
        show_error "Problem and solution cannot be empty!"
        return
    fi

    "${SCRIPT_DIR}/ai-lesson-add.sh" "$problem" "$solution" "$tags"
    show_message "Success" "Lesson learned recorded!\n\nProblem: $problem\nSolution: $solution"
}

kb_menu() {
    while true; do
        $DIALOG --title "Knowledge Base" \
                --menu "Manage knowledge and lessons:" \
                $HEIGHT $WIDTH $MENU_HEIGHT \
                "1" "Add KB Entry (Doc/Snippet/Decision/Pattern)" \
                "2" "Search Knowledge Base" \
                "3" "Add Lesson Learned" \
                "4" "Browse by Type" \
                "5" "← Back to Main Menu" \
                2> "$TEMP_FILE"

        local choice=$?
        if [[ $choice -ne 0 ]]; then
            return
        fi

        case $(cat "$TEMP_FILE") in
            1) add_kb_entry ;;
            2) search_kb ;;
            3) add_lesson ;;
            4) show_message "Browse KB" "KB browser - implementation pending" ;;
            5) return ;;
            *) return ;;
        esac
    done
}

# ═══════════════════════════════════════════════════════════
# fzf Tools
# ═══════════════════════════════════════════════════════════

launch_session_browser() {
    if [[ ! -f "${SCRIPT_DIR}/ai-session-browse-fzf.sh" ]]; then
        show_error "Session browser not found!\n\nExpected: ${SCRIPT_DIR}/ai-session-browse-fzf.sh"
        return
    fi

    clear
    "${SCRIPT_DIR}/ai-session-browse-fzf.sh"
    read -p "Press Enter to continue..."
}

launch_kb_search() {
    if [[ ! -f "${SCRIPT_DIR}/ai-kb-search-fzf.sh" ]]; then
        show_error "KB search not found!\n\nExpected: ${SCRIPT_DIR}/ai-kb-search-fzf.sh"
        return
    fi

    clear
    "${SCRIPT_DIR}/ai-kb-search-fzf.sh"
    read -p "Press Enter to continue..."
}

launch_pane_switcher() {
    if ! command -v tmux &>/dev/null; then
        show_error "tmux is not installed!"
        return
    fi

    if [[ -z "${TMUX:-}" ]]; then
        show_error "Not in a tmux session!\n\nStart tmux first with:\n  tmux new -s ai-agents"
        return
    fi

    if [[ ! -f "${SCRIPT_DIR}/ai-pane-fzf.sh" ]]; then
        show_error "Pane switcher not found!\n\nExpected: ${SCRIPT_DIR}/ai-pane-fzf.sh"
        return
    fi

    clear
    "${SCRIPT_DIR}/ai-pane-fzf.sh"
    read -p "Press Enter to continue..."
}

launch_mode_launcher() {
    if [[ ! -f "${SCRIPT_DIR}/ai-mode-fzf.sh" ]]; then
        show_error "Mode launcher not found!\n\nExpected: ${SCRIPT_DIR}/ai-mode-fzf.sh"
        return
    fi

    clear
    "${SCRIPT_DIR}/ai-mode-fzf.sh"
    read -p "Press Enter to continue..."
}

fzf_tools_menu() {
    while true; do
        $DIALOG --title "🔍 fzf Tools" \
                --menu "Interactive fuzzy finders:" \
                $HEIGHT $WIDTH $MENU_HEIGHT \
                "1" "📦 Session Browser (browse/restore sessions)" \
                "2" "📚 KB Search (search knowledge base)" \
                "3" "🗔 Pane Switcher (navigate tmux panes)" \
                "4" "🚀 Mode Launcher (select collaboration mode)" \
                "5" "← Back to Main Menu" \
                2> "$TEMP_FILE"

        local choice=$?
        if [[ $choice -ne 0 ]]; then
            return
        fi

        case $(cat "$TEMP_FILE") in
            1) launch_session_browser ;;
            2) launch_kb_search ;;
            3) launch_pane_switcher ;;
            4) launch_mode_launcher ;;
            5) return ;;
            *) return ;;
        esac
    done
}

# ═══════════════════════════════════════════════════════════
# Quick Actions
# ═══════════════════════════════════════════════════════════

launch_tmux_session() {
    if confirm "Launch AI Agents tmux session?"; then
        "${SCRIPT_DIR}/launch-ai-agents-tmux.sh"
    fi
}

setup_tpm() {
    if [[ ! -f "${SCRIPT_DIR}/setup-tmux-tpm.sh" ]]; then
        show_error "TPM setup script not found!\n\nExpected: ${SCRIPT_DIR}/setup-tmux-tpm.sh"
        return
    fi

    if confirm "Install TPM (Tmux Plugin Manager)?\n\nThis will:\n• Install TPM\n• Configure 7 plugins\n• Enable session persistence\n• Create layout templates"; then
        clear
        "${SCRIPT_DIR}/setup-tmux-tpm.sh"
        read -p "Press Enter to continue..."
    fi
}

show_help() {
    local help_text="AI Agents Management TUI

COLLABORATION MODES:
• Pair Programming - Driver/navigator roles
• Debate - Structured discussion (4 rounds)
• Teaching - Expert guides learner
• Consensus - Both agents must agree
• Competition - Best solution wins

fzf TOOLS (⭐ NEW!):
• Session Browser - Browse/restore sessions with live preview
• KB Search - Fuzzy search knowledge base with syntax highlighting
• Pane Switcher - Navigate tmux panes (requires tmux session)
• Mode Launcher - Select mode with comprehensive previews

SESSION MANAGEMENT:
• View active mode status
• Save current session
• Browse saved sessions
• View session history

KNOWLEDGE BASE:
• Add documentation, snippets, decisions
• Search knowledge base
• Record lessons learned

TPM (Tmux Plugin Manager) (⭐ NEW!):
• One-click installation
• 7 essential plugins
• Auto-save sessions every 15 min
• Session persistence (survives reboots)

KEYBOARD SHORTCUTS (Outside TUI):
• Ctrl+Alt+F - Session Browser
• Ctrl+Alt+K - KB Search
• Ctrl+Alt+P - Pane Switcher
• Ctrl+Alt+L - Mode Launcher
• Ctrl+Alt+M - This TUI

TUI NAVIGATION:
• Arrow keys - Navigate menus
• Enter - Select option
• Esc/Cancel - Go back
• Tab - Switch fields in forms

For full documentation:
  cat ~/.config/kitty/docs/TMUX-FZF-INTEGRATION.md
  cat ~/.config/kitty/docs/TPM-INTEGRATION-GUIDE.md"

    echo "$help_text" | $DIALOG --title "Help" --programbox 25 75
}

system_status() {
    local status="AI AGENTS SYSTEM STATUS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

"

    # Check tmux session
    if tmux has-session -t "$SESSION" 2>/dev/null; then
        status+="✅ Tmux session: ACTIVE ($SESSION)\n"
    else
        status+="❌ Tmux session: NOT RUNNING\n"
    fi

    # Check TPM
    if [[ -d "${HOME}/.tmux/plugins/tpm" ]]; then
        # Count plugins excluding TPM itself
        local plugin_count=$(find "${HOME}/.tmux/plugins" -maxdepth 1 -type d ! -name 'plugins' ! -name 'tpm' 2>/dev/null | tail -n +2 | wc -l)
        status+="✅ TPM (Plugin Manager): INSTALLED\n"
        status+="   • Total plugins: $plugin_count/16 configured\n"

        # Check if tmux.conf has TPM config
        if [[ -f "${HOME}/.tmux.conf" ]] && grep -q "tmux-plugins/tpm" "${HOME}/.tmux.conf" 2>/dev/null; then
            status+="   • Configuration: OK\n"
        else
            status+="   • Configuration: MISSING\n"
        fi

        # Core plugins status
        local core_installed=0
        [[ -d "${HOME}/.tmux/plugins/tmux-sensible" ]] && ((core_installed++))
        [[ -d "${HOME}/.tmux/plugins/tmux-resurrect" ]] && ((core_installed++))
        [[ -d "${HOME}/.tmux/plugins/tmux-continuum" ]] && ((core_installed++))
        [[ -d "${HOME}/.tmux/plugins/tmux-yank" ]] && ((core_installed++))
        [[ -d "${HOME}/.tmux/plugins/tmux-open" ]] && ((core_installed++))
        [[ -d "${HOME}/.tmux/plugins/tmux-copycat" ]] && ((core_installed++))
        [[ -d "${HOME}/.tmux/plugins/tmux-prefix-highlight" ]] && ((core_installed++))

        if [[ $core_installed -eq 7 ]]; then
            status+="   • Core plugins: ✅ ALL INSTALLED (7/7)\n"
        else
            status+="   • Core plugins: ⏳ PARTIAL ($core_installed/7)\n"
        fi

        # Enhanced plugins status (added 2025-10-29)
        local enhanced_installed=0
        [[ -d "${HOME}/.tmux/plugins/tmux-sessionx" ]] && ((enhanced_installed++))
        [[ -d "${HOME}/.tmux/plugins/tmux-jump" ]] && ((enhanced_installed++))
        [[ -d "${HOME}/.tmux/plugins/tmux-fzf" ]] && ((enhanced_installed++))
        [[ -d "${HOME}/.tmux/plugins/extrakto" ]] && ((enhanced_installed++))
        [[ -d "${HOME}/.tmux/plugins/tmux-menus" ]] && ((enhanced_installed++))
        [[ -d "${HOME}/.tmux/plugins/tmux-sessionist" ]] && ((enhanced_installed++))
        [[ -d "${HOME}/.tmux/plugins/tmux-logging" ]] && ((enhanced_installed++))
        [[ -d "${HOME}/.tmux/plugins/tmux-fingers" ]] && ((enhanced_installed++))

        if [[ $enhanced_installed -eq 8 ]]; then
            status+="   • Enhanced plugins: ✅ ALL INSTALLED (8/8)\n"
        elif [[ $enhanced_installed -gt 0 ]]; then
            status+="   • Enhanced plugins: ⏳ PARTIAL ($enhanced_installed/8)\n"
        else
            status+="   • Enhanced plugins: ⏳ NOT INSTALLED (0/8)\n"
            status+="     Run: prefix + I to install\n"
        fi

        # Check session persistence
        if [[ -d "${HOME}/.tmux/resurrect" ]]; then
            local save_count=$(ls -1 "${HOME}/.tmux/resurrect"/*.txt 2>/dev/null | wc -l)
            status+="   • Session saves: $save_count\n"
        fi

        # Check logging directory
        if [[ -d "${HOME}/tmux-logs" ]]; then
            local log_count=$(ls -1 "${HOME}/tmux-logs"/*.log 2>/dev/null | wc -l)
            if [[ $log_count -gt 0 ]]; then
                status+="   • Pane logs: $log_count files\n"
            fi
        fi
    else
        status+="⚠️  TPM: NOT INSTALLED\n"
        status+="   Install via: Setup TPM menu option\n"
    fi

    # Check active mode
    local mode_dir="/tmp/ai-mode-${SESSION}"
    if [[ -d "$mode_dir" ]] && [[ -n "$(ls -A "$mode_dir" 2>/dev/null)" ]]; then
        local mode_file=$(ls "$mode_dir"/*.json 2>/dev/null | head -1)
        if [[ -f "$mode_file" ]]; then
            local mode=$(jq -r '.mode // "unknown"' "$mode_file")
            status+="✅ Active mode: ${mode^^}\n"
        else
            status+="ℹ️  Active mode: NONE\n"
        fi
    else
        status+="ℹ️  Active mode: NONE\n"
    fi

    # Check KB
    local kb_dir="${HOME}/.ai-agents"
    if [[ -d "$kb_dir" ]]; then
        local doc_count=$(find "$kb_dir/knowledge/docs" -name "*.md" 2>/dev/null | wc -l)
        local lesson_count=$(find "$kb_dir/lessons" -name "*.md" 2>/dev/null | wc -l)
        local session_count=$(find "$kb_dir/snapshots" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)

        status+="✅ Knowledge base: INITIALIZED\n"
        status+="   • Documents: $doc_count\n"
        status+="   • Lessons: $lesson_count\n"
        status+="   • Saved sessions: $session_count\n"
    else
        status+="⚠️  Knowledge base: NOT INITIALIZED\n"
        status+="   Run: ai-knowledge-init.sh\n"
    fi

    # Check fzf tools
    local fzf_count=0
    [[ -f "${SCRIPT_DIR}/ai-session-browse-fzf.sh" ]] && ((fzf_count++))
    [[ -f "${SCRIPT_DIR}/ai-kb-search-fzf.sh" ]] && ((fzf_count++))
    [[ -f "${SCRIPT_DIR}/ai-pane-fzf.sh" ]] && ((fzf_count++))
    [[ -f "${SCRIPT_DIR}/ai-mode-fzf.sh" ]] && ((fzf_count++))

    if [[ $fzf_count -eq 4 ]]; then
        status+="✅ fzf tools: ALL INSTALLED (4/4)\n"
    elif [[ $fzf_count -gt 0 ]]; then
        status+="⚠️  fzf tools: PARTIAL ($fzf_count/4)\n"
    else
        status+="❌ fzf tools: NOT FOUND\n"
    fi

    status+="\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    echo -e "$status" | $DIALOG --title "System Status" --programbox 25 65
}

# ═══════════════════════════════════════════════════════════
# Main Menu
# ═══════════════════════════════════════════════════════════

main_menu() {
    while true; do
        $DIALOG --title "AI Agents Management" \
                --menu "Choose an option:" \
                22 70 14 \
                "1" "🚀 Start Collaboration Mode" \
                "2" "🔍 fzf Tools (Session/KB/Pane/Mode)" \
                "3" "💾 Session Management" \
                "4" "📚 Knowledge Base" \
                "5" "⚡ Launch Tmux Session" \
                "6" "🔌 Setup TPM (Tmux Plugin Manager)" \
                "7" "📊 System Status" \
                "8" "❓ Help & Documentation" \
                "9" "🚪 Exit" \
                2> "$TEMP_FILE"

        local choice=$?
        if [[ $choice -ne 0 ]]; then
            break
        fi

        case $(cat "$TEMP_FILE") in
            1) modes_menu ;;
            2) fzf_tools_menu ;;
            3) sessions_menu ;;
            4) kb_menu ;;
            5) launch_tmux_session ;;
            6) setup_tpm ;;
            7) system_status ;;
            8) show_help ;;
            9) break ;;
            *) break ;;
        esac
    done

    clear
    success_color "Thanks for using AI Agents Management TUI! 👋"
}

# ═══════════════════════════════════════════════════════════
# Entry Point
# ═══════════════════════════════════════════════════════════

# Check if KB is initialized
if [[ ! -d "${HOME}/.ai-agents" ]]; then
    if confirm "Knowledge base not initialized.\n\nInitialize now?"; then
        "${SCRIPT_DIR}/ai-knowledge-init.sh"
    fi
fi

# Start main menu
main_menu
