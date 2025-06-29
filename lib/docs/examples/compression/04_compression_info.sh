#!/bin/bash

# Example: Compression Information
# This demonstrates how to get detailed information about compressed files

# Import bash-lib
source core/init.sh
import compression
import console

echo "=== Compression Information ==="

# Create test directory and files
test_dir="test_compression_info"
mkdir -p "$test_dir"

# Create files with different content types
echo "This is a text file with repeated content for compression testing." > "$test_dir/text_file.txt"
for i in {1..50}; do
    echo "Line $i: Repeated content for better compression ratio testing." >> "$test_dir/text_file.txt"
done

# Create a binary-like file (less compressible)
for i in {1..100}; do
    echo "Random data: $(openssl rand -hex 16)" >> "$test_dir/random_file.txt"
done

# Create a structured file
cat > "$test_dir/structured_file.txt" << EOF
Name: John Doe
Age: 30
City: New York
Occupation: Developer
Skills: Bash, Python, JavaScript
Projects: bash-lib, web-app, api-service
EOF

echo ""
console.info "Created test files in $test_dir"

echo ""
echo "=== Basic Compression Information ==="

# Compress files with different methods
console.info "Compressing files with different methods..."
compression.gzip "$test_dir/text_file.txt"
compression.bzip2 "$test_dir/text_file.txt"
compression.xz "$test_dir/text_file.txt"
compression.gzip "$test_dir/random_file.txt"
compression.gzip "$test_dir/structured_file.txt"

echo ""
echo "=== File Size Information ==="

# Get original file sizes
console.info "Original file sizes:"
for file in "$test_dir"/*.txt; do
    if [ -f "$file" ]; then
        size=$(compression.getOriginalSize "$file")
        console.info "  $(basename "$file"): $size bytes"
    fi
done

# Get compressed file sizes
console.info "Compressed file sizes:"
for file in "$test_dir"/*.gz "$test_dir"/*.bz2 "$test_dir"/*.xz; do
    if [ -f "$file" ]; then
        size=$(compression.getSize "$file")
        console.info "  $(basename "$file"): $size bytes"
    fi
done

echo ""
echo "=== Compression Ratio Analysis ==="

# Calculate compression ratios
console.info "Compression ratios:"
for original in "$test_dir"/*.txt; do
    if [ -f "$original" ]; then
        base_name=$(basename "$original" .txt)
        console.info "  $(basename "$original"):"
        
        # Check for different compression formats
        for ext in gz bz2 xz; do
            compressed="$test_dir/${base_name}.txt.$ext"
            if [ -f "$compressed" ]; then
                ratio=$(compression.getRatio "$original" "$compressed")
                size=$(compression.getSize "$compressed")
                console.info "    $ext: $ratio% ($size bytes)"
            fi
        done
    fi
done

echo ""
echo "=== Compression Type Detection ==="

# Test compression type detection
console.info "Compression type detection:"
for file in "$test_dir"/*.gz "$test_dir"/*.bz2 "$test_dir"/*.xz; do
    if [ -f "$file" ]; then
        if compression.isCompressed "$file"; then
            type=$(compression.getType "$file")
            console.success "  $(basename "$file"): $type"
        else
            console.error "  $(basename "$file"): Not detected as compressed"
        fi
    fi
done

echo ""
echo "=== Detailed File Analysis ==="

# Analyze each file in detail
console.info "Detailed file analysis:"
for original in "$test_dir"/*.txt; do
    if [ -f "$original" ]; then
        filename=$(basename "$original")
        original_size=$(compression.getOriginalSize "$original")
        
        console.info "  File: $filename"
        console.info "    Original size: $original_size bytes"
        
        # Check for compressed versions
        for ext in gz bz2 xz; do
            compressed="$test_dir/${filename}.$ext"
            if [ -f "$compressed" ]; then
                compressed_size=$(compression.getSize "$compressed")
                ratio=$(compression.getRatio "$original" "$compressed")
                savings=$((original_size - compressed_size))
                savings_percent=$((savings * 100 / original_size))
                
                console.info "    $ext: $compressed_size bytes ($ratio%, saved $savings bytes - $savings_percent%)"
            fi
        done
        echo ""
    fi
done

echo ""
echo "=== Compression Efficiency Analysis ==="

# Compare compression efficiency across different content types
console.info "Compression efficiency by content type:"

# Text file (highly compressible)
text_gz_size=$(compression.getSize "$test_dir/text_file.txt.gz")
text_ratio=$(compression.getRatio "$test_dir/text_file.txt" "$test_dir/text_file.txt.gz")
console.info "  Text file (repetitive): $text_ratio% compression"

# Random file (less compressible)
random_gz_size=$(compression.getSize "$test_dir/random_file.txt.gz")
random_ratio=$(compression.getRatio "$test_dir/random_file.txt" "$test_dir/random_file.txt.gz")
console.info "  Random data: $random_ratio% compression"

# Structured file (moderately compressible)
structured_gz_size=$(compression.getSize "$test_dir/structured_file.txt.gz")
structured_ratio=$(compression.getRatio "$test_dir/structured_file.txt" "$test_dir/structured_file.txt.gz")
console.info "  Structured data: $structured_ratio% compression"

echo ""
echo "=== Compression Statistics ==="

# Get overall statistics
console.info "Overall compression statistics:"
total_original=0
total_compressed=0
file_count=0

for original in "$test_dir"/*.txt; do
    if [ -f "$original" ]; then
        original_size=$(compression.getOriginalSize "$original")
        total_original=$((total_original + original_size))
        file_count=$((file_count + 1))
    fi
done

for compressed in "$test_dir"/*.gz "$test_dir"/*.bz2 "$test_dir"/*.xz; do
    if [ -f "$compressed" ]; then
        compressed_size=$(compression.getSize "$compressed")
        total_compressed=$((total_compressed + compressed_size))
    fi
done

if [ $total_original -gt 0 ]; then
    overall_ratio=$((total_compressed * 100 / total_original))
    total_savings=$((total_original - total_compressed))
    console.info "  Total files: $file_count"
    console.info "  Total original size: $total_original bytes"
    console.info "  Total compressed size: $total_compressed bytes"
    console.info "  Overall compression ratio: $overall_ratio%"
    console.info "  Total space saved: $total_savings bytes"
fi

echo ""
echo "=== Cleanup ==="
rm -rf "$test_dir"
console.success "Test directory cleaned up"

echo ""
echo "=== Compression Information Example Complete ===" 