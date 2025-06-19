#!/bin/bash
##
## (Usage) import modulename if your adding and include item
##         you can use import config inc to mark its an inc extension
##  
## Allows you include libraries
function import () {

  local src=${BASH__PATH:-"/opt/bash-lib"};
  local extension=$([[ -z ${2} ]]  && echo "mod.sh" || echo "inc");

  if [[ ! -d ${src} ]]; then
      echo -e "\e[31mWarning: \e[0m Bash Path is not set or directory doesn't exist: \e[1m${src}\e[0m"
      echo -e "Set it with: \e[1mexport BASH__PATH=/opt/bash-lib\e[0m"
      return 1;
  fi

  local module=$(find ${src} -name "${1}.${extension}" 2>/dev/null)
  if [[  -f ${module} ]]; then
    source ${module}
    if [[ -z ${IMPORTED} ]]; then
      echo -e "\e[31mError:\e[0m Failed to load \e[1m${1}.${extension}\e[0m at ${src}";
      return 2;
    fi
  else
    echo -e "\e[31mError: \e[0mCannot find \e[1m${1}\e[0m library inside: ${src}";
    return 3;
  fi
}

# Import required modules for initialization (only if BASH__PATH is set)
if [[ -n "${BASH__PATH}" ]] && [[ -d "${BASH__PATH}" ]]; then
    # Source build configuration for version info
    if [[ -f "${BASH__PATH}/config/build.inc" ]]; then
        source "${BASH__PATH}/config/build.inc"
    fi
    
    import trapper 2>/dev/null && trapper.addTrap 'exit 1;' 10 
    import console 2>/dev/null
    
    [[ -z ${BASH__VERBOSE} ]] &&  export BASH__VERBOSE=info || export BASH__VERBOSE=${BASH__VERBOSE};
    
    # Only use console.debug if console module was successfully imported
    if command -v console.debug >/dev/null 2>&1; then
        console.debug "Verbosity:  ${BASH__VERBOSE} ";
        console.debug "Version : ${BASH__RELEASE} ";
    fi
else
    echo -e "\e[33mInfo: \e[0mBash-lib not fully initialized. Set \e[1mBASH__PATH\e[0m to enable all features."
fi


