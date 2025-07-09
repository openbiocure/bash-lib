#!/bin/bash

# Console Module for bash-lib (Modern, Robust, Test-Friendly)
# Provides structured logging with color, verbosity, and safe output

[[ "${BASH__VERBOSE:-}" == "debug" || "${BASH__VERBOSE:-}" == "trace" ]] && printf "DEBUG: console.mod.sh starting\n"

# Call import.meta.loaded if the function exists
if command -v import.meta.loaded >/dev/null 2>&1; then
    [[ "${BASH__VERBOSE:-}" == "debug" || "${BASH__VERBOSE:-}" == "trace" ]] && printf "DEBUG: console.mod.sh calling import.meta.loaded\n"
    import.meta.loaded "console" "${BASH__PATH:-/opt/bash-lib}/modules/system/console.mod.sh" "1.0.0" 2>/dev/null || true
    [[ "${BASH__VERBOSE:-}" == "debug" || "${BASH__VERBOSE:-}" == "trace" ]] && printf "DEBUG: console.mod.sh import.meta.loaded completed\n"
fi

# Import color definitions
source "${BASH__PATH:-/opt/bash-lib}/lib/config/colors.inc"
[[ "${BASH__VERBOSE:-}" == "debug" || "${BASH__VERBOSE:-}" == "trace" ]] && printf "DEBUG: console.mod.sh colors.inc sourced\n"

# Configuration
__CONSOLE__TIME__FORMAT="+%d/%m/%Y %H:%M:%S"
__CONSOLE__DEFAULT_VERBOSITY="info"
__CONSOLE__OUTPUT="" # Can be: stdout, stderr, /dev/null, or a file

# Log level mapping (lowest to highest)
# Use associative arrays if available (bash 4.0+), otherwise use regular arrays
if [[ "${BASH_VERSINFO[0]:-0}" -ge 4 ]]; then
declare -gA __CONSOLE__LEVELS
__CONSOLE__LEVELS=(
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
declare -gA __CONSOLE__COLORS
__CONSOLE__COLORS=(
    [trace]="$BYellow"
    [debug]="$BCyan"
    [info]="$Color_Off"
    [warn]="$BYellow"
    [error]="$BRed"
    [fatal]="$BRed"
    [success]="$BGreen"
    [log]="$Color_Off"
)
else
    # Fallback for older bash versions - use regular arrays
    __CONSOLE__LEVELS_trace=0
    __CONSOLE__LEVELS_debug=1
    __CONSOLE__LEVELS_info=2
    __CONSOLE__LEVELS_warn=3
    __CONSOLE__LEVELS_error=4
    __CONSOLE__LEVELS_fatal=5
    __CONSOLE__LEVELS_success=6
    __CONSOLE__LEVELS_log=7

    __CONSOLE__COLORS_trace="$BYellow"
    __CONSOLE__COLORS_debug="$BCyan"
    __CONSOLE__COLORS_info="$Color_Off"
    __CONSOLE__COLORS_warn="$BYellow"
    __CONSOLE__COLORS_error="$BRed"
    __CONSOLE__COLORS_fatal="$BRed"
    __CONSOLE__COLORS_success="$BGreen"
    __CONSOLE__COLORS_log="$Color_Off"
fi

# Output stream selector
__console__output_stream() {
    local log_type="$1"

    # Per-level output configuration
    case "$log_type" in
        error|fatal|warn)
            # Error and warning messages go to stderr by default
            if [[ "$__CONSOLE__OUTPUT" == "stdout" ]]; then
                echo
            elif [[ -n "$__CONSOLE__OUTPUT" && "$__CONSOLE__OUTPUT" != "stderr" ]]; then
                printf '%s\n' ">> $__CONSOLE__OUTPUT"
            else
                printf '%s\n' ">&2"
            fi
            ;;
        *)
            # Info, debug, trace, success, log go to stdout by default
            if [[ "$__CONSOLE__OUTPUT" == "stderr" ]]; then
                printf '%s\n' ">&2"
            elif [[ -n "$__CONSOLE__OUTPUT" && "$__CONSOLE__OUTPUT" != "stdout" ]]; then
                printf '%s\n' ">> $__CONSOLE__OUTPUT"
            else
                echo
            fi
            ;;
    esac
}

# Get numeric value for a log level
__console__level_value() {
    local level
    if [[ "${BASH_VERSINFO[0]:-0}" -ge 4 ]]; then
        level="${1,,}"
    printf "%d" "${__CONSOLE__LEVELS[$level]:-2}"
    else
        # Fallback for older bash versions - convert to lowercase manually
        level=$(printf "%s" "$1" | tr '[:upper:]' '[:lower:]')
        local var_name="__CONSOLE__LEVELS_${level}"
        printf "%d" "${!var_name:-2}"
    fi
}

# Should log this level?
__console__should_log() {
    local requested="$1"
    local current="${BASH__VERBOSE:-$__CONSOLE__DEFAULT_VERBOSITY}"

    # Error and fatal messages should always be shown
    if [[ "$requested" == "error" || "$requested" == "fatal" ]]; then
        return 0
    fi

    local req_val=$(__console__level_value "$requested")
    local cur_val=$(__console__level_value "$current")

    # Only log if requested level is >= current verbosity level
    [[ $req_val -ge $cur_val ]]
}

# Core logging function
__console__log() {
    local log_type
    if [[ "${BASH_VERSINFO[0]:-0}" -ge 4 ]]; then
        log_type="${1,,}"
    else
        # Fallback for older bash versions - convert to lowercase manually
        log_type=$(printf "%s" "$1" | tr '[:upper:]' '[:lower:]')
    fi
    shift
    local message="$*"
    local color
    local color_off="$Color_Off"

    if [[ "${BASH_VERSINFO[0]:-0}" -ge 4 ]]; then
        color="${__CONSOLE__COLORS[$log_type]:-$Color_Off}"
    else
        # Fallback for older bash versions
        local color_var_name="__CONSOLE__COLORS_${log_type}"
        color="${!color_var_name:-$Color_Off}"
    fi

    # Skip color codes if BASH_LIB_TEST is set (original request)
    if [[ -n "${BASH_LIB_TEST:-}" ]]; then
        color=""
        color_off=""
    fi

    local log_date=$(date "$__CONSOLE__TIME__FORMAT")
    local host_name=$(hostname)
    local script_name=$(basename "$0" 2>/dev/null || printf "bash")
    local log_type_upper
    if [[ "${BASH_VERSINFO[0]:-0}" -ge 4 ]]; then
        log_type_upper="${log_type^^}"
    else
        # Fallback for older bash versions - convert to uppercase manually
        log_type_upper=$(printf "%s" "$log_type" | tr '[:lower:]' '[:upper:]')
    fi
    local template="${color}${log_date} - ${host_name} - ${script_name} - [${log_type_upper}]:${color_off}"
    local out_stream=$(__console__output_stream "$log_type")

    __console__should_log "$log_type" || return 0

    # Output safely using printf (no broken pipe)
    case "$out_stream" in
        '>&2') printf "%b %s\n" "$template" "$message" >&2 ;;
        '')    printf "%b %s\n" "$template" "$message" ;;
        'echo') printf "%b %s\n" "$template" "$message" ;;
        '>> '*) printf "%b %s\n" "$template" "$message" >> "${out_stream#>> }" ;;
        *)     printf "%b %s\n" "$template" "$message" ;;
    esac
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
console.print() {
    local force_output=""
    local msg=""
    if [[ "${@: -1}" == "force" ]]; then
        force_output="force"
        msg="${*:1:$(($# - 1))}"
    else
        msg="$*"
    fi
    if [[ "$force_output" == "force" ]]; then
        printf "%s" "$msg"
    else
        printf "%s" "$msg"
    fi
}

console.println() { printf "%s\n" "$*"; }
console.print_error() { printf "%s" "$*" >&2; }
console.println_error() { printf "%s\n" "$*" >&2; }
console.empty() { printf ""; }

# Verbosity control
console.set_verbosity() {
    local level
    if [[ "${BASH_VERSINFO[0]:-0}" -ge 4 ]]; then
        level="${1,,}"
    else
        # Fallback for older bash versions - convert to lowercase manually
        level=$(printf "%s" "$1" | tr '[:upper:]' '[:lower:]')
    fi

    if [[ "${BASH_VERSINFO[0]:-0}" -ge 4 ]]; then
    # Workaround: re-declare the array if empty (for test/subshell issues)
        if [[ -z "${__CONSOLE__LEVELS[debug]:-isset}" ]]; then
        declare -gA __CONSOLE__LEVELS=(
            [trace]=0
            [debug]=1
            [info]=2
            [warn]=3
            [error]=4
            [fatal]=5
            [success]=6
            [log]=7
        )
    fi

        if [[ -n "${__CONSOLE__LEVELS[$level]:-}" ]]; then
            export BASH__VERBOSE="$level"
            # Only log if debug level is allowed
            if __console__should_log "debug"; then
                console.debug "Verbosity set to: $level"
            fi
        else
            printf "Invalid verbosity level: %s\n" "$level" >&2
            return 1
        fi
    else
        # Fallback for older bash versions
        local var_name="__CONSOLE__LEVELS_${level}"
        if [[ -n "${!var_name:-}" ]]; then
        export BASH__VERBOSE="$level"
        # Only log if debug level is allowed
        if __console__should_log "debug"; then
            console.debug "Verbosity set to: $level"
        fi
    else
        printf "Invalid verbosity level: %s\n" "$level" >&2
        return 1
        fi
    fi
}
console.get_verbosity() {
    printf "%s" "${BASH__VERBOSE:-$__CONSOLE__DEFAULT_VERBOSITY}"
}

# Output control
console.set_output() {
    local out="$1"
    if [[ "$out" == "stdout" || "$out" == "stderr" || "$out" == "/dev/null" ]]; then
        __CONSOLE__OUTPUT="$out"
        # Only log if debug level is allowed
        if __console__should_log "debug"; then
            console.debug "Console output set to: $out"
        fi
    else
        printf "Invalid output: %s\n" "$out" >&2
        return 1
    fi
}
console.get_output() {
    printf "%s" "$__CONSOLE__OUTPUT"
}

console.set_time_format() {
    if [[ -n "$1" ]]; then
        __CONSOLE__TIME__FORMAT="$1"
        # Only log if debug level is allowed
        if __console__should_log "debug"; then
        console.debug "Time format set to: $1"
        fi
    else
        printf "No time format specified\n" >&2
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
  BASH_LIB_TEST      - If set, colors are disabled

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
