#!/bin/bash

# Example: Permissions Module
# This demonstrates the file and directory permission operations

# Import bash-lib
source core/init.sh
import permissions
import console

echo "=== Permissions Module Example ==="

# Create test directory and files
test_dir="test_permissions"
mkdir -p "$test_dir"

# Create test files
echo "Test file 1" > "$test_dir/file1.txt"
echo "Test file 2" > "$test_dir/file2.txt"
echo "Test file 3" > "$test_dir/file3.txt"

# Create test directories
mkdir -p "$test_dir/dir1"
mkdir -p "$test_dir/dir2"
mkdir -p "$test_dir/dir3"

echo ""
echo "=== Basic Permission Operations ==="

# Get file permissions
console.info "Getting file permissions..."
file_perms=$(permissions.get "$test_dir/file1.txt")
console.info "File permissions: $file_perms"

# Get directory permissions
console.info "Getting directory permissions..."
dir_perms=$(permissions.get "$test_dir/dir1")
console.info "Directory permissions: $dir_perms"

# Get permissions in different formats
console.info "Getting permissions in different formats..."
octal_perms=$(permissions.getOctal "$test_dir/file1.txt")
console.info "Octal permissions: $octal_perms"

symbolic_perms=$(permissions.getSymbolic "$test_dir/file1.txt")
console.info "Symbolic permissions: $symbolic_perms"

human_perms=$(permissions.getHuman "$test_dir/file1.txt")
console.info "Human-readable permissions: $human_perms"

echo ""
echo "=== Permission Setting ==="

# Set permissions using octal
console.info "Setting permissions using octal..."
if permissions.set "$test_dir/file1.txt" 644; then
    console.success "Set permissions to 644"
else
    console.error "Failed to set permissions"
fi

# Set permissions using symbolic
console.info "Setting permissions using symbolic..."
if permissions.setSymbolic "$test_dir/file2.txt" "rw-r--r--"; then
    console.success "Set symbolic permissions to rw-r--r--"
else
    console.error "Failed to set symbolic permissions"
fi

# Set permissions for owner only
console.info "Setting owner permissions..."
if permissions.setOwner "$test_dir/file3.txt" "rwx"; then
    console.success "Set owner permissions to rwx"
else
    console.error "Failed to set owner permissions"
fi

# Set permissions for group only
console.info "Setting group permissions..."
if permissions.setGroup "$test_dir/dir1" "r-x"; then
    console.success "Set group permissions to r-x"
else
    console.error "Failed to set group permissions"
fi

# Set permissions for others only
console.info "Setting others permissions..."
if permissions.setOthers "$test_dir/dir2" "r--"; then
    console.success "Set others permissions to r--"
else
    console.error "Failed to set others permissions"
fi

echo ""
echo "=== Permission Modification ==="

# Add permissions
console.info "Adding permissions..."
if permissions.add "$test_dir/file1.txt" "execute"; then
    console.success "Added execute permission"
else
    console.error "Failed to add execute permission"
fi

# Remove permissions
console.info "Removing permissions..."
if permissions.remove "$test_dir/file1.txt" "write"; then
    console.success "Removed write permission"
else
    console.error "Failed to remove write permission"
fi

# Add specific permissions
console.info "Adding specific permissions..."
if permissions.addOwner "$test_dir/file2.txt" "execute"; then
    console.success "Added execute permission for owner"
else
    console.error "Failed to add execute permission for owner"
fi

if permissions.addGroup "$test_dir/file2.txt" "write"; then
    console.success "Added write permission for group"
else
    console.error "Failed to add write permission for group"
fi

# Remove specific permissions
console.info "Removing specific permissions..."
if permissions.removeOthers "$test_dir/file2.txt" "read"; then
    console.success "Removed read permission for others"
else
    console.error "Failed to remove read permission for others"
fi

echo ""
echo "=== Permission Checking ==="

# Check specific permissions
console.info "Checking specific permissions..."
if permissions.canRead "$test_dir/file1.txt"; then
    console.success "File is readable"
else
    console.error "File is not readable"
fi

if permissions.canWrite "$test_dir/file1.txt"; then
    console.success "File is writable"
else
    console.error "File is not writable"
fi

if permissions.canExecute "$test_dir/file1.txt"; then
    console.success "File is executable"
else
    console.error "File is not executable"
fi

# Check permissions for specific user
console.info "Checking permissions for specific user..."
current_user=$(whoami)
if permissions.canReadAs "$test_dir/file1.txt" "$current_user"; then
    console.success "User '$current_user' can read the file"
else
    console.error "User '$current_user' cannot read the file"
fi

if permissions.canWriteAs "$test_dir/file1.txt" "$current_user"; then
    console.success "User '$current_user' can write to the file"
else
    console.error "User '$current_user' cannot write to the file"
fi

if permissions.canExecuteAs "$test_dir/file1.txt" "$current_user"; then
    console.success "User '$current_user' can execute the file"
else
    console.error "User '$current_user' cannot execute the file"
fi

echo ""
echo "=== Permission Comparison ==="

# Compare permissions
console.info "Comparing permissions..."
if permissions.equals "$test_dir/file1.txt" "$test_dir/file2.txt"; then
    console.success "Files have same permissions"
else
    console.success "Files have different permissions"
fi

# Check if permissions are more permissive
if permissions.isMorePermissive "$test_dir/file1.txt" "$test_dir/file2.txt"; then
    console.success "File1 is more permissive than file2"
else
    console.success "File1 is not more permissive than file2"
fi

# Check if permissions are more restrictive
if permissions.isMoreRestrictive "$test_dir/file1.txt" "$test_dir/file2.txt"; then
    console.success "File1 is more restrictive than file2"
else
    console.success "File1 is not more restrictive than file2"
fi

echo ""
echo "=== Special Permissions ==="

# Set special permissions
console.info "Setting special permissions..."

# Set SUID
if permissions.setSuid "$test_dir/file1.txt"; then
    console.success "Set SUID permission"
else
    console.error "Failed to set SUID permission"
fi

# Set SGID
if permissions.setSgid "$test_dir/dir1"; then
    console.success "Set SGID permission"
else
    console.error "Failed to set SGID permission"
fi

# Set sticky bit
if permissions.setSticky "$test_dir/dir2"; then
    console.success "Set sticky bit"
else
    console.error "Failed to set sticky bit"
fi

# Check special permissions
console.info "Checking special permissions..."
if permissions.hasSuid "$test_dir/file1.txt"; then
    console.success "File has SUID permission"
else
    console.error "File does not have SUID permission"
fi

if permissions.hasSgid "$test_dir/dir1"; then
    console.success "Directory has SGID permission"
else
    console.error "Directory does not have SGID permission"
fi

if permissions.hasSticky "$test_dir/dir2"; then
    console.success "Directory has sticky bit"
else
    console.error "Directory does not have sticky bit"
fi

# Remove special permissions
console.info "Removing special permissions..."
if permissions.removeSuid "$test_dir/file1.txt"; then
    console.success "Removed SUID permission"
else
    console.error "Failed to remove SUID permission"
fi

if permissions.removeSgid "$test_dir/dir1"; then
    console.success "Removed SGID permission"
else
    console.error "Failed to remove SGID permission"
fi

if permissions.removeSticky "$test_dir/dir2"; then
    console.success "Removed sticky bit"
else
    console.error "Failed to remove sticky bit"
fi

echo ""
echo "=== Recursive Permission Operations ==="

# Set recursive permissions
console.info "Setting recursive permissions..."
if permissions.setRecursive "$test_dir" 755; then
    console.success "Set recursive permissions to 755"
else
    console.error "Failed to set recursive permissions"
fi

# Get recursive permissions
console.info "Getting recursive permissions..."
recursive_perms=$(permissions.getRecursive "$test_dir")
console.info "Recursive permissions: $recursive_perms"

# Check recursive permissions
console.info "Checking recursive permissions..."
if permissions.checkRecursive "$test_dir" "read"; then
    console.success "All files are readable"
else
    console.error "Not all files are readable"
fi

echo ""
echo "=== Permission Templates ==="

# Apply permission templates
console.info "Applying permission templates..."

# Secure file template
if permissions.applyTemplate "$test_dir/file1.txt" "secure_file"; then
    console.success "Applied secure file template"
else
    console.error "Failed to apply secure file template"
fi

# Executable file template
if permissions.applyTemplate "$test_dir/file2.txt" "executable_file"; then
    console.success "Applied executable file template"
else
    console.error "Failed to apply executable file template"
fi

# Public directory template
if permissions.applyTemplate "$test_dir/dir1" "public_directory"; then
    console.success "Applied public directory template"
else
    console.error "Failed to apply public directory template"
fi

# Private directory template
if permissions.applyTemplate "$test_dir/dir2" "private_directory"; then
    console.success "Applied private directory template"
else
    console.error "Failed to apply private directory template"
fi

echo ""
echo "=== Permission Validation ==="

# Validate permissions
console.info "Validating permissions..."
if permissions.isValid 644; then
    console.success "644 is a valid permission"
else
    console.error "644 is not a valid permission"
fi

if permissions.isValid 999; then
    console.error "999 is valid (unexpected)"
else
    console.success "999 is not a valid permission"
fi

# Validate symbolic permissions
console.info "Validating symbolic permissions..."
if permissions.isValidSymbolic "rw-r--r--"; then
    console.success "rw-r--r-- is valid symbolic permission"
else
    console.error "rw-r--r-- is not valid symbolic permission"
fi

if permissions.isValidSymbolic "invalid"; then
    console.error "invalid is valid (unexpected)"
else
    console.success "invalid is not valid symbolic permission"
fi

echo ""
echo "=== Permission Conversion ==="

# Convert between formats
console.info "Converting permission formats..."
octal_to_symbolic=$(permissions.octalToSymbolic 644)
console.info "644 to symbolic: $octal_to_symbolic"

symbolic_to_octal=$(permissions.symbolicToOctal "rw-r--r--")
console.info "rw-r--r-- to octal: $symbolic_to_octal"

octal_to_human=$(permissions.octalToHuman 755)
console.info "755 to human: $octal_to_human"

human_to_octal=$(permissions.humanToOctal "read, write, execute for owner; read, execute for group and others")
console.info "Human to octal: $human_to_octal"

echo ""
echo "=== Permission Analysis ==="

# Analyze permissions
console.info "Analyzing permissions..."
analysis=$(permissions.analyze "$test_dir")
console.info "Permission analysis: $analysis"

# Get permission statistics
console.info "Getting permission statistics..."
stats=$(permissions.stats "$test_dir")
console.info "Permission statistics: $stats"

# Find files with specific permissions
console.info "Finding files with specific permissions..."
files_with_write=$(permissions.findWithPermission "$test_dir" "write")
console.info "Files with write permission: $files_with_write"

files_with_execute=$(permissions.findWithPermission "$test_dir" "execute")
console.info "Files with execute permission: $files_with_execute"

echo ""
echo "=== Permission Backup and Restore ==="

# Backup permissions
console.info "Backing up permissions..."
if permissions.backup "$test_dir"; then
    console.success "Permissions backed up"
else
    console.error "Failed to backup permissions"
fi

# Modify permissions
permissions.set "$test_dir/file1.txt" 777

# Restore permissions
console.info "Restoring permissions..."
if permissions.restore "$test_dir"; then
    console.success "Permissions restored"
else
    console.error "Failed to restore permissions"
fi

echo ""
echo "=== Permission Module Example Complete ==="

# Clean up
console.info "Cleaning up test files..."
rm -rf "$test_dir"
console.success "Test files cleaned up" 