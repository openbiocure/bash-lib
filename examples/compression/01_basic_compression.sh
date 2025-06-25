#!/bin/bash

# Example: Basic Compression Operations
# This demonstrates simple file compression and decompression

# Import bash-lib
source core/init.sh
import compression
import console

echo "=== Basic Compression Operations ==="

# Create test directory and files
test_dir="test_basic_compression"
mkdir -p "$test_dir"

# Create test files
echo "This is a test file for compression." > "$test_dir/file1.txt"
echo "Another test file with different content." > "$test_dir/file2.txt"
echo "Third file with more content for testing compression algorithms." > "$test_dir/file3.txt"

echo ""
console.info "Created test files in $test_dir"

# Compress single file
console.info "Compressing single file..."
if compression.compress "$test_dir/file1.txt"; then
    console.success "File compressed: $test_dir/file1.txt.gz"
else
    console.error "Failed to compress file"
fi

# Decompress file
console.info "Decompressing file..."
if compression.decompress "$test_dir/file1.txt.gz"; then
    console.success "File decompressed"
else
    console.error "Failed to decompress file"
fi

# Verify decompression
if [ -f "$test_dir/file1.txt" ]; then
    console.success "Original file restored successfully"
else
    console.error "Original file not found after decompression"
fi

echo ""
echo "=== Multiple File Compression ==="

# Compress multiple files
console.info "Compressing multiple files..."
files=("$test_dir/file1.txt" "$test_dir/file2.txt" "$test_dir/file3.txt")
if compression.compressMultiple "${files[@]}"; then
    console.success "Multiple files compressed"
else
    console.error "Failed to compress multiple files"
fi

# Decompress multiple files
console.info "Decompressing multiple files..."
compressed_files=("$test_dir/file1.txt.gz" "$test_dir/file2.txt.gz" "$test_dir/file3.txt.gz")
if compression.decompressMultiple "${compressed_files[@]}"; then
    console.success "Multiple files decompressed"
else
    console.error "Failed to decompress multiple files"
fi

# Verify all files
for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        console.success "File restored: $(basename "$file")"
    else
        console.error "File missing: $(basename "$file")"
    fi
done

echo ""
echo "=== Cleanup ==="
rm -rf "$test_dir"
console.success "Test directory cleaned up"

echo ""
echo "=== Basic Compression Example Complete ===" 