#!/usr/bin/env bash
# Simple JSON Error Handling Tests

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/json-utils.sh"

TEST_DIR="/tmp/json-test-$$"
mkdir -p "$TEST_DIR"

echo "Running JSON error handling tests..."
echo ""

# Test 1: Create valid JSON
echo "✓ Test 1: json_create with valid JSON"
json_create "$TEST_DIR/test1.json" '{"test": "value"}' >/dev/null
[[ -f "$TEST_DIR/test1.json" ]] || { echo "FAIL: file not created"; exit 1; }

# Test 2: Read JSON field
echo "✓ Test 2: json_read value"
value=$(json_read "$TEST_DIR/test1.json" '.test')
[[ "$value" == "value" ]] || { echo "FAIL: got $value"; exit 1; }

# Test 3: Write JSON field
echo "✓ Test 3: json_write update"
json_write "$TEST_DIR/test1.json" '.test = "updated"' >/dev/null
value=$(json_read "$TEST_DIR/test1.json" '.test')
[[ "$value" == "updated" ]] || { echo "FAIL: got $value"; exit 1; }

# Test 4: Field exists check
echo "✓ Test 4: json_field_exists"
json_field_exists "$TEST_DIR/test1.json" '.test' || { echo "FAIL"; exit 1; }

# Test 5: Validate JSON
echo "✓ Test 5: json_validate"
json_validate "$TEST_DIR/test1.json" >/dev/null || { echo "FAIL"; exit 1; }

# Test 6: Invalid JSON handling
echo "✓ Test 6: Invalid JSON rejection"
echo "invalid" > "$TEST_DIR/bad.json"
json_validate "$TEST_DIR/bad.json" 2>/dev/null && { echo "FAIL: should reject"; exit 1; } || true

# Cleanup
rm -rf "$TEST_DIR"

echo ""
echo "✅ All 6 tests passed!"
