#!/usr/bin/env bash
set -euo pipefail

# Test framework for kitty and tmux configurations

# Absolute path to the repository root
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
KITTY_CONFIG="${REPO_ROOT}/kitty/kitty.conf"
TMUX_CONFIG="${REPO_ROOT}/kitty/tmux.conf"

# Test state
failures=0
tests_run=0

# Test runner function
assert_contains() {
    local test_name="$1"
    local file_path="$2"
    local expected_substring="$3"
    ((tests_run++))

    if grep -q "$expected_substring" "$file_path"; then
        echo "✅ PASS: $test_name"
    else
        echo "❌ FAIL: $test_name"
        echo "   Expected file $file_path to contain: $expected_substring"
        ((failures++))
    fi
}

# --- Test Cases ---

test_kitty_config() {
    local test_name="kitty.conf includes keybindings"
    assert_contains "$test_name" "$KITTY_CONFIG" "include kitty.d/keybindings.conf"
}

test_tmux_config() {
    local test_name="tmux.conf sets the correct prefix"
    assert_contains "$test_name" "$TMUX_CONFIG" "set -g prefix C-b"
}

# --- Test Execution ---
run_tests() {
    echo "Running tests for kitty and tmux configurations..."
    echo ""

    test_kitty_config
    test_tmux_config

    echo ""
    echo "--------------------"
    if (( failures == 0 )); then
        echo "✅ All $tests_run tests passed."
        exit 0
    else
        echo "❌ $failures out of $tests_run tests failed."
        exit 1
    fi
}

run_tests
