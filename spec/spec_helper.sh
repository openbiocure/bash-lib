#shellcheck shell=sh

# set -eu

# shellspec_spec_helper_configure() {
#   shellspec_import 'support/custom_matcher'
# }

# Set up the environment for testing
export BASH__PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export BASH__VERBOSE="error"

# Source the core initialization
source lib/init.sh

# Make import function available in shellspec context
# Commented out to avoid conflicts with ShellSpec's internal import mechanism
# shellspec_import() {
#   import "$@"
# }

# Alternative function name for bash-lib imports if needed
bashlib_import() {
  import "$@"
}

# ShellSpec configuration function to make import available in test context
shellspec_spec_helper_configure() {
  # Make the import function available in test context
  import() {
    # Call the original import function from lib/init.sh
    command import "$@"
  }
}

# Setup function for tests
setup_test_environment() {
  # Import required modules
  import http
  import console
}
