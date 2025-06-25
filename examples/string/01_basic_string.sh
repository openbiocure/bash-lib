#!/bin/bash

# Example: Basic String Operations
# This demonstrates basic string manipulation

# Import bash-lib
source core/init.sh
import string
import console

echo "=== Basic String Operations ==="

# Test strings
text="Hello World"
long_text="This is a longer text for testing string operations"

echo ""
echo "=== Basic String Operations ==="

# Length
console.info "String length operations:"
console.info "Length of '$text': $(string.length "$text")"
console.info "Length of '$long_text': $(string.length "$long_text")"

# Case operations
console.info "Case operations:"
console.info "Uppercase: $(string.upper "$text")"
console.info "Lowercase: $(string.lower "$text")"
console.info "Title case: $(string.title "$text")"

# Trimming
console.info "Trimming operations:"
spaced_text="   Hello World   "
console.info "Original: '$spaced_text'"
console.info "Trimmed: '$(string.trim "$spaced_text")'"

echo ""
echo "=== Basic String Operations Example Complete ==="
