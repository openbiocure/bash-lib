#!/bin/bash

# Variables
BASH_LIB_ZIP_URL="https://github.com/openbiocure/bash-lib/archive/refs/heads/main.zip"
BASH_LIB_PATH="/opt/bash-lib"
SHELL_PROFILE=""

if [ -n "$BASH_VERSION" ]; then
    SHELL_PROFILE="$HOME/.bashrc"
elif [ -n "$ZSH_VERSION" ]; then
    SHELL_PROFILE="$HOME/.zshrc"
fi

install() {
    # Create the directory if it does not exist
    sudo mkdir -p $BASH_LIB_PATH

    # Check if we're installing locally (from current directory)
    if [ -d "./core" ] && [ -d "./modules" ]; then
        echo "Installing bash-lib from local files..."
        
        # Copy the entire repository structure
        if sudo cp -r . $BASH_LIB_PATH/; then
            # Make scripts executable
            sudo chmod +x $BASH_LIB_PATH/*.sh
            sudo chmod +x $BASH_LIB_PATH/core/*.sh
            sudo chmod +x $BASH_LIB_PATH/modules/*/*.sh

            # Add to shell profile
            if ! grep -q "source $BASH_LIB_PATH/core/init.sh" "$SHELL_PROFILE"; then
                echo "source $BASH_LIB_PATH/core/init.sh" >> "$SHELL_PROFILE"
                echo "export BASH__PATH=$BASH_LIB_PATH" >> "$SHELL_PROFILE"
            fi

            # Source the script for the current session
            source $BASH_LIB_PATH/core/init.sh
            export BASH__PATH=$BASH_LIB_PATH

            echo "bash-lib installed successfully from local files. Please restart your terminal or run 'source $SHELL_PROFILE' to apply changes."
        else
            echo "Failed to copy bash-lib files. Please check if the files exist."
            exit 1
        fi
    else
        echo "Installing bash-lib from remote repository..."
        
        # Create temporary directory for download
        TEMP_DIR=$(mktemp -d)
        cd $TEMP_DIR
        
        # Download and extract the zip file
        if curl -sSL -o bash-lib.zip $BASH_LIB_ZIP_URL && unzip -q bash-lib.zip; then
            # Move the extracted content to the target directory
            if sudo cp -r bash-lib-main/* $BASH_LIB_PATH/; then
                # Make scripts executable
                sudo chmod +x $BASH_LIB_PATH/*.sh
                sudo chmod +x $BASH_LIB_PATH/core/*.sh
                sudo chmod +x $BASH_LIB_PATH/modules/*/*.sh

                # Add to shell profile
                if ! grep -q "source $BASH_LIB_PATH/core/init.sh" "$SHELL_PROFILE"; then
                    echo "source $BASH_LIB_PATH/core/init.sh" >> "$SHELL_PROFILE"
                    echo "export BASH__PATH=$BASH_LIB_PATH" >> "$SHELL_PROFILE"
                fi

                # Source the script for the current session
                source $BASH_LIB_PATH/core/init.sh
                export BASH__PATH=$BASH_LIB_PATH

                echo "bash-lib installed successfully from remote repository. Please restart your terminal or run 'source $SHELL_PROFILE' to apply changes."
            else
                echo "Failed to copy extracted files to $BASH_LIB_PATH"
                exit 1
            fi
        else
            echo "Failed to download or extract bash-lib. Please check your internet connection and try again."
            exit 1
        fi
        
        # Clean up temporary directory
        cd - > /dev/null
        rm -rf $TEMP_DIR
    fi
}

uninstall() {
    # Remove the entire directory
    if [ -d "$BASH_LIB_PATH" ]; then
        sudo rm -rf "$BASH_LIB_PATH"
    fi

    # Remove sourcing from shell profile
    sed -i '' '/source \/opt\/bash-lib\/core\/init.sh/d' "$SHELL_PROFILE"
    sed -i '' '/export BASH__PATH=\/opt\/bash-lib/d' "$SHELL_PROFILE"

    echo "bash-lib uninstalled successfully. Please restart your terminal or run 'source $SHELL_PROFILE' to apply changes."
}

# Check for uninstall flag
if [ "$1" == "uninstall" ]; then
    uninstall
else
    install
fi