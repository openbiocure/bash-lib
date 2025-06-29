Describe 'console'

It "console.log function outputs correctly"
When call console.log "test message"
The stdout should include "LOG"
The stdout should include "test message"
The status should be success
End

It "console.log function can be called"
When call console.log hello
The stdout should include "LOG"
The stdout should include "hello"
The status should be success
End

It "console.log contains LOG identifier"
When run console.log "test output"
The output should include "LOG"
The status should be success
End

It "console module is loaded"
When call console.help
The status should be success
The output should include "Console Module"
End
End
