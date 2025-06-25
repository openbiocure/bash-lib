#!/bin/bash

# Math Exceptions Module for bash-lib
# Provides math-specific exception handling

# Module import signal using scoped naming
export BASH_LIB_IMPORTED_mathExceptions="1"

# Call import.meta.loaded if the function exists
if command -v import.meta.loaded >/dev/null 2>&1; then
    import.meta.loaded "mathExceptions" "${BASH__PATH:-/opt/bash-lib}/modules/math/mathExceptions.mod.sh" "1.0.0" 2>/dev/null || true
fi

import exceptionBase

function math.exception.arithmeticComputation(){
     exceptionBase.throw "Failed to perform an arithmetic computation";
}