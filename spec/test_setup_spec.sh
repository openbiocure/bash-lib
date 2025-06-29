#!/usr/bin/env bash

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
