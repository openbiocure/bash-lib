#!/bin/bash

# bash-lib Docker Installation Script
# Optimized for Docker container environments

set -e

# Configuration
BASH_LIB_PATH="${BASH__PATH:-/opt/bash-lib}"
BASH_LIB_ZIP_URL="https://github.com/openbiocure/bash-lib/archive/refs/heads/main.zip"

echo "🐳 Installing bash-lib in Docker container..."

# Create the installation directory
mkdir -p "$BASH_LIB_PATH"

# Create temporary directory for download
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download the zip file
echo "📥 Downloading bash-lib..."
if ! curl -sSL -o bash-lib.zip "$BASH_LIB_ZIP_URL"; then
    echo "❌ Failed to download bash-lib. Please check your internet connection and try again."
    cd - >/dev/null
    rm -rf "$TEMP_DIR"
    exit 1
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
    rm -rf "$TEMP_DIR"
    exit 1
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
        rm -rf "$TEMP_DIR"
        exit 1
    fi
    extracted_dir=$(basename "$extracted_dir")
fi

# Copy the extracted content to the target directory
echo "📁 Installing to $BASH_LIB_PATH..."
if cp -r "$extracted_dir"/* "$BASH_LIB_PATH/"; then
    # Make scripts executable
    echo "🔧 Making scripts executable..."
    find "$BASH_LIB_PATH" -name "*.sh" -type f -exec chmod +x {} \; 2>/dev/null || true

    # Set up environment for current session
    export BASH__PATH="$BASH_LIB_PATH"

    # Source bash-lib in current session
    if [ -f "$BASH_LIB_PATH/core/init.sh" ]; then
        source "$BASH_LIB_PATH/core/init.sh"

        # Verify import function is available
        if command -v import >/dev/null 2>&1; then
            echo "✅ bash-lib installed and loaded successfully!"
            echo "📝 The 'import' function is now available in this session."
            echo ""
            echo "💡 Try: import console && console.info 'Hello from bash-lib!'"
        else
            echo "⚠️  bash-lib installed but 'import' function not found"
        fi
    else
        echo "⚠️  Could not source bash-lib (init.sh not found)"
    fi
else
    echo "❌ Failed to copy extracted files to $BASH_LIB_PATH"
    cd - >/dev/null
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Clean up temporary directory
cd - >/dev/null
rm -rf "$TEMP_DIR"

echo "🎉 bash-lib installation completed!"
