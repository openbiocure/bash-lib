#!/bin/bash

# Math Module for bash-lib
# Provides mathematical operations and utilities

# Call import.meta.loaded if the function exists
if command -v import.meta.loaded >/dev/null 2>&1; then
  import.meta.loaded "math" "${BASH__PATH:-/opt/bash-lib}/lib/modules/math/math.mod.sh" "1.0.0" 2>/dev/null || true
fi

import console
import mathExceptions

#
# (Usage)
#   adds to inputs e.g. math.add 1 2
#   Output
#        3
#
function math.add() {
  [[ $(math.__isNumber $1) == true && $(math.__isNumber $2) == true ]] && echo $(($1 + $2)) || math.exception.arithmeticComputation
}

#
# (Usage)
#   Checks if an input is a digit
#
function math.__isNumber() {
  [[ -n $1 && $1 != *[^[:digit:]]* ]] && echo true || echo false
}

##
## (Usage) Show math module help
##
function math.help() {
  cat <<EOF
Math Module - Mathematical operations and utilities

Available Functions:
  math.add <num1> <num2>            - Add two numbers
  math.help                          - Show this help

Examples:
  math.add 5 3                       # Returns 8
  math.add 10 20                     # Returns 30
  result=\$(math.add 15 25)          # Store result in variable
EOF
}

# Module import signal using scoped naming
export BASH_LIB_IMPORTED_math="1"
