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

# Trimming
console.info "Trimming operations:"
spaced_text="   Hello World   "
console.info "Original: '$spaced_text'"
console.info "Trimmed: '$(string.trim "$spaced_text")'"

# String contains
console.info "String contains operations:"
console.info "Does '$text' contain 'World'? $(string.contains "$text" "World")"
console.info "Does '$text' contain 'Python'? $(string.contains "$text" "Python")"

# String starts/ends with
console.info "String starts/ends with operations:"
console.info "Does '$text' start with 'Hello'? $(string.startswith "$text" "Hello")"
console.info "Does '$text' end with 'World'? $(string.endswith "$text" "World")"

# String replace
console.info "String replace operations:"
console.info "Replace 'World' with 'Bash': $(string.replace "World" "Bash" "$text")"

echo ""
echo "=== Basic String Operations Example Complete ==="
