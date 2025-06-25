#!/bin/bash

# Example: Basic Process Operations
# This demonstrates basic process operations

# Import bash-lib
source core/init.sh
import process
import console

echo "=== Basic Process Operations ==="

echo ""
echo "=== Basic Process Operations ==="

# Current process information
console.info "Current process information:"
console.info "  Process ID: $(process.id)"
console.info "  Parent Process ID: $(process.parentId)"
console.info "  Process name: $(process.name)"

# Process existence check
console.info "Process existence check:"
test_pid=1
if process.exists $test_pid; then
    console.success "Process $test_pid exists"
else
    console.error "Process $test_pid does not exist"
fi

# Process information
console.info "Process information for PID $test_pid:"
console.info "  Name: $(process.name $test_pid)"
console.info "  Status: $(process.status $test_pid)"
console.info "  CPU usage: $(process.cpu $test_pid)"
console.info "  Memory usage: $(process.memory $test_pid)"

echo ""
echo "=== Basic Process Operations Example Complete ==="
