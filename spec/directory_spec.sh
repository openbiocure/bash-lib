#!/usr/bin/env bash

Describe 'directory'
setup() {
    # Source the import system in every test shell
    export BASH__PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/" && pwd)"
    source "${BASH__PATH}/lib/init.sh"
    import directory
}
Before setup

It "directory.list function works"
When call directory.list /tmp
The status should be success
The stdout should include "items in /tmp"
End

It "directory.list shows directory contents"
When run directory.list /tmp
The stdout should include "items in /tmp"
The status should be success
End

It "directory.search function works"
When call directory.search /tmp "*"
The status should be success
The stdout should include "items matching"
End

It "directory.search finds files"
When run directory.search /tmp "*"
The stdout should include "items matching"
The status should be success
End

It "directory.create function works"
When call directory.create /tmp/test_dir_$(date +%s)_123
The status should be success
The stdout should include "Created directory"
rm -rf /tmp/test_dir_*_123
End

It "directory.create creates directories"
When run directory.create /tmp/test_dir_$(date +%s)_456
The stdout should include "Created directory"
The status should be success
rm -rf /tmp/test_dir_*_456
End

It "directory.info function works"
When call directory.info /tmp
The status should be success
The stdout should include "File Information"
End

It "directory.info shows file details"
When run directory.info /tmp
The stdout should include "File Information"
The status should be success
End

It "directory.size function works"
When call directory.size /tmp
The status should be success
The stdout should include "Directory size"
End

It "directory.size shows directory size"
When run directory.size /tmp
The stdout should include "Directory size"
The status should be success
End

It "directory.help function works"
When call directory.help
The status should be success
The stdout should include "Directory Module"
End

It "directory module is loaded"
When call directory.help
The status should be success
The stdout should include "Directory Module"
End

It "directory.remove function works"
# Create a test file first
local test_file="/tmp/test_remove_$(date +%s).txt"
echo "test" >"$test_file"
When call directory.remove "$test_file"
The status should be success
The stdout should include "Removed file"
End

It "directory.copy function works"
# Create a test file first
local test_file="/tmp/test_copy_$(date +%s).txt"
local dest_dir="/tmp/copy_dest_$(date +%s)/"
echo "test" >"$test_file"
When call directory.copy "$test_file" "$dest_dir"
The status should be success
The stdout should include "Copied"
rm -rf /tmp/copy_dest_* /tmp/test_copy_*.txt
End

It "directory.move function works"
# Create a test file first
local test_file="/tmp/test_move_$(date +%s).txt"
local dest_file="/tmp/moved_$(date +%s).txt"
echo "test" >"$test_file"
When call directory.move "$test_file" "$dest_file"
The status should be success
The stdout should include "Moved"
rm -f /tmp/moved_*.txt
End

It "directory.find_empty function works"
# Create an empty file first
touch /tmp/empty_test_$(date +%s).txt
When call directory.find_empty /tmp
The status should be success
The stdout should include "empty items found"
rm -f /tmp/empty_test_*.txt
End

It "directory.set_depth function works"
When call directory.set_depth 5
The status should be success
The stdout should include "Default search depth set to 5"
End

It "directory.set_max_results function works"
When call directory.set_max_results 50
The status should be success
The stdout should include "Default max results set to 50"
End
End
