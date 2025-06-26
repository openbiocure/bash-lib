#!/bin/bash

# Manual Generator for bash-lib (bash-lib only version)
# Generates Manual.md using only bash-lib modules (no bash built-ins)

# Import required modules
source core/init.sh
import console
import file
import string
import engine

# Set output file
manual_file="Manual.md"

# Helper: Print status/info/warning/error using console module (suppress output)
status()   { console.info   "$1" >/dev/null 2>&1; }
warning()  { console.warn   "$1" >/dev/null 2>&1; }
error()    { console.error "$1" >/dev/null 2>&1; }
success()  { console.success "$1" >/dev/null 2>&1; }

# Helper: Simple capitalize first letter (no file operations)
capitalize() {
    first=$(echo "$1" | cut -c1)
    rest=$(echo "$1" | cut -c2-)
    cap=$(string.upper "$first" 2>/dev/null)
    low=$(string.lower "$rest" 2>/dev/null)
    echo "${cap}${low}"
}

# Helper: Append to manual file
append_manual() {
    file.write "$manual_file" "$1" --append >/dev/null 2>&1
}

# Helper: Create manual file
create_manual() {
    file.create "$manual_file" "$1" --overwrite >/dev/null 2>&1
}

# Main manual generation logic
main() {
    status "Generating $manual_file using bash-lib only..."

    # Delete existing file and create fresh
    file.delete "$manual_file" 2>/dev/null || true

    # Create header step by step
    echo "# bash-lib Manual" > "$manual_file"
    echo "" >> "$manual_file"
    echo "A comprehensive bash library providing modular utilities for common shell operations." >> "$manual_file"
    echo "" >> "$manual_file"
    echo "## Summary" >> "$manual_file"
    echo "" >> "$manual_file"
    echo "bash-lib is a modular shell scripting library that provides:" >> "$manual_file"
    echo "" >> "$manual_file"
    echo "- **15+ modules** covering file operations, HTTP requests, user management, and more" >> "$manual_file"
    echo "- **Structured logging** with color-coded output and verbosity control" >> "$manual_file"
    echo "- **Error handling** with comprehensive signal trapping and cleanup" >> "$manual_file"
    echo "- **Developer-friendly APIs** that make shell scripting readable and maintainable" >> "$manual_file"
    echo "- **Auto-generated documentation** from built-in help functions" >> "$manual_file"
    echo "- **Cross-platform compatibility** with POSIX-compliant shell operations" >> "$manual_file"
    echo "" >> "$manual_file"
    echo "## Table of Contents" >> "$manual_file"

    # Get list of modules using engine.modules (simple output)
    engine.modules > /tmp/__modules.tmp 2>/dev/null || {
        error "Failed to get module list from engine.modules"
        return 1
    }

    # Build Table of Contents from simple module names
    while read -r module_name; do
        if [[ -n "$module_name" ]]; then
            local module_title=$(capitalize "$module_name")
            echo "- [${module_title}](#${module_name})" >> "$manual_file"
            status "  Added to TOC: $module_name"
        fi
    done < /tmp/__modules.tmp
    file.delete /tmp/__modules.tmp 2>/dev/null

    echo "" >> "$manual_file"
    echo "" >> "$manual_file"
    echo "## Installation" >> "$manual_file"
    echo "" >> "$manual_file"
    echo '```sh' >> "$manual_file"
    echo "# Clone the repository" >> "$manual_file"
    echo "git clone <repository-url>" >> "$manual_file"
    echo "cd bash-lib" >> "$manual_file"
    echo "" >> "$manual_file"
    echo "# Install dependencies" >> "$manual_file"
    echo "make install-deps" >> "$manual_file"
    echo "" >> "$manual_file"
    echo "# Install bash-lib" >> "$manual_file"
    echo "make install" >> "$manual_file"
    echo '```' >> "$manual_file"
    echo "" >> "$manual_file"
    echo "## Usage" >> "$manual_file"
    echo "" >> "$manual_file"
    echo '```sh' >> "$manual_file"
    echo "# Source the library" >> "$manual_file"
    echo 'export BASH__PATH="/path/to/bash-lib"' >> "$manual_file"
    echo "source core/init.sh" >> "$manual_file"
    echo "" >> "$manual_file"
    echo "# Import a module" >> "$manual_file"
    echo "import directory" >> "$manual_file"
    echo "import http" >> "$manual_file"
    echo "import math" >> "$manual_file"
    echo "" >> "$manual_file"
    echo "# Use the functions" >> "$manual_file"
    echo "directory.create /tmp/test" >> "$manual_file"
    echo "http.get https://api.example.com" >> "$manual_file"
    echo "math.add 5 3" >> "$manual_file"
    echo '```' >> "$manual_file"
    echo "" >> "$manual_file"
    echo "## Modules" >> "$manual_file"

    # Get modules again for documentation
    engine.modules > /tmp/__modules2.tmp 2>/dev/null

    # For each module, add section
    while read -r module_name; do
        if [[ -n "$module_name" ]]; then
            local module_title=$(capitalize "$module_name")
            echo "" >> "$manual_file"
            echo "### $module_title" >> "$manual_file"
            echo "" >> "$manual_file"
            
            status "  Processing module: $module_name"
            
            # Get help content by importing module and calling help function
            if import "$module_name" 2>/dev/null; then
                local help_func="${module_name}.help"
                if type "$help_func" >/dev/null 2>&1; then
                    echo '```sh' >> "$manual_file"
                    "$help_func" > /tmp/__help.tmp 2>/dev/null || echo "Help function failed to execute" > /tmp/__help.tmp
                    # Clean up escaped characters only, don't touch backticks
                    cat /tmp/__help.tmp | tr -d '\r' | sed 's/\\\$/\$/g; s/\\`/`/g' >> "$manual_file"
                    echo '```' >> "$manual_file"
                    file.delete /tmp/__help.tmp 2>/dev/null
                    status "  Added help content for: $module_name"
                else
                    warning "  No help function found for $module_name"
                    echo "No help function available for this module." >> "$manual_file"
                fi
            else
                warning "  Failed to import module $module_name"
                echo "Failed to import module." >> "$manual_file"
            fi
        fi
    done < /tmp/__modules2.tmp
    file.delete /tmp/__modules2.tmp 2>/dev/null

    echo "" >> "$manual_file"
    echo "## Contributing" >> "$manual_file"
    echo "" >> "$manual_file"
    echo "1. Fork the repository" >> "$manual_file"
    echo "2. Create a feature branch" >> "$manual_file"
    echo "3. Add your module or improvements" >> "$manual_file"
    echo "4. Write tests for your changes" >> "$manual_file"
    echo "5. Submit a pull request" >> "$manual_file"
    echo "" >> "$manual_file"
    echo "## License" >> "$manual_file"
    echo "" >> "$manual_file"
    echo "This project is licensed under the MIT License - see the LICENSE file for details." >> "$manual_file"
    echo "" >> "$manual_file"
    echo "---" >> "$manual_file"
    echo "" >> "$manual_file"
    echo "*Generated automatically by manual.sh*" >> "$manual_file"

    success "Manual generated successfully: $manual_file"
}

main "$@" 