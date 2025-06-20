# bash-lib Manual

A comprehensive bash library providing modular utilities for common shell operations.

## Table of Contents

- [Modules](#modules)
- [Compressions](#compressions)
- [Date](#date)
- [Directory](#directory)
- [Http](#http)
- [Kernel](#kernel)
- [Math](#math)
- [Utils](#utils)

## Installation

```bash
# Clone the repository
git clone <repository-url>
cd bash-lib

# Install dependencies
make install-deps

# Install bash-lib
make install
```

## Usage

```bash
# Source the library
export BASH__PATH="/path/to/bash-lib"
source core/init.sh

# Import a module
import directory
import http
import math

# Use the functions
directory.create /tmp/test
http.get https://api.example.com
math.add 5 3
```

## Modules

### Modules

```bash
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
```

### Compressions

No help function available for this module.

### Date

No help function available for this module.

### Directory

```bash
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
```

### Http

```bash
HTTP Module - Comprehensive HTTP client for bash-lib

Available Functions:
  http.get <url> [options]           - Perform GET request
  http.post <url> [options]          - Perform POST request
  http.put <url> [options]           - Perform PUT request
  http.delete <url> [options]        - Perform DELETE request
  http.download <url> <path> [opts]  - Download file with retries
  http.check <url> [options]         - Check if URL is accessible
  http.status <url>                  - Get HTTP status code
  http.is_404 <url>                  - Check if URL returns 404
  http.is_200 <url>                  - Check if URL returns 200
  http.headers <url> [options]       - Get response headers
  http.set_timeout <seconds>         - Set default timeout
  http.set_retries <count>           - Set default retry count
  http.help                          - Show this help

Options:
  --timeout=<seconds>     - Request timeout (default: 30)
  --retries=<count>       - Download retry count (default: 3)
  --header="key:value"    - Add HTTP header
  --data="content"        - POST/PUT data
  --data-urlencode="k=v"  - URL-encoded form data
  --insecure             - Skip SSL verification
  --show-status          - Include HTTP status in output

Examples:
  http.get https://api.example.com/data
  http.post https://api.example.com/submit --data='{"key":"value"}'
  http.download https://example.com/file.zip /tmp/file.zip
  http.check https://example.com
  if http.is_200 https://example.com; then echo "Site is up"; fi
```

### Kernel

No help function available for this module.

### Math

No help function available for this module.

### Utils

No help function available for this module.


## Contributing

1. Fork the repository
2. Create a feature branch
3. Add your module or improvements
4. Write tests for your changes
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

---

*Generated automatically by manual.sh*
