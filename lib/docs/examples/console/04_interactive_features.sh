#!/bin/bash

# Example: Interactive Features
# This demonstrates interactive prompts, confirmations, and selections

# Import bash-lib
source core/init.sh
import console

echo "=== Interactive Features ==="

# Note: These examples are commented out to avoid blocking the script execution
# In a real scenario, you would uncomment the ones you want to test

echo ""
echo "=== Interactive Prompts (Commented for Demo) ==="
console.info "The following interactive features are commented out to avoid blocking the script:"

# Interactive prompts
echo "# console.prompt \"Enter your name: \""
echo "# console.confirm \"Do you want to continue? \""
echo "# console.select \"Choose an option:\" \"Option 1\" \"Option 2\" \"Option 3\""

# Simulated interactive session
echo ""
echo "=== Simulated Interactive Session ==="
console.info "Simulating an interactive session..."

# Simulate user input
echo "Simulated user input: John Doe"
console.success "Name entered: John Doe"

echo "Simulated user input: yes"
console.success "User confirmed: yes"

echo "Simulated user input: 2"
console.success "User selected: Option 2"

# Error handling with interactive features
echo ""
echo "=== Error Handling with Interactive Features ==="

function simulate_prompt() {
    local prompt="$1"
    local default="$2"
    
    console.info "Prompt: $prompt"
    if [ -n "$default" ]; then
        console.info "Default value: $default"
        console.success "Using default value: $default"
    else
        console.error "No input provided, using fallback"
    fi
}

simulate_prompt "Enter configuration file path:" "/etc/config.conf"
simulate_prompt "Enter port number:" ""
simulate_prompt "Enter database name:" "mydb"

# Confirmation examples
echo ""
echo "=== Confirmation Examples ==="

function simulate_confirm() {
    local message="$1"
    local default="$2"
    
    console.info "Confirmation: $message"
    if [ "$default" = "yes" ]; then
        console.success "User confirmed (default: yes)"
    elif [ "$default" = "no" ]; then
        console.warn "User declined (default: no)"
    else
        console.info "User response: $default"
    fi
}

simulate_confirm "Do you want to install the package?" "yes"
simulate_confirm "Do you want to delete the file?" "no"
simulate_confirm "Continue with the operation?" "yes"

# Selection examples
echo ""
echo "=== Selection Examples ==="

function simulate_select() {
    local prompt="$1"
    shift
    local options=("$@")
    
    console.info "Selection: $prompt"
    console.info "Available options:"
    for i in "${!options[@]}"; do
        console.info "  $((i+1)). ${options[i]}"
    done
    
    # Simulate user selection
    local selection=2
    console.success "User selected: $selection - ${options[$((selection-1))]}"
}

simulate_select "Choose a database type:" "MySQL" "PostgreSQL" "SQLite" "MongoDB"
simulate_select "Choose an environment:" "Development" "Staging" "Production"

# Input validation simulation
echo ""
echo "=== Input Validation ==="

function validate_input() {
    local input="$1"
    local validation_type="$2"
    
    console.info "Validating input: '$input' (type: $validation_type)"
    
    case "$validation_type" in
        "email")
            if [[ "$input" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
                console.success "Valid email address"
            else
                console.error "Invalid email address"
            fi
            ;;
        "number")
            if [[ "$input" =~ ^[0-9]+$ ]]; then
                console.success "Valid number"
            else
                console.error "Invalid number"
            fi
            ;;
        "required")
            if [ -n "$input" ]; then
                console.success "Input provided"
            else
                console.error "Input is required"
            fi
            ;;
    esac
}

validate_input "john@example.com" "email"
validate_input "invalid-email" "email"
validate_input "12345" "number"
validate_input "abc" "number"
validate_input "some text" "required"
validate_input "" "required"

echo ""
echo "=== Interactive Features Example Complete ===" 