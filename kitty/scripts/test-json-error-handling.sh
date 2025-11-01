#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# JSON Error Handling Test Suite
# ═══════════════════════════════════════════════════════════

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/json-utils.sh"
source "${SCRIPT_DIR}/lib/colors.sh" 2>/dev/null || true

TEST_DIR="/tmp/json-test-$$"
mkdir -p "$TEST_DIR"

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

# Test helper functions
test_passed() {
    ((TESTS_PASSED++))
    echo "✅ $1"
}

test_failed() {
    ((TESTS_FAILED++))
    echo "❌ $1"
}

# ───────────────────────────────────────────────────────────
# Test 1: json_create with valid JSON
# ───────────────────────────────────────────────────────────
echo "Test 1: json_create with valid JSON"
if json_create "$TEST_DIR/test1.json" '{"test": "value"}'; then
    if [[ -f "$TEST_DIR/test1.json" ]]; then
        test_passed "json_create creates valid JSON file"
    else
        test_failed "json_create did not create file"
    fi
else
    test_failed "json_create failed with valid JSON"
fi

# ───────────────────────────────────────────────────────────
# Test 2: json_create with invalid JSON
# ───────────────────────────────────────────────────────────
echo "Test 2: json_create with invalid JSON"
if json_create "$TEST_DIR/test2.json" '{invalid json}' 2>&1 | grep -q "Invalid JSON"; then
    test_passed "json_create correctly rejects invalid JSON"
else
    test_failed "json_create should reject invalid JSON"
fi

# ───────────────────────────────────────────────────────────
# Test 3: json_read with valid file and field
# ───────────────────────────────────────────────────────────
echo "Test 3: json_read with valid file and field"
json_create "$TEST_DIR/test3.json" '{"name": "test", "count": 42}'
value=$(json_read "$TEST_DIR/test3.json" '.name')
if [[ "$value" == "test" ]]; then
    test_passed "json_read reads correct value"
else
    test_failed "json_read returned: $value (expected: test)"
fi

# ───────────────────────────────────────────────────────────
# Test 4: json_read with missing field (with default)
# ───────────────────────────────────────────────────────────
echo "Test 4: json_read with missing field (with default)"
value=$(json_read "$TEST_DIR/test3.json" '.missing' "default_value" 2>/dev/null)
if [[ "$value" == "default_value" ]]; then
    test_passed "json_read returns default for missing field"
else
    test_failed "json_read returned: $value (expected: default_value)"
fi

# ───────────────────────────────────────────────────────────
# Test 5: json_read with corrupted JSON
# ───────────────────────────────────────────────────────────
echo "Test 5: json_read with corrupted JSON"
echo "{corrupt json" > "$TEST_DIR/test5.json"
if json_read "$TEST_DIR/test5.json" '.field' 2>/dev/null; then
    test_failed "json_read should fail on corrupt JSON"
else
    test_passed "json_read correctly handles corrupt JSON"
fi

# ───────────────────────────────────────────────────────────
# Test 6: json_write updates existing field
# ───────────────────────────────────────────────────────────
echo "Test 6: json_write updates existing field"
json_create "$TEST_DIR/test6.json" '{"count": 0}' 2>/dev/null
if json_write "$TEST_DIR/test6.json" '.count = 1' 2>/dev/null; then
    value=$(json_read "$TEST_DIR/test6.json" '.count' 2>/dev/null)
    if [[ "$value" == "1" ]]; then
        test_passed "json_write updates field correctly"
    else
        test_failed "json_write update failed (got: $value)"
    fi
else
    test_failed "json_write failed"
fi

# ───────────────────────────────────────────────────────────
# Test 7: json_write with invalid update expression
# ───────────────────────────────────────────────────────────
echo "Test 7: json_write with invalid update expression"
json_create "$TEST_DIR/test7.json" '{"value": "original"}' 2>/dev/null
cp "$TEST_DIR/test7.json" "$TEST_DIR/test7.backup"
if json_write "$TEST_DIR/test7.json" 'invalid jq syntax' 2>/dev/null; then
    test_failed "json_write should fail on invalid expression"
else
    # Verify original file is preserved
    value=$(json_read "$TEST_DIR/test7.json" '.value' 2>/dev/null)
    if [[ "$value" == "original" ]]; then
        test_passed "json_write preserves file on error"
    else
        test_failed "json_write corrupted file on error"
    fi
fi

# ───────────────────────────────────────────────────────────
# Test 8: json_field_exists positive case
# ───────────────────────────────────────────────────────────
echo "Test 8: json_field_exists positive case"
json_create "$TEST_DIR/test8.json" '{"field": "exists"}' 2>/dev/null
if json_field_exists "$TEST_DIR/test8.json" '.field' 2>/dev/null; then
    test_passed "json_field_exists detects existing field"
else
    test_failed "json_field_exists failed to detect field"
fi

# ───────────────────────────────────────────────────────────
# Test 9: json_field_exists negative case
# ───────────────────────────────────────────────────────────
echo "Test 9: json_field_exists negative case"
if json_field_exists "$TEST_DIR/test8.json" '.nonexistent' 2>/dev/null; then
    test_failed "json_field_exists should not detect missing field"
else
    test_passed "json_field_exists correctly reports missing field"
fi

# ───────────────────────────────────────────────────────────
# Test 10: json_validate with valid JSON
# ───────────────────────────────────────────────────────────
echo "Test 10: json_validate with valid JSON"
json_create "$TEST_DIR/test10.json" '{"valid": true}' 2>/dev/null
if json_validate "$TEST_DIR/test10.json" 2>/dev/null; then
    test_passed "json_validate accepts valid JSON"
else
    test_failed "json_validate rejected valid JSON"
fi

# ───────────────────────────────────────────────────────────
# Test 11: json_validate with invalid JSON
# ───────────────────────────────────────────────────────────
echo "Test 11: json_validate with invalid JSON"
echo "{invalid" > "$TEST_DIR/test11.json"
if json_validate "$TEST_DIR/test11.json" 2>/dev/null; then
    test_failed "json_validate should reject invalid JSON"
else
    test_passed "json_validate correctly rejects invalid JSON"
fi

# ───────────────────────────────────────────────────────────
# Test 12: json_write atomic operation (no temp file left)
# ───────────────────────────────────────────────────────────
echo "Test 12: json_write atomic operation cleanup"
json_create "$TEST_DIR/test12.json" '{"test": "value"}' 2>/dev/null
json_write "$TEST_DIR/test12.json" '.test = "updated"' 2>/dev/null
if ls "$TEST_DIR"/test12.json.tmp.* 2>/dev/null || ls "$TEST_DIR"/test12.json.backup.* 2>/dev/null; then
    test_failed "json_write left temporary files"
else
    test_passed "json_write cleans up temporary files"
fi

# ───────────────────────────────────────────────────────────
# Cleanup and Summary
# ───────────────────────────────────────────────────────────
rm -rf "$TEST_DIR"

echo ""
echo "═══════════════════════════════════════"
echo "Test Results:"
echo "  Passed: $TESTS_PASSED"
echo "  Failed: $TESTS_FAILED"
echo "  Total:  $((TESTS_PASSED + TESTS_FAILED))"
echo "═══════════════════════════════════════"

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo "✅ All tests passed!"
    exit 0
else
    echo "❌ Some tests failed!"
    exit 1
fi
