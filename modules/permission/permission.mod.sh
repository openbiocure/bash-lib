#!/bin/bash

# Permissions Module for bash-lib
# Provides user-friendly file and directory permission management

# Module import signal using scoped naming
export BASH_LIB_IMPORTED_permission="1"

# Call import.meta.loaded if the function exists
if command -v import.meta.loaded >/dev/null 2>&1; then
    import.meta.loaded "permission" "${BASH__PATH:-/opt/bash-lib}/modules/permission/permission.mod.sh" "1.0.0" 2>/dev/null || true
fi

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
PERM_PRIVATE=600      # Owner read/write only
PERM_PRIVATE_EXEC=700 # Owner read/write/execute only
PERM_SHARED_READ=644  # Owner read/write, group/others read
PERM_SHARED_EXEC=755  # Owner read/write/execute, group/others read/execute
PERM_PUBLIC_READ=444  # Everyone read only
PERM_PUBLIC_WRITE=666 # Everyone read/write
PERM_PUBLIC_EXEC=777  # Everyone read/write/execute

# Symbolic permission constants
PERM_SYMBOLIC_READ="r"
PERM_SYMBOLIC_WRITE="w"
PERM_SYMBOLIC_EXECUTE="x"

##
## (Usage) Set file permissions using numeric mode
## Examples:
##   permission.set /path/to/file 644
##   permission.set /path/to/file $PERM_SHARED_READ
##
function permission.set() {
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
##   permission.set_symbolic /path/to/file u+rw,g+r,o+r
##   permission.set_symbolic /path/to/file a+x
##
function permission.set_symbolic() {
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
##   permission.own /path/to/file user:group
##   permission.own /path/to/file user
##
function permission.own() {
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
##   permission.get /path/to/file
##
function permission.get() {
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
##   permission.set_recursive /path/to/dir 755
##   permission.set_recursive /path/to/dir $PERM_SHARED_EXEC
##
function permission.set_recursive() {
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
##   permission.own_recursive /path/to/dir user:group
##
function permission.own_recursive() {
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
##   permission.make_executable /path/to/script
##
function permission.make_executable() {
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
##   permission.secure /path/to/file
##
function permission.secure() {
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
    permission.set "$path" "$PERM_PRIVATE"
}

##
## (Usage) Set public read permissions
## Examples:
##   permission.public_read /path/to/file
##
function permission.public_read() {
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
    permission.set "$path" "$PERM_SHARED_READ"
}

##
## (Usage) Check if a path is writable by current user
## Examples:
##   permission.check_write /path/to/file
##   permission.check_write /path/to/directory
##
function permission.check_write() {
    local path="$1"

    if [[ -z "$path" ]]; then
        console.error "Path is required"
        return 1
    fi

    if [[ ! -e "$path" ]]; then
        console.error "Path does not exist: $path"
        return 1
    fi

    if [[ -w "$path" ]]; then
        return 0
    else
        return 1
    fi
}

##
## (Usage) Check if a path is readable by current user
## Examples:
##   permission.check_read /path/to/file
##   permission.check_read /path/to/directory
##
function permission.check_read() {
    local path="$1"

    if [[ -z "$path" ]]; then
        console.error "Path is required"
        return 1
    fi

    if [[ ! -e "$path" ]]; then
        console.error "Path does not exist: $path"
        return 1
    fi

    if [[ -r "$path" ]]; then
        return 0
    else
        return 1
    fi
}

##
## (Usage) Check if a path is executable by current user
## Examples:
##   permission.check_execute /path/to/file
##   permission.check_execute /path/to/directory
##
function permission.check_execute() {
    local path="$1"

    if [[ -z "$path" ]]; then
        console.error "Path is required"
        return 1
    fi

    if [[ ! -e "$path" ]]; then
        console.error "Path does not exist: $path"
        return 1
    fi

    if [[ -x "$path" ]]; then
        return 0
    else
        return 1
    fi
}

##
## (Usage) Show permissions module help
##
function permission.help() {
    cat <<EOF
Permissions Module - File and directory permission management

Available Functions:
  permission.set <path> <mode>                    - Set numeric permissions
  permission.set_symbolic <path> <mode>           - Set symbolic permissions
  permission.own <path> <user:group>              - Set ownership
  permission.get <path>                           - Get current permissions
  permission.set_recursive <path> <mode>          - Set recursive permissions
  permission.own_recursive <path> <user:group>    - Set recursive ownership
  permission.make_executable <path>               - Make file executable
  permission.secure <path>                        - Set private permissions
  permission.public_read <path>                   - Set public read permissions
  permission.check_write <path>                   - Check if a path is writable
  permission.check_read <path>                    - Check if a path is readable
  permission.check_execute <path>                 - Check if a path is executable
  permission.help                                 - Show this help

Permission Constants:
  PERM_PRIVATE=600          # Owner read/write only
  PERM_PRIVATE_EXEC=700     # Owner read/write/execute only
  PERM_SHARED_READ=644      # Owner read/write, group/others read
  PERM_SHARED_EXEC=755      # Owner read/write/execute, group/others read/execute
  PERM_PUBLIC_READ=444      # Everyone read only
  PERM_PUBLIC_WRITE=666     # Everyone read/write
  PERM_PUBLIC_EXEC=777      # Everyone read/write/execute

Examples:
  permission.set file.txt 644
  permission.set file.txt \$PERM_SHARED_READ
  permission.set_symbolic file.txt u+rw,g+r,o+r
  permission.own file.txt user:group
  permission.get file.txt
  permission.set_recursive /dir 755
  permission.make_executable script.sh
  permission.secure secret.txt
  permission.public_read public.txt
  permission.check_write /path/to/file
  permission.check_read /path/to/directory
  permission.check_execute /path/to/file
EOF
}
