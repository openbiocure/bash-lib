#!/bin/bash

# Directory Module for bash-lib
# Provides comprehensive file and directory management utilities

# Module import signal using scoped naming
export BASH_LIB_IMPORTED_directory="1"

# Call import.meta.loaded if the function exists (with error suppression)
if command -v import.meta.loaded >/dev/null 2>&1; then
    import.meta.loaded "directory" "${BASH__PATH:-/opt/bash-lib}/modules/directory/directory.mod.sh" "1.0.0" 2>/dev/null || true
fi

import console
import string

# Directory Module Configuration
__DIR__DEFAULT_DEPTH=3
__DIR__DEFAULT_MAX_RESULTS=100
__DIR__DEFAULT_SORT_BY="name"  # name, size, date, type

##
## (Usage) List directory contents with various options
## Examples:
##   directory.list ~/Documents
##   directory.list ~/Documents --all --long
##   directory.list ~/Documents --type=file --sort=size
##   directory.list ~/Documents --pattern="*.txt" --max=50
##
function directory.list() {
    local path="${1:-.}"
    shift
    
    if [[ ! -d "$path" ]]; then
        console.error "Directory does not exist: $path"
        return 1
    fi
    
    local show_hidden=false
    local long_format=false
    local file_type=""
    local pattern=""
    local max_results="${__DIR__DEFAULT_MAX_RESULTS}"
    local sort_by="${__DIR__DEFAULT_SORT_BY}"
    local reverse_sort=false
    
    # Parse options
    for arg in "$@"; do
        case $arg in
            --all|-a) show_hidden=true ;;
            --long|-l) long_format=true ;;
            --type=*) file_type="${arg#*=}" ;;
            --pattern=*) pattern="${arg#*=}" ;;
            --max=*) max_results="${arg#*=}" ;;
            --sort=*) sort_by="${arg#*=}" ;;
            --reverse|-r) reverse_sort=true ;;
            *) ;;
        esac
    done
    
    # Build find command
    local find_cmd="find \"$path\" -maxdepth 1"
    
    if [[ "$show_hidden" == "false" ]]; then
        find_cmd="$find_cmd -not -name '.*'"
    fi
    
    if [[ -n "$file_type" ]]; then
        case $file_type in
            file) find_cmd="$find_cmd -type f" ;;
            dir|directory) find_cmd="$find_cmd -type d" ;;
            link|symlink) find_cmd="$find_cmd -type l" ;;
            *) ;;
        esac
    fi
    
    if [[ -n "$pattern" ]]; then
        find_cmd="$find_cmd -name \"$pattern\""
    fi
    
    # Execute find and process results
    local results=()
    local count=0
    while IFS= read -r -d '' item && [[ $count -lt $max_results ]]; do
        results+=("$item")
        ((count++))
    done < <(eval "$find_cmd -print0" 2>/dev/null)
    
    # Sort results
    if [[ ${#results[@]} -gt 0 ]]; then
        case $sort_by in
            name)
                if [[ "$reverse_sort" == "true" ]]; then
                    IFS=$'\n' results=($(printf '%s\n' "${results[@]}" | sort -r))
                else
                    IFS=$'\n' results=($(printf '%s\n' "${results[@]}" | sort))
                fi
                ;;
            size)
                if [[ "$reverse_sort" == "true" ]]; then
                    IFS=$'\n' results=($(printf '%s\n' "${results[@]}" | xargs -I {} stat -c "%s %n" {} 2>/dev/null | sort -nr | cut -d' ' -f2-))
                else
                    IFS=$'\n' results=($(printf '%s\n' "${results[@]}" | xargs -I {} stat -c "%s %n" {} 2>/dev/null | sort -n | cut -d' ' -f2-))
                fi
                ;;
            date)
                if [[ "$reverse_sort" == "true" ]]; then
                    IFS=$'\n' results=($(printf '%s\n' "${results[@]}" | xargs -I {} stat -c "%Y %n" {} 2>/dev/null | sort -nr | cut -d' ' -f2-))
                else
                    IFS=$'\n' results=($(printf '%s\n' "${results[@]}" | xargs -I {} stat -c "%Y %n" {} 2>/dev/null | sort -n | cut -d' ' -f2-))
                fi
                ;;
        esac
    fi
    
    # Display results
    if [[ ${#results[@]} -eq 0 ]]; then
        console.info "No items found in $path"
        return 0
    fi
    
    if [[ "$long_format" == "true" ]]; then
        directory.__display_long "${results[@]}"
    else
        directory.__display_simple "${results[@]}"
    fi
    
    console.info "Found ${#results[@]} items in $path"
}

##
## (Usage) Search for files and directories recursively
## Examples:
##   directory.search ~/Documents "*.txt"
##   directory.search ~/Documents "config" --type=file --depth=5
##   directory.search ~/Documents "*.log" --size=+1M --max=20
##
function directory.search() {
    local path="${1:-.}"
    local pattern="$2"
    shift 2
    
    if [[ ! -d "$path" ]]; then
        console.error "Directory does not exist: $path"
        return 1
    fi
    
    if [[ -z "$pattern" ]]; then
        console.error "Search pattern is required"
        return 1
    fi
    
    local max_depth="${__DIR__DEFAULT_DEPTH}"
    local file_type=""
    local size_filter=""
    local max_results="${__DIR__DEFAULT_MAX_RESULTS}"
    local case_sensitive=true
    
    # Parse options
    for arg in "$@"; do
        case $arg in
            --depth=*) max_depth="${arg#*=}" ;;
            --type=*) file_type="${arg#*=}" ;;
            --size=*) size_filter="${arg#*=}" ;;
            --max=*) max_results="${arg#*=}" ;;
            --ignore-case|-i) case_sensitive=false ;;
            *) ;;
        esac
    done
    
    # Build find command
    local find_cmd="find \"$path\" -maxdepth $max_depth"
    
    if [[ "$case_sensitive" == "false" ]]; then
        find_cmd="$find_cmd -iname \"$pattern\""
    else
        find_cmd="$find_cmd -name \"$pattern\""
    fi
    
    if [[ -n "$file_type" ]]; then
        case $file_type in
            file) find_cmd="$find_cmd -type f" ;;
            dir|directory) find_cmd="$find_cmd -type d" ;;
            link|symlink) find_cmd="$find_cmd -type l" ;;
            *) ;;
        esac
    fi
    
    if [[ -n "$size_filter" ]]; then
        find_cmd="$find_cmd -size \"$size_filter\""
    fi
    
    # Execute search
    local results=()
    local count=0
    while IFS= read -r -d '' item && [[ $count -lt $max_results ]]; do
        results+=("$item")
        ((count++))
    done < <(eval "$find_cmd -print0" 2>/dev/null)
    
    # Display results
    if [[ ${#results[@]} -eq 0 ]]; then
        console.info "No files found matching '$pattern' in $path"
        return 0
    fi
    
    console.info "Found ${#results[@]} items matching '$pattern':"
    for item in "${results[@]}"; do
        local relative_path="${item#$path/}"
        if [[ -d "$item" ]]; then
            console.info "  📁 $relative_path"
        elif [[ -L "$item" ]]; then
            console.info "  🔗 $relative_path"
        else
            console.info "  📄 $relative_path"
        fi
    done
}

##
## (Usage) Remove files and directories
## Examples:
##   directory.remove ~/temp/file.txt
##   directory.remove ~/temp/dir --recursive
##   directory.remove ~/temp --pattern="*.tmp" --force
##
function directory.remove() {
    local path="$1"
    shift
    
    if [[ -z "$path" ]]; then
        console.error "Path is required"
        return 1
    fi
    
    local recursive=false
    local force=false
    local pattern=""
    
    # Parse options
    for arg in "$@"; do
        case $arg in
            --recursive|-r) recursive=true ;;
            --force|-f) force=true ;;
            --pattern=*) pattern="${arg#*=}" ;;
            *) ;;
        esac
    done
    
    if [[ -n "$pattern" ]]; then
        # Remove files matching pattern
        if [[ "$recursive" == "true" ]]; then
            find "$path" -name "$pattern" -type f -print0 | xargs -0 rm -f
        else
            find "$path" -maxdepth 1 -name "$pattern" -type f -print0 | xargs -0 rm -f
        fi
        console.success "Removed files matching '$pattern' from $path"
    else
        # Remove specific path
        if [[ ! -e "$path" ]]; then
            console.error "Path does not exist: $path"
            return 1
        fi
        
        if [[ -d "$path" && "$recursive" == "false" ]]; then
            if [[ "$force" == "true" ]]; then
                rm -rf "$path"
                console.success "Removed directory: $path"
            else
                console.error "Cannot remove directory without --recursive flag"
                return 1
            fi
        else
            rm -f "$path"
            console.success "Removed file: $path"
        fi
    fi
}

##
## (Usage) Copy files and directories
## Examples:
##   directory.copy ~/source/file.txt ~/dest/
##   directory.copy ~/source/dir ~/dest/ --recursive
##   directory.copy ~/source ~/dest --pattern="*.txt" --preserve
##
function directory.copy() {
    local source="$1"
    local destination="$2"
    shift 2
    
    if [[ -z "$source" || -z "$destination" ]]; then
        console.error "Source and destination are required"
        return 1
    fi
    
    if [[ ! -e "$source" ]]; then
        console.error "Source does not exist: $source"
        return 1
    fi
    
    local recursive=false
    local preserve=false
    local pattern=""
    
    # Parse options
    for arg in "$@"; do
        case $arg in
            --recursive|-r) recursive=true ;;
            --preserve|-p) preserve=true ;;
            --pattern=*) pattern="${arg#*=}" ;;
            *) ;;
        esac
    done
    
    # Create destination directory if it doesn't exist
    if [[ ! -d "$destination" ]]; then
        mkdir -p "$destination" || {
            console.error "Failed to create destination directory: $destination"
            return 1
        }
    fi
    
    if [[ -n "$pattern" ]]; then
        # Copy files matching pattern
        local cp_opts=""
        [[ "$preserve" == "true" ]] && cp_opts="$cp_opts -p"
        
        if [[ "$recursive" == "true" ]]; then
            find "$source" -name "$pattern" -type f -exec cp $cp_opts {} "$destination/" \;
        else
            find "$source" -maxdepth 1 -name "$pattern" -type f -exec cp $cp_opts {} "$destination/" \;
        fi
        console.success "Copied files matching '$pattern' to $destination"
    else
        # Copy specific path
        local cp_opts=""
        [[ "$recursive" == "true" ]] && cp_opts="$cp_opts -r"
        [[ "$preserve" == "true" ]] && cp_opts="$cp_opts -p"
        
        cp $cp_opts "$source" "$destination/" || {
            console.error "Failed to copy $source to $destination"
            return 1
        }
        console.success "Copied $source to $destination"
    fi
}

##
## (Usage) Move/rename files and directories
## Examples:
##   directory.move ~/old_name.txt ~/new_name.txt
##   directory.move ~/source/dir ~/dest/dir
##
function directory.move() {
    local source="$1"
    local destination="$2"
    
    if [[ -z "$source" || -z "$destination" ]]; then
        console.error "Source and destination are required"
        return 1
    fi
    
    if [[ ! -e "$source" ]]; then
        console.error "Source does not exist: $source"
        return 1
    fi
    
    # Create destination directory if moving to a directory
    if [[ -d "$destination" ]]; then
        destination="$destination/$(basename "$source")"
    else
        local dest_dir=$(dirname "$destination")
        if [[ ! -d "$dest_dir" ]]; then
            mkdir -p "$dest_dir" || {
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
## (Usage) Create directories
## Examples:
##   directory.create ~/new/directory
##   directory.create ~/new/dir --parents
##
function directory.create() {
    local path="$1"
    shift
    
    if [[ -z "$path" ]]; then
        console.error "Path is required"
        return 1
    fi
    
    local parents=false
    
    # Parse options
    for arg in "$@"; do
        case $arg in
            --parents|-p) parents=true ;;
            *) ;;
        esac
    done
    
    if [[ -e "$path" ]]; then
        console.warn "Path already exists: $path"
        return 0
    fi
    
    local mkdir_opts=""
    [[ "$parents" == "true" ]] && mkdir_opts="$mkdir_opts -p"
    
    mkdir $mkdir_opts "$path" || {
        console.error "Failed to create directory: $path"
        return 1
    }
    
    console.success "Created directory: $path"
}

##
## (Usage) Get file/directory information
## Examples:
##   directory.info ~/file.txt
##   directory.info ~/directory --detailed
##
function directory.info() {
    local path="$1"
    shift
    
    if [[ -z "$path" ]]; then
        console.error "Path is required"
        return 1
    fi
    
    if [[ ! -e "$path" ]]; then
        console.error "Path does not exist: $path"
        return 1
    fi
    
    local detailed=false
    
    # Parse options
    for arg in "$@"; do
        case $arg in
            --detailed|-d) detailed=true ;;
            *) ;;
        esac
    done
    
    local name=$(basename "$path")
    local type=""
    local size=""
    local permissions=""
    local owner=""
    local modified=""
    
    if [[ -d "$path" ]]; then
        type="Directory"
        size=$(du -sh "$path" 2>/dev/null | cut -f1)
    elif [[ -L "$path" ]]; then
        type="Symbolic Link"
        size=$(stat -c "%s" "$path" 2>/dev/null | numfmt --to=iec 2>/dev/null || echo "Unknown")
    else
        type="File"
        size=$(stat -c "%s" "$path" 2>/dev/null | numfmt --to=iec 2>/dev/null || echo "Unknown")
    fi
    
    permissions=$(stat -c "%A" "$path" 2>/dev/null || echo "Unknown")
    owner=$(stat -c "%U:%G" "$path" 2>/dev/null || echo "Unknown")
    modified=$(stat -c "%y" "$path" 2>/dev/null || echo "Unknown")
    
    console.info "File Information:"
    console.info "  Name: $name"
    console.info "  Type: $type"
    console.info "  Size: $size"
    console.info "  Permissions: $permissions"
    console.info "  Permissions Description: $(directory.__permissions_to_description "$permissions")"
    console.info "  Owner: $owner"
    console.info "  Modified: $modified"
    
    if [[ "$detailed" == "true" ]]; then
        local inode=$(stat -c "%i" "$path" 2>/dev/null || echo "Unknown")
        local hard_links=$(stat -c "%h" "$path" 2>/dev/null || echo "Unknown")
        local device=$(stat -c "%D" "$path" 2>/dev/null || echo "Unknown")
        
        console.info "  Inode: $inode"
        console.info "  Hard Links: $hard_links"
        console.info "  Device: $device"
        
        if [[ -L "$path" ]]; then
            local target=$(readlink "$path")
            console.info "  Target: $target"
        fi
    fi
}

##
## (Usage) Get directory size
## Examples:
##   directory.size ~/Documents
##   directory.size ~/Downloads --human-readable
##
function directory.size() {
    local path="$1"
    shift
    
    if [[ -z "$path" ]]; then
        console.error "Path is required"
        return 1
    fi
    
    if [[ ! -d "$path" ]]; then
        console.error "Path is not a directory: $path"
        return 1
    fi
    
    local human_readable=true
    
    # Parse options
    for arg in "$@"; do
        case $arg in
            --bytes|-b) human_readable=false ;;
            *) ;;
        esac
    done
    
    local size
    if [[ "$human_readable" == "true" ]]; then
        size=$(du -sh "$path" 2>/dev/null | cut -f1)
    else
        size=$(du -sb "$path" 2>/dev/null | cut -f1)
    fi
    
    if [[ -n "$size" ]]; then
        console.info "Directory size: $size"
        echo "$size"
    else
        console.error "Failed to get directory size"
        return 1
    fi
}

##
## (Usage) Find empty files and directories
## Examples:
##   directory.find_empty ~/Documents
##   directory.find_empty ~/Downloads --files-only
##   directory.find_empty ~/temp --directories-only
##
function directory.find_empty() {
    local path="${1:-.}"
    shift
    
    if [[ ! -d "$path" ]]; then
        console.error "Directory does not exist: $path"
        return 1
    fi
    
    local files_only=false
    local directories_only=false
    
    # Parse options
    for arg in "$@"; do
        case $arg in
            --files-only|-f) files_only=true ;;
            --directories-only|-d) directories_only=true ;;
            *) ;;
        esac
    done
    
    local find_cmd="find \"$path\""
    
    if [[ "$files_only" == "true" ]]; then
        find_cmd="$find_cmd -type f -empty"
    elif [[ "$directories_only" == "true" ]]; then
        find_cmd="$find_cmd -type d -empty"
    else
        find_cmd="$find_cmd -empty"
    fi
    
    local results=()
    local count=0
    while IFS= read -r -d '' item && [[ $count -lt $max_results ]]; do
        results+=("$item")
        ((count++))
    done < <(eval "$find_cmd -print0" 2>/dev/null)
    
    if [[ ${#results[@]} -eq 0 ]]; then
        console.info "No empty items found in $path"
        return 0
    fi
    
    console.info "Found ${#results[@]} empty items:"
    for item in "${results[@]}"; do
        local relative_path="${item#$path/}"
        if [[ -d "$item" ]]; then
            console.info "  📁 $relative_path (empty directory)"
        else
            console.info "  📄 $relative_path (empty file)"
        fi
    done
}

# Internal helper functions

function directory.__permissions_to_description() {
    local permissions="$1"
    
    if [[ -z "$permissions" || "$permissions" == "Unknown" ]]; then
        echo "Unknown permissions"
        return
    fi
    
    local description=""
    
    # File type
    case ${permissions:0:1} in
        "-") description="Regular file" ;;
        "d") description="Directory" ;;
        "l") description="Symbolic link" ;;
        "c") description="Character device" ;;
        "b") description="Block device" ;;
        "p") description="Named pipe" ;;
        "s") description="Socket" ;;
        *) description="Unknown type" ;;
    esac
    
    description="$description with permissions: "
    
    # Owner permissions
    case ${permissions:1:3} in
        "rwx") description="${description}owner can read, write, and execute" ;;
        "rw-") description="${description}owner can read and write" ;;
        "r-x") description="${description}owner can read and execute" ;;
        "r--") description="${description}owner can read only" ;;
        "-wx") description="${description}owner can write and execute" ;;
        "-w-") description="${description}owner can write only" ;;
        "--x") description="${description}owner can execute only" ;;
        "---") description="${description}owner has no permissions" ;;
        *) description="${description}owner has unusual permissions" ;;
    esac
    
    description="$description; "
    
    # Group permissions
    case ${permissions:4:3} in
        "rwx") description="${description}group can read, write, and execute" ;;
        "rw-") description="${description}group can read and write" ;;
        "r-x") description="${description}group can read and execute" ;;
        "r--") description="${description}group can read only" ;;
        "-wx") description="${description}group can write and execute" ;;
        "-w-") description="${description}group can write only" ;;
        "--x") description="${description}group can execute only" ;;
        "---") description="${description}group has no permissions" ;;
        *) description="${description}group has unusual permissions" ;;
    esac
    
    description="$description; "
    
    # Others permissions
    case ${permissions:7:3} in
        "rwx") description="${description}others can read, write, and execute" ;;
        "rw-") description="${description}others can read and write" ;;
        "r-x") description="${description}others can read and execute" ;;
        "r--") description="${description}others can read only" ;;
        "-wx") description="${description}others can write and execute" ;;
        "-w-") description="${description}others can write only" ;;
        "--x") description="${description}others can execute only" ;;
        "---") description="${description}others have no permissions" ;;
        *) description="${description}others have unusual permissions" ;;
    esac
    
    echo "$description"
}

function directory.__display_simple() {
    local items=("$@")
    for item in "${items[@]}"; do
        local name=$(basename "$item")
        if [[ -d "$item" ]]; then
            echo "📁 $name"
        elif [[ -L "$item" ]]; then
            echo "🔗 $name"
        else
            echo "📄 $name"
        fi
    done
}

function directory.__display_long() {
    local items=("$@")
    for item in "${items[@]}"; do
        local name=$(basename "$item")
        local permissions=$(stat -c "%A" "$item" 2>/dev/null || echo "??????")
        local owner=$(stat -c "%U" "$item" 2>/dev/null || echo "unknown")
        local size=$(stat -c "%s" "$item" 2>/dev/null | numfmt --to=iec 2>/dev/null || echo "0")
        local modified=$(stat -c "%y" "$item" 2>/dev/null | cut -d' ' -f1 || echo "unknown")
        
        local icon="📄"
        if [[ -d "$item" ]]; then
            icon="📁"
        elif [[ -L "$item" ]]; then
            icon="🔗"
        fi
        
        printf "%-10s %-8s %-8s %-8s %s %s\n" "$permissions" "$owner" "$size" "$modified" "$icon" "$name"
    done
}

##
## (Usage) Set default search depth
## Examples:
##   directory.set_depth 5
##
function directory.set_depth() {
    if [[ -n "$1" && "$1" =~ ^[0-9]+$ ]]; then
        __DIR__DEFAULT_DEPTH="$1"
        console.info "Default search depth set to ${__DIR__DEFAULT_DEPTH}"
    else
        console.error "Invalid depth value. Must be a positive integer."
        return 1
    fi
}

##
## (Usage) Set default max results
## Examples:
##   directory.set_max_results 50
##
function directory.set_max_results() {
    if [[ -n "$1" && "$1" =~ ^[0-9]+$ ]]; then
        __DIR__DEFAULT_MAX_RESULTS="$1"
        console.info "Default max results set to ${__DIR__DEFAULT_MAX_RESULTS}"
    else
        console.error "Invalid max results value. Must be a positive integer."
        return 1
    fi
}

##
## (Usage) Show directory module help
##
function directory.help() {
    cat <<EOF
Directory Module - Comprehensive File and Directory Management

Available Functions:
  directory.list <path> [options]        - List directory contents
  directory.search <path> <pattern> [opts] - Search for files recursively
  directory.remove <path> [options]      - Remove files/directories
  directory.copy <source> <dest> [opts]  - Copy files/directories
  directory.move <source> <dest>         - Move/rename files/directories
  directory.create <path> [options]      - Create directories
  directory.info <path> [options]        - Get file/directory information
  directory.size <path> [options]        - Get directory size
  directory.find_empty <path> [options]  - Find empty files/directories
  directory.set_depth <number>           - Set default search depth
  directory.set_max_results <number>     - Set default max results
  directory.help                         - Show this help

List Options:
  --all, -a              - Show hidden files
  --long, -l             - Show detailed format
  --type=<type>          - Filter by type (file|dir|link)
  --pattern=<pattern>    - Filter by name pattern
  --max=<number>         - Maximum results to show
  --sort=<field>         - Sort by (name|size|date)
  --reverse, -r          - Reverse sort order

Search Options:
  --depth=<number>       - Maximum search depth
  --type=<type>          - Filter by type (file|dir|link)
  --size=<filter>        - Filter by size (e.g., +1M, -100k)
  --max=<number>         - Maximum results to show
  --ignore-case, -i      - Case-insensitive search

Remove Options:
  --recursive, -r        - Remove directories recursively
  --force, -f            - Force removal without confirmation
  --pattern=<pattern>    - Remove files matching pattern

Copy Options:
  --recursive, -r        - Copy directories recursively
  --preserve, -p         - Preserve attributes

Create Options:
  --parents, -p          - Create parent directories

Info Options:
  --detailed, -d         - Show detailed information

Size Options:
  --bytes, -b            - Show size in bytes

Find Empty Options:
  --files-only, -f       - Find only empty files
  --directories-only, -d - Find only empty directories

Examples:
  directory.list ~/Documents --all --long
  directory.search ~/Downloads "*.pdf" --depth=5
  directory.remove ~/temp --pattern="*.tmp" --force
  directory.copy ~/source ~/backup --recursive
  directory.move ~/old_name.txt ~/new_name.txt
  directory.create ~/new/project --parents
  directory.info ~/file.txt --detailed
  directory.size ~/Downloads --human-readable
  directory.find_empty ~/temp --files-only
EOF
}