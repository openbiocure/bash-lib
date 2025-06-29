#!/bin/bash

# Example: Process Module - Basic Process Operations
# This demonstrates the process.run functionality

# Import bash-lib
source core/init.sh
import process
import console

echo "=== Process Module - Basic Process Operations ==="

echo ""
echo "=== Testing process.run with timeout ==="
console.info "Running apt-get update with 5 second timeout (will likely timeout on non-Debian systems)..."
if process.run "apt-get update" --timeout=5; then
    console.success "apt-get update completed successfully"
else
    console.warn "apt-get update failed or timed out (expected on non-Debian systems)"
fi

echo ""
echo "=== Testing process.run with capture-output ==="
console.info "Running docker build with output capture..."
output=$(process.run "docker build ." --capture-output)
if [[ $? -eq 0 ]]; then
    console.success "Docker build completed successfully"
    console.info "Output length: ${#output} characters"
    if [[ ${#output} -gt 100 ]]; then
        console.info "First 100 characters: ${output:0:100}..."
    else
        console.info "Output: $output"
    fi
else
    console.warn "Docker build failed (expected if no Dockerfile present)"
    console.info "Error output: $output"
fi

echo ""
echo "=== Testing process.run with retries ==="
console.info "Running curl with 3 retries..."
if process.run "curl -s --connect-timeout 5 example.com" --retries=3 --verbose; then
    console.success "Curl completed successfully"
else
    console.warn "Curl failed after all retries"
fi

echo ""
echo "=== Testing process.run with dry-run ==="
console.info "Testing dry-run mode..."
process.run "rm -rf /tmp/*" --dry-run
process.run "ls -la /tmp" --dry-run --capture-output
process.run "echo 'test command'" --dry-run --timeout=10 --retries=3

echo ""
echo "=== Testing process.run with silent mode ==="
console.info "Running ls silently..."
if process.run "ls -la" --silent; then
    console.success "ls completed silently"
else
    console.error "ls failed"
fi

echo ""
echo "=== Testing process.run with verbose mode ==="
console.info "Running echo with verbose output..."
process.run "echo 'Hello, World!'" --verbose

echo ""
echo "=== Testing process.run with combined options ==="
console.info "Running a command with multiple options..."
if process.run "echo 'Combined test'" --capture-output --verbose --retries=2; then
    console.success "Combined test completed"
else
    console.error "Combined test failed"
fi

echo ""
echo "=== Testing process.run error handling ==="
console.info "Testing with invalid command..."
if process.run "nonexistent_command" --retries=2 --verbose; then
    console.error "Unexpected success with invalid command"
else
    console.success "Properly handled invalid command"
fi

console.info "Testing with invalid options..."
if process.run "echo test" --invalid-option; then
    console.error "Unexpected success with invalid option"
else
    console.success "Properly handled invalid option"
fi

echo ""
echo "=== Testing process.run with timeout and retries ==="
console.info "Running a command that will timeout with retries..."
if process.run "sleep 10" --timeout=2 --retries=3 --verbose; then
    console.success "Unexpected success with timeout"
else
    console.success "Properly handled timeout with retries"
fi

echo ""
console.success "All process.run tests completed!"
