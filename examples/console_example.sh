#!/bin/bash

# Example: Console Module
# This demonstrates the console logging and output formatting functionality

# Import bash-lib
source core/init.sh
import console

echo "=== Console Module Example ==="

# Basic logging functions
echo ""
echo "=== Basic Logging Functions ==="

console.log "This is a regular log message"
console.info "This is an informational message"
console.warn "This is a warning message"
console.error "This is an error message"
console.debug "This is a debug message (only shown if debug is enabled)"

# Enable debug mode
echo ""
echo "=== Debug Mode ==="
console.debug.enable
console.debug "This debug message will now be visible"
console.debug.disable
console.debug "This debug message will be hidden again"

# Colored output
echo ""
echo "=== Colored Output ==="
console.log "Regular message"
console.success "Success message"
console.info "Info message"
console.warn "Warning message"
console.error "Error message"

# Progress indicators
echo ""
echo "=== Progress Indicators ==="
console.progress.start "Processing data"
sleep 1
console.progress.update "Step 1/3: Reading files"
sleep 1
console.progress.update "Step 2/3: Processing data"
sleep 1
console.progress.update "Step 3/3: Writing results"
sleep 1
console.progress.complete "Processing completed successfully"

# Spinner for long-running operations
echo ""
echo "=== Spinner Example ==="
console.spinner.start "Downloading files"
sleep 3
console.spinner.stop "Download completed"

# Table output
echo ""
echo "=== Table Output ==="
console.table "Name,Age,City" "John,25,New York" "Jane,30,Los Angeles" "Bob,35,Chicago"

# JSON output
echo ""
echo "=== JSON Output ==="
console.json '{"name": "John", "age": 25, "city": "New York"}'

# Formatted output
echo ""
echo "=== Formatted Output ==="
console.format "%-20s %-10s %-15s" "Name" "Age" "City"
console.format "%-20s %-10s %-15s" "John Doe" "25" "New York"
console.format "%-20s %-10s %-15s" "Jane Smith" "30" "Los Angeles"

# Section headers
echo ""
echo "=== Section Headers ==="
console.section "User Information"
console.info "Name: John Doe"
console.info "Email: john@example.com"

console.section "System Status"
console.success "All systems operational"

# Status indicators
echo ""
echo "=== Status Indicators ==="
console.status "Database" "online"
console.status "Web Server" "online"
console.status "Cache" "offline"

# Interactive prompts
echo ""
echo "=== Interactive Prompts ==="
# Note: These are commented out to avoid blocking the script
# console.prompt "Enter your name: "
# console.confirm "Do you want to continue? "
# console.select "Choose an option:" "Option 1" "Option 2" "Option 3"

# Error handling with console
echo ""
echo "=== Error Handling ==="
function test_function() {
    if [[ $1 -eq 0 ]]; then
        console.error "Function failed with error code: $1"
        return 1
    else
        console.success "Function completed successfully"
        return 0
    fi
}

test_function 0
test_function 1

# Console settings
echo ""
echo "=== Console Settings ==="
console.settings.show

# Custom styling
echo ""
echo "=== Custom Styling ==="
console.custom "CUSTOM" "This is a custom styled message"
console.bold "This is bold text"
console.italic "This is italic text"
console.underline "This is underlined text"

# Timestamped logging
echo ""
echo "=== Timestamped Logging ==="
console.timestamp.enable
console.log "This message has a timestamp"
console.info "This info message also has a timestamp"
console.timestamp.disable
console.log "This message has no timestamp"

# Log levels
echo ""
echo "=== Log Levels ==="
console.level.set "warn"  # Only show warnings and errors
console.log "This log message will be hidden"
console.warn "This warning will be shown"
console.error "This error will be shown"
console.level.set "info"  # Reset to default

echo ""
echo "=== Console Module Example Complete ===" 