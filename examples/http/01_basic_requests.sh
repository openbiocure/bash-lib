#!/bin/bash

# Example: Basic HTTP Requests
# This demonstrates fundamental HTTP operations

# Import bash-lib
source core/init.sh
import http
import console

echo "=== Basic HTTP Requests ==="

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
response=$(http.get "https://httpbin.org/headers" --header="User-Agent: bash-lib-example" --header="Accept: application/json")
console.info "Response with custom headers:"
echo "$response" | head -10

# POST request with JSON data
echo ""
echo "=== POST Request with JSON Data ==="
json_data='{"name": "John Doe", "email": "john@example.com", "age": 30}'
response=$(http.post "https://httpbin.org/post" --data="$json_data" --header="Content-Type: application/json")
console.info "POST response:"
echo "$response" | head -10

# POST request with form data
echo ""
echo "=== POST Request with Form Data ==="
response=$(http.post "https://httpbin.org/post" --data-urlencode="name=John Doe" --data-urlencode="email=john@example.com" --data-urlencode="age=30")
console.info "Form POST response:"
echo "$response" | head -10

# PUT request
echo ""
echo "=== PUT Request ==="
put_data='{"id": 1, "name": "Jane Doe", "email": "jane@example.com"}'
response=$(http.put "https://httpbin.org/put" --data="$put_data" --header="Content-Type: application/json")
console.info "PUT response:"
echo "$response" | head -10

# DELETE request
echo ""
echo "=== DELETE Request ==="
response=$(http.delete "https://httpbin.org/delete")
console.info "DELETE response:"
echo "$response" | head -10

# Get headers only
echo ""
echo "=== Headers-Only Request ==="
headers_response=$(http.headers "https://httpbin.org/get")
console.info "Headers response:"
echo "$headers_response" | head -10

# Request with query parameters
echo ""
echo "=== Request with Query Parameters ==="
response=$(http.get "https://httpbin.org/get?param1=value1&param2=value2&param3=value3")
console.info "Query parameters response:"
echo "$response" | head -10

# Check if URL is accessible
echo ""
echo "=== URL Accessibility Check ==="
if http.check "https://httpbin.org/get"; then
    console.success "URL is accessible"
else
    console.error "URL is not accessible"
fi

echo ""
echo "=== Basic HTTP Requests Example Complete ===" 