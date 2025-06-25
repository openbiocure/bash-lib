#!/bin/bash

# Example: Users Module
# This demonstrates the user management functionality

# Import bash-lib
source core/init.sh
import users
import console

echo "=== Users Module Example ==="

echo ""
echo "=== Current User Information ==="

# Get current user
console.info "Current user operations..."
current_user=$(users.current)
console.info "Current user: $current_user"

# Get current user ID
user_id=$(users.currentId)
console.info "Current user ID: $user_id"

# Get current user home directory
home_dir=$(users.currentHome)
console.info "Current user home: $home_dir"

# Get current user shell
user_shell=$(users.currentShell)
console.info "Current user shell: $user_shell"

# Get current user groups
user_groups=$(users.currentGroups)
console.info "Current user groups: $user_groups"

echo ""
echo "=== User Information ==="

# Get user information
console.info "Getting user information..."
user_info=$(users.info "$current_user")
console.info "User information: $user_info"

# Check if user exists
console.info "Checking user existence..."
if users.exists "$current_user"; then
    console.success "User '$current_user' exists"
else
    console.error "User '$current_user' does not exist"
fi

# Check if user exists (non-existent user)
if users.exists "nonexistentuser123"; then
    console.error "Non-existent user found (unexpected)"
else
    console.success "Non-existent user properly detected"
fi

# Get user ID
uid=$(users.getId "$current_user")
console.info "User ID for '$current_user': $uid"

# Get user home directory
user_home=$(users.getHome "$current_user")
console.info "Home directory for '$current_user': $user_home"

# Get user shell
shell=$(users.getShell "$current_user")
console.info "Shell for '$current_user': $shell"

# Get user groups
groups=$(users.getGroups "$current_user")
console.info "Groups for '$current_user': $groups"

# Get user primary group
primary_group=$(users.getPrimaryGroup "$current_user")
console.info "Primary group for '$current_user': $primary_group"

echo ""
echo "=== User Authentication ==="

# Check if user can authenticate
console.info "Checking user authentication..."
if users.canAuthenticate "$current_user"; then
    console.success "User '$current_user' can authenticate"
else
    console.error "User '$current_user' cannot authenticate"
fi

# Check if user is locked
console.info "Checking if user is locked..."
if users.isLocked "$current_user"; then
    console.warn "User '$current_user' is locked"
else
    console.success "User '$current_user' is not locked"
fi

# Check if user account is expired
console.info "Checking if user account is expired..."
if users.isExpired "$current_user"; then
    console.warn "User '$current_user' account is expired"
else
    console.success "User '$current_user' account is not expired"
fi

# Check if user password is expired
console.info "Checking if user password is expired..."
if users.isPasswordExpired "$current_user"; then
    console.warn "User '$current_user' password is expired"
else
    console.success "User '$current_user' password is not expired"
fi

echo ""
echo "=== User Permissions ==="

# Check user permissions
console.info "Checking user permissions..."

# Check if user can read a file
test_file="/etc/passwd"
if users.canRead "$current_user" "$test_file"; then
    console.success "User '$current_user' can read '$test_file'"
else
    console.error "User '$current_user' cannot read '$test_file'"
fi

# Check if user can write to a file
test_file="/tmp/test_write"
touch "$test_file"
if users.canWrite "$current_user" "$test_file"; then
    console.success "User '$current_user' can write to '$test_file'"
else
    console.error "User '$current_user' cannot write to '$test_file'"
fi
rm -f "$test_file"

# Check if user can execute a file
test_file="/bin/ls"
if users.canExecute "$current_user" "$test_file"; then
    console.success "User '$current_user' can execute '$test_file'"
else
    console.error "User '$current_user' cannot execute '$test_file'"
fi

# Check if user has sudo privileges
console.info "Checking sudo privileges..."
if users.hasSudo "$current_user"; then
    console.success "User '$current_user' has sudo privileges"
else
    console.warn "User '$current_user' does not have sudo privileges"
fi

echo ""
echo "=== User Sessions ==="

# Get user sessions
console.info "Getting user sessions..."
sessions=$(users.getSessions "$current_user")
console.info "Sessions for '$current_user': $sessions"

# Check if user is logged in
console.info "Checking if user is logged in..."
if users.isLoggedIn "$current_user"; then
    console.success "User '$current_user' is logged in"
else
    console.warn "User '$current_user' is not logged in"
fi

# Get user login time
login_time=$(users.getLoginTime "$current_user")
console.info "Login time for '$current_user': $login_time"

# Get user last login
last_login=$(users.getLastLogin "$current_user")
console.info "Last login for '$current_user': $last_login"

echo ""
echo "=== User Management (Read-only operations) ==="

# List all users
console.info "Listing all users..."
all_users=$(users.list)
console.info "All users: $all_users"

# Count users
user_count=$(users.count)
console.info "Total number of users: $user_count"

# Get system users
system_users=$(users.getSystemUsers)
console.info "System users: $system_users"

# Get regular users
regular_users=$(users.getRegularUsers)
console.info "Regular users: $regular_users"

# Get users by group
console.info "Getting users by group..."
admin_users=$(users.getByGroup "admin" 2>/dev/null || users.getByGroup "sudo" 2>/dev/null || echo "No admin group found")
console.info "Admin users: $admin_users"

# Get users by shell
console.info "Getting users by shell..."
bash_users=$(users.getByShell "/bin/bash")
console.info "Bash users: $bash_users"

echo ""
echo "=== User Statistics ==="

# Get user statistics
console.info "Getting user statistics..."
stats=$(users.stats)
console.info "User statistics: $stats"

# Get user activity
console.info "Getting user activity..."
activity=$(users.getActivity "$current_user")
console.info "User activity: $activity"

# Get user resource usage
console.info "Getting user resource usage..."
usage=$(users.getResourceUsage "$current_user")
console.info "Resource usage: $usage"

echo ""
echo "=== User Validation ==="

# Validate username format
console.info "Validating username format..."
valid_username="testuser123"
if users.isValidUsername "$valid_username"; then
    console.success "'$valid_username' is a valid username format"
else
    console.error "'$valid_username' is not a valid username format"
fi

invalid_username="test@user"
if users.isValidUsername "$invalid_username"; then
    console.error "'$invalid_username' is valid (unexpected)"
else
    console.success "'$invalid_username' is not a valid username format"
fi

# Check if username is available
console.info "Checking username availability..."
if users.isUsernameAvailable "$valid_username"; then
    console.success "Username '$valid_username' is available"
else
    console.warn "Username '$valid_username' is not available"
fi

if users.isUsernameAvailable "$current_user"; then
    console.error "Current username is available (unexpected)"
else
    console.success "Current username is not available (expected)"
fi

echo ""
echo "=== User Comparison ==="

# Compare users
console.info "Comparing users..."
if users.equals "$current_user" "$current_user"; then
    console.success "User comparison works correctly"
else
    console.error "User comparison failed"
fi

if users.equals "$current_user" "root"; then
    console.error "Different users are equal (unexpected)"
else
    console.success "Different users are not equal"
fi

echo ""
echo "=== User Utilities ==="

# Get user display name
console.info "Getting user display name..."
display_name=$(users.getDisplayName "$current_user")
console.info "Display name: $display_name"

# Get user email (if available)
console.info "Getting user email..."
email=$(users.getEmail "$current_user")
console.info "Email: $email"

# Get user full name
console.info "Getting user full name..."
full_name=$(users.getFullName "$current_user")
console.info "Full name: $full_name"

# Get user comment
console.info "Getting user comment..."
comment=$(users.getComment "$current_user")
console.info "Comment: $comment"

# Get user creation date
console.info "Getting user creation date..."
creation_date=$(users.getCreationDate "$current_user")
console.info "Creation date: $creation_date"

echo ""
echo "=== User Security ==="

# Check password strength (if possible)
console.info "Checking password security..."
password_info=$(users.getPasswordInfo "$current_user")
console.info "Password info: $password_info"

# Check account security
console.info "Checking account security..."
security_info=$(users.getSecurityInfo "$current_user")
console.info "Security info: $security_info"

# Check login failures
console.info "Checking login failures..."
failures=$(users.getLoginFailures "$current_user")
console.info "Login failures: $failures"

echo ""
echo "=== User Module Example Complete ==="

# Note: User creation, modification, and deletion operations are not demonstrated
# as they require elevated privileges and could affect system security.
# These operations should be performed carefully in a controlled environment. 