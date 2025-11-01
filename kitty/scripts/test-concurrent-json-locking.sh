#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Concurrent JSON Locking Test
# ═══════════════════════════════════════════════════════════
# Tests that file locking prevents race conditions when
# multiple processes update the same JSON file concurrently.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/json-utils.sh"
source "${SCRIPT_DIR}/lib/colors.sh"

echo "Running concurrent JSON locking test..."
echo ""

# Test configuration
TEST_FILE="/tmp/concurrent-test-$$.json"
NUM_PROCESSES=10
INCREMENTS_PER_PROCESS=10

# Initialize test file
echo '{"count": 0, "processes": []}' > "$TEST_FILE"

success_color "✓ Created test file: $TEST_FILE"

# Test function that increments counter
increment_counter() {
    local process_id="$1"
    local iterations="$2"
    local test_file="$3"

    for ((i=1; i<=iterations; i++)); do
        # Read current value
        current=$(json_read "$test_file" '.count')

        # Increment
        new_value=$((current + 1))

        # Write back
        json_write "$test_file" '.count = ($count | tonumber)' --arg count "$new_value" >/dev/null

        # Small random delay to increase contention
        sleep 0.0$((RANDOM % 3))
    done
}

export -f increment_counter
export -f json_read
export -f json_write
export -f json_validate
export -f lock_acquire
export -f lock_acquire_shared
export -f lock_release
export -f lock_available

echo "Starting $NUM_PROCESSES concurrent processes..."
echo "Each process will increment counter $INCREMENTS_PER_PROCESS times"
echo ""

# Launch concurrent processes
pids=()
for ((p=1; p<=NUM_PROCESSES; p++)); do
    increment_counter $p $INCREMENTS_PER_PROCESS "$TEST_FILE" &
    pids+=($!)
done

# Wait for all processes to complete
for pid in "${pids[@]}"; do
    wait $pid 2>/dev/null || true
done

success_color "✓ All $NUM_PROCESSES processes completed"
echo ""

# Verify results
expected_count=$((NUM_PROCESSES * INCREMENTS_PER_PROCESS))
actual_count=$(json_read "$TEST_FILE" '.count')

echo "Expected count: $expected_count"
echo "Actual count:   $actual_count"
echo ""

if [[ "$actual_count" == "$expected_count" ]]; then
    success_color "✅ PASS: Counter is correct!"
    success_color "   File locking prevented race conditions"
    success_color "   All $expected_count increments were atomic"
else
    error_color "❌ FAIL: Counter mismatch!"
    error_color "   Expected: $expected_count"
    error_color "   Got: $actual_count"
    error_color "   Lost updates: $((expected_count - actual_count))"
    rm -f "$TEST_FILE"
    exit 1
fi

# Validate JSON structure
if json_validate "$TEST_FILE" >/dev/null 2>&1; then
    success_color "✅ JSON file structure is valid"
else
    error_color "❌ JSON file corrupted"
    rm -f "$TEST_FILE"
    exit 1
fi

# Cleanup
rm -f "$TEST_FILE"

echo ""
success_color "✅ Concurrent locking test passed!"
