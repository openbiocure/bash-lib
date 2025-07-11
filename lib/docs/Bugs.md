# Bugs & Fixes Tracker

This document tracks bugs found in bash-lib and their corresponding fixes.

## Bug Reports

### BUG-001: Missing `process.find_listeners` function
**Date:** 2025-11-07  
**Status:** ✅ FIXED  
**Priority:** High  

**Description:**  
The `process.find_listeners` function was referenced in the help documentation and examples but was not actually implemented in the code. Users trying to use this function would get "command not found" errors.

**Error Message:**  
```bash
bash: process.find_listeners: command not found
```

**Root Cause:**  
The function was documented in `process.help()` but never implemented in the `process.mod.sh` file.

**Fix Applied:**  
- Implemented the missing `process.find_listeners` function in `lib/modules/system/process.mod.sh`
- Added support for macOS compatibility using `lsof` with correct port filtering
- Implemented all documented options: `--tcp`, `--udp`, `--format=table`, `--pid-only`
- Fixed PID extraction and table formatting for `lsof` output
- Prioritized `lsof` over `ss` and `netstat` for better macOS compatibility

**Files Modified:**  
- `lib/modules/system/process.mod.sh`

**Commit:**  
`a67a74c` - fix: implement missing process.find_listeners function

**Testing:**  
- ✅ Function now works: `process.find_listeners 3080`
- ✅ Table format works: `process.find_listeners --format=table`
- ✅ PID-only mode works: `process.find_listeners 3080 --pid-only`
- ✅ Protocol filtering works: `process.find_listeners --tcp`

---

### BUG-002: Bash compatibility issue with indirect parameter expansion
**Date:** 2025-11-07  
**Status:** ✅ FIXED  
**Priority:** High  

**Description:**  
The `validate_environment` function in `init.sh` uses `${!var}` syntax (indirect parameter expansion) which causes "bad substitution" errors in some bash environments and older bash versions.

**Error Message:**  
```bash
validate_environment:6: bad substitution
```

**Steps to Reproduce:**  
1. Source the library from a different location: `source ~/develop/bash-lib/lib/init.sh`
2. Error occurs during environment validation

**Expected Behavior:**  
Library should initialize without errors in all bash environments.

**Actual Behavior:**  
"bad substitution" error prevents library initialization.

**Environment:**  
- OS: macOS
- Bash Version: 5.2.37(1)-release
- bash-lib Version: Current

**Root Cause:**  
`${!var}` syntax (indirect parameter expansion) is not supported in all bash versions or shell environments.

**Fix Applied:**  
- Replaced `${!var}` syntax with `eval "[[ -z \"\${$var}\" ]]"` for better compatibility
- Updated all instances in `lib/init.sh` including `validate_environment`, `import.meta.loaded`, `import.meta.info`, and `import` functions
- Maintained exact same functionality while improving bash version compatibility

**Files Modified:**  
- `lib/init.sh`

**Commit:**  
`ca410e7` - fix: resolve bash compatibility issue with indirect parameter expansion

**Testing:**  
- ✅ Library loads successfully from project directory
- ✅ Library loads successfully from different location (`/tmp`)
- ✅ No "bad substitution" errors
- ✅ All import functionality works correctly

---

## Bug Categories

### High Priority
- Critical functionality missing or broken
- Security vulnerabilities
- Installation/import failures

### Medium Priority  
- Incorrect output or behavior
- Performance issues
- Documentation inconsistencies

### Low Priority
- Cosmetic issues
- Minor usability improvements
- Code style issues

## How to Report a Bug

1. **Check existing bugs** - Search this file first
2. **Create new entry** - Use the template below
3. **Include details** - Error messages, steps to reproduce, environment info
4. **Update status** - Mark as FIXED when resolved

### Bug Report Template

```markdown
### BUG-XXX: [Brief Description]
**Date:** YYYY-MM-DD  
**Status:** 🔍 OPEN / 🔧 IN_PROGRESS / ✅ FIXED / ❌ WONTFIX  
**Priority:** High/Medium/Low  

**Description:**  
[Detailed description of the issue]

**Error Message:**  
```
[Paste error message here]
```

**Steps to Reproduce:**  
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Expected Behavior:**  
[What should happen]

**Actual Behavior:**  
[What actually happens]

**Environment:**  
- OS: [macOS/Linux/Windows]
- Bash Version: [version]
- bash-lib Version: [version]

**Fix Applied:**  
[Description of the fix]

**Files Modified:**  
- [list of files]

**Commit:**  
[commit hash and message]

**Testing:**  
- ✅ [test case 1]
- ❌ [test case 2]
```

## Fix Statistics

- **Total Bugs Fixed:** 2
- **Open Bugs:** 0
- **Last Updated:** 2025-11-07 