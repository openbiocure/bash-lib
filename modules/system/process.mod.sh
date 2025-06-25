#!/bin/bash

# Module import signal using scoped naming
export BASH_LIB_IMPORTED_process="1"

# Call import.meta.loaded if the function exists (with error suppression)
if command -v import.meta.loaded >/dev/null 2>&1; then
    import.meta.loaded "process" "${BASH__PATH:-/opt/bash-lib}/modules/system/process.mod.sh" "1.0.0" 2>/dev/null || true
fi

import console

##
## (Usage) returns a list of running processes on the host
##  you can specify -l=10 to return only 10 lines 
##  you can specify --no-log to avoid logging each line
##  you can specify --format=compact|table|default for different output formats
##
## Examples:
##   process.list                    # List all processes with default format
##   process.list -l=10             # List first 10 processes
##   process.list --no-log          # Fast output without logging overhead
##   process.list --format=compact  # Compact format: PID, CPU%, MEM%, COMMAND
##   process.list --format=table    # Table format with proper alignment
##   process.list -l=5 --no-log --format=compact  # Combined options
##
function process.list() {
    local limit=""
    local no_log=false
    local format="default"

    for i in "$@"; do
        case $i in
        -l=* | --limit=*) 
            limit="${i#*=}" 
            ;;
        --no-log) 
            no_log=true 
            ;;
        --format=*) 
            format="${i#*=}" 
            ;;
        *) ;;
        esac
    done

    local list

    if [[ ${limit} ]]; then
        n=${limit}
        t=$(expr ${n} - 1)
        list=$(ps aecux | head -${n} | tail -${t})
        unset limit
    else
        list=$(ps aecux)
    fi

    # If no-log is specified, just output the raw ps output
    if [[ "$no_log" == "true" ]]; then
        echo "$list"
        return 0
    fi

    # For better performance, batch the output
    if [[ "$format" == "compact" ]]; then
        # Compact format: just PID, CPU%, MEM%, COMMAND
        echo "$list" | awk '{printf "%-8s %-6s %-6s %s\n", $2, $3, $4, $11}'
    elif [[ "$format" == "table" ]]; then
        # Table format with headers
        echo "$list" | column -t
    else
        # Default format: output as-is but without individual logging
        echo "$list"
    fi
}

##
## (Usage) Get process count
##
## Examples:
##   process.count                   # Get total number of processes
##   echo "Total processes: $(process.count)"  # Use in scripts
##
function process.count() {
    ps aux | wc -l
}

##
## (Usage) Find processes by name
##
## Examples:
##   process.find ssh               # Find all SSH-related processes
##   process.find nginx             # Find nginx processes
##   process.find python            # Find Python processes
##   process.find "docker"          # Find Docker processes
##
function process.find() {
    local process_name="$1"
    if [[ -z "$process_name" ]]; then
        console.error "Process name is required"
        return 1
    fi
    
    ps aux | grep -i "$process_name" | grep -v grep
}

##
## (Usage) Get top processes by CPU usage
##
## Examples:
##   process.top_cpu                # Top 10 processes by CPU usage
##   process.top_cpu 5              # Top 5 processes by CPU usage
##   process.top_cpu 20             # Top 20 processes by CPU usage
##
function process.top_cpu() {
    local limit="${1:-10}"
    ps aux --sort=-%cpu | head -n $((limit + 1))
}

##
## (Usage) Get top processes by memory usage
##
## Examples:
##   process.top_mem                # Top 10 processes by memory usage
##   process.top_mem 5              # Top 5 processes by memory usage
##   process.top_mem 15             # Top 15 processes by memory usage
##
function process.top_mem() {
    local limit="${1:-10}"
    ps aux --sort=-%mem | head -n $((limit + 1))
}

##
## (Usage) Show process module help
##
function process.help() {
    cat <<EOF
Process Module - Process management and monitoring utilities

Available Functions:
  process.list [options]           - List running processes
  process.count                    - Get total process count
  process.find <name>              - Find processes by name
  process.top_cpu [limit]          - Top processes by CPU usage
  process.top_mem [limit]          - Top processes by memory usage
  process.help                     - Show this help

List Options:
  -l=<number>, --limit=<number>    - Limit number of processes shown
  --no-log                         - Fast output without logging overhead
  --format=<format>                - Output format (compact|table|default)

Examples:
  process.list                     # List all processes
  process.list -l=10              # List first 10 processes
  process.list --no-log --format=compact  # Fast compact output
  process.count                    # Get total process count
  process.find ssh                 # Find SSH processes
  process.top_cpu 5                # Top 5 CPU-intensive processes
  process.top_mem 10               # Top 10 memory-intensive processes
EOF
}
