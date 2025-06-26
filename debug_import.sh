#!/bin/bash

echo "=== Debug Import Issue ==="

# Source the init script
source core/init.sh

echo "=== Checking Guard Variables ==="
echo "BASH_LIB_IMPORTED_console: ${BASH_LIB_IMPORTED_console:-'NOT SET'}"
echo "BASH_LIB_IMPORTED_trapper: ${BASH_LIB_IMPORTED_trapper:-'NOT SET'}"
echo "BASH_LIB_IMPORTED_colors: ${BASH_LIB_IMPORTED_colors:-'NOT SET'}"

echo "=== Testing Console Import ==="
import console

echo "=== Checking Guard Variables After Import ==="
echo "BASH_LIB_IMPORTED_console: ${BASH_LIB_IMPORTED_console:-'NOT SET'}"

echo "=== Test Complete ===" 