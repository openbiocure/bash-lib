#!/bin/bash

IMPORTED="."

import console

function date.now(){
    local log_date=$(date)
    console.trace $log_date
    echo $log_date
}

##
## (Usage) Show date module help
##
function date.help() {
    cat <<EOF
Date Module - Date and time utilities

Available Functions:
  date.now                    - Get current date and time
  date.help                   - Show this help

Examples:
  date.now                    # Get current date/time
  current_time=\$(date.now)    # Store in variable
EOF
}

