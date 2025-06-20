#!/bin/bash

# Console Module for bash-lib
# Provides structured logging functionality with color support and verbosity control

exec 3>&1

IMPORTED="."

import "colors" "inc"

# Configuration
__CONSOLE__TIME__FORMAT="+%d/%m/%Y %H:%M:%S"
__CONSOLE__DEFAULT_VERBOSITY="trace"

# Shell detection
__console__detect_shell() {
    if [[ -n "$ZSH_VERSION" ]]; then
        echo "zsh"
    elif [[ -n "$BASH_VERSION" ]]; then
        echo "bash"
    else
        echo "unknown"
    fi
}

# Get current script name
__console__get_script_name() {
    local shell_name=$(__console__detect_shell)
    
    case $shell_name in
        "zsh")
            echo "${(%):-%N}"
            ;;
        "bash")
            if [[ -n "$0" ]]; then
                basename "$0" 2>/dev/null || echo "bash"
            else
                echo "bash"
            fi
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Get source file name for logging
__console__get_source_file() {
    local shell_name=$(__console__detect_shell)
    
    case $shell_name in
        "bash")
            if command -v caller >/dev/null 2>&1; then
                caller 0 2>/dev/null | awk '{print $2}' | head -1 | xargs basename 2>/dev/null || echo "bash"
            else
                echo "bash"
            fi
            ;;
        "zsh")
            echo "${(%):-%N}"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Check if log should be displayed based on verbosity
__console__should_log() {
    local requested_log_type="$1"
    local verbose="${BASH__VERBOSE:-$__CONSOLE__DEFAULT_VERBOSITY}"
    
    # Convert to lowercase for comparison
    verbose=$(echo "$verbose" | tr '[:upper:]' '[:lower:]')
    requested_log_type=$(echo "$requested_log_type" | tr '[:upper:]' '[:lower:]')
    
    # Always log these types
    case $requested_log_type in
        log|fatal|warn|error|success)
            return 0
            ;;
    esac
    
    # Check verbosity for these types
    case $requested_log_type in
        trace|debug|info)
            if [[ "$verbose" == "trace" ]] || [[ "$verbose" == "$requested_log_type" ]]; then
                return 0
            fi
            ;;
    esac
    
    return 1
}

# Core logging function
__console__log() {
    local log_type="$1"
    local color="$2"
    local message="$3"
    local line_no="$4"
    
    # Check if we should log this message
    if ! __console__should_log "$log_type"; then
        return 0
    fi
    
    # Get logging metadata
    local log_date=$(date "$__CONSOLE__TIME__FORMAT")
    local host_name=$(hostname)
    local script=$(__console__get_script_name)
    local source_file=$(__console__get_source_file)
    local color_off="${Color_Off}"
    
    # Build log template
    local template="${color}${log_date} - ${host_name} - ${script} - [${log_type}]:${color_off}"
    
    # Output the log message to stdout for better test compatibility
    echo -e "${template} ${message}"
}

# Public logging functions
console.log() {
    local message="$*"
    local line_no=$LINENO
    
    __console__log "LOG" "${Color_Off}" "$message" "$line_no"
}

console.info() {
    local message="$*"
    local line_no=$LINENO
    
    __console__log "INFO" "${Color_Off}" "$message" "$line_no"
}

console.debug() {
    local message="$*"
    local line_no=$LINENO
    
    __console__log "DEBUG" "${BCyan}" "$message" "$line_no"
}

console.trace() {
    local message="$*"
    local line_no=$LINENO
    
    __console__log "TRACE" "${BYellow}" "$message" "$line_no"
}

console.warn() {
    local message="$*"
    local line_no=$LINENO
    
    __console__log "WARN" "${BYellow}" "$message" "$line_no"
}

console.error() {
    local message="$*"
    local line_no=$LINENO
    
    __console__log "ERROR" "${BRed}" "$message" "$line_no"
}

console.fatal() {
    local message="$*"
    local line_no=$LINENO
    
    __console__log "FATAL" "${BRed}" "$message" "$line_no"
}

console.success() {
    local message="$*"
    local line_no=$LINENO

    __console__log "SUCCESS" "${BGreen}" "$message" "$line_no"
}

# Utility functions
console.set_verbosity() {
    if [[ -n "$1" ]]; then
        export BASH__VERBOSE="$1"
        console.debug "Verbosity set to: $1"
    else
        console.error "No verbosity level specified"
        return 1
    fi
}

console.get_verbosity() {
    echo "${BASH__VERBOSE:-$__CONSOLE__DEFAULT_VERBOSITY}"
}

console.set_time_format() {
    if [[ -n "$1" ]]; then
        __CONSOLE__TIME__FORMAT="$1"
        console.debug "Time format set to: $1"
    else
        console.error "No time format specified"
        return 1
    fi
}

# Help function
console.help() {
    cat <<EOF
Console Module - Structured Logging for bash-lib

Available Functions:
  console.log <message>     - Log a message with [LOG] identifier
  console.info <message>    - Log an info message with [INFO] identifier
  console.debug <message>   - Log a debug message with [DEBUG] identifier
  console.trace <message>   - Log a trace message with [TRACE] identifier
  console.warn <message>    - Log a warning message with [WARN] identifier
  console.error <message>   - Log an error message with [ERROR] identifier
  console.fatal <message>   - Log a fatal message with [FATAL] identifier
  console.success <message> - Log a success message with [SUCCESS] identifier

Utility Functions:
  console.set_verbosity <level>  - Set logging verbosity (trace|debug|info|warn|error|fatal)
  console.get_verbosity          - Get current verbosity level
  console.set_time_format <fmt>  - Set custom time format (date format string)
  console.help                   - Show this help message

Verbosity Levels:
  trace  - Show all log messages (default)
  debug  - Show debug and above
  info   - Show info and above
  warn   - Show warnings and above
  error  - Show errors and above
  fatal  - Show only fatal messages

Examples:
  console.log "Application started"
  console.set_verbosity debug
  console.debug "Processing user input"
  console.error "Failed to connect to database"
EOF
}