#!/bin/bash

# Firewall Module for bash-lib
# Provides unified firewall management across different backends

# Module import signal using scoped naming
export BASH_LIB_IMPORTED_firewall="1"

# Call import.meta.loaded if the function exists
if command -v import.meta.loaded >/dev/null 2>&1; then
    import.meta.loaded "firewall" "${BASH__PATH:-/opt/bash-lib}/modules/security/firewall.mod.sh" "1.0.0" 2>/dev/null || true
fi

import console
import string
import process

# Firewall Module Configuration
__FIREWALL__DEFAULT_BACKEND="auto"
__FIREWALL__DEFAULT_ZONE="public"
__FIREWALL__DEFAULT_TIMEOUT=30

# Firewall backend detection
declare -A FIREWALL_BACKENDS
FIREWALL_BACKENDS["iptables"]="iptables"
FIREWALL_BACKENDS["firewalld"]="firewall-cmd"
FIREWALL_BACKENDS["ufw"]="ufw"

# Current backend
FIREWALL_CURRENT_BACKEND=""

##
## (Usage) Detect and set firewall backend
## Examples:
##   firewall.detect_backend
##   firewall.detect_backend --prefer=firewalld
##
function firewall.detect_backend() {
    local prefer_backend=""

    # Parse options
    for arg in "$@"; do
        case $arg in
        --prefer=*) prefer_backend="${arg#*=}" ;;
        *) ;;
        esac
    done

    # Check preferred backend first if specified
    if [[ -n "$prefer_backend" ]]; then
        if firewall.__check_backend "$prefer_backend"; then
            FIREWALL_CURRENT_BACKEND="$prefer_backend"
            console.info "Using preferred firewall backend: $prefer_backend"
            return 0
        else
            console.warn "Preferred backend '$prefer_backend' not available"
        fi
    fi

    # Auto-detect backend
    for backend in "firewalld" "ufw" "iptables"; do
        if firewall.__check_backend "$backend"; then
            FIREWALL_CURRENT_BACKEND="$backend"
            console.info "Detected firewall backend: $backend"
            return 0
        fi
    done

    console.error "No supported firewall backend found"
    return 1
}

##
## (Usage) Get current firewall backend
## Examples:
##   current_backend=$(firewall.get_backend)
##
function firewall.get_backend() {
    if [[ -z "$FIREWALL_CURRENT_BACKEND" ]]; then
        firewall.detect_backend
    fi
    echo "$FIREWALL_CURRENT_BACKEND"
}

##
## (Usage) Check if firewall service is running
## Examples:
##   firewall.is_running
##   if firewall.is_running; then echo "Firewall active"; fi
##
function firewall.is_running() {
    local backend=$(firewall.get_backend)

    case $backend in
    "firewalld")
        systemctl is-active --quiet firewalld
        ;;
    "ufw")
        ufw status | grep -q "Status: active"
        ;;
    "iptables")
        # For iptables, check if there are any rules
        iptables -L | grep -q -v "Chain INPUT (policy ACCEPT)"
        ;;
    *)
        return 1
        ;;
    esac
}

##
## (Usage) Start firewall service
## Examples:
##   firewall.start
##   firewall.start --enable
##
function firewall.start() {
    local enable_service=false

    # Parse options
    for arg in "$@"; do
        case $arg in
        --enable) enable_service=true ;;
        *) ;;
        esac
    done

    local backend=$(firewall.get_backend)

    case $backend in
    "firewalld")
        if [[ "$enable_service" == true ]]; then
            systemctl enable firewalld
        fi
        systemctl start firewalld
        ;;
    "ufw")
        if [[ "$enable_service" == true ]]; then
            ufw --force enable
        else
            ufw enable
        fi
        ;;
    "iptables")
        console.info "iptables is stateless, no service to start"
        ;;
    *)
        console.error "Unsupported backend: $backend"
        return 1
        ;;
    esac
}

##
## (Usage) Stop firewall service
## Examples:
##   firewall.stop
##   firewall.stop --disable
##
function firewall.stop() {
    local disable_service=false

    # Parse options
    for arg in "$@"; do
        case $arg in
        --disable) disable_service=true ;;
        *) ;;
        esac
    done

    local backend=$(firewall.get_backend)

    case $backend in
    "firewalld")
        systemctl stop firewalld
        if [[ "$disable_service" == true ]]; then
            systemctl disable firewalld
        fi
        ;;
    "ufw")
        ufw disable
        ;;
    "iptables")
        console.info "iptables is stateless, no service to stop"
        ;;
    *)
        console.error "Unsupported backend: $backend"
        return 1
        ;;
    esac
}

##
## (Usage) Get firewall status
## Examples:
##   firewall.status
##   firewall.status --verbose
##
function firewall.status() {
    local verbose=false

    # Parse options
    for arg in "$@"; do
        case $arg in
        --verbose | -v) verbose=true ;;
        *) ;;
        esac
    done

    local backend=$(firewall.get_backend)

    console.info "Firewall Status:"
    console.info "  Backend: $backend"
    console.info "  Running: $(firewall.is_running && echo "Yes" || echo "No")"

    if [[ "$verbose" == true ]]; then
        case $backend in
        "firewalld")
            firewall-cmd --state
            firewall-cmd --list-all
            ;;
        "ufw")
            ufw status verbose
            ;;
        "iptables")
            iptables -L -v -n
            ;;
        esac
    fi
}

##
## (Usage) Allow port through firewall
## Examples:
##   firewall.allow_port 80
##   firewall.allow_port 443 --protocol=tcp
##   firewall.allow_port 8080 --zone=internal
##
function firewall.allow_port() {
    local port="$1"
    shift

    local protocol="tcp"
    local zone="${__FIREWALL__DEFAULT_ZONE}"
    local source=""
    local description=""

    # Parse options
    for arg in "$@"; do
        case $arg in
        --protocol=*) protocol="${arg#*=}" ;;
        --zone=*) zone="${arg#*=}" ;;
        --source=*) source="${arg#*=}" ;;
        --description=*) description="${arg#*=}" ;;
        *) ;;
        esac
    done

    if [[ -z "$port" ]]; then
        console.error "Port is required"
        return 1
    fi

    if ! [[ "$port" =~ ^[0-9]+$ ]]; then
        console.error "Port must be a number"
        return 1
    fi

    local backend=$(firewall.get_backend)

    case $backend in
    "firewalld")
        firewall.__firewalld_allow_port "$port" "$protocol" "$zone" "$source"
        ;;
    "ufw")
        firewall.__ufw_allow_port "$port" "$protocol" "$source"
        ;;
    "iptables")
        firewall.__iptables_allow_port "$port" "$protocol" "$source"
        ;;
    *)
        console.error "Unsupported backend: $backend"
        return 1
        ;;
    esac
}

##
## (Usage) Deny port through firewall
## Examples:
##   firewall.deny_port 22
##   firewall.deny_port 3306 --protocol=tcp
##
function firewall.deny_port() {
    local port="$1"
    shift

    local protocol="tcp"
    local zone="${__FIREWALL__DEFAULT_ZONE}"
    local source=""

    # Parse options
    for arg in "$@"; do
        case $arg in
        --protocol=*) protocol="${arg#*=}" ;;
        --zone=*) zone="${arg#*=}" ;;
        --source=*) source="${arg#*=}" ;;
        *) ;;
        esac
    done

    if [[ -z "$port" ]]; then
        console.error "Port is required"
        return 1
    fi

    local backend=$(firewall.get_backend)

    case $backend in
    "firewalld")
        firewall.__firewalld_deny_port "$port" "$protocol" "$zone" "$source"
        ;;
    "ufw")
        firewall.__ufw_deny_port "$port" "$protocol" "$source"
        ;;
    "iptables")
        firewall.__iptables_deny_port "$port" "$protocol" "$source"
        ;;
    *)
        console.error "Unsupported backend: $backend"
        return 1
        ;;
    esac
}

##
## (Usage) Allow IP address through firewall
## Examples:
##   firewall.allow_ip 192.168.1.100
##   firewall.allow_ip 10.0.0.0/24 --zone=trusted
##
function firewall.allow_ip() {
    local ip="$1"
    shift

    local zone="${__FIREWALL__DEFAULT_ZONE}"
    local description=""

    # Parse options
    for arg in "$@"; do
        case $arg in
        --zone=*) zone="${arg#*=}" ;;
        --description=*) description="${arg#*=}" ;;
        *) ;;
        esac
    done

    if [[ -z "$ip" ]]; then
        console.error "IP address is required"
        return 1
    fi

    local backend=$(firewall.get_backend)

    case $backend in
    "firewalld")
        firewall.__firewalld_allow_ip "$ip" "$zone"
        ;;
    "ufw")
        firewall.__ufw_allow_ip "$ip"
        ;;
    "iptables")
        firewall.__iptables_allow_ip "$ip"
        ;;
    *)
        console.error "Unsupported backend: $backend"
        return 1
        ;;
    esac
}

##
## (Usage) Deny IP address through firewall
## Examples:
##   firewall.deny_ip 192.168.1.200
##   firewall.deny_ip 10.0.0.0/24
##
function firewall.deny_ip() {
    local ip="$1"
    shift

    local zone="${__FIREWALL__DEFAULT_ZONE}"

    # Parse options
    for arg in "$@"; do
        case $arg in
        --zone=*) zone="${arg#*=}" ;;
        *) ;;
        esac
    done

    if [[ -z "$ip" ]]; then
        console.error "IP address is required"
        return 1
    fi

    local backend=$(firewall.get_backend)

    case $backend in
    "firewalld")
        firewall.__firewalld_deny_ip "$ip" "$zone"
        ;;
    "ufw")
        firewall.__ufw_deny_ip "$ip"
        ;;
    "iptables")
        firewall.__iptables_deny_ip "$ip"
        ;;
    *)
        console.error "Unsupported backend: $backend"
        return 1
        ;;
    esac
}

##
## (Usage) List firewall rules
## Examples:
##   firewall.list_rules
##   firewall.list_rules --zone=public
##
function firewall.list_rules() {
    local zone="${__FIREWALL__DEFAULT_ZONE}"
    local format="table"

    # Parse options
    for arg in "$@"; do
        case $arg in
        --zone=*) zone="${arg#*=}" ;;
        --format=*) format="${arg#*=}" ;;
        *) ;;
        esac
    done

    local backend=$(firewall.get_backend)

    case $backend in
    "firewalld")
        firewall.__firewalld_list_rules "$zone" "$format"
        ;;
    "ufw")
        firewall.__ufw_list_rules "$format"
        ;;
    "iptables")
        firewall.__iptables_list_rules "$format"
        ;;
    *)
        console.error "Unsupported backend: $backend"
        return 1
        ;;
    esac
}

##
## (Usage) Remove firewall rule
## Examples:
##   firewall.remove_rule "allow port 80"
##   firewall.remove_rule "deny ip 192.168.1.100"
##
function firewall.remove_rule() {
    local rule_description="$1"

    if [[ -z "$rule_description" ]]; then
        console.error "Rule description is required"
        return 1
    fi

    local backend=$(firewall.get_backend)

    case $backend in
    "firewalld")
        firewall.__firewalld_remove_rule "$rule_description"
        ;;
    "ufw")
        firewall.__ufw_remove_rule "$rule_description"
        ;;
    "iptables")
        firewall.__iptables_remove_rule "$rule_description"
        ;;
    *)
        console.error "Unsupported backend: $backend"
        return 1
        ;;
    esac
}

##
## (Usage) Reset firewall to default state
## Examples:
##   firewall.reset
##   firewall.reset --confirm
##
function firewall.reset() {
    local confirm=false

    # Parse options
    for arg in "$@"; do
        case $arg in
        --confirm) confirm=true ;;
        *) ;;
        esac
    done

    if [[ "$confirm" != true ]]; then
        console.warn "This will reset all firewall rules. Use --confirm to proceed."
        return 1
    fi

    local backend=$(firewall.get_backend)

    case $backend in
    "firewalld")
        firewall-cmd --reload
        ;;
    "ufw")
        ufw --force reset
        ;;
    "iptables")
        iptables -F
        iptables -X
        iptables -t nat -F
        iptables -t nat -X
        iptables -t mangle -F
        iptables -t mangle -X
        iptables -P INPUT ACCEPT
        iptables -P FORWARD ACCEPT
        iptables -P OUTPUT ACCEPT
        ;;
    *)
        console.error "Unsupported backend: $backend"
        return 1
        ;;
    esac

    console.success "Firewall reset to default state"
}

# Internal helper functions

function firewall.__check_backend() {
    local backend="$1"

    case $backend in
    "firewalld")
        command -v firewall-cmd >/dev/null 2>&1 && systemctl is-available firewalld >/dev/null 2>&1
        ;;
    "ufw")
        command -v ufw >/dev/null 2>&1
        ;;
    "iptables")
        command -v iptables >/dev/null 2>&1
        ;;
    *)
        return 1
        ;;
    esac
}

# Firewalld backend functions
function firewall.__firewalld_allow_port() {
    local port="$1"
    local protocol="$2"
    local zone="$3"
    local source="$4"

    if [[ -n "$source" ]]; then
        firewall-cmd --permanent --zone="$zone" --add-rich-rule="rule family=ipv4 source address=$source port protocol=$protocol port=$port accept"
    else
        firewall-cmd --permanent --zone="$zone" --add-port="$port/$protocol"
    fi

    firewall-cmd --reload
    console.success "Allowed $protocol port $port in zone $zone"
}

function firewall.__firewalld_deny_port() {
    local port="$1"
    local protocol="$2"
    local zone="$3"
    local source="$4"

    if [[ -n "$source" ]]; then
        firewall-cmd --permanent --zone="$zone" --add-rich-rule="rule family=ipv4 source address=$source port protocol=$protocol port=$port reject"
    else
        firewall-cmd --permanent --zone="$zone" --remove-port="$port/$protocol"
    fi

    firewall-cmd --reload
    console.success "Denied $protocol port $port in zone $zone"
}

function firewall.__firewalld_allow_ip() {
    local ip="$1"
    local zone="$2"

    firewall-cmd --permanent --zone="$zone" --add-source="$ip"
    firewall-cmd --reload
    console.success "Allowed IP $ip in zone $zone"
}

function firewall.__firewalld_deny_ip() {
    local ip="$1"
    local zone="$2"

    firewall-cmd --permanent --zone="$zone" --remove-source="$ip"
    firewall-cmd --reload
    console.success "Denied IP $ip in zone $zone"
}

function firewall.__firewalld_list_rules() {
    local zone="$1"
    local format="$2"

    if [[ "$format" == "table" ]]; then
        firewall-cmd --list-all --zone="$zone"
    else
        firewall-cmd --list-all --zone="$zone" --output=json
    fi
}

function firewall.__firewalld_remove_rule() {
    local rule_description="$1"
    console.warn "Manual rule removal required for firewalld: $rule_description"
}

# UFW backend functions
function firewall.__ufw_allow_port() {
    local port="$1"
    local protocol="$2"
    local source="$3"

    if [[ -n "$source" ]]; then
        ufw allow from "$source" to any port "$port" proto "$protocol"
    else
        ufw allow "$port/$protocol"
    fi

    console.success "Allowed $protocol port $port"
}

function firewall.__ufw_deny_port() {
    local port="$1"
    local protocol="$2"
    local source="$3"

    if [[ -n "$source" ]]; then
        ufw deny from "$source" to any port "$port" proto "$protocol"
    else
        ufw deny "$port/$protocol"
    fi

    console.success "Denied $protocol port $port"
}

function firewall.__ufw_allow_ip() {
    local ip="$1"

    ufw allow from "$ip"
    console.success "Allowed IP $ip"
}

function firewall.__ufw_deny_ip() {
    local ip="$1"

    ufw deny from "$ip"
    console.success "Denied IP $ip"
}

function firewall.__ufw_list_rules() {
    local format="$1"

    if [[ "$format" == "table" ]]; then
        ufw status numbered
    else
        ufw status verbose
    fi
}

function firewall.__ufw_remove_rule() {
    local rule_description="$1"
    console.warn "Manual rule removal required for UFW: $rule_description"
}

# iptables backend functions
function firewall.__iptables_allow_port() {
    local port="$1"
    local protocol="$2"
    local source="$3"

    if [[ -n "$source" ]]; then
        iptables -A INPUT -s "$source" -p "$protocol" --dport "$port" -j ACCEPT
    else
        iptables -A INPUT -p "$protocol" --dport "$port" -j ACCEPT
    fi

    console.success "Allowed $protocol port $port"
}

function firewall.__iptables_deny_port() {
    local port="$1"
    local protocol="$2"
    local source="$3"

    if [[ -n "$source" ]]; then
        iptables -A INPUT -s "$source" -p "$protocol" --dport "$port" -j DROP
    else
        iptables -A INPUT -p "$protocol" --dport "$port" -j DROP
    fi

    console.success "Denied $protocol port $port"
}

function firewall.__iptables_allow_ip() {
    local ip="$1"

    iptables -A INPUT -s "$ip" -j ACCEPT
    console.success "Allowed IP $ip"
}

function firewall.__iptables_deny_ip() {
    local ip="$1"

    iptables -A INPUT -s "$ip" -j DROP
    console.success "Denied IP $ip"
}

function firewall.__iptables_list_rules() {
    local format="$1"

    if [[ "$format" == "table" ]]; then
        iptables -L -v -n
    else
        iptables -L -v -n --line-numbers
    fi
}

function firewall.__iptables_remove_rule() {
    local rule_description="$1"
    console.warn "Manual rule removal required for iptables: $rule_description"
}

##
## (Usage) Show firewall module help
##
function firewall.help() {
    cat <<EOF
Firewall Module - Unified firewall management across different backends

Available Functions:
  firewall.detect_backend [options]      - Detect and set firewall backend
  firewall.get_backend                   - Get current firewall backend
  firewall.is_running                    - Check if firewall service is running
  firewall.start [options]               - Start firewall service
  firewall.stop [options]                - Stop firewall service
  firewall.status [options]              - Get firewall status
  firewall.allow_port <port> [options]   - Allow port through firewall
  firewall.deny_port <port> [options]    - Deny port through firewall
  firewall.allow_ip <ip> [options]       - Allow IP address through firewall
  firewall.deny_ip <ip> [options]        - Deny IP address through firewall
  firewall.list_rules [options]          - List firewall rules
  firewall.remove_rule <description>     - Remove firewall rule
  firewall.reset [options]               - Reset firewall to default state
  firewall.help                          - Show this help

Supported Backends:
  firewalld  - Red Hat/CentOS firewall daemon
  ufw        - Ubuntu/Debian uncomplicated firewall
  iptables   - Linux netfilter firewall

Options:
  --prefer=<backend>     - Prefer specific backend (detect_backend)
  --enable               - Enable service on boot (start)
  --disable              - Disable service on boot (stop)
  --verbose, -v          - Verbose output (status)
  --protocol=<proto>     - Protocol (tcp|udp) (allow_port, deny_port)
  --zone=<zone>          - Firewall zone (firewalld only)
  --source=<ip>          - Source IP address
  --description=<text>   - Rule description
  --format=<format>      - Output format (table|json|verbose)
  --confirm              - Confirm destructive operations (reset)

Examples:
  firewall.detect_backend --prefer=firewalld
  firewall.start --enable
  firewall.allow_port 80 --protocol=tcp --zone=public
  firewall.allow_ip 192.168.1.100 --zone=trusted
  firewall.deny_port 22 --source=10.0.0.0/24
  firewall.list_rules --zone=public --format=table
  firewall.status --verbose
  firewall.reset --confirm
EOF
}
