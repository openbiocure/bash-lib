#!/bin/bash

# Example: File Search and Pattern Matching
# This demonstrates file content search and pattern matching

# Import bash-lib
source core/init.sh
import file
import console

echo "=== File Search and Pattern Matching ==="

# Create test directory and files
test_dir="test_file_search"
mkdir -p "$test_dir"

# Create test files
content="Line 1: Hello World
Line 2: This is a test file
Line 3: Created by bash-lib file module
Line 4: End of file"
file.create "$test_dir/multiline.txt" "$content"

echo ""
echo "=== File Search and Pattern Matching ==="

# Search for content in file
console.info "Searching for content in file..."
if file.search "$test_dir/multiline.txt" "test"; then
    console.success "Found 'test' in file"
else
    console.warn "Did not find 'test' in file"
fi

# Search with regex
console.info "Searching with regex..."
if file.searchRegex "$test_dir/multiline.txt" "Line [0-9]+"; then
    console.success "Found lines matching pattern"
else
    console.warn "No lines match pattern"
fi

# Replace content
console.info "Replacing content..."
file.replace "$test_dir/multiline.txt" "test" "example"
console.success "Content replaced"

echo ""
echo "=== Cleanup ==="
rm -rf "$test_dir"
console.success "Test files cleaned up"

echo ""
echo "=== File Search Example Complete ==="
