#!/bin/bash

# Firewall Module Example
# Demonstrates firewall management capabilities

# Import required modules
import firewall
import console
import network

# Set up console for better output
console.set_verbosity debug

echo "=== Firewall Module Example ==="
echo

# Detect firewall backend
console.info "Detecting firewall backend..."
if firewall.detect_backend --prefer=firewalld; then
    console.success "Firewall backend detected: $(firewall.get_backend)"
else
    console.error "Failed to detect firewall backend"
    exit 1
fi

echo

# Check firewall status
console.info "Checking firewall status..."
firewall.status --verbose

echo

# Start firewall if not running
if ! firewall.is_running; then
    console.info "Starting firewall service..."
    firewall.start --enable
else
    console.info "Firewall is already running"
fi

echo

# Allow common web ports
console.info "Configuring web server ports..."
firewall.allow_port 80 --protocol=tcp --description="HTTP"
firewall.allow_port 443 --protocol=tcp --description="HTTPS"
firewall.allow_port 8080 --protocol=tcp --description="HTTP Alternative"

echo

# Allow SSH from specific network
console.info "Configuring SSH access..."
firewall.allow_port 22 --protocol=tcp --source=192.168.1.0/24 --description="SSH from local network"

echo

# Allow database port
console.info "Configuring database access..."
firewall.allow_port 3306 --protocol=tcp --source=10.0.0.0/8 --description="MySQL from internal network"

echo

# Deny potentially dangerous ports
console.info "Blocking dangerous ports..."
firewall.deny_port 23 --protocol=tcp --description="Telnet"
firewall.deny_port 21 --protocol=tcp --description="FTP"
firewall.deny_port 3389 --protocol=tcp --description="RDP"

echo

# Allow specific IP addresses
console.info "Configuring IP-based access..."
firewall.allow_ip 192.168.1.100 --description="Admin workstation"
firewall.allow_ip 10.0.0.50 --description="Internal server"

echo

# Deny suspicious IP addresses
console.info "Blocking suspicious IPs..."
firewall.deny_ip 192.168.1.200 --description="Suspicious activity"

echo

# List current rules
console.info "Current firewall rules:"
firewall.list_rules --format=table

echo

# Test port accessibility
console.info "Testing port accessibility..."
local_ip=$(network.local_ip)

if network.port_open "$local_ip" 80; then
    console.success "Port 80 is accessible"
else
    console.warn "Port 80 is not accessible"
fi

if network.port_open "$local_ip" 22; then
    console.success "Port 22 is accessible"
else
    console.warn "Port 22 is not accessible"
fi

echo

# Demonstrate rule removal (commented out for safety)
console.info "Rule removal example (commented out for safety):"
console.info "# firewall.remove_rule 'allow port 8080'"

echo

# Show firewall status summary
console.info "Final firewall status:"
firewall.status

echo
console.success "Firewall configuration complete!"
