#!/bin/bash

# Example: Core Initialization and Import System
# This demonstrates the core bash-lib initialization and module import system

echo "=== Core Initialization Example ==="

# Method 1: Direct source initialization
echo "Method 1: Direct source initialization"
source core/init.sh

# Method 2: Using BASH__PATH environment variable
echo ""
echo "Method 2: Using BASH__PATH environment variable"
export BASH__PATH="$(pwd)"
source core/init.sh

# Demonstrate import system
echo ""
echo "=== Import System Demonstration ==="

# Import a module
echo "Importing console module..."
import console

# Check if module is loaded
echo "Console module loaded: $(import.meta.loaded console)"

# Import multiple modules
echo ""
echo "Importing multiple modules..."
import http
import file
import directory
import math

# List all loaded modules
echo ""
echo "All loaded modules:"
import.meta.all

# Get import information
echo ""
echo "Import information for console module:"
import.meta.info console

# Demonstrate import error handling
echo ""
echo "=== Import Error Handling ==="

# Try to import a non-existent module
echo "Attempting to import non-existent module..."
if import nonexistent_module 2>/dev/null; then
    echo "Unexpected: non-existent module imported successfully"
else
    echo "Expected: non-existent module import failed"
fi

# Demonstrate module reloading prevention
echo ""
echo "=== Module Reloading Prevention ==="

echo "First import of console module..."
import console

echo "Second import of console module (should be skipped)..."
import console

echo "Force reload of console module..."
import.force console

# Demonstrate import status checking
echo ""
echo "=== Import Status Checking ==="

echo "Is console module loaded? $(import.meta.loaded console)"
echo "Is http module loaded? $(import.meta.loaded http)"
echo "Is nonexistent module loaded? $(import.meta.loaded nonexistent)"

echo ""
echo "=== Core Initialization Example Complete ===" 