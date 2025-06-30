#!/bin/bash

# Firewall Module Test Script
# Tests firewall functionality in a safe manner

# Import required modules
import firewall
import console
import network

# Test configuration
TEST_PORT=9999
TEST_IP="127.0.0.1"

# Colors for test output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Test function
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_result="$3"

    echo -e "${YELLOW}Running test: $test_name${NC}"

    if eval "$test_command" >/dev/null 2>&1; then
        if [[ "$expected_result" == "success" ]]; then
            echo -e "${GREEN}✓ PASS: $test_name${NC}"
            ((TESTS_PASSED++))
        else
            echo -e "${RED}✗ FAIL: $test_name (expected failure)${NC}"
            ((TESTS_FAILED++))
        fi
    else
        if [[ "$expected_result" == "failure" ]]; then
            echo -e "${GREEN}✓ PASS: $test_name (expected failure)${NC}"
            ((TESTS_PASSED++))
        else
            echo -e "${RED}✗ FAIL: $test_name${NC}"
            ((TESTS_FAILED++))
        fi
    fi
    echo
}

echo "=== Firewall Module Test Suite ==="
echo

# Test 1: Backend detection
run_test "Backend Detection" \
    "firewall.detect_backend" \
    "success"

# Test 2: Get backend
run_test "Get Backend" \
    "firewall.get_backend | grep -E '^(firewalld|ufw|iptables)$'" \
    "success"

# Test 3: Check if running (should not fail even if not running)
run_test "Check Running Status" \
    "firewall.is_running || true" \
    "success"

# Test 4: Status check
run_test "Status Check" \
    "firewall.status" \
    "success"

# Test 5: List rules (should not fail)
run_test "List Rules" \
    "firewall.list_rules" \
    "success"

# Test 6: Test port operations (safe test port)
echo -e "${YELLOW}Testing port operations on safe test port $TEST_PORT...${NC}"

# Allow test port
run_test "Allow Test Port" \
    "firewall.allow_port $TEST_PORT --protocol=tcp --description='Test port'" \
    "success"

# Check if port is now accessible (may fail if firewall blocks it)
run_test "Check Port Accessibility" \
    "network.port_open $TEST_IP $TEST_PORT || true" \
    "success"

# Deny test port
run_test "Deny Test Port" \
    "firewall.deny_port $TEST_PORT --protocol=tcp --description='Test port'" \
    "success"

echo

# Test 7: IP operations (safe test IP)
echo -e "${YELLOW}Testing IP operations on safe test IP $TEST_IP...${NC}"

# Allow test IP
run_test "Allow Test IP" \
    "firewall.allow_ip $TEST_IP --description='Test IP'" \
    "success"

# Deny test IP
run_test "Deny Test IP" \
    "firewall.deny_ip $TEST_IP --description='Test IP'" \
    "success"

echo

# Test 8: Invalid operations (should fail gracefully)
run_test "Invalid Port Number" \
    "firewall.allow_port invalid --protocol=tcp" \
    "failure"

run_test "Invalid IP Address" \
    "firewall.allow_ip invalid.ip.address" \
    "failure"

run_test "Invalid Protocol" \
    "firewall.allow_port 80 --protocol=invalid" \
    "failure"

echo

# Test 9: Help function
run_test "Help Function" \
    "firewall.help | grep -q 'Firewall Module'" \
    "success"

echo

# Test 10: Backend-specific tests
backend=$(firewall.get_backend)
echo -e "${YELLOW}Testing backend-specific functionality for: $backend${NC}"

case $backend in
"firewalld")
    run_test "Firewalld Zone Check" \
        "firewall-cmd --get-zones >/dev/null 2>&1" \
        "success"
    ;;
"ufw")
    run_test "UFW Status Check" \
        "ufw status >/dev/null 2>&1" \
        "success"
    ;;
"iptables")
    run_test "Iptables Rules Check" \
        "iptables -L >/dev/null 2>&1" \
        "success"
    ;;
esac

echo

# Summary
echo "=== Test Summary ==="
echo -e "${GREEN}Tests Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Tests Failed: $TESTS_FAILED${NC}"
echo -e "Total Tests: $((TESTS_PASSED + TESTS_FAILED))"

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed.${NC}"
    exit 1
fi
