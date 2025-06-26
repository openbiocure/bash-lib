# bash-lib Manual

A comprehensive bash library providing modular utilities for common shell operations.

## Summary

bash-lib is a modular shell scripting library that provides:

- **15+ modules** covering file operations, HTTP requests, user management, and more
- **Structured logging** with color-coded output and verbosity control
- **Error handling** with comprehensive signal trapping and cleanup
- **Developer-friendly APIs** that make shell scripting readable and maintainable
- **Auto-generated documentation** from built-in help functions
- **Cross-platform compatibility** with POSIX-compliant shell operations

## Table of Contents
- [Logo](#logo)
- [Engine](#engine)
- [File](#file)
- [Date](#date)
- [String](#string)
- [Directory](#directory)
- [Mathexceptions](#mathExceptions)
- [Math](#math)
- [Process](#process)
- [Console](#console)
- [Trapper](#trapper)
- [Http](#http)
- [User](#user)
- [Compression](#compression)
- [Permission](#permission)


## Installation

```sh
# Clone the repository
git clone <repository-url>
cd bash-lib

# Install dependencies
make install-deps

# Install bash-lib
make install
```

## Usage

```sh
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

### Logo

No help function available for this module.

### Engine

No help function available for this module.

### File

```sh
File Module - Comprehensive file management and manipulation utilities

Available Functions:
  file.create <path> [options]           - Create a new file with optional content
  file.read <path> [options]             - Read file content with various filters
  file.write <path> <content> [options]   - Write content to files
  file.list <path> [options]             - List files with filters and sorting
  file.search <path> <term> [options]     - Search for text in files
  file.stats <path> [options]             - Get file statistics and information
  file.copy <source> <dest> [options]     - Copy files with various options
  file.move <source> <dest>               - Move/rename files
  file.delete <path> [options]            - Delete files and directories
  file.help                                 - Show this help

Options:
  --content=<text>        - Content to write to file (file.create)
  --executable, -x         - Make file executable (file.create)
  --overwrite, -f          - Overwrite existing file (file.create, file.write)
  --append, -a             - Append content instead of overwrite (file.write)
  --lines=<n>              - Show only first N lines (file.read)
  --tail=<n>               - Show only last N lines (file.read)
  --grep=<pattern>         - Filter lines matching pattern (file.read)
  --line-numbers, -n       - Show line numbers (file.read)
  --pattern=<glob>         - Filter files by pattern (file.list, file.search)
  --size=<filter>          - Filter by size (e.g., +1M, -100k) (file.list)
  --modified=<days>         - Filter by modification time (e.g., +7d, -1d) (file.list)
  --max=<n>                - Maximum number of results (file.list, file.search)
  --sort=<field>           - Sort by name, size, or date (file.list)
  --reverse, -r            - Reverse sort order (file.list)
  --details, -l            - Show detailed information (file.list)
  --case-insensitive, -i   - Case-insensitive search (file.search)
  --context, -C            - Show context around matches (file.search)
  --summary, -s            - Show summary statistics (file.stats)
  --preserve, -p           - Preserve attributes when copying (file.copy)
  --recursive, -r          - Recursive operation (file.delete)

Examples:
  file.create "config.json" --content='{"key":"value"}'
  file.read "log.txt" --lines=10 --grep="ERROR"
  file.write "data.txt" "new data" --append
  file.list "/tmp" --pattern="*.log" --size=+1M --sort=date
  file.search "/etc" "password" --case-insensitive
  file.stats "large_file.txt"
  file.copy "*.txt" "/backup/" --pattern
  file.move "old.txt" "new.txt"
  file.delete "temp_*.tmp" --pattern
```

### Date

```sh
Date Module - Date and time utilities

Available Functions:
  date.now                    - Get current date and time
  date.help                   - Show this help

Examples:
  date.now                    # Get current date/time
  current_time=$(date.now)    # Store in variable
```

### String

```sh
String Module - String manipulation utilities

Available Functions:
  string.isEmpty <string>              - Check if string is empty
  string.replace <old> <new> <str>     - Replace characters in string
  string.length <str>                  - Get length of string
  string.lower <str>                   - Convert string to lowercase
  string.upper <str>                   - Convert string to uppercase
  string.trim <str>                    - Trim leading/trailing whitespace
  string.contains <str> <substr>       - Check if string contains substring
  string.startswith <str> <prefix>     - Check if string starts with prefix
  string.endswith <str> <suffix>       - Check if string ends with suffix
  string.basename <path>                - Get the basename of a path
  string.help                          - Show this help

Examples:
  string.isEmpty ""                     # Returns true
  string.length "hello"                 # Returns 5
  string.lower "HELLO"                  # Returns hello
  string.upper "hello"                  # Returns HELLO
  string.trim "  hello  "                # Returns hello
  string.contains "hello world" "wor"   # Returns true
  string.startswith "foobar" "foo"      # Returns true
  string.endswith "foobar" "bar"        # Returns true
  string.replace "a" "b" "cat"         # Returns cbt
  string.basename "/path/to/file.txt"  # Returns file.txt
```

### Directory

```sh
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

### Mathexceptions

No help function available for this module.

### Math

```sh
Math Module - Mathematical operations and utilities

Available Functions:
  math.add <num1> <num2>            - Add two numbers
  math.help                          - Show this help

Examples:
  math.add 5 3                       # Returns 8
  math.add 10 20                     # Returns 30
  result=$(math.add 15 25)          # Store result in variable
```

### Process

```sh
Process Module - Process management and monitoring utilities

Available Functions:
  process.list [options]           - List running processes
  process.count                    - Get total process count
  process.find <name>              - Find processes by name
  process.top_cpu [limit]          - Top processes by CPU usage
  process.top_mem [limit]          - Top processes by memory usage
  process.help                     - Show this help

List Options:
  -l=<number>, --limit=<number>    - Limit number of processes shown
  --no-log                         - Fast output without logging overhead
  --format=<format>                - Output format (compact|table|default)

Examples:
  process.list                     # List all processes
  process.list -l=10              # List first 10 processes
  process.list --no-log --format=compact  # Fast compact output
  process.count                    # Get total process count
  process.find ssh                 # Find SSH processes
  process.top_cpu 5                # Top 5 CPU-intensive processes
  process.top_mem 10               # Top 10 memory-intensive processes
```

### Console

```sh
Console Module - Structured Logging for bash-lib

Available Functions:
  console.log <message>     - Log a message with [LOG] identifier
  console.info <message>    - Log an info message with [INFO] identifier
  console.debug <message>   - Log a debug message with [DEBUG] identifier
  console.trace <message>   - Log a trace message with [TRACE] identifier
  console.warn <message>    - Log a warning message with [WARN] identifier
  console.error <message>   - Log an error message with [ERROR] identifier
  console.fatal <message>   - Log a fatal message with [FATAL] identifier
  console.success <message> - Log a success message with [SUCCESS] identifier

Utility Functions:
  console.set_verbosity <level>  - Set logging verbosity (trace|debug|info|warn|error|fatal)
  console.get_verbosity          - Get current verbosity level
  console.set_time_format <fmt>  - Set custom time format (date format string)
  console.help                   - Show this help message

Verbosity Levels:
  trace  - Show all log messages (default)
  debug  - Show debug and above
  info   - Show info and above
  warn   - Show warnings and above
  error  - Show errors and above
  fatal  - Show only fatal messages

Examples:
  console.log "Application started"
  console.set_verbosity debug
  console.debug "Processing user input"
  console.error "Failed to connect to database"
```

### Trapper

```sh
Trapper Module - Comprehensive signal handling and error trapping for all modules

Available Functions:
  trapper.addTrap <cmd> <signals...>      - Add a trap for specific signals
  trapper.addModuleTrap <module> <cmd> <signals...> - Add module-specific trap
  trapper.removeTrap <cmd> <signal>       - Remove a specific trap
  trapper.removeModuleTraps <module>      - Remove all traps for a module
  trapper.getTraps <signal>               - Get current traps for a signal
  trapper.filterTraps <cmd>               - Filter traps by command
  trapper.list [options]                  - List all registered traps
  trapper.clear [options]                 - Clear all traps
  trapper.setupDefaults [options]         - Set up default error handling
  trapper.tempFile                        - Create temporary file with cleanup
  trapper.tempDir                         - Create temporary directory with cleanup
  trapper.help                            - Show this help

Common Signals:
  EXIT  - Script exit (normal or error)
  INT   - Interrupt (Ctrl+C)
  TERM  - Termination request
  ERR   - Error occurred

Options:
  --module=<name>     - Filter by module name (trapper.list, trapper.clear)
  --verbose, -v       - Verbose output (trapper.setupDefaults)

Examples:
  # Basic trap
  trapper.addTrap 'echo "Exiting..."' EXIT
  
  # Module-specific trap
  trapper.addModuleTrap "http" 'http.cleanup' EXIT
  trapper.addModuleTrap "file" 'file.cleanup_temp' INT TERM
  
  # Temporary resources with auto-cleanup
  temp_file=$(trapper.tempFile)
  temp_dir=$(trapper.tempDir)
  
  # List and manage traps
  trapper.list
  trapper.list --module="http"
  trapper.removeModuleTraps "file"
  trapper.clear
  
  # Set up default error handling
  trapper.setupDefaults --verbose
```

### Http

```sh
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

### User

```sh
Users Module - User and group management utilities

Available Functions:
  user.create <username> [options]              - Create a new user
  user.delete <username> [options]              - Delete a user
  user.create_group <groupname> [options]       - Create a new group
  user.delete_group <groupname>                 - Delete a group
  user.add_to_group <username> <groupname>      - Add user to group
  user.remove_from_group <username> <groupname> - Remove user from group
  user.list [options]                           - List all users
  user.list_groups [options]                    - List all groups
  user.info <username>                          - Get user information
  user.set_password <username> <password>       - Set user password
  user.help                                     - Show this help

Create User Options:
  --home=<path>        - Set home directory
  --shell=<shell>      - Set login shell
  --system             - Create system user
  --no-home            - Don't create home directory
  --password=<pass>    - Set initial password

Delete User Options:
  --remove-home        - Remove home directory
  --force              - Force deletion

Create Group Options:
  --system             - Create system group

List Options:
  --system-only        - Show only system users/groups
  --regular-only       - Show only regular users/groups

Shell Constants:
  USER_SHELL_BASH="/bin/bash"
  USER_SHELL_ZSH="/bin/zsh"
  USER_SHELL_NOLOGIN="/usr/sbin/nologin"
  USER_SHELL_FALSE="/bin/false"

Examples:
  user.create john --home=/home/john --shell=$USER_SHELL_BASH
  user.create_group developers
  user.add_to_group john developers
  user.list --regular-only
  user.info john
  user.set_password john mypassword
```

### Compression

```sh
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
```

### Permission

```sh
Permissions Module - File and directory permission management

Available Functions:
  permission.set <path> <mode>                    - Set numeric permissions
  permission.set_symbolic <path> <mode>           - Set symbolic permissions
  permission.own <path> <user:group>              - Set ownership
  permission.get <path>                           - Get current permissions
  permission.set_recursive <path> <mode>          - Set recursive permissions
  permission.own_recursive <path> <user:group>    - Set recursive ownership
  permission.make_executable <path>               - Make file executable
  permission.secure <path>                        - Set private permissions
  permission.public_read <path>                   - Set public read permissions
  permission.help                                 - Show this help

Permission Constants:
  PERM_PRIVATE=600          # Owner read/write only
  PERM_PRIVATE_EXEC=700     # Owner read/write/execute only
  PERM_SHARED_READ=644      # Owner read/write, group/others read
  PERM_SHARED_EXEC=755      # Owner read/write/execute, group/others read/execute
  PERM_PUBLIC_READ=444      # Everyone read only
  PERM_PUBLIC_WRITE=666     # Everyone read/write
  PERM_PUBLIC_EXEC=777      # Everyone read/write/execute

Examples:
  permission.set file.txt 644
  permission.set file.txt $PERM_SHARED_READ
  permission.set_symbolic file.txt u+rw,g+r,o+r
  permission.own file.txt user:group
  permission.get file.txt
  permission.set_recursive /dir 755
  permission.make_executable script.sh
  permission.secure secret.txt
  permission.public_read public.txt
```

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
