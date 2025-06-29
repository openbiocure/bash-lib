# VSCode Setup for bash-lib

This guide will help you set up VSCode with full autocomplete and IntelliSense support for bash-lib development.

## Quick Setup

### Option 1: Use Workspace File (Recommended)

1. **Open the workspace file:**
   ```bash
   code bash-lib.code-workspace
   ```

2. **Install recommended extensions** when prompted

3. **You're done!** Autocomplete should work immediately

### Option 2: Manual Setup

1. **Install Required Extensions:**
   - `ms-vscode.shellscript` - Bash language support
   - `foxundermoon.shell-format` - Shell script formatting
   - `timonwong.shellcheck` - Shell script linting
   - `ms-vscode.vscode-bash-debug` - Bash debugging

2. **Copy settings to your VSCode settings.json:**
   ```json
   {
       "files.associations": {
           "*.mod.sh": "shellscript",
           "*.inc": "shellscript"
       },
       "bashIde.includeAllWorkspaceSymbols": true,
       "bashIde.globalVariables": [
           "BASH__PATH",
           "BASH__VERBOSE",
           "BASH__RELEASE"
       ]
   }
   ```

## Features Available

### 🔤 Autocomplete

- **Module imports:** `import <TAB>` → `console`, `file`, `directory`, etc.
- **Function calls:** `console.<TAB>` → `log`, `info`, `debug`, etc.
- **File operations:** `file.<TAB>` → `create`, `read`, `write`, etc.
- **String operations:** `string.<TAB>` → `length`, `upper`, `lower`, etc.

### 📝 Snippets

Use these prefixes for quick code insertion:

- `bl-import` → `import module_name`
- `bl-source` → `source lib/core/init.sh`
- `bl-console-log` → `console.log "message"`
- `bl-console-info` → `console.info "message"`
- `bl-file-create` → `file.create "path" --content="content"`
- `bl-http-get` → `http.get "url"`
- `bl-script` → Complete script template

### 🐛 Debugging

1. **Set breakpoints** in your bash scripts
2. **Press F5** to start debugging
3. **Use the debug console** to inspect variables

### 📋 Tasks

Use `Ctrl+Shift+P` → "Tasks: Run Task" to access:

- **Run Current Script** - Execute the currently open file
- **Generate Manual** - Run `./manual.sh`
- **Activate Completion** - Source completion for current session

## Configuration Files

### `.vscode/settings.json`
Contains workspace-specific settings for bash-lib development.

### `.vscode/tasks.json`
Defines tasks for running scripts and generating documentation.

### `.vscode/launch.json`
Configures debugging for bash scripts.

### `.vscode/extensions.json`
Recommends necessary extensions for bash-lib development.

## Advanced Configuration

### Custom Snippets

You can add custom snippets by editing `.vscode/bash-lib-snippets.json`:

```json
{
    "Custom Function": {
        "prefix": "bl-custom",
        "body": ["your_custom_code_here"],
        "description": "Description of your snippet"
    }
}
```

### Language Server Configuration

For advanced IntelliSense, you can configure the bash language server in `.vscode/bash-lib-language-server.json`.

## Troubleshooting

### Autocomplete Not Working

1. **Check extensions:** Make sure `ms-vscode.shellscript` is installed
2. **Reload VSCode:** `Ctrl+Shift+P` → "Developer: Reload Window"
3. **Check file associations:** Ensure `.mod.sh` files are recognized as shellscript

### Snippets Not Appearing

1. **Check language mode:** Make sure the file is in "Shell Script" mode
2. **Verify snippets file:** Check that `.vscode/bash-lib-snippets.json` exists
3. **Reload VSCode:** Sometimes a reload is needed for new snippets

### Debugging Not Working

1. **Install bashdb:** `npm install -g bashdb`
2. **Check launch configuration:** Verify `.vscode/launch.json` is correct
3. **Set breakpoints:** Make sure you have breakpoints set in your script

## Tips and Tricks

### Quick Commands

- `Ctrl+Shift+P` → "Tasks: Run Task" → "Run Current Script"
- `Ctrl+Shift+P` → "Tasks: Run Task" → "Generate Manual"
- `Ctrl+Space` → Trigger autocomplete manually

### Keyboard Shortcuts

- `F5` - Start debugging
- `Ctrl+F5` - Run without debugging
- `Ctrl+Shift+P` - Command palette
- `Ctrl+Space` - Trigger suggestions

### File Associations

The workspace automatically associates these file types:
- `*.mod.sh` → Shell Script
- `*.inc` → Shell Script

## Extension Development

If you want to create a custom VSCode extension for bash-lib:

1. **Check the `vscode-extension/` directory** for a basic extension template
2. **Modify `package.json`** to add your features
3. **Add snippets** in `snippets/bash-lib.json`
4. **Build and install** the extension

## Support

If you encounter issues:

1. **Check the VSCode output panel** for error messages
2. **Verify all extensions are installed** and up to date
3. **Try reloading VSCode** with `Ctrl+Shift+P` → "Developer: Reload Window"
4. **Check the bash-lib documentation** for function signatures

## Contributing

To improve VSCode support:

1. **Add new snippets** to `.vscode/bash-lib-snippets.json`
2. **Update function descriptions** in `.vscode/bash-lib-language-server.json`
3. **Enhance the extension** in `vscode-extension/`
4. **Update this documentation** with new features
