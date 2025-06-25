#!/bin/bash

# Example: File Module
# This demonstrates the file operations functionality

# Import bash-lib
source core/init.sh
import file
import console

echo "=== File Module Example ==="

# Create test directory and files
test_dir="test_files"
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

# Create a JSON file
console.info "Creating a JSON file..."
json_content='{
  "name": "John Doe",
  "age": 30,
  "email": "john@example.com",
  "skills": ["bash", "shell", "scripting"]
}'
file.create "$test_dir/data.json" "$json_content"
console.success "JSON file created: $test_dir/data.json"

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

# Read specific line
console.info "Reading specific line (line 2)..."
line2=$(file.readLine "$test_dir/multiline.txt" 2)
console.info "Line 2: '$line2'"

# Read last line
console.info "Reading last line..."
last_line=$(file.readLastLine "$test_dir/multiline.txt")
console.info "Last line: '$last_line'"

echo ""
echo "=== File Writing ==="

# Append to file
console.info "Appending to file..."
file.append "$test_dir/sample.txt" "This is appended content."
console.success "Content appended"

# Write to specific line
console.info "Writing to specific line..."
file.writeLine "$test_dir/multiline.txt" 2 "Line 2: Modified content"
console.success "Line 2 modified"

# Insert line
console.info "Inserting new line..."
file.insertLine "$test_dir/multiline.txt" 3 "Line 3: Inserted content"
console.success "Line inserted"

echo ""
echo "=== File Information ==="

# Get file info
console.info "Getting file information..."
file.info "$test_dir/sample.txt"

# Check if file exists
console.info "Checking file existence..."
if file.exists "$test_dir/sample.txt"; then
    console.success "File exists: $test_dir/sample.txt"
else
    console.error "File does not exist: $test_dir/sample.txt"
fi

# Get file size
console.info "Getting file size..."
size=$(file.size "$test_dir/sample.txt")
console.info "File size: $size bytes"

# Get file type
console.info "Getting file type..."
type=$(file.type "$test_dir/sample.txt")
console.info "File type: $type"

# Get file permissions
console.info "Getting file permissions..."
perms=$(file.permissions "$test_dir/sample.txt")
console.info "File permissions: $perms"

echo ""
echo "=== File Operations ==="

# Copy file
console.info "Copying file..."
file.copy "$test_dir/sample.txt" "$test_dir/sample_copy.txt"
console.success "File copied: $test_dir/sample_copy.txt"

# Move file
console.info "Moving file..."
file.move "$test_dir/sample_copy.txt" "$test_dir/sample_moved.txt"
console.success "File moved: $test_dir/sample_moved.txt"

# Rename file
console.info "Renaming file..."
file.rename "$test_dir/sample_moved.txt" "$test_dir/sample_renamed.txt"
console.success "File renamed: $test_dir/sample_renamed.txt"

# Create backup
console.info "Creating backup..."
file.backup "$test_dir/sample.txt"
console.success "Backup created"

echo ""
echo "=== File Search and Pattern Matching ==="

# Search for content in file
console.info "Searching for content in file..."
if file.search "$test_dir/multiline.txt" "test"; then
    console.success "Found 'test' in file"
else
    console.warn "Did not find 'test' in file"
fi

# Search with regex
console.info "Searching with regex..."
if file.searchRegex "$test_dir/multiline.txt" "Line [0-9]+"; then
    console.success "Found lines matching pattern"
else
    console.warn "No lines match pattern"
fi

# Replace content
console.info "Replacing content..."
file.replace "$test_dir/sample.txt" "sample" "example"
console.success "Content replaced"

# Replace with regex
console.info "Replacing with regex..."
file.replaceRegex "$test_dir/multiline.txt" "Line ([0-9]+):" "Entry \1:"
console.success "Regex replacement completed"

echo ""
echo "=== File Comparison ==="

# Create another file for comparison
file.create "$test_dir/compare1.txt" "Content for comparison"
file.create "$test_dir/compare2.txt" "Content for comparison"
file.create "$test_dir/compare3.txt" "Different content"

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
echo "=== File Validation ==="

# Validate file format
console.info "Validating JSON file..."
if file.validateJson "$test_dir/data.json"; then
    console.success "JSON file is valid"
else
    console.error "JSON file is invalid"
fi

# Create invalid JSON for testing
file.create "$test_dir/invalid.json" '{"name": "John", "age": 30,}'
console.info "Validating invalid JSON file..."
if file.validateJson "$test_dir/invalid.json"; then
    console.warn "Invalid JSON was accepted (unexpected)"
else
    console.success "Invalid JSON was rejected (expected)"
fi

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
echo "=== File Monitoring ==="

# Monitor file changes
console.info "Monitoring file for changes..."
file.monitor "$test_dir/sample.txt" 5 &
monitor_pid=$!

# Make a change to the file
sleep 2
file.append "$test_dir/sample.txt" "Change detected by monitor"

# Stop monitoring
sleep 3
kill $monitor_pid 2>/dev/null || true

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
echo "=== File Cleanup ==="

# List all test files
console.info "Listing all test files..."
file.list "$test_dir"

# Count files
console.info "Counting files..."
count=$(file.count "$test_dir")
console.info "Number of files: $count"

# Clean up test directory
console.info "Cleaning up test files..."
rm -rf "$test_dir"
console.success "Test files cleaned up"

echo ""
echo "=== File Module Example Complete ===" 