#!/bin/bash

# Compressions Module for bash-lib
# Provides file compression and extraction utilities

# Call import.meta.loaded if the function exists
if command -v import.meta.loaded >/dev/null 2>&1; then
    import.meta.loaded "compression" "${BASH__PATH:-/opt/bash-lib}/modules/compressions/compression.mod.sh" "1.0.0" 2>/dev/null || true
fi

import console
import string
import directory
import exceptionBase

[[ $BASH__DEBUG && $(basename "$ENTRY__POINT") == "$(basename $0)" ]] && source ./lib/init.sh

##
## (Usage)
##  Un compresses a file
##
compression.uncompress() {

    local file="$1"
    local destination="$2"

    if [[ ! $(string.isEmpty "$file") == false ]]; then
        console.warn "src is required"
        return 1
    fi

    if [[ ! $(string.isEmpty "${destination}") == false ]]; then
        console.warn "destination is required"
        return 1
    fi

    if [[ -d ${destination} ]]; then
        console.warn "[$destination] directory is already available, removing directory"
        directory.destory $destination
    fi

    command="unzip ${file} -d ${destination}"

    console.debug "${command}"

    ## redirect the stderr to stout
    ## in case we get an error
    ## add it to the exception message;
    result=$(${command} 2>&1)

    if [[ $? == 0 ]]; then
        console.log "Successfully extracted ${file} to ${destination}"
        return 1
    fi

    exceptionBase.throw $result
}

##
## (Usage)
##  Compresses a file
##
compression.compress() {
    zip "$1" "$2"
}

##
## (Usage) Extract a tar archive
##
compression.untar() {
    local archive="$1"
    local destination="$2"
    if [[ -z "$archive" ]]; then
        console.error "Archive file is required"
        return 1
    fi
    if [[ -z "$destination" ]]; then
        destination="."
    fi
    tar -xf "$archive" -C "$destination"
}

##
## (Usage) Create a tar archive
##
compression.tar() {
    local archive="$1"
    shift
    if [[ -z "$archive" || $# -eq 0 ]]; then
        console.error "Usage: compression.tar <archive.tar> <files...>"
        return 1
    fi
    tar -cf "$archive" "$@"
}

##
## (Usage) Compress a file with gzip
##
compression.gzip() {
    local file="$1"
    if [[ -z "$file" ]]; then
        console.error "File is required"
        return 1
    fi
    gzip -v "$file"
}

##
## (Usage) Decompress a gzip file
##
compression.gunzip() {
    local file="$1"
    if [[ -z "$file" ]]; then
        console.error "File is required"
        return 1
    fi
    gunzip -v "$file"
}

##
## (Usage) Create a zip archive
##
compression.zip() {
    local archive="$1"
    shift
    if [[ -z "$archive" || $# -eq 0 ]]; then
        console.error "Usage: compression.zip <archive.zip> <files...>"
        return 1
    fi
    zip "$archive" "$@"
}

##
## (Usage) Extract a zip archive (alias for uncompress)
##
compression.unzip() {
    compression.uncompress "$@"
}

##
## (Usage) Show compression module help
##
function compression.help() {
    cat <<EOF
Compression Module - File compression and extraction utilities

Available Functions:
  compression.uncompress <file> <destination>  - Extract zip files
  compression.compress <source> <destination>  - Compress files to zip
  compression.tar <archive.tar> <files...>     - Create a tar archive
  compression.untar <archive.tar> [dest]       - Extract a tar archive
  compression.gzip <file>                      - Compress a file with gzip
  compression.gunzip <file.gz>                 - Decompress a gzip file
  compression.zip <archive.zip> <files...>     - Create a zip archive
  compression.unzip <archive.zip> <dest>       - Extract a zip archive
  compression.help                             - Show this help

Examples:
  compression.uncompress archive.zip /tmp/extracted
  compression.compress file.txt archive.zip
  compression.tar archive.tar file1.txt dir/
  compression.untar archive.tar /tmp/extracted
  compression.gzip file.txt
  compression.gunzip file.txt.gz
  compression.zip archive.zip file1.txt dir/
  compression.unzip archive.zip /tmp/extracted
EOF
}

# Module import signal using scoped naming
export BASH_LIB_IMPORTED_compression="1"
