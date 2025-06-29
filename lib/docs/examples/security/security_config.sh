#!/bin/bash

# Comprehensive Security Configuration Script
# Demonstrates real-world firewall setup for different server types

# Import required modules
import firewall
import console
import network
import string

# Configuration
SERVER_TYPE="${1:-web}"
VERBOSE="${2:-false}"

# Set console verbosity
if [[ "$VERBOSE" == "true" ]]; then
    console.set_verbosity debug
else
    console.set_verbosity info
fi

echo "=== Security Configuration Script ==="
echo "Server Type: $SERVER_TYPE"
echo

# Function to validate server type
validate_server_type() {
    local valid_types=("web" "database" "mail" "ssh" "development" "minimal")
    for type in "${valid_types[@]}"; do
        if [[ "$SERVER_TYPE" == "$type" ]]; then
            return 0
        fi
    done
    return 1
}

# Function to get server configuration
get_server_config() {
    local server_type="$1"

    case $server_type in
    "web")
        echo "Web Server Configuration"
        echo "  - HTTP/HTTPS ports"
        echo "  - SSH access"
        echo "  - Basic security rules"
        ;;
    "database")
        echo "Database Server Configuration"
        echo "  - Database ports (MySQL/PostgreSQL)"
        echo "  - SSH access"
        echo "  - Restricted access"
        ;;
    "mail")
        echo "Mail Server Configuration"
        echo "  - SMTP/IMAP/POP3 ports"
        echo "  - SSH access"
        echo "  - Anti-spam rules"
        ;;
    "ssh")
        echo "SSH Gateway Configuration"
        echo "  - SSH port only"
        echo "  - Strict access control"
        echo "  - Logging enabled"
        ;;
    "development")
        echo "Development Server Configuration"
        echo "  - Multiple service ports"
        echo "  - SSH access"
        echo "  - Development tools"
        ;;
    "minimal")
        echo "Minimal Security Configuration"
        echo "  - SSH access only"
        echo "  - Deny all other traffic"
        ;;
    *)
        echo "Unknown server type"
        ;;
    esac
}

# Function to configure web server
configure_web_server() {
    console.info "Configuring Web Server Security..."

    # Allow web ports
    firewall.allow_port 80 --protocol=tcp --description="HTTP"
    firewall.allow_port 443 --protocol=tcp --description="HTTPS"

    # Allow SSH
    firewall.allow_port 22 --protocol=tcp --description="SSH"

    # Deny dangerous ports
    firewall.deny_port 23 --protocol=tcp --description="Telnet"
    firewall.deny_port 21 --protocol=tcp --description="FTP"
    firewall.deny_port 3389 --protocol=tcp --description="RDP"

    console.success "Web server security configured"
}

# Function to configure database server
configure_database_server() {
    console.info "Configuring Database Server Security..."

    # Allow database ports
    firewall.allow_port 3306 --protocol=tcp --description="MySQL"
    firewall.allow_port 5432 --protocol=tcp --description="PostgreSQL"
    firewall.allow_port 27017 --protocol=tcp --description="MongoDB"

    # Allow SSH
    firewall.allow_port 22 --protocol=tcp --description="SSH"

    # Deny all other ports
    firewall.deny_port 80 --protocol=tcp --description="HTTP"
    firewall.deny_port 443 --protocol=tcp --description="HTTPS"

    console.success "Database server security configured"
}

# Function to configure mail server
configure_mail_server() {
    console.info "Configuring Mail Server Security..."

    # Allow mail ports
    firewall.allow_port 25 --protocol=tcp --description="SMTP"
    firewall.allow_port 587 --protocol=tcp --description="SMTP Submission"
    firewall.allow_port 465 --protocol=tcp --description="SMTPS"
    firewall.allow_port 110 --protocol=tcp --description="POP3"
    firewall.allow_port 995 --protocol=tcp --description="POP3S"
    firewall.allow_port 143 --protocol=tcp --description="IMAP"
    firewall.allow_port 993 --protocol=tcp --description="IMAPS"

    # Allow SSH
    firewall.allow_port 22 --protocol=tcp --description="SSH"

    # Allow webmail
    firewall.allow_port 80 --protocol=tcp --description="HTTP"
    firewall.allow_port 443 --protocol=tcp --description="HTTPS"

    console.success "Mail server security configured"
}

# Function to configure SSH gateway
configure_ssh_gateway() {
    console.info "Configuring SSH Gateway Security..."

    # Allow SSH only
    firewall.allow_port 22 --protocol=tcp --description="SSH"

    # Deny all other common ports
    firewall.deny_port 80 --protocol=tcp --description="HTTP"
    firewall.deny_port 443 --protocol=tcp --description="HTTPS"
    firewall.deny_port 3306 --protocol=tcp --description="MySQL"
    firewall.deny_port 5432 --protocol=tcp --description="PostgreSQL"

    console.success "SSH gateway security configured"
}

# Function to configure development server
configure_development_server() {
    console.info "Configuring Development Server Security..."

    # Allow development ports
    firewall.allow_port 22 --protocol=tcp --description="SSH"
    firewall.allow_port 80 --protocol=tcp --description="HTTP"
    firewall.allow_port 443 --protocol=tcp --description="HTTPS"
    firewall.allow_port 3000 --protocol=tcp --description="Node.js"
    firewall.allow_port 8080 --protocol=tcp --description="Alternative HTTP"
    firewall.allow_port 3306 --protocol=tcp --description="MySQL"
    firewall.allow_port 5432 --protocol=tcp --description="PostgreSQL"
    firewall.allow_port 6379 --protocol=tcp --description="Redis"
    firewall.allow_port 27017 --protocol=tcp --description="MongoDB"

    console.success "Development server security configured"
}

# Function to configure minimal security
configure_minimal_security() {
    console.info "Configuring Minimal Security..."

    # Allow SSH only
    firewall.allow_port 22 --protocol=tcp --description="SSH"

    # Deny everything else
    firewall.deny_port 80 --protocol=tcp --description="HTTP"
    firewall.deny_port 443 --protocol=tcp --description="HTTPS"
    firewall.deny_port 3306 --protocol=tcp --description="MySQL"
    firewall.deny_port 5432 --protocol=tcp --description="PostgreSQL"

    console.success "Minimal security configured"
}

# Function to apply common security rules
apply_common_security() {
    console.info "Applying Common Security Rules..."

    # Block common attack ports
    firewall.deny_port 23 --protocol=tcp --description="Telnet"
    firewall.deny_port 21 --protocol=tcp --description="FTP"
    firewall.deny_port 3389 --protocol=tcp --description="RDP"
    firewall.deny_port 1433 --protocol=tcp --description="MSSQL"
    firewall.deny_port 1521 --protocol=tcp --description="Oracle"

    # Block suspicious IP ranges (example)
    # firewall.deny_ip 192.168.1.200 --description="Suspicious IP"

    console.success "Common security rules applied"
}

# Function to validate configuration
validate_configuration() {
    console.info "Validating Security Configuration..."

    local backend=$(firewall.get_backend)
    local is_running=$(firewall.is_running && echo "Yes" || echo "No")

    console.info "Firewall Backend: $backend"
    console.info "Firewall Running: $is_running"

    # Test critical ports
    local_ip=$(network.local_ip)

    if network.port_open "$local_ip" 22; then
        console.success "SSH port (22) is accessible"
    else
        console.warn "SSH port (22) is not accessible"
    fi

    if [[ "$SERVER_TYPE" == "web" ]]; then
        if network.port_open "$local_ip" 80; then
            console.success "HTTP port (80) is accessible"
        else
            console.warn "HTTP port (80) is not accessible"
        fi
    fi

    console.success "Configuration validation complete"
}

# Main execution
main() {
    # Validate server type
    if ! validate_server_type; then
        console.error "Invalid server type: $SERVER_TYPE"
        console.info "Valid types: web, database, mail, ssh, development, minimal"
        exit 1
    fi

    # Show configuration plan
    console.info "Configuration Plan:"
    get_server_config "$SERVER_TYPE"
    echo

    # Detect firewall backend
    console.info "Detecting firewall backend..."
    if ! firewall.detect_backend; then
        console.error "Failed to detect firewall backend"
        exit 1
    fi

    console.success "Using firewall backend: $(firewall.get_backend)"
    echo

    # Start firewall if not running
    if ! firewall.is_running; then
        console.info "Starting firewall service..."
        firewall.start --enable
    fi

    # Apply server-specific configuration
    case $SERVER_TYPE in
    "web")
        configure_web_server
        ;;
    "database")
        configure_database_server
        ;;
    "mail")
        configure_mail_server
        ;;
    "ssh")
        configure_ssh_gateway
        ;;
    "development")
        configure_development_server
        ;;
    "minimal")
        configure_minimal_security
        ;;
    esac

    # Apply common security rules
    apply_common_security

    echo

    # Show final configuration
    console.info "Final Firewall Configuration:"
    firewall.list_rules --format=table

    echo

    # Validate configuration
    validate_configuration

    echo
    console.success "Security configuration for $SERVER_TYPE server completed successfully!"
    console.info "Review the configuration and test connectivity before deploying to production."
}

# Run main function
main "$@"
