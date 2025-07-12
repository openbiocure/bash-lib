# Templates

This folder contains template files used by bash-lib modules for generating dynamic content.

## Available Templates

### service-supervisor.sh

Template for generating service supervisor scripts that handle automatic respawn functionality.

**Variables:**
- `{{SERVICE_NAME}}` - Name of the service
- `{{MAX_RESTARTS}}` - Maximum number of restart attempts (0 = infinite)
- `{{RESTART_DELAY}}` - Seconds to wait between restarts
- `{{COMMAND}}` - The command to execute for the service
- `{{LOG_FILE}}` - Path to the log file
- `{{PID_FILE}}` - Path to the PID file

**Usage:**
This template is automatically used by the `service.start` function when `--respawn` and `--background` options are specified.

## Template Processing

Templates use the `{{VARIABLE_NAME}}` syntax for variable substitution. The `_service_process_template` function in the service module handles the processing of these templates.

## Adding New Templates

When adding new templates:

1. Create the template file with `.sh` extension
2. Use `{{VARIABLE_NAME}}` syntax for variables
3. Document the variables in this README
4. Update the relevant module to use the template processing function 