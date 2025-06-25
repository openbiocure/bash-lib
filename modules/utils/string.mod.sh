#!/bin/bash

# String Module for bash-lib
# Provides string manipulation and utility functions

# Module import signal using scoped naming
export BASH_LIB_IMPORTED_string="1"

# Call import.meta.loaded if the function exists
if command -v import.meta.loaded >/dev/null 2>&1; then
    import.meta.loaded "string" "${BASH__PATH:-/opt/bash-lib}/modules/utils/string.mod.sh" "1.0.0" 2>/dev/null || true
fi

import console

#
# (Usage)
#   Checks if a paticular string is empty returns true; false otherwise    
#
function string.isEmpty() {
    [[ -z $1 ]] && echo true || echo false;
}

#
# (Usage)
#   Replaces a character with another character if matched in the input string
#
function string.replace (){
    local replace=$1;
    local with=$2;
    local str=$3;

    echo ${str//$1/$2};
}

#
# (Usage)
#   Get the length of a string
#
function string.length() {
    local str="$1"
    echo "${#str}"
}

#
# (Usage)
#   Convert a string to lowercase
#
function string.lower() {
    local str="$1"
    echo "${str,,}"
}

#
# (Usage)
#   Convert a string to uppercase
#
function string.upper() {
    local str="$1"
    echo "${str^^}"
}

#
# (Usage)
#   Trim leading and trailing whitespace
#
function string.trim() {
    local str="$1"
    # Remove leading and trailing whitespace
    echo "$str" | awk '{gsub(/^ +| +$/,"",$0); print}'
}

#
# (Usage)
#   Check if a string contains a substring
#
function string.contains() {
    local str="$1"
    local substr="$2"
    [[ "$str" == *"$substr"* ]] && echo true || echo false
}

#
# (Usage)
#   Check if a string starts with a prefix
#
function string.startswith() {
    local str="$1"
    local prefix="$2"
    [[ "$str" == "$prefix"* ]] && echo true || echo false
}

#
# (Usage)
#   Check if a string ends with a suffix
#
function string.endswith() {
    local str="$1"
    local suffix="$2"
    [[ "$str" == *"$suffix" ]] && echo true || echo false
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
EOF
}