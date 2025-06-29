#!/bin/bash

# Example: Basic Console Logging
# This demonstrates fundamental console logging functions

# Import bash-lib
source core/init.sh
import console

echo "=== Basic Console Logging ==="

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
console.set_verbosity debug
console.debug "This debug message will now be visible"
console.set_verbosity info
console.debug "This debug message will be hidden again"

# Colored output
echo ""
echo "=== Colored Output ==="
console.log "Regular message"
console.success "Success message"
console.info "Info message"
console.warn "Warning message"
console.error "Error message"

# Verbosity levels
echo ""
echo "=== Verbosity Levels ==="
console.set_verbosity warn  # Only show warnings and errors
console.log "This log message will be hidden"
console.warn "This warning will be shown"
console.error "This error will be shown"
console.set_verbosity info  # Reset to default

# Get current verbosity
echo ""
echo "=== Current Verbosity ==="
current_verbosity=$(console.get_verbosity)
console.info "Current verbosity level: $current_verbosity"

echo ""
echo "=== Basic Console Logging Example Complete ===" 