#!/bin/bash

# Example: HTTP Module
# This demonstrates the HTTP request functionality

# Import bash-lib
source core/init.sh
import http
import console

echo "=== HTTP Module Example ==="

# Basic GET request
echo ""
echo "=== Basic GET Request ==="
console.info "Making GET request to httpbin.org/get"
response=$(http.get "https://httpbin.org/get")
console.info "Response status: $?"
console.info "Response length: ${#response} characters"
echo "Response preview: ${response:0:200}..."

# GET request with headers
echo ""
echo "=== GET Request with Headers ==="
headers="User-Agent: bash-lib-example
Accept: application/json"
response=$(http.get "https://httpbin.org/headers" "$headers")
console.info "Response with custom headers:"
echo "$response" | head -10

# POST request with JSON data
echo ""
echo "=== POST Request with JSON Data ==="
json_data='{"name": "John Doe", "email": "john@example.com", "age": 30}'
response=$(http.post "https://httpbin.org/post" "$json_data" "application/json")
console.info "POST response:"
echo "$response" | head -10

# POST request with form data
echo ""
echo "=== POST Request with Form Data ==="
form_data="name=John%20Doe&email=john@example.com&age=30"
response=$(http.post "https://httpbin.org/post" "$form_data" "application/x-www-form-urlencoded")
console.info "Form POST response:"
echo "$response" | head -10

# PUT request
echo ""
echo "=== PUT Request ==="
put_data='{"id": 1, "name": "Jane Doe", "email": "jane@example.com"}'
response=$(http.put "https://httpbin.org/put" "$put_data" "application/json")
console.info "PUT response:"
echo "$response" | head -10

# DELETE request
echo ""
echo "=== DELETE Request ==="
response=$(http.delete "https://httpbin.org/delete")
console.info "DELETE response:"
echo "$response" | head -10

# Request with authentication
echo ""
echo "=== Request with Authentication ==="
# Note: Using httpbin.org/basic-auth for demonstration
response=$(http.get "https://httpbin.org/basic-auth/user/passwd" "" "user:passwd")
console.info "Authenticated request response:"
echo "$response" | head -5

# File upload (simulated)
echo ""
echo "=== File Upload Simulation ==="
# Create a temporary file for upload simulation
temp_file=$(mktemp)
echo "This is test file content" > "$temp_file"
console.info "Created temporary file: $temp_file"

# Simulate file upload
response=$(http.post "https://httpbin.org/post" "@$temp_file" "text/plain")
console.info "File upload response:"
echo "$response" | head -10

# Clean up
rm -f "$temp_file"

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

# Request with custom user agent
echo ""
echo "=== Custom User Agent ==="
custom_headers="User-Agent: bash-lib/1.0.0 (Example Script)"
response=$(http.get "https://httpbin.org/user-agent" "$custom_headers")
console.info "Custom user agent response:"
echo "$response" | head -5

# JSON response parsing
echo ""
echo "=== JSON Response Parsing ==="
response=$(http.get "https://httpbin.org/json")
console.info "JSON response:"
echo "$response" | head -10

# Headers-only request
echo ""
echo "=== Headers-Only Request ==="
headers_response=$(http.head "https://httpbin.org/get")
console.info "Headers response:"
echo "$headers_response" | head -10

# Request with query parameters
echo ""
echo "=== Request with Query Parameters ==="
query_params="param1=value1&param2=value2&param3=value3"
response=$(http.get "https://httpbin.org/get?$query_params")
console.info "Query parameters response:"
echo "$response" | head -10

# Multiple concurrent requests (simulated)
echo ""
echo "=== Multiple Requests ==="
console.info "Making multiple requests..."

for i in {1..3}; do
    console.info "Request $i/3"
    response=$(http.get "https://httpbin.org/delay/1")
    console.success "Request $i completed"
done

# Request with cookies
echo ""
echo "=== Request with Cookies ==="
cookie_headers="Cookie: session=abc123; user=john"
response=$(http.get "https://httpbin.org/cookies" "$cookie_headers")
console.info "Cookies response:"
echo "$response" | head -5

# Request with referer
echo ""
echo "=== Request with Referer ==="
referer_headers="Referer: https://example.com"
response=$(http.get "https://httpbin.org/headers" "$referer_headers")
console.info "Referer response:"
echo "$response" | head -10

echo ""
echo "=== HTTP Module Example Complete ===" 