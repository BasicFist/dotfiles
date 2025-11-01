#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Simple File Locking Test
# ═══════════════════════════════════════════════════════════

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/json-utils.sh"
source "${SCRIPT_DIR}/lib/colors.sh"

echo "Testing file locking integration..."
echo ""

# Test 1: Verify locking is enabled
if [[ "$JSON_LOCKING_ENABLED" == "true" ]]; then
    success_color "✅ File locking is enabled in json-utils"
else
    error_color "❌ File locking is NOT enabled"
    exit 1
fi

# Test 2: Verify flock is available
if lock_available; then
    success_color "✅ flock command is available"
else
    error_color "❌ flock command not found"
    exit 1
fi

# Test 3: Simple read with lock
TEST_FILE="/tmp/lock-test-$$.json"
echo '{"value": 42}' > "$TEST_FILE"

value=$(json_read "$TEST_FILE" '.value')
if [[ "$value" == "42" ]]; then
    success_color "✅ json_read with locking works"
else
    error_color "❌ json_read failed"
    rm -f "$TEST_FILE"
    exit 1
fi

# Test 4: Simple write with lock
if json_write "$TEST_FILE" '.value = 100' >/dev/null 2>&1; then
    value=$(json_read "$TEST_FILE" '.value')
    if [[ "$value" == "100" ]]; then
        success_color "✅ json_write with locking works"
    else
        error_color "❌ json_write produced wrong value: $value"
        rm -f "$TEST_FILE"
        exit 1
    fi
else
    error_color "❌ json_write failed"
    rm -f "$TEST_FILE"
    exit 1
fi

# Test 5: Sequential updates (should work)
echo '{"count": 0}' > "$TEST_FILE"

for ((i=1; i<=10; i++)); do
    current=$(json_read "$TEST_FILE" '.count')
    new_value=$((current + 1))
    json_write "$TEST_FILE" '.count = ($count | tonumber)' --arg count "$new_value" >/dev/null 2>&1
done

final=$(json_read "$TEST_FILE" '.count')
if [[ "$final" == "10" ]]; then
    success_color "✅ Sequential updates work correctly"
else
    error_color "❌ Sequential updates failed: got $final, expected 10"
    rm -f "$TEST_FILE"
    exit 1
fi

# Cleanup
rm -f "$TEST_FILE"

echo ""
success_color "✅ All 5 file locking integration tests passed!"
