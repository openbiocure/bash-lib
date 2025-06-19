#!/bin/bash

# Dependencies Management Script for bash-lib
# This script checks for and installs all required dependencies

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "info") echo -e "${BLUE}ℹ ${message}${NC}" ;;
        "success") echo -e "${GREEN}✓ ${message}${NC}" ;;
        "warning") echo -e "${YELLOW}⚠ ${message}${NC}" ;;
        "error") echo -e "${RED}✗ ${message}${NC}" ;;
    esac
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect package manager
detect_package_manager() {
    if command_exists apt-get; then
        echo "apt-get"
    elif command_exists yum; then
        echo "yum"
    elif command_exists brew; then
        echo "brew"
    elif command_exists pacman; then
        echo "pacman"
    else
        echo "unknown"
    fi
}

# Function to install package using detected package manager
install_package() {
    local package=$1
    local pkg_manager=$(detect_package_manager)
    
    case $pkg_manager in
        "apt-get")
            print_status "info" "Installing $package using apt-get..."
            sudo apt-get update && sudo apt-get install -y "$package"
            ;;
        "yum")
            print_status "info" "Installing $package using yum..."
            sudo yum install -y "$package"
            ;;
        "brew")
            print_status "info" "Installing $package using brew..."
            brew install "$package"
            ;;
        "pacman")
            print_status "info" "Installing $package using pacman..."
            sudo pacman -S --noconfirm "$package"
            ;;
        *)
            print_status "error" "Cannot install $package automatically. Please install $package manually."
            return 1
            ;;
    esac
}

# Function to check dependencies
check_dependencies() {
    print_status "info" "Checking dependencies..."
    
    local deps=("curl" "unzip" "jq" "shellspec")
    local missing_deps=()
    
    for dep in "${deps[@]}"; do
        if command_exists "$dep"; then
            print_status "success" "$dep: installed"
        else
            print_status "warning" "$dep: missing"
            missing_deps+=("$dep")
        fi
    done
    
    if [ ${#missing_deps[@]} -eq 0 ]; then
        print_status "success" "All dependencies are installed!"
        return 0
    else
        print_status "warning" "Missing dependencies: ${missing_deps[*]}"
        return 1
    fi
}

# Function to install dependencies
install_dependencies() {
    print_status "info" "Installing missing dependencies..."
    
    # Install curl if missing
    if ! command_exists curl; then
        print_status "info" "Installing curl..."
        install_package curl
    fi
    
    # Install unzip if missing
    if ! command_exists unzip; then
        print_status "info" "Installing unzip..."
        install_package unzip
    fi
    
    # Install jq if missing
    if ! command_exists jq; then
        print_status "info" "Installing jq..."
        install_package jq
    fi
    
    # Install shellspec if missing
    if ! command_exists shellspec; then
        print_status "info" "Installing shellspec..."
        curl -fsSL https://git.io/shellspec | sh -s -- --yes
        print_status "success" "shellspec installed successfully."
        print_status "info" "Adding ~/.local/bin to PATH for this session..."
        export PATH="$HOME/.local/bin:$PATH"
    fi
    
    print_status "success" "All dependencies installed successfully!"
}

# Function to show dependency status
show_status() {
    print_status "info" "Dependency Status:"
    echo
    local deps=("curl" "unzip" "jq" "shellspec")
    
    for dep in "${deps[@]}"; do
        if command_exists "$dep"; then
            local version=$($dep --version 2>/dev/null | head -n1 || echo "version unknown")
            print_status "success" "$dep: $version"
        else
            print_status "error" "$dep: not installed"
        fi
    done
}

# Function to show help
show_help() {
    echo "Dependencies Management Script for bash-lib"
    echo
    echo "Usage: $0 [COMMAND]"
    echo
    echo "Commands:"
    echo "  check     - Check if all dependencies are installed"
    echo "  install   - Install all missing dependencies"
    echo "  status    - Show detailed status of all dependencies"
    echo "  help      - Show this help message"
    echo
    echo "Dependencies:"
    echo "  curl      - For downloading files and HTTP requests"
    echo "  unzip     - For extracting downloaded files"
    echo "  jq        - For JSON processing in tests"
    echo "  shellspec - For running unit tests"
}

# Main script logic
case "${1:-help}" in
    "check")
        check_dependencies
        ;;
    "install")
        install_dependencies
        ;;
    "status")
        show_status
        ;;
    "help"|"--help"|"-h")
        show_help
        ;;
    *)
        print_status "error" "Unknown command: $1"
        echo
        show_help
        exit 1
        ;;
esac 