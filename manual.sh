#!/bin/bash

# Manual Generator for bash-lib (bash-lib only version)
# Generates Manual.md using only bash-lib modules (no bash built-ins)

# Import required modules
source core/init.sh
import console
import file
import directory
import string
import engine

# Set output file
manual_file="Manual.md"

# Helper: Print status/info/warning/error using console module
status()   { console.info   "$1"; }
warning()  { console.warn   "$1"; }
error()    { console.error "$1"; }
success()  { console.success "$1"; }

# Helper: Capitalize first letter using string module
capitalize() {
    string.upper "${1:0:1}" > /tmp/__cap.tmp
    string.lower "${1:1}" > /tmp/__rest.tmp
    file.read /tmp/__cap.tmp > /tmp/__cap2.tmp
    file.read /tmp/__rest.tmp > /tmp/__rest2.tmp
    cap=$(file.read /tmp/__cap2.tmp)
    rest=$(file.read /tmp/__rest2.tmp)
    file.delete /tmp/__cap.tmp
    file.delete /tmp/__rest.tmp
    file.delete /tmp/__cap2.tmp
    file.delete /tmp/__rest2.tmp
    console.log "$cap$rest" > /tmp/__final_cap.tmp
    file.read /tmp/__final_cap.tmp
    file.delete /tmp/__final_cap.tmp
}

# Helper: Append to manual file
append_manual() {
    file.write "$manual_file" "$1" --append
}

# Helper: Create manual file
create_manual() {
    file.create "$manual_file" "$1" --overwrite
}

# Main manual generation logic
main() {
    status "Generating $manual_file using bash-lib only..."

    # Delete existing file and create fresh
    file.delete "$manual_file" 2>/dev/null || true

    # Header
    create_manual "# bash-lib Manual\n\nA comprehensive bash library providing modular utilities for common shell operations.\n\n## Table of Contents\n"

    # Get list of modules using engine.modules
    engine.modules > /tmp/__modules.tmp 2>/dev/null || {
        error "Failed to get module list from engine.modules"
        return 1
    }

    # Extract module names from engine.modules output and build TOC
    file.read /tmp/__modules.tmp | while read -r line; do
        # Extract module name from lines like: "25/06/2025 15:30:55 - EPAEDUBW001A - test_engine.sh - [LOG]: file"
        if [[ "$line" == *" - [LOG]: "* ]]; then
            local module_name=$(echo "$line" | sed 's/.* - \[LOG\]: //')
            if [[ -n "$module_name" ]]; then
                local module_title=$(capitalize "$module_name")
                append_manual "- [${module_title}](#${module_name})\n"
                status "  Added to TOC: $module_name"
            fi
        fi
    done
    file.delete /tmp/__modules.tmp

    append_manual "\n## Installation\n\n\`\`\`bash\n# Clone the repository\ngit clone <repository-url>\ncd bash-lib\n\n# Install dependencies\nmake install-deps\n\n# Install bash-lib\nmake install\n\`\`\`\n\n## Usage\n\n\`\`\`bash\n# Source the library\nexport BASH__PATH=\"/path/to/bash-lib\"\nsource core/init.sh\n\n# Import a module\nimport directory\nimport http\nimport math\n\n# Use the functions\ndirectory.create /tmp/test\nhttp.get https://api.example.com\nmath.add 5 3\n\`\`\`\n\n## Modules\n"

    # Get modules again for documentation
    engine.modules > /tmp/__modules2.tmp 2>/dev/null

    # For each module, add section
    file.read /tmp/__modules2.tmp | while read -r line; do
        if [[ "$line" == *" - [LOG]: "* ]]; then
            local module_name=$(echo "$line" | sed 's/.* - \[LOG\]: //')
            if [[ -n "$module_name" ]]; then
                local module_title=$(capitalize "$module_name")
                append_manual "\n### $module_title\n\n"
                
                status "  Processing module: $module_name"
                
                # Get help content by importing module and calling help function
                if import "$module_name" 2>/dev/null; then
                    local help_func="${module_name}.help"
                    if type "$help_func" >/dev/null 2>&1; then
                        append_manual '\`\`\`bash\n'
                        "$help_func" > /tmp/__help.tmp 2>/dev/null || echo "Help function failed to execute" > /tmp/__help.tmp
                        file.read /tmp/__help.tmp | while read -r help_line; do
                            append_manual "$help_line\n"
                        done
                        append_manual '\`\`\`\n'
                        file.delete /tmp/__help.tmp
                        status "  Added help content for: $module_name"
                    else
                        warning "  No help function found for $module_name"
                        append_manual "No help function available for this module.\n"
                    fi
                else
                    warning "  Failed to import module $module_name"
                    append_manual "Failed to import module.\n"
                fi
            fi
        fi
    done
    file.delete /tmp/__modules2.tmp

    append_manual "\n## Contributing\n\n1. Fork the repository\n2. Create a feature branch\n3. Add your module or improvements\n4. Write tests for your changes\n5. Submit a pull request\n\n## License\n\nThis project is licensed under the MIT License - see the LICENSE file for details.\n\n---\n\n*Generated automatically by manual.sh*\n"

    success "Manual generated successfully: $manual_file"
}

main "$@" 