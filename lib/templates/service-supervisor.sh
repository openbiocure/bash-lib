#!/bin/bash
# Auto-generated supervisor script for {{SERVICE_NAME}}
# Generated at: $(date)
# Generator: bash-lib
# Author: openbiocure

# IMPORTANT: Why we use printf instead of console functions
# ========================================================
# This script runs as a standalone background process via nohup, which means:
# 1. It executes BEFORE bash-lib is loaded (console functions don't exist yet)
# 2. It runs in a detached process that may not inherit the full environment
# 3. It needs to write directly to log files for persistence, not stdout/stderr
# 4. Console functions are designed for interactive output, not file logging
# 5. printf is always available (built into bash) and reliable in background processes
# 
# The execution flow:
# Main process → creates this script → starts with nohup → runs independently
# This script needs to work before sourcing bash-lib, hence printf is required.

# Ensure we can find bash-lib
# Set BASH__PATH to /opt/bash-lib if not already set
export BASH__PATH="${BASH__PATH:-/opt/bash-lib}"
if [[ ! -f "$BASH__PATH/init.sh" ]]; then
    printf '%s: ERROR: Cannot find bash-lib at %s\n' "$(date)" "$BASH__PATH" >> "{{LOG_FILE}}"
    exit 1
fi

source "$BASH__PATH/init.sh"
import service

# Supervisor loop
restart_count=0
max_restarts={{MAX_RESTARTS}}
restart_delay={{RESTART_DELAY}}
service_name="{{SERVICE_NAME}}"
command="{{COMMAND}}"

printf '%s: Supervisor started for service %s\n' "$(date)" "'$service_name'" >> "{{LOG_FILE}}"

while true; do
    # Check restart limits
    if [[ $max_restarts -gt 0 && $restart_count -ge $max_restarts ]]; then
        printf '%s: Service %s exceeded maximum restart attempts (%s)\n' "$(date)" "'$service_name'" "$max_restarts" >> "{{LOG_FILE}}"
        exit 1
    fi

    # Start the service
    printf '%s: Starting service %s (attempt %s)\n' "$(date)" "'$service_name'" "$((restart_count + 1))" >> "{{LOG_FILE}}"
    
    # Use nohup to run the command
    nohup $command >> "{{LOG_FILE}}" 2>&1 &
    pid=$!
    
    # Write PID to file
    printf '%s\n' "$pid" > "{{PID_FILE}}"
    
    printf '%s: Service %s started with PID: %s\n' "$(date)" "'$service_name'" "$pid" >> "{{LOG_FILE}}"
    
    # Wait for process to die
    while kill -0 $pid 2>/dev/null; do
        sleep 5
    done
    
    # Process died
    printf '%s: Service %s (PID: %s) has stopped\n' "$(date)" "'$service_name'" "$pid" >> "{{LOG_FILE}}"
    
    # Increment restart count and wait before restarting
    restart_count=$((restart_count + 1))
    printf '%s: Restarting service %s in %s seconds... (restart #%s)\n' "$(date)" "'$service_name'" "$restart_delay" "$restart_count" >> "{{LOG_FILE}}"
    sleep "$restart_delay"
done 