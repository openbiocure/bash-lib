#!/bin/bash

# bash-lib Core Initialization Script
# Refactored for clean debug gating, Docker safety, and full environment setup

#---------------------------------------
# DEBUG WRAPPER
#---------------------------------------
__debug() {
  [[ "${BASH__VERBOSE:-}" == "debug" ]] && printf "DEBUG: %s\n" "$*" >&2
}

#---------------------------------------
# Docker Detection
#---------------------------------------
if [[ -f /.dockerenv ]] || grep -q docker /proc/1/cgroup 2>/dev/null; then
  export BASH_LIB_DEBUG=true
  export BASH_LIB_DOCKER=true
fi

#---------------------------------------
# Docker Timeout Setup
#---------------------------------------
if [[ "${BASH_LIB_DOCKER:-}" == "true" ]]; then
  TIMEOUT_SECONDS=30
  __debug "Docker detected. Timeout set to ${TIMEOUT_SECONDS}s"
fi

#---------------------------------------
# Environment Validation
#---------------------------------------
validate_environment() {
  __debug "Validating environment..."

  for var in PATH; do
    [[ -z "${!var}" ]] && {
      printf "ERROR: Required environment variable %s is not set\n" "$var" >&2
      return 1
    }
  done

  __debug "Environment validation passed"
  return 0
}

#---------------------------------------
# import.meta.* utilities
#---------------------------------------
import.meta.loaded() {
  local name="$1" path="$2" version="${3:-unknown}"
  local signal="BASH_LIB_IMPORTED_${name//\//_}"

  [[ -z "${!signal:-}" ]] && __debug "Loaded module: $name [$version] from $path"
}

import.meta.all() {
  printf "Loaded bash-lib modules:\n"
  declare -xp | grep '^declare \-x BASH_LIB_IMPORTED_' | while read -r line; do
    local var=$(cut -d= -f1 <<<"$line" | sed 's/declare -x //')
    printf "  ✓ %s\n" "${var#BASH_LIB_IMPORTED_}"
  done
}

import.meta.info() {
  local name="$1"
  [[ -z "$name" ]] && {
    printf "Usage: import.meta.info <module_name>\n" >&2
    return 1
  }

  local signal="BASH_LIB_IMPORTED_${name//\//_}"
  [[ -n "${!signal:-}" ]] && printf "Module '%s' is loaded\n" "$name" || printf "Module '%s' is not loaded\n" "$name"
}

#---------------------------------------
# Module Import: Standard + Force
#---------------------------------------
import() {
  local name="$1" ext="${2:-mod.sh}"
  [[ -z "$name" ]] && {
    printf "\e[31mError:\e[0m import requires a module name\n" >&2
    return 1
  }

  local src="${BASH__PATH:-/opt/bash-lib}"
  local signal="BASH_LIB_IMPORTED_${name//\//_}"
  [[ -n "${!signal:-}" ]] && return 0

  local mod_path=""
  case "$name" in
  console | service | process)
    mod_path="${src}/lib/modules/system/${name}.mod.sh"
    ;;
  engine)
    mod_path="${src}/lib/modules/core/engine.mod.sh"
    ;;
  colors)
    mod_path="${src}/lib/config/colors.inc"
    ext="inc"
    ;;
  *)
    mod_path="$(find "${src}" -name "${name}.${ext}" 2>/dev/null | head -n1)"
    ;;
  esac

  if [[ -f "$mod_path" ]]; then
    __debug "Importing $name from $mod_path"
    source "$mod_path"
    [[ -n "${!signal:-}" || "$(type -t "${name}.help")" == "function" ]] && return 0
    printf "\e[33mWarning:\e[0m '%s' loaded but import signal not set\n" "$name" >&2
    return 0
  else
    printf "\e[31mError:\e[0m Could not find module: %s [%s]\n" "$name" "$mod_path" >&2
    return 2
  fi
}

import.force() {
  local name="$1" ext="${2:-mod.sh}"
  [[ -z "$name" ]] && {
    printf "\e[31mError:\e[0m Missing module name for import.force\n" >&2
    return 1
  }

  local signal="BASH_LIB_IMPORTED_${name//\//_}"
  unset "$signal" 2>/dev/null || true
  import "$name" "$ext"
}

import.meta.reload() {
  declare -xp | grep '^declare \-x BASH_LIB_IMPORTED_' | while read -r line; do
    local var=$(cut -d= -f1 <<<"$line" | sed 's/declare -x //')
    local name="${var#BASH_LIB_IMPORTED_}"
    printf "Reloading: %s\n" "$name"
    import.force "$name"
  done
}

#---------------------------------------
# Main Initialization Logic
#---------------------------------------
main_init() {
  __debug "Beginning initialization process..."

  # Step 1: Validate environment
  if ! validate_environment; then
    printf "ERROR: Environment validation failed\n" >&2
    return 1
  fi

  # Step 2: Auto-detect BASH__PATH
  if [[ -z "${BASH__PATH}" ]]; then
    local here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
    local walk="$here"
    while [[ "$walk" != "/" ]]; do
      [[ -f "$walk/lib/init.sh" && -d "$walk/lib/modules" ]] && {
        BASH__PATH="$walk"
        break
      }
      walk=$(dirname "$walk")
    done
    [[ -z "$BASH__PATH" ]] && BASH__PATH="/opt/bash-lib"
    export BASH__PATH
    __debug "Set BASH__PATH to $BASH__PATH"
  fi

  # Step 3: Load build config
  [[ -f "$BASH__PATH/lib/config/build.inc" ]] && source "$BASH__PATH/lib/config/build.inc" 2>/dev/null

  # Step 4: Core imports
  import console

  # Step 5: Setup verbosity
  export BASH__VERBOSE="${BASH__VERBOSE:-info}"

  if command -v console.debug >/dev/null; then
    if [[ "$(console.get_verbosity)" == "debug" || "$(console.get_verbosity)" == "trace" ]]; then
      console.debug "Verbosity: $(console.get_verbosity)"
      console.debug "BASH__PATH: $BASH__PATH"
    fi
  else
    if [[ "$BASH__VERBOSE" == "debug" || "$BASH__VERBOSE" == "trace" ]]; then
      printf "DEBUG: Verbosity: %s\n" "$BASH__VERBOSE"
      printf "DEBUG: BASH__PATH: %s\n" "$BASH__PATH"
    fi
  fi

  __debug "Initialization complete."
    return 0
}

#---------------------------------------
# Execute Initialization
#---------------------------------------
# Initialize the result variable
init_result=0

if [[ "${BASH_LIB_DOCKER:-}" == "true" ]]; then
    # Simplified Docker initialization without timeout
    main_init
    init_result=$?

    if [[ $init_result -ne 0 ]]; then
        printf "ERROR: Initialization failed with exit code %d\n" "$init_result" >&2
        return $init_result
    fi
else
    main_init
    init_result=$?
fi

#---------------------------------------
# Final Status
#---------------------------------------
if [[ $init_result -eq 0 ]]; then
  __debug "bash-lib initialized successfully"
  # Always return 0 for successful initialization when sourced
  return 0
else
  __debug "bash-lib initialization failed"
  return $init_result
fi
