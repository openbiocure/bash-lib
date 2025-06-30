setup() {
    export BASH__PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/" && pwd)"
    source "${BASH__PATH}/lib/init.sh"
    import string
}
Before setup

Describe 'string replace'
 It "Run String Replace"

    When run string.replace mary cathy "How are you mary?"
    The output should equal "How are you cathy?"
 End
End
