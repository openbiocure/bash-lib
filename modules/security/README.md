# Security Module

The Security module provides comprehensive security management capabilities for bash-lib, with a focus on firewall management across different Linux distributions.

## Modules

### Firewall Module (`firewall.mod.sh`)

A unified firewall management system that supports multiple firewall backends:

- **firewalld** - Red Hat/CentOS firewall daemon
- **ufw** - Ubuntu/Debian uncomplicated firewall
- **iptables** - Linux netfilter firewall

## Features

### Backend Detection
- Automatic detection of available firewall backends
- Preference-based backend selection
- Fallback to available backends

### Service Management
- Start/stop firewall services
- Enable/disable services on boot
- Check service status

### Port Management
- Allow/deny specific ports
- Protocol-specific rules (TCP/UDP)
- Source IP restrictions
- Zone-based configuration (firewalld)

### IP Management
- Allow/deny specific IP addresses
- Network range support (CIDR notation)
- Zone-based IP management

### Rule Management
- List current firewall rules
- Remove specific rules
- Reset firewall to default state

## Usage Examples

### Basic Setup
```bash
# Import the firewall module
import firewall

# Detect and set backend
firewall.detect_backend --prefer=firewalld

# Start firewall service
firewall.start --enable

# Check status
firewall.status --verbose
```

### Port Configuration
```bash
# Allow web ports
firewall.allow_port 80 --protocol=tcp --description="HTTP"
firewall.allow_port 443 --protocol=tcp --description="HTTPS"

# Allow SSH from specific network
firewall.allow_port 22 --protocol=tcp --source=192.168.1.0/24

# Deny dangerous ports
firewall.deny_port 23 --protocol=tcp --description="Telnet"
```

### IP Management
```bash
# Allow specific IPs
firewall.allow_ip 192.168.1.100 --description="Admin workstation"
firewall.allow_ip 10.0.0.0/24 --description="Internal network"

# Block suspicious IPs
firewall.deny_ip 192.168.1.200 --description="Suspicious activity"
```

### Rule Management
```bash
# List current rules
firewall.list_rules --format=table

# Remove specific rule
firewall.remove_rule "allow port 8080"

# Reset to default state
firewall.reset --confirm
```

## Backend-Specific Features

### firewalld
- Zone-based configuration
- Rich rules support
- Service-based rules
- Runtime and permanent rules

### ufw
- Simple rule syntax
- Application profiles
- Logging configuration
- Default policies

### iptables
- Direct rule manipulation
- Custom chains
- Advanced matching
- NAT support

## Configuration

### Environment Variables
- `__FIREWALL__DEFAULT_BACKEND` - Default backend preference
- `__FIREWALL__DEFAULT_ZONE` - Default zone for firewalld
- `__FIREWALL__DEFAULT_TIMEOUT` - Default timeout for operations

### Backend Detection Order
1. firewalld (if available and running)
2. ufw (if available)
3. iptables (fallback)

## Error Handling

The module provides comprehensive error handling:
- Backend availability checks
- Service status validation
- Rule syntax validation
- Permission checks

## Security Considerations

- Always test rules in a safe environment
- Use specific source IPs when possible
- Document rule purposes with descriptions
- Regular rule audits recommended
- Backup configurations before major changes

## Dependencies

- `console` module for logging
- `string` module for string operations
- `process` module for service management
- `network` module for connectivity tests

## Examples

See `examples/security/firewall_example.sh` for a comprehensive usage example.

## Help

Get help for any function:
```bash
firewall.help
```

Or for specific functions:
```bash
firewall.allow_port --help
firewall.status --help
```
