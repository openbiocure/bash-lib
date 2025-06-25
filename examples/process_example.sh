#!/bin/bash

# Example: Process Module
# This demonstrates the process management functionality

# Import bash-lib
source core/init.sh
import process
import console

echo "=== Process Module Example ==="

echo ""
echo "=== Current Process Information ==="

# Get current process information
console.info "Getting current process information..."
current_pid=$(process.currentPid)
console.info "Current process PID: $current_pid"

current_ppid=$(process.currentPpid)
console.info "Current process PPID: $current_ppid"

current_name=$(process.currentName)
console.info "Current process name: $current_name"

current_command=$(process.currentCommand)
console.info "Current process command: $current_command"

current_user=$(process.currentUser)
console.info "Current process user: $current_user"

current_group=$(process.currentGroup)
console.info "Current process group: $current_group"

echo ""
echo "=== Process Information ==="

# Get process information by PID
console.info "Getting process information by PID..."
process_info=$(process.info "$current_pid")
console.info "Process information: $process_info"

# Check if process exists
console.info "Checking if process exists..."
if process.exists "$current_pid"; then
    console.success "Process $current_pid exists"
else
    console.error "Process $current_pid does not exist"
fi

# Check non-existent process
if process.exists 999999; then
    console.error "Non-existent process found (unexpected)"
else
    console.success "Non-existent process properly detected"
fi

# Get process name
process_name=$(process.getName "$current_pid")
console.info "Process name: $process_name"

# Get process command
process_cmd=$(process.getCommand "$current_pid")
console.info "Process command: $process_cmd"

# Get process user
process_user=$(process.getUser "$current_pid")
console.info "Process user: $process_user"

# Get process group
process_group=$(process.getGroup "$current_pid")
console.info "Process group: $process_group"

# Get process start time
start_time=$(process.getStartTime "$current_pid")
console.info "Process start time: $start_time"

# Get process CPU usage
cpu_usage=$(process.getCpuUsage "$current_pid")
console.info "Process CPU usage: $cpu_usage"

# Get process memory usage
memory_usage=$(process.getMemoryUsage "$current_pid")
console.info "Process memory usage: $memory_usage"

echo ""
echo "=== Process State ==="

# Get process state
console.info "Getting process state..."
state=$(process.getState "$current_pid")
console.info "Process state: $state"

# Check if process is running
console.info "Checking if process is running..."
if process.isRunning "$current_pid"; then
    console.success "Process is running"
else
    console.error "Process is not running"
fi

# Check if process is sleeping
console.info "Checking if process is sleeping..."
if process.isSleeping "$current_pid"; then
    console.success "Process is sleeping"
else
    console.success "Process is not sleeping"
fi

# Check if process is stopped
console.info "Checking if process is stopped..."
if process.isStopped "$current_pid"; then
    console.success "Process is stopped"
else
    console.success "Process is not stopped"
fi

# Check if process is zombie
console.info "Checking if process is zombie..."
if process.isZombie "$current_pid"; then
    console.warn "Process is zombie"
else
    console.success "Process is not zombie"
fi

echo ""
echo "=== Process Relationships ==="

# Get parent process
console.info "Getting parent process..."
parent_pid=$(process.getParent "$current_pid")
console.info "Parent PID: $parent_pid"

# Get child processes
console.info "Getting child processes..."
children=$(process.getChildren "$current_pid")
console.info "Child processes: $children"

# Get process tree
console.info "Getting process tree..."
tree=$(process.getTree "$current_pid")
console.info "Process tree: $tree"

# Get process siblings
console.info "Getting process siblings..."
siblings=$(process.getSiblings "$current_pid")
console.info "Process siblings: $siblings"

echo ""
echo "=== Process Management ==="

# Start a background process
console.info "Starting background process..."
background_pid=$(process.startBackground "sleep 30")
console.info "Background process started with PID: $background_pid"

# Wait a moment for the process to start
sleep 1

# Check if the background process is running
if process.isRunning "$background_pid"; then
    console.success "Background process is running"
else
    console.error "Background process is not running"
fi

# Suspend process
console.info "Suspending process..."
if process.suspend "$background_pid"; then
    console.success "Process suspended"
else
    console.error "Failed to suspend process"
fi

# Resume process
console.info "Resuming process..."
if process.resume "$background_pid"; then
    console.success "Process resumed"
else
    console.error "Failed to resume process"
fi

# Stop process gracefully
console.info "Stopping process gracefully..."
if process.stop "$background_pid"; then
    console.success "Process stopped gracefully"
else
    console.error "Failed to stop process gracefully"
fi

# Start another process for testing
test_pid=$(process.startBackground "sleep 60")
sleep 1

# Kill process forcefully
console.info "Killing process forcefully..."
if process.kill "$test_pid"; then
    console.success "Process killed forcefully"
else
    console.error "Failed to kill process"
fi

echo ""
echo "=== Process Monitoring ==="

# Monitor process
console.info "Monitoring process..."
process.monitor "$current_pid" 5 &
monitor_pid=$!

# Wait for monitoring
sleep 3

# Stop monitoring
kill $monitor_pid 2>/dev/null || true

# Get process statistics
console.info "Getting process statistics..."
stats=$(process.getStats "$current_pid")
console.info "Process statistics: $stats"

# Get process performance
console.info "Getting process performance..."
performance=$(process.getPerformance "$current_pid")
console.info "Process performance: $performance"

echo ""
echo "=== Process Search ==="

# Search for processes by name
console.info "Searching for processes by name..."
bash_processes=$(process.findByName "bash")
console.info "Bash processes: $bash_processes"

# Search for processes by user
console.info "Searching for processes by user..."
user_processes=$(process.findByUser "$current_user")
console.info "User processes: $user_processes"

# Search for processes by command pattern
console.info "Searching for processes by command pattern..."
pattern_processes=$(process.findByCommand "sleep")
console.info "Sleep processes: $pattern_processes"

# Search for processes by state
console.info "Searching for processes by state..."
running_processes=$(process.findByState "R")
console.info "Running processes: $running_processes"

echo ""
echo "=== Process Comparison ==="

# Compare processes
console.info "Comparing processes..."
if process.equals "$current_pid" "$current_pid"; then
    console.success "Process comparison works correctly"
else
    console.error "Process comparison failed"
fi

if process.equals "$current_pid" "$parent_pid"; then
    console.error "Different processes are equal (unexpected)"
else
    console.success "Different processes are not equal"
fi

# Check if process is child of another
console.info "Checking process relationships..."
if process.isChildOf "$current_pid" "$parent_pid"; then
    console.success "Current process is child of parent"
else
    console.error "Current process is not child of parent"
fi

# Check if process is parent of another
if process.isParentOf "$parent_pid" "$current_pid"; then
    console.success "Parent process is parent of current process"
else
    console.error "Parent process is not parent of current process"
fi

echo ""
echo "=== Process Utilities ==="

# Get process priority
console.info "Getting process priority..."
priority=$(process.getPriority "$current_pid")
console.info "Process priority: $priority"

# Set process priority
console.info "Setting process priority..."
if process.setPriority "$current_pid" 10; then
    console.success "Process priority set to 10"
else
    console.error "Failed to set process priority"
fi

# Get process nice value
console.info "Getting process nice value..."
nice_value=$(process.getNice "$current_pid")
console.info "Process nice value: $nice_value"

# Set process nice value
console.info "Setting process nice value..."
if process.setNice "$current_pid" 5; then
    console.success "Process nice value set to 5"
else
    console.error "Failed to set process nice value"
fi

# Get process working directory
console.info "Getting process working directory..."
work_dir=$(process.getWorkingDirectory "$current_pid")
console.info "Process working directory: $work_dir"

# Get process environment
console.info "Getting process environment..."
env=$(process.getEnvironment "$current_pid")
console.info "Process environment: $env"

echo ""
echo "=== Process Signals ==="

# Start a process for signal testing
signal_pid=$(process.startBackground "sleep 30")
sleep 1

# Send different signals
console.info "Sending signals to process..."

# Send SIGTERM
console.info "Sending SIGTERM..."
if process.sendSignal "$signal_pid" "TERM"; then
    console.success "SIGTERM sent"
else
    console.error "Failed to send SIGTERM"
fi

# Wait a moment
sleep 1

# Check if process is still running
if process.isRunning "$signal_pid"; then
    console.info "Process still running after SIGTERM"
    
    # Send SIGKILL
    console.info "Sending SIGKILL..."
    if process.sendSignal "$signal_pid" "KILL"; then
        console.success "SIGKILL sent"
    else
        console.error "Failed to send SIGKILL"
    fi
else
    console.success "Process terminated by SIGTERM"
fi

echo ""
echo "=== Process Groups and Sessions ==="

# Get process group
console.info "Getting process group..."
group_id=$(process.getGroupId "$current_pid")
console.info "Process group ID: $group_id"

# Get process session
console.info "Getting process session..."
session_id=$(process.getSessionId "$current_pid")
console.info "Process session ID: $session_id"

# Get processes in same group
console.info "Getting processes in same group..."
group_processes=$(process.getByGroup "$group_id")
console.info "Processes in group $group_id: $group_processes"

# Get processes in same session
console.info "Getting processes in same session..."
session_processes=$(process.getBySession "$session_id")
console.info "Processes in session $session_id: $session_processes"

echo ""
echo "=== Process Cleanup ==="

# Kill all child processes
console.info "Killing all child processes..."
if process.killChildren "$current_pid"; then
    console.success "All child processes killed"
else
    console.error "Failed to kill all child processes"
fi

# Clean up zombie processes
console.info "Cleaning up zombie processes..."
if process.cleanupZombies; then
    console.success "Zombie processes cleaned up"
else
    console.error "Failed to cleanup zombie processes"
fi

echo ""
echo "=== Process Module Example Complete ===" 