#!/bin/bash

IMPORTED="."

import console
import string

# Permission constants for better readability
# Owner permissions
PERM_OWNER_READ=400
PERM_OWNER_WRITE=200
PERM_OWNER_EXECUTE=100
PERM_OWNER_ALL=700

# Group permissions
PERM_GROUP_READ=40
PERM_GROUP_WRITE=20
PERM_GROUP_EXECUTE=10
PERM_GROUP_ALL=70

# Others permissions
PERM_OTHERS_READ=4
PERM_OTHERS_WRITE=2
PERM_OTHERS_EXECUTE=1
PERM_OTHERS_ALL=7

# Common permission combinations
PERM_PRIVATE=600          # Owner read/write only
PERM_PRIVATE_EXEC=700     # Owner read/write/execute only
PERM_SHARED_READ=644      # Owner read/write, group/others read
PERM_SHARED_EXEC=755      # Owner read/write/execute, group/others read/execute
PERM_PUBLIC_READ=444      # Everyone read only
PERM_PUBLIC_WRITE=666     # Everyone read/write
PERM_PUBLIC_EXEC=777      # Everyone read/write/execute

# Symbolic permission constants
PERM_SYMBOLIC_READ="r"
PERM_SYMBOLIC_WRITE="w"
PERM_SYMBOLIC_EXECUTE="x"

##
## (Usage) Set file permissions using numeric mode
## Examples:
##   permissions.set /path/to/file 644
##   permissions.set /path/to/file $PERM_SHARED_READ
##
function permissions.set() {
    local path="$1"
    local mode="$2"
    
    if [[ -z "$path" ]]; then
        console.error "Path is required"
        return 1
    fi
    
    if [[ -z "$mode" ]]; then
        console.error "Permission mode is required"
        return 1
    fi
    
    if [[ ! -e "$path" ]]; then
        console.error "Path does not exist: $path"
        return 1
    fi
    
    chmod "$mode" "$path" || {
        console.error "Failed to set permissions on $path"
        return 1
    }
    
    console.success "Set permissions $mode on $path"
}

##
## (Usage) Set file permissions using symbolic mode
## Examples:
##   permissions.set_symbolic /path/to/file u+rw,g+r,o+r
##   permissions.set_symbolic /path/to/file a+x
##
function permissions.set_symbolic() {
    local path="$1"
    local mode="$2"
    
    if [[ -z "$path" ]]; then
        console.error "Path is required"
        return 1
    fi
    
    if [[ -z "$mode" ]]; then
        console.error "Symbolic permission mode is required"
        return 1
    fi
    
    if [[ ! -e "$path" ]]; then
        console.error "Path does not exist: $path"
        return 1
    fi
    
    chmod "$mode" "$path" || {
        console.error "Failed to set symbolic permissions on $path"
        return 1
    }
    
    console.success "Set symbolic permissions $mode on $path"
}

##
## (Usage) Set ownership of files/directories
## Examples:
##   permissions.own /path/to/file user:group
##   permissions.own /path/to/file user
##
function permissions.own() {
    local path="$1"
    local ownership="$2"
    
    if [[ -z "$path" ]]; then
        console.error "Path is required"
        return 1
    fi
    
    if [[ -z "$ownership" ]]; then
        console.error "Ownership (user:group or user) is required"
        return 1
    fi
    
    if [[ ! -e "$path" ]]; then
        console.error "Path does not exist: $path"
        return 1
    fi
    
    chown "$ownership" "$path" || {
        console.error "Failed to set ownership on $path"
        return 1
    }
    
    console.success "Set ownership $ownership on $path"
}

##
## (Usage) Get current permissions of a file/directory
## Examples:
##   permissions.get /path/to/file
##
function permissions.get() {
    local path="$1"
    
    if [[ -z "$path" ]]; then
        console.error "Path is required"
        return 1
    fi
    
    if [[ ! -e "$path" ]]; then
        console.error "Path does not exist: $path"
        return 1
    fi
    
    local numeric_mode=$(stat -c "%a" "$path" 2>/dev/null || stat -f "%Lp" "$path" 2>/dev/null)
    local symbolic_mode=$(stat -c "%A" "$path" 2>/dev/null || ls -ld "$path" | cut -c2-10)
    local owner=$(stat -c "%U:%G" "$path" 2>/dev/null || stat -f "%Su:%Sg" "$path" 2>/dev/null)
    
    console.info "Permissions for $path:"
    console.info "  Numeric: $numeric_mode"
    console.info "  Symbolic: $symbolic_mode"
    console.info "  Owner: $owner"
    
    echo "$numeric_mode"
}

##
## (Usage) Set recursive permissions on directories
## Examples:
##   permissions.set_recursive /path/to/dir 755
##   permissions.set_recursive /path/to/dir $PERM_SHARED_EXEC
##
function permissions.set_recursive() {
    local path="$1"
    local mode="$2"
    
    if [[ -z "$path" ]]; then
        console.error "Path is required"
        return 1
    fi
    
    if [[ -z "$mode" ]]; then
        console.error "Permission mode is required"
        return 1
    fi
    
    if [[ ! -d "$path" ]]; then
        console.error "Path is not a directory: $path"
        return 1
    fi
    
    chmod -R "$mode" "$path" || {
        console.error "Failed to set recursive permissions on $path"
        return 1
    }
    
    console.success "Set recursive permissions $mode on $path"
}

##
## (Usage) Set recursive ownership on directories
## Examples:
##   permissions.own_recursive /path/to/dir user:group
##
function permissions.own_recursive() {
    local path="$1"
    local ownership="$2"
    
    if [[ -z "$path" ]]; then
        console.error "Path is required"
        return 1
    fi
    
    if [[ -z "$ownership" ]]; then
        console.error "Ownership (user:group or user) is required"
        return 1
    fi
    
    if [[ ! -d "$path" ]]; then
        console.error "Path is not a directory: $path"
        return 1
    fi
    
    chown -R "$ownership" "$path" || {
        console.error "Failed to set recursive ownership on $path"
        return 1
    }
    
    console.success "Set recursive ownership $ownership on $path"
}

##
## (Usage) Make a file executable
## Examples:
##   permissions.make_executable /path/to/script
##
function permissions.make_executable() {
    local path="$1"
    
    if [[ -z "$path" ]]; then
        console.error "Path is required"
        return 1
    fi
    
    if [[ ! -e "$path" ]]; then
        console.error "Path does not exist: $path"
        return 1
    fi
    
    chmod +x "$path" || {
        console.error "Failed to make $path executable"
        return 1
    }
    
    console.success "Made $path executable"
}

##
## (Usage) Set secure permissions (private to owner)
## Examples:
##   permissions.secure /path/to/file
##
function permissions.secure() {
    local path="$1"
    
    if [[ -z "$path" ]]; then
        console.error "Path is required"
        return 1
    fi
    
    if [[ ! -e "$path" ]]; then
        console.error "Path does not exist: $path"
        return 1
    fi
    
    # Set to owner read/write only
    permissions.set "$path" "$PERM_PRIVATE"
}

##
## (Usage) Set public read permissions
## Examples:
##   permissions.public_read /path/to/file
##
function permissions.public_read() {
    local path="$1"
    
    if [[ -z "$path" ]]; then
        console.error "Path is required"
        return 1
    fi
    
    if [[ ! -e "$path" ]]; then
        console.error "Path does not exist: $path"
        return 1
    fi
    
    # Set to owner read/write, others read
    permissions.set "$path" "$PERM_SHARED_READ"
}

##
## (Usage) Show permissions module help
##
function permissions.help() {
    cat <<EOF
Permissions Module - File and directory permission management

Available Functions:
  permissions.set <path> <mode>                    - Set numeric permissions
  permissions.set_symbolic <path> <mode>           - Set symbolic permissions
  permissions.own <path> <user:group>              - Set ownership
  permissions.get <path>                           - Get current permissions
  permissions.set_recursive <path> <mode>          - Set recursive permissions
  permissions.own_recursive <path> <user:group>    - Set recursive ownership
  permissions.make_executable <path>               - Make file executable
  permissions.secure <path>                        - Set private permissions
  permissions.public_read <path>                   - Set public read permissions
  permissions.help                                 - Show this help

Permission Constants:
  PERM_PRIVATE=600          # Owner read/write only
  PERM_PRIVATE_EXEC=700     # Owner read/write/execute only
  PERM_SHARED_READ=644      # Owner read/write, group/others read
  PERM_SHARED_EXEC=755      # Owner read/write/execute, group/others read/execute
  PERM_PUBLIC_READ=444      # Everyone read only
  PERM_PUBLIC_WRITE=666     # Everyone read/write
  PERM_PUBLIC_EXEC=777      # Everyone read/write/execute

Examples:
  permissions.set file.txt 644
  permissions.set file.txt \$PERM_SHARED_READ
  permissions.set_symbolic file.txt u+rw,g+r,o+r
  permissions.own file.txt user:group
  permissions.get file.txt
  permissions.set_recursive /dir 755
  permissions.make_executable script.sh
  permissions.secure secret.txt
  permissions.public_read public.txt
EOF
} 