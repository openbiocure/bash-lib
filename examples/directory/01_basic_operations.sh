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

# Count files and directories
console.info "Counting items in directory..."
file_count=$(directory.countFiles "$test_dir")
dir_count=$(directory.countDirectories "$test_dir")
console.info "Files: $file_count, Directories: $dir_count"

# Check if directory exists
console.info "Checking directory existence..."
if directory.exists "$test_dir"; then
    console.success "Directory exists: $test_dir"
else
    console.error "Directory does not exist: $test_dir"
fi

echo ""
echo "=== Cleanup ==="
rm -rf "$test_dir"
console.success "Test directory cleaned up"

echo ""
echo "=== Basic Directory Operations Example Complete ==="
