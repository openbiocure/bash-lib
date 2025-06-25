#!/bin/bash

## bash asci banner openner

# Logo Module for bash-lib
# Provides ASCII art and branding functionality

# Module import signal using scoped naming
export BASH_LIB_IMPORTED_logo="1"

# Call import.meta.loaded if the function exists
if command -v import.meta.loaded >/dev/null 2>&1; then
    import.meta.loaded "logo" "${BASH__PATH:-/opt/bash-lib}/core/logo.mod.sh" "1.0.0" 2>/dev/null || true
fi

import console;

echo -e """

██████╗  █████╗ ███████╗██╗  ██╗    ██╗     ██╗██████╗ ██████╗  █████╗ ██████╗ ██╗   ██╗
██╔══██╗██╔══██╗██╔════╝██║  ██║    ██║     ██║██╔══██╗██╔══██╗██╔══██╗██╔══██╗╚██╗ ██╔╝
██████╔╝███████║███████╗███████║    ██║     ██║██████╔╝██████╔╝███████║██████╔╝ ╚████╔╝ 
██╔══██╗██╔══██║╚════██║██╔══██║    ██║     ██║██╔══██╗██╔══██╗██╔══██║██╔══██╗  ╚██╔╝  
██████╔╝██║  ██║███████║██║  ██║    ███████╗██║██████╔╝██║  ██║██║  ██║██║  ██║   ██║   
╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝    ╚══════╝╚═╝╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   
                                                                                        

""" 1>&3


