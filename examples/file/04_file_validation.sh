#!/bin/bash

# Example: File Validation
# This demonstrates file format validation and comparison

# Import bash-lib
source core/init.sh
import file
import console

echo "=== File Validation ==="

# Create test directory and files
test_dir="test_file_validation"
mkdir -p "$test_dir"

# Create test files
file.create "$test_dir/compare1.txt" "Content for comparison"
file.create "$test_dir/compare2.txt" "Content for comparison"
file.create "$test_dir/compare3.txt" "Different content"

echo ""
echo "=== File Comparison ==="

# Compare files
console.info "Comparing identical files..."
if file.compare "$test_dir/compare1.txt" "$test_dir/compare2.txt"; then
    console.success "Files are identical"
else
    console.warn "Files are different"
fi

console.info "Comparing different files..."
if file.compare "$test_dir/compare1.txt" "$test_dir/compare3.txt"; then
    console.warn "Files are identical (unexpected)"
else
    console.success "Files are different (expected)"
fi

echo ""
echo "=== Cleanup ==="
rm -rf "$test_dir"
console.success "Test files cleaned up"

echo ""
echo "=== File Validation Example Complete ==="
