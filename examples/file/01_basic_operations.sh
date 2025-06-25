#!/bin/bash

# Example: Basic File Operations
# This demonstrates file creation, reading, and writing

# Import bash-lib
source core/init.sh
import file
import console

echo "=== Basic File Operations ==="

# Create test directory and files
test_dir="test_basic_files"
mkdir -p "$test_dir"

echo ""
echo "=== File Creation ==="

# Create a simple text file
console.info "Creating a simple text file..."
file.create "$test_dir/sample.txt" "This is sample content for testing."
console.success "File created: $test_dir/sample.txt"

# Create a file with multiple lines
console.info "Creating a file with multiple lines..."
content="Line 1: Hello World
Line 2: This is a test file
Line 3: Created by bash-lib file module
Line 4: End of file"
file.create "$test_dir/multiline.txt" "$content"
console.success "Multi-line file created: $test_dir/multiline.txt"

echo ""
echo "=== File Reading ==="

# Read entire file
console.info "Reading entire file content..."
content=$(file.read "$test_dir/sample.txt")
console.info "File content: '$content'"

# Read file line by line
console.info "Reading file line by line..."
file.readLines "$test_dir/multiline.txt" | while read -r line; do
    console.info "Line: $line"
done

echo ""
echo "=== File Writing ==="

# Append to file
console.info "Appending to file..."
file.append "$test_dir/sample.txt" "This is appended content."
console.success "Content appended"

echo ""
echo "=== Cleanup ==="
rm -rf "$test_dir"
console.success "Test files cleaned up"

echo ""
echo "=== Basic File Operations Example Complete ==="
