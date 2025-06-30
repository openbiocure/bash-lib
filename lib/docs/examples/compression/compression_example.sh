#!/bin/bash

# Example: Compression Module
# This demonstrates the file compression and decompression functionality

# Import bash-lib
source core/init.sh
import compression
import console

echo "=== Compression Module Example ==="

# Create test directory and files
test_dir="test_compression"
mkdir -p "$test_dir"

# Create test files
echo "This is a test file for compression." > "$test_dir/file1.txt"
echo "Another test file with different content." > "$test_dir/file2.txt"
echo "Third file with more content for testing compression algorithms." > "$test_dir/file3.txt"

# Create a larger file for better compression testing
for i in {1..100}; do
    echo "Line $i: This is repeated content to test compression efficiency." >> "$test_dir/large_file.txt"
done

echo ""
echo "=== Basic Compression Operations ==="

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

echo ""
echo "=== Directory Compression ==="

# Compress entire directory
console.info "Compressing directory..."
if compression.compressDirectory "$test_dir"; then
    console.success "Directory compressed: $test_dir.tar.gz"
else
    console.error "Failed to compress directory"
fi

# Decompress directory
console.info "Decompressing directory..."
if compression.decompressDirectory "$test_dir.tar.gz"; then
    console.success "Directory decompressed"
else
    console.error "Failed to decompress directory"
fi

echo ""
echo "=== Different Compression Formats ==="

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
echo "=== Compression Information ==="

# Get compression information
console.info "Getting compression information..."

# Check if file is compressed
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

# Get compression type
compression_type=$(compression.getType "$test_dir/large_file.txt.gz")
console.info "Compression type: $compression_type"

# Get compression ratio
ratio=$(compression.getRatio "$test_dir/large_file.txt" "$test_dir/large_file.txt.gz")
console.info "Compression ratio: $ratio%"

# Get compressed file size
compressed_size=$(compression.getSize "$test_dir/large_file.txt.gz")
console.info "Compressed size: $compressed_size bytes"

# Get original file size
original_size=$(compression.getOriginalSize "$test_dir/large_file.txt")
console.info "Original size: $original_size bytes"

echo ""
echo "=== Compression Comparison ==="

# Compare different compression methods
console.info "Comparing compression methods..."

# Compress with different methods
compression.gzip "$test_dir/large_file.txt"
compression.bzip2 "$test_dir/large_file.txt"
compression.xz "$test_dir/large_file.txt"

# Get sizes for comparison
gzip_size=$(compression.getSize "$test_dir/large_file.txt.gz")
bzip2_size=$(compression.getSize "$test_dir/large_file.txt.bz2")
xz_size=$(compression.getSize "$test_dir/large_file.txt.xz")

console.info "Compression comparison:"
console.info "  Gzip size: $gzip_size bytes"
console.info "  Bzip2 size: $bzip2_size bytes"
console.info "  XZ size: $xz_size bytes"

# Calculate compression ratios
gzip_ratio=$(compression.getRatio "$test_dir/large_file.txt" "$test_dir/large_file.txt.gz")
bzip2_ratio=$(compression.getRatio "$test_dir/large_file.txt" "$test_dir/large_file.txt.bz2")
xz_ratio=$(compression.getRatio "$test_dir/large_file.txt" "$test_dir/large_file.txt.xz")

console.info "Compression ratios:"
console.info "  Gzip ratio: $gzip_ratio%"
console.info "  Bzip2 ratio: $bzip2_ratio%"
console.info "  XZ ratio: $xz_ratio%"

echo ""
echo "=== Advanced Compression Features ==="

# Compress with specific level
console.info "Compressing with specific level..."
if compression.compressWithLevel "$test_dir/file1.txt" 9; then
    console.success "File compressed with maximum level"
else
    console.error "Failed to compress with specific level"
fi

# Compress with password (for zip)
console.info "Compressing with password..."
if compression.compressWithPassword "$test_dir/file2.txt" "testpassword"; then
    console.success "File compressed with password"
else
    console.error "Failed to compress with password"
fi

# Create self-extracting archive
console.info "Creating self-extracting archive..."
if compression.createSelfExtracting "$test_dir/file3.txt"; then
    console.success "Self-extracting archive created"
else
    console.error "Failed to create self-extracting archive"
fi

echo ""
echo "=== Compression Validation ==="

# Validate compressed file integrity
console.info "Validating compressed file integrity..."
if compression.validate "$test_dir/large_file.txt.gz"; then
    console.success "Compressed file is valid"
else
    console.error "Compressed file is corrupted"
fi

# Test corrupted file (simulate corruption)
echo "corrupted" > "$test_dir/corrupted.gz"
if compression.validate "$test_dir/corrupted.gz"; then
    console.error "Corrupted file validated as good (unexpected)"
else
    console.success "Corrupted file properly detected"
fi

echo ""
echo "=== Compression Utilities ==="

# List compressed files
console.info "Listing compressed files..."
compressed_files=$(compression.list "$test_dir")
console.info "Compressed files: $compressed_files"

# Count compressed files
count=$(compression.count "$test_dir")
console.info "Number of compressed files: $count"

# Get compression statistics
console.info "Getting compression statistics..."
stats=$(compression.stats "$test_dir")
console.info "Compression statistics: $stats"

# Batch compression
console.info "Batch compression..."
txt_files=$(find "$test_dir" -name "*.txt" -type f)
if compression.batchCompress $txt_files; then
    console.success "Batch compression completed"
else
    console.error "Batch compression failed"
fi

echo ""
echo "=== Compression Cleanup ==="

# Clean up compressed files
console.info "Cleaning up compressed files..."
if compression.cleanup "$test_dir"; then
    console.success "Compressed files cleaned up"
else
    console.error "Failed to cleanup compressed files"
fi

# Final cleanup
console.info "Final cleanup..."
rm -rf "$test_dir"
console.success "Test directory cleaned up"

echo ""
echo "=== Compression Module Example Complete ===" 