![bash](./assets/bash.png)

#  Bash Library

>> Let's be honest; bash for developers is not that straightforward. And that's exactly why I made the bash library.

>>How many of you wish you can use console.log inside a terminal instead of echo Hello world? If you are one, you should check this out.

[![asciicast](https://asciinema.org/a/xsWFcHG0hrFnKAvhrubClsq6n.svg)](https://asciinema.org/a/xsWFcHG0hrFnKAvhrubClsq6n)

A Core library for bash Bourne with modular architecture

## Quick Setup

To quickly set up the `bash-lib` library, run the following command:

```bash
curl -sSL https://raw.githubusercontent.com/openbiocure/bash-lib/main/install.sh -o /tmp/install.sh && bash /tmp/install.sh
```

This script will:
- Download the complete bash-lib repository structure
- Install it to `/opt/bash-lib`
- Modify your shell profile to source the library automatically
- Source the library in the current session

## Un Installation

```bash
curl -sSL https://raw.githubusercontent.com/openbiocure/bash-lib/main/install.sh -o /tmp/install.sh && bash /tmp/install.sh uninstall
```

## Development

```bash
git clone https://github.com/openbiocure/bash-lib && \
cd bash-lib && \
make install
```

## Using the Library

### Importing Modules

The library uses a modular approach. Import only the modules you need:

```bash
import console  # Load the console module
import http     # Load the HTTP module
import math     # Load the math module
```

### Using Modules

Once a module is loaded, you can use its functions:

```bash
# Console logging
console.log "Hello world!"
# Output: 19/06/2025 09:13:51 - workernode04 - bash - [LOG]: Hello world!

# HTTP requests
http.get "https://httpbin.org/get"

# Math operations
math.add 5 3  # Returns 8
```

### One-liner Examples

```bash
# Import and use in one line
import http && http.get "https://api.example.com/data"

# Import multiple modules
import console && import http && console.log "Making request..." && http.get "https://example.com"
```

### Available Modules

List all available modules:

```bash
engine.modules
```

### Unloading Modules

Remove a module from memory:

```bash
unset console
```

## Make Targets

The project includes several make targets for development:

```bash
make          # Show help
make build    # Build the merged script file
make install  # Build and install locally
make test     # Run unit tests
make uninstall # Uninstall the library
make clean    # Remove build artifacts
```

## Configuration

| Variable | Description |
|:--- | :--- |
| `BASH__PATH`| The root location of the library (default: `/opt/bash-lib`) |
| `BASH__VERBOSE`| Log verbosity level: `TRACE`, `DEBUG`, `INFO`, `WARN`, or `ERROR`. Default is `TRACE` |

## Naming Conventions

| Convention | Description |
|:--- | :--- |
| Class level variables in modules | `BASHLIB__MODULENAME__VARIABLE__NAME` |
| Environment Scope | `VARIABLE__NAME` |

## Debugging

Enable bash debugging:

```bash
set -x  # Turn on debugging
# ... your code ...
set +x  # Turn off debugging
```

Check bash-lib environment variables:

```bash
env | sed "s/=.*//" | grep BASH
# Example output:
# BASH__PATH
# BASH__VERBOSE
```

## Unit Testing

The library uses [shellspec](https://github.com/shellspec/shellspec) for unit testing. All test cases are stored in the `spec` directory.

```bash
make test     # Run all tests
make all      # Alternative way to run tests
```

## Architecture

The library follows a modular architecture:

```
/opt/bash-lib/
├── core/           # Core functionality (import, engine, etc.)
├── modules/        # Feature modules (http, console, math, etc.)
├── config/         # Configuration files
└── spec/          # Unit tests
```

## Contribute

Looking for ways to contribute?

```bash
egrep -Rin "TODO|FIXME" -R *
```

## Change log

See the complete [changelog](CHANGELOG.md)
