#!/bin/bash

# bash-lib Core Initialization Script
# Enhanced for Docker compatibility with comprehensive debugging and error handling

# Enable debugging in Docker environments
if [[ -f /.dockerenv ]] || grep -q docker /proc/1/cgroup 2>/dev/null; then
  # Docker environment detected - enable debugging
  export BASH_LIB_DEBUG=true
  export BASH_LIB_DOCKER=true
fi

# Debug mode setup
if [[ "${BASH_LIB_DEBUG}" == "true" ]]; then
  set -x    # Enable debug mode
  exec 2>&1 # Ensure stderr goes to stdout for Docker build logs
  echo "DEBUG: bash-lib init.sh starting"
  echo "DEBUG: Current environment:"
  env | sort
  echo "DEBUG: Current directory: $(pwd)"
  echo "DEBUG: Available commands:"
  which bash curl wget ls cat 2>/dev/null || echo "DEBUG: Some commands not found"
  echo "DEBUG: BASH__PATH=${BASH__PATH}"
  echo "DEBUG: BASH_SOURCE[0]=${BASH_SOURCE[0]}"
fi

# Timeout protection for Docker environments
if [[ "${BASH_LIB_DOCKER}" == "true" ]]; then
  # Set a timeout for the entire initialization process
  TIMEOUT_SECONDS=30
  echo "DEBUG: Docker environment detected, setting timeout to ${TIMEOUT_SECONDS} seconds"
fi

# Environment validation
validate_environment() {
  echo "DEBUG: Validating environment..."

  # Check required environment variables
  local required_vars=("PATH")
  for var in "${required_vars[@]}"; do
    if [[ -z "${!var}" ]]; then
      echo "ERROR: Required environment variable $var is not set"
      return 1
    fi
  done

  # Check if we're in a Docker container
  if [[ -f /.dockerenv ]] || grep -q docker /proc/1/cgroup 2>/dev/null; then
    echo "DEBUG: Running in Docker container"
  fi

  # Check if we're running as root
  if [[ "$(id -u)" -eq 0 ]]; then
    echo "DEBUG: Running as root user"
  fi

  echo "DEBUG: Environment validation passed"
  return 0
}

# Import metadata functions - define these first so modules can use them
function import.meta.loaded() {
  local module_name="$1"
  local module_path="$2"
  local version="${3:-unknown}"

  if [[ -n "$module_name" && -n "$module_path" ]]; then
    # Check if module is already loaded to avoid duplicate messages
    local check_var="BASH_LIB_IMPORTED_${module_name//\//_}"
    if [[ -z "${!check_var}" ]]; then
      echo "Module: $module_name, Version: $version, Loaded from: $module_path"
    fi
  else
    echo "Usage: import.meta.loaded <module_name> <module_path> [version]"
  fi
}

function import.meta.all() {
  echo "Loaded bash-lib modules:"
  echo "========================"
  declare -xp | grep '^declare \-x BASH_LIB_IMPORTED_' | while read -r line; do
    local var_name=$(echo "$line" | cut -d'=' -f1 | sed 's/declare -x //')
    local module_name=$(echo "$var_name" | sed 's/BASH_LIB_IMPORTED_//')
    echo "  ✓ $module_name"
  done
}

function import.meta.info() {
  local module_name="$1"

  if [[ -z "$module_name" ]]; then
    echo "Usage: import.meta.info <module_name>"
    return 1
  fi

  local check_var="BASH_LIB_IMPORTED_${module_name//\//_}"
  if [[ -n "${!check_var}" ]]; then
    echo "Module '$module_name' is loaded"
    return 0
  else
    echo "Module '$module_name' is not loaded"
    return 1
  fi
}

function import.force() {
  # Force reload a module even if it's already loaded
  local module_name="$1"
  local extension="${2:-mod.sh}"

  if [[ -z "$module_name" ]]; then
    echo -e "\e[31mError: \e[0mNo module name provided"
    echo -e "Usage: \e[1mimport.force <module_name> [extension]\e[0m"
    return 1
  fi

  # Check if module is already loaded
  local check_var="BASH_LIB_IMPORTED_${module_name//\//_}"
  local already_loaded=false

  if [[ -n "${!check_var}" ]]; then
    already_loaded=true
  fi

  # Only clear the import signal if we're actually forcing a reload
  if [[ "$already_loaded" == "true" ]]; then
    unset "$check_var" 2>/dev/null || true
  fi

  # Handle special cases for modules in subdirectories
  local module_path=""
  case "$module_name" in
  "console")
    # System-level console logging module
    module_path="${BASH__PATH}/lib/modules/system/console.mod.sh"
    ;;
  "trapper")
    # System-level signal handling and error trapping module
    module_path="${BASH__PATH}/lib/modules/system/trapper.mod.sh"
    ;;
  "service")
    # System-level service management module
    module_path="${BASH__PATH}/lib/modules/system/service.mod.sh"
    ;;
  "process")
    # System-level process management module
    module_path="${BASH__PATH}/lib/modules/system/process.mod.sh"
    ;;
  "engine")
    # Core engine functionality for module management
    module_path="${BASH__PATH}/lib/modules/core/engine.mod.sh"
    ;;
  "colors")
    # Configuration file for color definitions (not a module, but needs special handling)
    module_path="${BASH__PATH}/lib/config/colors.inc"
    ;;
  *)
    # For modules that follow the standard pattern: lib/modules/module-name/module-name.mod.sh
    # Examples: file, http, math, date, etc.
    # Use the regular import function which has proper guard checking
    import "$module_name" "$extension"
    return $?
    ;;
  esac

  # Only proceed with direct sourcing if this is a force reload (not first-time import)
  if [[ "$already_loaded" == "true" ]]; then
    # Source the module directly using the hardcoded path
    if [[ -f "$module_path" ]]; then
      source "$module_path"

      # Check if module loaded successfully using multiple verification methods
      if [[ -n "${!check_var}" ]]; then
        # Import signal is set - module loaded successfully
        echo "Module: $module_name, Version: 1.0.0, Loaded from: $module_path"
        return 0
      elif command -v "${module_name}.help" >/dev/null 2>&1; then
        # Module has a help function - it's probably loaded
        echo "Module: $module_name, Version: 1.0.0, Loaded from: $module_path"
        return 0
      else
        # Module failed to load or signal properly
        echo -e "\e[31mError:\e[0m Module '$module_name' did not signal a successful load"
        return 2
      fi
    else
      # Module file not found at the expected path
      echo -e "\e[31mError: \e[0mCannot find \e[1m${module_name}\e[0m library at: $module_path"
      return 3
    fi
  else
    # For first-time imports, use the regular import function
    import "$module_name" "$extension"
    return $?
  fi
}

function import.meta.reload() {
  # Reload all loaded modules
  echo "Reloading all loaded modules..."

  declare -xp | grep '^declare \-x BASH_LIB_IMPORTED_' | while read -r line; do
    local var_name=$(echo "$line" | cut -d'=' -f1 | sed 's/declare -x //')
    local module_name=$(echo "$var_name" | sed 's/BASH_LIB_IMPORTED_//')
    echo "Reloading module: $module_name"
    import.force "$module_name"
  done

  echo "All modules reloaded"
}

##
## (Usage) import modulename if your adding and include item
##         you can use import config inc to mark its an inc extension
##
## Allows you include libraries
function import() {

  # Validate that a module name is provided
  if [[ -z "${1}" ]]; then
    echo -e "\e[31mError: \e[0mNo module name provided"
    echo -e "Usage: \e[1mimport <module_name> [extension]\e[0m"
    echo -e "Example: \e[1mimport console\e[0m or \e[1mimport colors inc\e[0m"
    return 1
  fi

  local src=${BASH__PATH:-"/opt/bash-lib"}
  local extension=$([[ -z ${2} ]] && echo "mod.sh" || echo "inc")

  if [[ ! -d ${src} ]]; then
    echo -e "\e[31mWarning: \e[0m Bash Path is not set or directory doesn't exist: \e[1m${src}\e[0m"
    echo -e "Set it with: \e[1mexport BASH__PATH=/opt/bash-lib\e[0m"
    return 1
  fi

  # Check if module is already loaded
  local check_var="BASH_LIB_IMPORTED_${1//\//_}"
  if [[ -n "${!check_var}" ]]; then
    # Module is already loaded, skip reloading
    return 0
  fi

  # Handle special cases for modules in subdirectories
  local module_path=""
  case "$1" in
  "console")
    # System-level console logging module
    module_path="${src}/lib/modules/system/console.mod.sh"
    ;;
  "trapper")
    # System-level signal handling and error trapping module
    module_path="${src}/lib/modules/system/trapper.mod.sh"
    ;;
  "service")
    # System-level service management module
    module_path="${src}/lib/modules/system/service.mod.sh"
    ;;
  "process")
    # System-level process management module
    module_path="${src}/lib/modules/system/process.mod.sh"
    ;;
  "engine")
    # Core engine functionality for module management
    module_path="${src}/lib/modules/core/engine.mod.sh"
    ;;
  "colors")
    # Configuration file for color definitions (not a module, but needs special handling)
    module_path="${src}/lib/config/colors.inc"
    ;;
  esac

  # If we have a special case path, use it
  if [[ -n "$module_path" ]]; then
    if [[ -f "$module_path" ]]; then
      echo "DEBUG: Sourcing special case module: $module_path"
      source "$module_path"

      # Check for module-specific import signal using new naming pattern
      if [[ -n "${!check_var}" ]]; then
        # Import signal is set - module loaded successfully
        echo "DEBUG: Module $1 loaded successfully (import signal set)"
        return 0
      elif command -v "${1}.help" >/dev/null 2>&1; then
        # Module has a help function - it's probably loaded
        echo "DEBUG: Module $1 loaded successfully (help function found)"
        echo -e "\e[33mWarning: \e[0mModule '$1' loaded but import signal not set. This may be due to environment restrictions."
        return 0
      elif [[ -n "$(declare -F | grep -E "^declare -f ${1}\.")" ]]; then
        # Module has functions defined - it's probably loaded
        echo "DEBUG: Module $1 loaded successfully (functions defined)"
        echo -e "\e[33mWarning: \e[0mModule '$1' loaded but import signal not set. This may be due to environment restrictions."
        return 0
      else
        echo "DEBUG: Module $1 failed to load (no verification method succeeded)"
        echo -e "\e[31mError:\e[0m Module '$1' did not signal a successful load"
        return 2
      fi
    else
      echo "DEBUG: Special case module not found: $module_path"
      echo -e "\e[31mError: \e[0mCannot find \e[1m${1}\e[0m library at: $module_path"
      return 3
    fi
  fi

  # Standard module discovery using find
  echo "DEBUG: Searching for standard module: ${1}.${extension}"
  local module=$(find ${src} -name "${1}.${extension}" 2>/dev/null)
  if [[ -f ${module} ]]; then
    echo "DEBUG: Found module at: $module"
    # Source the module
    source ${module}

    # Check for module-specific import signal using new naming pattern
    # More robust check - try multiple ways to verify the module loaded
    if [[ -n "${!check_var}" ]]; then
      # Import signal is set - module loaded successfully
      echo "DEBUG: Module $1 loaded successfully (import signal set)"
      return 0
    elif command -v "${1}.help" >/dev/null 2>&1; then
      # Module has a help function - it's probably loaded
      echo "DEBUG: Module $1 loaded successfully (help function found)"
      echo -e "\e[33mWarning: \e[0mModule '$1' loaded but import signal not set. This may be due to environment restrictions."
      return 0
    elif [[ -n "$(declare -F | grep -E "^declare -f ${1}\.")" ]]; then
      # Module has functions defined - it's probably loaded
      echo "DEBUG: Module $1 loaded successfully (functions defined)"
      echo -e "\e[33mWarning: \e[0mModule '$1' loaded but import signal not set. This may be due to environment restrictions."
      return 0
    else
      echo "DEBUG: Module $1 failed to load (no verification method succeeded)"
      echo -e "\e[31mError:\e[0m Module '$1' did not signal a successful load"
      return 2
    fi
  else
    echo "DEBUG: Standard module not found: ${1}.${extension}"
    echo -e "\e[31mError: \e[0mCannot find \e[1m${1}\e[0m library inside: ${src}"
    return 3
  fi
}

# Main initialization function with timeout protection
main_init() {
  echo "DEBUG: Starting main initialization..."

  # Step 1: Environment validation
  echo "DEBUG: Step 1 - Environment validation"
  if ! validate_environment; then
    echo "ERROR: Environment validation failed"
    return 1
  fi

  # Step 2: Auto-detect BASH__PATH if not set
  echo "DEBUG: Step 2 - BASH__PATH detection"
  if [[ -z "${BASH__PATH}" ]]; then
    # Get the directory where this script is located
    script_dir=""
    if [[ -n "${BASH_SOURCE[0]}" ]]; then
      # Use macOS-compatible way to get absolute path
      if command -v readlink >/dev/null 2>&1 && readlink -f "${BASH_SOURCE[0]}" >/dev/null 2>&1; then
        script_dir=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
      else
        # Fallback for macOS where readlink -f doesn't exist
        script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
      fi
    else
      script_dir=$(cd "$(dirname "$0")" && pwd)
    fi

    echo "DEBUG: Script directory: $script_dir"

    # Navigate up to find the bash-lib root (where lib/core/ and lib/modules/ directories exist)
    current_dir="$script_dir"
    bash_lib_root=""

    while [[ -n "$current_dir" ]] && [[ "$current_dir" != "/" ]]; do
      if [[ -d "$current_dir/lib/core" ]] && [[ -d "$current_dir/lib/modules" ]]; then
        bash_lib_root="$current_dir"
        break
      fi
      current_dir=$(dirname "$current_dir")
    done

    if [[ -n "$bash_lib_root" ]]; then
      export BASH__PATH="$bash_lib_root"
      echo "DEBUG: Auto-detected bash-lib at: ${BASH__PATH}"
      echo -e "\e[32mInfo: \e[0mAuto-detected bash-lib at: \e[1m${BASH__PATH}\e[0m"
    else
      # Fallback to default location
      export BASH__PATH="/opt/bash-lib"
      echo "DEBUG: Using default bash-lib path: ${BASH__PATH}"
      echo -e "\e[33mInfo: \e[0mCould not auto-detect bash-lib, using default: \e[1m${BASH__PATH}\e[0m"
    fi
  fi

  # Step 3: Validate BASH__PATH
  echo "DEBUG: Step 3 - BASH__PATH validation"
  if [[ -n "${BASH__PATH}" ]] && [[ -d "${BASH__PATH}" ]]; then
    echo "DEBUG: BASH__PATH is valid: ${BASH__PATH}"

    # Step 4: Source build configuration
    echo "DEBUG: Step 4 - Build configuration"
    if [[ -f "${BASH__PATH}/lib/config/build.inc" ]]; then
      echo "DEBUG: Sourcing build configuration"
      source "${BASH__PATH}/lib/config/build.inc" 2>/dev/null || echo "DEBUG: Build config sourcing failed (non-critical)"
    else
      echo "DEBUG: Build configuration not found"
    fi

    # Step 5: Import core modules with error suppression
    echo "DEBUG: Step 5 - Core module imports"

    # Import trapper module
    if [[ -f "${BASH__PATH}/lib/modules/system/trapper.mod.sh" ]]; then
      echo "DEBUG: Sourcing trapper module"
      source "${BASH__PATH}/lib/modules/system/trapper.mod.sh" 2>/dev/null || echo "DEBUG: Trapper module sourcing failed (non-critical)"
    else
      echo "DEBUG: Trapper module not found"
    fi

    # Import console module
    if [[ -f "${BASH__PATH}/lib/modules/system/console.mod.sh" ]]; then
      echo "DEBUG: Sourcing console module"
      source "${BASH__PATH}/lib/modules/system/console.mod.sh" 2>/dev/null || echo "DEBUG: Console module sourcing failed (non-critical)"
    else
      echo "DEBUG: Console module not found"
    fi

    # Step 6: Setup traps and verbosity
    echo "DEBUG: Step 6 - Setup traps and verbosity"

    # Only add trap if trapper was successfully imported
    if command -v trapper.addTrap >/dev/null 2>&1; then
      echo "DEBUG: Adding trapper trap"
      trapper.addTrap 'exit 1;' 10 2>/dev/null || echo "DEBUG: Trap setup failed (non-critical)"
    else
      echo "DEBUG: Trapper not available, skipping trap setup"
    fi

    [[ -z ${BASH__VERBOSE} ]] && export BASH__VERBOSE=info || export BASH__VERBOSE=${BASH__VERBOSE}

    # Only use console.debug if console module was successfully imported
    if command -v console.debug >/dev/null 2>&1; then
      echo "DEBUG: Using console.debug for verbosity info"
      console.debug "Verbosity:  ${BASH__VERBOSE} " 2>/dev/null || echo "DEBUG: Console debug failed (non-critical)"
      console.debug "Version : ${BASH__RELEASE} " 2>/dev/null || echo "DEBUG: Console debug failed (non-critical)"
      console.debug "BASH__PATH: ${BASH__PATH} " 2>/dev/null || echo "DEBUG: Console debug failed (non-critical)"
    else
      echo "DEBUG: Console not available, using echo for verbosity info"
      echo "INFO: Verbosity: ${BASH__VERBOSE}"
      echo "INFO: Version: ${BASH__RELEASE}"
      echo "INFO: BASH__PATH: ${BASH__PATH}"
    fi

    echo "DEBUG: Initialization completed successfully"
    return 0
  else
    echo "DEBUG: BASH__PATH is invalid or not set"
    echo -e "\e[33mInfo: \e[0mBash-lib not fully initialized. Set \e[1mBASH__PATH\e[0m to enable all features."
    return 1
  fi
}

# Execute main initialization with timeout protection
if [[ "${BASH_LIB_DOCKER}" == "true" ]]; then
  echo "DEBUG: Running initialization with timeout protection"
  # Use timeout if available, otherwise run normally
  if command -v timeout >/dev/null 2>&1; then
    timeout ${TIMEOUT_SECONDS}s main_init || {
      echo "ERROR: bash-lib initialization timed out after ${TIMEOUT_SECONDS} seconds"
      exit 1
    }
  else
    echo "DEBUG: Timeout command not available, running without timeout"
    main_init
  fi
else
  echo "DEBUG: Running initialization without timeout protection"
  main_init
fi

# Final status
if [[ $? -eq 0 ]]; then
  echo "DEBUG: bash-lib initialization completed successfully"
else
  echo "DEBUG: bash-lib initialization completed with errors"
fi
