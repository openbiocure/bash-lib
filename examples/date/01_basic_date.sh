#!/bin/bash

# Example: Basic Date Operations
# This demonstrates basic date and time operations

# Import bash-lib
source core/init.sh
import date
import console

echo "=== Basic Date Operations ==="

echo ""
echo "=== Basic Date Operations ==="

# Current date and time
console.info "Current date and time:"
console.info "  Date: $(date.current)"
console.info "  Time: $(date.time)"
console.info "  Timestamp: $(date.timestamp)"

# Date formatting
console.info "Date formatting:"
console.info "  ISO format: $(date.format "$(date.current)" "%Y-%m-%d")"
console.info "  US format: $(date.format "$(date.current)" "%m/%d/%Y")"
console.info "  European format: $(date.format "$(date.current)" "%d/%m/%Y")"

# Date arithmetic
console.info "Date arithmetic:"
tomorrow=$(date.add "$(date.current)" 1 "day")
yesterday=$(date.subtract "$(date.current)" 1 "day")
console.info "  Tomorrow: $tomorrow"
console.info "  Yesterday: $yesterday"

echo ""
echo "=== Basic Date Operations Example Complete ==="
