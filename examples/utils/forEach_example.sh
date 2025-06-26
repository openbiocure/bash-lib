#!/bin/bash

# Example: forEach Module
# This demonstrates the forEach iteration utilities

# Import bash-lib
source core/init.sh
import forEach
import console
import process

echo "=== forEach Module Example ==="

echo ""
echo "=== Testing forEach.array ==="

console.info "Basic array iteration:"
forEach.array "item" "echo 'Processing: \$item'" "apple" "banana" "cherry" "date"

echo ""
console.info "Array iteration with parallel execution:"
forEach.array "num" "echo 'Number \$num squared: \$((num * num))'" --parallel=3 1 2 3 4 5 6 7 8 9 10

echo ""
console.info "Array iteration with error handling:"
forEach.array "pid" "process.exists \$pid && echo 'Process \$pid exists' || echo 'Process \$pid not found'" --continue-on-error --verbose 1 999999 2 888888

echo ""
echo "=== Testing forEach.file ==="

# Create a test file
echo "Creating test file..."
cat >test_commands.txt <<'EOF'
echo "Command 1"
echo "Command 2"
echo "Command 3"
# This is a comment
echo "Command 4"

echo "Command 5"
EOF

console.info "File iteration (basic):"
forEach.file "line" "echo 'Executing: \$line'" test_commands.txt

echo ""
console.info "File iteration with comment and empty line skipping:"
forEach.file "line" "echo 'Processing: \$line'" test_commands.txt --skip-comments --skip-empty

echo ""
console.info "File iteration with parallel execution:"
forEach.file "line" "echo 'Parallel: \$line'" test_commands.txt --parallel=2 --verbose

echo ""
echo "=== Testing forEach.command ==="

console.info "Command output iteration:"
forEach.command "line" "echo 'Found: \$line'" "ls -1 *.sh | head -5"

echo ""
console.info "Command iteration with process management:"
# Start some background processes for testing
sleep 60 &
sleep 60 &
sleep 60 &
console.info "Started background sleep processes"

# Wait a moment for processes to start
sleep 1

console.info "Stopping sleep processes:"
forEach.command "pid" "process.stop \$pid --verbose" "pgrep sleep" --parallel=3

echo ""
console.info "Command iteration with dry-run:"
forEach.command "file" "echo 'Would process: \$file'" "find . -name '*.txt' -type f" --dry-run

echo ""
echo "=== Testing Advanced forEach Features ==="

console.info "Combining forEach with other modules:"
forEach.array "num" "echo 'Number \$num: \$(string.upper \$num)'" "one" "two" "three" "four" "five"

echo ""
console.info "forEach with mathematical operations:"
forEach.array "num" "echo '2^\$num = \$((2 ** num))'" 1 2 3 4 5 6 7 8

echo ""
console.info "forEach with conditional processing:"
forEach.array "file" "if [[ -f \$file ]]; then echo 'File exists: \$file'; else echo 'File missing: \$file'; fi" "README.md" "nonexistent.txt" "core/init.sh"

echo ""
console.info "forEach with break-on-error:"
forEach.array "cmd" "process.run \$cmd --timeout=2" --break-on-error --verbose "echo 'success'" "false" "echo 'this should not run'"

echo ""
console.info "forEach with silent mode:"
forEach.array "item" "echo 'Silent processing: \$item'" --silent "item1" "item2" "item3"

echo ""
echo "=== Testing forEach Error Handling ==="

console.info "Testing with invalid parameters:"
if forEach.array "" "echo test" "item"; then
    console.error "Unexpected success with empty variable name"
else
    console.success "Properly handled empty variable name"
fi

if forEach.array "var" "" "item"; then
    console.error "Unexpected success with empty callback"
else
    console.success "Properly handled empty callback"
fi

if forEach.array "var" "echo test"; then
    console.error "Unexpected success with no items"
else
    console.success "Properly handled no items"
fi

console.info "Testing file iteration with non-existent file:"
if forEach.file "line" "echo \$line" "nonexistent.txt"; then
    console.error "Unexpected success with non-existent file"
else
    console.success "Properly handled non-existent file"
fi

echo ""
console.info "Testing command iteration with failing command:"
if forEach.command "line" "echo \$line" "nonexistent_command"; then
    console.error "Unexpected success with failing command"
else
    console.success "Properly handled failing command"
fi

# Clean up
rm -f test_commands.txt

echo ""
console.success "All forEach examples completed!"
