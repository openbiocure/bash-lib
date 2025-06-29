#!/bin/bash

# Example: Advanced File Features
# This demonstrates file locking, monitoring, and compression

# Import bash-lib
source core/init.sh
import file
import console

echo "=== Advanced File Features ==="

# Create test directory and files
test_dir="test_file_advanced"
mkdir -p "$test_dir"

# Create test file
file.create "$test_dir/sample.txt" "Content for advanced features testing"

echo ""
echo "=== File Locking ==="

# Lock file
console.info "Locking file..."
if file.lock "$test_dir/sample.txt"; then
    console.success "File locked successfully"
    
    # Try to lock again (should fail)
    if file.lock "$test_dir/sample.txt"; then
        console.warn "File locked again (unexpected)"
    else
        console.success "File already locked (expected)"
    fi
    
    # Unlock file
    file.unlock "$test_dir/sample.txt"
    console.success "File unlocked"
else
    console.error "Failed to lock file"
fi

echo ""
echo "=== File Compression ==="

# Compress file
console.info "Compressing file..."
if file.compress "$test_dir/sample.txt"; then
    console.success "File compressed: $test_dir/sample.txt.gz"
else
    console.error "Failed to compress file"
fi

# Decompress file
console.info "Decompressing file..."
if file.decompress "$test_dir/sample.txt.gz"; then
    console.success "File decompressed"
else
    console.error "Failed to decompress file"
fi

echo ""
echo "=== Cleanup ==="
rm -rf "$test_dir"
console.success "Test files cleaned up"

echo ""
echo "=== Advanced File Features Example Complete ==="
