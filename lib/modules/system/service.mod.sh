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
        *)
            console.error "Unknown option: $1"
            return 1
            ;;
        esac
    done

    # Validate required parameters
    if [[ -z "$service_name" || -z "$command" ]]; then
        console.error "service.start: service_name and command are required"
        return 1
    fi

    if [[ "$dry_run" == true ]]; then
        console.info "DRY RUN: Would start service '$service_name' with command: $command"
        if [[ -n "$health_check" ]]; then
            console.info "DRY RUN: Health check: $health_check"
        fi
        if [[ -n "$port" ]]; then
            console.info "DRY RUN: Port check: $port"
        fi
        if [[ -n "$url" ]]; then
            console.info "DRY RUN: URL check: $url"
        fi
        return 0
    fi

    # Check if service is already running
    if service.is_running "$service_name"; then
        local existing_pid=$(_service_get_pid "$service_name")
        console.warn "Service '$service_name' is already running (PID: $existing_pid)"
        return 0
    fi

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

    # Parse options
    while [[ $# -gt 0 ]]; do
        case $1 in
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

    local service_list=$(_service_list)
    if [[ -z "$service_list" ]]; then
        console.info "No services are currently tracked"
        return 0
    fi

    console.info "Services:"
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

  service.info <service_name>
    Show detailed information about a service

  service.help
    Show this help message

Examples:
  # Start a web service
  service.start web_server "python -m http.server 8080" --port 8080 --timeout 60

  # Start with custom health check
  service.start api_server "node server.js" --health-check "curl -f http://localhost:3000/health" --timeout 30

  # Wait for service to be ready
  service.wait_for_ready web_server --port 8080

  # Check service health
  service.health web_server --port 8080 --verbose

  # Stop service gracefully
  service.stop web_server --timeout 15

  # List all services
  service.list --verbose
EOF
}

# Module import signal using scoped naming
export BASH_LIB_IMPORTED_service="1"
