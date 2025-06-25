#!/bin/bash

# Example: File Operations
# This demonstrates file copying, moving, renaming, and backup operations

# Import bash-lib
source core/init.sh
import file
import console

echo "=== File Operations ==="

# Create test directory and files
test_dir="test_file_operations"
mkdir -p "$test_dir"

# Create test files
file.create "$test_dir/sample.txt" "Content for operations testing"

echo ""
echo "=== File Operations ==="

# Copy file
console.info "Copying file..."
file.copy "$test_dir/sample.txt" "$test_dir/sample_copy.txt"
console.success "File copied: $test_dir/sample_copy.txt"

# Move file
console.info "Moving file..."
file.move "$test_dir/sample_copy.txt" "$test_dir/sample_moved.txt"
console.success "File moved: $test_dir/sample_moved.txt"

# Rename file
console.info "Renaming file..."
file.rename "$test_dir/sample_moved.txt" "$test_dir/sample_renamed.txt"
console.success "File renamed: $test_dir/sample_renamed.txt"

# Create backup
console.info "Creating backup..."
file.backup "$test_dir/sample.txt"
console.success "Backup created"

echo ""
echo "=== Cleanup ==="
rm -rf "$test_dir"
console.success "Test files cleaned up"

echo ""
echo "=== File Operations Example Complete ==="
