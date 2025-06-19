Describe 'console'
Include ./core/init.sh
It "Run console log"
    When run console.log hello 2>/dev/null
    The output should include "[LOG]: hello"
End
End