#!/bin/bash

# Example: Comprehensive bash-lib Usage
# This demonstrates all modules working together in a real-world scenario

# Import bash-lib
source core/init.sh
import console
import trapper
import http
import file
import directory
import math
import string
import date
import compression
import users
import permissions
import process

echo "=== Comprehensive bash-lib Example ==="

# Set up error handling for all modules
trapper.setupDefaults --verbose

# Add module-specific traps
trapper.addModuleTrap "http" 'echo "HTTP cleanup completed"' EXIT
trapper.addModuleTrap "file" 'echo "File cleanup completed"' EXIT
trapper.addModuleTrap "compression" 'echo "Compression cleanup completed"' EXIT

echo ""
echo "=== System Information Gathering ==="

# Get system information using various modules
console.section "System Information"

current_user=$(users.current)
current_date=$(date.current)
system_info=$(process.getStats $(process.currentPid))

console.info "Current User: $current_user"
console.info "Current Date: $current_date"
console.info "System Info: $system_info"

echo ""
echo "=== File System Operations ==="

# Create a working directory
console.section "File System Operations"

work_dir="bash_lib_demo"
directory.create "$work_dir"
console.success "Created working directory: $work_dir"

# Create some test files
file.create "$work_dir/data.txt" "Sample data for demonstration"
file.create "$work_dir/config.json" '{"name": "demo", "version": "1.0.0", "enabled": true}'
file.create "$work_dir/log.txt" "Application log entries"

console.success "Created test files"

# Get directory information
dir_info=$(directory.info "$work_dir")
console.info "Directory information: $dir_info"

# List files with different methods
console.info "Files in directory:"
directory.list "$work_dir"

echo ""
echo "=== Data Processing ==="

# Read and process data
console.section "Data Processing"

# Read file content
content=$(file.read "$work_dir/data.txt")
console.info "File content: $content"

# Process string data
uppercase_content=$(string.toUpper "$content")
console.info "Uppercase content: $uppercase_content"

# Count characters
char_count=$(string.length "$content")
console.info "Character count: $char_count"

# Extract words
words=$(string.extractWords "$content")
console.info "Words: $words"

echo ""
echo "=== Mathematical Operations ==="

# Perform calculations
console.section "Mathematical Operations"

# Calculate file sizes
file_size=$(file.size "$work_dir/data.txt")
console.info "File size: $file_size bytes"

# Convert to KB
size_kb=$(math.divide "$file_size" 1024)
console.info "File size in KB: $size_kb"

# Calculate compression ratio (simulated)
original_size=1000
compressed_size=600
compression_ratio=$(math.multiply $(math.divide $(math.subtract "$original_size" "$compressed_size") "$original_size") 100)
console.info "Compression ratio: $compression_ratio%"

echo ""
echo "=== HTTP Operations ==="

# Make HTTP requests
console.section "HTTP Operations"

# Get current time from an API
console.info "Fetching current time from API..."
time_response=$(http.get "https://httpbin.org/json" 2>/dev/null || echo "API request failed")
console.info "API response received"

# Process JSON response
if [[ "$time_response" != "API request failed" ]]; then
    # Extract some data from JSON (simplified)
    console.success "Successfully retrieved data from API"
else
    console.warn "API request failed, continuing with local data"
fi

echo ""
echo "=== File Compression ==="

# Compress files
console.section "File Compression"

# Create a larger file for compression
for i in {1..50}; do
    echo "Line $i: This is repeated content for compression testing." >> "$work_dir/large_file.txt"
done

console.info "Created large file for compression"

# Compress the file
if compression.compress "$work_dir/large_file.txt"; then
    console.success "File compressed successfully"
    
    # Get compression information
    original_size=$(file.size "$work_dir/large_file.txt")
    compressed_size=$(file.size "$work_dir/large_file.txt.gz")
    ratio=$(math.multiply $(math.divide $(math.subtract "$original_size" "$compressed_size") "$original_size") 100)
    
    console.info "Original size: $original_size bytes"
    console.info "Compressed size: $compressed_size bytes"
    console.info "Compression ratio: $ratio%"
else
    console.error "Compression failed"
fi

echo ""
echo "=== Permission Management ==="

# Manage file permissions
console.section "Permission Management"

# Get current permissions
current_perms=$(permissions.get "$work_dir/data.txt")
console.info "Current permissions: $current_perms"

# Set secure permissions
if permissions.set "$work_dir/data.txt" 644; then
    console.success "Set secure permissions (644)"
else
    console.error "Failed to set permissions"
fi

# Check if file is readable
if permissions.canRead "$work_dir/data.txt"; then
    console.success "File is readable"
else
    console.error "File is not readable"
fi

echo ""
echo "=== Process Management ==="

# Manage processes
console.section "Process Management"

# Get current process information
current_pid=$(process.currentPid)
current_user=$(process.currentUser)
console.info "Current PID: $current_pid"
console.info "Current User: $current_user"

# Start a background process
background_pid=$(process.startBackground "sleep 10")
console.info "Started background process: $background_pid"

# Check if process is running
if process.isRunning "$background_pid"; then
    console.success "Background process is running"
else
    console.error "Background process is not running"
fi

# Get process information
process_info=$(process.info "$background_pid")
console.info "Process info: $process_info"

echo ""
echo "=== Data Analysis ==="

# Perform data analysis
console.section "Data Analysis"

# Create a data file with numbers
echo "10" > "$work_dir/numbers.txt"
echo "20" >> "$work_dir/numbers.txt"
echo "30" >> "$work_dir/numbers.txt"
echo "40" >> "$work_dir/numbers.txt"
echo "50" >> "$work_dir/numbers.txt"

# Read numbers and calculate statistics
numbers=$(file.readLines "$work_dir/numbers.txt")
sum=0
count=0

for num in $numbers; do
    sum=$(math.add "$sum" "$num")
    count=$(math.add "$count" 1)
done

average=$(math.divide "$sum" "$count")
console.info "Numbers: $numbers"
console.info "Sum: $sum"
console.info "Count: $count"
console.info "Average: $average"

echo ""
echo "=== String Processing ==="

# Process strings
console.section "String Processing"

# Create a complex string
complex_string="  Hello World Example  "
console.info "Original string: '$complex_string'"

# Apply various string operations
trimmed=$(string.trim "$complex_string")
console.info "Trimmed: '$trimmed'"

uppercase=$(string.toUpper "$trimmed")
console.info "Uppercase: '$uppercase'"

reversed=$(string.reverse "$trimmed")
console.info "Reversed: '$reversed'"

# Generate a random string
random_str=$(string.random 10)
console.info "Random string: '$random_str'"

echo ""
echo "=== Date and Time Operations ==="

# Work with dates
console.section "Date and Time Operations"

# Get current date in different formats
current_date=$(date.current)
iso_date=$(date.iso)
formatted_date=$(date.format "%Y-%m-%d %H:%M:%S")

console.info "Current date: $current_date"
console.info "ISO date: $iso_date"
console.info "Formatted date: $formatted_date"

# Calculate future date
future_date=$(date.addDays "$current_date" 7)
console.info "Date in 7 days: $future_date"

# Calculate date difference
diff_days=$(date.diffDays "$current_date" "$future_date")
console.info "Days difference: $diff_days"

echo ""
echo "=== Directory Operations ==="

# Work with directories
console.section "Directory Operations"

# Create nested directory structure
directory.createNested "$work_dir/subdir/level1/level2"
console.success "Created nested directory structure"

# Create files in subdirectories
file.create "$work_dir/subdir/file1.txt" "File in subdirectory"
file.create "$work_dir/subdir/level1/file2.txt" "File in level1"

# List directory tree
console.info "Directory structure:"
directory.tree "$work_dir"

# Get directory statistics
dir_stats=$(directory.stats "$work_dir")
console.info "Directory statistics: $dir_stats"

echo ""
echo "=== Error Handling and Validation ==="

# Demonstrate error handling
console.section "Error Handling and Validation"

# Test invalid operations
console.info "Testing error handling..."

# Try to read non-existent file
if file.read "nonexistent.txt" 2>/dev/null; then
    console.error "Unexpected: read non-existent file succeeded"
else
    console.success "Properly handled non-existent file"
fi

# Try invalid mathematical operation
if math.divide 10 0 2>/dev/null; then
    console.error "Unexpected: division by zero succeeded"
else
    console.success "Properly handled division by zero"
fi

# Validate string operations
if string.isNumeric "123"; then
    console.success "123 is numeric"
else
    console.error "123 is not numeric"
fi

if string.isNumeric "abc"; then
    console.error "abc is numeric (unexpected)"
else
    console.success "abc is not numeric"
fi

echo ""
echo "=== Performance Monitoring ==="

# Monitor performance
console.section "Performance Monitoring"

# Get process performance
performance=$(process.getPerformance "$current_pid")
console.info "Process performance: $performance"

# Get system resource usage
resource_usage=$(users.getResourceUsage "$current_user")
console.info "Resource usage: $resource_usage"

echo ""
echo "=== Data Export and Reporting ==="

# Create a comprehensive report
console.section "Data Export and Reporting"

# Generate report content
report_content="=== bash-lib Demo Report ===
Generated: $(date.current)
User: $(users.current)
Working Directory: $(pwd)/$work_dir

File Statistics:
- Total files: $(directory.countFiles "$work_dir")
- Total directories: $(directory.countDirectories "$work_dir")
- Total size: $(directory.size "$work_dir") bytes

Process Information:
- Current PID: $(process.currentPid)
- Process user: $(process.currentUser)
- Process state: $(process.getState $(process.currentPid))

System Information:
- Current date: $(date.current)
- User home: $(users.currentHome)
- User groups: $(users.currentGroups)

=== End Report ==="

# Save report
file.create "$work_dir/report.txt" "$report_content"
console.success "Generated comprehensive report"

# Compress the report
if compression.compress "$work_dir/report.txt"; then
    console.success "Report compressed"
else
    console.error "Failed to compress report"
fi

echo ""
echo "=== Cleanup Operations ==="

# Clean up resources
console.section "Cleanup Operations"

# Stop background process
if process.isRunning "$background_pid"; then
    process.stop "$background_pid"
    console.success "Stopped background process"
fi

# Remove working directory
if directory.exists "$work_dir"; then
    rm -rf "$work_dir"
    console.success "Cleaned up working directory"
else
    console.error "Working directory not found"
fi

echo ""
echo "=== Module Integration Summary ==="

# Show module integration
console.section "Module Integration Summary"

console.success "Successfully demonstrated integration of all modules:"
console.info "  ✓ Core initialization and import system"
console.info "  ✓ Console logging and output formatting"
console.info "  ✓ Signal handling and error trapping"
console.info "  ✓ HTTP requests and API communication"
console.info "  ✓ File operations and management"
console.info "  ✓ Directory operations and traversal"
console.info "  ✓ Mathematical calculations and statistics"
console.info "  ✓ String manipulation and processing"
console.info "  ✓ Date and time operations"
console.info "  ✓ File compression and decompression"
console.info "  ✓ User management and information"
console.info "  ✓ Permission management and validation"
console.info "  ✓ Process management and monitoring"

console.info ""
console.info "All modules work together seamlessly to provide"
console.info "a comprehensive bash scripting library for various tasks."

echo ""
echo "=== Comprehensive bash-lib Example Complete ===" 