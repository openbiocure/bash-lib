#!/usr/bin/env bash
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/" && pwd)/lib/init.sh"

Describe 'Simple Test'
It 'should work'
When run echo "hello"
The output should eq "hello"
End
End
