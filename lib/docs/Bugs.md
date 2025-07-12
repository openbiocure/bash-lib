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