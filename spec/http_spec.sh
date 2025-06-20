#!/bin/bash

Describe 'HTTP Module'
  Include spec/spec_helper.sh

  BeforeAll 'setup_test_environment'

  Describe 'http.get'
    It 'should perform GET request successfully'
      When call http.get "https://dummyjson.com/products/1"
      The status should be success
      The output should include '"id":1'
    End

    It 'should handle headers correctly'
      When call http.get "https://dummyjson.com/products/1" --header="Accept: application/json"
      The status should be success
      The output should include '"id":1'
    End

    It 'should handle timeout option'
      When call http.get "https://dummyjson.com/products/1" --timeout=30
      The status should be success
      The output should include '"id":1'
    End

    It 'should handle insecure option'
      When call http.get "https://dummyjson.com/products/1" --insecure
      The status should be success
      The output should include '"id":1'
    End
  End

  Describe 'http.post'
    It 'should perform POST request with JSON data'
      When call http.post "https://dummyjson.com/products/add" --data='{"title":"Test Product","price":99.99}'
      The status should be success
      The output should include '"title":"Test Product"'
    End

    It 'should perform POST request with URL-encoded data'
      When call http.post "https://dummyjson.com/products/add" --data-urlencode="title=Test Product" --data-urlencode="price=99.99"
      The status should be success
      The output should include '"title":"Test Product"'
    End
  End

  Describe 'http.put'
    It 'should perform PUT request'
      When call http.put "https://dummyjson.com/products/1" --data='{"title":"Updated Product"}'
      The status should be success
      The output should include '"title":"Updated Product"'
    End
  End

  Describe 'http.delete'
    It 'should perform DELETE request'
      When call http.delete "https://dummyjson.com/products/1"
      The status should be success
      The output should include '"id":1'
    End
  End

  Describe 'http.status'
    It 'should return HTTP status code'
      When call http.status "https://dummyjson.com/products/1"
      The status should be success
      The output should eq "200"
    End

    It 'should return 404 for non-existent resource'
      When call http.status "https://dummyjson.com/products/999999"
      The status should be success
      The output should eq "404"
    End
  End

  Describe 'http.is_200'
    It 'should return true for 200 status'
      When call http.is_200 "https://dummyjson.com/products/1"
      The status should be success
    End

    It 'should return false for 404 status'
      When call http.is_200 "https://dummyjson.com/products/999999"
      The status should be failure
    End
  End

  Describe 'http.is_404'
    It 'should return true for 404 status'
      When call http.is_404 "https://dummyjson.com/products/999999"
      The status should be success
    End

    It 'should return false for 200 status'
      When call http.is_404 "https://dummyjson.com/products/1"
      The status should be failure
    End
  End

  Describe 'http.check'
    It 'should return success for accessible URL'
      When call http.check "https://dummyjson.com/products/1"
      The status should be success
    End

    It 'should return failure for inaccessible URL'
      When call http.check "https://dummyjson.com/products/999999"
      The status should be failure
    End

    It 'should handle timeout option'
      When call http.check "https://dummyjson.com/products/1" --timeout=30
      The status should be success
    End
  End

  Describe 'http.headers'
    It 'should return response headers'
      When call http.headers "https://dummyjson.com/products/1"
      The status should be success
      The output should include "HTTP"
    End

    It 'should handle custom headers'
      When call http.headers "https://dummyjson.com/products/1" --header="User-Agent: TestAgent"
      The status should be success
      The output should include "HTTP"
    End
  End

  Describe 'http.download'
    It 'should download file successfully'
      local test_file="/tmp/test_download.json"
      When call http.download "https://dummyjson.com/products/1" "$test_file"
      The status should be success
      The path "$test_file" should be exist
      The contents of file "$test_file" should include '"id":1'
      rm -f "$test_file"
    End

    It 'should handle retries on failure'
      local test_file="/tmp/test_download_fail.json"
      When call http.download "https://invalid-url-that-does-not-exist.com/file.json" "$test_file" --retries=2
      The status should be failure
      rm -f "$test_file"
    End

    It 'should create output directory if it does not exist'
      local test_dir="/tmp/test_download_dir"
      local test_file="$test_dir/test.json"
      When call http.download "https://dummyjson.com/products/1" "$test_file"
      The status should be success
      The path "$test_dir" should be exist
      The path "$test_file" should be exist
      rm -rf "$test_dir"
    End
  End

  Describe 'http.set_timeout'
    It 'should set timeout correctly'
      When call http.set_timeout 60
      The status should be success
      The output should include "HTTP timeout set to 60 seconds"
    End

    It 'should reject invalid timeout values'
      When call http.set_timeout "invalid"
      The status should be failure
      The output should include "Invalid timeout value"
    End
  End

  Describe 'http.set_retries'
    It 'should set retry count correctly'
      When call http.set_retries 5
      The status should be success
      The output should include "HTTP retry count set to 5"
    End

    It 'should reject invalid retry values'
      When call http.set_retries "invalid"
      The status should be failure
      The output should include "Invalid retry count"
    End
  End

  Describe 'http.help'
    It 'should display help information'
      When call http.help
      The status should be success
      The output should include "HTTP Module - Comprehensive HTTP client"
      The output should include "http.get"
      The output should include "http.download"
    End
  End

  Describe 'Error handling'
    It 'should handle missing URL parameter'
      When call http.get
      The status should be failure
      The output should include "Usage: http.GET"
    End

    It 'should handle missing URL parameter for download'
      When call http.download
      The status should be failure
      The output should include "Usage: http.download"
    End

    It 'should handle missing URL parameter for status'
      When call http.status
      The status should be failure
      The output should include "Usage: http.status"
    End
  End

  Describe 'Request with status output'
    It 'should include status code in output when requested'
      When call http.get "https://dummyjson.com/products/1" --show-status
      The status should be success
      The output should include '"id":1'
    End

    It 'should return failure status for 4xx/5xx responses'
      When call http.get "https://dummyjson.com/products/999999" --show-status
      The status should be failure
    End
  End
End