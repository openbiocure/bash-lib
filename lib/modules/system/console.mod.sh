#!/bin/bash

# Console Module for bash-lib (Modern, Robust, Test-Friendly)
# Provides structured logging with color, verbosity, and safe output

# Call import.meta.loaded if the function exists
if command -v import.meta.loaded >/dev/null 2>&1; then
    import.meta.loaded "console" "${BASH__PATH:-/opt/bash-lib}/lib/modules/system/console.mod.sh" "1.0.0" 2>/dev/null || true
fi

# Import color definitions
import "colors" "inc"

# Configuration
__CONSOLE__TIME__FORMAT="+%d/%m/%Y %H:%M:%S"
__CONSOLE__DEFAULT_VERBOSITY="info"
__CONSOLE__OUTPUT="stdout" # Can be: stdout, stderr, /dev/null, or a file

# Log level mapping (lowest to highest)
declare -A __CONSOLE__LEVELS=(
    [trace]=0
    [debug]=1
    [info]=2
    [warn]=3
    [error]=4
    [fatal]=5
    [success]=6
    [log]=7
)

# Color mapping for log types
declare -A __CONSOLE__COLORS=(
    [trace]="$BYellow"
    [debug]="$BCyan"
    [info]="$Color_Off"
    [warn]="$BYellow"
    [error]="$BRed"
    [fatal]="$BRed"
    [success]="$BGreen"
    [log]="$Color_Off"
)

# Output stream selector
__console__output_stream() {
    if [[ -n "$BASH_LIB_TEST" ]]; then
        echo "/dev/null"
    elif [[ "$__CONSOLE__OUTPUT" == "stderr" ]]; then
        echo ">&2"
    elif [[ "$__CONSOLE__OUTPUT" == "stdout" ]]; then
        echo
    else
        echo ">> $__CONSOLE__OUTPUT"
    fi
}

# Get numeric value for a log level
__console__level_value() {
    local level="${1,,}"
    printf "%d" "${__CONSOLE__LEVELS[$level]:-2}"
}

# Should log this level?
__console__should_log() {
    local requested="$1"
    local current="${BASH__VERBOSE:-$__CONSOLE__DEFAULT_VERBOSITY}"
    local req_val=$(__console__level_value "$requested")
    local cur_val=$(__console__level_value "$current")

    # Only log if requested level is >= current verbosity level
    [[ $req_val -ge $cur_val ]]
}

# Core logging function
__console__log() {
    local log_type="${1,,}"
    shift
    local message="$*"
    local color="${__CONSOLE__COLORS[$log_type]:-$Color_Off}"
    local color_off="$Color_Off"
    local log_date=$(date "$__CONSOLE__TIME__FORMAT")
    local host_name=$(hostname)
    local script_name=$(basename "$0" 2>/dev/null || printf "bash")
    local template="${color}${log_date} - ${host_name} - ${script_name} - [${log_type^^}]:${color_off}"
    local out_stream=$(__console__output_stream)

    __console__should_log "$log_type" || return 0

    # Output safely using printf (no broken pipe)
    if [[ -z "$out_stream" ]]; then
        printf "%b %s\n" "$template" "$message" 2>/dev/null || true
    else
        eval "printf \"%b %s\\n\" \"$template\" \"$message\" $out_stream" 2>/dev/null || true
    fi
}

# Public API
console.log() { __console__log log "$@"; }
console.info() { __console__log info "$@"; }
console.debug() { __console__log debug "$@"; }
console.trace() { __console__log trace "$@"; }
console.warn() { __console__log warn "$@"; }
console.error() { __console__log error "$@"; }
console.fatal() { __console__log fatal "$@"; }
console.success() { __console__log success "$@"; }

# Simple output functions (no formatting, no colors)
console.print() { printf "%s" "$*"; }
console.println() { printf "%s\n" "$*"; }
console.print_error() { printf "%s" "$*" >&2; }
console.println_error() { printf "%s\n" "$*" >&2; }
console.empty() { printf ""; }

# Verbosity control
console.set_verbosity() {
    local level="${1,,}"
    if [[ -n "${__CONSOLE__LEVELS[$level]}" ]]; then
        export BASH__VERBOSE="$level"
        console.debug "Verbosity set to: $level"
    else
        console.error "Invalid verbosity level: $level"
        return 1
    fi
}
console.get_verbosity() {
    printf "%s" "${BASH__VERBOSE:-$__CONSOLE__DEFAULT_VERBOSITY}"
}

# Output control
console.set_output() {
    local out="$1"
    if [[ "$out" == "stdout" || "$out" == "stderr" || "$out" == "/dev/null" || -n "$out" ]]; then
        __CONSOLE__OUTPUT="$out"
        console.debug "Console output set to: $out"
    else
        console.error "Invalid output: $out"
        return 1
    fi
}
console.get_output() {
    printf "%s" "$__CONSOLE__OUTPUT"
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

console.help() {
    cat <<EOF
Console Module - Structured Logging for bash-lib

Available Functions:
  console.log <msg>      - Log a message
  console.info <msg>     - Info message
  console.debug <msg>    - Debug message
  console.trace <msg>    - Trace message
  console.warn <msg>     - Warning message
  console.error <msg>    - Error message
  console.fatal <msg>    - Fatal message
  console.success <msg>  - Success message
  console.print <msg>    - Print without newline
  console.println <msg>  - Print with newline
  console.print_error <msg>  - Print to stderr without newline
  console.println_error <msg> - Print to stderr with newline
  console.set_verbosity <level> - Set verbosity (trace|debug|info|warn|error|fatal|success|log)
  console.get_verbosity         - Get current verbosity
  console.set_output <target>   - Set output (stdout|stderr|/dev/null|file)
  console.get_output            - Get current output
  console.set_time_format <fmt> - Set time format
  console.help                  - Show this help

Environment:
  BASH__VERBOSE      - Current verbosity
  BASH_LIB_TEST      - If set, all logs go to /dev/null

Examples:
  console.info "App started"
  console.println "Simple output"
  console.set_verbosity debug
  console.set_output /tmp/mylog.txt
  console.set_time_format "+%Y-%m-%d %H:%M:%S"
EOF
}

# Module import signal using scoped naming
export BASH_LIB_IMPORTED_console="1"
