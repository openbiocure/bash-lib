#!/bin/bash

# File Module for bash-lib
# Provides comprehensive file management and manipulation utilities

# Module import signal using scoped naming
export BASH_LIB_IMPORTED_files="1"

# Call import.meta.loaded if the function exists (with error suppression)
if command -v import.meta.loaded >/dev/null 2>&1; then
    import.meta.loaded "file" "${BASH__PATH:-/opt/bash-lib}/modules/file/file.mod.sh" "1.0.0" 2>/dev/null || true
fi

import console
import string
import directory

##
## (Usage) Create a new file with optional content
## Examples:
##   file.create "newfile.txt"
##   file.create "config.json" --content='{"key":"value"}'
##   file.create "script.sh" --content='#!/bin/bash' --executable
##
function file.create() {
    local filepath="$1"
    shift

    if [[ -z "$filepath" ]]; then
        console.error "File path is required"
        return 1
    fi

    local content=""
    local executable=false
    local overwrite=false

    # Parse options
    for arg in "$@"; do
        case $arg in
        --content=*) content="${arg#*=}" ;;
        --executable | -x) executable=true ;;
        --overwrite | -f) overwrite=true ;;
        *) ;;
        esac
    done

    # Check if file exists
    if [[ -f "$filepath" && "$overwrite" == "false" ]]; then
        console.error "File already exists: $filepath (use --overwrite to force)"
        return 1
    fi

    # Create directory if needed
    local dir=$(dirname "$filepath")
    if [[ ! -d "$dir" ]]; then
        directory.create "$dir" --parents || {
            console.error "Failed to create directory: $dir"
            return 1
        }
    fi

    # Create the file
    if [[ -n "$content" ]]; then
        echo -e "$content" >"$filepath" || {
            console.error "Failed to create file: $filepath"
            return 1
        }
    else
        touch "$filepath" || {
            console.error "Failed to create file: $filepath"
            return 1
        }
    fi

    # Make executable if requested
    if [[ "$executable" == "true" ]]; then
        chmod +x "$filepath"
    fi

    console.success "Created file: $filepath"
}

##
## (Usage) Read file content with various options
## Examples:
##   file.read "config.txt"
##   file.read "log.txt" --lines=10
##   file.read "data.json" --tail=5
##   file.read "script.sh" --grep="function"
##
function file.read() {
    local filepath="$1"
    shift

    if [[ -z "$filepath" ]]; then
        console.error "File path is required"
        return 1
    fi

    if [[ ! -f "$filepath" ]]; then
        console.error "File does not exist: $filepath"
        return 1
    fi

    local lines=""
    local tail=""
    local grep_pattern=""
    local show_line_numbers=false

    # Parse options
    for arg in "$@"; do
        case $arg in
        --lines=*) lines="${arg#*=}" ;;
        --tail=*) tail="${arg#*=}" ;;
        --grep=*) grep_pattern="${arg#*=}" ;;
        --line-numbers | -n) show_line_numbers=true ;;
        *) ;;
        esac
    done

    local cmd="cat"

    # Apply filters
    if [[ -n "$grep_pattern" ]]; then
        cmd="$cmd | grep '$grep_pattern'"
    fi

    if [[ -n "$lines" ]]; then
        cmd="$cmd | head -n $lines"
    elif [[ -n "$tail" ]]; then
        cmd="$cmd | tail -n $tail"
    fi

    if [[ "$show_line_numbers" == "true" ]]; then
        cmd="$cmd | nl"
    fi

    # Execute the command
    eval "$cmd '$filepath'"
}

##
## (Usage) Write content to files
## Examples:
##   file.write "log.txt" "New log entry"
##   file.write "config.txt" "setting=value" --append
##   file.write "data.txt" "$content" --overwrite
##
function file.write() {
    local filepath="$1"
    local content="$2"
    shift 2

    if [[ -z "$filepath" ]]; then
        console.error "File path is required"
        return 1
    fi

    local append=false
    local overwrite=false

    # Parse options
    for arg in "$@"; do
        case $arg in
        --append | -a) append=true ;;
        --overwrite | -f) overwrite=true ;;
        *) ;;
        esac
    done

    # Create directory if needed
    local dir=$(dirname "$filepath")
    if [[ ! -d "$dir" ]]; then
        directory.create "$dir" --parents || {
            console.error "Failed to create directory: $dir"
            return 1
        }
    fi

    # Write content
    if [[ "$append" == "true" ]]; then
        echo -e "$content" >>"$filepath"
        console.success "Appended to file: $filepath"
    else
        echo -e "$content" >"$filepath"
        console.success "Written to file: $filepath"
    fi
}

##
## (Usage) List files with various filters and options
## Examples:
##   file.list "/tmp"
##   file.list "/home" --pattern="*.txt"
##   file.list "/var/log" --size=+1M
##   file.list "/etc" --modified=+7d
##
function file.list() {
    local path="${1:-.}"
    shift

    if [[ ! -d "$path" ]]; then
        console.error "Directory does not exist: $path"
        return 1
    fi

    local pattern=""
    local size_filter=""
    local modified_filter=""
    local max_results=50
    local sort_by="name"
    local reverse=false
    local show_details=false

    # Parse options
    for arg in "$@"; do
        case $arg in
        --pattern=*) pattern="${arg#*=}" ;;
        --size=*) size_filter="${arg#*=}" ;;
        --modified=*) modified_filter="${arg#*=}" ;;
        --max=*) max_results="${arg#*=}" ;;
        --sort=*) sort_by="${arg#*=}" ;;
        --reverse | -r) reverse=true ;;
        --details | -l) show_details=true ;;
        *) ;;
        esac
    done

    local find_cmd="find '$path' -type f"

    # Apply filters
    if [[ -n "$pattern" ]]; then
        find_cmd="$find_cmd -name '$pattern'"
    fi

    if [[ -n "$size_filter" ]]; then
        find_cmd="$find_cmd -size $size_filter"
    fi

    if [[ -n "$modified_filter" ]]; then
        find_cmd="$find_cmd -mtime $modified_filter"
    fi

    # Apply sorting
    case $sort_by in
    name) find_cmd="$find_cmd | sort" ;;
    size) find_cmd="$find_cmd -exec ls -la {} + | sort -k5 -n" ;;
    date) find_cmd="$find_cmd -exec ls -la {} + | sort -k6,7" ;;
    *) find_cmd="$find_cmd | sort" ;;
    esac

    if [[ "$reverse" == "true" ]]; then
        find_cmd="$find_cmd | tac"
    fi

    # Limit results
    find_cmd="$find_cmd | head -n $max_results"

    # Execute and display
    local results=()
    while IFS= read -r line; do
        results+=("$line")
    done < <(eval "$find_cmd" 2>/dev/null)

    if [[ ${#results[@]} -eq 0 ]]; then
        console.info "No files found in $path"
        return 0
    fi

    console.info "Found ${#results[@]} files in $path:"

    for file in "${results[@]}"; do
        if [[ "$show_details" == "true" ]]; then
            local size=$(stat -c "%s" "$file" 2>/dev/null | numfmt --to=iec 2>/dev/null || echo "Unknown")
            local modified=$(stat -c "%y" "$file" 2>/dev/null | cut -d' ' -f1 || echo "Unknown")
            local permissions=$(stat -c "%A" "$file" 2>/dev/null || echo "Unknown")
            console.info "  📄 $file ($size, $modified, $permissions)"
        else
            console.info "  📄 $file"
        fi
    done
}

##
## (Usage) Search for text in files
## Examples:
##   file.search "/etc" "password"
##   file.search "/home" "TODO" --pattern="*.txt"
##   file.search "/var/log" "error" --case-insensitive
##
function file.search() {
    local path="$1"
    local search_term="$2"
    shift 2

    if [[ -z "$path" || -z "$search_term" ]]; then
        console.error "Path and search term are required"
        return 1
    fi

    if [[ ! -d "$path" ]]; then
        console.error "Directory does not exist: $path"
        return 1
    fi

    local pattern=""
    local case_insensitive=false
    local max_results=50
    local show_context=false

    # Parse options
    for arg in "$@"; do
        case $arg in
        --pattern=*) pattern="${arg#*=}" ;;
        --case-insensitive | -i) case_insensitive=true ;;
        --max=*) max_results="${arg#*=}" ;;
        --context | -C) show_context=true ;;
        *) ;;
        esac
    done

    local grep_cmd="grep"
    if [[ "$case_insensitive" == "true" ]]; then
        grep_cmd="$grep_cmd -i"
    fi

    if [[ "$show_context" == "true" ]]; then
        grep_cmd="$grep_cmd -C 2"
    fi

    local find_cmd="find '$path' -type f"
    if [[ -n "$pattern" ]]; then
        find_cmd="$find_cmd -name '$pattern'"
    fi

    find_cmd="$find_cmd -exec $grep_cmd -l '$search_term' {} + 2>/dev/null | head -n $max_results"

    local results=()
    while IFS= read -r line; do
        results+=("$line")
    done < <(eval "$find_cmd")

    if [[ ${#results[@]} -eq 0 ]]; then
        console.info "No files found containing '$search_term' in $path"
        return 0
    fi

    console.info "Found ${#results[@]} files containing '$search_term' in $path:"
    for file in "${results[@]}"; do
        console.info "  📄 $file"
    done
}

##
## (Usage) Get file statistics and information
## Examples:
##   file.stats "large_file.txt"
##   file.stats "/tmp" --summary
##
function file.stats() {
    local path="$1"
    shift

    if [[ -z "$path" ]]; then
        console.error "Path is required"
        return 1
    fi

    local summary=false

    # Parse options
    for arg in "$@"; do
        case $arg in
        --summary | -s) summary=true ;;
        *) ;;
        esac
    done

    if [[ -f "$path" ]]; then
        # Single file stats
        local size=$(stat -c "%s" "$path" 2>/dev/null | numfmt --to=iec 2>/dev/null || echo "Unknown")
        local lines=$(wc -l <"$path" 2>/dev/null || echo "Unknown")
        local words=$(wc -w <"$path" 2>/dev/null || echo "Unknown")
        local chars=$(wc -c <"$path" 2>/dev/null || echo "Unknown")
        local modified=$(stat -c "%y" "$path" 2>/dev/null || echo "Unknown")
        local permissions=$(stat -c "%A" "$path" 2>/dev/null || echo "Unknown")

        console.info "File Statistics: $path"
        console.info "  Size: $size"
        console.info "  Lines: $lines"
        console.info "  Words: $words"
        console.info "  Characters: $chars"
        console.info "  Modified: $modified"
        console.info "  Permissions: $permissions"

    elif [[ -d "$path" ]]; then
        # Directory stats
        local file_count=$(find "$path" -type f | wc -l)
        local dir_count=$(find "$path" -type d | wc -l)
        local total_size=$(du -sh "$path" 2>/dev/null | cut -f1 || echo "Unknown")

        console.info "Directory Statistics: $path"
        console.info "  Files: $file_count"
        console.info "  Directories: $dir_count"
        console.info "  Total Size: $total_size"

        if [[ "$summary" == "true" ]]; then
            local largest_files=$(find "$path" -type f -exec ls -la {} + | sort -k5 -n | tail -5)
            console.info "  Largest files:"
            echo "$largest_files" | while read -r line; do
                console.info "    $line"
            done
        fi
    else
        console.error "Path does not exist: $path"
        return 1
    fi
}

##
## (Usage) Copy files with various options
## Examples:
##   file.copy "source.txt" "dest.txt"
##   file.copy "config.json" "/backup/" --preserve
##   file.copy "*.log" "/logs/" --pattern
##
function file.copy() {
    local source="$1"
    local destination="$2"
    shift 2

    if [[ -z "$source" || -z "$destination" ]]; then
        console.error "Source and destination are required"
        return 1
    fi

    local preserve=false
    local pattern=false

    # Parse options
    for arg in "$@"; do
        case $arg in
        --preserve | -p) preserve=true ;;
        --pattern) pattern=true ;;
        *) ;;
        esac
    done

    local cp_opts=""
    [[ "$preserve" == "true" ]] && cp_opts="$cp_opts -p"

    if [[ "$pattern" == "true" ]]; then
        # Copy files matching pattern
        local source_dir=$(dirname "$source")
        local pattern_name=$(basename "$source")

        if [[ ! -d "$source_dir" ]]; then
            console.error "Source directory does not exist: $source_dir"
            return 1
        fi

        # Create destination if it doesn't exist
        if [[ ! -d "$destination" ]]; then
            directory.create "$destination" --parents || {
                console.error "Failed to create destination directory: $destination"
                return 1
            }
        fi

        # Copy matching files
        find "$source_dir" -maxdepth 1 -name "$pattern_name" -type f -exec cp $cp_opts {} "$destination/" \; || {
            console.error "Failed to copy files matching pattern: $source"
            return 1
        }

        console.success "Copied files matching '$pattern_name' to $destination"
    else
        # Copy single file
        if [[ ! -f "$source" ]]; then
            console.error "Source file does not exist: $source"
            return 1
        fi

        # Create destination directory if needed
        if [[ -d "$destination" ]]; then
            destination="$destination/$(basename "$source")"
        else
            local dest_dir=$(dirname "$destination")
            if [[ ! -d "$dest_dir" ]]; then
                directory.create "$dest_dir" --parents || {
                    console.error "Failed to create destination directory: $dest_dir"
                    return 1
                }
            fi
        fi

        cp $cp_opts "$source" "$destination" || {
            console.error "Failed to copy $source to $destination"
            return 1
        }

        console.success "Copied $source to $destination"
    fi
}

##
## (Usage) Move files with various options
## Examples:
##   file.move "old_name.txt" "new_name.txt"
##   file.move "temp_file.log" "/archive/"
##
function file.move() {
    local source="$1"
    local destination="$2"

    if [[ -z "$source" || -z "$destination" ]]; then
        console.error "Source and destination are required"
        return 1
    fi

    if [[ ! -f "$source" ]]; then
        console.error "Source file does not exist: $source"
        return 1
    fi

    # Create destination directory if needed
    if [[ -d "$destination" ]]; then
        destination="$destination/$(basename "$source")"
    else
        local dest_dir=$(dirname "$destination")
        if [[ ! -d "$dest_dir" ]]; then
            directory.create "$dest_dir" --parents || {
                console.error "Failed to create destination directory: $dest_dir"
                return 1
            }
        fi
    fi

    mv "$source" "$destination" || {
        console.error "Failed to move $source to $destination"
        return 1
    }

    console.success "Moved $source to $destination"
}

##
## (Usage) Delete files with various options
## Examples:
##   file.delete "temp_file.txt"
##   file.delete "*.tmp" --pattern
##   file.delete "old_logs/" --recursive
##
function file.delete() {
    local path="$1"
    shift

    if [[ -z "$path" ]]; then
        console.error "Path is required"
        return 1
    fi

    local pattern=false
    local recursive=false
    local force=false

    # Parse options
    for arg in "$@"; do
        case $arg in
        --pattern) pattern=true ;;
        --recursive | -r) recursive=true ;;
        --force | -f) force=true ;;
        *) ;;
        esac
    done

    if [[ "$pattern" == "true" ]]; then
        # Delete files matching pattern
        local dir=$(dirname "$path")
        local pattern_name=$(basename "$path")

        if [[ ! -d "$dir" ]]; then
            console.error "Directory does not exist: $dir"
            return 1
        fi

        find "$dir" -maxdepth 1 -name "$pattern_name" -type f -delete || {
            console.error "Failed to delete files matching pattern: $path"
            return 1
        }

        console.success "Deleted files matching '$pattern_name'"
    else
        # Delete single file or directory
        if [[ ! -e "$path" ]]; then
            console.error "Path does not exist: $path"
            return 1
        fi

        if [[ -d "$path" && "$recursive" == "false" ]]; then
            console.error "Cannot delete directory without --recursive flag"
            return 1
        fi

        if [[ -d "$path" ]]; then
            rm -rf "$path" || {
                console.error "Failed to delete directory: $path"
                return 1
            }
            console.success "Deleted directory: $path"
        else
            rm -f "$path" || {
                console.error "Failed to delete file: $path"
                return 1
            }
            console.success "Deleted file: $path"
        fi
    fi
}

##
## (Usage) Check if a file exists
## Examples:
##   file.exists "config.txt" && echo "File exists"
##   if file.exists "data.json"; then echo "Found"; fi
##
function file.exists() {
    local filepath="$1"

    if [[ -z "$filepath" ]]; then
        console.error "File path is required"
        return 1
    fi

    [[ -f "$filepath" ]]
}

##
## (Usage) Check if a file exists, exit with error if not
## Examples:
##   file.existsOrBreak "config.txt"
##   file.existsOrBreak "data.json" "Configuration file is required"
##
function file.existsOrBreak() {
    local filepath="$1"
    local error_message="${2:-File does not exist: $filepath}"

    if ! file.exists "$filepath"; then
        console.error "$error_message"
        return 1
    fi

    return 0
}

##
## (Usage) Check if a file is writable
## Examples:
##   file.isWritable "log.txt" && echo "Can write to log"
##   if file.isWritable "config.json"; then echo "Writable"; fi
##
function file.isWritable() {
    local filepath="$1"

    if [[ -z "$filepath" ]]; then
        console.error "File path is required"
        return 1
    fi

    [[ -w "$filepath" ]]
}

##
## (Usage) Check if a file is readable
## Examples:
##   file.isReadable "config.txt" && echo "Can read config"
##   if file.isReadable "data.json"; then echo "Readable"; fi
##
function file.isReadable() {
    local filepath="$1"

    if [[ -z "$filepath" ]]; then
        console.error "File path is required"
        return 1
    fi

    [[ -r "$filepath" ]]
}

##
## (Usage) Check if a file is executable
## Examples:
##   file.isExecutable "script.sh" && echo "Can execute script"
##   if file.isExecutable "binary"; then echo "Executable"; fi
##
function file.isExecutable() {
    local filepath="$1"

    if [[ -z "$filepath" ]]; then
        console.error "File path is required"
        return 1
    fi

    [[ -x "$filepath" ]]
}

##
## (Usage) Validate file with multiple checks
## Options:
##   --exists        - Check if file exists
##   --readable      - Check if file is readable
##   --writable      - Check if file is writable
##   --executable    - Check if file is executable
##   --not-empty     - Check if file is not empty
##   --break-on-error - Exit on first error (default: continue)
##
## Examples:
##   file.validate "config.txt" --exists --readable
##   file.validate "log.txt" --exists --writable --not-empty
##   file.validate "script.sh" --exists --executable --break-on-error
##
function file.validate() {
    local filepath="$1"
    shift

    if [[ -z "$filepath" ]]; then
        console.error "File path is required"
        return 1
    fi

    local check_exists=false
    local check_readable=false
    local check_writable=false
    local check_executable=false
    local check_not_empty=false
    local break_on_error=false

    # Parse options
    for arg in "$@"; do
        case $arg in
        --exists) check_exists=true ;;
        --readable) check_readable=true ;;
        --writable) check_writable=true ;;
        --executable) check_executable=true ;;
        --not-empty) check_not_empty=true ;;
        --break-on-error) break_on_error=true ;;
        *) ;;
        esac
    done

    # If no checks specified, default to exists
    if [[ "$check_exists" == "false" && "$check_readable" == "false" && "$check_writable" == "false" && "$check_executable" == "false" && "$check_not_empty" == "false" ]]; then
        check_exists=true
    fi

    local exit_code=0

    # Perform checks
    if [[ "$check_exists" == "true" ]]; then
        if file.exists "$filepath"; then
            console.success "$filepath exists"
        else
            console.error "$filepath does not exist"
            exit_code=1
            if [[ "$break_on_error" == "true" ]]; then
                return $exit_code
            fi
        fi
    fi

    if [[ "$check_readable" == "true" ]]; then
        if file.isReadable "$filepath"; then
            console.success "$filepath is readable"
        else
            console.error "$filepath is not readable"
            exit_code=1
            if [[ "$break_on_error" == "true" ]]; then
                return $exit_code
            fi
        fi
    fi

    if [[ "$check_writable" == "true" ]]; then
        if file.isWritable "$filepath"; then
            console.success "$filepath is writable"
        else
            console.error "$filepath is not writable"
            exit_code=1
            if [[ "$break_on_error" == "true" ]]; then
                return $exit_code
            fi
        fi
    fi

    if [[ "$check_executable" == "true" ]]; then
        if file.isExecutable "$filepath"; then
            console.success "$filepath is executable"
        else
            console.error "$filepath is not executable"
            exit_code=1
            if [[ "$break_on_error" == "true" ]]; then
                return $exit_code
            fi
        fi
    fi

    if [[ "$check_not_empty" == "true" ]]; then
        if [[ -s "$filepath" ]]; then
            console.success "$filepath is not empty"
        else
            console.error "$filepath is empty"
            exit_code=1
            if [[ "$break_on_error" == "true" ]]; then
                return $exit_code
            fi
        fi
    fi

    return $exit_code
}

##
## (Usage) Show file module help
##
function file.help() {
    cat <<EOF
File Module - Comprehensive file management and manipulation utilities

Available Functions:
  file.create <path> [options]           - Create a new file with optional content
  file.read <path> [options]             - Read file content with various filters
  file.write <path> <content> [options]   - Write content to files
  file.list <path> [options]             - List files with filters and sorting
  file.search <path> <term> [options]     - Search for text in files
  file.stats <path> [options]             - Get file statistics and information
  file.copy <source> <dest> [options]     - Copy files with various options
  file.move <source> <dest>               - Move/rename files
  file.delete <path> [options]            - Delete files and directories
  file.exists <path>                      - Check if file exists
  file.existsOrBreak <path> [message]     - Check if file exists, exit if not
  file.isReadable <path>                  - Check if file is readable
  file.isWritable <path>                  - Check if file is writable
  file.isExecutable <path>                - Check if file is executable
  file.validate <path> [options]          - Validate file with multiple checks
  file.help                               - Show this help

Options:
  --content=<text>        - Content to write to file (file.create)
  --executable, -x         - Make file executable (file.create)
  --overwrite, -f          - Overwrite existing file (file.create, file.write)
  --append, -a             - Append content instead of overwrite (file.write)
  --lines=<n>              - Show only first N lines (file.read)
  --tail=<n>               - Show only last N lines (file.read)
  --grep=<pattern>         - Filter lines matching pattern (file.read)
  --line-numbers, -n       - Show line numbers (file.read)
  --pattern=<glob>         - Filter files by pattern (file.list, file.search)
  --size=<filter>          - Filter by size (e.g., +1M, -100k) (file.list)
  --modified=<days>         - Filter by modification time (e.g., +7d, -1d) (file.list)
  --max=<n>                - Maximum number of results (file.list, file.search)
  --sort=<field>           - Sort by name, size, or date (file.list)
  --reverse, -r            - Reverse sort order (file.list)
  --details, -l            - Show detailed information (file.list)
  --case-insensitive, -i   - Case-insensitive search (file.search)
  --context, -C            - Show context around matches (file.search)
  --summary, -s            - Show summary statistics (file.stats)
  --preserve, -p           - Preserve attributes when copying (file.copy)
  --recursive, -r          - Recursive operation (file.delete)

Validation Options (file.validate):
  --exists                 - Check if file exists
  --readable               - Check if file is readable
  --writable               - Check if file is writable
  --executable             - Check if file is executable
  --not-empty              - Check if file is not empty
  --break-on-error         - Exit on first error (default: continue)

Examples:
  file.create "config.json" --content='{"key":"value"}'
  file.read "log.txt" --lines=10 --grep="ERROR"
  file.write "data.txt" "new data" --append
  file.list "/tmp" --pattern="*.log" --size=+1M --sort=date
  file.search "/etc" "password" --case-insensitive
  file.stats "large_file.txt"
  file.copy "*.txt" "/backup/" --pattern
  file.move "old.txt" "new.txt"
  file.delete "temp_*.tmp" --pattern
  file.exists "config.txt" && echo "File exists"
  file.existsOrBreak "data.json" "Configuration file is required"
  file.validate "log.txt" --exists --writable --not-empty
  file.validate "script.sh" --exists --executable --break-on-error
EOF
}
