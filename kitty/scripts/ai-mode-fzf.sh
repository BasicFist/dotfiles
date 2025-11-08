#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# AI Agents - Enhanced fzf Mode Launcher with Statistics
# ═══════════════════════════════════════════════════════════
# Interactive mode selection with stats tracking and favorites

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if fzf is installed
if ! command -v fzf &>/dev/null; then
    echo "❌ fzf not installed!"
    echo "Install with: sudo apt install fzf"
    exit 1
fi

# Source required libraries if available
if [[ -f "${SCRIPT_DIR}/lib/constants.sh" ]]; then
    source "${SCRIPT_DIR}/lib/constants.sh" 2>/dev/null || true
fi

# Set stats file location
STATS_FILE="${AI_AGENTS_STATE:-${HOME}/.ai-agents/state}/mode-stats.json"
mkdir -p "$(dirname "$STATS_FILE")"

# Initialize stats file
init_stats() {
    if [[ ! -f "$STATS_FILE" ]]; then
        cat > "$STATS_FILE" <<'EOF'
{
  "pair-programming": {
    "usage_count": 0,
    "last_used": null,
    "is_favorite": false
  },
  "code-review": {
    "usage_count": 0,
    "last_used": null,
    "is_favorite": false
  },
  "debug": {
    "usage_count": 0,
    "last_used": null,
    "is_favorite": false
  },
  "brainstorm": {
    "usage_count": 0,
    "last_used": null,
    "is_favorite": false
  },
  "debate": {
    "usage_count": 0,
    "last_used": null,
    "is_favorite": false
  },
  "teaching": {
    "usage_count": 0,
    "last_used": null,
    "is_favorite": false
  },
  "consensus": {
    "usage_count": 0,
    "last_used": null,
    "is_favorite": false
  },
  "competition": {
    "usage_count": 0,
    "last_used": null,
    "is_favorite": false
  }
}
EOF
    fi
}

# Get mode stats
get_mode_stats() {
    local mode="$1"

    if [[ ! -f "$STATS_FILE" ]]; then
        echo "0|never|false"
        return
    fi

    local usage_count=$(jq -r ".[\"$mode\"].usage_count // 0" "$STATS_FILE" 2>/dev/null || echo "0")
    local last_used=$(jq -r ".[\"$mode\"].last_used // \"never\"" "$STATS_FILE" 2>/dev/null || echo "never")
    local is_favorite=$(jq -r ".[\"$mode\"].is_favorite // false" "$STATS_FILE" 2>/dev/null || echo "false")

    echo "$usage_count|$last_used|$is_favorite"
}

# Update mode stats
update_mode_stats() {
    local mode="$1"
    local timestamp=$(date -Iseconds 2>/dev/null || date +%Y-%m-%dT%H:%M:%S)

    if [[ ! -f "$STATS_FILE" ]]; then
        init_stats
    fi

    local temp_file=$(mktemp)
    jq --arg mode "$mode" \
       --arg ts "$timestamp" \
       '.[$mode].usage_count += 1 | .[$mode].last_used = $ts' \
       "$STATS_FILE" > "$temp_file" && mv "$temp_file" "$STATS_FILE"
}

# Toggle favorite
toggle_favorite() {
    local mode="$1"

    if [[ ! -f "$STATS_FILE" ]]; then
        init_stats
    fi

    local temp_file=$(mktemp)
    jq --arg mode "$mode" \
       '.[$mode].is_favorite = (.[$mode].is_favorite // false | not)' \
       "$STATS_FILE" > "$temp_file" && mv "$temp_file" "$STATS_FILE"
}

# List modes with statistics
list_modes() {
    local sort_mode="${1:-alphabetical}"

    init_stats

    declare -A mode_data
    declare -A mode_emoji
    declare -A mode_desc
    declare -A mode_category

    # Core modes (recommended for daily use)
    mode_emoji["pair-programming"]="⭐🎯"
    mode_emoji["code-review"]="⭐📝"
    mode_emoji["debug"]="⭐🐛"
    mode_emoji["brainstorm"]="⭐💭"

    # Legacy modes (kept for compatibility)
    mode_emoji["debate"]="💬"
    mode_emoji["teaching"]="🎓"
    mode_emoji["consensus"]="🤝"
    mode_emoji["competition"]="⚔️"

    mode_desc["pair-programming"]="[CORE] Driver/Navigator - Build features together"
    mode_desc["code-review"]="[CORE] Author/Reviewer - Systematic code quality review"
    mode_desc["debug"]="[CORE] Reporter/Debugger - Collaborative bug fixing"
    mode_desc["brainstorm"]="[CORE] Free-form idea generation with 4 phases"
    mode_desc["debate"]="[LEGACY] Structured Discussion - Thesis → Antithesis → Synthesis"
    mode_desc["teaching"]="[LEGACY] Expert/Learner - Knowledge transfer with Q&A"
    mode_desc["consensus"]="[LEGACY] Agreement Building - Collaborative decision-making"
    mode_desc["competition"]="[LEGACY] Best Solution Wins - Independent approaches compared"

    mode_category["pair-programming"]="0"
    mode_category["code-review"]="0"
    mode_category["debug"]="0"
    mode_category["brainstorm"]="0"
    mode_category["debate"]="1"
    mode_category["teaching"]="1"
    mode_category["consensus"]="1"
    mode_category["competition"]="1"

    for mode in pair-programming code-review debug brainstorm debate teaching consensus competition; do
        local stats=$(get_mode_stats "$mode")
        local usage_count=$(echo "$stats" | cut -d'|' -f1)
        local last_used=$(echo "$stats" | cut -d'|' -f2)
        local is_favorite=$(echo "$stats" | cut -d'|' -f3)

        # Format last used as relative time
        local last_used_display="never"
        if [[ "$last_used" != "never" ]] && [[ "$last_used" != "null" ]]; then
            local last_epoch=$(date -d "$last_used" +%s 2>/dev/null || echo "0")
            local now_epoch=$(date +%s)
            local diff=$((now_epoch - last_epoch))

            if [[ $diff -lt 3600 ]]; then
                last_used_display="$((diff / 60))m ago"
            elif [[ $diff -lt 86400 ]]; then
                last_used_display="$((diff / 3600))h ago"
            else
                last_used_display="$((diff / 86400))d ago"
            fi
        fi

        # Favorite indicator
        local fav_icon=""
        if [[ "$is_favorite" == "true" ]]; then
            fav_icon="⭐ "
        fi

        # Calculate sort key
        local sort_key=""
        case "$sort_mode" in
            frequent)
                # Sort by usage, but keep core modes higher
                sort_key="${mode_category[$mode]}-$(printf "%05d" "$((99999 - usage_count))")"
                ;;
            recent)
                local epoch=0
                if [[ "$last_used" != "never" ]] && [[ "$last_used" != "null" ]]; then
                    epoch=$(date -d "$last_used" +%s 2>/dev/null || echo "0")
                fi
                # Sort by recency, but keep core modes higher
                sort_key="${mode_category[$mode]}-$(printf "%010d" "$((9999999999 - epoch))")"
                ;;
            favorites)
                if [[ "$is_favorite" == "true" ]]; then
                    sort_key="0-${mode_category[$mode]}"
                else
                    sort_key="1-${mode_category[$mode]}"
                fi
                ;;
            *)
                # Alphabetical: core modes first (0-*), then legacy (1-*)
                sort_key="${mode_category[$mode]}-$mode"
                ;;
        esac

        # Format: sort_key|fav_icon|emoji|mode|usage|last_used|description
        mode_data["$mode"]="$sort_key|$fav_icon|${mode_emoji[$mode]}|$mode|$usage_count|$last_used_display|${mode_desc[$mode]}"
    done

    # Output sorted
    for mode in pair-programming code-review debug brainstorm debate teaching consensus competition; do
        echo "${mode_data[$mode]}"
    done | sort -t'|' -k1 | while IFS='|' read -r sort_key fav_icon emoji mode_name usage last desc; do
        printf "%s%s %-18s  │ %3d uses  │ %-10s  │ %s\n" \
            "$fav_icon" "$emoji" "$mode_name" "$usage" "$last" "$desc"
    done
}

# Preview mode details (keeping original excellent content)
preview_mode() {
    local line="$1"
    local mode=$(echo "$line" | awk '{print $2}')

    # Get stats
    local stats=$(get_mode_stats "$mode")
    local usage_count=$(echo "$stats" | cut -d'|' -f1)
    local last_used=$(echo "$stats" | cut -d'|' -f2)
    local is_favorite=$(echo "$stats" | cut -d'|' -f3)

    echo "═══════════════════════════════════════════════════════"
    echo "Mode: $mode"
    echo "═══════════════════════════════════════════════════════"
    echo ""
    echo "📊 Statistics: $usage_count uses | Last: $last_used | Favorite: $is_favorite"
    echo ""

    case "$mode" in
        pair-programming)
            cat <<'PREVIEW'
👨‍💻 PAIR PROGRAMMING MODE

CONCEPT:
Two agents collaborate with distinct roles - one acts as the "driver"
writing code, while the other acts as the "navigator" reviewing and
guiding the implementation.

ROLES:
• Driver: Focuses on implementation details and writing code
• Navigator: Reviews code, suggests improvements, thinks strategically

BEST FOR:
• Complex implementations requiring multiple perspectives
• Code quality improvement through real-time review
• Learning and knowledge transfer
• Catching bugs early in development

WORKFLOW:
1. Define the task and assign roles
2. Driver implements while narrating approach
3. Navigator reviews and provides feedback
4. Roles can switch periodically (15-30 min intervals)

EXAMPLE:
Driver: "I'll implement the authentication middleware..."
Navigator: "Consider edge cases - what if token is malformed?"
Driver: "Good point, adding validation for that now..."

COMMANDS:
ai-mode-start.sh pair --driver "Agent1" --navigator "Agent2"
PREVIEW
            ;;
        code-review)
            cat <<'PREVIEW'
📝 CODE REVIEW MODE

CONCEPT:
One agent submits code for review, another provides systematic feedback
on quality, security, performance, and best practices. Like a real PR review.

ROLES:
• Author: Submits code, explains decisions, addresses feedback
• Reviewer: Examines code systematically, provides constructive feedback

BEST FOR:
• Pre-merge PR reviews for quality assurance
• Catching bugs before production deployment
• Learning from others' code and sharing knowledge
• Ensuring code follows team conventions

REVIEW CHECKLIST:
✓ Correctness - Does it work as intended?
✓ Edge Cases - What can break? Error handling?
✓ Performance - Is it efficient? Any bottlenecks?
✓ Security - Any vulnerabilities? Input validation?
✓ Style - Follows coding conventions?
✓ Tests - Adequate test coverage?
✓ Docs - Clear comments and documentation?

WORKFLOW:
1. Author presents code for review
2. Reviewer examines code systematically using checklist
3. Reviewer provides specific, constructive feedback
4. Author addresses comments and questions
5. Approve or request changes

EXAMPLE:
Reviewer: "Line 42 - This could cause null pointer exception"
Author: "Good catch! I'll add null check before accessing property"
Reviewer: "Consider using bcrypt instead of MD5 for password hashing"
Author: "Agreed - security issue. Will update to bcrypt"

COMMANDS:
ai-mode-start.sh code-review --author "Agent1" --reviewer "Agent2" --file "auth.js"
PREVIEW
            ;;
        debug)
            cat <<'PREVIEW'
🐛 DEBUG SESSION MODE

CONCEPT:
Collaborative debugging where one agent has a bug and another helps
solve it through systematic investigation. Fresh eyes on tough problems.

ROLES:
• Bug Reporter: Has the bug, provides context and error messages
• Debugger: Guides investigation, proposes hypotheses, suggests solutions

BEST FOR:
• Stuck on a bug for >30 minutes
• Need fresh perspective on complex problem
• Hard-to-reproduce or intermittent bugs
• Learning systematic debugging techniques

DEBUG PROCESS (6 Steps):
1. REPRODUCE - Can we reliably trigger it?
2. ISOLATE - What's the minimal failing case?
3. INVESTIGATE - What's actually happening? Add logging
4. HYPOTHESIZE - What could cause this behavior?
5. TEST - Try potential solutions systematically
6. VERIFY - Did it fix the root cause? Test edge cases

WORKFLOW:
Reporter: Describes bug + error messages + context
Debugger: Asks clarifying questions, requests logs
Both: Work through 6-step debugging process
Debugger: Proposes hypotheses based on findings
Reporter: Tests proposed solutions
Both: Verify fix resolves issue

EXAMPLE:
Reporter: "Users can't login after deployment - getting 500 error"
Reporter: "Error: Cannot read property 'hash' of undefined"
Debugger: "Sounds like user object is null. Check DB connection?"
Reporter: "DB shows users exist, but password field is missing!"
Debugger: "Did the schema migration run on production?"
Reporter: "No! Running migration now... login works!"

COMMANDS:
ai-mode-start.sh debug --reporter "Agent1" --debugger "Agent2" --bug "TypeError in login"
PREVIEW
            ;;
        brainstorm)
            cat <<'PREVIEW'
💭 BRAINSTORM MODE

CONCEPT:
Free-form idea generation session with no judgment. Generate creative
solutions through divergent and convergent thinking phases.

4-PHASE WORKFLOW:
1. DIVERGE (10 min) - Generate ideas freely, no criticism allowed
2. GROUP (5 min) - Cluster similar ideas into themes
3. CONVERGE (10 min) - Evaluate and prioritize best ideas
4. REFINE (5 min) - Detail the top ideas with specifics

BEST FOR:
• Planning new features and architecture decisions
• Problem-solving when stuck or exploring alternatives
• Quick decision-making with multiple options
• Team creativity and innovative thinking

BRAINSTORM RULES:
✓ All ideas welcome - no bad ideas
✓ Defer judgment - critique comes later
✓ Encourage wild ideas - creativity thrives
✓ Build on each other - "yes, and..." thinking
✓ Stay focused on topic - don't drift
✗ NO criticism during diverge phase!

WORKFLOW:
1. Define clear brainstorm topic/question
2. DIVERGE: Rapidly generate ideas without judgment
3. GROUP: Organize ideas into logical themes
4. CONVERGE: Vote on best ideas, discuss trade-offs
5. REFINE: Add details and action steps to top ideas

EXAMPLE:
Topic: "Improve app performance"

DIVERGE:
• Add Redis caching layer
• Lazy load images
• Use CDN for static assets
• Database query optimization
• Code splitting for bundles
• Server-side rendering

GROUP:
• Frontend: lazy loading, code splitting, SSR
• Backend: Redis, query optimization
• Infrastructure: CDN

CONVERGE: Vote for Redis caching + query optimization

REFINE: "Use Redis for user sessions (TTL: session) and API responses (TTL: 5min)"

COMMANDS:
ai-mode-start.sh brainstorm --topic "How to handle API rate limiting"
PREVIEW
            ;;
        debate)
            cat <<'PREVIEW'
💬 DEBATE MODE

CONCEPT:
Structured dialectical approach where agents present opposing views
to reach a synthesized solution through thesis-antithesis-synthesis.

STRUCTURE:
1. Thesis: First agent presents initial position
2. Antithesis: Second agent presents counter-argument
3. Synthesis: Both agents collaborate on unified solution

BEST FOR:
• Exploring multiple approaches to a problem
• Challenging assumptions and finding edge cases
• Design decisions requiring trade-off analysis
• Architecture decisions with pros/cons

WORKFLOW:
1. Define the debate topic/question
2. Agent 1 presents thesis with rationale
3. Agent 2 presents antithesis with counter-points
4. Both agents synthesize best elements into solution

EXAMPLE:
Thesis: "Use microservices for scalability"
Antithesis: "Monolith first - microservices add complexity"
Synthesis: "Start monolithic, design for future service extraction"

COMMANDS:
ai-mode-start.sh debate --topic "Architecture approach for MVP"
PREVIEW
            ;;
        teaching)
            cat <<'PREVIEW'
🎓 TEACHING MODE

CONCEPT:
Expert agent teaches learner agent through explanations, examples,
and Q&A sessions. Focuses on knowledge transfer and understanding.

ROLES:
• Expert: Explains concepts, provides examples, answers questions
• Learner: Asks questions, seeks clarification, applies learning

BEST FOR:
• Learning new technologies or frameworks
• Understanding complex codebases
• Onboarding to new domains
• Deep dives into specific topics

WORKFLOW:
1. Learner states what they want to understand
2. Expert explains concept with examples
3. Learner asks clarifying questions
4. Expert provides additional context
5. Learner demonstrates understanding by applying concept

EXAMPLE:
Learner: "How do React hooks work?"
Expert: "Hooks are functions that let you use state in functional components..."
Learner: "What's the difference between useState and useEffect?"
Expert: "useState manages component state, useEffect handles side effects..."

COMMANDS:
ai-mode-start.sh teach --expert "Agent1" --learner "Agent2" --topic "React Hooks"
PREVIEW
            ;;
        consensus)
            cat <<'PREVIEW'
🤝 CONSENSUS MODE

CONCEPT:
Both agents must reach agreement before proceeding. Emphasizes
collaborative decision-making and mutual understanding.

PROCESS:
1. Present problem/decision
2. Each agent shares perspective
3. Discuss differences and concerns
4. Refine solution until consensus
5. Document agreed approach

BEST FOR:
• Critical decisions requiring buy-in
• Design patterns and conventions
• API contracts and interfaces
• Architecture decisions with long-term impact

VOTING METHODS:
• Fist-of-Five: Rate agreement 0-5 (need 3+ to proceed)
• Dot Voting: Each agent distributes votes across options
• Roman Voting: Thumbs up/down/sideways for quick consensus

WORKFLOW:
1. State the decision/problem clearly
2. Each agent proposes approach
3. Discuss pros/cons of each approach
4. Vote on preferred solution
5. If no consensus, iterate until agreement

EXAMPLE:
Agent1: "I propose GraphQL for the API"
Agent2: "REST might be simpler for this use case"
[Discussion of trade-offs]
Consensus: "Start with REST, design schema for future GraphQL migration"

COMMANDS:
ai-mode-start.sh consensus --method "fist-of-five"
PREVIEW
            ;;
        competition)
            cat <<'PREVIEW'
⚔️  COMPETITION MODE

CONCEPT:
Agents independently develop solutions to the same problem, then
compare approaches to identify the best elements of each.

STRUCTURE:
1. Define problem and success criteria
2. Agents work independently (no collaboration)
3. Present solutions simultaneously
4. Compare and evaluate approaches
5. Select best solution or synthesize hybrid

BEST FOR:
• Algorithm optimization challenges
• Multiple valid implementation approaches
• Innovation through diverse thinking
• Benchmark different strategies

WORKFLOW:
1. Clearly define problem and constraints
2. Set time limit for independent work
3. Agents develop solutions separately
4. Present solutions with rationale
5. Evaluate against criteria
6. Select winner or create hybrid

EVALUATION CRITERIA:
• Performance/efficiency
• Code quality and maintainability
• Completeness and correctness
• Innovation and creativity

EXAMPLE:
Problem: "Optimize database query performance"
Agent1: Uses caching strategy
Agent2: Uses query optimization and indexing
Result: Combine both - cache + optimized queries

COMMANDS:
ai-mode-start.sh compete --problem "Sort algorithm for large dataset" --time-limit "30min"
PREVIEW
            ;;
        *)
            echo "No preview available for: $mode"
            ;;
    esac
}

export -f preview_mode get_mode_stats
export STATS_FILE

# Handle internal commands first
if [[ "${1:-}" == "list-modes" ]]; then
    list_modes "${2:-alphabetical}"
    exit 0
fi

if [[ "${1:-}" == "--toggle-favorite" ]]; then
    toggle_favorite "$2"
    exit 0
fi

# Parse arguments
SORT_MODE="alphabetical"
while [[ $# -gt 0 ]]; do
    case $1 in
        --sort)
            SORT_MODE="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

# Build fzf options
FZF_OPTS=(
    --ansi
    --preview 'bash -c "preview_mode {}"'
    --preview-window 'right:65%:wrap'
    --header "🚀 AI Mode Launcher (⭐=Core, Default=Legacy) | Ctrl-F=Favorite | Alt-A/R/Q/F=Sort | ESC=Cancel"
    --border rounded
    --height 90%
    --layout reverse
    --prompt "🔍 Select mode (Core modes first): "
    --pointer "▶"
    --marker "✓"
    --color 'fg:#f8f8f2,bg:#282a36,hl:#bd93f9'
    --color 'fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9'
    --color 'info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6'
    --color 'marker:#ff79c6,spinner:#ffb86c,header:#6272a4'
    --bind 'ctrl-d:preview-half-page-down'
    --bind 'ctrl-u:preview-half-page-up'
    --bind "ctrl-f:execute-silent(bash '$0' --toggle-favorite {2})+reload(bash '$0' list-modes $SORT_MODE)"
    --bind "alt-a:reload(bash '$0' list-modes alphabetical)+change-header(🚀 Sort: Alphabetical (Core First))"
    --bind "alt-r:reload(bash '$0' list-modes recent)+change-header(🚀 Sort: Recent (Core First))"
    --bind "alt-q:reload(bash '$0' list-modes frequent)+change-header(🚀 Sort: Most Used (Core First))"
    --bind "alt-f:reload(bash '$0' list-modes favorites)+change-header(🚀 Sort: Favorites)"
)

# If in tmux and version 3.2+, use popup
if [[ -n "${TMUX:-}" ]]; then
    tmux_version=$(tmux -V | grep -oP '\d+\.\d+' || echo "0.0")
    if awk "BEGIN {exit !($tmux_version >= 3.2)}" 2>/dev/null; then
        selected=$(list_modes "$SORT_MODE" | fzf-tmux -p 90%,90% "${FZF_OPTS[@]}")
    else
        selected=$(list_modes "$SORT_MODE" | fzf "${FZF_OPTS[@]}")
    fi
else
    selected=$(list_modes "$SORT_MODE" | fzf "${FZF_OPTS[@]}")
fi

# Process selection
if [[ -n "$selected" ]]; then
    mode=$(echo "$selected" | awk '{print $2}')

    # Update stats
    update_mode_stats "$mode"

    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo "Selected mode: $mode"
    echo "═══════════════════════════════════════════════════════"
    echo ""

    # Check if mode start script exists
    if [[ -f "${SCRIPT_DIR}/ai-mode-start.sh" ]]; then
        echo "🚀 Launching $mode mode..."
        echo ""

        # Launch the mode
        "${SCRIPT_DIR}/ai-mode-start.sh" "$mode"
    else
        echo "📋 Mode: $mode"
        echo ""
        echo "To start this mode, use:"
        echo "  ai-mode-start.sh $mode [options]"
        echo ""
        echo "For more options and parameters, see:"
        echo "  ai-mode-start.sh $mode --help"
    fi
else
    echo ""
    echo "❌ No mode selected. Cancelled."
    exit 0
fi
