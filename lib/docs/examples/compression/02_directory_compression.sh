#!/bin/bash

# Example: Directory Compression
# This demonstrates compressing and decompressing entire directories

# Import bash-lib
source core/init.sh
import compression
import console

echo "=== Directory Compression ==="

# Create test directory structure
test_dir="test_directory_compression"
mkdir -p "$test_dir/subdir1"
mkdir -p "$test_dir/subdir2/nested"

# Create test files in different directories
echo "File in root directory" > "$test_dir/root_file.txt"
echo "File in subdir1" > "$test_dir/subdir1/sub1_file.txt"
echo "File in subdir2" > "$test_dir/subdir2/sub2_file.txt"
echo "Nested file" > "$test_dir/subdir2/nested/nested_file.txt"

# Create a larger file for better compression testing
for i in {1..50}; do
    echo "Line $i: This is repeated content to test directory compression efficiency." >> "$test_dir/large_file.txt"
done

echo ""
console.info "Created test directory structure in $test_dir"

# Show directory structure
console.info "Directory structure:"
find "$test_dir" -type f | sort

echo ""
echo "=== Directory Compression ==="

# Compress entire directory
console.info "Compressing directory..."
if compression.compressDirectory "$test_dir"; then
    console.success "Directory compressed: $test_dir.tar.gz"
else
    console.error "Failed to compress directory"
fi

# Check if compressed file exists
if [ -f "$test_dir.tar.gz" ]; then
    compressed_size=$(du -h "$test_dir.tar.gz" | cut -f1)
    console.info "Compressed size: $compressed_size"
else
    console.error "Compressed file not found"
    exit 1
fi

echo ""
echo "=== Directory Decompression ==="

# Remove original directory to simulate extraction
rm -rf "$test_dir"

# Decompress directory
console.info "Decompressing directory..."
if compression.decompressDirectory "$test_dir.tar.gz"; then
    console.success "Directory decompressed"
else
    console.error "Failed to decompress directory"
fi

# Verify directory structure was restored
console.info "Verifying restored directory structure..."
if [ -d "$test_dir" ]; then
    console.success "Main directory restored"
    
    # Check subdirectories
    if [ -d "$test_dir/subdir1" ] && [ -d "$test_dir/subdir2" ] && [ -d "$test_dir/subdir2/nested" ]; then
        console.success "Subdirectories restored"
    else
        console.error "Subdirectories missing"
    fi
    
    # Check files
    files=("$test_dir/root_file.txt" "$test_dir/subdir1/sub1_file.txt" "$test_dir/subdir2/sub2_file.txt" "$test_dir/subdir2/nested/nested_file.txt" "$test_dir/large_file.txt")
    all_files_exist=true
    
    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            console.success "File restored: $(basename "$file")"
        else
            console.error "File missing: $(basename "$file")"
            all_files_exist=false
        fi
    done
    
    if [ "$all_files_exist" = true ]; then
        console.success "All files restored successfully"
    fi
else
    console.error "Main directory not restored"
fi

echo ""
echo "=== Directory Compression with Different Formats ==="

# Test directory compression with different formats
console.info "Testing directory compression with different formats..."

# Create a new test directory
test_dir2="test_dir_formats"
mkdir -p "$test_dir2"
echo "Test content" > "$test_dir2/test.txt"

# Compress with different methods
console.info "Compressing with gzip..."
if compression.compressDirectory "$test_dir2" "gzip"; then
    console.success "Directory compressed with gzip"
fi

console.info "Compressing with bzip2..."
if compression.compressDirectory "$test_dir2" "bzip2"; then
    console.success "Directory compressed with bzip2"
fi

console.info "Compressing with xz..."
if compression.compressDirectory "$test_dir2" "xz"; then
    console.success "Directory compressed with xz"
fi

# List compressed files
console.info "Compressed directory files:"
ls -la "$test_dir2".*

echo ""
echo "=== Cleanup ==="
rm -rf "$test_dir" "$test_dir2"
rm -f "$test_dir2".*
console.success "Test directories cleaned up"

echo ""
echo "=== Directory Compression Example Complete ===" 