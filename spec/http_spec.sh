Describe 'http'
Include ./core/init.sh
import http
    It "http.get will return a json"
        doWork(){
            http.get https://httpbin.org/json | jq '.slideshow.author'
        }
        When call doWork
        The output should equal "\"Yours Truly\""
    End
End