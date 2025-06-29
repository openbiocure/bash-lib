#!/bin/bash

# Date Module for bash-lib
# Provides date and time utilities

# Module import signal using scoped naming
export BASH_LIB_IMPORTED_date="1"

# Call import.meta.loaded if the function exists
if command -v import.meta.loaded >/dev/null 2>&1; then
    import.meta.loaded "date" "${BASH__PATH:-/opt/bash-lib}/modules/date/date.mod.sh" "1.0.0" 2>/dev/null || true
fi

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

