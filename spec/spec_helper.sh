#shellcheck shell=sh

# set -eu

# shellspec_spec_helper_configure() {
#   shellspec_import 'support/custom_matcher'
# }

# Setup function for tests
setup_test_environment() {
  # Set up bash-lib environment
  export BASH__PATH="$(pwd)"
  export BASH__VERBOSE="info"
  
  # Source the core initialization
  source core/init.sh
  
  # Import required modules
  import http
  import console
}
