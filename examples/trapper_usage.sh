#!/bin/bash

# Example: Comprehensive Trapper Module Usage Across All Modules
# This demonstrates how the enhanced trapper module provides generic
# signal handling and error trapping for all bash-lib modules

# Import bash-lib
source core/init.sh

# Set up default error handling for all modules
trapper.setupDefaults --verbose

# Example 1: HTTP Module with automatic cleanup
import http

# Add module-specific traps for HTTP
trapper.addModuleTrap "http" 'http.cleanup' EXIT
trapper.addModuleTrap "http" 'http.abort_requests' INT TERM

# Example 2: File Module with temporary file cleanup
import file

# Create temporary files with automatic cleanup
temp_file=$(trapper.tempFile)
temp_dir=$(trapper.tempDir)

# Add module-specific traps for file operations
trapper.addModuleTrap "file" 'file.cleanup_temp' EXIT
trapper.addModuleTrap "file" 'file.unlock_all' INT TERM

# Example 3: Directory Module with cleanup
import directory

# Add module-specific traps for directory operations
trapper.addModuleTrap "directory" 'directory.cleanup_temp' EXIT

# Example 4: Compression Module with cleanup
import compression

# Add module-specific traps for compression operations
trapper.addModuleTrap "compression" 'compression.cleanup_temp' EXIT

# Example 5: Process Module with signal handling
import process

# Add module-specific traps for process management
trapper.addModuleTrap "process" 'process.kill_all_children' EXIT
trapper.addModuleTrap "process" 'process.terminate_background' INT TERM

# Example 6: Users Module with cleanup
import users

# Add module-specific traps for user operations
trapper.addModuleTrap "users" 'users.cleanup_temp' EXIT

# Example 7: Math Module (usually doesn't need cleanup, but for demonstration)
import math

# Example 8: String Module (usually doesn't need cleanup, but for demonstration)
import string

# Example 9: Date Module (usually doesn't need cleanup, but for demonstration)
import date

# Example 10: Permissions Module with cleanup
import permissions

# Add module-specific traps for permission operations
trapper.addModuleTrap "permissions" 'permissions.restore_original' EXIT

# Example 11: System Console Module with cleanup
import console

# Add module-specific traps for console operations
trapper.addModuleTrap "console" 'console.restore_settings' EXIT

# Demonstrate the trap system in action
console.info "=== Trapper Module Demonstration ==="

# Show all registered traps
console.info "Current trap configuration:"
trapper.list

# Show traps for specific modules
console.info ""
console.info "HTTP module traps:"
trapper.list --module="http"

console.info ""
console.info "File module traps:"
trapper.list --module="file"

# Demonstrate temporary resource creation
console.info ""
console.info "Creating temporary resources with auto-cleanup:"
temp_file1=$(trapper.tempFile)
temp_file2=$(trapper.tempFile)
temp_dir1=$(trapper.tempDir)

console.info "Created temporary file: $temp_file1"
console.info "Created temporary file: $temp_file2"
console.info "Created temporary directory: $temp_dir1"

# Write some data to demonstrate cleanup
echo "test data" > "$temp_file1"
echo "more data" > "$temp_file2"
mkdir -p "$temp_dir1/subdir"

# Demonstrate error handling
console.info ""
console.info "Demonstrating error handling..."

# This will trigger the error handler
false

# Demonstrate interrupt handling (commented out to avoid stopping the script)
# console.info "Press Ctrl+C to test interrupt handling..."
# sleep 10

# Demonstrate module-specific cleanup functions
console.info ""
console.info "Demonstrating module cleanup functions..."

# Simulate HTTP cleanup
function http.cleanup() {
    console.info "HTTP module: Cleaning up connections and temporary files"
}

# Simulate file cleanup
function file.cleanup_temp() {
    console.info "File module: Cleaning up temporary files and locks"
}

# Simulate directory cleanup
function directory.cleanup_temp() {
    console.info "Directory module: Cleaning up temporary directories"
}

# Simulate compression cleanup
function compression.cleanup_temp() {
    console.info "Compression module: Cleaning up temporary archives"
}

# Simulate process cleanup
function process.kill_all_children() {
    console.info "Process module: Terminating all child processes"
}

function process.terminate_background() {
    console.info "Process module: Terminating background processes"
}

# Simulate users cleanup
function users.cleanup_temp() {
    console.info "Users module: Cleaning up temporary user data"
}

# Simulate permissions cleanup
function permissions.restore_original() {
    console.info "Permissions module: Restoring original permissions"
}

# Simulate console cleanup
function console.restore_settings() {
    console.info "Console module: Restoring original console settings"
}

# Test removing traps for a specific module
console.info ""
console.info "Testing trap removal for 'math' module..."
trapper.removeModuleTraps "math"

# Show updated trap configuration
console.info ""
console.info "Updated trap configuration after removing math module:"
trapper.list

# Demonstrate clearing all traps
console.info ""
console.info "Clearing all traps..."
trapper.clear

console.info ""
console.info "Final trap configuration:"
trapper.list

console.info ""
console.info "=== Trapper Module Demonstration Complete ==="
console.info "All temporary resources will be automatically cleaned up on exit" 