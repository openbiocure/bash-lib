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
console.info "Subtraction: $(math.subtract $a $b)"
console.info "Multiplication: $(math.multiply $a $b)"
console.info "Division: $(math.divide $a $b)"
console.info "Modulo: $(math.modulo $a $b)"
console.info "Power: $(math.power $a $b)"

# Comparison operations
echo ""
echo "=== Comparison Operations ==="
console.info "Is $a greater than $b? $(math.greaterThan $a $b)"
console.info "Is $a less than $b? $(math.lessThan $a $b)"
console.info "Is $a equal to $b? $(math.equal $a $b)"

echo ""
echo "=== Basic Math Operations Example Complete ==="
