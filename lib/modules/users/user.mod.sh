#!/bin/bash

# Users Module for bash-lib
# Provides comprehensive user and group management utilities

# Call import.meta.loaded if the function exists
if command -v import.meta.loaded >/dev/null 2>&1; then
    import.meta.loaded "user" "${BASH__PATH:-/opt/bash-lib}/modules/users/user.mod.sh" "1.0.0" 2>/dev/null || true
fi

import console
import string

# User management constants
USER_SHELL_BASH="/bin/bash"
USER_SHELL_ZSH="/bin/zsh"
USER_SHELL_NOLOGIN="/usr/sbin/nologin"
USER_SHELL_FALSE="/bin/false"

# Default home directory template
USER_HOME_TEMPLATE="/home"

# User types
USER_TYPE_SYSTEM="system"
USER_TYPE_REGULAR="regular"
USER_TYPE_SERVICE="service"

##
## (Usage) Create a new user
## Examples:
##   user.create username
##   user.create username --home=/custom/home --shell=/bin/zsh
##
function user.create() {
    local username="$1"
    shift

    if [[ -z "$username" ]]; then
        console.error "Username is required"
        return 1
    fi

    # Check if user already exists
    if id "$username" &>/dev/null; then
        console.error "User $username already exists"
        return 1
    fi

    local home_dir="$USER_HOME_TEMPLATE/$username"
    local shell="$USER_SHELL_BASH"
    local system_user=false
    local create_home=true
    local password=""

    # Parse options
    for arg in "$@"; do
        case $arg in
        --home=*) home_dir="${arg#*=}" ;;
        --shell=*) shell="${arg#*=}" ;;
        --system) system_user=true ;;
        --no-home) create_home=false ;;
        --password=*) password="${arg#*=}" ;;
        *) ;;
        esac
    done

    # Build useradd command
    local useradd_cmd="useradd"

    if [[ "$system_user" == "true" ]]; then
        useradd_cmd="$useradd_cmd --system"
    fi

    if [[ "$create_home" == "true" ]]; then
        useradd_cmd="$useradd_cmd --create-home"
    fi

    if [[ -n "$home_dir" ]]; then
        useradd_cmd="$useradd_cmd --home-dir $home_dir"
    fi

    if [[ -n "$shell" ]]; then
        useradd_cmd="$useradd_cmd --shell $shell"
    fi

    useradd_cmd="$useradd_cmd $username"

    # Create user
    if eval "$useradd_cmd"; then
        console.success "Created user: $username"

        # Set password if provided
        if [[ -n "$password" ]]; then
            echo "$username:$password" | chpasswd
            console.info "Set password for user: $username"
        fi

        return 0
    else
        console.error "Failed to create user: $username"
        return 1
    fi
}

##
## (Usage) Delete a user
## Examples:
##   user.delete username
##   user.delete username --remove-home
##
function user.delete() {
    local username="$1"
    shift

    if [[ -z "$username" ]]; then
        console.error "Username is required"
        return 1
    fi

    # Check if user exists
    if ! id "$username" &>/dev/null; then
        console.error "User $username does not exist"
        return 1
    fi

    local remove_home=false
    local force=false

    # Parse options
    for arg in "$@"; do
        case $arg in
        --remove-home) remove_home=true ;;
        --force) force=true ;;
        *) ;;
        esac
    done

    # Build userdel command
    local userdel_cmd="userdel"

    if [[ "$remove_home" == "true" ]]; then
        userdel_cmd="$userdel_cmd --remove"
    fi

    if [[ "$force" == "true" ]]; then
        userdel_cmd="$userdel_cmd --force"
    fi

    userdel_cmd="$userdel_cmd $username"

    # Delete user
    if eval "$userdel_cmd"; then
        console.success "Deleted user: $username"
        return 0
    else
        console.error "Failed to delete user: $username"
        return 1
    fi
}

##
## (Usage) Create a new group
## Examples:
##   user.create_group groupname
##   user.create_group groupname --system
##
function user.create_group() {
    local groupname="$1"
    shift

    if [[ -z "$groupname" ]]; then
        console.error "Group name is required"
        return 1
    fi

    # Check if group already exists
    if getent group "$groupname" &>/dev/null; then
        console.error "Group $groupname already exists"
        return 1
    fi

    local system_group=false

    # Parse options
    for arg in "$@"; do
        case $arg in
        --system) system_group=true ;;
        *) ;;
        esac
    done

    # Build groupadd command
    local groupadd_cmd="groupadd"

    if [[ "$system_group" == "true" ]]; then
        groupadd_cmd="$groupadd_cmd --system"
    fi

    groupadd_cmd="$groupadd_cmd $groupname"

    # Create group
    if eval "$groupadd_cmd"; then
        console.success "Created group: $groupname"
        return 0
    else
        console.error "Failed to create group: $groupname"
        return 1
    fi
}

##
## (Usage) Delete a group
## Examples:
##   user.delete_group groupname
##
function user.delete_group() {
    local groupname="$1"

    if [[ -z "$groupname" ]]; then
        console.error "Group name is required"
        return 1
    fi

    # Check if group exists
    if ! getent group "$groupname" &>/dev/null; then
        console.error "Group $groupname does not exist"
        return 1
    fi

    # Delete group
    if groupdel "$groupname"; then
        console.success "Deleted group: $groupname"
        return 0
    else
        console.error "Failed to delete group: $groupname"
        return 1
    fi
}

##
## (Usage) Add user to group
## Examples:
##   user.add_to_group username groupname
##
function user.add_to_group() {
    local username="$1"
    local groupname="$2"

    if [[ -z "$username" ]]; then
        console.error "Username is required"
        return 1
    fi

    if [[ -z "$groupname" ]]; then
        console.error "Group name is required"
        return 1
    fi

    # Check if user exists
    if ! id "$username" &>/dev/null; then
        console.error "User $username does not exist"
        return 1
    fi

    # Check if group exists
    if ! getent group "$groupname" &>/dev/null; then
        console.error "Group $groupname does not exist"
        return 1
    fi

    # Add user to group
    if usermod -a -G "$groupname" "$username"; then
        console.success "Added user $username to group $groupname"
        return 0
    else
        console.error "Failed to add user $username to group $groupname"
        return 1
    fi
}

##
## (Usage) Remove user from group
## Examples:
##   user.remove_from_group username groupname
##
function user.remove_from_group() {
    local username="$1"
    local groupname="$2"

    if [[ -z "$username" ]]; then
        console.error "Username is required"
        return 1
    fi

    if [[ -z "$groupname" ]]; then
        console.error "Group name is required"
        return 1
    fi

    # Check if user exists
    if ! id "$username" &>/dev/null; then
        console.error "User $username does not exist"
        return 1
    fi

    # Check if group exists
    if ! getent group "$groupname" &>/dev/null; then
        console.error "Group $groupname does not exist"
        return 1
    fi

    # Get current groups for user
    local current_groups=$(id -Gn "$username" | tr ' ' '\n' | grep -v "^$groupname$" | tr '\n' ',' | sed 's/,$//')

    # Remove user from group
    if usermod -G "$current_groups" "$username"; then
        console.success "Removed user $username from group $groupname"
        return 0
    else
        console.error "Failed to remove user $username from group $groupname"
        return 1
    fi
}

##
## (Usage) List all users
## Examples:
##   user.list
##   user.list --system-only
##
function user.list() {
    local system_only=false
    local regular_only=false

    # Parse options
    for arg in "$@"; do
        case $arg in
        --system-only) system_only=true ;;
        --regular-only) regular_only=true ;;
        *) ;;
        esac
    done

    console.info "User List:"
    console.info "=========="

    # Get user list from /etc/passwd
    while IFS=: read -r username password uid gid info home shell; do
        # Skip system users if regular_only is true
        if [[ "$regular_only" == "true" && $uid -lt 1000 ]]; then
            continue
        fi

        # Skip regular users if system_only is true
        if [[ "$system_only" == "true" && $uid -ge 1000 ]]; then
            continue
        fi

        local user_type="regular"
        if [[ $uid -lt 1000 ]]; then
            user_type="system"
        fi

        console.info "  $username (UID: $uid, GID: $gid, Type: $user_type)"
        console.info "    Home: $home"
        console.info "    Shell: $shell"
        console.info ""
    done </etc/passwd
}

##
## (Usage) List all groups
## Examples:
##   user.list_groups
##   user.list_groups --system-only
##
function user.list_groups() {
    local system_only=false
    local regular_only=false

    # Parse options
    for arg in "$@"; do
        case $arg in
        --system-only) system_only=true ;;
        --regular-only) regular_only=true ;;
        *) ;;
        esac
    done

    console.info "Group List:"
    console.info "==========="

    # Get group list from /etc/group
    while IFS=: read -r groupname password gid members; do
        # Skip system groups if regular_only is true
        if [[ "$regular_only" == "true" && $gid -lt 1000 ]]; then
            continue
        fi

        # Skip regular groups if system_only is true
        if [[ "$system_only" == "true" && $gid -ge 1000 ]]; then
            continue
        fi

        local group_type="regular"
        if [[ $gid -lt 1000 ]]; then
            group_type="system"
        fi

        console.info "  $groupname (GID: $gid, Type: $group_type)"
        if [[ -n "$members" ]]; then
            console.info "    Members: $members"
        fi
        console.info ""
    done </etc/group
}

##
## (Usage) Get user information
## Examples:
##   user.info username
##
function user.info() {
    local username="$1"

    if [[ -z "$username" ]]; then
        console.error "Username is required"
        return 1
    fi

    # Check if user exists
    if ! id "$username" &>/dev/null; then
        console.error "User $username does not exist"
        return 1
    fi

    # Get user info
    local uid=$(id -u "$username")
    local gid=$(id -g "$username")
    local groups=$(id -Gn "$username")
    local home=$(eval echo ~$username)
    local shell=$(getent passwd "$username" | cut -d: -f7)

    console.info "User Information for $username:"
    console.info "=============================="
    console.info "  Username: $username"
    console.info "  UID: $uid"
    console.info "  Primary GID: $gid"
    console.info "  Groups: $groups"
    console.info "  Home Directory: $home"
    console.info "  Shell: $shell"

    # Check if home directory exists
    if [[ -d "$home" ]]; then
        console.info "  Home Directory: Exists"
    else
        console.info "  Home Directory: Does not exist"
    fi
}

##
## (Usage) Set user password
## Examples:
##   user.set_password username newpassword
##
function user.set_password() {
    local username="$1"
    local password="$2"

    if [[ -z "$username" ]]; then
        console.error "Username is required"
        return 1
    fi

    if [[ -z "$password" ]]; then
        console.error "Password is required"
        return 1
    fi

    # Check if user exists
    if ! id "$username" &>/dev/null; then
        console.error "User $username does not exist"
        return 1
    fi

    # Set password
    if echo "$username:$password" | chpasswd; then
        console.success "Set password for user: $username"
        return 0
    else
        console.error "Failed to set password for user: $username"
        return 1
    fi
}

##
## (Usage) Show users module help
##
function user.help() {
    cat <<EOF
Users Module - User and group management utilities

Available Functions:
  user.create <username> [options]              - Create a new user
  user.delete <username> [options]              - Delete a user
  user.create_group <groupname> [options]       - Create a new group
  user.delete_group <groupname>                 - Delete a group
  user.add_to_group <username> <groupname>      - Add user to group
  user.remove_from_group <username> <groupname> - Remove user from group
  user.list [options]                           - List all users
  user.list_groups [options]                    - List all groups
  user.info <username>                          - Get user information
  user.set_password <username> <password>       - Set user password
  user.help                                     - Show this help

Create User Options:
  --home=<path>        - Set home directory
  --shell=<shell>      - Set login shell
  --system             - Create system user
  --no-home            - Don't create home directory
  --password=<pass>    - Set initial password

Delete User Options:
  --remove-home        - Remove home directory
  --force              - Force deletion

Create Group Options:
  --system             - Create system group

List Options:
  --system-only        - Show only system users/groups
  --regular-only       - Show only regular users/groups

Shell Constants:
  USER_SHELL_BASH="/bin/bash"
  USER_SHELL_ZSH="/bin/zsh"
  USER_SHELL_NOLOGIN="/usr/sbin/nologin"
  USER_SHELL_FALSE="/bin/false"

Examples:
  user.create john --home=/home/john --shell=\$USER_SHELL_BASH
  user.create_group developers
  user.add_to_group john developers
  user.list --regular-only
  user.info john
  user.set_password john mypassword
EOF
}

# Module import signal using scoped naming
export BASH_LIB_IMPORTED_user="1"
