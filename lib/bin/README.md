# bash-lib Completion

This directory contains autocomplete functionality for bash-lib, providing intelligent tab completion for all modules and functions.

## Quick Start

### Option 1: Temporary Activation (Current Session Only)

```bash
# From the bash-lib root directory
source activate-completion.sh
```

### Option 2: Permanent Activation

Add this line to your `~/.bashrc` or `~/.zshrc`:

```bash
# For bash
source /path/to/bash-lib/activate-completion.sh

# Or source the completion directly
source /path/to/bash-lib/completion/bash-lib-completion.sh
```

### Option 3: System-wide Installation

```bash
# Run the installation script
./install-completion.sh
```

## What Gets Completed

### Import Commands
- `import <TAB>` - Complete module names
- `import.force <TAB>` - Complete module names
- `import.meta.info <TAB>` - Complete module names

### Module Functions
- `console.<TAB>` - Complete console functions
- `file.<TAB>` - Complete file functions
- `directory.<TAB>` - Complete directory functions
- `string.<TAB>` - Complete string functions
- `math.<TAB>` - Complete math functions
- `date.<TAB>` - Complete date functions
- `http.<TAB>` - Complete HTTP functions
- `user.<TAB>` - Complete user functions
- `permission.<TAB>` - Complete permission functions
- `compression.<TAB>` - Complete compression functions
- `process.<TAB>` - Complete process functions
- `trapper.<TAB>` - Complete trapper functions

## Available Completions

### Console Module
- `log`, `info`, `debug`, `trace`, `warn`, `error`, `fatal`, `success`
- `set_verbosity`, `get_verbosity`, `set_time_format`, `help`

### File Module
- `create`, `read`, `write`, `list`, `search`, `stats`, `copy`, `move`, `delete`, `help`

### Directory Module
- `list`, `search`, `remove`, `copy`, `move`, `create`, `info`, `size`, `find_empty`
- `set_depth`, `set_max_results`, `help`

### String Module
- `isEmpty`, `replace`, `length`, `lower`, `upper`, `trim`
- `contains`, `startswith`, `endswith`, `basename`, `help`

### Math Module
- `add`, `help`

### Date Module
- `now`, `help`

### HTTP Module
- `get`, `post`, `put`, `delete`, `download`, `check`, `status`
- `is_404`, `is_200`, `headers`, `set_timeout`, `set_retries`, `help`

### User Module
- `create`, `delete`, `create_group`, `delete_group`
- `add_to_group`, `remove_from_group`, `list`, `list_groups`
- `info`, `set_password`, `help`

### Permission Module
- `set`, `set_symbolic`, `own`, `get`, `set_recursive`
- `own_recursive`, `make_executable`, `secure`, `public_read`, `help`

### Compression Module
- `uncompress`, `compress`, `tar`, `untar`, `gzip`, `gunzip`, `zip`, `unzip`, `help`

### Process Module
- `list`, `count`, `find`, `top_cpu`, `top_mem`, `help`

### Trapper Module
- `addTrap`, `addModuleTrap`, `removeTrap`, `removeModuleTraps`
- `getTraps`, `filterTraps`, `list`, `clear`, `setupDefaults`
- `tempFile`, `tempDir`, `help`

## Usage Examples

```bash
# Import a module
$ import <TAB>
console  directory  file  http  math  string  ...

# Use file functions
$ file.<TAB>
create  delete  help  list  move  read  search  stats  write

# Use console functions
$ console.<TAB>
debug  error  fatal  get_verbosity  help  info  log  set_verbosity  success  trace  warn

# Use HTTP functions
$ http.<TAB>
check  delete  download  get  headers  help  is_200  is_404  post  put  set_retries  set_timeout  status
```

## Troubleshooting

### Completion Not Working

1. **Check if completion is loaded:**
   ```bash
   complete | grep bash_lib
   ```

2. **Reload completion:**
   ```bash
   source completion/bash-lib-completion.sh
   ```

3. **Check shell compatibility:**
   - Works with Bash 4.0+
   - Works with Zsh (with some limitations)

### Common Issues

1. **"command not found" errors:**
   - Make sure you're in the bash-lib root directory
   - Check that the completion script exists

2. **Completion not showing:**
   - Ensure bash-completion is installed on your system
   - Try restarting your terminal

3. **Partial completion:**
   - The completion is designed to work with the exact function names
   - Make sure you're using the correct module names

## Customization

You can customize the completion by editing `completion/bash-lib-completion.sh`:

1. **Add new modules:** Add module names to `BASH_LIB_MODULES`
2. **Add new functions:** Add function names to the appropriate `*_FUNCTIONS` variables
3. **Modify behavior:** Edit the `_bash_lib_complete` function

## Files

- `bash-lib-completion.sh` - Main completion script
- `bash-lib-completion.bash` - Advanced completion script (more features)
- `README.md` - This file
- `../activate-completion.sh` - Simple activation script
- `../install-completion.sh` - Installation script for system-wide setup

## Contributing

When adding new modules or functions to bash-lib, remember to update the completion script to include them. 