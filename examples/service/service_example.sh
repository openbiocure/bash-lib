#!/bin/bash

# Service Module Example
# Demonstrates service management functionality

# Source the bash-lib
source "$(dirname "$0")/../../core/init.sh"

# Import required modules
import "system/service"
import "system/console"
import "network/network"
import "http/http"

console.info "=== Service Module Example ==="

# Example 1: Start a simple HTTP server
console.section "Example 1: Starting a Python HTTP Server"

service.start web_server "python3 -m http.server 8080" \
    --port 8080 \
    --timeout 30 \
    --verbose

if [[ $? -eq 0 ]]; then
    console.success "Web server started successfully"

    # Check service health
    service.health web_server --port 8080 --verbose

    # Show service info
    service.info web_server

    # List all services
    service.list --verbose
else
    console.error "Failed to start web server"
fi

# Example 2: Start a service with custom health check
console.section "Example 2: Service with Custom Health Check"

# Create a simple health check script
cat >/tmp/health_check.sh <<'EOF'
#!/bin/bash
curl -f http://localhost:8080 >/dev/null 2>&1
EOF
chmod +x /tmp/health_check.sh

service.start api_server "python3 -m http.server 8081" \
    --health-check "/tmp/health_check.sh" \
    --timeout 20 \
    --verbose

if [[ $? -eq 0 ]]; then
    console.success "API server started with custom health check"
    service.health api_server --health-check "/tmp/health_check.sh" --verbose
fi

# Example 3: Wait for existing service
console.section "Example 3: Wait for Service Ready"

if service.is_running web_server; then
    console.info "Waiting for web server to be ready..."
    service.wait_for_ready web_server --port 8080 --timeout 10 --verbose
fi

# Example 4: Service health monitoring
console.section "Example 4: Health Monitoring"

# Monitor services for a few seconds
for i in {1..3}; do
    console.info "Health check round $i:"
    service.health web_server --port 8080
    service.health api_server --health-check "/tmp/health_check.sh"
    sleep 2
done

# Example 5: Graceful service stop
console.section "Example 5: Graceful Service Stop"

console.info "Stopping web server gracefully..."
service.stop web_server --timeout 5 --verbose

console.info "Stopping API server gracefully..."
service.stop api_server --timeout 5 --verbose

# Example 6: Force stop (if needed)
console.section "Example 6: Force Stop Example"

# Start a service that might hang
service.start test_service "sleep 1000" --timeout 5

if service.is_running test_service; then
    console.info "Force stopping test service..."
    service.stop test_service --force --verbose
fi

# Example 7: Service with URL health check
console.section "Example 7: URL Health Check"

service.start url_test "python3 -m http.server 8082" \
    --url "http://localhost:8082" \
    --timeout 15 \
    --verbose

if [[ $? -eq 0 ]]; then
    console.success "URL test service started"
    service.health url_test --url "http://localhost:8082" --verbose
    service.stop url_test --timeout 5
fi

# Example 8: Multiple services management
console.section "Example 8: Multiple Services"

# Start multiple services
service.start service1 "python3 -m http.server 8083" --port 8083 --timeout 10
service.start service2 "python3 -m http.server 8084" --port 8084 --timeout 10
service.start service3 "python3 -m http.server 8085" --port 8085 --timeout 10

# List all services
console.info "All running services:"
service.list --verbose

# Check health of all services
console.info "Health check all services:"
for service in service1 service2 service3; do
    if service.is_running "$service"; then
        service.health "$service" --port "808$((3 + $(echo "$service" | sed 's/service//')))"
    fi
done

# Stop all services
console.info "Stopping all services..."
for service in service1 service2 service3; do
    service.stop "$service" --timeout 5
done

# Final service list
console.info "Final service list:"
service.list

# Cleanup
rm -f /tmp/health_check.sh

console.success "=== Service Module Example Complete ==="
