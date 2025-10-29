#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# AI Agents - fzf Mode Quick Launcher
# ═══════════════════════════════════════════════════════════
# Interactive mode selection with descriptions and examples

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if fzf is installed
if ! command -v fzf &>/dev/null; then
    echo "❌ fzf not installed!"
    echo "Install with: sudo apt install fzf"
    exit 1
fi

# List modes with metadata
list_modes() {
    cat <<'EOF'
🎯 pair-programming    |  Driver/Navigator - One codes, one reviews in real-time
💬 debate              |  Structured Discussion - Thesis → Antithesis → Synthesis
🎓 teaching            |  Expert/Learner - Knowledge transfer with Q&A
🤝 consensus           |  Agreement Building - Collaborative decision-making
⚔️  competition        |  Best Solution Wins - Independent approaches compared
EOF
}

# Preview mode details
preview_mode() {
    local line="$1"
    local mode=$(echo "$line" | awk -F'|' '{print $1}' | awk '{print $2}')

    echo "═══════════════════════════════════════════════════════"
    echo "Mode: $mode"
    echo "═══════════════════════════════════════════════════════"
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
ai-mode-start.sh pair-programming --driver "Agent1" --navigator "Agent2"
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
ai-mode-start.sh teaching --expert "Agent1" --learner "Agent2" --topic "React Hooks"
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
ai-mode-start.sh competition --problem "Sort algorithm for large dataset" --time-limit "30min"
PREVIEW
            ;;
        *)
            echo "No preview available for: $mode"
            ;;
    esac
}

export -f preview_mode

# Build fzf options
FZF_OPTS=(
    --ansi
    --preview 'bash -c "preview_mode {}"'
    --preview-window 'right:65%:wrap'
    --header "🚀 AI Agents Mode Launcher | Enter=Launch | Ctrl-C=Cancel"
    --border rounded
    --height 90%
    --layout reverse
    --prompt "🔍 Select mode: "
    --pointer "▶"
    --marker "✓"
    --color 'fg:#f8f8f2,bg:#282a36,hl:#bd93f9'
    --color 'fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9'
    --color 'info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6'
    --color 'marker:#ff79c6,spinner:#ffb86c,header:#6272a4'
    --bind 'ctrl-d:preview-half-page-down'
    --bind 'ctrl-u:preview-half-page-up'
    --bind 'ctrl-f:preview-page-down'
    --bind 'ctrl-b:preview-page-up'
)

# If in tmux and version 3.2+, use popup
if [[ -n "${TMUX:-}" ]]; then
    tmux_version=$(tmux -V | grep -oP '\d+\.\d+' || echo "0.0")
    if awk "BEGIN {exit !($tmux_version >= 3.2)}" 2>/dev/null; then
        selected=$(list_modes | fzf-tmux -p 90%,90% "${FZF_OPTS[@]}")
    else
        selected=$(list_modes | fzf "${FZF_OPTS[@]}")
    fi
else
    selected=$(list_modes | fzf "${FZF_OPTS[@]}")
fi

# Process selection
if [[ -n "$selected" ]]; then
    mode=$(echo "$selected" | awk -F'|' '{print $1}' | awk '{print $2}')

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
