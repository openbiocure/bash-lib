#!/bin/bash

# Trapper Module for bash-lib
# Provides comprehensive signal handling and error trapping functionality for all modules

# Call import.meta.loaded if the function exists
if command -v import.meta.loaded >/dev/null 2>&1; then
    import.meta.loaded "trapper" "${BASH__PATH:-/opt/bash-lib}/lib/modules/system/trapper.mod.sh" "1.0.0" 2>/dev/null || true
fi

import console

# Global trap registry for all modules
declare -A TRAP_REGISTRY
declare -A MODULE_TRAPS

##
## (Usage) Add a trap for specific signals
## Examples:
##   trapper.addTrap 'echo "Exiting..."' EXIT
##   trapper.addTrap 'cleanup_function' INT TERM
##   trapper.addTrap 'console.log "Error occurred"' ERR
##
function trapper.addTrap() {
    local cmd="$1"
    shift
    local sig traps
    for sig in "$@"; do
        traps="$(trapper.getTraps $sig | trapper.filterTraps "$cmd")"
        if [[ -n "$traps" ]]; then
            trap "$traps ; $cmd" $sig
        else
            trap "$cmd" $sig
        fi
        # Register the trap
        TRAP_REGISTRY["$sig"]="${TRAP_REGISTRY[$sig]:-} $cmd"
    done
}

##
## (Usage) Add a module-specific trap
## Examples:
##   trapper.addModuleTrap "http" 'http.cleanup' EXIT
##   trapper.addModuleTrap "file" 'file.cleanup_temp' INT TERM
##
function trapper.addModuleTrap() {
    local module="$1"
    local cmd="$2"
    shift 2

    if [[ -z "$module" || -z "$cmd" ]]; then
        console.error "Module name and command are required"
        return 1
    fi

    # Register module trap
    MODULE_TRAPS["$module"]="${MODULE_TRAPS[$module]:-} $cmd"

    # Add to global trap system
    trapper.addTrap "$cmd" "$@"

    console.debug "Added trap for module '$module': $cmd"
}

##
## (Usage) Remove a specific trap
## Examples:
##   trapper.removeTrap 'cleanup_function' INT
##   trapper.removeTrap 'echo "Exiting..."' EXIT
##
function trapper.removeTrap() {
    local cmd="$1"
    local sig="$2"

    if [[ -z "$cmd" || -z "$sig" ]]; then
        console.error "Command and signal are required"
        return 1
    fi

    # Get current traps for this signal
    local current_traps=$(trapper.getTraps "$sig")

    # Remove the specific command
    local new_traps=$(echo "$current_traps" | sed "s/$cmd//g" | sed 's/;;/;/g' | sed 's/^;//' | sed 's/;$//')

    if [[ -n "$new_traps" ]]; then
        trap "$new_traps" "$sig"
    else
        trap - "$sig"
    fi

    # Remove from registry
    TRAP_REGISTRY["$sig"]=$(echo "${TRAP_REGISTRY[$sig]}" | sed "s/$cmd//g")

    console.debug "Removed trap: $cmd for signal $sig"
}

##
## (Usage) Remove all traps for a module
## Examples:
##   trapper.removeModuleTraps "http"
##   trapper.removeModuleTraps "file"
##
function trapper.removeModuleTraps() {
    local module="$1"

    if [[ -z "$module" ]]; then
        console.error "Module name is required"
        return 1
    fi

    local module_traps="${MODULE_TRAPS[$module]}"
    if [[ -n "$module_traps" ]]; then
        for trap_cmd in $module_traps; do
            # Remove from all common signals
            trapper.removeTrap "$trap_cmd" EXIT
            trapper.removeTrap "$trap_cmd" INT
            trapper.removeTrap "$trap_cmd" TERM
            trapper.removeTrap "$trap_cmd" ERR
        done

        # Clear module registry
        unset MODULE_TRAPS["$module"]

        console.debug "Removed all traps for module '$module'"
    else
        console.debug "No traps found for module '$module'"
    fi
}

##
## (Usage) Get current traps for a signal
## Examples:
##   trapper.getTraps EXIT
##   trapper.getTraps INT
##
function trapper.getTraps() {
    local sig="$1"
    if [[ -z "$sig" ]]; then
        console.error "Signal is required"
        return 1
    fi

    echo $(trap | grep "$sig" | sed -e "s/$'\n'/ ; /g")
}

##
## (Usage) Filter traps by command
## Examples:
##   trapper.filterTraps "cleanup_function"
##   trapper.filterTraps "echo"
##
function trapper.filterTraps() {
    local cmd="$1"
    if [[ -z "$cmd" ]]; then
        console.error "Command is required"
        return 1
    fi

    echo $(trap | grep "$cmd" | sed -e "s/$'\n'/ ; /g")
}

##
## (Usage) List all registered traps
## Examples:
##   trapper.list
##   trapper.list --module="http"
##
function trapper.list() {
    local module_filter=""

    # Parse options
    for arg in "$@"; do
        case $arg in
        --module=*) module_filter="${arg#*=}" ;;
        *) ;;
        esac
    done

    if [[ -n "$module_filter" ]]; then
        console.info "Traps for module '$module_filter':"
        local module_traps="${MODULE_TRAPS[$module_filter]}"
        if [[ -n "$module_traps" ]]; then
            for trap_cmd in $module_traps; do
                console.info "  $trap_cmd"
            done
        else
            console.info "  No traps registered"
        fi
    else
        console.info "All registered traps:"
        for sig in "${!TRAP_REGISTRY[@]}"; do
            local traps="${TRAP_REGISTRY[$sig]}"
            if [[ -n "$traps" ]]; then
                console.info "  Signal $sig: $traps"
            fi
        done

        console.info ""
        console.info "Module-specific traps:"
        for module in "${!MODULE_TRAPS[@]}"; do
            local module_traps="${MODULE_TRAPS[$module]}"
            console.info "  $module: $module_traps"
        done
    fi
}

##
## (Usage) Clear all traps
## Examples:
##   trapper.clear
##   trapper.clear --module="http"
##
function trapper.clear() {
    local module_filter=""

    # Parse options
    for arg in "$@"; do
        case $arg in
        --module=*) module_filter="${arg#*=}" ;;
        *) ;;
        esac
    done

    if [[ -n "$module_filter" ]]; then
        trapper.removeModuleTraps "$module_filter"
    else
        # Clear all traps
        trap - EXIT INT TERM ERR
        TRAP_REGISTRY=()
        MODULE_TRAPS=()
        console.info "Cleared all traps"
    fi
}

##
## (Usage) Set up default error handling for all modules
## Examples:
##   trapper.setupDefaults
##   trapper.setupDefaults --verbose
##
function trapper.setupDefaults() {
    local verbose=false

    # Parse options
    for arg in "$@"; do
        case $arg in
        --verbose | -v) verbose=true ;;
        *) ;;
        esac
    done

    # Set up common error handling
    trapper.addTrap 'trapper.handleExit' EXIT
    trapper.addTrap 'trapper.handleInterrupt' INT TERM
    trapper.addTrap 'trapper.handleError' ERR

    if [[ "$verbose" == "true" ]]; then
        console.info "Default error handling configured"
    fi
}

##
## (Usage) Handle script exit
##
function trapper.handleExit() {
    local exit_code=$?

    # Run cleanup for all modules
    for module in "${!MODULE_TRAPS[@]}"; do
        local module_traps="${MODULE_TRAPS[$module]}"
        for trap_cmd in $module_traps; do
            if [[ "$trap_cmd" == *"cleanup"* || "$trap_cmd" == *"exit"* ]]; then
                eval "$trap_cmd" 2>/dev/null || true
            fi
        done
    done

    if [[ $exit_code -ne 0 ]]; then
        console.error "Script exited with code: $exit_code"
    fi
}

##
## (Usage) Handle interrupt signals
##
function trapper.handleInterrupt() {
    console.warn "Received interrupt signal, cleaning up..."

    # Run interrupt handlers for all modules
    for module in "${!MODULE_TRAPS[@]}"; do
        local module_traps="${MODULE_TRAPS[$module]}"
        for trap_cmd in $module_traps; do
            if [[ "$trap_cmd" == *"interrupt"* || "$trap_cmd" == *"cleanup"* ]]; then
                eval "$trap_cmd" 2>/dev/null || true
            fi
        done
    done

    exit 1
}

##
## (Usage) Handle errors
##
function trapper.handleError() {
    local exit_code=$?
    local line_number=${BASH_LINENO[0]}
    local script_name=${BASH_SOURCE[1]}

    console.error "Error occurred in $script_name at line $line_number (exit code: $exit_code)"

    # Run error handlers for all modules
    for module in "${!MODULE_TRAPS[@]}"; do
        local module_traps="${MODULE_TRAPS[$module]}"
        for trap_cmd in $module_traps; do
            if [[ "$trap_cmd" == *"error"* || "$trap_cmd" == *"cleanup"* ]]; then
                eval "$trap_cmd" 2>/dev/null || true
            fi
        done
    done
}

##
## (Usage) Create a temporary file/directory with automatic cleanup
## Examples:
##   temp_file=$(trapper.tempFile)
##   temp_dir=$(trapper.tempDir)
##
function trapper.tempFile() {
    local temp_file=$(mktemp)
    trapper.addTrap "rm -f '$temp_file'" EXIT
    echo "$temp_file"
}

function trapper.tempDir() {
    local temp_dir=$(mktemp -d)
    trapper.addTrap "rm -rf '$temp_dir'" EXIT
    echo "$temp_dir"
}

##
## (Usage) Show trapper module help
##
function trapper.help() {
    cat <<EOF
Trapper Module - Comprehensive signal handling and error trapping for all modules

Available Functions:
  trapper.addTrap <cmd> <signals...>      - Add a trap for specific signals
  trapper.addModuleTrap <module> <cmd> <signals...> - Add module-specific trap
  trapper.removeTrap <cmd> <signal>       - Remove a specific trap
  trapper.removeModuleTraps <module>      - Remove all traps for a module
  trapper.getTraps <signal>               - Get current traps for a signal
  trapper.filterTraps <cmd>               - Filter traps by command
  trapper.list [options]                  - List all registered traps
  trapper.clear [options]                 - Clear all traps
  trapper.setupDefaults [options]         - Set up default error handling
  trapper.tempFile                        - Create temporary file with cleanup
  trapper.tempDir                         - Create temporary directory with cleanup
  trapper.help                            - Show this help

Common Signals:
  EXIT  - Script exit (normal or error)
  INT   - Interrupt (Ctrl+C)
  TERM  - Termination request
  ERR   - Error occurred

Options:
  --module=<name>     - Filter by module name (trapper.list, trapper.clear)
  --verbose, -v       - Verbose output (trapper.setupDefaults)

Examples:
  # Basic trap
  trapper.addTrap 'echo "Exiting..."' EXIT

  # Module-specific trap
  trapper.addModuleTrap "http" 'http.cleanup' EXIT
  trapper.addModuleTrap "file" 'file.cleanup_temp' INT TERM

  # Temporary resources with auto-cleanup
  temp_file=\$(trapper.tempFile)
  temp_dir=\$(trapper.tempDir)

  # List and manage traps
  trapper.list
  trapper.list --module="http"
  trapper.removeModuleTraps "file"
  trapper.clear

  # Set up default error handling
  trapper.setupDefaults --verbose
EOF
}

# Module import signal using scoped naming
export BASH_LIB_IMPORTED_trapper="1"
