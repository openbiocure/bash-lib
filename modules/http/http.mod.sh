#!/bin/bash

IMPORTED="."

import console

# HTTP Module Configuration
__HTTP__DEFAULT_TIMEOUT=30
__HTTP__DEFAULT_RETRIES=3
__HTTP__DEFAULT_RETRY_DELAY=2

##
## (Usage) HTTP GET request
## Examples:
##   http.get https://api.example.com/data
##   http.get https://api.example.com/data --header="Authorization: Bearer token"
##   http.get https://api.example.com/data --timeout=60
##
function http.get() {
    http.__request "GET" "$@"
}

##
## (Usage) HTTP POST request
## Examples:
##   http.post https://api.example.com/submit --data='{"key":"value"}'
##   http.post https://api.example.com/submit --data-urlencode="name=value"
##   http.post https://api.example.com/submit --header="Content-Type: application/json"
##
function http.post() {
    http.__request "POST" "$@"
}

##
## (Usage) HTTP PUT request
## Examples:
##   http.put https://api.example.com/update/123 --data='{"key":"new_value"}'
##
function http.put() {
    http.__request "PUT" "$@"
}

##
## (Usage) HTTP DELETE request
## Examples:
##   http.delete https://api.example.com/delete/123
##
function http.delete() {
    http.__request "DELETE" "$@"
}

##
## (Usage) Download file with retries
## Examples:
##   http.download https://example.com/file.zip /tmp/file.zip
##   http.download https://example.com/file.zip /tmp/file.zip --retries=5
##   http.download https://example.com/file.zip /tmp/file.zip --timeout=60
##
function http.download() {
    local url="$1"
    local output_path="$2"
    shift 2
    
    if [[ -z "$url" || -z "$output_path" ]]; then
        console.error "Usage: http.download <url> <output_path> [options]"
        return 1
    fi
    
    local retries="${__HTTP__DEFAULT_RETRIES}"
    local timeout="${__HTTP__DEFAULT_TIMEOUT}"
    local headers=()
    
    # Parse options
    for arg in "$@"; do
        case $arg in
            --retries=*) retries="${arg#*=}" ;;
            --timeout=*) timeout="${arg#*=}" ;;
            --header=*) headers+=("${arg#*=}") ;;
            *) ;;
        esac
    done
    
    # Create output directory if it doesn't exist
    local output_dir=$(dirname "$output_path")
    if [[ ! -d "$output_dir" ]]; then
        mkdir -p "$output_dir" || {
            console.error "Failed to create output directory: $output_dir"
            return 1
        }
    fi
    
    local attempt=1
    while [[ $attempt -le $retries ]]; do
        console.info "Downloading $url (attempt $attempt/$retries)"
        
        local curl_opts=(
            "--silent"
            "--show-error"
            "--location"
            "--max-time" "$timeout"
            "--output" "$output_path"
            "--write-out" "HTTPSTATUS:%{http_code}"
        )
        
        # Add headers
        for header in "${headers[@]}"; do
            curl_opts+=("--header" "$header")
        done
        
        local response=$(curl "${curl_opts[@]}" "$url" 2>&1)
        local http_status=$(echo "$response" | grep -o 'HTTPSTATUS:[0-9]*' | cut -d: -f2)
        
        if [[ $? -eq 0 && "$http_status" =~ ^[23][0-9][0-9]$ ]]; then
            console.success "Download completed successfully (HTTP $http_status)"
            return 0
        else
            console.warn "Download failed (attempt $attempt/$retries) - HTTP $http_status"
            if [[ $attempt -lt $retries ]]; then
                console.info "Retrying in ${__HTTP__DEFAULT_RETRY_DELAY} seconds..."
                sleep "${__HTTP__DEFAULT_RETRY_DELAY}"
            fi
        fi
        
        ((attempt++))
    done
    
    console.error "Download failed after $retries attempts"
    return 1
}

##
## (Usage) Check if URL is accessible (returns 0 if accessible, 1 if not)
## Examples:
##   http.check https://example.com
##   http.check https://example.com --timeout=10
##
function http.check() {
    local url="$1"
    shift
    
    if [[ -z "$url" ]]; then
        console.error "Usage: http.check <url> [options]"
        return 1
    fi
    
    local timeout="${__HTTP__DEFAULT_TIMEOUT}"
    
    # Parse options
    for arg in "$@"; do
        case $arg in
            --timeout=*) timeout="${arg#*=}" ;;
            *) ;;
        esac
    done
    
    local http_status=$(curl --silent --show-error --location --max-time "$timeout" \
        --write-out "%{http_code}" --output /dev/null "$url" 2>/dev/null)
    
    if [[ "$http_status" =~ ^[23][0-9][0-9]$ ]]; then
        console.success "URL is accessible (HTTP $http_status)"
        return 0
    else
        console.error "URL is not accessible (HTTP $http_status)"
        return 1
    fi
}

##
## (Usage) Get HTTP status code for URL
## Examples:
##   http.status https://example.com
##   local status=$(http.status https://example.com)
##
function http.status() {
    local url="$1"
    
    if [[ -z "$url" ]]; then
        console.error "Usage: http.status <url>"
        return 1
    fi
    
    curl --silent --show-error --location --max-time "${__HTTP__DEFAULT_TIMEOUT}" \
        --write-out "%{http_code}" --output /dev/null "$url" 2>/dev/null
}

##
## (Usage) Check if URL returns 404
## Examples:
##   if http.is_404 https://example.com/missing; then echo "Page not found"; fi
##
function http.is_404() {
    local url="$1"
    local status=$(http.status "$url")
    [[ "$status" == "404" ]]
}

##
## (Usage) Check if URL returns 200
## Examples:
##   if http.is_200 https://example.com; then echo "Page exists"; fi
##
function http.is_200() {
    local url="$1"
    local status=$(http.status "$url")
    [[ "$status" == "200" ]]
}

##
## (Usage) Get response headers
## Examples:
##   http.headers https://example.com
##   http.headers https://example.com --header="User-Agent: Custom"
##
function http.headers() {
    local url="$1"
    shift
    
    if [[ -z "$url" ]]; then
        console.error "Usage: http.headers <url> [options]"
        return 1
    fi
    
    local headers=()
    
    # Parse options
    for arg in "$@"; do
        case $arg in
            --header=*) headers+=("${arg#*=}") ;;
            *) ;;
        esac
    done
    
    local curl_opts=(
        "--silent"
        "--show-error"
        "--location"
        "--max-time" "${__HTTP__DEFAULT_TIMEOUT}"
        "--head"
    )
    
    # Add headers
    for header in "${headers[@]}"; do
        curl_opts+=("--header" "$header")
    done
    
    curl "${curl_opts[@]}" "$url" 2>/dev/null
}

# Internal request processor
function http.__request() {
    local method="$1"
    local url="$2"
    shift 2
    
    if [[ -z "$url" ]]; then
        console.error "Usage: http.$method <url> [options]"
        return 1
    fi
    
    local timeout="${__HTTP__DEFAULT_TIMEOUT}"
    local headers=()
    local data=""
    local data_urlencode=()
    local insecure=false
    local show_status=false
    
    # Parse options
    for arg in "$@"; do
        case $arg in
            --timeout=*) timeout="${arg#*=}" ;;
            --header=*) headers+=("${arg#*=}") ;;
            --data=*) data="${arg#*=}" ;;
            --data-urlencode=*) data_urlencode+=("${arg#*=}") ;;
            --insecure) insecure=true ;;
            --show-status) show_status=true ;;
            *) ;;
        esac
    done
    
    # Build curl command
    local curl_opts=(
        "--silent"
        "--show-error"
        "--location"
        "--max-time" "$timeout"
        "--request" "$method"
    )
    
    # Add insecure flag if requested
    if [[ "$insecure" == "true" ]]; then
        curl_opts+=("--insecure")
    fi
    
    # Add headers
    for header in "${headers[@]}"; do
        curl_opts+=("--header" "$header")
    done
    
    # Add data
    if [[ -n "$data" ]]; then
        curl_opts+=("--data" "$data")
    fi
    
    # Add URL-encoded data
    for item in "${data_urlencode[@]}"; do
        curl_opts+=("--data-urlencode" "$item")
    done
    
    # Add status code output if requested
    if [[ "$show_status" == "true" ]]; then
        curl_opts+=("--write-out" "HTTPSTATUS:%{http_code}")
    fi
    
    # Execute request
    local response
    if [[ "$show_status" == "true" ]]; then
        response=$(curl "${curl_opts[@]}" "$url" 2>&1)
        local http_status=$(echo "$response" | grep -o 'HTTPSTATUS:[0-9]*' | cut -d: -f2)
        response=$(echo "$response" | sed '/HTTPSTATUS:/d')
        echo "$response"
        return $([[ "$http_status" =~ ^[23][0-9][0-9]$ ]] && echo 0 || echo 1)
    else
        curl "${curl_opts[@]}" "$url" 2>&1
    fi
}

##
## (Usage) Set default timeout for HTTP requests
## Examples:
##   http.set_timeout 60
##
function http.set_timeout() {
    if [[ -n "$1" && "$1" =~ ^[0-9]+$ ]]; then
        __HTTP__DEFAULT_TIMEOUT="$1"
        console.info "HTTP timeout set to ${__HTTP__DEFAULT_TIMEOUT} seconds"
    else
        console.error "Invalid timeout value. Must be a positive integer."
        return 1
    fi
}

##
## (Usage) Set default retry count for downloads
## Examples:
##   http.set_retries 5
##
function http.set_retries() {
    if [[ -n "$1" && "$1" =~ ^[0-9]+$ ]]; then
        __HTTP__DEFAULT_RETRIES="$1"
        console.info "HTTP retry count set to ${__HTTP__DEFAULT_RETRIES}"
    else
        console.error "Invalid retry count. Must be a positive integer."
        return 1
    fi
}

##
## (Usage) Show HTTP module help
##
function http.help() {
    cat <<EOF
HTTP Module - Comprehensive HTTP client for bash-lib

Available Functions:
  http.get <url> [options]           - Perform GET request
  http.post <url> [options]          - Perform POST request
  http.put <url> [options]           - Perform PUT request
  http.delete <url> [options]        - Perform DELETE request
  http.download <url> <path> [opts]  - Download file with retries
  http.check <url> [options]         - Check if URL is accessible
  http.status <url>                  - Get HTTP status code
  http.is_404 <url>                  - Check if URL returns 404
  http.is_200 <url>                  - Check if URL returns 200
  http.headers <url> [options]       - Get response headers
  http.set_timeout <seconds>         - Set default timeout
  http.set_retries <count>           - Set default retry count
  http.help                          - Show this help

Options:
  --timeout=<seconds>     - Request timeout (default: ${__HTTP__DEFAULT_TIMEOUT})
  --retries=<count>       - Download retry count (default: ${__HTTP__DEFAULT_RETRIES})
  --header="key:value"    - Add HTTP header
  --data="content"        - POST/PUT data
  --data-urlencode="k=v"  - URL-encoded form data
  --insecure             - Skip SSL verification
  --show-status          - Include HTTP status in output

Examples:
  http.get https://api.example.com/data
  http.post https://api.example.com/submit --data='{"key":"value"}'
  http.download https://example.com/file.zip /tmp/file.zip
  http.check https://example.com
  if http.is_200 https://example.com; then echo "Site is up"; fi
EOF
}
