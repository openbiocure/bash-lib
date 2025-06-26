#!/bin/bash

# Import metadata functions - define these first so modules can use them
function import.meta.loaded() {
  local module_name="$1"
  local module_path="$2"
  local version="${3:-unknown}"
  
  if [[ -n "$module_name" && -n "$module_path" ]]; then
    echo "Module: $module_name, Version: $version, Loaded from: $module_path"
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
  
  # Clear the import signal to force reload
  local check_var="BASH_LIB_IMPORTED_${module_name//\//_}"
  unset "$check_var" 2>/dev/null || true
  
  # Handle special cases for modules in subdirectories
  # 
  # DECISION: We use hardcoded paths for certain modules because:
  # 1. The standard import function uses 'find' to locate files with pattern: ${module_name}.${extension}
  # 2. Some modules are organized in subdirectories (e.g., modules/system/console.mod.sh)
  # 3. The find command searches recursively, but the import function expects exact module names
  # 4. This creates a mismatch between module organization and import discovery
  #
  # ALTERNATIVES CONSIDERED:
  # - Modify import function to handle subdirectories better (complex, breaks existing logic)
  # - Use symlinks (maintenance overhead, potential confusion)
  # - Require full paths in imports (user-unfriendly)
  #
  # CURRENT SOLUTION:
  # - Keep the standard import function simple and predictable
  # - Add special cases here for modules that don't follow the flat structure
  # - This maintains backward compatibility while supporting organized module structure
  #
  local module_path=""
  case "$module_name" in
    "console")
      # System-level console logging module
      module_path="${BASH__PATH}/modules/system/console.mod.sh"
      ;;
    "trapper")
      # System-level signal handling and error trapping module
      module_path="${BASH__PATH}/modules/system/trapper.mod.sh"
      ;;
    "engine")
      # Core engine functionality for module management
      module_path="${BASH__PATH}/modules/core/engine.mod.sh"
      ;;
    "colors")
      # Configuration file for color definitions (not a module, but needs special handling)
      module_path="${BASH__PATH}/config/colors.inc"
      ;;
    *)
      # For modules that follow the standard pattern: modules/module-name/module-name.mod.sh
      # Examples: file, http, math, date, etc.
      import "$module_name" "$extension"
      return $?
      ;;
  esac
  
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
function import () {

  # Validate that a module name is provided
  if [[ -z "${1}" ]]; then
      echo -e "\e[31mError: \e[0mNo module name provided"
      echo -e "Usage: \e[1mimport <module_name> [extension]\e[0m"
      echo -e "Example: \e[1mimport console\e[0m or \e[1mimport colors inc\e[0m"
      return 1
  fi

  local src=${BASH__PATH:-"/opt/bash-lib"};
  local extension=$([[ -z ${2} ]]  && echo "mod.sh" || echo "inc");

  if [[ ! -d ${src} ]]; then
      echo -e "\e[31mWarning: \e[0m Bash Path is not set or directory doesn't exist: \e[1m${src}\e[0m"
      echo -e "Set it with: \e[1mexport BASH__PATH=/opt/bash-lib\e[0m"
      return 1;
  fi

  # Check if module is already loaded
  local check_var="BASH_LIB_IMPORTED_${1//\//_}"
  if [[ -n "${!check_var}" ]]; then
    # Module is already loaded, skip reloading
    return 0
  fi

  local module=$(find ${src} -name "${1}.${extension}" 2>/dev/null)
  if [[  -f ${module} ]]; then
    # Source the module
    source ${module}
    
    # Check for module-specific import signal using new naming pattern
    
    # More robust check - try multiple ways to verify the module loaded
    if [[ -n "${!check_var}" ]]; then
      # Import signal is set - module loaded successfully
      return 0
    elif command -v "${1}.help" >/dev/null 2>&1; then
      # Module has a help function - it's probably loaded
      echo -e "\e[33mWarning: \e[0mModule '$1' loaded but import signal not set. This may be due to environment restrictions."
      return 0
    elif [[ -n "$(declare -F | grep -E "^declare -f ${1}\.")" ]]; then
      # Module has functions defined - it's probably loaded
      echo -e "\e[33mWarning: \e[0mModule '$1' loaded but import signal not set. This may be due to environment restrictions."
      return 0
    else
      echo -e "\e[31mError:\e[0m Module '$1' did not signal a successful load"
      return 2;
    fi
  else
    echo -e "\e[31mError: \e[0mCannot find \e[1m${1}\e[0m library inside: ${src}";
    return 3;
  fi
}

# Auto-detect BASH__PATH if not set
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
    
    # Navigate up to find the bash-lib root (where core/ and modules/ directories exist)
    current_dir="$script_dir"
    bash_lib_root=""
    
    while [[ -n "$current_dir" ]] && [[ "$current_dir" != "/" ]]; do
        if [[ -d "$current_dir/core" ]] && [[ -d "$current_dir/modules" ]]; then
            bash_lib_root="$current_dir"
            break
        fi
        current_dir=$(dirname "$current_dir")
    done
    
    if [[ -n "$bash_lib_root" ]]; then
        export BASH__PATH="$bash_lib_root"
        echo -e "\e[32mInfo: \e[0mAuto-detected bash-lib at: \e[1m${BASH__PATH}\e[0m"
    else
        # Fallback to default location
        export BASH__PATH="/opt/bash-lib"
        echo -e "\e[33mInfo: \e[0mCould not auto-detect bash-lib, using default: \e[1m${BASH__PATH}\e[0m"
    fi
fi

# Import required modules for initialization (only if BASH__PATH is set and valid)
if [[ -n "${BASH__PATH}" ]] && [[ -d "${BASH__PATH}" ]]; then
    # Source build configuration for version info
    if [[ -f "${BASH__PATH}/config/build.inc" ]]; then
        source "${BASH__PATH}/config/build.inc"
    fi
    
    # Import core modules with error suppression during initialization
    # Use a more robust approach that doesn't rely on import signals during init
    if [[ -f "${BASH__PATH}/modules/system/trapper.mod.sh" ]]; then
        source "${BASH__PATH}/modules/system/trapper.mod.sh" 2>/dev/null || true
    fi
    
    if [[ -f "${BASH__PATH}/modules/system/console.mod.sh" ]]; then
        source "${BASH__PATH}/modules/system/console.mod.sh" 2>/dev/null || true
    fi
    
    # Only add trap if trapper was successfully imported
    if command -v trapper.addTrap >/dev/null 2>&1; then
        trapper.addTrap 'exit 1;' 10 
    fi
    
    [[ -z ${BASH__VERBOSE} ]] &&  export BASH__VERBOSE=info || export BASH__VERBOSE=${BASH__VERBOSE};
    
    # Only use console.debug if console module was successfully imported
    if command -v console.debug >/dev/null 2>&1; then
        console.debug "Verbosity:  ${BASH__VERBOSE} ";
        console.debug "Version : ${BASH__RELEASE} ";
        console.debug "BASH__PATH: ${BASH__PATH} ";
    fi
else
    echo -e "\e[33mInfo: \e[0mBash-lib not fully initialized. Set \e[1mBASH__PATH\e[0m to enable all features."
fi


