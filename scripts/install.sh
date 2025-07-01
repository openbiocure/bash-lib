#!/bin/bash

# bash-lib Installation Script
# This script installs bash-lib to /opt/bash-lib by default

set -e

# Configuration
BASH_LIB_PATH="${BASH__PATH:-/opt/bash-lib}"
GITHUB_REPO="openbiocure/bash-lib"
SHELL_PROFILE=""
BASH_PROFILE=""

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

    # Add export for BASH__PATH
    if ! grep -q "export BASH__PATH=$BASH_LIB_PATH" "$SHELL_PROFILE" 2>/dev/null; then
        echo "export BASH__PATH=$BASH_LIB_PATH" >>"$SHELL_PROFILE"
    fi

    # Add source for init.sh
    if ! grep -q "source $BASH_LIB_PATH/lib/init.sh" "$SHELL_PROFILE" 2>/dev/null; then
        echo "source $BASH_LIB_PATH/lib/init.sh" >>"$SHELL_PROFILE"
    fi

    # Also add to .bash_profile if it exists and is different
    if [ -n "$BASH_PROFILE" ] && [ "$SHELL_PROFILE" != "$BASH_PROFILE" ] && [ -f "$BASH_PROFILE" ]; then
        if ! grep -q "export BASH__PATH=$BASH_LIB_PATH" "$BASH_PROFILE" 2>/dev/null; then
            echo "export BASH__PATH=$BASH_LIB_PATH" >>"$BASH_PROFILE"
        fi
        if ! grep -q "source $BASH_LIB_PATH/lib/init.sh" "$BASH_PROFILE" 2>/dev/null; then
            echo "source $BASH_LIB_PATH/lib/init.sh" >>"$BASH_PROFILE"
        fi
    fi
}

# Source bash-lib in current session
source_bash_lib() {
    export BASH__PATH="$BASH_LIB_PATH"
    if [ -f "$BASH_LIB_PATH/lib/init.sh" ]; then
        source "$BASH_LIB_PATH/lib/init.sh"

        # Verify import function is available
        if command -v import >/dev/null 2>&1; then
            echo "✅ bash-lib successfully loaded in current session"
        else
            echo "⚠️  bash-lib loaded but 'import' function not found"
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
        add_to_shell_profile
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
            echo "🔄 For new terminal sessions, restart your terminal or run: source $SHELL_PROFILE"
            echo ""
            echo "💡 Try: import console && console.info 'Hello from bash-lib!'"
        fi
    else
        echo "❌ Failed to copy files to $BASH_LIB_PATH"
        return 1
    fi
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

    # Extract the tarball
    echo "📦 Extracting bash-lib..."
    if ! tar -xzf "$tarball_name"; then
        echo "❌ Failed to extract bash-lib tarball. Please ensure tar is available."
        cd - >/dev/null
        rm -rf $TEMP_DIR
        return 1
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
        add_to_shell_profile
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
            echo "🔄 For new terminal sessions, restart your terminal or run: source $SHELL_PROFILE"
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

# Main installation function
install() {
    local version="$1"
    local cmd_prefix=$(get_cmd_prefix)

    # Create the directory if it does not exist
    $cmd_prefix mkdir -p $BASH_LIB_PATH

    # Check if we're installing locally (from current directory)
    if [ -d "./core" ] && [ -d "./modules" ]; then
        install_from_local
    else
        install_from_remote "$version"
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
    echo "Usage: $0 [COMMAND] [VERSION]"
    echo ""
    echo "Commands:"
    echo "  install    - Install bash-lib (default)"
    echo "  uninstall  - Uninstall bash-lib"
    echo "  help       - Show this help message"
    echo ""
    echo "Arguments:"
    echo "  VERSION    - Specific version to install (e.g., v1.0.0, 20241201-abc123)"
    echo "               If not specified, installs the latest release"
    echo ""
    echo "Examples:"
    echo "  $0                    # Install latest bash-lib"
    echo "  $0 install            # Install latest bash-lib"
    echo "  $0 install v1.0.0     # Install specific version"
    echo "  $0 install 20241201-abc123  # Install specific build"
    echo "  $0 uninstall          # Uninstall bash-lib"
    echo "  $0 help               # Show help"
}

# Main function with switch statement
main() {
    init_shell_profile

    case "${1:-install}" in
    "install")
        install "$2"
        ;;
    "uninstall")
        uninstall
        ;;
    "help" | "-h" | "--help")
        show_help
        ;;
    *)
        # If first argument is not a command, treat it as version for install
        if [[ "$1" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]] || [[ "$1" =~ ^[0-9]{8}-[a-f0-9]+$ ]]; then
            install "$1"
        else
            echo "Unknown command: $1"
            echo "Use '$0 help' for usage information."
            exit 1
        fi
        ;;
    esac
}

# Execute main function with all arguments
main "$@"
