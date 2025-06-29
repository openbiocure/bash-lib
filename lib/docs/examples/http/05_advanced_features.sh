#!/bin/bash

# Example: HTTP Advanced Features
# This demonstrates JSON parsing, concurrent requests, and advanced features

# Import bash-lib
source core/init.sh
import http
import console

echo "=== HTTP Advanced Features ==="

# JSON response parsing
echo ""
echo "=== JSON Response Parsing ==="
response=$(http.get "https://httpbin.org/json")
console.info "JSON response:"
echo "$response" | head -10

# Parse JSON response (basic parsing)
if [[ -n "$response" ]]; then
    # Extract specific fields using basic text processing
    slideshow_title=$(echo "$response" | grep -o '"title":"[^"]*"' | cut -d'"' -f4)
    slideshow_date=$(echo "$response" | grep -o '"date":"[^"]*"' | cut -d'"' -f4)
    
    console.info "Parsed JSON data:"
    console.info "  Title: $slideshow_title"
    console.info "  Date: $slideshow_date"
fi

# Multiple concurrent requests (simulated)
echo ""
echo "=== Multiple Requests ==="
console.info "Making multiple requests..."

for i in {1..3}; do
    console.info "Request $i/3"
    response=$(http.get "https://httpbin.org/delay/1")
    console.success "Request $i completed"
done

# Batch requests with different endpoints
echo ""
echo "=== Batch Requests ==="
endpoints=("get" "headers" "user-agent" "ip")
for endpoint in "${endpoints[@]}"; do
    console.info "Requesting /$endpoint..."
    response=$(http.get "https://httpbin.org/$endpoint")
    if [[ $? -eq 0 ]]; then
        console.success "Successfully retrieved /$endpoint"
    else
        console.error "Failed to retrieve /$endpoint"
    fi
done

# Request with different content types
echo ""
echo "=== Different Content Types ==="
content_types=("application/json" "text/plain" "application/xml" "text/html")

for content_type in "${content_types[@]}"; do
    console.info "Testing content type: $content_type"
    response=$(http.post "https://httpbin.org/post" "test data" "$content_type")
    if [[ $? -eq 0 ]]; then
        console.success "Successfully posted with $content_type"
    else
        console.error "Failed to post with $content_type"
    fi
done

# Request with custom headers
echo ""
echo "=== Custom Headers ==="
custom_headers="User-Agent: bash-lib/1.0.0
Accept: application/json
Accept-Language: en-US,en;q=0.9
Cache-Control: no-cache"
response=$(http.get "https://httpbin.org/headers" "$custom_headers")
console.info "Custom headers response:"
echo "$response" | head -10

# Request with query parameters
echo ""
echo "=== Complex Query Parameters ==="
query_params="name=John%20Doe&age=30&city=New%20York&tags=api&tags=test"
response=$(http.get "https://httpbin.org/get?$query_params")
console.info "Complex query parameters response:"
echo "$response" | head -10

# Request with different HTTP methods
echo ""
echo "=== Different HTTP Methods ==="
methods=("GET" "POST" "PUT" "DELETE" "PATCH")

for method in "${methods[@]}"; do
    console.info "Testing $method method..."
    case $method in
        "GET")
            response=$(http.get "https://httpbin.org/get")
            ;;
        "POST")
            response=$(http.post "https://httpbin.org/post" "test data" "text/plain")
            ;;
        "PUT")
            response=$(http.put "https://httpbin.org/put" "test data" "text/plain")
            ;;
        "DELETE")
            response=$(http.delete "https://httpbin.org/delete")
            ;;
        "PATCH")
            # Note: PATCH might not be available in all http modules
            response=$(http.post "https://httpbin.org/patch" "test data" "text/plain")
            ;;
    esac
    
    if [[ $? -eq 0 ]]; then
        console.success "$method method successful"
    else
        console.error "$method method failed"
    fi
done

# Request with different response formats
echo ""
echo "=== Different Response Formats ==="
formats=("json" "xml" "html" "text")

for format in "${formats[@]}"; do
    console.info "Requesting $format format..."
    response=$(http.get "https://httpbin.org/$format")
    if [[ $? -eq 0 ]]; then
        console.success "Successfully retrieved $format format"
        console.info "Response length: ${#response} characters"
    else
        console.error "Failed to retrieve $format format"
    fi
done

# Request with different status codes
echo ""
echo "=== Different Status Codes ==="
status_codes=(200 201 400 401 403 404 500)

for status in "${status_codes[@]}"; do
    console.info "Testing status code $status..."
    response=$(http.get "https://httpbin.org/status/$status" 2>/dev/null)
    exit_code=$?
    console.info "  Exit code: $exit_code"
done

# Request with different delays
echo ""
echo "=== Different Delays ==="
delays=(0 1 2 3)

for delay in "${delays[@]}"; do
    console.info "Testing delay of $delay seconds..."
    start_time=$(date +%s)
    response=$(http.get "https://httpbin.org/delay/$delay")
    end_time=$(date +%s)
    actual_delay=$((end_time - start_time))
    console.info "  Actual delay: ${actual_delay}s"
done

echo ""
echo "=== HTTP Advanced Features Example Complete ===" 