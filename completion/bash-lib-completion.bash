#!/bin/bash

# bash-lib completion script
# Provides autocomplete for all bash-lib modules and functions

_bash_lib_completion() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    # Get the command being completed
    local cmd="${COMP_WORDS[0]}"
    
    # If this is the first word, suggest bash-lib commands
    if [[ $COMP_CWORD -eq 1 ]]; then
        local commands="import import.force import.meta.all import.meta.info import.meta.reload"
        COMPREPLY=( $(compgen -W "$commands" -- "$cur") )
        return 0
    fi
    
    # Handle import command
    if [[ "$cmd" == "import" ]]; then
        case $COMP_CWORD in
            2)
                # Suggest available modules
                local modules="console trapper engine colors file directory string math date http user permission compression process"
                COMPREPLY=( $(compgen -W "$modules" -- "$cur") )
                ;;
            3)
                # Suggest extensions
                if [[ "$prev" == "colors" ]]; then
                    COMPREPLY=( $(compgen -W "inc" -- "$cur") )
                else
                    COMPREPLY=( $(compgen -W "mod.sh" -- "$cur") )
                fi
                ;;
        esac
        return 0
    fi
    
    # Handle import.force command
    if [[ "$cmd" == "import.force" ]]; then
        if [[ $COMP_CWORD -eq 2 ]]; then
            local modules="console trapper engine colors file directory string math date http user permission compression process"
            COMPREPLY=( $(compgen -W "$modules" -- "$cur") )
        fi
        return 0
    fi
    
    # Handle import.meta.info command
    if [[ "$cmd" == "import.meta.info" ]]; then
        if [[ $COMP_CWORD -eq 2 ]]; then
            local modules="console trapper engine colors file directory string math date http user permission compression process"
            COMPREPLY=( $(compgen -W "$modules" -- "$cur") )
        fi
        return 0
    fi
    
    # Handle module-specific completions
    if [[ "$cmd" =~ ^(console|file|directory|string|math|date|http|user|permission|compression|process|trapper)\. ]]; then
        local module="${cmd%%.*}"
        local function_name="${cmd#*.}"
        
        case "$module" in
            console)
                if [[ $COMP_CWORD -eq 1 ]]; then
                    local functions="log info debug trace warn error fatal success set_verbosity get_verbosity set_time_format help"
                    COMPREPLY=( $(compgen -W "$functions" -- "$function_name") )
                fi
                ;;
            file)
                if [[ $COMP_CWORD -eq 1 ]]; then
                    local functions="create read write list search stats copy move delete help"
                    COMPREPLY=( $(compgen -W "$functions" -- "$function_name") )
                elif [[ $COMP_CWORD -eq 2 ]]; then
                    # Suggest file paths
                    COMPREPLY=( $(compgen -f -- "$cur") )
                elif [[ $COMP_CWORD -eq 3 ]]; then
                    case "${COMP_WORDS[1]}" in
                        create)
                            local options="--content --executable -x --overwrite -f"
                            COMPREPLY=( $(compgen -W "$options" -- "$cur") )
                            ;;
                        read)
                            local options="--lines --tail --grep --line-numbers -n"
                            COMPREPLY=( $(compgen -W "$options" -- "$cur") )
                            ;;
                        write)
                            local options="--overwrite -f --append -a"
                            COMPREPLY=( $(compgen -W "$options" -- "$cur") )
                            ;;
                        list)
                            local options="--pattern --size --modified --max --sort --reverse -r --details -l"
                            COMPREPLY=( $(compgen -W "$options" -- "$cur") )
                            ;;
                        search)
                            local options="--case-insensitive -i --context -C"
                            COMPREPLY=( $(compgen -W "$options" -- "$cur") )
                            ;;
                        copy)
                            local options="--preserve -p"
                            COMPREPLY=( $(compgen -W "$options" -- "$cur") )
                            ;;
                        delete)
                            local options="--recursive -r"
                            COMPREPLY=( $(compgen -W "$options" -- "$cur") )
                            ;;
                    esac
                fi
                ;;
            directory)
                if [[ $COMP_CWORD -eq 1 ]]; then
                    local functions="list search remove copy move create info size find_empty set_depth set_max_results help"
                    COMPREPLY=( $(compgen -W "$functions" -- "$function_name") )
                elif [[ $COMP_CWORD -eq 2 ]]; then
                    # Suggest directory paths
                    COMPREPLY=( $(compgen -d -- "$cur") )
                elif [[ $COMP_CWORD -eq 3 ]]; then
                    case "${COMP_WORDS[1]}" in
                        list)
                            local options="--all -a --long -l --type --pattern --max --sort --reverse -r"
                            COMPREPLY=( $(compgen -W "$options" -- "$cur") )
                            ;;
                        search)
                            local options="--depth --type --size --max --ignore-case -i"
                            COMPREPLY=( $(compgen -W "$options" -- "$cur") )
                            ;;
                        remove)
                            local options="--recursive -r --force -f --pattern"
                            COMPREPLY=( $(compgen -W "$options" -- "$cur") )
                            ;;
                        copy)
                            local options="--recursive -r --preserve -p"
                            COMPREPLY=( $(compgen -W "$options" -- "$cur") )
                            ;;
                        create)
                            local options="--parents -p"
                            COMPREPLY=( $(compgen -W "$options" -- "$cur") )
                            ;;
                    esac
                fi
                ;;
            string)
                if [[ $COMP_CWORD -eq 1 ]]; then
                    local functions="isEmpty replace length lower upper trim contains startswith endswith basename help"
                    COMPREPLY=( $(compgen -W "$functions" -- "$function_name") )
                fi
                ;;
            math)
                if [[ $COMP_CWORD -eq 1 ]]; then
                    local functions="add help"
                    COMPREPLY=( $(compgen -W "$functions" -- "$function_name") )
                fi
                ;;
            date)
                if [[ $COMP_CWORD -eq 1 ]]; then
                    local functions="now help"
                    COMPREPLY=( $(compgen -W "$functions" -- "$function_name") )
                fi
                ;;
            http)
                if [[ $COMP_CWORD -eq 1 ]]; then
                    local functions="get post put delete download check status is_404 is_200 headers set_timeout set_retries help"
                    COMPREPLY=( $(compgen -W "$functions" -- "$function_name") )
                elif [[ $COMP_CWORD -eq 2 ]]; then
                    # Suggest URLs
                    COMPREPLY=( $(compgen -W "https:// http://" -- "$cur") )
                elif [[ $COMP_CWORD -eq 3 ]]; then
                    case "${COMP_WORDS[1]}" in
                        get|post|put|delete)
                            local options="--timeout --retries --header --data --data-urlencode --insecure --show-status"
                            COMPREPLY=( $(compgen -W "$options" -- "$cur") )
                            ;;
                        download)
                            local options="--timeout --retries"
                            COMPREPLY=( $(compgen -W "$options" -- "$cur") )
                            ;;
                    esac
                fi
                ;;
            user)
                if [[ $COMP_CWORD -eq 1 ]]; then
                    local functions="create delete create_group delete_group add_to_group remove_from_group list list_groups info set_password help"
                    COMPREPLY=( $(compgen -W "$functions" -- "$function_name") )
                elif [[ $COMP_CWORD -eq 2 ]]; then
                    case "${COMP_WORDS[1]}" in
                        create|delete|info|set_password)
                            # Suggest usernames
                            COMPREPLY=( $(compgen -u -- "$cur") )
                            ;;
                        create_group|delete_group|add_to_group|remove_from_group)
                            # Suggest group names
                            COMPREPLY=( $(compgen -g -- "$cur") )
                            ;;
                        list|list_groups)
                            local options="--system-only --regular-only"
                            COMPREPLY=( $(compgen -W "$options" -- "$cur") )
                            ;;
                    esac
                fi
                ;;
            permission)
                if [[ $COMP_CWORD -eq 1 ]]; then
                    local functions="set set_symbolic own get set_recursive own_recursive make_executable secure public_read help"
                    COMPREPLY=( $(compgen -W "$functions" -- "$function_name") )
                elif [[ $COMP_CWORD -eq 2 ]]; then
                    # Suggest file paths
                    COMPREPLY=( $(compgen -f -- "$cur") )
                fi
                ;;
            compression)
                if [[ $COMP_CWORD -eq 1 ]]; then
                    local functions="uncompress compress tar untar gzip gunzip zip unzip help"
                    COMPREPLY=( $(compgen -W "$functions" -- "$function_name") )
                elif [[ $COMP_CWORD -eq 2 ]]; then
                    # Suggest file paths
                    COMPREPLY=( $(compgen -f -- "$cur") )
                fi
                ;;
            process)
                if [[ $COMP_CWORD -eq 1 ]]; then
                    local functions="list count find top_cpu top_mem help"
                    COMPREPLY=( $(compgen -W "$functions" -- "$function_name") )
                elif [[ $COMP_CWORD -eq 2 ]]; then
                    case "${COMP_WORDS[1]}" in
                        list)
                            local options="-l --limit --no-log --format"
                            COMPREPLY=( $(compgen -W "$options" -- "$cur") )
                            ;;
                        find|top_cpu|top_mem)
                            # These take process names or numbers
                            COMPREPLY=( $(compgen -W "1 5 10 20" -- "$cur") )
                            ;;
                    esac
                fi
                ;;
            trapper)
                if [[ $COMP_CWORD -eq 1 ]]; then
                    local functions="addTrap addModuleTrap removeTrap removeModuleTraps getTraps filterTraps list clear setupDefaults tempFile tempDir help"
                    COMPREPLY=( $(compgen -W "$functions" -- "$function_name") )
                elif [[ $COMP_CWORD -eq 2 ]]; then
                    case "${COMP_WORDS[1]}" in
                        addModuleTrap|removeModuleTraps)
                            local modules="console trapper engine colors file directory string math date http user permission compression process"
                            COMPREPLY=( $(compgen -W "$modules" -- "$cur") )
                            ;;
                        list|clear)
                            local options="--module --verbose -v"
                            COMPREPLY=( $(compgen -W "$options" -- "$cur") )
                            ;;
                    esac
                fi
                ;;
        esac
    fi
    
    return 0
}

# Register the completion function
complete -F _bash_lib_completion import import.force import.meta.all import.meta.info import.meta.reload
complete -F _bash_lib_completion console. file. directory. string. math. date. http. user. permission. compression. process. trapper. 