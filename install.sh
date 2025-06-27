#!/bin/bash

# Variables
BASH_LIB_ZIP_URL="https://github.com/openbiocure/bash-lib/archive/refs/heads/main.zip"
BASH_LIB_PATH="/opt/bash-lib"
SHELL_PROFILE=""
BASH_PROFILE=""

# Initialize shell profile based on current shell
init_shell_profile() {
    if [ -n "$BASH_VERSION" ]; then
        SHELL_PROFILE="$HOME/.bashrc"
        # Also check for .bash_profile for login shells
        if [ -f "$HOME/.bash_profile" ]; then
            BASH_PROFILE="$HOME/.bash_profile"
        elif [ -f "$HOME/.profile" ]; then
            BASH_PROFILE="$HOME/.profile"
        fi
    elif [ -n "$ZSH_VERSION" ]; then
        SHELL_PROFILE="$HOME/.zshrc"
    fi
}

# Make all scripts executable
make_scripts_executable() {
    sudo chmod +x $BASH_LIB_PATH/*.sh
    sudo chmod +x $BASH_LIB_PATH/core/*.sh
    sudo chmod +x $BASH_LIB_PATH/modules/*/*.sh
}

# Add bash-lib to shell profile
add_to_shell_profile() {
    # Add to .bashrc for interactive shells
    if ! grep -q "source $BASH_LIB_PATH/core/init.sh" "$SHELL_PROFILE"; then
        echo "source $BASH_LIB_PATH/core/init.sh" >>"$SHELL_PROFILE"
        echo "export BASH__PATH=$BASH_LIB_PATH" >>"$SHELL_PROFILE"
    fi

    # Add to .bash_profile/.profile for login shells (SSH sessions)
    if [ -n "$BASH_PROFILE" ]; then
        if ! grep -q "source $BASH_LIB_PATH/core/init.sh" "$BASH_PROFILE"; then
            echo "source $BASH_LIB_PATH/core/init.sh" >>"$BASH_PROFILE"
            echo "export BASH__PATH=$BASH_LIB_PATH" >>"$BASH_PROFILE"
        fi
    fi
}

# Source bash-lib for current session
source_bash_lib() {
    # Set the BASH__PATH environment variable
    export BASH__PATH=$BASH_LIB_PATH

    # Source the init script to make import function available
    if [ -f "$BASH_LIB_PATH/core/init.sh" ]; then
        source "$BASH_LIB_PATH/core/init.sh"
        echo "bash-lib sourced successfully for current session."

        # Verify that import function is available
        if command -v import >/dev/null 2>&1; then
            echo "✅ 'import' function is now available!"
        else
            echo "⚠️  Warning: 'import' function not found. Please restart your terminal."
        fi
    else
        echo "❌ Error: Could not find bash-lib init script at $BASH_LIB_PATH/core/init.sh"
        return 1
    fi
}

# Install from local files
install_from_local() {
    echo "Installing bash-lib from local files..."

    if sudo cp -r . $BASH_LIB_PATH/; then
        make_scripts_executable
        add_to_shell_profile
        source_bash_lib

        echo ""
        echo "✅ bash-lib installed successfully from local files!"
        echo "📝 The 'import' function is now available in this session."
        echo "🔄 For new terminal sessions, restart your terminal or run: source $SHELL_PROFILE"
        echo ""
        echo "💡 Try: import console && console.info 'Hello from bash-lib!'"
    else
        echo "❌ Failed to copy bash-lib files. Please check if the files exist."
        return 1
    fi
}

# Install from remote repository
install_from_remote() {
    echo "Installing bash-lib from remote repository..."

    # Create temporary directory for download
    TEMP_DIR=$(mktemp -d)
    cd $TEMP_DIR

    # Download the zip file
    echo "📥 Downloading bash-lib..."
    if ! curl -sSL -o bash-lib.zip $BASH_LIB_ZIP_URL; then
        echo "❌ Failed to download bash-lib. Please check your internet connection and try again."
        cd - >/dev/null
        rm -rf $TEMP_DIR
        return 1
    fi

    # Try different extraction methods
    echo "📦 Extracting bash-lib..."
    local extracted=false

    # Method 1: Try unzip
    if command -v unzip >/dev/null 2>&1; then
        if unzip -q bash-lib.zip; then
            extracted=true
        fi
    fi

    # Method 2: Try tar (some systems have tar but not unzip)
    if [ "$extracted" = false ] && command -v tar >/dev/null 2>&1; then
        if tar -xf bash-lib.zip; then
            extracted=true
        fi
    fi

    # Method 3: Try 7z if available
    if [ "$extracted" = false ] && command -v 7z >/dev/null 2>&1; then
        if 7z x bash-lib.zip >/dev/null 2>&1; then
            extracted=true
        fi
    fi

    # Method 4: Try installing unzip if possible
    if [ "$extracted" = false ]; then
        echo "⚠️  No extraction tool found. Attempting to install unzip..."
        if command -v yum >/dev/null 2>&1; then
            # RHEL/CentOS/Fedora
            if yum install -y unzip >/dev/null 2>&1; then
                if unzip -q bash-lib.zip; then
                    extracted=true
                fi
            fi
        elif command -v apt-get >/dev/null 2>&1; then
            # Debian/Ubuntu
            if apt-get update >/dev/null 2>&1 && apt-get install -y unzip >/dev/null 2>&1; then
                if unzip -q bash-lib.zip; then
                    extracted=true
                fi
            fi
        elif command -v dnf >/dev/null 2>&1; then
            # Fedora (newer)
            if dnf install -y unzip >/dev/null 2>&1; then
                if unzip -q bash-lib.zip; then
                    extracted=true
                fi
            fi
        fi
    fi

    # Check if extraction was successful
    if [ "$extracted" = false ]; then
        echo "❌ Failed to extract bash-lib. Please install unzip or tar:"
        echo "   RHEL/CentOS: yum install -y unzip"
        echo "   Ubuntu/Debian: apt-get install -y unzip"
        echo "   Fedora: dnf install -y unzip"
        cd - >/dev/null
        rm -rf $TEMP_DIR
        return 1
    fi

    # Find the extracted directory (it might be named differently)
    local extracted_dir=""
    if [ -d "bash-lib-main" ]; then
        extracted_dir="bash-lib-main"
    elif [ -d "main" ]; then
        extracted_dir="main"
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
    if sudo cp -r "$extracted_dir"/* $BASH_LIB_PATH/; then
        make_scripts_executable
        add_to_shell_profile
        source_bash_lib

        echo ""
        echo "✅ bash-lib installed successfully from remote repository!"
        echo "📝 The 'import' function is now available in this session."
        echo "🔄 For new terminal sessions, restart your terminal or run: source $SHELL_PROFILE"
        echo ""
        echo "💡 Try: import console && console.info 'Hello from bash-lib!'"
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
    # Create the directory if it does not exist
    sudo mkdir -p $BASH_LIB_PATH

    # Check if we're installing locally (from current directory)
    if [ -d "./core" ] && [ -d "./modules" ]; then
        install_from_local
    else
        install_from_remote
    fi
}

# Uninstall bash-lib
uninstall() {
    # Remove the entire directory
    if [ -d "$BASH_LIB_PATH" ]; then
        sudo rm -rf "$BASH_LIB_PATH"
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
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  install    - Install bash-lib (default)"
    echo "  uninstall  - Uninstall bash-lib"
    echo "  help       - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0              # Install bash-lib"
    echo "  $0 install      # Install bash-lib"
    echo "  $0 uninstall    # Uninstall bash-lib"
    echo "  $0 help         # Show help"
}

# Main function with switch statement
main() {
    init_shell_profile

    case "${1:-install}" in
    "install")
        install
        ;;
    "uninstall")
        uninstall
        ;;
    "help" | "-h" | "--help")
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        echo "Use '$0 help' for usage information."
        exit 1
        ;;
    esac
}

# Execute main function with all arguments
main "$@"
