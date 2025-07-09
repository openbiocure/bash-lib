#!/bin/bash

# bash-lib Installation Script
# This script installs bash-lib to /opt/bash-lib by default

set -e

# Configuration
BASH_LIB_PATH="${BASH__PATH:-/opt/bash-lib}"
GITHUB_REPO="openbiocure/bash-lib"
SHELL_PROFILE=""
BASH_PROFILE=""

# Parse command line arguments
parse_arguments() {
    local version=""
    local branch=""
    local commit=""
    local path=""
    local command="install"

    while [[ $# -gt 0 ]]; do
        case $1 in
            --version)
                version="$2"
                shift 2
                ;;
            --branch)
                branch="$2"
                shift 2
                ;;
            --commit)
                commit="$2"
                shift 2
                ;;
            --path)
                path="$2"
                shift 2
                ;;
            install|uninstall|help)
                command="$1"
                shift
                ;;
            -h|--help)
                command="help"
                shift
                ;;
            *)
                # If it looks like a version, treat it as such
                if [[ "$1" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]] || [[ "$1" =~ ^[0-9]{8}-[a-f0-9]+$ ]]; then
                    version="$1"
                else
                    echo "Unknown option: $1"
                    echo "Use '$0 help' for usage information."
                    exit 1
                fi
                shift
                ;;
        esac
    done

    echo "$command|$version|$branch|$commit|$path"
}

# Detect if we're running in a Docker container or as root
is_docker_or_root() {
    # Check if we're running as root (UID 0)
    if [ "$(id -u)" -eq 0 ]; then
        return 0
    fi

    # Check if we're in a Docker container
    if [ -f /.dockerenv ] || grep -q docker /proc/1/cgroup 2>/dev/null; then
        return 0
    fi

    return 1
}

# Get the appropriate command prefix (sudo or empty)
get_cmd_prefix() {
    if is_docker_or_root; then
        echo ""
    else
        echo "sudo"
    fi
}

# Get the latest release version from GitHub
get_latest_release() {
    local api_url="https://api.github.com/repos/$GITHUB_REPO/releases/latest"
    local version=$(curl -s "$api_url" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

    if [ -z "$version" ]; then
        echo "❌ Failed to get latest release version"
        return 1
    fi

    echo "$version"
}

# Validate version format
validate_version() {
    local version="$1"
    # Check if version follows semantic versioning or date format
    if [[ "$version" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]] || [[ "$version" =~ ^[0-9]{8}-[a-f0-9]+$ ]]; then
        return 0
    else
        echo "❌ Invalid version format. Expected format: v1.0.0 or YYYYMMDD-commit"
        return 1
    fi
}

# Get the download URL for a specific version
get_release_url() {
    local version="$1"
    # Try the standard naming pattern first
    echo "https://github.com/$GITHUB_REPO/releases/download/$version/bash-lib-$version.tar.gz"
}

# Get the actual tarball name from GitHub release assets
get_tarball_name() {
    local version="$1"
    local api_url="https://api.github.com/repos/$GITHUB_REPO/releases/tags/$version"
    local tarball_name=$(curl -s "$api_url" | grep '"name":' | grep '\.tar\.gz"' | head -1 | sed -E 's/.*"([^"]+\.tar\.gz)".*/\1/')

    if [ -z "$tarball_name" ]; then
        # Fallback to standard naming pattern
        echo "bash-lib-$version.tar.gz"
    else
        echo "$tarball_name"
    fi
}

# Initialize shell profile detection
init_shell_profile() {
    # Detect the appropriate shell profile file
    if [ -n "$ZSH_VERSION" ]; then
        # Zsh
        SHELL_PROFILE="$HOME/.zshrc"
        BASH_PROFILE="$HOME/.zprofile"
    elif [ -n "$BASH_VERSION" ]; then
        # Bash
        SHELL_PROFILE="$HOME/.bashrc"
        BASH_PROFILE="$HOME/.bash_profile"
    else
        # Fallback
        SHELL_PROFILE="$HOME/.profile"
    fi

    # Create the profile file if it doesn't exist
    if [ ! -f "$SHELL_PROFILE" ]; then
        touch "$SHELL_PROFILE"
    fi
}

# Add bash-lib to shell profile
add_to_shell_profile() {
    local cmd_prefix=$(get_cmd_prefix)
    local profile_updated=false

    # In Docker environments, we might not want to modify shell profiles
    if [ "$BASH_LIB_DOCKER" = "true" ]; then
        echo "🐳 Docker environment detected - skipping shell profile modifications"
        return 0
    fi

    echo "📝 Configuring shell profile: $SHELL_PROFILE"

    # Add export for BASH__PATH
    if ! grep -q "export BASH__PATH=$BASH_LIB_PATH" "$SHELL_PROFILE" 2>/dev/null; then
        if echo "export BASH__PATH=$BASH_LIB_PATH" >>"$SHELL_PROFILE" 2>/dev/null; then
            echo "✅ Added BASH__PATH export to $SHELL_PROFILE"
            profile_updated=true
        else
            echo "⚠️  Could not write to $SHELL_PROFILE (permission denied)"
            echo "   You may need to manually add: export BASH__PATH=$BASH_LIB_PATH"
        fi
    else
        echo "ℹ️  BASH__PATH already configured in $SHELL_PROFILE"
    fi

    # Add source for init.sh
    if ! grep -q "source $BASH_LIB_PATH/lib/init.sh" "$SHELL_PROFILE" 2>/dev/null; then
        if echo "source $BASH_LIB_PATH/lib/init.sh" >>"$SHELL_PROFILE" 2>/dev/null; then
            echo "✅ Added bash-lib source to $SHELL_PROFILE"
            profile_updated=true
        else
            echo "⚠️  Could not write to $SHELL_PROFILE (permission denied)"
            echo "   You may need to manually add: source $BASH_LIB_PATH/lib/init.sh"
        fi
    else
        echo "ℹ️  bash-lib source already configured in $SHELL_PROFILE"
    fi

    # Also add to .bash_profile if it exists and is different
    if [ -n "$BASH_PROFILE" ] && [ "$SHELL_PROFILE" != "$BASH_PROFILE" ] && [ -f "$BASH_PROFILE" ]; then
        echo "📝 Also configuring: $BASH_PROFILE"

        if ! grep -q "export BASH__PATH=$BASH_LIB_PATH" "$BASH_PROFILE" 2>/dev/null; then
            if echo "export BASH__PATH=$BASH_LIB_PATH" >>"$BASH_PROFILE" 2>/dev/null; then
                echo "✅ Added BASH__PATH export to $BASH_PROFILE"
                profile_updated=true
            else
                echo "⚠️  Could not write to $BASH_PROFILE (permission denied)"
            fi
        fi

        if ! grep -q "source $BASH_LIB_PATH/lib/init.sh" "$BASH_PROFILE" 2>/dev/null; then
            if echo "source $BASH_LIB_PATH/lib/init.sh" >>"$BASH_PROFILE" 2>/dev/null; then
                echo "✅ Added bash-lib source to $BASH_PROFILE"
                profile_updated=true
            else
                echo "⚠️  Could not write to $BASH_PROFILE (permission denied)"
            fi
        fi
    fi

    # Return whether profile was updated
    if [ "$profile_updated" = true ]; then
        return 0
    else
        return 1
    fi
}

# Source bash-lib in current session
source_bash_lib() {
    export BASH__PATH="$BASH_LIB_PATH"
    if [ -f "$BASH_LIB_PATH/lib/init.sh" ]; then
        # Use a subshell to prevent sourcing errors from affecting the main script
        if (source "$BASH_LIB_PATH/lib/init.sh" 2>/dev/null); then
            # Verify import function is available (use type to check for shell functions)
            if type import >/dev/null 2>&1; then
            echo "✅ bash-lib successfully loaded in current session"
        else
            echo "⚠️  bash-lib loaded but 'import' function not found"
            fi
        else
            echo "⚠️  Could not source bash-lib (init.sh had errors)"
        fi
    else
        echo "⚠️  Could not source bash-lib (init.sh not found)"
    fi
}

# Make scripts executable
make_scripts_executable() {
    local cmd_prefix=$(get_cmd_prefix)

    echo "🔧 Making scripts executable..."
    find "$BASH_LIB_PATH" -name "*.sh" -type f -exec $cmd_prefix chmod +x {} \; 2>/dev/null || true
}

# Install from local directory
install_from_local() {
    if is_docker_or_root; then
        echo "🐳 Installing bash-lib from local directory in Docker container..."
    else
    echo "Installing bash-lib from local directory..."
    fi

    # Copy files to target directory
    echo "📁 Installing to $BASH_LIB_PATH..."
    local cmd_prefix=$(get_cmd_prefix)

    if $cmd_prefix cp -r . "$BASH_LIB_PATH/"; then
        make_scripts_executable
        local profile_updated=false
        if add_to_shell_profile; then
            profile_updated=true
        fi
        source_bash_lib

        echo ""
        if is_docker_or_root; then
            echo "✅ bash-lib installed successfully from local directory in Docker container!"
            echo "📝 The 'import' function is now available in this session."
            echo ""
            echo "💡 Try: import console && console.info 'Hello from bash-lib!'"
        else
            echo "✅ bash-lib installed successfully from local directory!"
            echo "📝 The 'import' function is now available in this session."

            if [ "$profile_updated" = true ]; then
                echo ""
                echo "🔄 To activate bash-lib in new terminal sessions:"
                echo "   • Restart your terminal, OR"
                echo "   • Run: source $SHELL_PROFILE"
                echo ""
                echo "📋 Manual activation (if auto-configuration failed):"
                echo "   export BASH__PATH=$BASH_LIB_PATH"
                echo "   source $BASH_LIB_PATH/lib/init.sh"
            else
                echo ""
                echo "⚠️  Shell profile configuration failed or was already configured."
                echo "📋 To manually activate bash-lib in new sessions, add to $SHELL_PROFILE:"
                echo "   export BASH__PATH=$BASH_LIB_PATH"
                echo "   source $BASH_LIB_PATH/lib/init.sh"
            fi

            echo ""
            echo "💡 Try: import console && console.info 'Hello from bash-lib!'"
        fi
    else
        echo "❌ Failed to copy files to $BASH_LIB_PATH"
        return 1
    fi
}

# Install from specific path
install_from_path() {
    local source_path="$1"

    if is_docker_or_root; then
        echo "🐳 Installing bash-lib from path: $source_path in Docker container..."
    else
        echo "Installing bash-lib from path: $source_path..."
    fi

    # Validate the source path
    if [ ! -d "$source_path" ]; then
        echo "❌ Source path does not exist or is not a directory: $source_path"
        return 1
    fi

    # Check if it looks like a bash-lib installation
    if [ ! -d "$source_path/lib/modules/core" ] || [ ! -d "$source_path/lib/modules" ]; then
        echo "❌ Source path does not appear to be a valid bash-lib installation"
        echo "   Expected structure: $source_path/lib/modules/core"
        return 1
    fi

    # Copy files to target directory
    echo "📁 Installing to $BASH_LIB_PATH..."
    local cmd_prefix=$(get_cmd_prefix)

    if $cmd_prefix cp -r "$source_path"/* "$BASH_LIB_PATH/"; then
        make_scripts_executable
        local profile_updated=false
        if add_to_shell_profile; then
            profile_updated=true
        fi
        source_bash_lib

        echo ""
        if is_docker_or_root; then
            echo "✅ bash-lib installed successfully from path in Docker container!"
            echo "📝 The 'import' function is now available in this session."
            echo ""
            echo "💡 Try: import console && console.info 'Hello from bash-lib!'"
        else
            echo "✅ bash-lib installed successfully from path!"
            echo "📝 The 'import' function is now available in this session."

            if [ "$profile_updated" = true ]; then
                echo ""
                echo "🔄 To activate bash-lib in new terminal sessions:"
                echo "   • Restart your terminal, OR"
                echo "   • Run: source $SHELL_PROFILE"
                echo ""
                echo "📋 Manual activation (if auto-configuration failed):"
                echo "   export BASH__PATH=$BASH_LIB_PATH"
                echo "   source $BASH_LIB_PATH/lib/init.sh"
            else
                echo ""
                echo "⚠️  Shell profile configuration failed or was already configured."
                echo "📋 To manually activate bash-lib in new sessions, add to $SHELL_PROFILE:"
                echo "   export BASH__PATH=$BASH_LIB_PATH"
                echo "   source $BASH_LIB_PATH/lib/init.sh"
            fi

            echo ""
            echo "💡 Try: import console && console.info 'Hello from bash-lib!'"
        fi
    else
        echo "❌ Failed to copy files from $source_path to $BASH_LIB_PATH"
        return 1
    fi
}

# Install from branch or commit
install_from_branch_or_commit() {
    local branch_or_commit="$1"
    local type="$2"  # "branch" or "commit"

    if is_docker_or_root; then
        echo "🐳 Installing bash-lib from $type: $branch_or_commit in Docker container..."
    else
        echo "Installing bash-lib from $type: $branch_or_commit..."
    fi

    # Validate branch/commit name
    if [ -z "$branch_or_commit" ]; then
        echo "❌ $type name cannot be empty"
        return 1
    fi

    # Check for potentially dangerous characters in branch/commit names
    if [[ "$branch_or_commit" =~ [\;\&\|\`\$] ]]; then
        echo "❌ Invalid $type name: contains potentially dangerous characters"
        echo "   Please use a valid $type name without special characters"
        return 1
    fi

    # Create temporary directory
    TEMP_DIR=$(mktemp -d)
    cd $TEMP_DIR

    # Clone the repository
    echo "📥 Cloning bash-lib repository..."
    if ! git clone --depth 1 https://github.com/$GITHUB_REPO.git bash-lib-temp; then
        echo "❌ Failed to clone bash-lib repository"
        echo "   Please check your internet connection and try again"
        cd - >/dev/null
        rm -rf $TEMP_DIR
        return 1
    fi

    # Checkout specific branch or commit
    cd bash-lib-temp
    echo "🔍 Checking out $type: $branch_or_commit..."
    if ! git checkout "$branch_or_commit" 2>/dev/null; then
        echo "❌ Failed to checkout $type: $branch_or_commit"
        echo ""
        echo "Possible reasons:"
        echo "  - The $type does not exist in the repository"
        echo "  - The $type name is misspelled"
        echo "  - You don't have access to this $type"
        echo ""
        echo "Available branches:"
        git branch -r | head -10 | sed 's/^/  - /' || echo "  (Could not list branches)"
        echo ""
        echo "💡 Try:"
        echo "  - Check the $type name spelling"
        echo "  - Use 'git ls-remote --heads origin' to see available branches"
        echo "  - Install from a release instead: $0 --version v1.0.0"
        cd - >/dev/null
        rm -rf $TEMP_DIR
        return 1
    fi

    # Verify it's a valid bash-lib installation
    if [ ! -d "lib/modules/core" ] || [ ! -d "lib/modules" ]; then
        echo "❌ The checked out $type does not appear to be a valid bash-lib installation"
        echo "   Expected structure: lib/modules/core"
        cd - >/dev/null
        rm -rf $TEMP_DIR
        return 1
    fi

    # Install from local directory
    cd ..
    local cmd_prefix=$(get_cmd_prefix)

    if $cmd_prefix cp -r bash-lib-temp/* "$BASH_LIB_PATH/"; then
        make_scripts_executable
        local profile_updated=false
        if add_to_shell_profile; then
            profile_updated=true
        fi
        source_bash_lib

        echo ""
        if is_docker_or_root; then
            echo "✅ bash-lib installed successfully from $type in Docker container!"
            echo "📝 The 'import' function is now available in this session."
            echo ""
            echo "💡 Try: import console && console.info 'Hello from bash-lib!'"
        else
            echo "✅ bash-lib installed successfully from $type!"
            echo "📝 The 'import' function is now available in this session."

            if [ "$profile_updated" = true ]; then
                echo ""
                echo "🔄 To activate bash-lib in new terminal sessions:"
                echo "   • Restart your terminal, OR"
                echo "   • Run: source $SHELL_PROFILE"
                echo ""
                echo "📋 Manual activation (if auto-configuration failed):"
                echo "   export BASH__PATH=$BASH_LIB_PATH"
                echo "   source $BASH_LIB_PATH/lib/init.sh"
            else
                echo ""
                echo "⚠️  Shell profile configuration failed or was already configured."
                echo "📋 To manually activate bash-lib in new sessions, add to $SHELL_PROFILE:"
                echo "   export BASH__PATH=$BASH_LIB_PATH"
                echo "   source $BASH_LIB_PATH/lib/init.sh"
            fi

            echo ""
            echo "💡 Try: import console && console.info 'Hello from bash-lib!'"
        fi
    else
        echo "❌ Failed to copy files to $BASH_LIB_PATH"
        cd - >/dev/null
        rm -rf $TEMP_DIR
        return 1
    fi

    # Cleanup
    cd - >/dev/null
    rm -rf $TEMP_DIR
}

# Install from remote repository
install_from_remote() {
    local requested_version="$1"

    if is_docker_or_root; then
        echo "🐳 Installing bash-lib in Docker container..."
    else
        echo "Installing bash-lib from release..."
    fi

    # Determine version to install
    local version=""
    if [ -n "$requested_version" ]; then
        echo "📋 Using requested version: $requested_version"
        if ! validate_version "$requested_version"; then
            return 1
        fi
        version="$requested_version"
    else
        echo "📋 Getting latest release version..."
        version=$(get_latest_release)
        if [ $? -ne 0 ]; then
            echo "❌ Failed to get latest release version. Please check your internet connection and try again."
            return 1
        fi
        echo "📦 Latest version: $version"
    fi

    # Get the actual tarball name and download URL
    local tarball_name=$(get_tarball_name "$version")
    local download_url="https://github.com/$GITHUB_REPO/releases/download/$version/$tarball_name"

    # Create temporary directory for download
    TEMP_DIR=$(mktemp -d)
    cd $TEMP_DIR

    # Download the tarball
    echo "📥 Downloading bash-lib $version ($tarball_name)..."
    if ! curl -sSL -o "$tarball_name" "$download_url"; then
        echo "❌ Failed to download bash-lib. Please check your internet connection and try again."
        echo "   URL: $download_url"
        cd - >/dev/null
        rm -rf $TEMP_DIR
        return 1
    fi

    # Verify the downloaded file is a valid tarball
    if command -v file >/dev/null 2>&1; then
        if ! file "$tarball_name" | grep -q "gzip compressed data"; then
            echo "❌ Downloaded file is not a valid tarball."
            echo "   This usually means the release doesn't have the proper assets uploaded."
            echo "   File type: $(file "$tarball_name")"
            echo ""
            echo "💡 This release may not have proper assets. Please try a different version or contact the maintainer."
            cd - >/dev/null
            rm -rf $TEMP_DIR
            return 1
        fi
    else
        # Alternative validation: check file size and magic bytes
        if [ ! -s "$tarball_name" ]; then
            echo "❌ Downloaded file is empty or invalid."
            cd - >/dev/null
            rm -rf $TEMP_DIR
            return 1
    fi

        # Check if it's a gzip file by looking at magic bytes
        if ! head -c 2 "$tarball_name" | grep -q $'\x1f\x8b'; then
            echo "❌ Downloaded file doesn't appear to be a valid gzip tarball."
            echo "   This usually means the release doesn't have the proper assets uploaded."
            echo ""
            echo "💡 This release may not have proper assets. Please try a different version or contact the maintainer."
            cd - >/dev/null
            rm -rf $TEMP_DIR
            return 1
        fi
    fi

    # Extract the tarball
    echo "📦 Extracting bash-lib..."

    # Check if tar is available
    if command -v tar >/dev/null 2>&1; then
        if ! tar -xzf "$tarball_name"; then
            echo "❌ Failed to extract bash-lib tarball with tar."
            cd - >/dev/null
            rm -rf $TEMP_DIR
            return 1
        fi
    else
        echo "⚠️  tar not found, trying alternative extraction methods..."

        # Try with gunzip + tar (some systems have them separately)
        if command -v gunzip >/dev/null 2>&1; then
            echo "📦 Using gunzip + tar..."
            if gunzip -c "$tarball_name" | tar -xf -; then
                echo "✅ Extracted successfully with gunzip + tar"
            else
                echo "❌ Failed to extract with gunzip + tar"
                cd - >/dev/null
                rm -rf $TEMP_DIR
                return 1
            fi
        else
            echo "❌ No suitable extraction tool found. Please install tar or gunzip."
            echo "   On Ubuntu/Debian: sudo apt-get install tar"
            echo "   On CentOS/RHEL: sudo yum install tar"
            echo "   On macOS: tar should be pre-installed"
        cd - >/dev/null
        rm -rf $TEMP_DIR
        return 1
        fi
    fi

    # Find the extracted directory
    local extracted_dir=""
    if [ -d "bash-lib-$version" ]; then
        extracted_dir="bash-lib-$version"
    else
        # Find any directory that looks like bash-lib
        extracted_dir=$(find . -maxdepth 1 -type d -name "*bash*lib*" | head -1)
        if [ -z "$extracted_dir" ]; then
            echo "❌ Could not find extracted bash-lib directory"
            cd - >/dev/null
            rm -rf $TEMP_DIR
            return 1
        fi
        extracted_dir=$(basename "$extracted_dir")
    fi

    # Move the extracted content to the target directory
    echo "📁 Installing to $BASH_LIB_PATH..."
    local cmd_prefix=$(get_cmd_prefix)

    if $cmd_prefix cp -r "$extracted_dir"/* $BASH_LIB_PATH/; then
        make_scripts_executable
        local profile_updated=false
        if add_to_shell_profile; then
            profile_updated=true
        fi
        source_bash_lib

        echo ""
        if is_docker_or_root; then
            echo "✅ bash-lib installed and loaded successfully in Docker container!"
            echo "📝 The 'import' function is now available in this session."
            echo ""
            echo "💡 Try: import console && console.info 'Hello from bash-lib!'"
        else
            echo "✅ bash-lib installed successfully from remote repository!"
            echo "📝 The 'import' function is now available in this session."

            if [ "$profile_updated" = true ]; then
                echo ""
                echo "🔄 To activate bash-lib in new terminal sessions:"
                echo "   • Restart your terminal, OR"
                echo "   • Run: source $SHELL_PROFILE"
                echo ""
                echo "📋 Manual activation (if auto-configuration failed):"
                echo "   export BASH__PATH=$BASH_LIB_PATH"
                echo "   source $BASH_LIB_PATH/lib/init.sh"
            else
                echo ""
                echo "⚠️  Shell profile configuration failed or was already configured."
                echo "📋 To manually activate bash-lib in new sessions, add to $SHELL_PROFILE:"
                echo "   export BASH__PATH=$BASH_LIB_PATH"
                echo "   source $BASH_LIB_PATH/lib/init.sh"
            fi

            echo ""
            echo "💡 Try: import console && console.info 'Hello from bash-lib!'"
        fi
    else
        echo "❌ Failed to copy extracted files to $BASH_LIB_PATH"
        cd - >/dev/null
        rm -rf $TEMP_DIR
        return 1
    fi

    # Clean up temporary directory
    cd - >/dev/null
    rm -rf $TEMP_DIR
}

# Check if git is available
check_git_availability() {
    if ! command -v git >/dev/null 2>&1; then
        echo "❌ git is not installed on this system"
        echo ""
        echo "To install git:"
        echo "  Ubuntu/Debian: sudo apt-get install git"
        echo "  CentOS/RHEL:   sudo yum install git"
        echo "  macOS:         brew install git"
        echo "  Windows:       Download from https://git-scm.com/"
        echo ""
        echo "Alternatively, you can:"
        echo "  - Install from a release version: $0 --version v1.0.0"
        echo "  - Install from a local path: $0 --path /path/to/bash-lib"
        echo "  - Install from current directory (if it's a bash-lib repo)"
        return 1
    fi
    return 0
}

# Check for required dependencies
check_dependencies() {
    local missing_deps=()

    # Check for curl (needed for release downloads)
    if ! command -v curl >/dev/null 2>&1; then
        missing_deps+=("curl")
    fi

    # Check for tar (needed for extracting tarballs)
    if ! command -v tar >/dev/null 2>&1; then
        missing_deps+=("tar")
    fi

    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo "❌ Missing required dependencies: ${missing_deps[*]}"
        echo ""
        echo "To install missing dependencies:"
        echo "  Ubuntu/Debian: sudo apt-get install ${missing_deps[*]}"
        echo "  CentOS/RHEL:   sudo yum install ${missing_deps[*]}"
        echo "  macOS:         brew install ${missing_deps[*]}"
        return 1
    fi

    return 0
}

# Main installation function
install() {
    local version="$1"
    local branch="$2"
    local commit="$3"
    local path="$4"
    local cmd_prefix=$(get_cmd_prefix)

    # Check dependencies for all installation methods
    if ! check_dependencies; then
        return 1
    fi

    # Create the directory if it does not exist
    $cmd_prefix mkdir -p $BASH_LIB_PATH

    # Priority order: path > branch > commit > version > local > latest
    if [ -n "$path" ]; then
        install_from_path "$path"
    elif [ -n "$branch" ]; then
        # Check git availability before attempting branch installation
        if ! check_git_availability; then
            return 1
        fi
        install_from_branch_or_commit "$branch" "branch"
    elif [ -n "$commit" ]; then
        # Check git availability before attempting commit installation
        if ! check_git_availability; then
            return 1
        fi
        install_from_branch_or_commit "$commit" "commit"
    elif [ -n "$version" ]; then
        install_from_remote "$version"
    elif [ -d "./lib/modules/core" ] && [ -d "./lib/modules" ]; then
        install_from_local
    else
        install_from_remote
    fi
}

# Uninstall bash-lib
uninstall() {
    local cmd_prefix=$(get_cmd_prefix)

    # Remove the entire directory
    if [ -d "$BASH_LIB_PATH" ]; then
        $cmd_prefix rm -rf "$BASH_LIB_PATH"
    fi

    # Remove sourcing from shell profile
    sed -i '/source \/opt\/bash-lib\/core\/init.sh/d' "$SHELL_PROFILE" 2>/dev/null || true
    sed -i '/export BASH__PATH=\/opt\/bash-lib/d' "$SHELL_PROFILE" 2>/dev/null || true

    # Remove from .bash_profile/.profile if it exists
    if [ -n "$BASH_PROFILE" ]; then
        sed -i '/source \/opt\/bash-lib\/core\/init.sh/d' "$BASH_PROFILE" 2>/dev/null || true
        sed -i '/export BASH__PATH=\/opt\/bash-lib/d' "$BASH_PROFILE" 2>/dev/null || true
    fi

    echo "bash-lib uninstalled successfully. Please restart your terminal or run 'source $SHELL_PROFILE' to apply changes."
}

# Show help
show_help() {
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  install    - Install bash-lib (default)"
    echo "  uninstall  - Uninstall bash-lib"
    echo "  help       - Show this help message"
    echo ""
    echo "Options:"
    echo "  --version <version>  - Install specific release version (e.g., v1.0.0)"
    echo "  --branch <branch>    - Install from specific branch (e.g., fix/bug-123)"
    echo "  --commit <commit>    - Install from specific commit (e.g., d08b7e5)"
    echo "  --path <path>        - Install from local path"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Install latest release"
    echo "  $0 install --version v1.0.0          # Install specific version"
    echo "  $0 install --branch fix/bug-123      # Install from branch"
    echo "  $0 install --commit d08b7e5          # Install from commit"
    echo "  $0 install --path /tmp/bash-lib      # Install from local path"
    echo "  $0 uninstall                         # Uninstall bash-lib"
    echo "  $0 help                              # Show help"
    echo ""
    echo "Note: When installing from branch or commit, git must be installed on your system."
}

# Main function with switch statement
main() {
    init_shell_profile

    # Parse arguments
    local parsed_args=$(parse_arguments "$@")
    IFS='|' read -r command version branch commit path <<< "$parsed_args"

    case "$command" in
    "install")
        install "$version" "$branch" "$commit" "$path"
        ;;
    "uninstall")
        uninstall
        ;;
    "help" | "-h" | "--help")
        show_help
        ;;
    *)
        echo "Unknown command: $command"
        echo "Use '$0 help' for usage information."
        exit 1
        ;;
    esac
}

# Execute main function with all arguments
main "$@"
