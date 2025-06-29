#!/bin/bash

# Example: Progress Indicators
# This demonstrates progress bars, spinners, and status updates

# Import bash-lib
source core/init.sh
import console

echo "=== Progress Indicators ==="

# Progress indicators
echo ""
echo "=== Progress Bar ==="
console.progress.start "Processing data"
sleep 1
console.progress.update "Step 1/3: Reading files"
sleep 1
console.progress.update "Step 2/3: Processing data"
sleep 1
console.progress.update "Step 3/3: Writing results"
sleep 1
console.progress.complete "Processing completed successfully"

# Spinner for long-running operations
echo ""
echo "=== Spinner Example ==="
console.spinner.start "Downloading files"
sleep 3
console.spinner.stop "Download completed"

# Status indicators
echo ""
echo "=== Status Indicators ==="
console.status "Database" "online"
console.status "Web Server" "online"
console.status "Cache" "offline"
console.status "API Gateway" "online"
console.status "Load Balancer" "degraded"

# Progress with percentage
echo ""
echo "=== Progress with Percentage ==="
console.progress.start "Installing packages"
for i in {1..10}; do
    percentage=$((i * 10))
    console.progress.update "Installing package $i/10 ($percentage%)"
    sleep 0.5
done
console.progress.complete "Installation completed"

# Multiple spinners
echo ""
echo "=== Multiple Spinners ==="
console.spinner.start "Task 1: Initializing"
sleep 1
console.spinner.stop "Task 1 completed"

console.spinner.start "Task 2: Processing"
sleep 1
console.spinner.stop "Task 2 completed"

console.spinner.start "Task 3: Finalizing"
sleep 1
console.spinner.stop "Task 3 completed"

# Error handling with progress
echo ""
echo "=== Error Handling with Progress ==="
console.progress.start "Testing system components"
sleep 1
console.progress.update "Testing database connection"
sleep 1
console.progress.update "Testing file system"
sleep 1
console.progress.error "File system test failed"
console.error "Cannot access required directory"

echo ""
echo "=== Progress Indicators Example Complete ===" 