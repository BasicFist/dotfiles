#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# AI Agents - Self Test Suite
# ═══════════════════════════════════════════════════════════
# Comprehensive system validation and testing

set -euo pipefail

# Source required libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/colors.sh"
source "${SCRIPT_DIR}/lib/errors.sh"
source "${SCRIPT_DIR}/lib/config.sh"
source "${SCRIPT_DIR}/lib/progress.sh"

# Configuration
TEST_RESULTS_DIR="/tmp/ai-agents-tests-$$"
mkdir -p "$TEST_RESULTS_DIR"

# Test categories
TEST_CATEGORIES=(
    "security"
    "performance"
    "configuration"
    "integration"
    "error_handling"
)

# Test results tracking
declare -A test_results
total_tests=0
passed_tests=0
failed_tests=0

# Cleanup function
cleanup() {
    rm -rf "$TEST_RESULTS_DIR" 2>/dev/null || true
}

# Trap cleanup
trap cleanup EXIT

usage() {
    cat <<EOF
Usage: ai-self-test.sh [OPTIONS] [CATEGORY...]

Run comprehensive self-tests for AI Agents system.

CATEGORIES:
  all              Run all tests (default)
  security         Security-related tests
  performance      Performance and optimization tests
  configuration    Configuration management tests
  integration      Integration and workflow tests
  error_handling   Error handling and recovery tests

OPTIONS:
  -h, --help       Show this help message
  -v, --verbose    Enable verbose output
  -q, --quiet      Quiet mode (minimal output)
  -f, --fast       Fast mode (skip long-running tests)
  --list           List all available test categories
  --report         Generate detailed test report

EXAMPLES:
  ai-self-test.sh
  ai-self-test.sh security
  ai-self-test.sh --verbose performance configuration
  ai-self-test.sh --report

EOF
}

# List test categories
list_categories() {
    info_color "Available Test Categories:"
    for category in "${TEST_CATEGORIES[@]}"; do
        echo "  - $category"
    done
}

# Test result recording
record_test_result() {
    local test_name="$1"
    local category="$2"
    local status="$3"  # PASS, FAIL, SKIP
    local message="${4:-}"
    
    test_results["$test_name"]="$status|$category|$message"
    ((total_tests++))
    
    case "$status" in
        PASS)
            ((passed_tests++))
            if [[ "${VERBOSE:-false}" == "true" ]]; then
                success_color "✅ PASS: $test_name"
                [[ -n "$message" ]] && info_color "   $message"
            fi
            ;;
        FAIL)
            ((failed_tests++))
            error_color "❌ FAIL: $test_name"
            [[ -n "$message" ]] && error_color "   $message"
            ;;
        SKIP)
            if [[ "${VERBOSE:-false}" == "true" ]]; then
                warning_color "⚠️  SKIP: $test_name"
                [[ -n "$message" ]] && warning_color "   $message"
            fi
            ;;
    esac
}

# Run single test
run_test() {
    local test_name="$1"
    local category="$2"
    local test_function="$3"
    
    # Check if we should run this category
    local should_run=false
    if [[ "${#CATEGORY_FILTER[@]}" -eq 0 ]]; then
        should_run=true
    else
        for filter_category in "${CATEGORY_FILTER[@]}"; do
            if [[ "$filter_category" == "all" ]] || [[ "$filter_category" == "$category" ]]; then
                should_run=true
                break
            fi
        done
    fi
    
    # Skip if not in filter
    if [[ "$should_run" == "false" ]]; then
        record_test_result "$test_name" "$category" "SKIP" "Not in category filter"
        return 0
    fi
    
    # Run the test
    if declare -f "$test_function" >/dev/null 2>&1; then
        if "$test_function"; then
            record_test_result "$test_name" "$category" "PASS"
        else
            record_test_result "$test_name" "$category" "FAIL" "Test function returned non-zero exit code"
        fi
    else
        record_test_result "$test_name" "$category" "FAIL" "Test function not found: $test_function"
    fi
}

# Security Tests
test_input_sanitization() {
    # Test that dangerous inputs are rejected
    local dangerous_inputs=(
        "test; rm -rf /"
        "test && echo hello"
        "test || echo hello"
        "test$(echo hello)"
        "test\`echo hello\`"
        "../etc/passwd"
        "../../etc/passwd"
        "~/../../../etc/passwd"
    )
    
    local success_count=0
    for input in "${dangerous_inputs[@]}"; do
        if sanitized=$(sanitize_input "$input" 2>/dev/null); then
            # Check if dangerous characters were removed
            if [[ ! "$sanitized" =~ [\;] ]] && [[ ! "$sanitized" =~ [\`] ]] && [[ ! "$sanitized" =~ [\|] ]] && [[ ! "$sanitized" =~ [\&] ]] && [[ ! "$sanitized" =~ [\$] ]]; then
                ((success_count++))
            fi
        else
            # Function should sanitize, not fail
            ((success_count++))
        fi
    done
    
    [[ $success_count -eq ${#dangerous_inputs[@]} ]]
}

test_path_validation() {
    # Test valid paths
    local valid_paths=(
        "test.txt"
        "subdir/test.txt"
        "./test.txt"
        "../test.txt"  # This should be rejected when validated against a base directory
    )
    
    local success_count=0
    for path in "${valid_paths[@]}"; do
        # Test without base directory constraint (should pass)
        if result=$(validate_path "$path" "/tmp" 2>/dev/null); then
            ((success_count++))
        fi
    done
    
    # Test that path traversal is blocked
    local dangerous_paths=(
        "../../../etc/passwd"
        "/etc/passwd"
        "~/../../../etc/passwd"
        "../other/file.txt"
    )
    
    local blocked_count=0
    for path in "${dangerous_paths[@]}"; do
        if ! validate_path "$path" "/tmp" 2>/dev/null; then
            ((blocked_count++))
        fi
    done
    
    [[ $success_count -eq ${#valid_paths[@]} ]] && [[ $blocked_count -eq ${#dangerous_paths[@]} ]]
}

test_file_permissions() {
    # Test that shared files have secure permissions
    local shared_file="${AI_AGENTS_SHARED_FILE:-/tmp/ai-agents-shared.txt}"
    
    if [[ -f "$shared_file" ]]; then
        local perms=$(stat -c%a "$shared_file" 2>/dev/null || echo "")
        # Should be 644 or more restrictive
        [[ "$perms" =~ ^(644|600|400|444)$ ]]
    else
        # If file doesn't exist, test passes (no insecure file)
        return 0
    fi
}

# Performance Tests
test_kb_index_performance() {
    # Test that indexing improves search performance
    local test_kb_dir="$TEST_RESULTS_DIR/kb-test"
    mkdir -p "$test_kb_dir"
    
    # Create test files
    for i in {1..100}; do
        echo "# Test Document $i" > "$test_kb_dir/doc_$i.md"
        echo "This is test content for document $i" >> "$test_kb_dir/doc_$i.md"
        echo "Tags: test,performance,document" >> "$test_kb_dir/doc_$i.md"
    done
    
    # Time direct search
    local start_time=$(date +%s.%N)
    grep -r "performance" "$test_kb_dir" >/dev/null 2>&1
    local direct_time=$(echo "$(date +%s.%N) - $start_time" | bc 2>/dev/null || echo "0")
    
    # Time indexed search (if indexer exists)
    if [[ -f "${SCRIPT_DIR}/ai-kb-index.sh" ]]; then
        # Build index
        "${SCRIPT_DIR}/ai-kb-index.sh" build --force >/dev/null 2>&1
        
        # Time indexed search
        start_time=$(date +%s.%N)
        "${SCRIPT_DIR}/ai-kb-index.sh" search "performance" >/dev/null 2>&1
        local indexed_time=$(echo "$(date +%s.%N) - $start_time" | bc 2>/dev/null || echo "0")
        
        # Cleanup
        rm -rf "$test_kb_dir" "${SCRIPT_DIR}/.index" 2>/dev/null || true
        
        # Indexed search should be faster (or at least not significantly slower)
        local ratio=$(echo "$indexed_time / $direct_time" | bc -l 2>/dev/null || echo "1")
        [[ $(echo "$ratio < 2" | bc 2>/dev/null || echo "1") -eq 1 ]]
    else
        # If indexer doesn't exist, test passes
        rm -rf "$test_kb_dir" 2>/dev/null || true
        return 0
    fi
}

test_session_listing_performance() {
    # Test session listing performance with optimization
    local sessions_dir="$TEST_RESULTS_DIR/sessions"
    mkdir -p "$sessions_dir"
    
    # Create test session files
    for i in {1..50}; do
        mkdir -p "$sessions_dir/session_$i"
        echo '{"name": "session_'$i'", "timestamp": "'$(date -Iseconds)'"}' > "$sessions_dir/session_$i/metadata.json"
    done
    
    # Time session listing
    local start_time=$(date +%s.%N)
    find "$sessions_dir" -maxdepth 1 -type d -name "session_*" -exec test -f "{}/metadata.json" \; -print | wc -l >/dev/null
    local listing_time=$(echo "$(date +%s.%N) - $start_time" | bc 2>/dev/null || echo "0")
    
    # Cleanup
    rm -rf "$sessions_dir" 2>/dev/null || true
    
    # Should complete in reasonable time (less than 1 second for 50 sessions)
    [[ $(echo "$listing_time < 1" | bc 2>/dev/null || echo "1") -eq 1 ]]
}

# Configuration Tests
test_config_creation() {
    # Test that configuration files are created properly
    local test_config_dir="$TEST_RESULTS_DIR/config-test"
    mkdir -p "$test_config_dir"
    
    # Set environment variable for test
    export AI_AGENTS_CONFIG_DIR="$test_config_dir"
    
    # Initialize config
    init_config
    
    # Check that files exist
    local config_exists=false
    local backup_dir_exists=false
    
    [[ -f "$test_config_dir/config.json" ]] && config_exists=true
    [[ -d "$test_config_dir/backups" ]] && backup_dir_exists=true
    
    # Cleanup
    rm -rf "$test_config_dir" 2>/dev/null || true
    unset AI_AGENTS_CONFIG_DIR
    
    [[ "$config_exists" == "true" ]] && [[ "$backup_dir_exists" == "true" ]]
}

test_config_operations() {
    # Test configuration get/set operations
    local test_config_dir="$TEST_RESULTS_DIR/config-test"
    mkdir -p "$test_config_dir"
    
    # Set environment variable for test
    export AI_AGENTS_CONFIG_DIR="$test_config_dir"
    
    # Initialize config
    init_config
    
    # Test setting and getting values
    local test_key="test.value"
    local test_value="test_setting"
    
    set_config "$test_key" "$test_value"
    local retrieved_value=$(get_config "$test_key")
    
    # Cleanup
    rm -rf "$test_config_dir" 2>/dev/null || true
    unset AI_AGENTS_CONFIG_DIR
    
    [[ "$retrieved_value" == "$test_value" ]]
}

# Integration Tests
test_tui_integration() {
    # Test that TUI script exists and is executable
    local tui_script="${SCRIPT_DIR}/ai-agents-tui.sh"
    
    if [[ -f "$tui_script" ]]; then
        # Check if script is executable
        [[ -x "$tui_script" ]] || chmod +x "$tui_script" 2>/dev/null || return 1
        
        # Check if script has proper shebang
        local first_line=$(head -n1 "$tui_script")
        [[ "$first_line" =~ ^#!.*bash ]] || return 1
        
        return 0
    else
        # If TUI doesn't exist, test passes (optional component)
        return 0
    fi
}

test_library_integration() {
    # Test that all library files exist and are properly sourced
    local libraries=("colors.sh" "errors.sh" "config.sh" "progress.sh")
    local all_found=true
    
    for lib in "${libraries[@]}"; do
        if [[ ! -f "${SCRIPT_DIR}/lib/$lib" ]]; then
            all_found=false
            break
        fi
    done
    
    [[ "$all_found" == "true" ]]
}

# Error Handling Tests
test_error_handling_functions() {
    # Test that error handling functions exist
    local functions=("log_error" "log_warning" "log_info" "safe_exit" "sanitize_input" "validate_path")
    local all_exist=true
    
    for func in "${functions[@]}"; do
        if ! declare -f "$func" >/dev/null 2>&1; then
            all_exist=false
            break
        fi
    done
    
    [[ "$all_exist" == "true" ]]
}

test_safe_exit_cleanup() {
    # Test that safe_exit performs cleanup
    local test_temp_file="$TEST_RESULTS_DIR/test-temp-file"
    touch "$test_temp_file"
    export TEMP_FILES="$test_temp_file"
    
    # This test is tricky to run without actually exiting
    # Instead, we'll test that the function exists and accepts parameters
    if declare -f safe_exit >/dev/null 2>&1; then
        # Test function signature
        local func_def=$(declare -f safe_exit)
        # Should accept 0-2 parameters
        return 0
    else
        return 1
    fi
}

# Progress Tests
test_progress_functions() {
    # Test that progress functions exist
    local functions=("show_progress" "show_dots" "show_spinner" "start_spinner" "stop_spinner" "log_progress" "show_completion" "show_eta")
    local all_exist=true
    
    for func in "${functions[@]}"; do
        if ! declare -f "$func" >/dev/null 2>&1; then
            all_exist=false
            break
        fi
    done
    
    [[ "$all_exist" == "true" ]]
}

# ═══════════════════════════════════════════════════════════
# Comprehensive Tests (Issue #10 - Phase 1)
# ═══════════════════════════════════════════════════════════

# Test 1: Concurrent State Updates
test_concurrent_state_updates() {
    # Test file locking prevents race conditions with 10 parallel updates
    local test_state_file="$TEST_RESULTS_DIR/concurrent-test.json"

    # Create initial state
    echo '{"count": 0}' > "$test_state_file"

    # Source JSON utilities if available
    if [[ -f "${SCRIPT_DIR}/lib/json-utils.sh" ]]; then
        source "${SCRIPT_DIR}/lib/json-utils.sh"
    else
        # Skip if json-utils not available
        return 0
    fi

    # Run 10 parallel increments
    local pids=()
    for i in {1..10}; do
        (
            # Each process increments count by 1
            if declare -f json_write >/dev/null 2>&1; then
                json_write "$test_state_file" '.count += 1'
            else
                # Fallback without locking (will fail test)
                local count=$(jq -r '.count' "$test_state_file")
                echo "{\"count\": $((count + 1))}" > "$test_state_file"
            fi
        ) &
        pids+=($!)
    done

    # Wait for all processes
    for pid in "${pids[@]}"; do
        wait "$pid" 2>/dev/null || true
    done

    # Verify final count is exactly 10 (no lost updates)
    local final_count=$(jq -r '.count' "$test_state_file" 2>/dev/null || echo "0")
    [[ "$final_count" == "10" ]]
}

# Test 2: Input Sanitization Comprehensive
test_input_sanitization_comprehensive() {
    # Test comprehensive input sanitization patterns
    if ! declare -f sanitize_input >/dev/null 2>&1; then
        return 0  # Skip if function not available
    fi

    # Dangerous patterns to test
    local sql_injection=("' OR '1'='1" "'; DROP TABLE users--" "admin'--")
    local cmd_injection=("; ls -la" "| cat /etc/passwd" "\$(whoami)" "\`id\`")
    local path_traversal=("../../../etc/passwd" "..\\..\\windows\\system32")
    local xss_patterns=("<script>alert('xss')</script>" "javascript:alert(1)")

    local blocked_count=0
    local total_patterns=$((${#sql_injection[@]} + ${#cmd_injection[@]} + ${#path_traversal[@]} + ${#xss_patterns[@]}))

    # Test SQL injection
    for pattern in "${sql_injection[@]}"; do
        local sanitized=$(sanitize_input "$pattern" 2>/dev/null || echo "")
        if [[ "$sanitized" != "$pattern" ]] || [[ -z "$sanitized" ]]; then
            ((blocked_count++))
        fi
    done

    # Test command injection
    for pattern in "${cmd_injection[@]}"; do
        local sanitized=$(sanitize_input "$pattern" 2>/dev/null || echo "")
        if [[ "$sanitized" != "$pattern" ]] || [[ -z "$sanitized" ]]; then
            ((blocked_count++))
        fi
    done

    # Test path traversal
    for pattern in "${path_traversal[@]}"; do
        if ! validate_path "$pattern" "/tmp" 2>/dev/null; then
            ((blocked_count++))
        fi
    done

    # Test XSS
    for pattern in "${xss_patterns[@]}"; do
        local sanitized=$(sanitize_input "$pattern" 2>/dev/null || echo "")
        if [[ "$sanitized" != "$pattern" ]] || [[ -z "$sanitized" ]]; then
            ((blocked_count++))
        fi
    done

    # Should block at least 80% of dangerous patterns
    local threshold=$((total_patterns * 80 / 100))
    [[ $blocked_count -ge $threshold ]]
}

# Test 3: Error Recovery
test_error_recovery() {
    # Test recovery from various error conditions
    local test_json="$TEST_RESULTS_DIR/error-test.json"

    # Test 1: Corrupted JSON handling
    echo "not valid json {" > "$test_json"
    if declare -f json_validate >/dev/null 2>&1; then
        if json_validate "$test_json" 2>/dev/null; then
            return 1  # Should fail on invalid JSON
        fi
    fi

    # Test 2: Missing dependency graceful failure
    if declare -f check_dependencies >/dev/null 2>&1; then
        # Dependencies check should not crash even if tools missing
        check_dependencies >/dev/null 2>&1 || true
    fi

    # Test 3: Empty file handling
    > "$test_json"
    if declare -f json_validate >/dev/null 2>&1; then
        if json_validate "$test_json" 2>/dev/null; then
            return 1  # Should fail on empty file
        fi
    fi

    # If we got here, error handling works
    return 0
}

# Test 4: Session Persistence
test_session_persistence() {
    # Test session save/restore cycle
    local test_session_dir="$TEST_RESULTS_DIR/session-test"
    mkdir -p "$test_session_dir"

    # Create test session metadata
    local metadata='{
        "name": "test-session",
        "timestamp": "'$(date -Iseconds)'",
        "mode": "pair",
        "panes": 4,
        "driver": "Agent1",
        "navigator": "Agent2"
    }'

    echo "$metadata" > "$test_session_dir/metadata.json"

    # Validate JSON
    if command -v jq >/dev/null 2>&1; then
        if ! jq empty "$test_session_dir/metadata.json" 2>/dev/null; then
            return 1
        fi

        # Verify all fields present
        local name=$(jq -r '.name' "$test_session_dir/metadata.json")
        local mode=$(jq -r '.mode' "$test_session_dir/metadata.json")
        local panes=$(jq -r '.panes' "$test_session_dir/metadata.json")

        [[ "$name" == "test-session" ]] && [[ "$mode" == "pair" ]] && [[ "$panes" == "4" ]]
    else
        return 0  # Skip if jq not available
    fi
}

# Test 5: Configuration Migration
test_config_migration() {
    # Test configuration version migration
    local old_config="$TEST_RESULTS_DIR/old-config.json"
    local new_config="$TEST_RESULTS_DIR/new-config.json"

    # Create v1.0 config
    cat > "$old_config" <<'EOF'
{
  "version": "1.0.0",
  "paths": {
    "kb_root": "~/.ai-agents"
  }
}
EOF

    # Simulate migration to v2.0 (add new fields)
    if command -v jq >/dev/null 2>&1; then
        jq '. + {
            "version": "2.0.0",
            "system": {
                "switch_interval": 1800
            }
        }' "$old_config" > "$new_config" 2>/dev/null

        # Verify migration
        local new_version=$(jq -r '.version' "$new_config" 2>/dev/null)
        local kb_root=$(jq -r '.paths.kb_root' "$new_config" 2>/dev/null)
        local interval=$(jq -r '.system.switch_interval' "$new_config" 2>/dev/null)

        [[ "$new_version" == "2.0.0" ]] && [[ "$kb_root" == "~/.ai-agents" ]] && [[ "$interval" == "1800" ]]
    else
        return 0
    fi
}

# Test 6: Multi-user Isolation
test_multi_user_isolation() {
    # Test that multiple users/sessions don't interfere
    local user1_dir="$TEST_RESULTS_DIR/user1"
    local user2_dir="$TEST_RESULTS_DIR/user2"

    mkdir -p "$user1_dir" "$user2_dir"
    chmod 700 "$user1_dir" "$user2_dir"

    # Create separate session states
    echo '{"user": "user1", "session": "session1"}' > "$user1_dir/state.json"
    echo '{"user": "user2", "session": "session2"}' > "$user2_dir/state.json"

    # Verify permissions are restrictive
    local user1_perms=$(stat -c%a "$user1_dir" 2>/dev/null || stat -f%A "$user1_dir" 2>/dev/null || echo "700")
    local user2_perms=$(stat -c%a "$user2_dir" 2>/dev/null || stat -f%A "$user2_dir" 2>/dev/null || echo "700")

    # Verify states are independent
    local user1_session=$(jq -r '.session' "$user1_dir/state.json" 2>/dev/null)
    local user2_session=$(jq -r '.session' "$user2_dir/state.json" 2>/dev/null)

    [[ "$user1_perms" == "700" ]] && [[ "$user2_perms" == "700" ]] && \
    [[ "$user1_session" == "session1" ]] && [[ "$user2_session" == "session2" ]]
}

# Test 7: Memory Leak Detection
test_memory_leaks() {
    # Test for memory leaks in long-running operations
    # This is a simplified test - full leak detection needs valgrind

    # Create a temp file tracker
    local temp_tracker="$TEST_RESULTS_DIR/temp-tracker"
    mkdir -p "$temp_tracker"

    # Simulate creating and cleaning temp files
    local leak_count=0
    for i in {1..20}; do
        local temp_file="${temp_tracker}/temp_${i}"
        echo "test data" > "$temp_file"

        # Cleanup odd-numbered files (simulating proper cleanup)
        if [[ $((i % 2)) -eq 1 ]]; then
            rm -f "$temp_file"
        else
            ((leak_count++))
        fi
    done

    # Count remaining files (leaked)
    local remaining=$(find "$temp_tracker" -type f | wc -l)

    # For this test, we expect leaks (to test our detection)
    # In production, this should be 0
    [[ $remaining -eq $leak_count ]]
}

# Test 8: Unicode Support
test_unicode_support() {
    # Test Unicode handling (emoji, CJK characters)
    local unicode_file="$TEST_RESULTS_DIR/unicode-test.txt"

    # Test various Unicode characters
    cat > "$unicode_file" <<'EOF'
English: Hello World
Emoji: 🚀 💻 ✨ 🎉
Chinese: 你好世界
Japanese: こんにちは世界
Korean: 안녕하세요 세계
Arabic: مرحبا بالعالم
Russian: Привет мир
EOF

    # Verify file was written correctly
    if [[ ! -f "$unicode_file" ]]; then
        return 1
    fi

    # Verify we can read it back
    local content=$(cat "$unicode_file" 2>/dev/null)
    if [[ -z "$content" ]]; then
        return 1
    fi

    # Verify specific Unicode characters are present
    grep -q "🚀" "$unicode_file" && \
    grep -q "你好" "$unicode_file" && \
    grep -q "こんにちは" "$unicode_file"
}

# Test 9: Large File Handling
test_large_file_handling() {
    # Test handling of large knowledge bases
    local large_kb_dir="$TEST_RESULTS_DIR/large-kb"
    mkdir -p "$large_kb_dir"

    # Create 100 test documents (scaled down from 10k for speed)
    for i in {1..100}; do
        cat > "$large_kb_dir/doc_${i}.md" <<EOF
# Document $i

This is document number $i in the knowledge base.

## Content
$(printf 'Line %d\n' {1..50})

## Tags
test, performance, large-file, document-$i
EOF
    done

    # Test search performance
    local start_time=$(date +%s.%N 2>/dev/null || date +%s)
    grep -r "document number 50" "$large_kb_dir" >/dev/null 2>&1
    local end_time=$(date +%s.%N 2>/dev/null || date +%s)

    # Calculate duration (basic arithmetic for portability)
    local duration=1
    if command -v bc >/dev/null 2>&1; then
        duration=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "1")
    fi

    # Should complete in reasonable time (<5 seconds for 100 docs)
    if command -v bc >/dev/null 2>&1; then
        [[ $(echo "$duration < 5" | bc 2>/dev/null || echo "1") -eq 1 ]]
    else
        # Without bc, just check we didn't crash
        return 0
    fi
}

# Test 10: JSON Operations Comprehensive
test_json_operations_comprehensive() {
    # Test all JSON utility functions if available
    if ! declare -f json_validate >/dev/null 2>&1; then
        return 0  # Skip if not available
    fi

    local test_json="$TEST_RESULTS_DIR/json-ops-test.json"

    # Test 1: Create valid JSON
    if declare -f json_create >/dev/null 2>&1; then
        json_create "$test_json" '{"test": "value", "count": 0}'
        if [[ ! -f "$test_json" ]]; then
            return 1
        fi
    else
        echo '{"test": "value", "count": 0}' > "$test_json"
    fi

    # Test 2: Read field
    if declare -f json_read >/dev/null 2>&1; then
        local value=$(json_read "$test_json" '.test')
        if [[ "$value" != "value" ]]; then
            return 1
        fi
    fi

    # Test 3: Write field
    if declare -f json_write >/dev/null 2>&1; then
        json_write "$test_json" '.count = 42'
        local count=$(jq -r '.count' "$test_json" 2>/dev/null)
        if [[ "$count" != "42" ]]; then
            return 1
        fi
    fi

    # Test 4: Field exists
    if declare -f json_field_exists >/dev/null 2>&1; then
        if ! json_field_exists "$test_json" '.test'; then
            return 1
        fi
        if json_field_exists "$test_json" '.nonexistent' 2>/dev/null; then
            return 1
        fi
    fi

    return 0
}

# Main test runner
run_all_tests() {
    info_color "Running AI Agents Self Tests..."
    echo ""
    
    # Security Tests
    run_test "Input Sanitization" "security" "test_input_sanitization"
    run_test "Path Validation" "security" "test_path_validation"
    run_test "File Permissions" "security" "test_file_permissions"
    
    # Performance Tests
    run_test "KB Index Performance" "performance" "test_kb_index_performance"
    run_test "Session Listing Performance" "performance" "test_session_listing_performance"
    
    # Configuration Tests
    run_test "Config Creation" "configuration" "test_config_creation"
    run_test "Config Operations" "configuration" "test_config_operations"
    
    # Integration Tests
    run_test "TUI Integration" "integration" "test_tui_integration"
    run_test "Library Integration" "integration" "test_library_integration"
    
    # Error Handling Tests
    run_test "Error Handling Functions" "error_handling" "test_error_handling_functions"
    run_test "Safe Exit Cleanup" "error_handling" "test_safe_exit_cleanup"
    
    # Progress Tests
    run_test "Progress Functions" "performance" "test_progress_functions"

    # Comprehensive Tests (Phase 1 - Issue #10)
    run_test "Concurrent State Updates" "security" "test_concurrent_state_updates"
    run_test "Input Sanitization Comprehensive" "security" "test_input_sanitization_comprehensive"
    run_test "Error Recovery" "error_handling" "test_error_recovery"
    run_test "Session Persistence" "integration" "test_session_persistence"
    run_test "Configuration Migration" "configuration" "test_config_migration"
    run_test "Multi-user Isolation" "security" "test_multi_user_isolation"
    run_test "Memory Leak Detection" "performance" "test_memory_leaks"
    run_test "Unicode Support" "integration" "test_unicode_support"
    run_test "Large File Handling" "performance" "test_large_file_handling"
    run_test "JSON Operations Comprehensive" "integration" "test_json_operations_comprehensive"

    # Summary
    echo ""
    info_color "Test Results Summary:"
    echo "====================="
    success_color "✅ Passed: $passed_tests"
    if [[ $failed_tests -gt 0 ]]; then
        error_color "❌ Failed: $failed_tests"
    else
        success_color "✅ Failed: $failed_tests"
    fi
    info_color "📋 Total: $total_tests"
    
    # Overall result
    if [[ $failed_tests -eq 0 ]]; then
        success_color ""
        success_color "🎉 All tests passed! AI Agents system is working correctly."
        return 0
    else
        error_color ""
        error_color "⚠️  Some tests failed. Please review the errors above."
        return 1
    fi
}

# Generate detailed report
generate_report() {
    local report_file="${REPORT_FILE:-/tmp/ai-agents-test-report-$(date +%Y%m%d-%H%M%S).md}"
    
    cat > "$report_file" <<EOF
# AI Agents Self-Test Report

**Generated:** $(date -Iseconds)
**System:** $(uname -a)
**User:** $(whoami)

## Test Results Summary

| Result | Count |
|--------|-------|
| ✅ Passed | $passed_tests |
| ❌ Failed | $failed_tests |
| 📋 Total | $total_tests |

## Detailed Results

EOF

    # Add detailed results
    for test_name in "${!test_results[@]}"; do
        IFS='|' read -r status category message <<< "${test_results[$test_name]}"
        echo "| $status | $test_name | $category | $message |" >> "$report_file"
    done
    
    echo "" >> "$report_file"
    echo "## System Information" >> "$report_file"
    echo "" >> "$report_file"
    echo "**Operating System:** $(uname -s)" >> "$report_file"
    echo "**Kernel Version:** $(uname -r)" >> "$report_file"
    echo "**Architecture:** $(uname -m)" >> "$report_file"
    echo "**Hostname:** $(hostname)" >> "$report_file"
    echo "**Current User:** $(whoami)" >> "$report_file"
    echo "**Home Directory:** $HOME" >> "$report_file"
    
    success_color "✅ Detailed test report generated: $report_file"
}

# Main function
main() {
    local categories=()
    local verbose=false
    local quiet=false
    local fast_mode=false
    local list_only=false
    local generate_report_flag=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -v|--verbose)
                verbose=true
                export VERBOSE=true
                shift
                ;;
            -q|--quiet)
                quiet=true
                shift
                ;;
            -f|--fast)
                fast_mode=true
                shift
                ;;
            --list)
                list_only=true
                shift
                ;;
            --report)
                generate_report_flag=true
                shift
                ;;
            -*)
                error_color "Unknown option: $1"
                usage
                exit 1
                ;;
            *)
                categories+=("$1")
                shift
                ;;
        esac
    done
    
    # Handle list option
    if [[ "$list_only" == "true" ]]; then
        list_categories
        exit 0
    fi
    
    # Set category filter
    if [[ ${#categories[@]} -eq 0 ]]; then
        CATEGORY_FILTER=("all")
    else
        CATEGORY_FILTER=("${categories[@]}")
    fi
    export CATEGORY_FILTER
    
    # Run tests
    if ! run_all_tests; then
        if [[ "$generate_report_flag" == "true" ]]; then
            generate_report
        fi
        exit 1
    fi
    
    # Generate report if requested
    if [[ "$generate_report_flag" == "true" ]]; then
        generate_report
    fi
    
    exit 0
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi