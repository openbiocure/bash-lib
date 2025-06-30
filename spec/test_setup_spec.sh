#!/usr/bin/env bash

setup() {
    export BASH__PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/" && pwd)"
    source "${BASH__PATH}/lib/init.sh"
}
Before setup

Describe 'Test Setup'
setup() {
    # Simple test - just echo something
    echo "Setup function called"
}
Before setup

It "should work"
When run echo "test"
The output should eq "test"
End
End
