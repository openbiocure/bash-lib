#!/bin/bash

Describe "console module basic logging"
setup() {
    export BASH__PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/" && pwd)"
    source "$BASH__PATH/lib/config/colors.inc"
    source "$BASH__PATH/lib/modules/system/console.mod.sh"
    console.set_verbosity "trace"
}
Before setup

It "outputs a log message with correct level and content"
  When call console.log "hello world"
  The stdout should match pattern "*hello world*"
  The status should be success
End

It "outputs info messages"
  When call console.info "info message"
  The stdout should match pattern "*info message*"
  The status should be success
End

It "outputs debug messages"
  When call console.debug "debug message"
  The stdout should match pattern "*debug message*"
  The status should be success
End

It "outputs warning messages"
  When call console.warn "warning message"
  The stderr should match pattern "*warning message*"
  The status should be success
End

It "outputs error messages"
  When call console.error "error message"
  The stderr should match pattern "*error message*"
  The status should be success
End

It "outputs success messages"
  When call console.success "success message"
  The stdout should match pattern "*success message*"
  The status should be success
End

It "outputs fatal messages"
  When call console.fatal "fatal message"
  The stderr should match pattern "*fatal message*"
  The status should be success
End

It "outputs trace messages"
  When call console.trace "trace message"
  The stdout should match pattern "*trace message*"
  The status should be success
End
End

Describe "console module verbosity control"
setup() {
    export BASH__PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/" && pwd)"
    source "$BASH__PATH/lib/config/colors.inc"
    source "$BASH__PATH/lib/modules/system/console.mod.sh"
}
Before setup

It "sets verbosity to debug level"
  When call console.set_verbosity "debug"
  The stdout should match pattern "*Verbosity set to: debug*"
  The status should be success
End

It "sets verbosity to info level"
  When call console.set_verbosity "info"
  The status should be success
End

It "sets verbosity to warn level"
  When call console.set_verbosity "warn"
  The status should be success
End

It "sets verbosity to error level"
  When call console.set_verbosity "error"
  The status should be success
End

It "rejects invalid verbosity level"
  When call console.set_verbosity "invalid"
  The status should be failure
  The stderr should match pattern "*Invalid verbosity level*"
End

It "gets current verbosity level"
  When call console.get_verbosity
  The stdout should match pattern "*"
  The status should be success
End
End

Describe "console module output control"
setup() {
    export BASH__PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/" && pwd)"
    source "$BASH__PATH/lib/config/colors.inc"
    source "$BASH__PATH/lib/modules/system/console.mod.sh"
}
Before setup

It "sets output to stdout"
  When call console.set_output "stdout"
  The status should be success
End

It "sets output to stderr"
  When call console.set_output "stderr"
  The status should be success
End

It "sets output to /dev/null"
  When call console.set_output "/dev/null"
  The status should be success
End

It "gets current output setting"
  When call console.get_output
  The stdout should match pattern "*"
  The status should be success
End

It "rejects invalid output setting"
  When call console.set_output "invalid"
  The status should be failure
  The stderr should match pattern "*Invalid output*"
End
End

Describe "console module simple output functions"
setup() {
    export BASH__PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/" && pwd)"
    source "$BASH__PATH/lib/config/colors.inc"
    source "$BASH__PATH/lib/modules/system/console.mod.sh"
}
Before setup

It "prints without newline"
  When call console.print "test"
  The stdout should eq "test"
  The status should be success
End

It "prints with newline"
  When call console.println "test"
  The stdout should eq "test"
  The status should be success
End

It "prints error to stderr without newline"
  When call console.print_error "error test"
  The stderr should eq "error test"
  The status should be success
End

It "prints error to stderr with newline"
  When call console.println_error "error test"
  The stderr should eq "error test"
  The status should be success
End

It "prints empty string"
  When call console.empty
  The stdout should eq ""
  The status should be success
End

It "forces output in test mode with force flag"
  When call console.print "test" "force"
  The stdout should eq "test"
  The status should be success
End
End

Describe "console module time format control"
setup() {
    export BASH__PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/" && pwd)"
    source "$BASH__PATH/lib/config/colors.inc"
    source "$BASH__PATH/lib/modules/system/console.mod.sh"
}
Before setup

It "sets time format"
  When call console.set_time_format "+%Y-%m-%d"
  The status should be success
End

It "rejects empty time format"
  When call console.set_time_format ""
  The status should be failure
  The stderr should match pattern "*No time format specified*"
End

It "rejects no time format"
  When call console.set_time_format
  The status should be failure
  The stderr should match pattern "*No time format specified*"
End
End

Describe "console module edge cases"
setup() {
    export BASH__PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/" && pwd)"
    source "$BASH__PATH/lib/config/colors.inc"
    source "$BASH__PATH/lib/modules/system/console.mod.sh"
    console.set_verbosity "trace"
}
Before setup

It "handles empty messages"
  When call console.log
  # At least something was output
  The stdout should match pattern "*[[]LOG[]]:*"
The status should be success
End

It "handles messages with special characters"
  When call console.log "test@#$%^&*()"
  The stdout should match pattern "*test@#$%^&*()*"
The status should be success
End

It "handles messages with spaces"
  When call console.log "test message with spaces"
  The stdout should match pattern "*test message with spaces*"
The status should be success
End

It "handles unicode characters"
  When call console.log "test 🚀 emoji"
  The stdout should match pattern "*test 🚀 emoji*"
  The status should be success
End
End

Describe "console module help function"
setup() {
    export BASH__PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/" && pwd)"
    source "$BASH__PATH/lib/config/colors.inc"
    source "$BASH__PATH/lib/modules/system/console.mod.sh"
}
Before setup

It "shows help information"
When call console.help
  The stdout should match pattern "*Console Module*"
The status should be success
End
End
