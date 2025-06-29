#!/bin/bash

# bash-lib completion - Simple version
# Source this file to enable autocomplete for bash-lib

# Available modules
BASH_LIB_MODULES="console trapper engine colors file directory string math date http user permission compression process"

# Console functions
CONSOLE_FUNCTIONS="log info debug trace warn error fatal success set_verbosity get_verbosity set_time_format help"

# File functions
FILE_FUNCTIONS="create read write list search stats copy move delete help"

# Directory functions
DIRECTORY_FUNCTIONS="list search remove copy move create info size find_empty set_depth set_max_results help"

# String functions
STRING_FUNCTIONS="isEmpty replace length lower upper trim contains startswith endswith basename help"

# Math functions
MATH_FUNCTIONS="add help"

# Date functions
DATE_FUNCTIONS="now help"

# HTTP functions
HTTP_FUNCTIONS="get post put delete download check status is_404 is_200 headers set_timeout set_retries help"

# User functions
USER_FUNCTIONS="create delete create_group delete_group add_to_group remove_from_group list list_groups info set_password help"

# Permission functions
PERMISSION_FUNCTIONS="set set_symbolic own get set_recursive own_recursive make_executable secure public_read help"

# Compression functions
COMPRESSION_FUNCTIONS="uncompress compress tar untar gzip gunzip zip unzip help"

# Process functions
PROCESS_FUNCTIONS="list count find top_cpu top_mem help"

# Trapper functions
TRAPPER_FUNCTIONS="addTrap addModuleTrap removeTrap removeModuleTraps getTraps filterTraps list clear setupDefaults tempFile tempDir help"

# Import functions
IMPORT_FUNCTIONS="import import.force import.meta.all import.meta.info import.meta.reload"

# Completion function
_bash_lib_complete() {
    local cur prev
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    # Handle import commands
    if [[ "$prev" == "import" ]]; then
        COMPREPLY=( $(compgen -W "$BASH_LIB_MODULES" -- "$cur") )
        return 0
    fi
    
    if [[ "$prev" == "import.force" ]] || [[ "$prev" == "import.meta.info" ]]; then
        COMPREPLY=( $(compgen -W "$BASH_LIB_MODULES" -- "$cur") )
        return 0
    fi
    
    # Handle module.function patterns
    if [[ "$prev" =~ ^(console|file|directory|string|math|date|http|user|permission|compression|process|trapper)\. ]]; then
        local module="${prev%%.*}"
        case "$module" in
            console)
                COMPREPLY=( $(compgen -W "$CONSOLE_FUNCTIONS" -- "$cur") )
                ;;
            file)
                COMPREPLY=( $(compgen -W "$FILE_FUNCTIONS" -- "$cur") )
                ;;
            directory)
                COMPREPLY=( $(compgen -W "$DIRECTORY_FUNCTIONS" -- "$cur") )
                ;;
            string)
                COMPREPLY=( $(compgen -W "$STRING_FUNCTIONS" -- "$cur") )
                ;;
            math)
                COMPREPLY=( $(compgen -W "$MATH_FUNCTIONS" -- "$cur") )
                ;;
            date)
                COMPREPLY=( $(compgen -W "$DATE_FUNCTIONS" -- "$cur") )
                ;;
            http)
                COMPREPLY=( $(compgen -W "$HTTP_FUNCTIONS" -- "$cur") )
                ;;
            user)
                COMPREPLY=( $(compgen -W "$USER_FUNCTIONS" -- "$cur") )
                ;;
            permission)
                COMPREPLY=( $(compgen -W "$PERMISSION_FUNCTIONS" -- "$cur") )
                ;;
            compression)
                COMPREPLY=( $(compgen -W "$COMPRESSION_FUNCTIONS" -- "$cur") )
                ;;
            process)
                COMPREPLY=( $(compgen -W "$PROCESS_FUNCTIONS" -- "$cur") )
                ;;
            trapper)
                COMPREPLY=( $(compgen -W "$TRAPPER_FUNCTIONS" -- "$cur") )
                ;;
        esac
        return 0
    fi
    
    # Handle first word
    if [[ $COMP_CWORD -eq 1 ]]; then
        local all_commands="$IMPORT_FUNCTIONS"
        for module in $BASH_LIB_MODULES; do
            all_commands="$all_commands $module."
        done
        COMPREPLY=( $(compgen -W "$all_commands" -- "$cur") )
        return 0
    fi
    
    return 0
}

# Register completion for all bash-lib commands
complete -F _bash_lib_complete import import.force import.meta.all import.meta.info import.meta.reload
complete -F _bash_lib_complete console. file. directory. string. math. date. http. user. permission. compression. process. trapper.

echo "bash-lib completion loaded. Try: import <TAB> or file.<TAB>" 