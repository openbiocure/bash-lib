![bash](./assets/bash.png)

# Bash Library (bash-lib)

[![Bash Library CI](https://github.com/openbiocure/bash-lib/actions/workflows/test.yml/badge.svg)](https://github.com/openbiocure/bash-lib/actions/workflows/test.yml)

> **A comprehensive, modular bash library for developers who want powerful, readable shell scripting**

Bash-lib transforms shell scripting from a cryptic art into a developer-friendly experience. With structured logging, HTTP clients, file management, user management, and more - all wrapped in clean, readable APIs.

[![asciicast](https://asciinema.org/a/xsWFcHG0hrFnKAvhrubClsq6n.svg)](https://asciinema.org/a/xsWFcHG0hrFnKAvhrubClsq6n)

## 🚀 Quick Start

### One-Command Installation

```bash
# Install latest version
curl -sSL https://raw.githubusercontent.com/openbiocure/bash-lib/main/scripts/install.sh | bash

# Install specific version
curl -sSL https://raw.githubusercontent.com/openbiocure/bash-lib/main/scripts/install.sh | bash -s v1.0.0

# Install specific build
curl -sSL https://raw.githubusercontent.com/openbiocure/bash-lib/main/scripts/install.sh | bash -s 20241201-abc123
```

### Development Setup

```bash
git clone https://github.com/openbiocure/bash-lib
cd bash-lib
make install-deps
make install
```

## 📦 Available Modules

### 🔧 **System Utilities**
- **`console`** - Structured logging with colors and verbosity control
- **`process`** - Process management and monitoring

### 🌐 **Network & HTTP**
- **`http`** - Full-featured HTTP client with retries, timeouts, and status checking

### 📁 **File & Directory Management**
- **`directory`** - Comprehensive file/directory operations with search and filtering
- **`permissions`** - User-friendly permission management with readable constants
- **`compressions`** - Archive creation and extraction (tar, zip, gzip)

### 👥 **User Management**
- **`users`** - Complete user and group management system

### 🧮 **Utilities**
- **`math`** - Mathematical operations and calculations
- **`string`** - String manipulation and validation
- **`date`** - Date and time utilities

## 💡 Usage Examples

### Basic Setup

```bash
# Source the library (BASH__PATH is auto-detected)
source lib/core/init.sh

# Import modules
import console
import http
import directory
import permissions
```

### Console Logging

```bash
console.log "Application started"
console.info "Processing user input"
console.debug "Variable value: $user_input"
console.warn "Deprecated function called"
console.error "Failed to connect to database"
console.success "User created successfully"
```

### HTTP Requests

```bash
# Simple GET request
http.get "https://api.example.com/data"

# POST with data
http.post "https://api.example.com/submit" --data='{"name":"John","age":30}'

# Download file with retries
http.download "https://example.com/file.zip" "/tmp/file.zip"

# Check if service is up
if http.is_200 "https://api.example.com/health"; then
    console.success "Service is healthy"
fi
```

### File & Directory Operations

```bash
# Create directory with parents
directory.create "/path/to/new/dir" --parents

# Search for files
directory.search "/home/user" "*.log" --depth=3 --max=10

# Get directory size
size=$(directory.size "/var/log" --human-readable)

# List with options
directory.list "/tmp" --all --long --sort=date
```

### Permission Management

```bash
# Set permissions using readable constants
permissions.set "file.txt" $PERM_SHARED_READ
permissions.set "script.sh" $PERM_SHARED_EXEC

# Make executable
permissions.make_executable "script.sh"

# Set ownership
permissions.own "file.txt" "user:group"

# Secure a file (private to owner)
permissions.secure "secret.txt"
```

### User Management

```bash
# Create user with custom options
users.create "john" --home="/home/john" --shell=$USER_SHELL_BASH

# Create group and add user
users.create_group "developers"
users.add_to_group "john" "developers"

# List users
users.list --regular-only

# Get user info
users.info "john"
```

### String Operations

```bash
# Check if string is empty
if [[ $(string.isEmpty "$input") == "true" ]]; then
    console.error "Input is required"
fi

# Convert case
uppercase=$(string.upper "hello world")
lowercase=$(string.lower "HELLO WORLD")

# String manipulation
trimmed=$(string.trim "  hello  ")
length=$(string.length "hello")

# Check patterns
if [[ $(string.contains "hello world" "world") == "true" ]]; then
    console.info "Found 'world' in string"
fi
```

### Compression & Archives

```bash
# Create tar archive
compression.tar "backup.tar" "file1.txt" "dir1/"

# Extract tar archive
compression.untar "backup.tar" "/tmp/extracted"

# Compress with gzip
compression.gzip "large_file.txt"

# Create zip archive
compression.zip "archive.zip" "file1.txt" "file2.txt"
```

## 🛠️ Development

### Available Make Targets

```bash
make help          # Show all available targets
make install-deps  # Install development dependencies
make test          # Run unit tests
make man           # Generate Manual.md from module help
make install       # Install bash-lib locally
```

### Running Tests

```bash
# Run all tests
make test

# Run specific module tests
shellspec spec/directory_spec.sh --shell /bin/bash

# Run with verbose output
shellspec --shell /bin/bash -e BASH__VERBOSE=debug
```

### Generating Documentation

```bash
# Generate Manual.md from all module help functions
make man

# View the generated manual
cat Manual.md
```

## ⚙️ Configuration

### Environment Variables

| Variable        | Description                                                 | Default         |
| :-------------- | :---------------------------------------------------------- | :-------------- |
| `BASH__PATH`    | Library root location (auto-detected by `init.sh` if unset) | `/opt/bash-lib` |
| `BASH__VERBOSE` | Log verbosity level                                         | `info`          |

> **Note:** You usually do **not** need to set `BASH__PATH` manually. The library will auto-detect its root directory when you source `lib/core/init.sh`. Only set it if you want to override the default detection.

### Verbosity Levels

- `trace` - Show all log messages
- `debug` - Show debug and above
- `info` - Show info and above
- `warn` - Show warnings and above
- `error` - Show errors and above

### Setting Verbosity

```bash
# Set verbosity level
console.set_verbosity debug

# Check current level
current_level=$(console.get_verbosity)
```

## 🏗️ Architecture

```
bash-lib/
├── core/                    # Core functionality
│   ├── init.sh             # Library initialization
│   ├── engine.mod.sh       # Module engine
│   └── trapper.mod.sh      # Signal handling
├── modules/                 # Feature modules
│   ├── system/             # System utilities
│   │   ├── console.mod.sh  # Logging
│   │   └── process.mod.sh  # Process management
│   ├── http/               # HTTP client
│   ├── directory/          # File operations
│   ├── permissions/        # Permission management
│   ├── users/              # User management
│   ├── compressions/       # Archive operations
│   ├── math/               # Mathematical operations
│   ├── utils/              # Utility functions
│   └── date/               # Date/time utilities
├── config/                 # Configuration files
├── spec/                   # Unit tests
├── assets/                 # Static assets
└── Manual.md              # Auto-generated documentation
```

## 🔍 Debugging

### Enable Debug Mode

```bash
# Enable bash debugging
set -x

# Your code here
import console
console.debug "Debug message"

set +x
```

### Check Environment

```bash
# List all bash-lib environment variables
env | grep BASH__

# Check module availability
ls modules/*/
```

## 🤝 Contributing & Conduct

All contributors must follow our [Code of Conduct](lib/docs/CODE_OF_CONDUCT.md).

> **Shell Scripting Policy:**
>
> This project enforces strict shell scripting best practices, including the mandatory use of `set -u` (nounset) and proper guarding of all variable and array expansions. Please read the [Code of Conduct](lib/docs/CODE_OF_CONDUCT.md) for details.

### Getting Started

1. Fork the repository
2. Create a feature branch
3. Add your module or improvements
4. Write tests for your changes
5. Submit a pull request

### Development Guidelines

- Follow the existing module structure
- Add comprehensive help functions
- Include unit tests
- Use descriptive function names
- Add proper error handling
- Document all functions with examples

### Finding TODOs

```bash
# Find all TODO and FIXME comments
egrep -Rin "TODO|FIXME" -R *
```

## 📚 Documentation

- **[Manual.md](Manual.md)** - Auto-generated from module help functions
- **CHANGELOG.md** - Complete change history
- **Module Help** - Each module has built-in help: `module.help`

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

- **Issues**: [GitHub Issues](https://github.com/openbiocure/bash-lib/issues)
- **Documentation**: Run `make man` to generate the latest manual
- **Module Help**: Run `module.help` for any module's documentation

---

**Transform your bash scripts from cryptic commands into readable, maintainable code with bash-lib! 🚀**
