#!/bin/bash

# forEach Module for bash-lib
# Provides iteration utilities for arrays, files, and collections

# Module import signal using scoped naming
export BASH_LIB_IMPORTED_forEach="1"

# Call import.meta.loaded if the function exists
if command -v import.meta.loaded >/dev/null 2>&1; then
    import.meta.loaded "forEach" "${BASH__PATH:-/opt/bash-lib}/modules/utils/forEach.mod.sh" "1.0.0" 2>/dev/null || true
fi

import console

##
## (Usage) Iterate over an array with a callback function
##
## Options:
##   --parallel=<number>     - Run iterations in parallel (default: 1)
##   --break-on-error        - Stop iteration on first error
##   --continue-on-error     - Continue iteration even if errors occur
##   --silent                - Suppress output from callback function
##   --verbose               - Show detailed execution information
##   --dry-run               - Show what would be executed without running
##
## Examples:
##   forEach.array "item" "echo \$item" "apple" "banana" "cherry"
##   forEach.array "file" "ls -la \$file" --parallel=3 *.txt
##   forEach.array "pid" "process.stop \$pid" --break-on-error 1234 5678 9012
##
function forEach.array() {
    local var_name=""
    local callback=""
    local parallel=1
    local break_on_error=false
    local continue_on_error=false
    local silent=false
    local verbose=false
    local dry_run=false
    local items=()

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
        --parallel=*)
            parallel="${1#*=}"
            shift
            ;;
        --break-on-error)
            break_on_error=true
            shift
            ;;
        --continue-on-error)
            continue_on_error=true
            shift
            ;;
        --silent)
            silent=true
            shift
            ;;
        --verbose)
            verbose=true
            shift
            ;;
        --dry-run)
            dry_run=true
            shift
            ;;
        -*)
            console.error "Unknown option: $1"
            return 1
            ;;
        *)
            if [[ -z "$var_name" ]]; then
                var_name="$1"
            elif [[ -z "$callback" ]]; then
                callback="$1"
            else
                items+=("$1")
            fi
            shift
            ;;
        esac
    done

    # Validate required parameters
    if [[ -z "$var_name" ]]; then
        console.error "Variable name is required"
        return 1
    fi

    if [[ -z "$callback" ]]; then
        console.error "Callback function is required"
        return 1
    fi

    if [[ ${#items[@]} -eq 0 ]]; then
        console.error "No items to iterate over"
        return 1
    fi

    # Validate parallel count
    if ! [[ "$parallel" =~ ^[0-9]+$ ]] || [[ "$parallel" -lt 1 ]]; then
        console.error "Parallel count must be a positive integer"
        return 1
    fi

    if [[ "$dry_run" == "true" ]]; then
        console.info "DRY RUN: Would iterate over ${#items[@]} items"
        console.info "DRY RUN: Variable name: $var_name"
        console.info "DRY RUN: Callback: $callback"
        if [[ "$parallel" -gt 1 ]]; then
            console.info "DRY RUN: Parallel execution: $parallel"
        fi
        if [[ "$break_on_error" == "true" ]]; then
            console.info "DRY RUN: Would break on first error"
        fi
        if [[ "$continue_on_error" == "true" ]]; then
            console.info "DRY RUN: Would continue on errors"
        fi
        return 0
    fi

    if [[ "$verbose" == "true" ]]; then
        console.debug "Starting forEach.array with ${#items[@]} items"
        console.debug "Variable: $var_name, Callback: $callback"
        if [[ "$parallel" -gt 1 ]]; then
            console.debug "Parallel execution: $parallel"
        fi
    fi

    local exit_code=0
    local processed=0
    local errors=0

    # Function to process a single item
    process_item() {
        local item="$1"
        local index="$2"

        if [[ "$verbose" == "true" ]]; then
            console.debug "Processing item $((index + 1)): $item"
        fi

        # Execute callback with proper variable expansion
        if [[ "$silent" == "true" ]]; then
            # Use eval to properly expand variables in the callback
            eval "$var_name=\"$item\"; eval \"$callback\"" >/dev/null 2>&1
        else
            # Use eval to properly expand variables in the callback
            eval "$var_name=\"$item\"; eval \"$callback\""
        fi

        local item_exit_code=$?

        if [[ $item_exit_code -ne 0 ]]; then
            ((errors++))
            if [[ "$verbose" == "true" ]]; then
                console.error "Callback failed for item: $item (exit code: $item_exit_code)"
            fi

            if [[ "$break_on_error" == "true" ]]; then
                exit_code=$item_exit_code
                return 1
            fi
        fi

        ((processed++))
        return 0
    }

    # Sequential execution
    if [[ "$parallel" -eq 1 ]]; then
        for i in "${!items[@]}"; do
            if ! process_item "${items[$i]}" "$i"; then
                break
            fi
        done
    else
        # Parallel execution
        local pids=()
        local max_jobs=$parallel
        local current_jobs=0

        for i in "${!items[@]}"; do
            # Wait if we've reached the maximum number of parallel jobs
            while [[ $current_jobs -ge $max_jobs ]]; do
                for j in "${!pids[@]}"; do
                    if ! kill -0 "${pids[$j]}" 2>/dev/null; then
                        wait "${pids[$j]}"
                        unset "pids[$j]"
                        ((current_jobs--))
                    fi
                done
                sleep 0.1
            done

            # Start new job
            process_item "${items[$i]}" "$i" &
            pids+=($!)
            ((current_jobs++))
        done

        # Wait for all remaining jobs
        for pid in "${pids[@]}"; do
            wait "$pid"
        done
    fi

    if [[ "$verbose" == "true" ]]; then
        console.debug "Completed: $processed items processed, $errors errors"
    fi

    return $exit_code
}

##
## (Usage) Iterate over lines in a file with a callback function
##
## Options:
##   --parallel=<number>     - Run iterations in parallel (default: 1)
##   --break-on-error        - Stop iteration on first error
##   --continue-on-error     - Continue iteration even if errors occur
##   --silent                - Suppress output from callback function
##   --verbose               - Show detailed execution information
##   --dry-run               - Show what would be executed without running
##   --skip-empty            - Skip empty lines
##   --skip-comments         - Skip lines starting with #
##
## Examples:
##   forEach.file "line" "echo \$line" input.txt
##   forEach.file "line" "process.run \$line" commands.txt --parallel=5
##   forEach.file "line" "echo \$line" config.txt --skip-comments --skip-empty
##
function forEach.file() {
    local var_name=""
    local callback=""
    local file_path=""
    local parallel=1
    local break_on_error=false
    local continue_on_error=false
    local silent=false
    local verbose=false
    local dry_run=false
    local skip_empty=false
    local skip_comments=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
        --parallel=*)
            parallel="${1#*=}"
            shift
            ;;
        --break-on-error)
            break_on_error=true
            shift
            ;;
        --continue-on-error)
            continue_on_error=true
            shift
            ;;
        --silent)
            silent=true
            shift
            ;;
        --verbose)
            verbose=true
            shift
            ;;
        --dry-run)
            dry_run=true
            shift
            ;;
        --skip-empty)
            skip_empty=true
            shift
            ;;
        --skip-comments)
            skip_comments=true
            shift
            ;;
        -*)
            console.error "Unknown option: $1"
            return 1
            ;;
        *)
            if [[ -z "$var_name" ]]; then
                var_name="$1"
            elif [[ -z "$callback" ]]; then
                callback="$1"
            elif [[ -z "$file_path" ]]; then
                file_path="$1"
            else
                console.error "Too many arguments"
                return 1
            fi
            shift
            ;;
        esac
    done

    # Validate required parameters
    if [[ -z "$var_name" ]]; then
        console.error "Variable name is required"
        return 1
    fi

    if [[ -z "$callback" ]]; then
        console.error "Callback function is required"
        return 1
    fi

    if [[ -z "$file_path" ]]; then
        console.error "File path is required"
        return 1
    fi

    # Check if file exists
    if [[ ! -f "$file_path" ]]; then
        console.error "File does not exist: $file_path"
        return 1
    fi

    # Validate parallel count
    if ! [[ "$parallel" =~ ^[0-9]+$ ]] || [[ "$parallel" -lt 1 ]]; then
        console.error "Parallel count must be a positive integer"
        return 1
    fi

    if [[ "$dry_run" == "true" ]]; then
        console.info "DRY RUN: Would iterate over file: $file_path"
        console.info "DRY RUN: Variable name: $var_name"
        console.info "DRY RUN: Callback: $callback"
        if [[ "$parallel" -gt 1 ]]; then
            console.info "DRY RUN: Parallel execution: $parallel"
        fi
        if [[ "$skip_empty" == "true" ]]; then
            console.info "DRY RUN: Would skip empty lines"
        fi
        if [[ "$skip_comments" == "true" ]]; then
            console.info "DRY RUN: Would skip comment lines"
        fi
        return 0
    fi

    if [[ "$verbose" == "true" ]]; then
        console.debug "Starting forEach.file: $file_path"
        console.debug "Variable: $var_name, Callback: $callback"
        if [[ "$parallel" -gt 1 ]]; then
            console.debug "Parallel execution: $parallel"
        fi
    fi

    # Read file into array
    local lines=()
    local line_number=0

    while IFS= read -r line; do
        ((line_number++))

        # Skip empty lines if requested
        if [[ "$skip_empty" == "true" ]] && [[ -z "$line" ]]; then
            continue
        fi

        # Skip comment lines if requested
        if [[ "$skip_comments" == "true" ]] && [[ "$line" =~ ^[[:space:]]*# ]]; then
            continue
        fi

        lines+=("$line")
    done <"$file_path"

    if [[ ${#lines[@]} -eq 0 ]]; then
        if [[ "$verbose" == "true" ]]; then
            console.warn "No lines to process in file: $file_path"
        fi
        return 0
    fi

    # Use forEach.array to process the lines
    forEach.array "$var_name" "$callback" "${lines[@]}" \
        --parallel="$parallel" \
        ${break_on_error:+--break-on-error} \
        ${continue_on_error:+--continue-on-error} \
        ${silent:+--silent} \
        ${verbose:+--verbose}
}

##
## (Usage) Iterate over command output with a callback function
##
## Options:
##   --parallel=<number>     - Run iterations in parallel (default: 1)
##   --break-on-error        - Stop iteration on first error
##   --continue-on-error     - Continue iteration even if errors occur
##   --silent                - Suppress output from callback function
##   --verbose               - Show detailed execution information
##   --dry-run               - Show what would be executed without running
##   --skip-empty            - Skip empty lines
##
## Examples:
##   forEach.command "line" "echo \$line" "ls -1"
##   forEach.command "pid" "process.stop \$pid" "ps aux | grep nginx | awk '{print \$2}'"
##   forEach.command "file" "ls -la \$file" "find . -name '*.txt'" --parallel=3
##
function forEach.command() {
    local var_name=""
    local callback=""
    local command=""
    local parallel=1
    local break_on_error=false
    local continue_on_error=false
    local silent=false
    local verbose=false
    local dry_run=false
    local skip_empty=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
        --parallel=*)
            parallel="${1#*=}"
            shift
            ;;
        --break-on-error)
            break_on_error=true
            shift
            ;;
        --continue-on-error)
            continue_on_error=true
            shift
            ;;
        --silent)
            silent=true
            shift
            ;;
        --verbose)
            verbose=true
            shift
            ;;
        --dry-run)
            dry_run=true
            shift
            ;;
        --skip-empty)
            skip_empty=true
            shift
            ;;
        -*)
            console.error "Unknown option: $1"
            return 1
            ;;
        *)
            if [[ -z "$var_name" ]]; then
                var_name="$1"
            elif [[ -z "$callback" ]]; then
                callback="$1"
            elif [[ -z "$command" ]]; then
                command="$1"
            else
                command="$command $1"
            fi
            shift
            ;;
        esac
    done

    # Validate required parameters
    if [[ -z "$var_name" ]]; then
        console.error "Variable name is required"
        return 1
    fi

    if [[ -z "$callback" ]]; then
        console.error "Callback function is required"
        return 1
    fi

    if [[ -z "$command" ]]; then
        console.error "Command is required"
        return 1
    fi

    # Validate parallel count
    if ! [[ "$parallel" =~ ^[0-9]+$ ]] || [[ "$parallel" -lt 1 ]]; then
        console.error "Parallel count must be a positive integer"
        return 1
    fi

    if [[ "$dry_run" == "true" ]]; then
        console.info "DRY RUN: Would execute command: $command"
        console.info "DRY RUN: Variable name: $var_name"
        console.info "DRY RUN: Callback: $callback"
        if [[ "$parallel" -gt 1 ]]; then
            console.info "DRY RUN: Parallel execution: $parallel"
        fi
        return 0
    fi

    if [[ "$verbose" == "true" ]]; then
        console.debug "Starting forEach.command: $command"
        console.debug "Variable: $var_name, Callback: $callback"
        if [[ "$parallel" -gt 1 ]]; then
            console.debug "Parallel execution: $parallel"
        fi
    fi

    # Execute command and capture output
    local output
    output=$(eval "$command" 2>/dev/null)
    local command_exit_code=$?

    if [[ $command_exit_code -ne 0 ]]; then
        console.error "Command failed: $command (exit code: $command_exit_code)"
        return $command_exit_code
    fi

    # Convert output to array
    local lines=()
    while IFS= read -r line; do
        # Skip empty lines if requested
        if [[ "$skip_empty" == "true" ]] && [[ -z "$line" ]]; then
            continue
        fi
        lines+=("$line")
    done <<<"$output"

    if [[ ${#lines[@]} -eq 0 ]]; then
        if [[ "$verbose" == "true" ]]; then
            console.warn "No output to process from command: $command"
        fi
        return 0
    fi

    # Use forEach.array to process the lines
    forEach.array "$var_name" "$callback" "${lines[@]}" \
        --parallel="$parallel" \
        ${break_on_error:+--break-on-error} \
        ${continue_on_error:+--continue-on-error} \
        ${silent:+--silent} \
        ${verbose:+--verbose}
}

##
## (Usage) Show forEach module help
##
function forEach.help() {
    cat <<EOF
forEach Module - Iteration utilities for arrays, files, and collections

Available Functions:
  forEach.array <var> <callback> [items...] [options]  - Iterate over array items
  forEach.file <var> <callback> <file> [options]       - Iterate over file lines
  forEach.command <var> <callback> <command> [options] - Iterate over command output
  forEach.help                                          - Show this help

Common Options:
  --parallel=<number>     - Run iterations in parallel (default: 1)
  --break-on-error        - Stop iteration on first error
  --continue-on-error     - Continue iteration even if errors occur
  --silent                - Suppress output from callback function
  --verbose               - Show detailed execution information
  --dry-run               - Show what would be executed without running

File-specific Options:
  --skip-empty            - Skip empty lines
  --skip-comments         - Skip lines starting with #

Examples:
  # Array iteration
  forEach.array "item" "echo \$item" "apple" "banana" "cherry"
  forEach.array "file" "ls -la \$file" --parallel=3 *.txt
  forEach.array "pid" "process.stop \$pid" --break-on-error 1234 5678 9012

  # File iteration
  forEach.file "line" "echo \$line" input.txt
  forEach.file "line" "process.run \$line" commands.txt --parallel=5
  forEach.file "line" "echo \$line" config.txt --skip-comments --skip-empty

  # Command output iteration
  forEach.command "line" "echo \$line" "ls -1"
  forEach.command "pid" "process.stop \$pid" "ps aux | grep nginx | awk '{print \$2}'"
  forEach.command "file" "ls -la \$file" "find . -name '*.txt'" --parallel=3

  # Advanced examples
  forEach.command "pid" "process.stop \$pid --verbose" "pgrep sleep" --parallel=5
  forEach.file "line" "echo 'Processing: \$line'" urls.txt --dry-run
  forEach.array "num" "echo \$((num * 2))" {1..10} --silent
EOF
}
