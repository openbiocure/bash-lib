#!/bin/bash

# bash-lib Completion Installation Script
# Installs autocomplete for bash-lib functions

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== bash-lib Completion Installation ===${NC}"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPLETION_FILE="$SCRIPT_DIR/completion/bash-lib-completion.bash"

# Check if completion file exists
if [[ ! -f "$COMPLETION_FILE" ]]; then
    echo -e "${RED}Error: Completion file not found at $COMPLETION_FILE${NC}"
    exit 1
fi

# Determine the user's shell
SHELL_TYPE=""
if [[ -n "$ZSH_VERSION" ]]; then
    SHELL_TYPE="zsh"
elif [[ -n "$BASH_VERSION" ]]; then
    SHELL_TYPE="bash"
else
    echo -e "${YELLOW}Warning: Unknown shell type. Assuming bash.${NC}"
    SHELL_TYPE="bash"
fi

echo -e "${GREEN}Detected shell: $SHELL_TYPE${NC}"

# Installation paths
case "$SHELL_TYPE" in
    bash)
        # For bash, we'll add to .bashrc
        RC_FILE="$HOME/.bashrc"
        COMPLETION_DIR="$HOME/.local/share/bash-completion/completions"
        ;;
    zsh)
        # For zsh, we'll add to .zshrc
        RC_FILE="$HOME/.zshrc"
        COMPLETION_DIR="$HOME/.zsh/completions"
        ;;
    *)
        echo -e "${RED}Unsupported shell: $SHELL_TYPE${NC}"
        exit 1
        ;;
esac

# Create completion directory if it doesn't exist
if [[ ! -d "$COMPLETION_DIR" ]]; then
    echo -e "${BLUE}Creating completion directory: $COMPLETION_DIR${NC}"
    mkdir -p "$COMPLETION_DIR"
fi

# Copy completion file
echo -e "${BLUE}Installing completion file...${NC}"
cp "$COMPLETION_FILE" "$COMPLETION_DIR/bash-lib"

# Make it executable
chmod +x "$COMPLETION_DIR/bash-lib"

# Add to shell configuration if not already present
if [[ ! -f "$RC_FILE" ]]; then
    echo -e "${YELLOW}Creating $RC_FILE${NC}"
    touch "$RC_FILE"
fi

# Check if completion is already sourced
if ! grep -q "bash-lib completion" "$RC_FILE" 2>/dev/null; then
    echo -e "${BLUE}Adding completion to $RC_FILE${NC}"
    cat >> "$RC_FILE" << EOF

# bash-lib completion
if [[ -f "$COMPLETION_DIR/bash-lib" ]]; then
    source "$COMPLETION_DIR/bash-lib"
fi
EOF
    echo -e "${GREEN}Added completion to $RC_FILE${NC}"
else
    echo -e "${YELLOW}Completion already configured in $RC_FILE${NC}"
fi

# Create a simple activation script for immediate use
ACTIVATION_SCRIPT="$SCRIPT_DIR/activate-completion.sh"
cat > "$ACTIVATION_SCRIPT" << EOF
#!/bin/bash
# Activate bash-lib completion for current session
source "$COMPLETION_DIR/bash-lib"
echo "bash-lib completion activated for this session"
EOF

chmod +x "$ACTIVATION_SCRIPT"

echo -e "${GREEN}=== Installation Complete ===${NC}"
echo -e "${BLUE}Completion file installed to: $COMPLETION_DIR/bash-lib${NC}"
echo -e "${BLUE}Shell configuration updated: $RC_FILE${NC}"
echo ""
echo -e "${YELLOW}To activate completion immediately:${NC}"
echo -e "  source $ACTIVATION_SCRIPT"
echo ""
echo -e "${YELLOW}To activate completion for new sessions:${NC}"
echo -e "  Restart your terminal or run: source $RC_FILE"
echo ""
echo -e "${BLUE}Usage examples:${NC}"
echo -e "  import <TAB>          # Complete module names"
echo -e "  file.<TAB>            # Complete file functions"
echo -e "  console.<TAB>         # Complete console functions"
echo -e "  http.get <TAB>        # Complete HTTP options"
echo -e "  directory.list <TAB>  # Complete directory options" 