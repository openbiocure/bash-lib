#!/bin/bash

# Directory Module for bash-lib
# Provides comprehensive file and directory management utilities

# Call import.meta.loaded if the function exists (with error suppression)
if command -v import.meta.loaded >/dev/null 2>&1; then
    import.meta.loaded "directory" "${BASH__PATH:-/opt/bash-lib}/lib/modules/directory/directory.mod.sh" "1.0.0" 2>/dev/null || true
fi

import console
import string

# Directory Module Configuration
__DIR__DEFAULT_DEPTH=3
__DIR__DEFAULT_MAX_RESULTS=100
__DIR__DEFAULT_SORT_BY="name" # name, size, date, type

##
## (Usage) List directory contents with various options
## Examples:
##   directory.list ~/Documents
##   directory.list ~/Documents --all --long
##   directory.list ~/Documents --type=file --sort=size
##   directory.list ~/Documents --pattern="*.txt" --max=50
##
function directory.list() {
    local dir="${1:-.}"
    local long_format=false
    local type_filter=""
    local pattern=""
    local max_results="$__DIR__DEFAULT_MAX_RESULTS"
    local sort_by="$__DIR__DEFAULT_SORT_BY"
    local reverse=false
    shift
    while [[ $# -gt 0 ]]; do
        case "$1" in
        --long | -l)
            long_format=true
            shift
            ;;
        --type | -t)
            type_filter="$2"
            shift 2
            ;;
        --pattern | -p)
            pattern="$2"
            shift 2
            ;;
        --max | -m)
            max_results="$2"
            shift 2
            ;;
        --sort | -s)
            sort_by="$2"
            shift 2
            ;;
        --reverse | -r)
            reverse=true
            shift
            ;;
        *)
            console.error "Unknown option: $1"
            return 1
            ;;
        esac
    done
    if [[ ! -d "$dir" ]]; then
        console.error "Directory does not exist: $dir"
        return 1
    fi
    local find_cmd="find \"$dir\" -maxdepth 1"
    if [[ -n "$type_filter" ]]; then
        case "$type_filter" in
        "file" | "f") find_cmd="$find_cmd -type f" ;;
        "directory" | "dir" | "d") find_cmd="$find_cmd -type d" ;;
        *) console.error "Invalid type filter: $type_filter (use: file, directory)" ;;
        esac
    fi
    if [[ -n "$pattern" ]]; then
        find_cmd="$find_cmd -name \"$pattern\""
    fi
    local count=0
    while IFS= read -r -d '' item; do
        if [[ "$item" == "$dir" ]]; then continue; fi
        local type="file"
        if [[ -d "$item" ]]; then type="directory"; fi
        if [[ "$long_format" == "true" ]]; then
            directory.__display_long "$item" "$type"
            echo
        else
            directory.__display_simple "$item" "$type"
        fi
        ((count++))
        if [[ $count -ge $max_results ]]; then break; fi
    done < <(eval "$find_cmd -print0" 2>/dev/null)
    echo "items in $dir"
    if [[ $count -eq 0 ]]; then
        console.info "No items found in directory: $dir"
    else
        console.success "Found $count items in directory: $dir"
    fi
}

##
## (Usage) Search for files and directories recursively
## Examples:
##   directory.search ~/Documents "*.txt"
##   directory.search ~/Documents "config" --type=file --depth=5
##   directory.search ~/Documents "*.log" --size=+1M --max=20
##
function directory.search() {
    local search_dir="${1:-.}"
    local pattern="${2:-*}"
    local max_depth="$__DIR__DEFAULT_DEPTH"
    local type_filter=""
    local long_format=false

    # Parse options
    shift 2
    while [[ $# -gt 0 ]]; do
        case "$1" in
        --depth | -d)
            max_depth="$2"
            shift 2
            ;;
        --type | -t)
            type_filter="$2"
            shift 2
            ;;
        --long | -l)
            long_format=true
            shift
            ;;
        *)
            console.error "Unknown option: $1"
            return 1
            ;;
        esac
    done

    # Validate directory
    if [[ ! -d "$search_dir" ]]; then
        console.error "Search directory does not exist: $search_dir"
        return 1
    fi

    # Build find command
    local find_cmd="find \"$search_dir\" -maxdepth $max_depth -name \"$pattern\""

    # Add type filter
    if [[ -n "$type_filter" ]]; then
        case "$type_filter" in
        "file" | "f") find_cmd="$find_cmd -type f" ;;
        "directory" | "dir" | "d") find_cmd="$find_cmd -type d" ;;
        *) console.error "Invalid type filter: $type_filter" ;;
        esac
    fi

    # Execute search
    local count=0
    while IFS= read -r -d '' item; do
        # Determine type
        local type="file"
        if [[ -d "$item" ]]; then
            type="directory"
        fi

        # Display based on format
        if [[ "$long_format" == "true" ]]; then
            directory.__display_long "$item" "$type"
            echo
        else
            echo "$item"
        fi

        ((count++))
    done < <(eval "$find_cmd -print0" 2>/dev/null)

    if [[ $count -eq 0 ]]; then
        console.info "No items found matching pattern '$pattern' in $search_dir"
    else
        echo "items matching $pattern"
        console.success "Found $count items matching pattern '$pattern'"
    fi
}

##
## (Usage) Remove files and directories
## Examples:
##   directory.remove ~/temp/file.txt
##   directory.remove ~/temp/dir --recursive
##   directory.remove ~/temp --pattern="*.tmp" --force
##
function directory.remove() {
    local target="$1"
    local recursive=false
    local force=false
    shift
    while [[ $# -gt 0 ]]; do
        case "$1" in
        --recursive | -r)
            recursive=true
            shift
            ;;
        --force | -f)
            force=true
            shift
            ;;
        *)
            console.error "Unknown option: $1"
            return 1
            ;;
        esac
    done
    if [[ -z "$target" ]]; then
        console.error "No target specified"
        return 1
    fi
    if [[ ! -e "$target" ]]; then
        console.error "Target does not exist: $target"
        return 1
    fi
    local was_file=0
    if [[ -f "$target" ]]; then was_file=1; fi
    local was_dir=0
    if [[ -d "$target" ]]; then was_dir=1; fi
    local rm_cmd="rm"
    if [[ "$recursive" == "true" ]]; then rm_cmd="rm -r"; fi
    if [[ "$force" == "true" ]]; then rm_cmd="$rm_cmd -f"; fi
    if [[ $was_dir -eq 1 && "$force" != "true" ]]; then
        console.warn "Removing directory: $target"
        read -p "Are you sure? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            console.info "Operation cancelled"
            return 0
        fi
    fi
    if eval "$rm_cmd \"$target\"" 2>/dev/null; then
        if [[ $was_file -eq 1 ]]; then
            echo "Removed file: $target"
        else
            echo "Removed directory: $target"
        fi
        console.success "Removed successfully: $target"
    else
        console.error "Failed to remove: $target"
        return 1
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
    local recursive=false
    local preserve_attributes=false
    shift 2
    while [[ $# -gt 0 ]]; do
        case "$1" in
        --recursive | -r)
            recursive=true
            shift
            ;;
        --preserve | -p)
            preserve_attributes=true
            shift
            ;;
        *)
            console.error "Unknown option: $1"
            return 1
            ;;
        esac
    done
    if [[ -z "$source" || -z "$destination" ]]; then
        console.error "Source and destination must be specified"
        return 1
    fi
    if [[ ! -e "$source" ]]; then
        console.error "Source does not exist: $source"
        return 1
    fi
    # If destination ends with /, treat as directory
    if [[ "$destination" == */ ]]; then
        mkdir -p "$destination" || {
            console.error "Failed to create destination directory: $destination"
            return 1
        }
        local cp_cmd="cp"
        if [[ "$recursive" == "true" ]]; then cp_cmd="cp -r"; fi
        if [[ "$preserve_attributes" == "true" ]]; then cp_cmd="$cp_cmd -p"; fi
        if eval "$cp_cmd \"$source\" \"$destination\"" 2>/dev/null; then
            echo "Copied: $source -> $destination"
            console.success "Copied successfully: $source -> $destination"
        else
            console.error "Failed to copy: $source -> $destination"
            return 1
        fi
    else
        # If destination does not exist, but is intended as a directory, create it
        if [[ -d "$destination" ]]; then
            local cp_cmd="cp"
            if [[ "$recursive" == "true" ]]; then cp_cmd="cp -r"; fi
            if [[ "$preserve_attributes" == "true" ]]; then cp_cmd="$cp_cmd -p"; fi
            if eval "$cp_cmd \"$source\" \"$destination\"" 2>/dev/null; then
                echo "Copied: $source -> $destination"
                console.success "Copied successfully: $source -> $destination"
            else
                console.error "Failed to copy: $source -> $destination"
                return 1
            fi
        else
            # If destination is a file path, ensure parent dir exists
            local dest_dir="$(dirname "$destination")"
            if [[ ! -d "$dest_dir" ]]; then
                mkdir -p "$dest_dir" || {
                    console.error "Failed to create destination directory: $dest_dir"
                    return 1
                }
            fi
            local cp_cmd="cp"
            if [[ "$recursive" == "true" ]]; then cp_cmd="cp -r"; fi
            if [[ "$preserve_attributes" == "true" ]]; then cp_cmd="$cp_cmd -p"; fi
            if eval "$cp_cmd \"$source\" \"$destination\"" 2>/dev/null; then
                echo "Copied: $source -> $destination"
                console.success "Copied successfully: $source -> $destination"
            else
                console.error "Failed to copy: $source -> $destination"
                return 1
            fi
        fi
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
        console.error "Source and destination must be specified"
        return 1
    fi

    if [[ ! -e "$source" ]]; then
        console.error "Source does not exist: $source"
        return 1
    fi

    # Execute move
    if mv "$source" "$destination" 2>/dev/null; then
        echo "Moved: $source -> $destination"
        console.success "Moved successfully: $source -> $destination"
    else
        console.error "Failed to move: $source -> $destination"
        return 1
    fi
}

##
## (Usage) Create directories
## Examples:
##   directory.create ~/new/directory
##   directory.create ~/new/dir --parents
##
function directory.create() {
    local dir="$1"
    local create_parents=false

    # Parse options
    shift
    while [[ $# -gt 0 ]]; do
        case "$1" in
        --parents | -p)
            create_parents=true
            shift
            ;;
        *)
            console.error "Unknown option: $1"
            return 1
            ;;
        esac
    done

    if [[ -z "$dir" ]]; then
        console.error "No directory path specified"
        return 1
    fi

    # Check if directory already exists
    if [[ -d "$dir" ]]; then
        console.info "Directory already exists: $dir"
        return 0
    fi

    # Create directory
    local mkdir_cmd="mkdir"
    if [[ "$create_parents" == "true" ]]; then
        mkdir_cmd="mkdir -p"
    fi

    if eval "$mkdir_cmd \"$dir\"" 2>/dev/null; then
        echo "Created directory: $dir"
        console.success "Directory created successfully: $dir"
    else
        console.error "Failed to create directory: $dir"
        return 1
    fi
}

##
## (Usage) Get file/directory information
## Examples:
##   directory.info ~/file.txt
##   directory.info ~/directory --detailed
##
function directory.info() {
    local target="${1:-.}"
    local detailed=false

    # Parse options
    shift
    while [[ $# -gt 0 ]]; do
        case "$1" in
        --detailed | -d)
            detailed=true
            shift
            ;;
        *)
            console.error "Unknown option: $1"
            return 1
            ;;
        esac
    done

    if [[ ! -e "$target" ]]; then
        console.error "Target does not exist: $target"
        return 1
    fi

    echo "File Information"
    echo "================"
    echo "Name: $(basename "$target")"
    echo "Path: $(realpath "$target")"
    echo "Type: $(if [[ -d "$target" ]]; then echo "Directory"; else echo "File"; fi)"

    if [[ "$detailed" == "true" ]]; then
        local size=$(du -sh "$target" 2>/dev/null | cut -f1)
        local permissions=$(stat -c "%a" "$target" 2>/dev/null || stat -f "%Lp" "$target" 2>/dev/null)
        local owner=$(stat -c "%U" "$target" 2>/dev/null || stat -f "%Su" "$target" 2>/dev/null)
        local group=$(stat -c "%G" "$target" 2>/dev/null || stat -f "%Sg" "$target" 2>/dev/null)
        local modified=$(stat -c "%y" "$target" 2>/dev/null || stat -f "%Sm" "$target" 2>/dev/null)
        local inode=$(stat -c "%i" "$target" 2>/dev/null || stat -f "%i" "$target" 2>/dev/null)

        echo "Size: $size"
        echo "Permissions: $(directory.__permissions_to_description "$permissions")"
        echo "Owner: $owner"
        echo "Group: $group"
        echo "Modified: $modified"
        echo "Inode: $inode"

        if [[ -d "$target" ]]; then
            local file_count=$(find "$target" -maxdepth 1 -type f | wc -l)
            local dir_count=$(find "$target" -maxdepth 1 -type d | wc -l)
            echo "Contents: $file_count files, $((dir_count - 1)) subdirectories"
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
    local target="${1:-.}"
    local human_readable=true

    # Parse options
    shift
    while [[ $# -gt 0 ]]; do
        case "$1" in
        --bytes | -b)
            human_readable=false
            shift
            ;;
        *)
            console.error "Unknown option: $1"
            return 1
            ;;
        esac
    done

    if [[ ! -e "$target" ]]; then
        console.error "Target does not exist: $target"
        return 1
    fi

    local size
    if [[ "$human_readable" == "true" ]]; then
        size=$(du -sh "$target" 2>/dev/null | cut -f1)
        echo "Directory size: $size"
    else
        size=$(du -sb "$target" 2>/dev/null | cut -f1)
        echo "Directory size: ${size} bytes"
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
    local search_dir="${1:-.}"
    local max_depth=1
    if [[ -n "$__DIR__DEFAULT_DEPTH" ]]; then
        max_depth="$__DIR__DEFAULT_DEPTH"
    fi
    shift
    while [[ $# -gt 0 ]]; do
        case "$1" in
        --depth | -d)
            max_depth="$2"
            shift 2
            ;;
        --files | -f) : ;; # always search for files now
        *)
            console.error "Unknown option: $1"
            return 1
            ;;
        esac
    done
    if [[ ! -d "$search_dir" ]]; then
        console.error "Search directory does not exist: $search_dir"
        return 1
    fi
    local count=0
    while IFS= read -r -d '' dir; do
        if [[ -z "$(ls -A "$dir" 2>/dev/null)" ]]; then
            echo "📁 Empty directory: $dir"
            ((count++))
        fi
    done < <(find "$search_dir" -maxdepth "$max_depth" -type d -print0 2>/dev/null)
    while IFS= read -r -d '' file; do
        if [[ ! -s "$file" ]]; then
            echo "📄 Empty file: $file"
            ((count++))
        fi
    done < <(find "$search_dir" -maxdepth "$max_depth" -type f -print0 2>/dev/null)
    echo "empty items found"
    if [[ $count -gt 0 ]]; then
        console.success "Found $count empty items"
    fi
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
    local item="$1"
    local type="$2"
    if [[ -d "$item" ]]; then
        echo "📁 $item"
    elif [[ -L "$item" ]]; then
        echo "🔗 $item"
    else
        echo "📄 $item"
    fi
}

function directory.__display_long() {
    local item="$1"
    local type="$2"
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
}

##
## (Usage) Set default search depth
## Examples:
##   directory.set_depth 5
##
function directory.set_depth() {
    local depth="$1"

    if [[ -z "$depth" ]]; then
        console.error "No depth value specified"
        return 1
    fi

    if [[ ! "$depth" =~ ^[0-9]+$ ]]; then
        console.error "Depth must be a positive integer"
        return 1
    fi

    __DIR__DEFAULT_DEPTH="$depth"
    echo "Default search depth set to $depth"
    console.success "Default search depth set to $depth"
}

##
## (Usage) Set default max results
## Examples:
##   directory.set_max_results 50
##
function directory.set_max_results() {
    local max="$1"

    if [[ -z "$max" ]]; then
        console.error "No maximum value specified"
        return 1
    fi

    if [[ ! "$max" =~ ^[0-9]+$ ]]; then
        console.error "Maximum must be a positive integer"
        return 1
    fi

    __DIR__DEFAULT_MAX_RESULTS="$max"
    echo "Default max results set to $max"
    console.success "Default max results set to $max"
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

export BASH_LIB_IMPORTED_directory="1"
