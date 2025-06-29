#!/bin/bash

# Call import.meta.loaded if the function exists
if command -v import.meta.loaded >/dev/null 2>&1; then
    import.meta.loaded "process" "${BASH__PATH:-/opt/bash-lib}/lib/modules/system/process.mod.sh" "1.0.0" 2>/dev/null || true
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
## (Usage) Run a command with various options
##
## Options:
##   --timeout=<seconds>     - Set timeout in seconds (default: no timeout)
##   --capture-output        - Capture and return command output
##   --retries=<number>      - Number of retry attempts (default: 1)
##   --dry-run              - Show what would be executed without running
##   --silent               - Suppress command output (except errors)
##   --verbose              - Show detailed execution information
##
## Examples:
##   process.run "apt-get update" --timeout=300
##   process.run "docker build ." --capture-output
##   process.run "curl example.com" --retries=3
##   process.run "rm -rf /tmp/*" --dry-run
##   process.run "ls -la" --silent
##   process.run "echo 'test'" --verbose
##
function process.run() {
    local command=""
    local timeout=""
    local capture_output=false
    local retries=1
    local dry_run=false
    local silent=false
    local verbose=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
        --timeout=*)
            timeout="${1#*=}"
            shift
            ;;
        --capture-output)
            capture_output=true
            shift
            ;;
        --retries=*)
            retries="${1#*=}"
            shift
            ;;
        --dry-run)
            dry_run=true
            shift
            ;;
        --silent)
            silent=true
            shift
            ;;
        --verbose)
            verbose=true
            shift
            ;;
        -*)
            console.error "Unknown option: $1"
            return 1
            ;;
        *)
            if [[ -z "$command" ]]; then
                command="$1"
            else
                command="$command $1"
            fi
            shift
            ;;
        esac
    done

    # Validate command
    if [[ -z "$command" ]]; then
        console.error "No command specified"
        return 1
    fi

    # Validate timeout
    if [[ -n "$timeout" ]] && ! [[ "$timeout" =~ ^[0-9]+$ ]]; then
        console.error "Timeout must be a positive integer"
        return 1
    fi

    # Validate retries
    if ! [[ "$retries" =~ ^[0-9]+$ ]] || [[ "$retries" -lt 1 ]]; then
        console.error "Retries must be a positive integer"
        return 1
    fi

    # Show dry run information
    if [[ "$dry_run" == "true" ]]; then
        console.info "DRY RUN: Would execute: $command"
        if [[ -n "$timeout" ]]; then
            console.info "DRY RUN: With timeout: ${timeout}s"
        fi
        if [[ "$retries" -gt 1 ]]; then
            console.info "DRY RUN: With retries: $retries"
        fi
        if [[ "$capture_output" == "true" ]]; then
            console.info "DRY RUN: Would capture output"
        fi
        if [[ "$silent" == "true" ]]; then
            console.info "DRY RUN: Would run silently"
        fi
        return 0
    fi

    # Show verbose information
    if [[ "$verbose" == "true" ]]; then
        console.debug "Executing command: $command"
        if [[ -n "$timeout" ]]; then
            console.debug "Timeout set to: ${timeout}s"
        fi
        if [[ "$retries" -gt 1 ]]; then
            console.debug "Retry attempts: $retries"
        fi
        if [[ "$capture_output" == "true" ]]; then
            console.debug "Output will be captured"
        fi
        if [[ "$silent" == "true" ]]; then
            console.debug "Running in silent mode"
        fi
    fi

    local attempt=1
    local exit_code=0
    local output=""

    while [[ $attempt -le $retries ]]; do
        if [[ "$verbose" == "true" ]] && [[ $retries -gt 1 ]]; then
            console.debug "Attempt $attempt of $retries"
        fi

        # Prepare the command execution
        local exec_cmd="$command"

        # Add timeout if specified
        if [[ -n "$timeout" ]]; then
            exec_cmd="timeout $timeout $command"
        fi

        # Execute the command
        if [[ "$capture_output" == "true" ]]; then
            # Capture output
            if [[ "$silent" == "true" ]]; then
                # Silent mode: only capture output, don't show it
                output=$(eval "$exec_cmd" 2>&1)
                exit_code=$?
            else
                # Normal mode: show output and capture it
                output=$(eval "$exec_cmd" 2>&1)
                exit_code=$?
                echo "$output"
            fi
        else
            # Don't capture output, just execute
            if [[ "$silent" == "true" ]]; then
                # Silent mode: redirect output to /dev/null
                eval "$exec_cmd" >/dev/null 2>&1
                exit_code=$?
            else
                # Normal mode: show output
                eval "$exec_cmd"
                exit_code=$?
            fi
        fi

        # Check if command succeeded
        if [[ $exit_code -eq 0 ]]; then
            if [[ "$verbose" == "true" ]]; then
                console.success "Command succeeded on attempt $attempt"
            fi
            break
        else
            if [[ $attempt -lt $retries ]]; then
                if [[ "$verbose" == "true" ]]; then
                    console.warn "Command failed on attempt $attempt (exit code: $exit_code), retrying..."
                fi
                # Wait a bit before retrying (exponential backoff)
                local wait_time=$((attempt * 2))
                if [[ "$verbose" == "true" ]]; then
                    console.debug "Waiting ${wait_time}s before retry..."
                fi
                sleep $wait_time
            else
                if [[ "$verbose" == "true" ]]; then
                    console.error "Command failed on final attempt $attempt (exit code: $exit_code)"
                fi
            fi
        fi

        ((attempt++))
    done

    # Return captured output if requested
    if [[ "$capture_output" == "true" ]]; then
        echo "$output"
    fi

    return $exit_code
}

##
## (Usage) Stop a process gracefully (SIGTERM)
##
## Options:
##   --timeout=<seconds>     - Wait timeout before force kill (default: 10)
##   --force                 - Force kill immediately (SIGKILL)
##   --verbose               - Show detailed execution information
##
## Examples:
##   process.stop <pid>                    # Stop process gracefully
##   process.stop <pid> --timeout=30       # Wait 30 seconds before force kill
##   process.stop <pid> --force            # Force kill immediately
##   process.stop <pid> --verbose          # Show detailed information
##
function process.stop() {
    local pid=""
    local timeout=10
    local force=false
    local verbose=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
        --timeout=*)
            timeout="${1#*=}"
            shift
            ;;
        --force)
            force=true
            shift
            ;;
        --verbose)
            verbose=true
            shift
            ;;
        -*)
            console.error "Unknown option: $1"
            return 1
            ;;
        *)
            if [[ -z "$pid" ]]; then
                pid="$1"
            else
                console.error "Multiple PIDs specified"
                return 1
            fi
            shift
            ;;
        esac
    done

    # Validate PID
    if [[ -z "$pid" ]]; then
        console.error "PID is required"
        return 1
    fi

    if ! [[ "$pid" =~ ^[0-9]+$ ]]; then
        console.error "PID must be a positive integer"
        return 1
    fi

    # Validate timeout
    if ! [[ "$timeout" =~ ^[0-9]+$ ]] || [[ "$timeout" -lt 0 ]]; then
        console.error "Timeout must be a non-negative integer"
        return 1
    fi

    # Check if process exists
    if ! process.exists "$pid"; then
        console.error "Process $pid does not exist"
        return 1
    fi

    if [[ "$verbose" == "true" ]]; then
        console.debug "Stopping process $pid"
        if [[ "$force" == "true" ]]; then
            console.debug "Force kill mode enabled"
        else
            console.debug "Graceful stop with ${timeout}s timeout"
        fi
    fi

    # Get process info before stopping
    local process_name=$(process.getName "$pid" 2>/dev/null || echo "unknown")
    local process_user=$(process.getUser "$pid" 2>/dev/null || echo "unknown")

    if [[ "$verbose" == "true" ]]; then
        console.debug "Process: $process_name (PID: $pid, User: $process_user)"
    fi

    # Stop the process
    if [[ "$force" == "true" ]]; then
        # Force kill immediately
        if kill -9 "$pid" 2>/dev/null; then
            if [[ "$verbose" == "true" ]]; then
                console.success "Process $pid force killed successfully"
            fi
            return 0
        else
            console.error "Failed to force kill process $pid"
            return 1
        fi
    else
        # Graceful stop with timeout
        if kill -TERM "$pid" 2>/dev/null; then
            if [[ "$verbose" == "true" ]]; then
                console.debug "SIGTERM sent to process $pid, waiting up to ${timeout}s"
            fi

            # Wait for process to terminate gracefully
            local waited=0
            while [[ $waited -lt $timeout ]]; do
                if ! process.exists "$pid"; then
                    if [[ "$verbose" == "true" ]]; then
                        console.success "Process $pid stopped gracefully after ${waited}s"
                    fi
                    return 0
                fi
                sleep 1
                ((waited++))
            done

            # Process didn't stop gracefully, force kill
            if [[ "$verbose" == "true" ]]; then
                console.warn "Process $pid did not stop gracefully, force killing"
            fi

            if kill -9 "$pid" 2>/dev/null; then
                if [[ "$verbose" == "true" ]]; then
                    console.success "Process $pid force killed after timeout"
                fi
                return 0
            else
                console.error "Failed to force kill process $pid after timeout"
                return 1
            fi
        else
            console.error "Failed to send SIGTERM to process $pid"
            return 1
        fi
    fi
}

##
## (Usage) Abort/kill a process immediately (SIGKILL)
##
## Options:
##   --verbose               - Show detailed execution information
##
## Examples:
##   process.abort <pid>                    # Kill process immediately
##   process.abort <pid> --verbose          # Show detailed information
##
function process.abort() {
    local pid=""
    local verbose=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
        --verbose)
            verbose=true
            shift
            ;;
        -*)
            console.error "Unknown option: $1"
            return 1
            ;;
        *)
            if [[ -z "$pid" ]]; then
                pid="$1"
            else
                console.error "Multiple PIDs specified"
                return 1
            fi
            shift
            ;;
        esac
    done

    # Validate PID
    if [[ -z "$pid" ]]; then
        console.error "PID is required"
        return 1
    fi

    if ! [[ "$pid" =~ ^[0-9]+$ ]]; then
        console.error "PID must be a positive integer"
        return 1
    fi

    # Check if process exists
    if ! process.exists "$pid"; then
        console.error "Process $pid does not exist"
        return 1
    fi

    if [[ "$verbose" == "true" ]]; then
        console.debug "Aborting process $pid"
        local process_name=$(process.getName "$pid" 2>/dev/null || echo "unknown")
        local process_user=$(process.getUser "$pid" 2>/dev/null || echo "unknown")
        console.debug "Process: $process_name (PID: $pid, User: $process_user)"
    fi

    # Kill the process immediately
    if kill -9 "$pid" 2>/dev/null; then
        if [[ "$verbose" == "true" ]]; then
            console.success "Process $pid aborted successfully"
        fi
        return 0
    else
        console.error "Failed to abort process $pid"
        return 1
    fi
}

##
## (Usage) Check if a process exists
##
## Examples:
##   process.exists 1234              # Check if process 1234 exists
##   if process.exists $pid; then     # Use in conditional statements
##
function process.exists() {
    local pid="$1"

    if [[ -z "$pid" ]]; then
        return 1
    fi

    if ! [[ "$pid" =~ ^[0-9]+$ ]]; then
        return 1
    fi

    kill -0 "$pid" 2>/dev/null
}

##
## (Usage) Get process name by PID
##
## Examples:
##   process.getName 1234             # Get name of process 1234
##
function process.getName() {
    local pid="$1"

    if [[ -z "$pid" ]]; then
        echo ""
        return 1
    fi

    if ! [[ "$pid" =~ ^[0-9]+$ ]]; then
        echo ""
        return 1
    fi

    ps -p "$pid" -o comm= 2>/dev/null | head -1
}

##
## (Usage) Get process user by PID
##
## Examples:
##   process.getUser 1234             # Get user of process 1234
##
function process.getUser() {
    local pid="$1"

    if [[ -z "$pid" ]]; then
        echo ""
        return 1
    fi

    if ! [[ "$pid" =~ ^[0-9]+$ ]]; then
        echo ""
        return 1
    fi

    ps -p "$pid" -o user= 2>/dev/null | head -1
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
  process.run <command> [options]  - Run a command with various options
  process.stop <pid> [options]     - Stop a process gracefully
  process.abort <pid> [options]    - Abort/kill a process immediately
  process.help                     - Show this help

List Options:
  -l=<number>, --limit=<number>    - Limit number of processes shown
  --no-log                         - Fast output without logging overhead
  --format=<format>                - Output format (compact|table|default)

Run Options:
  --timeout=<seconds>     - Set timeout in seconds (default: no timeout)
  --capture-output        - Capture and return command output
  --retries=<number>      - Number of retry attempts (default: 1)
  --dry-run              - Show what would be executed without running
  --silent               - Suppress command output (except errors)
  --verbose              - Show detailed execution information

Stop Options:
  --timeout=<seconds>     - Wait timeout before force kill (default: 10)
  --force                 - Force kill immediately (SIGKILL)
  --verbose               - Show detailed execution information

Abort Options:
  --verbose               - Show detailed execution information

Examples:
  process.list                     # List all processes
  process.list -l=10              # List first 10 processes
  process.list --no-log --format=compact  # Fast compact output
  process.count                    # Get total process count
  process.find ssh                 # Find SSH processes
  process.top_cpu 5                # Top 5 CPU-intensive processes
  process.top_mem 10               # Top 10 memory-intensive processes
  process.run "apt-get update" --timeout=300
  process.run "docker build ." --capture-output
  process.run "curl example.com" --retries=3
  process.run "rm -rf /tmp/*" --dry-run
  process.run "ls -la" --silent
  process.run "echo 'test'" --verbose
  process.stop 1234                # Stop process gracefully
  process.stop 1234 --timeout=30   # Wait 30 seconds before force kill
  process.stop 1234 --force        # Force kill immediately
  process.stop 1234 --verbose      # Show detailed information
  process.abort 1234               # Kill process immediately
  process.abort 1234 --verbose     # Show detailed information
EOF
}

# Module import signal using scoped naming
export BASH_LIB_IMPORTED_process="1"
