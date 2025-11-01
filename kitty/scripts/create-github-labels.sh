#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Create GitHub Labels for Improvement Roadmap
# ═══════════════════════════════════════════════════════════
# Automatically creates all required labels using GitHub CLI

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
    echo ""
    echo "Or download from: https://cli.github.com/"
    exit 1
fi

# Check authentication
if ! gh auth status &> /dev/null; then
    error "Not authenticated with GitHub CLI"
    echo ""
    echo "Run: gh auth login"
    exit 1
fi

info "Creating GitHub labels for improvement roadmap..."
echo ""

# Priority Labels
info "Creating priority labels..."
gh label create "priority: critical" --color "B60205" --description "Blocking issue, must fix immediately" --force 2>/dev/null && success "Created: priority: critical" || warning "Already exists: priority: critical"
gh label create "priority: high" --color "D93F0B" --description "Important, schedule soon" --force 2>/dev/null && success "Created: priority: high" || warning "Already exists: priority: high"
gh label create "priority: medium" --color "FBCA04" --description "Normal priority" --force 2>/dev/null && success "Created: priority: medium" || warning "Already exists: priority: medium"
gh label create "priority: low" --color "0E8A16" --description "Nice to have, low urgency" --force 2>/dev/null && success "Created: priority: low" || warning "Already exists: priority: low"
echo ""

# Phase Labels
info "Creating phase labels..."
gh label create "phase: 0-foundation" --color "0052CC" --description "Phase 0: Foundation Stabilization" --force 2>/dev/null && success "Created: phase: 0-foundation" || warning "Already exists: phase: 0-foundation"
gh label create "phase: 1-completion" --color "0052CC" --description "Phase 1: Completion & Polish" --force 2>/dev/null && success "Created: phase: 1-completion" || warning "Already exists: phase: 1-completion"
gh label create "phase: 2-advanced" --color "5319E7" --description "Phase 2: Advanced Features" --force 2>/dev/null && success "Created: phase: 2-advanced" || warning "Already exists: phase: 2-advanced"
gh label create "phase: 3-enterprise" --color "5319E7" --description "Phase 3: Enterprise Features" --force 2>/dev/null && success "Created: phase: 3-enterprise" || warning "Already exists: phase: 3-enterprise"
gh label create "phase: 4-optimization" --color "5319E7" --description "Phase 4: Optimization & Scale" --force 2>/dev/null && success "Created: phase: 4-optimization" || warning "Already exists: phase: 4-optimization"
echo ""

# Type Labels
info "Creating type labels..."
gh label create "type: bug" --color "D73A4A" --description "Something isn't working" --force 2>/dev/null && success "Created: type: bug" || warning "Already exists: type: bug"
gh label create "type: security" --color "D73A4A" --description "Security vulnerability or hardening" --force 2>/dev/null && success "Created: type: security" || warning "Already exists: type: security"
gh label create "type: enhancement" --color "A2EEEF" --description "New feature or improvement" --force 2>/dev/null && success "Created: type: enhancement" || warning "Already exists: type: enhancement"
gh label create "type: performance" --color "FBCA04" --description "Performance optimization" --force 2>/dev/null && success "Created: type: performance" || warning "Already exists: type: performance"
gh label create "type: documentation" --color "0075CA" --description "Documentation updates" --force 2>/dev/null && success "Created: type: documentation" || warning "Already exists: type: documentation"
gh label create "type: meta" --color "D4C5F9" --description "Process or meta issue" --force 2>/dev/null && success "Created: type: meta" || warning "Already exists: type: meta"
echo ""

# Effort Labels
info "Creating effort labels..."
gh label create "effort: small" --color "C2E0C6" --description "1-2 days of work" --force 2>/dev/null && success "Created: effort: small" || warning "Already exists: effort: small"
gh label create "effort: medium" --color "FEF2C0" --description "3-5 days of work" --force 2>/dev/null && success "Created: effort: medium" || warning "Already exists: effort: medium"
gh label create "effort: large" --color "F9D0C4" --description "1-2 weeks of work" --force 2>/dev/null && success "Created: effort: large" || warning "Already exists: effort: large"
echo ""

success "Label creation complete!"
echo ""
info "Total labels created:"
echo "  - Priority: 4 labels"
echo "  - Phase: 5 labels"
echo "  - Type: 6 labels"
echo "  - Effort: 3 labels"
echo ""
info "View all labels at:"
gh repo view --web 2>/dev/null && echo "  Click on 'Issues' → 'Labels'" || echo "  https://github.com/YOUR-USERNAME/YOUR-REPO/labels"
