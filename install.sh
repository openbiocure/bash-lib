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
        echo "source $BASH_LIB_PATH/core/init.sh" >> "$SHELL_PROFILE"
        echo "export BASH__PATH=$BASH_LIB_PATH" >> "$SHELL_PROFILE"
    fi
    
    # Add to .bash_profile/.profile for login shells (SSH sessions)
    if [ -n "$BASH_PROFILE" ]; then
        if ! grep -q "source $BASH_LIB_PATH/core/init.sh" "$BASH_PROFILE"; then
            echo "source $BASH_LIB_PATH/core/init.sh" >> "$BASH_PROFILE"
            echo "export BASH__PATH=$BASH_LIB_PATH" >> "$BASH_PROFILE"
        fi
    fi
}

# Source bash-lib for current session
source_bash_lib() {
    source $BASH_LIB_PATH/core/init.sh
    export BASH__PATH=$BASH_LIB_PATH
}

# Install from local files
install_from_local() {
    echo "Installing bash-lib from local files..."
    
    if sudo cp -r . $BASH_LIB_PATH/; then
        make_scripts_executable
        add_to_shell_profile
        source_bash_lib
        
        echo "bash-lib installed successfully from local files. Please restart your terminal or run 'source $SHELL_PROFILE' to apply changes."
    else
        echo "Failed to copy bash-lib files. Please check if the files exist."
        return 1
    fi
}

# Install from remote repository
install_from_remote() {
    echo "Installing bash-lib from remote repository..."
    
    # Create temporary directory for download
    TEMP_DIR=$(mktemp -d)
    cd $TEMP_DIR
    
    # Download and extract the zip file
    if curl -sSL -o bash-lib.zip $BASH_LIB_ZIP_URL && unzip -q bash-lib.zip; then
        # Move the extracted content to the target directory
        if sudo cp -r bash-lib-main/* $BASH_LIB_PATH/; then
            make_scripts_executable
            add_to_shell_profile
            source_bash_lib
            
            echo "bash-lib installed successfully from remote repository. Please restart your terminal or run 'source $SHELL_PROFILE' to apply changes."
        else
            echo "Failed to copy extracted files to $BASH_LIB_PATH"
            cd - > /dev/null
            rm -rf $TEMP_DIR
            return 1
        fi
    else
        echo "Failed to download or extract bash-lib. Please check your internet connection and try again."
        cd - > /dev/null
        rm -rf $TEMP_DIR
        return 1
    fi
    
    # Clean up temporary directory
    cd - > /dev/null
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
        "help"|"-h"|"--help")
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