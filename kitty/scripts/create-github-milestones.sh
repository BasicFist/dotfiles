#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Create GitHub Milestones for Improvement Roadmap
# ═══════════════════════════════════════════════════════════
# Automatically creates all phase milestones with due dates

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() {
    echo -e "${BLUE}ℹ${NC} $*"
}

success() {
    echo -e "${GREEN}✓${NC} $*"
}

warning() {
    echo -e "${YELLOW}⚠${NC} $*"
}

error() {
    echo -e "${RED}✗${NC} $*"
}

# Check for gh CLI
if ! command -v gh &> /dev/null; then
    error "GitHub CLI (gh) not found!"
    echo ""
    echo "Install with:"
    echo "  sudo apt install gh"
    exit 1
fi

# Check authentication
if ! gh auth status &> /dev/null; then
    error "Not authenticated with GitHub CLI"
    echo ""
    echo "Run: gh auth login"
    exit 1
fi

info "Creating GitHub milestones for improvement roadmap..."
echo ""

# Calculate due dates (weeks from today)
calculate_date() {
    local weeks=$1
    date -d "+${weeks} weeks" +%Y-%m-%d
}

DATE_P0=$(calculate_date 2)
DATE_P1=$(calculate_date 5)
DATE_P2=$(calculate_date 9)
DATE_P3=$(calculate_date 13)
DATE_P4=$(calculate_date 16)

info "Milestone due dates:"
echo "  Phase 0: $DATE_P0 (2 weeks)"
echo "  Phase 1: $DATE_P1 (5 weeks)"
echo "  Phase 2: $DATE_P2 (9 weeks)"
echo "  Phase 3: $DATE_P3 (13 weeks)"
echo "  Phase 4: $DATE_P4 (16 weeks)"
echo ""

# Get repository info
REPO_OWNER=$(gh repo view --json owner --jq '.owner.login')
REPO_NAME=$(gh repo view --json name --jq '.name')

info "Creating milestones in: $REPO_OWNER/$REPO_NAME"
echo ""

# Helper function to create milestone
create_milestone() {
    local title="$1"
    local due_date="$2"
    local description="$3"

    # Format date for GitHub API (ISO 8601)
    local due_on="${due_date}T23:59:59Z"

    # Create milestone using GitHub API
    if gh api "repos/$REPO_OWNER/$REPO_NAME/milestones" \
        -X POST \
        -f title="$title" \
        -f due_on="$due_on" \
        -f description="$description" \
        >/dev/null 2>&1; then
        success "Created: $title (due: $due_date)"
    else
        warning "Failed to create or already exists: $title"
    fi
}

# Create Phase 0 milestone
create_milestone \
    "Phase 0: Foundation Stabilization" \
    "$DATE_P0" \
    "Fix critical issues, eliminate technical debt, establish baseline quality standards. Includes ShellCheck fixes, error handling, secure temp files, file locking, and configuration centralization."

# Create Phase 1 milestone
create_milestone \
    "Phase 1: Completion & Polish" \
    "$DATE_P1" \
    "Complete partial implementations and add missing features. Includes fzf integration completion, ADR support, enhanced test coverage, and documentation consolidation."

# Create Phase 2 milestone
create_milestone \
    "Phase 2: Advanced Features" \
    "$DATE_P2" \
    "Add enterprise capabilities, monitoring, and optimization. Includes structured logging, performance optimization, remote session support, and metrics/analytics."

# Create Phase 3 milestone
create_milestone \
    "Phase 3: Enterprise Features" \
    "$DATE_P3" \
    "Production hardening, compliance, and scale. Includes RBAC, audit logging, backup/disaster recovery, and plugin system."

# Create Phase 4 milestone
create_milestone \
    "Phase 4: Optimization & Scale" \
    "$DATE_P4" \
    "Handle large-scale deployments and final optimization. Includes resource management, advanced search, and CI/CD pipeline."

echo ""
success "Milestone creation complete!"
echo ""
info "Total milestones created: 5 phases"
echo ""
info "View milestones at:"
gh repo view --web 2>/dev/null && echo "  Click on 'Issues' → 'Milestones'" || echo "  https://github.com/$REPO_OWNER/$REPO_NAME/milestones"
echo ""
info "Next step: Create Phase 0 issues and assign to the first milestone"
