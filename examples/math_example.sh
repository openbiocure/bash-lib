#!/bin/bash

# Example: Math Module
# This demonstrates the mathematical operations functionality

# Import bash-lib
source core/init.sh
import math
import console

echo "=== Math Module Example ==="

echo ""
echo "=== Basic Arithmetic Operations ==="

# Addition
console.info "Addition operations..."
result=$(math.add 10 5)
console.info "10 + 5 = $result"

result=$(math.add 3.14 2.86)
console.info "3.14 + 2.86 = $result"

# Subtraction
console.info "Subtraction operations..."
result=$(math.subtract 10 5)
console.info "10 - 5 = $result"

result=$(math.subtract 3.14 1.14)
console.info "3.14 - 1.14 = $result"

# Multiplication
console.info "Multiplication operations..."
result=$(math.multiply 10 5)
console.info "10 * 5 = $result"

result=$(math.multiply 3.14 2)
console.info "3.14 * 2 = $result"

# Division
console.info "Division operations..."
result=$(math.divide 10 5)
console.info "10 / 5 = $result"

result=$(math.divide 3.14 2)
console.info "3.14 / 2 = $result"

# Division by zero handling
console.info "Division by zero handling..."
if math.divide 10 0 2>/dev/null; then
    console.warn "Division by zero succeeded (unexpected)"
else
    console.success "Division by zero properly handled"
fi

echo ""
echo "=== Advanced Mathematical Operations ==="

# Power/Exponentiation
console.info "Power operations..."
result=$(math.power 2 3)
console.info "2^3 = $result"

result=$(math.power 5 2)
console.info "5^2 = $result"

result=$(math.power 2 0.5)
console.info "2^0.5 = $result"

# Square root
console.info "Square root operations..."
result=$(math.sqrt 16)
console.info "√16 = $result"

result=$(math.sqrt 2)
console.info "√2 = $result"

# Absolute value
console.info "Absolute value operations..."
result=$(math.abs -10)
console.info "|-10| = $result"

result=$(math.abs -3.14)
console.info "|-3.14| = $result"

result=$(math.abs 5)
console.info "|5| = $result"

# Modulo
console.info "Modulo operations..."
result=$(math.modulo 17 5)
console.info "17 % 5 = $result"

result=$(math.modulo 10 3)
console.info "10 % 3 = $result"

# Floor and ceiling
console.info "Floor and ceiling operations..."
result=$(math.floor 3.7)
console.info "floor(3.7) = $result"

result=$(math.ceil 3.2)
console.info "ceil(3.2) = $result"

result=$(math.floor -3.7)
console.info "floor(-3.7) = $result"

result=$(math.ceil -3.2)
console.info "ceil(-3.2) = $result"

echo ""
echo "=== Comparison Operations ==="

# Greater than
console.info "Greater than comparisons..."
if math.gt 10 5; then
    console.success "10 > 5 (true)"
else
    console.error "10 > 5 (false)"
fi

if math.gt 5 10; then
    console.error "5 > 10 (true)"
else
    console.success "5 > 10 (false)"
fi

# Less than
console.info "Less than comparisons..."
if math.lt 5 10; then
    console.success "5 < 10 (true)"
else
    console.error "5 < 10 (false)"
fi

# Equal
console.info "Equality comparisons..."
if math.eq 10 10; then
    console.success "10 == 10 (true)"
else
    console.error "10 == 10 (false)"
fi

if math.eq 10 5; then
    console.error "10 == 5 (true)"
else
    console.success "10 == 5 (false)"
fi

# Greater than or equal
console.info "Greater than or equal comparisons..."
if math.gte 10 10; then
    console.success "10 >= 10 (true)"
else
    console.error "10 >= 10 (false)"
fi

if math.gte 10 5; then
    console.success "10 >= 5 (true)"
else
    console.error "10 >= 5 (false)"
fi

# Less than or equal
console.info "Less than or equal comparisons..."
if math.lte 5 10; then
    console.success "5 <= 10 (true)"
else
    console.error "5 <= 10 (false)"
fi

if math.lte 5 5; then
    console.success "5 <= 5 (true)"
else
    console.error "5 <= 5 (false)"
fi

echo ""
echo "=== Statistical Operations ==="

# Calculate average
console.info "Average calculations..."
numbers="10 20 30 40 50"
result=$(math.average $numbers)
console.info "Average of $numbers = $result"

numbers="1.5 2.5 3.5 4.5"
result=$(math.average $numbers)
console.info "Average of $numbers = $result"

# Calculate sum
console.info "Sum calculations..."
result=$(math.sum $numbers)
console.info "Sum of $numbers = $result"

# Find minimum
console.info "Minimum calculations..."
result=$(math.min $numbers)
console.info "Minimum of $numbers = $result"

# Find maximum
console.info "Maximum calculations..."
result=$(math.max $numbers)
console.info "Maximum of $numbers = $result"

# Calculate range
console.info "Range calculations..."
result=$(math.range $numbers)
console.info "Range of $numbers = $result"

echo ""
echo "=== Trigonometric Functions ==="

# Sine
console.info "Sine calculations..."
result=$(math.sin 0)
console.info "sin(0) = $result"

result=$(math.sin 1.5708)  # π/2
console.info "sin(π/2) = $result"

# Cosine
console.info "Cosine calculations..."
result=$(math.cos 0)
console.info "cos(0) = $result"

result=$(math.cos 3.14159)  # π
console.info "cos(π) = $result"

# Tangent
console.info "Tangent calculations..."
result=$(math.tan 0)
console.info "tan(0) = $result"

result=$(math.tan 0.7854)  # π/4
console.info "tan(π/4) = $result"

echo ""
echo "=== Logarithmic Functions ==="

# Natural logarithm
console.info "Natural logarithm calculations..."
result=$(math.ln 1)
console.info "ln(1) = $result"

result=$(math.ln 2.71828)  # e
console.info "ln(e) = $result"

# Base-10 logarithm
console.info "Base-10 logarithm calculations..."
result=$(math.log10 1)
console.info "log10(1) = $result"

result=$(math.log10 100)
console.info "log10(100) = $result"

# Base-2 logarithm
console.info "Base-2 logarithm calculations..."
result=$(math.log2 1)
console.info "log2(1) = $result"

result=$(math.log2 8)
console.info "log2(8) = $result"

echo ""
echo "=== Mathematical Constants ==="

# Get mathematical constants
console.info "Mathematical constants..."
pi=$(math.pi)
console.info "π = $pi"

e=$(math.e)
console.info "e = $e"

echo ""
echo "=== Complex Calculations ==="

# Calculate area of a circle
console.info "Circle area calculation..."
radius=5
area=$(math.multiply $(math.multiply $pi $radius) $radius)
console.info "Area of circle with radius $radius = $area"

# Calculate compound interest
console.info "Compound interest calculation..."
principal=1000
rate=0.05
time=2
compound_interest=$(math.subtract $(math.multiply $principal $(math.power $(math.add 1 $rate) $time)) $principal)
console.info "Compound interest: $compound_interest"

# Calculate standard deviation (simplified)
console.info "Standard deviation calculation..."
values="2 4 4 4 5 5 7 9"
mean=$(math.average $values)
console.info "Mean: $mean"

# Calculate variance
variance_sum=0
count=0
for value in $values; do
    diff=$(math.subtract $value $mean)
    squared_diff=$(math.multiply $diff $diff)
    variance_sum=$(math.add $variance_sum $squared_diff)
    count=$(math.add $count 1)
done
variance=$(math.divide $variance_sum $count)
std_dev=$(math.sqrt $variance)
console.info "Standard deviation: $std_dev"

echo ""
echo "=== Error Handling ==="

# Test invalid inputs
console.info "Testing error handling..."

# Invalid number
if math.add "abc" 5 2>/dev/null; then
    console.warn "Invalid number accepted (unexpected)"
else
    console.success "Invalid number properly rejected"
fi

# Too many arguments
if math.add 1 2 3 2>/dev/null; then
    console.warn "Too many arguments accepted (unexpected)"
else
    console.success "Too many arguments properly rejected"
fi

# Missing arguments
if math.add 1 2>/dev/null; then
    console.warn "Missing arguments accepted (unexpected)"
else
    console.success "Missing arguments properly rejected"
fi

echo ""
echo "=== Math Module Example Complete ===" 