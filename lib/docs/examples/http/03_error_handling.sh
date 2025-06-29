#!/bin/bash

# Example: HTTP Error Handling
# This demonstrates how to handle HTTP errors and timeouts

# Import bash-lib
source core/init.sh
import http
import console

echo "=== HTTP Error Handling ==="

# Error handling
echo ""
echo "=== Error Handling ==="
console.info "Testing error handling with invalid URL..."
response=$(http.get "https://invalid-domain-that-does-not-exist.com" 2>/dev/null)
if [[ $? -ne 0 ]]; then
    console.error "Expected error occurred for invalid URL"
else
    console.warn "Unexpected: invalid URL request succeeded"
fi

# Status code checking
echo ""
echo "=== Status Code Checking ==="
console.info "Testing different status codes..."

# 200 OK
response=$(http.get "https://httpbin.org/status/200")
console.info "Status 200 response: $?"

# 404 Not Found
response=$(http.get "https://httpbin.org/status/404" 2>/dev/null)
console.info "Status 404 response: $?"

# 500 Internal Server Error
response=$(http.get "https://httpbin.org/status/500" 2>/dev/null)
console.info "Status 500 response: $?"

# Request with timeout
echo ""
echo "=== Request with Timeout ==="
console.info "Making request with 5 second timeout..."
response=$(http.get "https://httpbin.org/delay/3" "" "" 5)
if [[ $? -eq 0 ]]; then
    console.success "Request completed within timeout"
else
    console.warn "Request timed out (expected for delay > timeout)"
fi

# Test timeout with longer delay
echo ""
echo "=== Timeout with Longer Delay ==="
console.info "Making request with 2 second timeout to 5 second delay..."
response=$(http.get "https://httpbin.org/delay/5" "" "" 2)
if [[ $? -eq 0 ]]; then
    console.warn "Unexpected: request completed despite timeout"
else
    console.success "Request properly timed out"
fi

# Network error simulation
echo ""
echo "=== Network Error Simulation ==="
console.info "Testing network error handling..."
response=$(http.get "https://httpbin.org/status/503" 2>/dev/null)
if [[ $? -ne 0 ]]; then
    console.error "Service unavailable (503) - expected error"
else
    console.warn "Unexpected: 503 request succeeded"
fi

# Invalid JSON handling
echo ""
echo "=== Invalid JSON Handling ==="
console.info "Testing POST with invalid JSON..."
invalid_json='{"name": "John", "email": "john@example.com", "age": "invalid"}'
response=$(http.post "https://httpbin.org/post" "$invalid_json" "application/json")
console.info "Invalid JSON POST response status: $?"

# Large payload handling
echo ""
echo "=== Large Payload Handling ==="
console.info "Testing POST with large payload..."
large_payload=$(printf '{"data": "%s"}' "$(printf 'x%.0s' {1..1000})")
response=$(http.post "https://httpbin.org/post" "$large_payload" "application/json")
console.info "Large payload POST response status: $?"

# SSL/TLS error handling
echo ""
echo "=== SSL/TLS Error Handling ==="
console.info "Testing SSL error handling with invalid certificate..."
response=$(http.get "https://expired.badssl.com/" 2>/dev/null)
if [[ $? -ne 0 ]]; then
    console.error "SSL certificate error - expected"
else
    console.warn "Unexpected: SSL request succeeded"
fi

# Rate limiting simulation
echo ""
echo "=== Rate Limiting Simulation ==="
console.info "Making multiple rapid requests to test rate limiting..."
for i in {1..5}; do
    console.info "Request $i/5"
    response=$(http.get "https://httpbin.org/delay/0.1")
    if [[ $? -eq 0 ]]; then
        console.success "Request $i completed"
    else
        console.error "Request $i failed"
    fi
    sleep 0.2
done

echo ""
echo "=== HTTP Error Handling Example Complete ===" 