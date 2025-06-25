#!/bin/bash

# Example: Basic User Operations
# This demonstrates basic user information operations

# Import bash-lib
source core/init.sh
import users
import console

echo "=== Basic User Operations ==="

echo ""
echo "=== Basic User Operations ==="

# Current user information
console.info "Current user information:"
console.info "  Username: $(users.current)"
console.info "  User ID: $(users.id)"
console.info "  Home directory: $(users.home)"

# User existence check
console.info "User existence check:"
test_user="root"
if users.exists "$test_user"; then
    console.success "User '$test_user' exists"
else
    console.error "User '$test_user' does not exist"
fi

# User information
console.info "User information for '$test_user':"
console.info "  User ID: $(users.id "$test_user")"
console.info "  Home directory: $(users.home "$test_user")"
console.info "  Shell: $(users.shell "$test_user")"

echo ""
echo "=== Basic User Operations Example Complete ==="
