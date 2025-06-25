#!/bin/bash

# Engine Module for bash-lib
# Core engine functionality

# Module import signal using scoped naming
export BASH_LIB_IMPORTED_engine="1"

# Call import.meta.loaded if the function exists
if command -v import.meta.loaded >/dev/null 2>&1; then
    import.meta.loaded "engine" "${BASH__PATH:-/opt/bash-lib}/core/engine.mod.sh" "1.0.0" 2>/dev/null || true
fi

import console

##  (Usage)
##      List all available modules on the terminal
##
function engine.modules() {
    modules=$(ls ${BASH__PATH}/modules | sed "s/.mod.*//g")
    for m in $modules; do
         console.log "${BWhite}$m" && \
         [[  -z $( type "${m}.help" 2> /dev/null) ]] && console.warn "No Help Provided for the module ${m}" || eval "${m}.help";
    done
}
