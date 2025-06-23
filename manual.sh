#!/bin/bash

# Manual Generator for bash-lib
# Automatically generates Manual.md from all module help functions

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Initialize bash-lib environment
export BASH__PATH="$(pwd)"
source core/init.sh

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to get module name from path
get_module_name() {
    local path="$1"
    basename "$(dirname "$path")"
}

# Function to capitalize first letter (POSIX compliant)
capitalize() {
    local str="$1"
    local first="${str:0:1}"
    local rest="${str:1}"
    echo "$(echo "$first" | tr '[:lower:]' '[:upper:]')$rest"
}

# Function to check if a module has a help function
has_help_function() {
    local module_dir="$1"
    # Check all .mod.sh files in the module directory
    while IFS= read -r -d '' file; do
        if grep -q "function.*\.help()" "$file" 2>/dev/null; then
            return 0
        fi
    done < <(find "$module_dir" -name "*.mod.sh" -print0 2>/dev/null)
    return 1
}

# Function to get help function name
get_help_function() {
    local module_dir="$1"
    local module_name=$(basename "$module_dir")
    
    # Check all .mod.sh files in the module directory
    while IFS= read -r -d '' file; do
        if grep -q "function.*\.help()" "$file" 2>/dev/null; then
            # Extract the help function name from the file
            local help_func=$(grep -o "function [^.]*\.help()" "$file" | head -1 | sed 's/function //')
            if [[ -n "$help_func" ]]; then
                echo "$help_func"
                return 0
            fi
        fi
    done < <(find "$module_dir" -name "*.mod.sh" -print0 2>/dev/null)
    
    # Fallback to module name
    echo "${module_name}.help"
}

# Function to run help function and capture output
run_help_function() {
    local module_dir="$1"
    local help_func=$(get_help_function "$module_dir")
    
    # Find the file containing the help function
    local help_file=""
    while IFS= read -r -d '' file; do
        if grep -q "function.*\.help()" "$file" 2>/dev/null; then
            help_file="$file"
            break
        fi
    done < <(find "$module_dir" -name "*.mod.sh" -print0 2>/dev/null)
    
    if [[ -z "$help_file" ]]; then
        print_warning "No help file found for $module_dir"
        return 1
    fi
    
    # Source the file and run the help function
    local output
    if output=$(bash -c "export BASH__PATH=\"$(pwd)\" && source core/init.sh && source \"$help_file\" && $help_func" 2>&1); then
        echo "$output"
    else
        print_warning "Failed to run $help_func from $help_file"
        return 1
    fi
}

# Function to generate manual content
generate_manual() {
    local output_file="$1"
    
    # Create header
    cat > "$output_file" << 'EOF'
# bash-lib Manual

A comprehensive bash library providing modular utilities for common shell operations.

## Table of Contents

EOF

    # Find all module directories
    local module_dirs=()
    while IFS= read -r -d '' dir; do
        # Skip the top-level modules directory itself
        [[ "$dir" == "modules" ]] && continue
        if [[ -d "$dir" ]]; then
            module_dirs+=("$dir")
        fi
    done < <(find modules -mindepth 1 -type d -print0 2>/dev/null)

    # Sort module directories alphabetically
    IFS=$'\n' module_dirs=($(sort <<<"${module_dirs[*]}"))
    unset IFS

    # Generate table of contents
    for module_dir in "${module_dirs[@]}"; do
        local module_name=$(basename "$module_dir")
        local module_title=$(capitalize "$module_name")
        echo "- [$module_title](#$module_name)" >> "$output_file"
    done

    # Add sections
    cat >> "$output_file" << 'EOF'

## Installation

```bash
# Clone the repository
git clone <repository-url>
cd bash-lib

# Install dependencies
make install-deps

# Install bash-lib
make install
```

## Usage

```bash
# Source the library
export BASH__PATH="/path/to/bash-lib"
source core/init.sh

# Import a module
import directory
import http
import math

# Use the functions
directory.create /tmp/test
http.get https://api.example.com
math.add 5 3
```

## Modules

EOF

    # Generate module documentation
    local module_count=0
    for module_dir in "${module_dirs[@]}"; do
        local module_name=$(basename "$module_dir")
        local module_title=$(capitalize "$module_name")
        
        print_status "Processing module: $module_name"
        
        # Add module header
        echo "### $module_title" >> "$output_file"
        echo "" >> "$output_file"
        
        # Check if module has help function
        if has_help_function "$module_dir"; then
            print_status "  Found help function for $module_name"
            
            # Get help output
            local help_output
            if help_output=$(run_help_function "$module_dir" 2>/dev/null); then
                # Format the help output
                echo '```bash' >> "$output_file"
                echo "$help_output" >> "$output_file"
                echo '```' >> "$output_file"
            else
                print_warning "  Failed to get help for $module_name"
                echo "Help function available but failed to execute." >> "$output_file"
            fi
        else
            print_warning "  No help function found for $module_name"
            echo "No help function available for this module." >> "$output_file"
        fi
        
        echo "" >> "$output_file"
        ((module_count++))
    done

    # Add footer
    cat >> "$output_file" << 'EOF'

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add your module or improvements
4. Write tests for your changes
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

---

*Generated automatically by manual.sh*
EOF

    print_status "Generated manual with $module_count modules"
}

# Main execution
main() {
    local output_file="Manual.md"
    
    print_status "Starting manual generation..."
    
    # Check if bash-lib is properly initialized
    if [[ ! -f "core/init.sh" ]]; then
        print_error "core/init.sh not found. Please run this script from the bash-lib root directory."
        exit 1
    fi
    
    # Generate the manual
    generate_manual "$output_file"
    
    print_status "Manual generated successfully: $output_file"
    print_status "You can now view the manual with: cat $output_file"
}

# Run main function
main "$@" 