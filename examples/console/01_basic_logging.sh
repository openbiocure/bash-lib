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
echo "=== Basic Console Logging Example Complete ===" 