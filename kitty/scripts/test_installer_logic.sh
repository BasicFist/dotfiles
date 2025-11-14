#!/usr/bin/env bash
set -euo pipefail

# Test framework for installer logic

# Absolute path to the repository root
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${REPO_ROOT}/kitty/scripts/lib/installer_logic.sh"

# Test state
failures=0
tests_run=0

# Test runner function
assert_true() {
    local test_name="$1"
    shift
    ((tests_run++))

    if "$@"; then
        echo "✅ PASS: $test_name"
    else
        echo "❌ FAIL: $test_name"
        ((failures++))
    fi
}

# --- Test Setup ---

setup() {
    # Create a fake kitty directory
    mkdir -p kitty/kitty.d
    echo "include kitty.d/keybindings.conf" > kitty/kitty.conf
    echo "map ctrl+alt+x launch --type=tab --cwd=current ${HOME}/.config/kitty/scripts/launch-ai-agents-tmux.sh" > kitty/kitty.d/keybindings.conf
    echo "set -g prefix C-b" > kitty/tmux.conf
}

teardown() {
    rm -rf kitty
}

# Mock git command
git() {
    if [[ "$1" == "clone" ]]; then
        mkdir -p "$3"
    fi
}

# --- Test Cases ---

test_pre_flight_checks_success() {
    local test_name="run_pre_flight_checks succeeds with all commands"

    # Create a fake bin directory and add it to the PATH
    local fake_bin
    fake_bin=$(mktemp -d)
    export PATH="$fake_bin:$PATH"

    # Create fake commands
    for cmd in git kitty tmux fzf xclip zoxide bat; do
        touch "${fake_bin}/${cmd}"
        chmod +x "${fake_bin}/${cmd}"
    done

    # Run the pre-flight checks
    local output
    output=$(run_pre_flight_checks 2>&1)

    assert_true "$test_name" "! echo \"$output\" | grep -q 'Missing required tools'"

    # Clean up
    rm -rf "$fake_bin"
}

test_pre_flight_checks_failure() {
    local test_name="run_pre_flight_checks fails with missing commands"

    # Create a fake bin directory and add it to the PATH
    local fake_bin
    fake_bin=$(mktemp -d)
    export PATH="$fake_bin"

    # Run the pre-flight checks, expecting failure
    local output
    output=$(run_pre_flight_checks 2>&1 || true)

    assert_true "$test_name" "echo \"$output\" | grep -q 'Missing required tools'"

    # Clean up
    rm -rf "$fake_bin"
}


# --- Test Execution ---
run_tests() {
    setup
    echo "Running tests for installer logic..."
    echo ""

    test_pre_flight_checks_success
    test_pre_flight_checks_failure

    echo ""
    echo "--------------------"
    if (( failures == 0 )); then
        echo "✅ All $tests_run tests passed."
        exit 0
    else
        echo "❌ $failures out of $tests_run tests failed."
        exit 1
    fi
    teardown
}

run_tests
