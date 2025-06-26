#!/bin/bash

# Example: Basic Directory Operations
# This demonstrates directory creation, listing, and basic operations

# Import bash-lib
source core/init.sh
import directory
import console

echo "=== Basic Directory Operations ==="

# Create test directory structure
test_dir="test_basic_directory"
mkdir -p "$test_dir/subdir1"
mkdir -p "$test_dir/subdir2/nested"

# Create test files
echo "File in root" > "$test_dir/root_file.txt"
echo "File in subdir1" > "$test_dir/subdir1/sub1_file.txt"
echo "File in subdir2" > "$test_dir/subdir2/sub2_file.txt"
echo "Nested file" > "$test_dir/subdir2/nested/nested_file.txt"

echo ""
echo "=== Basic Directory Operations ==="

# List directory contents
console.info "Listing directory contents..."
directory.list "$test_dir"

# List with details
console.info "Listing directory contents with details..."
directory.list "$test_dir" --long

# Get directory information
console.info "Getting directory information..."
directory.info "$test_dir"

# Get directory size
console.info "Getting directory size..."
directory.size "$test_dir"

# Search for files
console.info "Searching for .txt files..."
directory.search "$test_dir" "*.txt"

echo ""
echo "=== Cleanup ==="
directory.remove "$test_dir" --recursive --force
console.success "Test directory cleaned up"

echo ""
echo "=== Basic Directory Operations Example Complete ==="
