#!/bin/bash

# Example: Console Settings
# This demonstrates console configuration and customization

# Import bash-lib
source core/init.sh
import console

echo "=== Console Settings ==="

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

# Console configuration examples
echo ""
echo "=== Console Configuration ==="

# Show current settings
console.info "Current console settings:"
console.settings.show

# Demonstrate different log levels
echo ""
echo "=== Log Level Demonstration ==="

console.info "Setting log level to 'error' (only errors will show)"
console.level.set "error"
console.log "This log message will be hidden"
console.info "This info message will be hidden"
console.warn "This warning will be hidden"
console.error "This error will be shown"

console.info "Setting log level to 'warn' (warnings and errors will show)"
console.level.set "warn"
console.log "This log message will be hidden"
console.info "This info message will be hidden"
console.warn "This warning will be shown"
console.error "This error will be shown"

console.info "Setting log level to 'info' (default - all messages will show)"
console.level.set "info"
console.log "This log message will be shown"
console.info "This info message will be shown"
console.warn "This warning will be shown"
console.error "This error will be shown"

# Timestamp configuration
echo ""
echo "=== Timestamp Configuration ==="

console.info "Enabling timestamps..."
console.timestamp.enable
console.log "This message has a timestamp"
console.info "This info message also has a timestamp"

console.info "Disabling timestamps..."
console.timestamp.disable
console.log "This message has no timestamp"
console.info "This info message has no timestamp"

# Debug mode configuration
echo ""
echo "=== Debug Mode Configuration ==="

console.info "Debug mode is disabled by default"
console.debug "This debug message is hidden"

console.info "Enabling debug mode..."
console.debug.enable
console.debug "This debug message is now visible"

console.info "Disabling debug mode..."
console.debug.disable
console.debug "This debug message is hidden again"

# Custom message formatting
echo ""
echo "=== Custom Message Formatting ==="

# Create custom message types
console.custom "SUCCESS" "Operation completed successfully"
console.custom "WARNING" "Please review the configuration"
console.custom "ERROR" "Critical system failure"
console.custom "INFO" "System information updated"

# Styled text combinations
echo ""
echo "=== Styled Text Combinations ==="
console.bold "Bold text"
console.italic "Italic text"
console.underline "Underlined text"
console.bold "Bold and " && console.italic "italic text"
console.bold "Bold and " && console.underline "underlined text"

# Console output redirection
echo ""
echo "=== Console Output Redirection ==="

# Save current settings
console.info "Saving current console settings..."

# Demonstrate output to file
console.info "Console output can be redirected to files for logging"
console.info "Example: ./script.sh > output.log 2>&1"

# Error handling demonstration
echo ""
echo "=== Error Handling Demonstration ==="

function demonstrate_error_handling() {
    local operation="$1"
    local should_fail="$2"
    
    console.info "Testing operation: $operation"
    
    if [ "$should_fail" = "true" ]; then
        console.error "Operation '$operation' failed"
        return 1
    else
        console.success "Operation '$operation' completed successfully"
        return 0
    fi
}

demonstrate_error_handling "Database connection" "false"
demonstrate_error_handling "File system check" "true"
demonstrate_error_handling "Network test" "false"

echo ""
echo "=== Console Settings Example Complete ===" 