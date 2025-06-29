#!/bin/bash

# Network Module for bash-lib
# Provides network utilities with concise naming

# Call import.meta.loaded if the function exists
if command -v import.meta.loaded >/dev/null 2>&1; then
    import.meta.loaded "network" "${BASH__PATH:-/opt/bash-lib}/modules/network/network.mod.sh" "1.0.0" 2>/dev/null || true
fi

import console

##
## (Usage) Check if a port is in use
## Examples:
##   network.port_in_use 8080
##   if network.port_in_use 10000; then echo "Port busy"; fi
##
function network.port_in_use() {
    local port="$1"

    if [[ -z "$port" ]]; then
        console.error "Port number is required"
        return 1
    fi

    if ! [[ "$port" =~ ^[0-9]+$ ]]; then
        console.error "Port must be a number"
        return 1
    fi

    # Check if port is in use
    netstat -tuln 2>/dev/null | grep -q ":$port "
    return $?
}

##
## (Usage) Check if a port is open on a host
## Examples:
##   network.port_open "localhost" 8080
##   if network.port_open "example.com" 80; then echo "Port open"; fi
##
function network.port_open() {
    local host="$1"
    local port="$2"

    if [[ -z "$host" ]] || [[ -z "$port" ]]; then
        console.error "Host and port are required"
        return 1
    fi

    if ! [[ "$port" =~ ^[0-9]+$ ]]; then
        console.error "Port must be a number"
        return 1
    fi

    # Try to connect to the port
    timeout 5 bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null
    return $?
}

##
## (Usage) Test if we can bind to a port
## Examples:
##   network.can_bind 8080
##   if network.can_bind 10000; then echo "Can bind"; fi
##
function network.can_bind() {
    local port="$1"

    if [[ -z "$port" ]]; then
        console.error "Port number is required"
        return 1
    fi

    if ! [[ "$port" =~ ^[0-9]+$ ]]; then
        console.error "Port must be a number"
        return 1
    fi

    # Try to bind to the port
    timeout 5 bash -c "exec 3<>/dev/tcp/127.0.0.1/$port" 2>/dev/null
    local result=$?

    # Close the file descriptor if it was opened
    exec 3>&- 2>/dev/null

    return $result
}

##
## (Usage) Ensure a port is free (exit if not)
## Examples:
##   network.ensure_free 8080
##   network.ensure_free 10000 "HiveServer2 port"
##
function network.ensure_free() {
    local port="$1"
    local service_name="${2:-Service}"

    if network.port_in_use "$port"; then
        console.error "$service_name port $port is already in use"
        return 1
    fi

    return 0
}

##
## (Usage) Wait for a port to become available
## Examples:
##   network.wait_for_port "localhost" 8080 30
##   network.wait_for_port "db.example.com" 5432 60 "PostgreSQL"
##
function network.wait_for_port() {
    local host="$1"
    local port="$2"
    local timeout="${3:-30}"
    local service_name="${4:-Service}"

    if [[ -z "$host" ]] || [[ -z "$port" ]]; then
        console.error "Host and port are required"
        return 1
    fi

    if ! [[ "$timeout" =~ ^[0-9]+$ ]]; then
        console.error "Timeout must be a number"
        return 1
    fi

    console.info "Waiting for $service_name on $host:$port (timeout: ${timeout}s)"

    local attempt=1
    while [[ $attempt -le $timeout ]]; do
        if network.port_open "$host" "$port"; then
            console.success "$service_name is ready on $host:$port"
            return 0
        fi

        if [[ $attempt -lt $timeout ]]; then
            console.debug "Attempt $attempt/$timeout: $service_name not ready yet"
            sleep 1
        fi

        ((attempt++))
    done

    console.error "$service_name failed to become available on $host:$port after ${timeout}s"
    return 1
}

##
## (Usage) Get local IP address
## Examples:
##   local_ip=$(network.local_ip)
##   echo "Local IP: $local_ip"
##
function network.local_ip() {
    # Try different methods to get local IP
    local ip

    # Method 1: hostname -I (Linux)
    ip=$(hostname -I 2>/dev/null | awk '{print $1}')
    if [[ -n "$ip" ]]; then
        echo "$ip"
        return 0
    fi

    # Method 2: ifconfig (macOS/Linux)
    ip=$(ifconfig 2>/dev/null | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1)
    if [[ -n "$ip" ]]; then
        echo "$ip"
        return 0
    fi

    # Method 3: ip addr (Linux)
    ip=$(ip addr show 2>/dev/null | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | cut -d/ -f1 | head -1)
    if [[ -n "$ip" ]]; then
        echo "$ip"
        return 0
    fi

    # Fallback to localhost
    echo "127.0.0.1"
    return 1
}

##
## (Usage) Check if host is reachable
## Examples:
##   network.ping "google.com"
##   if network.ping "db.example.com"; then echo "Host reachable"; fi
##
function network.ping() {
    local host="$1"

    if [[ -z "$host" ]]; then
        console.error "Host is required"
        return 1
    fi

    # Try ping with timeout
    ping -c 1 -W 5 "$host" >/dev/null 2>&1
    return $?
}

##
## (Usage) Show network module help
##
function network.help() {
    cat <<EOF
Network Module - Network utilities with concise naming

Available Functions:
  network.port_in_use <port>                    - Check if port is in use
  network.port_open <host> <port>               - Check if port is open on host
  network.can_bind <port>                       - Test if we can bind to port
  network.ensure_free <port> [service_name]     - Ensure port is free (exit if not)
  network.wait_for_port <host> <port> [timeout] [service_name] - Wait for port to be available
  network.local_ip                              - Get local IP address
  network.ping <host>                           - Check if host is reachable
  network.help                                  - Show this help

Examples:
  network.port_in_use 8080                      # Check if port 8080 is in use
  network.port_open "localhost" 8080            # Check if port 8080 is open on localhost
  network.can_bind 10000                        # Test if we can bind to port 10000
  network.ensure_free 8080 "Web Server"         # Ensure port 8080 is free for web server
  network.wait_for_port "db.example.com" 5432 60 "PostgreSQL"  # Wait for PostgreSQL
  local_ip=\$(network.local_ip)                 # Get local IP address
  network.ping "google.com"                     # Check if google.com is reachable
EOF
}

# Module import signal using scoped naming
export BASH_LIB_IMPORTED_network="1"
