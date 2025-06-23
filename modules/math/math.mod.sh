#!/bin/bash

IMPORTED="."

import mathExceptions;

#
# (Usage)
#   adds to inputs e.g. math.add 1 2
#   Output
#        3
#
function math.add() {
    [[ $(math.__isNumber $1) == true && $(math.__isNumber $2) == true ]] && echo $(($1 + $2)) || math.exception.arithmeticComputation;
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
