#!/bin/bash

# Example: HTTP Authentication
# This demonstrates different authentication methods

# Import bash-lib
source core/init.sh
import http
import console

echo "=== HTTP Authentication ==="

# Request with basic authentication
echo ""
echo "=== Basic Authentication ==="
# Note: Using httpbin.org/basic-auth for demonstration
response=$(http.get "https://httpbin.org/basic-auth/user/passwd" "" "user:passwd")
console.info "Authenticated request response:"
echo "$response" | head -5

# Request with custom user agent
echo ""
echo "=== Custom User Agent ==="
custom_headers="User-Agent: bash-lib/1.0.0 (Example Script)"
response=$(http.get "https://httpbin.org/user-agent" "$custom_headers")
console.info "Custom user agent response:"
echo "$response" | head -5

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

# Request with authorization header
echo ""
echo "=== Authorization Header ==="
auth_headers="Authorization: Bearer token123"
response=$(http.get "https://httpbin.org/headers" "$auth_headers")
console.info "Authorization header response:"
echo "$response" | head -10

# Request with API key
echo ""
echo "=== API Key Authentication ==="
api_key_headers="X-API-Key: your-api-key-here"
response=$(http.get "https://httpbin.org/headers" "$api_key_headers")
console.info "API key response:"
echo "$response" | head -10

# Multiple authentication headers
echo ""
echo "=== Multiple Authentication Headers ==="
multi_auth_headers="Authorization: Bearer token123
X-API-Key: your-api-key-here
Cookie: session=abc123"
response=$(http.get "https://httpbin.org/headers" "$multi_auth_headers")
console.info "Multiple auth headers response:"
echo "$response" | head -10

echo ""
echo "=== HTTP Authentication Example Complete ===" 