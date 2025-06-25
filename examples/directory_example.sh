#!/bin/bash

# Example: Directory Module
# This demonstrates the directory operations functionality

# Import bash-lib
source core/init.sh
import directory
import console

echo "=== Directory Module Example ==="

# Create test directory structure
test_base="test_dirs"
mkdir -p "$test_base"

echo ""
echo "=== Directory Creation ==="

# Create a simple directory
console.info "Creating a simple directory..."
directory.create "$test_base/simple_dir"
console.success "Directory created: $test_base/simple_dir"

# Create nested directories
console.info "Creating nested directory structure..."
directory.createNested "$test_base/nested/level1/level2/level3"
console.success "Nested directories created"

# Create directory with specific permissions
console.info "Creating directory with specific permissions..."
directory.createWithPermissions "$test_base/perm_dir" 755
console.success "Directory created with permissions: $test_base/perm_dir"

echo ""
echo "=== Directory Information ==="

# Get directory info
console.info "Getting directory information..."
directory.info "$test_base"

# Check if directory exists
console.info "Checking directory existence..."
if directory.exists "$test_base"; then
    console.success "Directory exists: $test_base"
else
    console.error "Directory does not exist: $test_base"
fi

# Get directory size
console.info "Getting directory size..."
size=$(directory.size "$test_base")
console.info "Directory size: $size bytes"

# Get directory permissions
console.info "Getting directory permissions..."
perms=$(directory.permissions "$test_base")
console.info "Directory permissions: $perms"

# Get directory owner
console.info "Getting directory owner..."
owner=$(directory.owner "$test_base")
console.info "Directory owner: $owner"

# Get directory group
console.info "Getting directory group..."
group=$(directory.group "$test_base")
console.info "Directory group: $group"

echo ""
echo "=== Directory Operations ==="

# Copy directory
console.info "Copying directory..."
directory.copy "$test_base/simple_dir" "$test_base/simple_dir_copy"
console.success "Directory copied: $test_base/simple_dir_copy"

# Move directory
console.info "Moving directory..."
directory.move "$test_base/simple_dir_copy" "$test_base/simple_dir_moved"
console.success "Directory moved: $test_base/simple_dir_moved"

# Rename directory
console.info "Renaming directory..."
directory.rename "$test_base/simple_dir_moved" "$test_base/simple_dir_renamed"
console.success "Directory renamed: $test_base/simple_dir_renamed"

# Create backup
console.info "Creating directory backup..."
directory.backup "$test_base/simple_dir"
console.success "Directory backup created"

echo ""
echo "=== Directory Listing ==="

# Create some test files in directories
mkdir -p "$test_base/list_test"
echo "file1" > "$test_base/list_test/file1.txt"
echo "file2" > "$test_base/list_test/file2.txt"
mkdir -p "$test_base/list_test/subdir"
echo "file3" > "$test_base/list_test/subdir/file3.txt"

# List directory contents
console.info "Listing directory contents..."
directory.list "$test_base/list_test"

# List files only
console.info "Listing files only..."
directory.listFiles "$test_base/list_test"

# List directories only
console.info "Listing directories only..."
directory.listDirectories "$test_base/list_test"

# List with pattern
console.info "Listing with pattern (*.txt)..."
directory.listPattern "$test_base/list_test" "*.txt"

# List recursively
console.info "Listing recursively..."
directory.listRecursive "$test_base/list_test"

echo ""
echo "=== Directory Search ==="

# Search for files in directory
console.info "Searching for files containing 'file'..."
results=$(directory.search "$test_base/list_test" "file")
console.info "Search results: $results"

# Search with regex
console.info "Searching with regex (file[0-9]+)..."
results=$(directory.searchRegex "$test_base/list_test" "file[0-9]+")
console.info "Regex search results: $results"

# Find files by name
console.info "Finding files by name..."
results=$(directory.findByName "$test_base/list_test" "file1.txt")
console.info "Find by name results: $results"

# Find files by extension
console.info "Finding files by extension..."
results=$(directory.findByExtension "$test_base/list_test" "txt")
console.info "Find by extension results: $results"

echo ""
echo "=== Directory Permissions ==="

# Change directory permissions
console.info "Changing directory permissions..."
directory.changePermissions "$test_base/perm_dir" 750
console.success "Permissions changed"

# Change directory owner
console.info "Changing directory owner..."
# Note: This might require sudo, so we'll just demonstrate the function
console.info "Owner change function available: directory.changeOwner"

# Change directory group
console.info "Changing directory group..."
# Note: This might require sudo, so we'll just demonstrate the function
console.info "Group change function available: directory.changeGroup"

# Set recursive permissions
console.info "Setting recursive permissions..."
directory.setRecursivePermissions "$test_base/nested" 644
console.success "Recursive permissions set"

echo ""
echo "=== Directory Comparison ==="

# Create directories for comparison
mkdir -p "$test_base/compare1"
mkdir -p "$test_base/compare2"
echo "same content" > "$test_base/compare1/file.txt"
echo "same content" > "$test_base/compare2/file.txt"
echo "different" > "$test_base/compare1/unique.txt"

# Compare directories
console.info "Comparing directories..."
if directory.compare "$test_base/compare1" "$test_base/compare2"; then
    console.success "Directories are identical"
else
    console.warn "Directories are different"
fi

# Get directory differences
console.info "Getting directory differences..."
diff_output=$(directory.diff "$test_base/compare1" "$test_base/compare2")
console.info "Directory differences: $diff_output"

echo ""
echo "=== Directory Monitoring ==="

# Monitor directory for changes
console.info "Monitoring directory for changes..."
directory.monitor "$test_base/list_test" 5 &
monitor_pid=$!

# Make changes to the directory
sleep 2
echo "new file" > "$test_base/list_test/newfile.txt"
rm -f "$test_base/list_test/file1.txt"

# Stop monitoring
sleep 3
kill $monitor_pid 2>/dev/null || true

echo ""
echo "=== Directory Compression ==="

# Compress directory
console.info "Compressing directory..."
if directory.compress "$test_base/list_test"; then
    console.success "Directory compressed: $test_base/list_test.tar.gz"
else
    console.error "Failed to compress directory"
fi

# Decompress directory
console.info "Decompressing directory..."
if directory.decompress "$test_base/list_test.tar.gz"; then
    console.success "Directory decompressed"
else
    console.error "Failed to decompress directory"
fi

echo ""
echo "=== Directory Statistics ==="

# Get directory statistics
console.info "Getting directory statistics..."
directory.stats "$test_base"

# Count files and directories
console.info "Counting files and directories..."
file_count=$(directory.countFiles "$test_base")
dir_count=$(directory.countDirectories "$test_base")
console.info "File count: $file_count"
console.info "Directory count: $dir_count"

# Get directory tree
console.info "Getting directory tree..."
directory.tree "$test_base"

echo ""
echo "=== Directory Validation ==="

# Validate directory structure
console.info "Validating directory structure..."
if directory.validate "$test_base"; then
    console.success "Directory structure is valid"
else
    console.error "Directory structure is invalid"
fi

# Check directory permissions
console.info "Checking directory permissions..."
if directory.checkPermissions "$test_base" "r"; then
    console.success "Directory is readable"
else
    console.error "Directory is not readable"
fi

if directory.checkPermissions "$test_base" "w"; then
    console.success "Directory is writable"
else
    console.error "Directory is not writable"
fi

if directory.checkPermissions "$test_base" "x"; then
    console.success "Directory is executable"
else
    console.error "Directory is not executable"
fi

echo ""
echo "=== Directory Cleanup ==="

# Clean empty directories
console.info "Cleaning empty directories..."
directory.cleanEmpty "$test_base"
console.success "Empty directories cleaned"

# Clean old files
console.info "Cleaning old files (older than 1 day)..."
directory.cleanOld "$test_base" 1
console.success "Old files cleaned"

# Clean temporary files
console.info "Cleaning temporary files..."
directory.cleanTemp "$test_base"
console.success "Temporary files cleaned"

# Final cleanup
console.info "Final cleanup..."
rm -rf "$test_base"
console.success "Test directories cleaned up"

echo ""
echo "=== Directory Module Example Complete ===" 