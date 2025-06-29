#!/bin/bash

# Example: Basic Permission Operations
# This demonstrates basic permission operations

# Import bash-lib
source core/init.sh
import permissions
import console

echo "=== Basic Permission Operations ==="

# Create test file
test_file="test_permissions.txt"
echo "Test content" > "$test_file"

echo ""
echo "=== Basic Permission Operations ==="

# Check file permissions
console.info "File permission operations:"
console.info "  File: $test_file"
console.info "  Readable: $(permissions.readable "$test_file")"
console.info "  Writable: $(permissions.writable "$test_file")"
console.info "  Executable: $(permissions.executable "$test_file")"

# Change permissions
console.info "Changing permissions..."
permissions.chmod "$test_file" 755
console.info "  New permissions: $(permissions.get "$test_file")"

# Check directory permissions
test_dir="test_permissions_dir"
mkdir -p "$test_dir"
console.info "Directory permission operations:"
console.info "  Directory: $test_dir"
console.info "  Readable: $(permissions.readable "$test_dir")"
console.info "  Writable: $(permissions.writable "$test_dir")"
console.info "  Executable: $(permissions.executable "$test_dir")"

echo ""
echo "=== Cleanup ==="
rm -f "$test_file"
rm -rf "$test_dir"
console.success "Test files cleaned up"

echo ""
echo "=== Basic Permission Operations Example Complete ==="
