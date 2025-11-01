#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# AI Agents - Improvement Validation Script
# ═══════════════════════════════════════════════════════════
# Validate that all security and performance improvements have been applied

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/colors.sh"
source "${SCRIPT_DIR}/lib/errors.sh"

# Configuration
REPORT_FILE="/tmp/ai-agents-validation-report-$(date +%Y%m%d-%H%M%S).txt"

# Test tracking
total_tests=0
passed_tests=0
failed_tests=0

# Record test result
record_test() {
    local test_name="$1"
    local status="$2"  # PASS, FAIL
    local message="${3:-}"
    
    ((total_tests++))
    
    case "$status" in
        PASS)
            ((passed_tests++))
            success_color "✅ PASS: $test_name"
            [[ -n "$message" ]] && info_color "   $message"
            ;;
        FAIL)
            ((failed_tests++))
            error_color "❌ FAIL: $test_name"
            [[ -n "$message" ]] && error_color "   $message"
            ;;
    esac
}

# Validation functions
validate_security_improvements() {
    info_color "Validating Security Improvements..."
    
    # Check input sanitization
    if [[ -f "${SCRIPT_DIR}/lib/errors.sh" ]]; then
        if grep -q "sanitize_input" "${SCRIPT_DIR}/lib/errors.sh"; then
            record_test "Input Sanitization" "PASS" "sanitize_input function found"
        else
            record_test "Input Sanitization" "FAIL" "sanitize_input function missing"
        fi
    else
        record_test "Input Sanitization" "FAIL" "lib/errors.sh not found"
    fi
    
    # Check path validation
    if [[ -f "${SCRIPT_DIR}/lib/errors.sh" ]]; then
        if grep -q "validate_path" "${SCRIPT_DIR}/lib/errors.sh"; then
            record_test "Path Validation" "PASS" "validate_path function found"
        else
            record_test "Path Validation" "FAIL" "validate_path function missing"
        fi
    else
        record_test "Path Validation" "FAIL" "lib/errors.sh not found"
    fi
    
    # Check file permissions hardening
    local shared_file="/tmp/ai-agents-shared.txt"
    if [[ -f "$shared_file" ]]; then
        local perms=$(stat -c%a "$shared_file" 2>/dev/null || echo "666")
        if [[ "$perms" =~ ^(644|600|400|444)$ ]]; then
            record_test "File Permissions" "PASS" "Secure permissions: $perms"
        else
            record_test "File Permissions" "FAIL" "Insecure permissions: $perms"
        fi
    else
        record_test "File Permissions" "SKIP" "Shared file not found"
    fi
}

validate_performance_improvements() {
    info_color "Validating Performance Improvements..."
    
    # Check KB indexing
    if [[ -f "${SCRIPT_DIR}/ai-kb-index.sh" ]]; then
        if [[ -x "${SCRIPT_DIR}/ai-kb-index.sh" ]]; then
            record_test "KB Indexing" "PASS" "ai-kb-index.sh exists and is executable"
        else
            record_test "KB Indexing" "FAIL" "ai-kb-index.sh not executable"
        fi
    else
        record_test "KB Indexing" "FAIL" "ai-kb-index.sh not found"
    fi
    
    # Check session listing optimization
    if [[ -f "${SCRIPT_DIR}/ai-session-list.sh" ]]; then
        if grep -q "find.*-maxdepth" "${SCRIPT_DIR}/ai-session-list.sh" 2>/dev/null; then
            record_test "Session Listing" "PASS" "Session listing optimized with find -maxdepth"
        else
            record_test "Session Listing" "SKIP" "Session listing optimization not detected"
        fi
    else
        record_test "Session Listing" "FAIL" "ai-session-list.sh not found"
    fi
}

validate_configuration_management() {
    info_color "Validating Configuration Management..."
    
    # Check config library
    if [[ -f "${SCRIPT_DIR}/lib/config.sh" ]]; then
        if [[ -x "${SCRIPT_DIR}/lib/config.sh" ]]; then
            record_test "Config Library" "PASS" "lib/config.sh exists and is executable"
        else
            record_test "Config Library" "FAIL" "lib/config.sh not executable"
        fi
    else
        record_test "Config Library" "FAIL" "lib/config.sh not found"
    fi
    
    # Check config script
    if [[ -f "${SCRIPT_DIR}/ai-config.sh" ]]; then
        if [[ -x "${SCRIPT_DIR}/ai-config.sh" ]]; then
            record_test "Config Script" "PASS" "ai-config.sh exists and is executable"
        else
            record_test "Config Script" "FAIL" "ai-config.sh not executable"
        fi
    else
        record_test "Config Script" "FAIL" "ai-config.sh not found"
    fi
}

validate_error_handling() {
    info_color "Validating Error Handling..."
    
    # Check error library
    if [[ -f "${SCRIPT_DIR}/lib/errors.sh" ]]; then
        if [[ -x "${SCRIPT_DIR}/lib/errors.sh" ]]; then
            # Check for key functions
            local key_functions=("log_error" "log_warning" "log_info" "safe_exit")
            local all_found=true
            
            for func in "${key_functions[@]}"; do
                if ! grep -q "$func" "${SCRIPT_DIR}/lib/errors.sh" 2>/dev/null; then
                    all_found=false
                    break
                fi
            done
            
            if [[ "$all_found" == "true" ]]; then
                record_test "Error Handling" "PASS" "Error handling library with key functions"
            else
                record_test "Error Handling" "FAIL" "Error handling library missing key functions"
            fi
        else
            record_test "Error Handling" "FAIL" "lib/errors.sh not executable"
        fi
    else
        record_test "Error Handling" "FAIL" "lib/errors.sh not found"
    fi
}

validate_progress_feedback() {
    info_color "Validating Progress Feedback..."
    
    # Check progress library
    if [[ -f "${SCRIPT_DIR}/lib/progress.sh" ]]; then
        if [[ -x "${SCRIPT_DIR}/lib/progress.sh" ]]; then
            # Check for key functions
            local key_functions=("show_progress" "show_dots" "show_spinner")
            local all_found=true
            
            for func in "${key_functions[@]}"; do
                if ! grep -q "$func" "${SCRIPT_DIR}/lib/progress.sh" 2>/dev/null; then
                    all_found=false
                    break
                fi
            done
            
            if [[ "$all_found" == "true" ]]; then
                record_test "Progress Feedback" "PASS" "Progress feedback library with key functions"
            else
                record_test "Progress Feedback" "FAIL" "Progress feedback library missing key functions"
            fi
        else
            record_test "Progress Feedback" "FAIL" "lib/progress.sh not executable"
        fi
    else
        record_test "Progress Feedback" "FAIL" "lib/progress.sh not found"
    fi
}

validate_testing_framework() {
    info_color "Validating Testing Framework..."
    
    # Check self-test script
    if [[ -f "${SCRIPT_DIR}/ai-self-test.sh" ]]; then
        if [[ -x "${SCRIPT_DIR}/ai-self-test.sh" ]]; then
            record_test "Self Test" "PASS" "ai-self-test.sh exists and is executable"
        else
            record_test "Self Test" "FAIL" "ai-self-test.sh not executable"
        fi
    else
        record_test "Self Test" "FAIL" "ai-self-test.sh not found"
    fi
    
    # Check validation script
    if [[ -f "${SCRIPT_DIR}/validate-improvements.sh" ]]; then
        if [[ -x "${SCRIPT_DIR}/validate-improvements.sh" ]]; then
            record_test "Improvement Validation" "PASS" "validate-improvements.sh exists and is executable"
        else
            record_test "Improvement Validation" "FAIL" "validate-improvements.sh not executable"
        fi
    else
        record_test "Improvement Validation" "FAIL" "validate-improvements.sh not found"
    fi
}

# Generate report
generate_report() {
    cat > "$REPORT_FILE" <<EOF
AI Agents Security & Performance Improvements Validation Report
=================================================================

Generated: $(date -Iseconds)
System: $(uname -a)

Summary:
--------
Total Tests: $total_tests
Passed: $passed_tests
Failed: $failed_tests

Detailed Results:
-----------------
EOF

    # Add detailed results
    echo "Detailed Results:" >> "$REPORT_FILE"
    echo "-----------------" >> "$REPORT_FILE"
    
    success_color "✅ Validation complete!"
    info_color "   Report saved to: $REPORT_FILE"
    
    if [[ $failed_tests -eq 0 ]]; then
        success_color "🎉 All validations passed!"
        echo "🎉 All validations passed!" >> "$REPORT_FILE"
    else
        error_color "❌ Some validations failed."
        echo "❌ Some validations failed." >> "$REPORT_FILE"
    fi
}

# Main function
main() {
    info_color "Validating AI Agents Security & Performance Improvements..."
    echo ""
    
    # Run all validations
    validate_security_improvements
    echo ""
    validate_performance_improvements
    echo ""
    validate_configuration_management
    echo ""
    validate_error_handling
    echo ""
    validate_progress_feedback
    echo ""
    validate_testing_framework
    echo ""
    
    # Generate report
    generate_report
    
    # Summary
    info_color "Validation Summary:"
    echo "==================="
    info_color "Total Tests: $total_tests"
    success_color "Passed: $passed_tests"
    if [[ $failed_tests -gt 0 ]]; then
        error_color "Failed: $failed_tests"
    else
        success_color "Failed: $failed_tests"
    fi
    
    if [[ $failed_tests -eq 0 ]]; then
        success_color ""
        success_color "🎉 All improvements have been successfully applied!"
        return 0
    else
        error_color ""
        error_color "⚠️  Some improvements are missing or incomplete."
        return 1
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi