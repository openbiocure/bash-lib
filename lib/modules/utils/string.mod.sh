#!/bin/bash

# String Module for bash-lib
# Provides string manipulation and utility functions

# Call import.meta.loaded if the function exists
if command -v import.meta.loaded >/dev/null 2>&1; then
    import.meta.loaded "string" "${BASH__PATH:-/opt/bash-lib}/lib/modules/utils/string.mod.sh" "1.0.0" 2>/dev/null || true
fi

import console

#
# (Usage)
#   Checks if a paticular string is empty returns true; false otherwise
#
function string.isEmpty() {
    [[ -z $1 ]] && printf true || printf false
}

#
# (Usage)
#   Replaces a character with another character if matched in the input string
#
function string.replace() {
    local replace=$1
    local with=$2
    local str=$3

    printf "%s" "${str//$1/$2}"
}

#
# (Usage)
#   Get the length of a string
#
function string.length() {
    local str="$1"
    printf "%d" "${#str}"
}

#
# (Usage)
#   Convert a string to lowercase
#
function string.lower() {
    local str="$1"
    printf "%s" "$str" | tr '[:upper:]' '[:lower:]'
}

#
# (Usage)
#   Convert a string to uppercase
#
function string.upper() {
    local str="$1"
    printf "%s" "$str" | tr '[:lower:]' '[:upper:]'
}

#
# (Usage)
#   Trim leading and trailing whitespace
#
function string.trim() {
    local str="$1"
    # Remove leading and trailing whitespace
    printf "%s" "$str" | awk '{gsub(/^ +| +$/,"",$0); print}'
}

#
# (Usage)
#   Check if a string contains a substring
#
function string.contains() {
    local str="$1"
    local substr="$2"
    [[ "$str" == *"$substr"* ]] && printf true || printf false
}

#
# (Usage)
#   Check if a string starts with a prefix
#
function string.startswith() {
    local str="$1"
    local prefix="$2"
    [[ "$str" == "$prefix"* ]] && printf true || printf false
}

#
# (Usage)
#   Check if a string ends with a suffix
#
function string.endswith() {
    local str="$1"
    local suffix="$2"
    [[ "$str" == *"$suffix" ]] && printf true || printf false
}

#
# (Usage)
#   Get the basename of a path (filename without directory)
#
function string.basename() {
    local path="$1"
    printf "%s" "${path##*/}"
}

#
# string.render: Render a template string or file with environment variables
# Usage:
#   string.render "Hello $USER"
#   string.render --file template.txt
#   string.render --file template.txt --out output.txt
#   string.render --strict "Hello $UNSET_VAR"
#   string.render --strict --file template.txt
#
function string.render() {
    local input=""
    local file=""
    local out=""
    local strict=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
        --file)
            file="$2"
            shift 2
            ;;
        --out)
            out="$2"
            shift 2
            ;;
        --strict)
            strict=true
            shift
            ;;
        --help)
            echo "Usage: string.render [--file <file>] [--out <file>] [--strict] <template>"
            return 0
            ;;
        *)
            if [[ -z "$input" ]]; then
                input="$1"
                shift
            else
                shift
            fi
            ;;
        esac
    done

    # Read input
    local template=""
    if [[ -n "$file" ]]; then
        if [[ ! -f "$file" ]]; then
            echo "string.render: file not found: $file" >&2
            return 1
        fi
        template="$(cat "$file")"
    else
        template="$input"
    fi

    # Strict mode: check for unset variables
    if [[ "$strict" == true ]]; then
        # Find all ${VAR} and $VAR patterns
        local missing_vars=()
        local var_regex='\$\{?([A-Za-z_][A-Za-z0-9_]*)\}?'
        while read -r var; do
            if [[ -z "${!var+x}" ]]; then
                missing_vars+=("$var")
            fi
        done < <(echo "$template" | grep -oE '\$\{?[A-Za-z_][A-Za-z0-9_]*\}?')
        if [[ ${#missing_vars[@]:-0} -gt 0 ]]; then
            echo "string.render: missing variables: ${missing_vars[*]:-}" >&2
            return 1
        fi
    fi

    # Render using envsubst if available, else Bash eval
    local rendered=""
    if command -v envsubst >/dev/null 2>&1; then
        rendered="$(echo "$template" | envsubst)"
    else
        # Use Bash parameter expansion
        rendered="$(eval "echo \"$template\"")"
    fi

    # Output
    if [[ -n "$out" ]]; then
        echo "$rendered" >"$out"
    else
        echo "$rendered"
    fi
}

##
## (Usage) Show string module help
##
function string.help() {
    cat <<EOF
String Module - String manipulation utilities

Available Functions:
  string.isEmpty <string>              - Check if string is empty
  string.replace <old> <new> <str>     - Replace characters in string
  string.length <str>                  - Get length of string
  string.lower <str>                   - Convert string to lowercase
  string.upper <str>                   - Convert string to uppercase
  string.trim <str>                    - Trim leading/trailing whitespace
  string.contains <str> <substr>       - Check if string contains substring
  string.startswith <str> <prefix>     - Check if string starts with prefix
  string.endswith <str> <suffix>       - Check if string ends with suffix
  string.basename <path>                - Get the basename of a path
  string.render <template>               - Render a template string or file
  string.help                          - Show this help

Examples:
  string.isEmpty ""                     # Returns true
  string.length "hello"                 # Returns 5
  string.lower "HELLO"                  # Returns hello
  string.upper "hello"                  # Returns HELLO
  string.trim "  hello  "                # Returns hello
  string.contains "hello world" "wor"   # Returns true
  string.startswith "foobar" "foo"      # Returns true
  string.endswith "foobar" "bar"        # Returns true
  string.replace "a" "b" "cat"         # Returns cbt
  string.basename "/path/to/file.txt"  # Returns file.txt
  string.render "Hello $USER"
  string.render --file template.txt
  string.render --file template.txt --out output.txt
  string.render --strict "Hello $UNSET_VAR"
  string.render --strict --file template.txt
EOF
}

# Module import signal using scoped naming
export BASH_LIB_IMPORTED_string="1"
