#!/bin/bash

# Example: Compression Formats
# This demonstrates different compression algorithms and their characteristics

# Import bash-lib
source core/init.sh
import compression
import console

echo "=== Compression Formats ==="

# Create test directory and files
test_dir="test_compression_formats"
mkdir -p "$test_dir"

# Create a larger file for better compression testing
for i in {1..100}; do
    echo "Line $i: This is repeated content to test compression efficiency across different algorithms." >> "$test_dir/large_file.txt"
done

# Create a file with mixed content
echo "This file contains mixed content including text, numbers, and special characters." > "$test_dir/mixed_file.txt"
echo "1234567890" >> "$test_dir/mixed_file.txt"
echo "Special chars: !@#$%^&*()_+-=[]{}|;':\",./<>?" >> "$test_dir/mixed_file.txt"
echo "Unicode: éñüßçå" >> "$test_dir/mixed_file.txt"

echo ""
console.info "Created test files in $test_dir"

echo ""
echo "=== Testing Different Compression Formats ==="

# Test different compression formats
console.info "Testing different compression formats..."

# Gzip compression
console.info "Gzip compression..."
if compression.gzip "$test_dir/large_file.txt"; then
    console.success "Gzip compression completed"
else
    console.error "Gzip compression failed"
fi

# Bzip2 compression
console.info "Bzip2 compression..."
if compression.bzip2 "$test_dir/large_file.txt"; then
    console.success "Bzip2 compression completed"
else
    console.error "Bzip2 compression failed"
fi

# XZ compression
console.info "XZ compression..."
if compression.xz "$test_dir/large_file.txt"; then
    console.success "XZ compression completed"
else
    console.error "XZ compression failed"
fi

# Zip compression
console.info "Zip compression..."
if compression.zip "$test_dir/large_file.txt"; then
    console.success "Zip compression completed"
else
    console.error "Zip compression failed"
fi

echo ""
echo "=== Compression Comparison ==="

# Compare different compression methods
console.info "Comparing compression methods..."

# Get sizes for comparison
gzip_size=$(compression.getSize "$test_dir/large_file.txt.gz")
bzip2_size=$(compression.getSize "$test_dir/large_file.txt.bz2")
xz_size=$(compression.getSize "$test_dir/large_file.txt.xz")
zip_size=$(compression.getSize "$test_dir/large_file.zip")
original_size=$(compression.getOriginalSize "$test_dir/large_file.txt")

console.info "File size comparison:"
console.info "  Original size: $original_size bytes"
console.info "  Gzip size: $gzip_size bytes"
console.info "  Bzip2 size: $bzip2_size bytes"
console.info "  XZ size: $xz_size bytes"
console.info "  Zip size: $zip_size bytes"

# Calculate compression ratios
gzip_ratio=$(compression.getRatio "$test_dir/large_file.txt" "$test_dir/large_file.txt.gz")
bzip2_ratio=$(compression.getRatio "$test_dir/large_file.txt" "$test_dir/large_file.txt.bz2")
xz_ratio=$(compression.getRatio "$test_dir/large_file.txt" "$test_dir/large_file.txt.xz")
zip_ratio=$(compression.getRatio "$test_dir/large_file.txt" "$test_dir/large_file.zip")

console.info "Compression ratios:"
console.info "  Gzip ratio: $gzip_ratio%"
console.info "  Bzip2 ratio: $bzip2_ratio%"
console.info "  XZ ratio: $xz_ratio%"
console.info "  Zip ratio: $zip_ratio%"

echo ""
echo "=== Compression Type Detection ==="

# Test compression type detection
console.info "Testing compression type detection..."

# Check if files are compressed
if compression.isCompressed "$test_dir/large_file.txt.gz"; then
    console.success "File is compressed (gzip)"
else
    console.error "File is not compressed"
fi

if compression.isCompressed "$test_dir/large_file.txt.bz2"; then
    console.success "File is compressed (bzip2)"
else
    console.error "File is not compressed"
fi

if compression.isCompressed "$test_dir/large_file.txt.xz"; then
    console.success "File is compressed (xz)"
else
    console.error "File is not compressed"
fi

if compression.isCompressed "$test_dir/large_file.zip"; then
    console.success "File is compressed (zip)"
else
    console.error "File is not compressed"
fi

# Get compression types
gzip_type=$(compression.getType "$test_dir/large_file.txt.gz")
bzip2_type=$(compression.getType "$test_dir/large_file.txt.bz2")
xz_type=$(compression.getType "$test_dir/large_file.txt.xz")
zip_type=$(compression.getType "$test_dir/large_file.zip")

console.info "Compression types detected:"
console.info "  Gzip file: $gzip_type"
console.info "  Bzip2 file: $bzip2_type"
console.info "  XZ file: $xz_type"
console.info "  Zip file: $zip_type"

echo ""
echo "=== Format-Specific Features ==="

# Test format-specific features
console.info "Testing format-specific features..."

# Test zip with password
console.info "Creating password-protected zip..."
if compression.compressWithPassword "$test_dir/mixed_file.txt" "testpassword"; then
    console.success "Password-protected zip created"
else
    console.error "Failed to create password-protected zip"
fi

# Test different compression levels
console.info "Testing different compression levels with gzip..."
for level in 1 6 9; do
    if compression.compressWithLevel "$test_dir/mixed_file.txt" "$level"; then
        level_size=$(compression.getSize "$test_dir/mixed_file.txt.gz")
        level_ratio=$(compression.getRatio "$test_dir/mixed_file.txt" "$test_dir/mixed_file.txt.gz")
        console.info "  Level $level: $level_size bytes ($level_ratio%)"
    fi
done

echo ""
echo "=== Cleanup ==="
rm -rf "$test_dir"
console.success "Test directory cleaned up"

echo ""
echo "=== Compression Formats Example Complete ===" 