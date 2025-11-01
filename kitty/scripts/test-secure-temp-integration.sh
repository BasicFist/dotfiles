#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Secure Temp Files Integration Test
# ═══════════════════════════════════════════════════════════

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/temp-files.sh"
source "${SCRIPT_DIR}/lib/colors.sh"

echo "Running secure temp files integration tests..."
echo ""

# Test 1: Verify permissions on temp file
echo "Test 1: Temp file has secure permissions (600)"
tmpfile=$(temp_file "" "noregister")
perms=$(stat -c '%a' "$tmpfile")
if [[ "$perms" == "600" ]]; then
    success_color "✅ Temp file permissions: $perms"
else
    error_color "❌ Insecure permissions: $perms (expected 600)"
    rm -f "$tmpfile"
    exit 1
fi

# Test 2: Verify permissions on temp dir
echo "Test 2: Temp dir has secure permissions (700)"
tmpdir=$(temp_dir "" "noregister")
perms=$(stat -c '%a' "$tmpdir")
if [[ "$perms" == "700" ]]; then
    success_color "✅ Temp dir permissions: $perms"
else
    error_color "❌ Insecure permissions: $perms (expected 700)"
    rm -rf "$tmpdir"
    exit 1
fi

# Test 3: App temp directory
echo "Test 3: App temp directory created and secured"
SESSION="test-$$"
app_dir=$(temp_app_dir "ai-mode-${SESSION}")
if [[ -d "$app_dir" ]]; then
    perms=$(stat -c '%a' "$app_dir")
    if [[ "$perms" == "700" ]]; then
        success_color "✅ App temp dir: $app_dir ($perms)"
    else
        error_color "❌ Insecure app dir: $perms"
        exit 1
    fi
else
    error_color "❌ App dir not created"
    exit 1
fi

# Test 4: Atomic temp file in correct location
echo "Test 4: Atomic temp file created for target"
test_target="$app_dir/test-state.json"
tmpatomic=$(temp_atomic "$test_target")
temp_unregister "$tmpatomic"
if [[ "$tmpatomic" =~ ${test_target}\.tmp\. ]]; then
    success_color "✅ Atomic temp file: $(basename "$tmpatomic")"
else
    error_color "❌ Wrong atomic pattern: $tmpatomic"
    exit 1
fi

# Test 5: Write and move atomically
echo "Test 5: Atomic write simulation"
echo '{"test": "value"}' > "$tmpatomic"
mv "$tmpatomic" "$test_target"
if [[ -f "$test_target" ]]; then
    content=$(cat "$test_target")
    if [[ "$content" == '{"test": "value"}' ]]; then
        success_color "✅ Atomic write successful"
    else
        error_color "❌ Content mismatch"
        exit 1
    fi
else
    error_color "❌ Atomic move failed"
    exit 1
fi

# Cleanup test resources
rm -f "$tmpfile"
rm -rf "$tmpdir" "$app_dir"

echo ""
success_color "✅ All 5 integration tests passed!"
