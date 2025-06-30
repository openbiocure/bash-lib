# Compression Module Examples

This directory contains focused examples for the compression module, broken down into smaller, more manageable examples that each demonstrate specific aspects of file compression and decompression.

## Example Files

### 01_basic_compression.sh
**Purpose**: Basic file compression and decompression operations
**What it covers**:
- Single file compression and decompression
- Multiple file compression and decompression
- Verification of compression/decompression results

**Best for**: Beginners learning compression basics

### 02_directory_compression.sh
**Purpose**: Compressing and decompressing entire directories
**What it covers**:
- Directory structure compression
- Directory decompression and restoration
- Verification of directory structure integrity
- Different compression formats for directories

**Best for**: Learning how to work with directory archives

### 03_compression_formats.sh
**Purpose**: Different compression algorithms and their characteristics
**What it covers**:
- Gzip, Bzip2, XZ, and Zip compression
- Compression ratio comparison
- Compression type detection
- Format-specific features

**Best for**: Understanding different compression algorithms

### 04_compression_info.sh
**Purpose**: Getting detailed information about compressed files
**What it covers**:
- File size analysis
- Compression ratio calculations
- Compression type detection
- Detailed file analysis
- Compression efficiency analysis
- Overall statistics

**Best for**: Analyzing compression performance and file characteristics

### 05_advanced_features.sh
**Purpose**: Advanced compression capabilities
**What it covers**:
- Compression with specific levels
- Password-protected compression
- Self-extracting archives
- Compression validation
- Batch compression operations
- Compression utilities
- Performance testing

**Best for**: Advanced users and production scenarios

### compression_example.sh (Legacy)
**Purpose**: Comprehensive example covering all compression features
**What it covers**: All features combined in one large example
**Best for**: Reference and legacy compatibility

## Learning Path

For optimal learning, follow this sequence:

1. **Start with basics**: `01_basic_compression.sh`
2. **Learn directory operations**: `02_directory_compression.sh`
3. **Understand different formats**: `03_compression_formats.sh`
4. **Analyze compression data**: `04_compression_info.sh`
5. **Master advanced features**: `05_advanced_features.sh`

## Running Examples

```bash
# Run examples individually
./01_basic_compression.sh
./02_directory_compression.sh
./03_compression_formats.sh
./04_compression_info.sh
./05_advanced_features.sh

# Run all compression examples
for example in 0*.sh; do
    echo "=== Running $example ==="
    bash "$example"
    echo ""
done
```

## Example Features

Each focused example demonstrates:

- **Clear Purpose**: Each example has a specific learning objective
- **Self-Contained**: Examples can be run independently
- **Comprehensive Testing**: Each example includes verification steps
- **Error Handling**: Proper error checking and reporting
- **Cleanup**: Automatic cleanup of test files and directories
- **Documentation**: Clear comments explaining each step

## Requirements

- bash-lib compression module
- bash-lib console module (for output formatting)
- Standard compression tools (gzip, bzip2, xz, zip)
- Write permissions in the current directory

## Troubleshooting

### Common Issues

1. **Missing compression tools**: Ensure gzip, bzip2, xz, and zip are installed
2. **Permission errors**: Ensure write permissions in the current directory
3. **Import errors**: Ensure bash-lib is properly installed and configured

### Debug Mode

```bash
export BASH__VERBOSE=debug
./01_basic_compression.sh
```

## Contributing

When adding new compression examples:

1. Follow the naming convention: `##_description.sh`
2. Make examples self-contained and focused
3. Include proper cleanup
4. Add comprehensive documentation
5. Update this README 