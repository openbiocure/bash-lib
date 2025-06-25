#!/bin/bash

# Exception Base Module for bash-lib
# Provides base exception handling functionality

# Module import signal using scoped naming
export BASH_LIB_IMPORTED_exceptionBase="1"

# Call import.meta.loaded if the function exists
if command -v import.meta.loaded >/dev/null 2>&1; then
    import.meta.loaded "exceptionBase" "${BASH__PATH:-/opt/bash-lib}/core/exceptions/exceptionBase.mod.sh" "1.0.0" 2>/dev/null || true
fi

import console

function exceptionBase.throw() {
    kill -10 $$
}
