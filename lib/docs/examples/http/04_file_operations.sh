#!/bin/bash

# Example: HTTP File Operations
# This demonstrates file uploads and downloads

# Import bash-lib
source core/init.sh
import http
import console

echo "=== HTTP File Operations ==="

# File upload (simulated)
echo ""
echo "=== File Upload Simulation ==="
# Create a temporary file for upload simulation
temp_file=$(mktemp)
echo "This is test file content for upload" > "$temp_file"
console.info "Created temporary file: $temp_file"

# Simulate file upload
response=$(http.post "https://httpbin.org/post" "@$temp_file" "text/plain")
console.info "File upload response:"
echo "$response" | head -10

# Clean up
rm -f "$temp_file"

# File upload with JSON metadata
echo ""
echo "=== File Upload with Metadata ==="
# Create another temporary file
temp_file2=$(mktemp)
echo "File content with metadata" > "$temp_file2"

# Create JSON metadata
metadata='{"filename": "test.txt", "description": "Test file upload", "version": "1.0"}'

# Upload file with metadata
response=$(http.post "https://httpbin.org/post" "@$temp_file2" "text/plain" "" "" "$metadata")
console.info "File upload with metadata response:"
echo "$response" | head -10

# Clean up
rm -f "$temp_file2"

# Download file simulation
echo ""
echo "=== File Download Simulation ==="
console.info "Downloading JSON data as file..."
response=$(http.get "https://httpbin.org/json")
if [[ $? -eq 0 ]]; then
    # Save response to file
    echo "$response" > "downloaded_data.json"
    console.success "Data downloaded and saved to downloaded_data.json"
    console.info "File size: $(wc -c < downloaded_data.json) bytes"
else
    console.error "Failed to download data"
fi

# Binary file upload simulation
echo ""
echo "=== Binary File Upload Simulation ==="
# Create a binary-like file
binary_file=$(mktemp)
dd if=/dev/urandom of="$binary_file" bs=1k count=1 2>/dev/null
console.info "Created binary file: $binary_file"

# Upload binary file
response=$(http.post "https://httpbin.org/post" "@$binary_file" "application/octet-stream")
console.info "Binary file upload response:"
echo "$response" | head -5

# Clean up
rm -f "$binary_file"

# Multiple file upload simulation
echo ""
echo "=== Multiple File Upload Simulation ==="
# Create multiple files
file1=$(mktemp)
file2=$(mktemp)
file3=$(mktemp)

echo "File 1 content" > "$file1"
echo "File 2 content" > "$file2"
echo "File 3 content" > "$file3"

console.info "Created multiple files for upload"

# Upload files one by one
for file in "$file1" "$file2" "$file3"; do
    filename=$(basename "$file")
    console.info "Uploading $filename..."
    response=$(http.post "https://httpbin.org/post" "@$file" "text/plain")
    if [[ $? -eq 0 ]]; then
        console.success "Uploaded $filename successfully"
    else
        console.error "Failed to upload $filename"
    fi
done

# Clean up
rm -f "$file1" "$file2" "$file3"

# File upload with progress simulation
echo ""
echo "=== File Upload with Progress ==="
# Create a larger file for progress demonstration
large_file=$(mktemp)
for i in {1..100}; do
    echo "Line $i: This is content for progress demonstration" >> "$large_file"
done

console.info "Created large file: $large_file"
console.info "File size: $(wc -c < "$large_file") bytes"

# Simulate upload with progress
console.info "Uploading large file..."
response=$(http.post "https://httpbin.org/post" "@$large_file" "text/plain")
if [[ $? -eq 0 ]]; then
    console.success "Large file uploaded successfully"
else
    console.error "Failed to upload large file"
fi

# Clean up
rm -f "$large_file"

# Clean up downloaded file
rm -f "downloaded_data.json"

echo ""
echo "=== HTTP File Operations Example Complete ===" 