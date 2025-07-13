# Known Bugs and Issues

## Bash 5.1.8 Import Function Failure

### Issue Description
The `import` function fails silently when executed in subshells on bash 5.1.8, causing `console.success: command not found` errors in tests.

### Symptoms
- Tests fail with `console.success: command not found` on bash 5.1.8
- Tests pass on bash 5.2.x and newer versions
- `import console` appears to succeed but functions are not defined
- Direct sourcing of modules works correctly

### Environment
- **Affected:** bash 5.1.8 (x86_64-redhat-linux-gnu)
- **Working:** bash 5.2.21+ (GitHub CI), bash 5.2.37 (macOS)
- **Impact:** Test failures on production servers running older bash versions

### Root Cause Investigation Needed
The `import` function appears to fail silently in subshells on bash 5.1.8. When debugging:

```bash
# This works (direct sourcing)
source lib/modules/system/console.mod.sh
declare -F | grep console  # Shows all console functions

# This fails silently (import function)
import console
declare -F | grep console  # Returns nothing
```

### Temporary Workaround
Added direct sourcing of console module in test setup:

```bash
setup() {
    export BASH__PATH="$(pwd)"
    source "${BASH__PATH:-}/spec/init-spec.sh"
    
    # Source console module directly for bash 5.1.8 compatibility
    source "${BASH__PATH:-}/lib/modules/system/console.mod.sh"
    
    import directory
    import string
}
```

### Files Modified
- `spec/directory_spec.sh`
- `spec/http_spec.sh`

### TODO
- [ ] Investigate why `import` function fails in bash 5.1.8 subshells
- [ ] Check if it's related to function export behavior differences
- [ ] Look into subshell environment inheritance issues
- [ ] Consider if it's a path resolution problem in older bash versions
- [ ] Find a proper fix that doesn't require direct sourcing

### Related Commits
- `e3edb31` - fix: Source console module directly for bash 5.1.8 compatibility

---

## Service Module Respawn Functionality

### Issue Description
The `service.start` command only launches a process once and doesn't automatically restart it when the process dies.

### Symptoms
- Service starts successfully but doesn't respawn when it crashes
- No automatic restart functionality
- Manual intervention required to restart failed services

### Solution Implemented
Added respawn functionality with `nohup` support:

```bash
# Start with respawn (foreground)
service.start api_server "npm run backend" --respawn --max-restarts 5

# Start with respawn and background (survives logout)
service.start api_server "npm run backend" --respawn --background --log-file /var/log/api.log
```

### New Options
- `--respawn` - Enable automatic respawn when process dies
- `--max-restarts N` - Maximum restart attempts (0 = infinite)
- `--restart-delay N` - Seconds to wait between restarts
- `--background` - Run with nohup (survives logout)
- `--log-file PATH` - Log file for background mode
- `--pid-file PATH` - PID file for background mode

### Files Modified
- `lib/modules/system/service.mod.sh`

### Related Commits
- `247f8ea` - feat: Add respawn functionality to service module with nohup support

---

## Makefile Bash Detection

### Issue Description
Makefile was hardcoded to use `/opt/homebrew/bin/bash` which doesn't exist on Linux CI servers.

### Symptoms
- CI server error: `Not found specified shell: /opt/homebrew/bin/bash`
- Tests fail on Linux environments
- Works only on macOS with Homebrew

### Solution Implemented
Added cross-platform bash detection:

```makefile
# Detect the best available bash version
ifeq ($(shell test -x /opt/homebrew/bin/bash && echo yes),yes)
  BASH_PATH := /opt/homebrew/bin/bash
else
  BASH_PATH := /bin/bash
endif
SHELL := $(BASH_PATH)
```

### Files Modified
- `Makefile`

### Related Commits
- `b6fc9e2` - fix: Makefile bash detection for cross-platform compatibility

---

## Service Supervisor Template Path Issue

### Issue Description
The service supervisor script template was looking for bash-lib at the wrong path, causing "Cannot find bash-lib" errors when starting background services.

### Symptoms
- Background services fail to start with `--respawn --background`
- Error: `Cannot find bash-lib at /opt/bash-lib`
- Supervisor script exits immediately with exit code 1
- Service appears to start but then fails verification

### Environment
- **Affected:** All systems with bash-lib installed at `/opt/bash-lib/`
- **Root Cause:** Template was checking `$BASH__PATH/init.sh` instead of `$BASH__PATH/lib/init.sh`
- **Impact:** Background service management completely broken

### Root Cause
The supervisor template was using incorrect path structure:

```bash
# ❌ Wrong path (template was using this)
if [[ ! -f "$BASH__PATH/init.sh" ]]; then

# ✅ Correct path (actual bash-lib structure)
if [[ ! -f "$BASH__PATH/lib/init.sh" ]]; then
```

### Solution Implemented
1. **Moved supervisor script to templates folder** for better organization
2. **Fixed path in template** to use `$BASH__PATH/lib/init.sh`
3. **Added template processing** with variable substitution
4. **Passed BASH__PATH during template processing** instead of during execution
5. **Added comprehensive documentation** explaining the approach

### Files Modified
- `lib/modules/system/service.mod.sh` - Added template processing function
- `lib/templates/service-supervisor.sh` - Created template with correct paths
- `lib/templates/README.md` - Added template documentation

### Template Processing
The supervisor script is now generated using a template system:

```bash
# Template processing happens in main process (has access to environment)
_service_process_template "$template_file" "$supervisor_script" \
    "SERVICE_NAME=$service_name" \
    "BASH__PATH=${BASH__PATH:-/opt/bash-lib}" \
    # ... other variables

# Generated script runs in background with embedded values
nohup bash "$supervisor_script" > "$log_file" 2>&1 &
```

### Why printf instead of console
The template uses `printf` instead of `console` functions because:
1. Runs before bash-lib is loaded (console functions don't exist yet)
2. Needs to write directly to log files for persistence
3. Runs in detached background process
4. `printf` is always available (built into bash)

### Related Commits
- `4a0a928` - refactor: move supervisor script to templates folder and add documentation
- `bb9f17b` - fix: pass BASH__PATH during template processing to fix background service startup
- `871ae25` - fix: correct path to init.sh in supervisor template

---

## Service Tracking Lost After Logout

### Issue Description
Service tracking information is lost when users logout and return, making it impossible to manage auto-respawning services that continue running in the background.

### Symptoms
- `service.list` returns "No services are currently tracked" after logout
- Auto-respawning services continue running but aren't tracked
- Manual process killing required to stop services
- No way to discover running services from previous sessions

### Environment
- **Affected:** All systems using background services with `--respawn --background`
- **Root Cause:** Service tracking uses memory variables that are lost on logout
- **Impact:** Cannot manage services after session restart

### Root Cause
Service tracking uses in-memory variables that don't persist across sessions:

```bash
# These variables are lost on logout
SERVICE_PIDS=""
SERVICE_STATUS=""

# But background processes continue running with nohup
nohup bash supervisor_script > log_file 2>&1 &
```

### Solution Implemented
1. **Added `--discover` option to `service.list`** to find services from PID files
2. **Enhanced service discovery** from `/var/run/*.pid` files
3. **Created `service.kill_respawn` function** to stop auto-respawning services
4. **Added comprehensive cleanup** for supervisor processes

### Files Modified
- `lib/modules/system/service.mod.sh` - Added discovery and kill_respawn functions

### New Functions
```bash
# Discover services from PID files (useful after logout)
service.list --discover

# Kill auto-respawning service completely
service.kill_respawn <service_name>

# Kill all auto-respawning services
service.kill_respawn --all
```

### Related Commits
- `505c67e` - feat: add service discovery from PID files for post-logout scenarios

---

## Directory Remove Function Missing Recursive Flag

### Issue Description
The `directory.remove` function fails to remove directories because it doesn't automatically add the recursive flag when the target is a directory.

### Symptoms
- Error: `Failed to remove: directory_name/`
- Directory removal fails even when target is clearly a directory
- Manual `rm -rf` works but `directory.remove` doesn't
- Function requires explicit `--recursive` flag for directories

### Environment
- **Affected:** All systems using `directory.remove` on directories
- **Root Cause:** Function doesn't automatically detect directories and add `-r` flag
- **Impact:** Directory removal operations fail unexpectedly

### Root Cause
The function checks if the target is a directory but doesn't automatically add the recursive flag:

```bash
# ❌ Old logic - only adds -r if --recursive flag is used
if [[ "$recursive" == "true" ]]; then rm_cmd="rm -r"; fi

# ✅ Fixed logic - adds -r for directories automatically
if [[ "$recursive" == "true" || $was_dir -eq 1 ]]; then rm_cmd="rm -r"; fi
```

### Solution Implemented
Modified the `directory.remove` function to automatically add the recursive flag when the target is a directory, while still respecting the explicit `--recursive` flag.

### Files Modified
- `lib/modules/directory/directory.mod.sh` - Fixed recursive flag logic

### Related Commits
- `[commit_hash]` - fix: directory.remove auto-adds recursive flag for directories 