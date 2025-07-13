#!/bin/bash

# Service Management Module
# Provides functions for service-level operations

# shellcheck disable=SC2034
SERVICE_MODULE_VERSION="1.0.0"

# Import required modules
import console
import process
import network
import http

# Default service configuration
SERVICE_DEFAULT_TIMEOUT=30
SERVICE_DEFAULT_RETRY_INTERVAL=2
SERVICE_DEFAULT_HEALTH_CHECK_INTERVAL=5

# Service status tracking (bash 3.x compatible)
SERVICE_PIDS=""
SERVICE_STATUS=""

# Helper functions for service tracking
_service_get_pid() {
    local service_name="$1"
    echo "$SERVICE_PIDS" | grep "^$service_name:" | cut -d: -f2
}

_service_set_pid() {
    local service_name="$1"
    local pid="$2"
    # Remove existing entry if any
    SERVICE_PIDS=$(echo "$SERVICE_PIDS" | grep -v "^$service_name:")
    # Add new entry
    SERVICE_PIDS="$SERVICE_PIDS
$service_name:$pid"
}

_service_get_status() {
    local service_name="$1"
    echo "$SERVICE_STATUS" | grep "^$service_name:" | cut -d: -f2
}

_service_set_status() {
    local service_name="$1"
    local status="$2"
    # Remove existing entry if any
    SERVICE_STATUS=$(echo "$SERVICE_STATUS" | grep -v "^$service_name:")
    # Add new entry
    SERVICE_STATUS="$SERVICE_STATUS
$service_name:$status"
}

_service_remove() {
    local service_name="$1"
    SERVICE_PIDS=$(echo "$SERVICE_PIDS" | grep -v "^$service_name:")
    SERVICE_STATUS=$(echo "$SERVICE_STATUS" | grep -v "^$service_name:")
}

_service_list() {
    echo "$SERVICE_PIDS" | grep -v "^$" | cut -d: -f1
}

# Check if nohup is available
_service_check_nohup() {
    if ! command -v nohup >/dev/null 2>&1; then
        console.error "nohup is not available on this system"
        console.info "Please install nohup or use foreground mode (remove --background flag)"
        return 1
    fi
    return 0
}

# Process template file with variable substitution
# Usage: _service_process_template <template_file> <output_file> <var1=value1> [var2=value2] ...
_service_process_template() {
    local template_file="$1"
    local output_file="$2"
    shift 2
    
    # Check if template file exists
    if [[ ! -f "$template_file" ]]; then
        console.error "Template file not found: $template_file"
        return 1
    fi
    
    # Read template content
    local content
    content=$(cat "$template_file") || {
        console.error "Failed to read template file: $template_file"
        return 1
    }
    
    # Replace variables
    local var_name var_value
    for var_spec in "$@"; do
        if [[ "$var_spec" =~ ^([^=]+)=(.*)$ ]]; then
            var_name="${BASH_REMATCH[1]}"
            var_value="${BASH_REMATCH[2]}"
            # Escape special characters in var_value for sed
            var_value=$(printf '%s\n' "$var_value" | sed 's:[][\/.^$*]:\\&:g')
            content=$(printf '%s\n' "$content" | sed "s/{{${var_name}}}/$var_value/g")
        fi
    done
    
    # Write processed content to output file
    printf '%s\n' "$content" > "$output_file" || {
        console.error "Failed to write output file: $output_file"
        return 1
    }
    
    return 0
}

# Check service module requirements
service.check_requirements() {
    console.info "Checking service module requirements..."
    
    local missing_tools=()
    
    # Check for nohup
    if ! command -v nohup >/dev/null 2>&1; then
        missing_tools+=("nohup")
    fi
    
    # Check for other required tools
    if ! command -v kill >/dev/null 2>&1; then
        missing_tools+=("kill")
    fi
    
    if ! command -v sleep >/dev/null 2>&1; then
        missing_tools+=("sleep")
    fi
    
    if [[ ${#missing_tools[@]} -eq 0 ]]; then
        console.success "All required tools are available"
        return 0
    else
        console.error "Missing required tools: ${missing_tools[*]}"
        console.info "Background mode will not be available"
        return 1
    fi
}

# Start a service with health check
# Usage: service.start <service_name> <command> [options]
# Options:
#   --timeout <seconds>     Health check timeout (default: 30)
#   --retry-interval <sec>  Retry interval for health checks (default: 2)
#   --health-check <cmd>    Custom health check command
#   --port <port>          Port to check for service readiness
#   --url <url>            URL to check for service readiness
#   --dry-run              Show what would be done without executing
#   --verbose              Enable verbose output
#   --respawn              Enable automatic respawn when process dies
#   --max-restarts <num>   Maximum restart attempts (0 = infinite, default: 0)
#   --restart-delay <sec>  Seconds to wait between restarts (default: 5)
#   --background           Run in background with nohup (survives logout)
#   --log-file <path>      Log file for background mode
#   --pid-file <path>      PID file for background mode
service.start() {
    local service_name="$1"
    local command="$2"
    shift 2

    local timeout="$SERVICE_DEFAULT_TIMEOUT"
    local retry_interval="$SERVICE_DEFAULT_RETRY_INTERVAL"
    local health_check=""
    local port=""
    local url=""
    local dry_run=false
    local verbose=false
    local respawn=false
    local max_restarts=0
    local restart_delay=5
    local background=false
    local log_file=""
    local pid_file=""

    # Parse options
    while [[ $# -gt 0 ]]; do
        case $1 in
        --timeout)
            timeout="$2"
            shift 2
            ;;
        --retry-interval)
            retry_interval="$2"
            shift 2
            ;;
        --health-check)
            health_check="$2"
            shift 2
            ;;
        --port)
            port="$2"
            shift 2
            ;;
        --url)
            url="$2"
            shift 2
            ;;
        --dry-run)
            dry_run=true
            shift
            ;;
        --verbose)
            verbose=true
            shift
            ;;
        --respawn)
            respawn=true
            shift
            ;;
        --max-restarts)
            max_restarts="$2"
            shift 2
            ;;
        --restart-delay)
            restart_delay="$2"
            shift 2
            ;;
        --background)
            background=true
            shift
            ;;
        --log-file)
            log_file="$2"
            shift 2
            ;;
        --pid-file)
            pid_file="$2"
            shift 2
            ;;
        *)
            console.error "Unknown option: $1"
            return 1
            ;;
        esac
    done

    # Check nohup availability if background mode requested
    if [[ "$background" == true ]]; then
        if ! _service_check_nohup; then
            return 1
        fi
        
        # Set default pid file if not specified
        if [[ -z "$pid_file" ]]; then
            pid_file="/var/run/${service_name}.pid"
        fi
        
        # Ensure log file is specified for background mode
        if [[ -z "$log_file" ]]; then
            log_file="/var/log/${service_name}.log"
            console.warn "No log file specified, using default: $log_file"
        fi
        
        # Ensure log directory exists
        local log_dir=$(dirname "$log_file")
        if [[ ! -d "$log_dir" ]]; then
            console.info "Creating log directory: $log_dir"
            mkdir -p "$log_dir" || {
                console.error "Failed to create log directory: $log_dir"
                return 1
            }
        fi
    fi

    # Validate required parameters
    if [[ -z "$service_name" || -z "$command" ]]; then
        console.error "service.start: service_name and command are required"
        return 1
    fi

    if [[ "$dry_run" == true ]]; then
        console.info "DRY RUN: Would start service '$service_name' with command: $command"
        if [[ "$respawn" == true ]]; then
            console.info "DRY RUN: Respawn enabled (max: $max_restarts, delay: ${restart_delay}s)"
        fi
        if [[ "$background" == true ]]; then
            console.info "DRY RUN: Background mode enabled (nohup)"
            console.info "DRY RUN: Log file: $log_file"
            console.info "DRY RUN: PID file: $pid_file"
        fi
        return 0
    fi

    # Check if service is already running
    if service.is_running "$service_name"; then
        local existing_pid=$(_service_get_pid "$service_name")
        console.warn "Service '$service_name' is already running (PID: $existing_pid)"
        return 0
    fi

    # Start service with appropriate mode
    if [[ "$respawn" == true ]]; then
        _service_start_with_respawn "$service_name" "$command" "$timeout" "$retry_interval" "$health_check" "$port" "$url" "$verbose" "$max_restarts" "$restart_delay" "$background" "$log_file" "$pid_file"
    else
        _service_start_once "$service_name" "$command" "$timeout" "$retry_interval" "$health_check" "$port" "$url" "$verbose"
    fi
}

# Internal function for one-shot service start (current behavior)
_service_start_once() {
    local service_name="$1"
    local command="$2"
    local timeout="$3"
    local retry_interval="$4"
    local health_check="$5"
    local port="$6"
    local url="$7"
    local verbose="$8"

    console.info "Starting service '$service_name'..."

    # Start the service
    if [[ "$verbose" == true ]]; then
        console.debug "Executing: $command"
    fi

    # Run the command in background
    eval "$command" &
    local pid=$!

    # Store service information
    _service_set_pid "$service_name" "$pid"
    _service_set_status "$service_name" "starting"

    console.info "Service '$service_name' started with PID: $pid"

    # Wait for service to be ready
    if ! service.wait_for_ready "$service_name" --timeout "$timeout" --retry-interval "$retry_interval" --health-check "$health_check" --port "$port" --url "$url" --verbose "$verbose"; then
        console.error "Service '$service_name' failed to become ready within timeout"
        service.stop "$service_name" --force
        return 1
    fi

    _service_set_status "$service_name" "running"
    console.success "Service '$service_name' is ready and running"
    return 0
}

# Internal function for respawn-enabled service start
_service_start_with_respawn() {
    local service_name="$1"
    local command="$2"
    local timeout="$3"
    local retry_interval="$4"
    local health_check="$5"
    local port="$6"
    local url="$7"
    local verbose="$8"
    local max_restarts="$9"
    local restart_delay="${10}"
    local background="${11}"
    local log_file="${12}"
    local pid_file="${13}"

    if [[ "$background" == true ]]; then
        # Double-check nohup availability
        if ! _service_check_nohup; then
            console.error "Cannot start background service: nohup not available"
            console.info "Falling back to foreground mode"
            background=false
        else
            console.info "Starting service '$service_name' with background respawn (nohup)"
            
            # Create supervisor script using template
            local supervisor_script="/tmp/${service_name}_supervisor_$$.sh"
            local template_file="${BASH__PATH:-/opt/bash-lib}/lib/templates/service-supervisor.sh"
            
            if ! _service_process_template "$template_file" "$supervisor_script" \
                "SERVICE_NAME=$service_name" \
                "MAX_RESTARTS=$max_restarts" \
                "RESTART_DELAY=$restart_delay" \
                "COMMAND=$command" \
                "LOG_FILE=$log_file" \
                "PID_FILE=$pid_file" \
                "BASH__PATH=${BASH__PATH:-/opt/bash-lib}"; then
                console.error "Failed to create supervisor script from template"
                return 1
            fi

            # Make executable and run with nohup
            chmod +x "$supervisor_script"
            
            # Start supervisor in background
            nohup bash "$supervisor_script" > "$log_file" 2>&1 &
            local supervisor_pid=$!
            
            # Wait a moment to ensure it started
            sleep 2
            
            # Verify supervisor is running
            if kill -0 "$supervisor_pid" 2>/dev/null; then
                console.success "Service '$service_name' supervisor started in background (PID: $supervisor_pid)"
                console.info "Logs: $log_file"
                console.info "PID file: $pid_file"
                console.info "Supervisor script: $supervisor_script"
            else
                console.error "Failed to start supervisor for service '$service_name'"
                console.error "Check logs: $log_file"
                rm -f "$supervisor_script"
                return 1
            fi
            
            # Clean up temporary script after a delay
            (sleep 30 && rm -f "$supervisor_script") &
            
        fi
    fi
    
    # Fallback to foreground mode if background failed or not requested
    if [[ "$background" != true ]]; then
        console.info "Starting service '$service_name' with foreground respawn"
        
        local restart_count=0
        local supervisor_pid=$$

        # Set up signal handling for graceful shutdown
        trap '_service_supervisor_cleanup "$service_name" "$supervisor_pid"' EXIT INT TERM

        while true; do
            # Check restart limits
            if [[ $max_restarts -gt 0 && $restart_count -ge $max_restarts ]]; then
                console.error "Service '$service_name' exceeded maximum restart attempts ($max_restarts)"
                return 1
            fi

            # Start the service
            console.info "Starting service '$service_name' (attempt $((restart_count + 1)))"
            
            eval "$command" &
            local pid=$!

            # Store service information
            _service_set_pid "$service_name" "$pid"
            _service_set_status "$service_name" "starting"

            console.info "Service '$service_name' started with PID: $pid"

            # Wait for service to be ready
            if service.wait_for_ready "$service_name" --timeout "$timeout" --retry-interval "$retry_interval" --health-check "$health_check" --port "$port" --url "$url" --verbose "$verbose"; then
                _service_set_status "$service_name" "running"
                console.success "Service '$service_name' is ready and running"
                
                # Monitor the process
                while process.exists "$pid"; do
                    sleep 5
                done
                
                # Process died
                console.warn "Service '$service_name' (PID: $pid) has stopped"
                _service_set_status "$service_name" "stopped"
                
                # Increment restart count and wait before restarting
                restart_count=$((restart_count + 1))
                console.info "Restarting service '$service_name' in ${restart_delay} seconds... (restart #$restart_count)"
                sleep "$restart_delay"
                
            else
                console.error "Service '$service_name' failed to become ready within timeout"
                service.stop "$service_name" --force
                restart_count=$((restart_count + 1))
                console.info "Restarting service '$service_name' in ${restart_delay} seconds... (restart #$restart_count)"
                sleep "$restart_delay"
            fi
        done
    fi
}

# Cleanup function for supervisor
_service_supervisor_cleanup() {
    local service_name="$1"
    local supervisor_pid="$2"
    
    console.info "Supervisor shutting down for service '$service_name'"
    service.stop "$service_name" --force
    exit 0
}

# Wait for a service to be ready
# Usage: service.wait_for_ready <service_name> [options]
service.wait_for_ready() {
    local service_name="$1"
    shift

    local timeout="$SERVICE_DEFAULT_TIMEOUT"
    local retry_interval="$SERVICE_DEFAULT_RETRY_INTERVAL"
    local health_check=""
    local port=""
    local url=""
    local verbose=false

    # Parse options
    while [[ $# -gt 0 ]]; do
        case $1 in
        --timeout)
            timeout="$2"
            shift 2
            ;;
        --retry-interval)
            retry_interval="$2"
            shift 2
            ;;
        --health-check)
            health_check="$2"
            shift 2
            ;;
        --port)
            port="$2"
            shift 2
            ;;
        --url)
            url="$2"
            shift 2
            ;;
        --verbose)
            verbose="$2"
            shift 2
            ;;
        *)
            console.error "Unknown option: $1"
            return 1
            ;;
        esac
    done

    # Validate service exists
    local pid=$(_service_get_pid "$service_name")
    if [[ -z "$pid" ]]; then
        console.error "Service '$service_name' not found"
        return 1
    fi
    local start_time=$(date +%s)
    local elapsed=0

    console.info "Waiting for service '$service_name' to be ready..."

    while [[ $elapsed -lt $timeout ]]; do
        # Check if process is still running
        if ! process.exists "$pid"; then
            console.error "Service '$service_name' process (PID: $pid) is no longer running"
            return 1
        fi

        # Perform health checks
        local health_ok=true

        # Port check
        if [[ -n "$port" ]]; then
            if ! network.port_open "$port"; then
                health_ok=false
                if [[ "$verbose" == true ]]; then
                    console.debug "Port $port is not yet open"
                fi
            fi
        fi

        # URL check
        if [[ -n "$url" && "$health_ok" == true ]]; then
            if ! http.get "$url" --timeout 5 --silent >/dev/null 2>&1; then
                health_ok=false
                if [[ "$verbose" == true ]]; then
                    console.debug "URL $url is not yet responding"
                fi
            fi
        fi

        # Custom health check
        if [[ -n "$health_check" && "$health_ok" == true ]]; then
            if ! eval "$health_check" >/dev/null 2>&1; then
                health_ok=false
                if [[ "$verbose" == true ]]; then
                    console.debug "Custom health check failed"
                fi
            fi
        fi

        # If no specific checks, just wait a bit
        if [[ -z "$port" && -z "$url" && -z "$health_check" ]]; then
            health_ok=true
        fi

        if [[ "$health_ok" == true ]]; then
            console.success "Service '$service_name' is ready"
            return 0
        fi

        sleep "$retry_interval"
        elapsed=$(($(date +%s) - start_time))

        if [[ "$verbose" == true ]]; then
            console.debug "Still waiting... ($elapsed/$timeout seconds elapsed)"
        fi
    done

    console.error "Service '$service_name' did not become ready within $timeout seconds"
    return 1
}

# Check service health
# Usage: service.health <service_name> [options]
service.health() {
    local service_name="$1"
    shift

    local health_check=""
    local port=""
    local url=""
    local verbose=false

    # Parse options
    while [[ $# -gt 0 ]]; do
        case $1 in
        --health-check)
            health_check="$2"
            shift 2
            ;;
        --port)
            port="$2"
            shift 2
            ;;
        --url)
            url="$2"
            shift 2
            ;;
        --verbose)
            verbose=true
            shift
            ;;
        *)
            console.error "Unknown option: $1"
            return 1
            ;;
        esac
    done

    # Check if service exists
    local pid=$(_service_get_pid "$service_name")
    if [[ -z "$pid" ]]; then
        console.error "Service '$service_name' not found"
        return 1
    fi

    # Check if process is running
    if ! process.exists "$pid"; then
        console.error "Service '$service_name' process (PID: $pid) is not running"
        return 1
    fi

    # Perform health checks
    local health_ok=true
    local issues=()

    # Port check
    if [[ -n "$port" ]]; then
        if ! network.port_open "$port"; then
            health_ok=false
            issues+=("Port $port is not open")
        fi
    fi

    # URL check
    if [[ -n "$url" ]]; then
        if ! http.get "$url" --timeout 5 --silent >/dev/null 2>&1; then
            health_ok=false
            issues+=("URL $url is not responding")
        fi
    fi

    # Custom health check
    if [[ -n "$health_check" ]]; then
        if ! eval "$health_check" >/dev/null 2>&1; then
            health_ok=false
            issues+=("Custom health check failed")
        fi
    fi

    if [[ "$health_ok" == true ]]; then
        if [[ "$verbose" == true ]]; then
            console.success "Service '$service_name' is healthy (PID: $pid)"
        fi
        return 0
    else
        if [[ "$verbose" == true ]]; then
            console.error "Service '$service_name' health check failed:"
            for issue in "${issues[@]:-}"; do
                console.error "  - $issue"
            done
        fi
        return 1
    fi
}

# Check if a service is running
# Usage: service.is_running <service_name>
service.is_running() {
    local service_name="$1"

    if [[ -z "$service_name" ]]; then
        console.error "service.is_running: service_name is required"
        return 1
    fi

    local pid=$(_service_get_pid "$service_name")

    if [[ -z "$pid" ]]; then
        return 1
    fi

    if process.exists "$pid"; then
        return 0
    else
        # Clean up stale entry
        _service_remove "$service_name"
        return 1
    fi
}

# Stop a service
# Usage: service.stop <service_name> [options]
service.stop() {
    local service_name="$1"
    shift

    local force=false
    local timeout=10
    local verbose=false

    # Parse options
    while [[ $# -gt 0 ]]; do
        case $1 in
        --force)
            force=true
            shift
            ;;
        --timeout)
            timeout="$2"
            shift 2
            ;;
        --verbose)
            verbose=true
            shift
            ;;
        *)
            console.error "Unknown option: $1"
            return 1
            ;;
        esac
    done

    if [[ -z "$service_name" ]]; then
        console.error "service.stop: service_name is required"
        return 1
    fi

    local pid=$(_service_get_pid "$service_name")

    if [[ -z "$pid" ]]; then
        console.warn "Service '$service_name' not found"
        return 0
    fi

    if ! process.exists "$pid"; then
        console.warn "Service '$service_name' process (PID: $pid) is not running"
        _service_remove "$service_name"
        return 0
    fi

    console.info "Stopping service '$service_name' (PID: $pid)..."

    if [[ "$force" == true ]]; then
        if process.abort "$pid" --verbose "$verbose"; then
            console.success "Service '$service_name' forcefully stopped"
        else
            console.error "Failed to forcefully stop service '$service_name'"
            return 1
        fi
    else
        if process.stop "$pid" --timeout "$timeout" --verbose "$verbose"; then
            console.success "Service '$service_name' gracefully stopped"
        else
            console.error "Failed to gracefully stop service '$service_name'"
            return 1
        fi
    fi

    # Clean up service tracking
    _service_remove "$service_name"

    return 0
}

# List all services
# Usage: service.list [options]
service.list() {
    local verbose=false
    local discover=false

    # Parse options
    while [[ $# -gt 0 ]]; do
        case $1 in
        --verbose)
            verbose=true
            shift
            ;;
        --discover)
            discover=true
            shift
            ;;
        *)
            console.error "Unknown option: $1"
            return 1
            ;;
        esac
    done

    local service_list=$(_service_list)
    local found_services=false

    # Show tracked services
    if [[ -n "$service_list" ]]; then
        console.info "Tracked Services:"
        found_services=true
        echo "$service_list" | while read -r service_name; do
            local pid=$(_service_get_pid "$service_name")
            local status=$(_service_get_status "$service_name")

            if process.exists "$pid"; then
                if [[ "$verbose" == true ]]; then
                    local process_name=$(process.getName "$pid" 2>/dev/null || printf '%s\n' "unknown")
                    local user=$(process.getUser "$pid" 2>/dev/null || printf '%s\n' "unknown")
                    console.info "  $service_name: PID=$pid, Status=$status, Process=$process_name, User=$user"
                else
                    console.info "  $service_name: PID=$pid, Status=$status"
                fi
            else
                console.warn "  $service_name: PID=$pid (process not found - stale entry)"
            fi
        done
    fi

    # Discover services from PID files if requested
    if [[ "$discover" == true ]]; then
        console.info "Discovering Services from PID Files:"
        local pid_files=$(find /var/run -name "*.pid" 2>/dev/null)
        
        if [[ -n "$pid_files" ]]; then
            found_services=true
            for pid_file in $pid_files; do
                local service_name=$(basename "$pid_file" .pid)
                local pid=$(cat "$pid_file" 2>/dev/null)
                
                if [[ -n "$pid" && process.exists "$pid" ]]; then
                    if [[ "$verbose" == true ]]; then
                        local process_name=$(process.getName "$pid" 2>/dev/null || printf '%s\n' "unknown")
                        local user=$(process.getUser "$pid" 2>/dev/null || printf '%s\n' "unknown")
                        console.info "  $service_name: PID=$pid, PID_File=$pid_file, Process=$process_name, User=$user"
                    else
                        console.info "  $service_name: PID=$pid, PID_File=$pid_file"
                    fi
                else
                    console.warn "  $service_name: PID_File=$pid_file (process not found - stale PID file)"
                fi
            done
        else
            console.info "  No PID files found in /var/run/"
        fi
    fi

    if [[ "$found_services" != true ]]; then
        console.info "No services found"
        if [[ "$discover" != true ]]; then
            console.info "Use 'service.list --discover' to find services from PID files"
        fi
    fi
}

# Get service information
# Usage: service.info <service_name>
service.info() {
    local service_name="$1"

    if [[ -z "$service_name" ]]; then
        console.error "service.info: service_name is required"
        return 1
    fi

    local pid=$(_service_get_pid "$service_name")

    if [[ -z "$pid" ]]; then
        console.error "Service '$service_name' not found"
        return 1
    fi

    console.info "Service: $service_name"
    console.info "  PID: $pid"
    console.info "  Status: $(_service_get_status "$service_name")"

    if process.exists "$pid"; then
        local process_name=$(process.getName "$pid" 2>/dev/null || printf '%s\n' "unknown")
        local user=$(process.getUser "$pid" 2>/dev/null || printf '%s\n' "unknown")
        local start_time=$(ps -o lstart= -p "$pid" 2>/dev/null || printf '%s\n' "unknown")

        console.info "  Process: $process_name"
        console.info "  User: $user"
        console.info "  Started: $start_time"
    else
        console.warn "  Process not found (stale entry)"
    fi
}

# Show service module help
service.help() {
    cat <<'EOF'
Service Management Module

Functions:
  service.start <service_name> <command> [options]
    Start a service with health monitoring
    Options:
      --timeout <seconds>     Health check timeout (default: 30)
      --retry-interval <sec>  Retry interval for health checks (default: 2)
      --health-check <cmd>    Custom health check command
      --port <port>          Port to check for service readiness
      --url <url>            URL to check for service readiness
      --dry-run              Show what would be done without executing
      --verbose              Enable verbose output
      --respawn              Enable automatic respawn when process dies
      --max-restarts <num>   Maximum restart attempts (0 = infinite, default: 0)
      --restart-delay <sec>  Seconds to wait between restarts (default: 5)
      --background           Run in background with nohup (survives logout)
      --log-file <path>      Log file for background mode
      --pid-file <path>      PID file for background mode

  service.wait_for_ready <service_name> [options]
    Wait for a service to become ready
    Options:
      --timeout <seconds>     Timeout for readiness check
      --retry-interval <sec>  Retry interval
      --health-check <cmd>    Custom health check command
      --port <port>          Port to check
      --url <url>            URL to check
      --verbose <bool>        Enable verbose output

  service.health <service_name> [options]
    Check service health
    Options:
      --health-check <cmd>    Custom health check command
      --port <port>          Port to check
      --url <url>            URL to check
      --verbose              Enable verbose output

  service.is_running <service_name>
    Check if a service is currently running

  service.stop <service_name> [options]
    Stop a service
    Options:
      --force                Force stop (kill -9)
      --timeout <seconds>    Graceful stop timeout (default: 10)
      --verbose              Enable verbose output

  service.list [options]
    List all tracked services
    Options:
      --verbose              Show detailed information
      --discover             Discover services from PID files (useful after logout)

  service.info <service_name>
    Show detailed information about a service

  service.check_requirements
    Check if required tools (nohup, kill, sleep) are available

  service.help
    Show this help message

Examples:
  # Start a web service
  service.start web_server "python -m http.server 8080" --port 8080 --timeout 60

  # Start with custom health check
  service.start api_server "node server.js" --health-check "curl -f http://localhost:3000/health" --timeout 30

  # Start with respawn (foreground)
  service.start api_server "npm run backend" --respawn --max-restarts 5 --restart-delay 10

  # Start with respawn and background (survives logout)
  service.start api_server "npm run backend" --respawn --background --log-file /var/log/api.log

  # Wait for service to be ready
  service.wait_for_ready web_server --port 8080

  # Check service health
  service.health web_server --port 8080 --verbose

  # Stop service gracefully
  service.stop web_server --timeout 15

  # List all services
  service.list --verbose

  # Check requirements
  service.check_requirements
EOF
}

# Module import signal using scoped naming
export BASH_LIB_IMPORTED_service="1"
