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
        printf '%s\n' "$list"
        return 0
    fi

    # For better performance, batch the output
    if [[ "$format" == "compact" ]]; then
        # Compact format: just PID, CPU%, MEM%, COMMAND
        printf '%s' "$list" | awk '{printf "%-8s %-6s %-6s %s\n", $2, $3, $4, $11}'
    elif [[ "$format" == "table" ]]; then
        # Table format with headers
        printf '%s' "$list" | column -t
    else
        # Default format: output as-is but without individual logging
        printf '%s\n' "$list"
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
## Options:
##   --id                    - Print only process IDs
##   --kill                  - Kill all matching processes
##   --verbose               - Show detailed information
##
## Examples:
##   process.find ssh               # Find all SSH-related processes
##   process.find nginx             # Find nginx processes
##   process.find python            # Find Python processes
##   process.find "docker"          # Find Docker processes
##   process.find npm --id          # Print only npm process IDs
##   process.find npm --kill        # Kill all npm processes
##   process.find node --id --kill  # Print IDs and kill node processes
##
function process.find() {
    local process_name=""
    local show_ids=false
    local kill_processes=false
    local verbose=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
        --id)
            show_ids=true
            shift
            ;;
        --kill)
            kill_processes=true
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
            if [[ -z "$process_name" ]]; then
                process_name="$1"
            else
                console.error "Multiple process names specified"
                return 1
            fi
            shift
            ;;
        esac
    done

    if [[ -z "$process_name" ]]; then
        console.error "Process name is required"
        return 1
    fi

    # Find matching processes
    local processes=$(ps aux | grep -i "$process_name" | grep -v grep)

    if [[ -z "$processes" ]]; then
        if [[ "$verbose" == true ]]; then
            console.info "No processes found matching '$process_name'"
        fi
        return 0
    fi

    # Extract PIDs
    local pids=$(echo "$processes" | awk '{print $2}')

    # Handle different output modes
    if [[ "$show_ids" == true ]]; then
        # Print only PIDs
        echo "$pids"
    elif [[ "$kill_processes" == true ]]; then
        # Kill processes and show results
        local killed_count=0
        local failed_count=0

        for pid in $pids; do
            if process.exists "$pid"; then
                if [[ "$verbose" == true ]]; then
                    if process.stop "$pid" --verbose; then
                        ((killed_count++))
                        console.success "Killed process $pid"
                    else
                        ((failed_count++))
                        console.error "Failed to kill process $pid"
                    fi
                else
                    if process.stop "$pid"; then
                        ((killed_count++))
                    else
                        ((failed_count++))
                    fi
                fi
            else
                if [[ "$verbose" == true ]]; then
                    console.warn "Process $pid no longer exists"
                fi
            fi
        done

        if [[ $killed_count -gt 0 ]]; then
            console.success "Successfully killed $killed_count process(es)"
        fi

        if [[ $failed_count -gt 0 ]]; then
            console.error "Failed to kill $failed_count process(es)"
            return 1
        fi

        return 0
    else
        # Default: show full process information
        echo "$processes"
    fi
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
                printf '%s\n' "$output"
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
        printf '%s\n' "$output"
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
    local process_name=$(process.getName "$pid" 2>/dev/null || printf '%s\n' "unknown")
    local process_user=$(process.getUser "$pid" 2>/dev/null || printf '%s\n' "unknown")

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
        local process_name=$(process.getName "$pid" 2>/dev/null || printf '%s\n' "unknown")
        local process_user=$(process.getUser "$pid" 2>/dev/null || printf '%s\n' "unknown")
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
        printf '%s\n' ""
        return 1
    fi

    if ! [[ "$pid" =~ ^[0-9]+$ ]]; then
        printf '%s\n' ""
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
        printf '%s\n' ""
        return 1
    fi

    if ! [[ "$pid" =~ ^[0-9]+$ ]]; then
        printf '%s\n' ""
        return 1
    fi

    ps -p "$pid" -o user= 2>/dev/null | head -1
}

##
## (Usage) Find processes listening on a specific port
##
## Options:
##   --verbose               - Show detailed information
##   --id                   - Print only process IDs
##   --kill                 - Kill all processes listening on the port
##
## Examples:
##   process.listening_to 8080              # Find processes on port 8080
##   process.listening_to 3000 --verbose    # Show detailed info
##   process.listening_to 80 --id           # Print only PIDs
##   process.listening_to 443 --kill        # Kill all processes on port 443
##
function process.listening_to() {
    local port=""
    local verbose=false
    local show_ids=false
    local kill_processes=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
        --verbose)
            verbose=true
            shift
            ;;
        --id)
            show_ids=true
            shift
            ;;
        --kill)
            kill_processes=true
            shift
            ;;
        -*)
            console.error "Unknown option: $1"
            return 1
            ;;
        *)
            if [[ -z "$port" ]]; then
                port="$1"
            else
                console.error "Multiple ports specified"
                return 1
            fi
            shift
            ;;
        esac
    done

    # Validate port
    if [[ -z "$port" ]]; then
        console.error "Port number is required"
        return 1
    fi

    if ! [[ "$port" =~ ^[0-9]+$ ]] || [[ "$port" -lt 1 ]] || [[ "$port" -gt 65535 ]]; then
        console.error "Port must be a number between 1 and 65535"
        return 1
    fi

    # Find processes listening on the port
    local listening_processes=""
    
    # Try different methods to find listening processes
    if command -v ss >/dev/null 2>&1; then
        # Use ss (socket statistics) - modern replacement for netstat
        listening_processes=$(ss -tlnp 2>/dev/null | grep ":$port " | awk '{print $7}' | sed 's/.*pid=\([0-9]*\).*/\1/' | sort -u)
    elif command -v netstat >/dev/null 2>&1; then
        # Fallback to netstat
        listening_processes=$(netstat -tlnp 2>/dev/null | grep ":$port " | awk '{print $7}' | sed 's/.*\/\([0-9]*\).*/\1/' | sort -u)
    elif command -v lsof >/dev/null 2>&1; then
        # Fallback to lsof
        listening_processes=$(lsof -i :$port -t 2>/dev/null | sort -u)
    else
        console.error "No suitable tool found (ss, netstat, or lsof required)"
        return 1
    fi

    if [[ -z "$listening_processes" ]]; then
        if [[ "$verbose" == true ]]; then
            console.info "No processes found listening on port $port"
        fi
        return 0
    fi

    # Handle different output modes
    if [[ "$show_ids" == true ]]; then
        # Print only PIDs
        echo "$listening_processes"
    elif [[ "$kill_processes" == true ]]; then
        # Kill processes and show results
        local killed_count=0
        local failed_count=0

        for pid in $listening_processes; do
            if process.exists "$pid"; then
                if [[ "$verbose" == true ]]; then
                    local process_name=$(process.getName "$pid" 2>/dev/null || printf '%s\n' "unknown")
                    local process_user=$(process.getUser "$pid" 2>/dev/null || printf '%s\n' "unknown")
                    console.info "Killing process $pid ($process_name, user: $process_user)"
                fi
                
                if process.stop "$pid" --timeout=5; then
                    ((killed_count++))
                    if [[ "$verbose" == true ]]; then
                        console.success "Killed process $pid"
                    fi
                else
                    ((failed_count++))
                    if [[ "$verbose" == true ]]; then
                        console.error "Failed to kill process $pid"
                    fi
                fi
            else
                if [[ "$verbose" == true ]]; then
                    console.warn "Process $pid no longer exists"
                fi
            fi
        done

        if [[ $killed_count -gt 0 ]]; then
            console.success "Successfully killed $killed_count process(es) listening on port $port"
        fi

        if [[ $failed_count -gt 0 ]]; then
            console.error "Failed to kill $failed_count process(es)"
            return 1
        fi

        return 0
    else
        # Default: show detailed process information
        local found_processes=false
        
        for pid in $listening_processes; do
            if process.exists "$pid"; then
                found_processes=true
                local process_name=$(process.getName "$pid" 2>/dev/null || printf '%s\n' "unknown")
                local process_user=$(process.getUser "$pid" 2>/dev/null || printf '%s\n' "unknown")
                
                if [[ "$verbose" == true ]]; then
                    # Get additional process info
                    local cmdline=$(ps -p "$pid" -o args= 2>/dev/null | head -1)
                    local memory=$(ps -p "$pid" -o rss= 2>/dev/null | head -1)
                    local cpu=$(ps -p "$pid" -o %cpu= 2>/dev/null | head -1)
                    
                    console.info "Process listening on port $port:"
                    console.info "  PID: $pid"
                    console.info "  Name: $process_name"
                    console.info "  User: $process_user"
                    console.info "  Command: $cmdline"
                    console.info "  Memory: ${memory}KB"
                    console.info "  CPU: ${cpu}%"
                    console.info "  ---"
                else
                    console.info "PID: $pid, Name: $process_name, User: $process_user"
                fi
            else
                if [[ "$verbose" == true ]]; then
                    console.warn "Process $pid no longer exists"
                fi
            fi
        done
        
        if [[ "$found_processes" != true ]]; then
            console.info "No active processes found listening on port $port"
        fi
    fi
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
  process.find <name> [options]    - Find processes by name
  process.listening_to <port> [options] - Find processes listening on a port
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

Find Options:
  --id                             - Print only process IDs
  --kill                           - Kill all matching processes
  --verbose                        - Show detailed information

Listening Options:
  --id                             - Print only process IDs
  --kill                           - Kill all processes listening on the port
  --verbose                        - Show detailed information

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
  process.find npm --id            # Print only npm process IDs
  process.find node --kill         # Kill all node processes
  process.find python --verbose    # Find Python processes with details
  process.listening_to 8080        # Find processes on port 8080
  process.listening_to 3000 --verbose # Show detailed info
  process.listening_to 80 --id     # Print only PIDs
  process.listening_to 443 --kill  # Kill all processes on port 443
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
