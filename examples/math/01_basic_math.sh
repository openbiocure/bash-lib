#!/bin/bash

# Example: Basic Math Operations
# This demonstrates basic mathematical operations

# Import bash-lib
source core/init.sh
import math
import console

echo "=== Basic Math Operations ==="

# Basic arithmetic
echo ""
echo "=== Basic Arithmetic ==="
a=10
b=5

console.info "Basic arithmetic with a=$a, b=$b"
console.info "Addition: $(math.add $a $b)"

# Show available functions
echo ""
echo "=== Available Math Functions ==="
math.help

echo ""
echo "=== Basic Math Operations Example Complete ==="
