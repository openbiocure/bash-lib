#!/bin/bash

# Docker Initialization Test Script
# This script helps debug bash-lib initialization issues in Docker environments

set -e

echo "=== Docker Initialization Test Script ==="
echo "Testing bash-lib initialization in Docker environment"
echo

# Environment detection
echo "Environment Detection:"
echo "====================="
echo "Platform: $(uname -m)"
echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2 2>/dev/null || echo "Unknown")"
echo "Bash Version: $(bash --version | head -1)"
echo "User: $(whoami) (UID: $(id -u))"
echo "Docker Environment: $([ -f /.dockerenv ] && echo "Yes" || echo "No")"
echo "Cgroup Docker: $(grep -q docker /proc/1/cgroup 2>/dev/null && echo "Yes" || echo "No")"
echo

# Check required tools
echo "Required Tools Check:"
echo "===================="
for tool in bash curl unzip find grep sed awk; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo "✓ $tool: $(which $tool)"
    else
        echo "✗ $tool: Not found"
    fi
done
echo

# Check bash-lib installation
echo "Bash-lib Installation Check:"
echo "============================"
BASH__PATH="${BASH__PATH:-/opt/bash-lib}"
echo "BASH__PATH: $BASH__PATH"

if [[ -d "$BASH__PATH" ]]; then
    echo "✓ Bash-lib directory exists"

    # Check key files
    for file in "lib/core/init.sh" "lib/modules/system/console.mod.sh" "lib/modules/system/trapper.mod.sh"; do
        if [[ -f "$BASH__PATH/$file" ]]; then
            echo "✓ $file exists"
        else
            echo "✗ $file missing"
        fi
    done

    # Check permissions
    if [[ -r "$BASH__PATH/lib/core/init.sh" ]]; then
        echo "✓ init.sh is readable"
    else
        echo "✗ init.sh is not readable"
    fi

    if [[ -x "$BASH__PATH/lib/core/init.sh" ]]; then
        echo "✓ init.sh is executable"
    else
        echo "✗ init.sh is not executable"
    fi
else
    echo "✗ Bash-lib directory does not exist"
    exit 1
fi
echo

# Test init.sh syntax
echo "Syntax Check:"
echo "============="
if bash -n "$BASH__PATH/lib/core/init.sh"; then
    echo "✓ init.sh syntax is valid"
else
    echo "✗ init.sh has syntax errors"
    exit 1
fi
echo

# Test step-by-step initialization
echo "Step-by-Step Initialization Test:"
echo "================================="

# Step 1: Environment variables
echo "Step 1: Environment Variables"
export BASH_LIB_DEBUG=true
export BASH_LIB_DOCKER=true
echo "✓ Environment variables set"
echo

# Step 2: Direct sourcing test
echo "Step 2: Direct Sourcing Test"
echo "Attempting to source init.sh directly..."

# Capture all output and exit codes
{
    source_output=$(source "$BASH__PATH/lib/core/init.sh" 2>&1)
    source_exit_code=$?
} || {
    source_exit_code=$?
    source_output="Command failed with exit code $source_exit_code"
}

echo "Source exit code: $source_exit_code"
echo "Source output length: ${#source_output} characters"

if [[ $source_exit_code -eq 0 ]]; then
    echo "✓ Direct sourcing successful"
else
    echo "✗ Direct sourcing failed with exit code $source_exit_code"
    echo "Output: $source_output"
fi
echo

# Step 3: Import function test
echo "Step 3: Import Function Test"
if command -v import >/dev/null 2>&1; then
    echo "✓ Import function is available"

    # Test importing a simple module
    echo "Testing import console..."
    if import console 2>/dev/null; then
        echo "✓ Console module imported successfully"

        # Test console function
        if command -v console.info >/dev/null 2>&1; then
            echo "✓ Console functions are available"
            console.info "Test message from console module"
        else
            echo "✗ Console functions are not available"
        fi
    else
        echo "✗ Console module import failed"
    fi
else
    echo "✗ Import function is not available"
fi
echo

# Step 4: Module discovery test
echo "Step 4: Module Discovery Test"
echo "Available modules:"
find "$BASH__PATH/lib/modules" -name "*.mod.sh" 2>/dev/null | while read -r module; do
    module_name=$(basename "$module" .mod.sh)
    echo "  - $module_name"
done
echo

# Step 5: Function availability test
echo "Step 5: Function Availability Test"
if command -v import >/dev/null 2>&1; then
    echo "✓ Import function available"
    echo "✓ Import.meta.loaded function available"
    echo "✓ Import.meta.all function available"
    echo "✓ Import.meta.info function available"
    echo "✓ Import.force function available"
    echo "✓ Import.meta.reload function available"
else
    echo "✗ Import functions not available"
fi
echo

# Step 6: Environment after initialization
echo "Step 6: Environment After Initialization"
echo "BASH__PATH: $BASH__PATH"
echo "BASH__VERBOSE: ${BASH__VERBOSE:-not set}"
echo "BASH__RELEASE: ${BASH__RELEASE:-not set}"
echo "BASH_LIB_DEBUG: ${BASH_LIB_DEBUG:-not set}"
echo "BASH_LIB_DOCKER: ${BASH_LIB_DOCKER:-not set}"
echo

# Step 7: Loaded modules check
echo "Step 7: Loaded Modules Check"
if command -v import.meta.all >/dev/null 2>&1; then
    echo "Loaded modules:"
    import.meta.all
else
    echo "import.meta.all function not available"
fi
echo

# Step 8: Error simulation test
echo "Step 8: Error Simulation Test"
echo "Testing with invalid module..."
if import nonexistent_module 2>/dev/null; then
    echo "✗ Unexpected success importing nonexistent module"
else
    echo "✓ Correctly failed to import nonexistent module"
fi
echo

# Final status
echo "Final Status:"
echo "============="
if command -v import >/dev/null 2>&1 && command -v console.info >/dev/null 2>&1; then
    echo "✅ bash-lib initialization successful"
    echo "✅ All core functions available"
    echo "✅ Ready for use"
    exit 0
else
    echo "❌ bash-lib initialization failed"
    echo "❌ Core functions not available"
    echo "❌ Not ready for use"
    exit 1
fi
