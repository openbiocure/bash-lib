Describe 'http'
Include ./core/init.sh
import http
    It "http.get will return content"
        doWork(){
            http.get https://dummyjson.com/products/1 2>/dev/null | grep -q "title"
        }
        When call doWork
        The status should be success
    End
    
    It "http.get returns JSON content"
        When run http.get https://dummyjson.com/products/1 2>/dev/null
        The output should include "title"
        The status should be success
    End
End