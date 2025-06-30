#!/bin/bash

# Example: Advanced Compression Features
# This demonstrates advanced compression capabilities

# Import bash-lib
source core/init.sh
import compression
import console

echo "=== Advanced Compression Features ==="

# Create test directory and files
test_dir="test_advanced_compression"
mkdir -p "$test_dir"

# Create test files
echo "This is a test file for advanced compression features." > "$test_dir/file1.txt"
echo "Another test file with sensitive content." > "$test_dir/file2.txt"
echo "Third file for testing compression levels." > "$test_dir/file3.txt"

# Create a larger file for testing
for i in {1..100}; do
    echo "Line $i: Content for testing advanced compression features." >> "$test_dir/large_file.txt"
done

echo ""
console.info "Created test files in $test_dir"

echo ""
echo "=== Compression with Specific Levels ==="

# Test compression with different levels
console.info "Testing compression with different levels..."

for level in 1 3 6 9; do
    console.info "Compressing with level $level..."
    if compression.compressWithLevel "$test_dir/file1.txt" "$level"; then
        size=$(compression.getSize "$test_dir/file1.txt.gz")
        ratio=$(compression.getRatio "$test_dir/file1.txt" "$test_dir/file1.txt.gz")
        console.success "  Level $level: $size bytes ($ratio%)"
    else
        console.error "  Level $level: Failed"
    fi
done

echo ""
echo "=== Password-Protected Compression ==="

# Test password-protected compression
console.info "Testing password-protected compression..."

# Create password-protected zip
if compression.compressWithPassword "$test_dir/file2.txt" "testpassword123"; then
    console.success "Password-protected zip created"
    
    # Check if file exists
    if [ -f "$test_dir/file2.txt.zip" ]; then
        size=$(compression.getSize "$test_dir/file2.txt.zip")
        console.info "  Password-protected file size: $size bytes"
    fi
else
    console.error "Failed to create password-protected zip"
fi

# Test with different password
console.info "Creating another password-protected file..."
if compression.compressWithPassword "$test_dir/file3.txt" "anotherpassword"; then
    console.success "Second password-protected zip created"
else
    console.error "Failed to create second password-protected zip"
fi

echo ""
echo "=== Self-Extracting Archives ==="

# Test self-extracting archive creation
console.info "Testing self-extracting archive creation..."

if compression.createSelfExtracting "$test_dir/file1.txt"; then
    console.success "Self-extracting archive created"
    
    # Check if self-extracting file exists
    if [ -f "$test_dir/file1.txt.sh" ]; then
        size=$(du -h "$test_dir/file1.txt.sh" | cut -f1)
        console.info "  Self-extracting file size: $size"
        
        # Make it executable
        chmod +x "$test_dir/file1.txt.sh"
        console.info "  Made self-extracting file executable"
    fi
else
    console.error "Failed to create self-extracting archive"
fi

echo ""
echo "=== Compression Validation ==="

# Test compression validation
console.info "Testing compression validation..."

# Validate good compressed files
for file in "$test_dir"/*.gz "$test_dir"/*.bz2 "$test_dir"/*.xz "$test_dir"/*.zip; do
    if [ -f "$file" ]; then
        if compression.validate "$file"; then
            console.success "  Valid: $(basename "$file")"
        else
            console.error "  Invalid: $(basename "$file")"
        fi
    fi
done

# Test corrupted file detection
console.info "Testing corrupted file detection..."
echo "This is not a valid compressed file" > "$test_dir/corrupted.gz"

if compression.validate "$test_dir/corrupted.gz"; then
    console.error "  Corrupted file validated as good (unexpected)"
else
    console.success "  Corrupted file properly detected"
fi

echo ""
echo "=== Batch Compression Operations ==="

# Test batch compression
console.info "Testing batch compression..."

# Get all text files
txt_files=$(find "$test_dir" -name "*.txt" -type f)
console.info "Found text files: $txt_files"

if compression.batchCompress $txt_files; then
    console.success "Batch compression completed"
    
    # Count compressed files
    compressed_count=$(find "$test_dir" -name "*.gz" -o -name "*.bz2" -o -name "*.xz" -o -name "*.zip" | wc -l)
    console.info "  Total compressed files created: $compressed_count"
else
    console.error "Batch compression failed"
fi

echo ""
echo "=== Compression Utilities ==="

# Test compression utilities
console.info "Testing compression utilities..."

# List compressed files
console.info "Listing compressed files..."
compressed_files=$(compression.list "$test_dir")
console.info "  Compressed files: $compressed_files"

# Count compressed files
count=$(compression.count "$test_dir")
console.info "  Number of compressed files: $count"

# Get compression statistics
console.info "Getting compression statistics..."
stats=$(compression.stats "$test_dir")
console.info "  Compression statistics: $stats"

echo ""
echo "=== Compression Performance Testing ==="

# Test compression performance
console.info "Testing compression performance..."

# Create a larger file for performance testing
for i in {1..1000}; do
    echo "Performance test line $i: This is repeated content for testing compression speed and efficiency." >> "$test_dir/performance_test.txt"
done

console.info "Created performance test file"

# Test compression speed
console.info "Testing compression speed..."
start_time=$(date +%s)
compression.gzip "$test_dir/performance_test.txt"
end_time=$(date +%s)
gzip_time=$((end_time - start_time))

start_time=$(date +%s)
compression.bzip2 "$test_dir/performance_test.txt"
end_time=$(date +%s)
bzip2_time=$((end_time - start_time))

start_time=$(date +%s)
compression.xz "$test_dir/performance_test.txt"
end_time=$(date +%s)
xz_time=$((end_time - start_time))

console.info "Compression time comparison:"
console.info "  Gzip: ${gzip_time}s"
console.info "  Bzip2: ${bzip2_time}s"
console.info "  XZ: ${xz_time}s"

# Get final sizes
gzip_size=$(compression.getSize "$test_dir/performance_test.txt.gz")
bzip2_size=$(compression.getSize "$test_dir/performance_test.txt.bz2")
xz_size=$(compression.getSize "$test_dir/performance_test.txt.xz")

console.info "Final size comparison:"
console.info "  Gzip: $gzip_size bytes"
console.info "  Bzip2: $bzip2_size bytes"
console.info "  XZ: $xz_size bytes"

echo ""
echo "=== Cleanup ==="
rm -rf "$test_dir"
console.success "Test directory cleaned up"

echo ""
echo "=== Advanced Compression Features Example Complete ===" 