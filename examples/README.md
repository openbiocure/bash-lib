# bash-lib Examples

This directory contains comprehensive examples for all bash-lib modules, organized by module type for easy navigation and learning. Each module now includes focused examples that demonstrate specific aspects of functionality.

## Directory Structure

```
examples/
├── core/                    # Core initialization and import system
│   └── core_init_example.sh
├── console/                 # Console logging and output formatting
│   ├── 01_basic_logging.sh
│   ├── 02_progress_indicators.sh
│   ├── 03_formatted_output.sh
│   ├── 04_interactive_features.sh
│   ├── 05_console_settings.sh
│   └── console_example.sh
├── http/                    # HTTP requests and API communication
│   ├── 01_basic_requests.sh
│   ├── 02_authentication.sh
│   ├── 03_error_handling.sh
│   ├── 04_file_operations.sh
│   ├── 05_advanced_features.sh
│   └── http_example.sh
├── file/                    # File operations and management
│   ├── 01_basic_operations.sh
│   ├── 02_file_operations.sh
│   ├── 03_file_search.sh
│   ├── 04_file_validation.sh
│   ├── 05_file_advanced.sh
│   └── file_example.sh
├── directory/               # Directory operations and traversal
│   ├── 01_basic_operations.sh
│   └── directory_example.sh
├── math/                    # Mathematical calculations and statistics
│   ├── 01_basic_math.sh
│   └── math_example.sh
├── string/                  # String manipulation and processing
│   ├── 01_basic_string.sh
│   └── string_example.sh
├── date/                    # Date and time operations
│   ├── 01_basic_date.sh
│   └── date_example.sh
├── compression/             # File compression and decompression
│   ├── 01_basic_compression.sh
│   ├── 02_directory_compression.sh
│   ├── 03_compression_formats.sh
│   ├── 04_compression_info.sh
│   ├── 05_advanced_features.sh
│   └── compression_example.sh
├── users/                   # User management and information
│   ├── 01_basic_users.sh
│   └── users_example.sh
├── permissions/             # Permission management and validation
│   ├── 01_basic_permissions.sh
│   └── permissions_example.sh
├── process/                 # Process management and monitoring
│   ├── 01_basic_process.sh
│   └── process_example.sh
├── trapper/                 # Signal handling and error trapping
│   └── trapper_usage.sh
├── integration/             # Cross-module integration examples
│   └── comprehensive_example.sh
└── README.md               # This file
```

## Module-Specific Examples

### Core Module (`core/`)
- **core_init_example.sh**: Demonstrates the core initialization and module import system

### Console Module (`console/`)
The console module includes focused examples for different aspects:

- **01_basic_logging.sh**: Basic logging functions, debug mode, colored output, and log levels
- **02_progress_indicators.sh**: Progress bars, spinners, and status updates
- **03_formatted_output.sh**: Tables, JSON output, and custom formatting
- **04_interactive_features.sh**: Interactive prompts, confirmations, and selections
- **05_console_settings.sh**: Console configuration and customization
- **console_example.sh**: Comprehensive example covering all console features (legacy)

### HTTP Module (`http/`)
The HTTP module includes focused examples for different aspects:

- **01_basic_requests.sh**: Basic GET, POST, PUT, DELETE operations
- **02_authentication.sh**: Different authentication methods
- **03_error_handling.sh**: Error handling and timeouts
- **04_file_operations.sh**: File uploads and downloads
- **05_advanced_features.sh**: JSON parsing, concurrent requests, and advanced features
- **http_example.sh**: Comprehensive example covering all HTTP features (legacy)

### File Module (`file/`)
The file module includes focused examples for different aspects:

- **01_basic_operations.sh**: File creation, reading, and writing
- **02_file_operations.sh**: File copying, moving, renaming, and backup operations
- **03_file_search.sh**: File content search and pattern matching
- **04_file_validation.sh**: File format validation and comparison
- **05_file_advanced.sh**: File locking, monitoring, and compression
- **file_example.sh**: Comprehensive example covering all file features (legacy)

### Directory Module (`directory/`)
- **01_basic_operations.sh**: Directory creation, listing, and basic operations
- **directory_example.sh**: Comprehensive example covering all directory features (legacy)

### Math Module (`math/`)
- **01_basic_math.sh**: Basic mathematical operations and comparisons
- **math_example.sh**: Comprehensive example covering all math features (legacy)

### String Module (`string/`)
- **01_basic_string.sh**: Basic string manipulation and formatting
- **string_example.sh**: Comprehensive example covering all string features (legacy)

### Date Module (`date/`)
- **01_basic_date.sh**: Basic date and time operations
- **date_example.sh**: Comprehensive example covering all date features (legacy)

### Compression Module (`compression/`)
The compression module includes focused examples for different aspects:

- **01_basic_compression.sh**: Basic file compression and decompression operations
- **02_directory_compression.sh**: Compressing and decompressing entire directories
- **03_compression_formats.sh**: Different compression algorithms (gzip, bzip2, xz, zip)
- **04_compression_info.sh**: Getting detailed information about compressed files
- **05_advanced_features.sh**: Advanced features like password protection, compression levels, validation
- **compression_example.sh**: Comprehensive example covering all compression features (legacy)

### Users Module (`users/`)
- **01_basic_users.sh**: Basic user information operations
- **users_example.sh**: Comprehensive example covering all user features (legacy)

### Permissions Module (`permissions/`)
- **01_basic_permissions.sh**: Basic permission operations
- **permissions_example.sh**: Comprehensive example covering all permission features (legacy)

### Process Module (`process/`)
- **01_basic_process.sh**: Basic process operations
- **process_example.sh**: Comprehensive example covering all process features (legacy)

### Trapper Module (`trapper/`)
- **trapper_usage.sh**: Shows signal handling, error trapping, and cleanup management

## Integration Examples

### Integration Module (`integration/`)
- **comprehensive_example.sh**: Demonstrates all modules working together in a real-world scenario

## Usage Instructions

### Running Individual Examples

To run a specific module example:

```bash
# Navigate to the examples directory
cd examples

# Run a specific example
./core/core_init_example.sh
./console/01_basic_logging.sh
./http/01_basic_requests.sh
# ... etc
```

### Running Focused Examples

Each module now has focused examples that can be run individually:

```bash
# Console examples
./console/01_basic_logging.sh
./console/02_progress_indicators.sh
./console/03_formatted_output.sh
./console/04_interactive_features.sh
./console/05_console_settings.sh

# HTTP examples
./http/01_basic_requests.sh
./http/02_authentication.sh
./http/03_error_handling.sh
./http/04_file_operations.sh
./http/05_advanced_features.sh

# File examples
./file/01_basic_operations.sh
./file/02_file_operations.sh
./file/03_file_search.sh
./file/04_file_validation.sh
./file/05_file_advanced.sh

# Compression examples
./compression/01_basic_compression.sh
./compression/02_directory_compression.sh
./compression/03_compression_formats.sh
./compression/04_compression_info.sh
./compression/05_advanced_features.sh
```

### Running All Examples

To run all examples (for testing purposes):

```bash
# From the examples directory
for module in core console http file directory math string date compression users permissions process trapper integration; do
    echo "=== Running $module examples ==="
    for example in $module/*.sh; do
        if [ -f "$example" ]; then
            echo "Running: $example"
            bash "$example"
            echo ""
        fi
    done
done
```

### Learning Path

For new users, we recommend following this learning path:

1. **Start with Core**: `core/core_init_example.sh` - Learn the import system
2. **Console Basics**: `console/01_basic_logging.sh` - Learn logging and output
3. **Console Progress**: `console/02_progress_indicators.sh` - Learn progress indicators
4. **Console Formatting**: `console/03_formatted_output.sh` - Learn formatted output
5. **File Basics**: `file/01_basic_operations.sh` - Learn file handling
6. **File Operations**: `file/02_file_operations.sh` - Learn file management
7. **Directory Operations**: `directory/01_basic_operations.sh` - Learn directory management
8. **String Processing**: `string/01_basic_string.sh` - Learn text manipulation
9. **Math Operations**: `math/01_basic_math.sh` - Learn calculations
10. **Date Handling**: `date/01_basic_date.sh` - Learn time operations
11. **HTTP Basics**: `http/01_basic_requests.sh` - Learn API communication
12. **HTTP Auth**: `http/02_authentication.sh` - Learn authentication
13. **Compression Basics**: `compression/01_basic_compression.sh` - Learn file compression
14. **User Management**: `users/01_basic_users.sh` - Learn user operations
15. **Permissions**: `permissions/01_basic_permissions.sh` - Learn security
16. **Process Management**: `process/01_basic_process.sh` - Learn process control
17. **Error Handling**: `trapper/trapper_usage.sh` - Learn signal handling
18. **Integration**: `integration/comprehensive_example.sh` - See everything working together

## Example Features

Each focused example demonstrates:

- **Clear Purpose**: Each example has a specific learning objective
- **Self-Contained**: Examples can be run independently
- **Progressive Complexity**: Examples build from basic to advanced
- **Comprehensive Testing**: Each example includes verification steps
- **Error Handling**: Proper error checking and reporting
- **Cleanup**: Automatic cleanup of test files and directories
- **Documentation**: Clear comments explaining each step

## Requirements

- Bash shell (version 4.0 or higher recommended)
- bash-lib library installed and configured
- Internet connection (for HTTP examples)
- Appropriate permissions (for system operations)

## Troubleshooting

### Common Issues

1. **Import Errors**: Ensure bash-lib is properly installed and `BASH__PATH` is set
2. **Permission Errors**: Some examples require elevated privileges
3. **Network Errors**: HTTP examples require internet connectivity
4. **File System Errors**: Ensure write permissions in the current directory

### Debug Mode

To run examples with debug output:

```bash
export BASH__VERBOSE=debug
./module/example.sh
```

### Verbose Mode

To run examples with verbose output:

```bash
export BASH__VERBOSE=info
./module/example.sh
```

## Contributing

When adding new examples:

1. Create the example in the appropriate module directory
2. Follow the naming convention: `##_description.sh` for focused examples
3. Make examples self-contained and focused
4. Include comprehensive documentation in the script
5. Test the example thoroughly
6. Update this README if needed

## Support

For issues with examples or bash-lib usage:

1. Check the main bash-lib documentation
2. Review the module-specific documentation
3. Run examples with debug mode enabled
4. Check the bash-lib issue tracker 