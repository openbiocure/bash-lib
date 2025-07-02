#!/bin/bash

# Engine Module for bash-lib
# Core engine functionality

# Call import.meta.loaded if the function exists
if command -v import.meta.loaded >/dev/null 2>&1; then
    import.meta.loaded "engine" "${BASH__PATH:-/opt/bash-lib}/lib/modules/core/engine.mod.sh" "1.0.0" 2>/dev/null || true
fi

import console

##
## (Usage) List all available modules
## Examples:
##   engine.modules
##   engine.modules --help
##
function engine.modules() {
    # List all module names (from *.mod.sh files in lib/modules/)
    find "${BASH__PATH:-}/lib/modules" -name "*.mod.sh" 2>/dev/null | while read -r modfile; do
        local module_name=$(basename "$modfile" .mod.sh)
        printf "%s\n" "$module_name"
    done
}

##
## (Usage) List modules by category/bundle
## Examples:
##   engine.modules.byCategory
##   engine.modules.byCategory --system
##
function engine.modules.byCategory() {
    local category_filter=""

    # Parse options
    for arg in "$@"; do
        case $arg in
            --system) category_filter="system" ;;
            --core) category_filter="core" ;;
            --utils) category_filter="utils" ;;
            --file) category_filter="file" ;;
            --http) category_filter="http" ;;
            --math) category_filter="math" ;;
            --date) category_filter="date" ;;
            --compression) category_filter="compression" ;;
            --directory) category_filter="directory" ;;
            --permission) category_filter="permission" ;;
            --users) category_filter="users" ;;
            *) ;;
        esac
    done

    console.info "bash-lib modules by category:"
    console.info "============================="

    # Find all module directories
    find ${BASH__PATH:-}/lib/modules -type d -mindepth 1 -maxdepth 1 2>/dev/null | sort | while read -r category_dir; do
        local category_name=$(basename "$category_dir")

        # Skip if category filter is specified and doesn't match
        if [[ -n "$category_filter" && "$category_name" != "$category_filter" ]]; then
            continue
        fi

        console.log ""
        console.log "${BWhite}${category_name}${NC}:"

        # Find modules in this category
        find "$category_dir" -name "*.mod.sh" 2>/dev/null | sort | while read -r modfile; do
            local module_name=$(basename "$modfile" .mod.sh)
            console.log "  ${BGreen}${module_name}${NC}"
        done
    done
}

# Module import signal using scoped naming
export BASH_LIB_IMPORTED_engine="1"
