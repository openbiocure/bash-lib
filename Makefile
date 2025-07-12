ifeq ($(shell test -x /opt/homebrew/bin/bash && echo yes),yes)
  SHELL := /opt/homebrew/bin/bash
else
  SHELL := /bin/bash
endif

# Default target
.DEFAULT_GOAL := help

# Check and install dependencies
check-deps:
	@chmod +x scripts/dependencies-management.sh
	@./scripts/dependencies-management.sh check

# Install missing dependencies
install-deps:
	@chmod +x scripts/dependencies-management.sh
	@./scripts/dependencies-management.sh install

# Show dependency status
deps-status:
	@chmod +x scripts/dependencies-management.sh
	@./scripts/dependencies-management.sh status

# Check and install shellspec if needed (legacy target)
ensure-shellspec: install-deps

# run unit tests (alias for all)
test: install-deps
	@export PATH="$$HOME/.local/bin:$$PATH" && export BASH__PATH="$$(pwd)" && shellspec --shell /opt/homebrew/bin/bash -e BASH__VERBOSE=info

# install bash-lib locally
install: install-deps
	@echo "Installing bash-lib..."
	@mkdir -p dist/bash-lib
	@cp -r lib assets lib/docs/README.md lib/docs/CHANGELOG.md LICENSE* dist/bash-lib/ 2>/dev/null || true
	@cp scripts/install.sh dist/bash-lib/
	@chmod +x dist/bash-lib/install.sh
	@cd dist/bash-lib && sudo ./install.sh

# uninstall bash-lib
uninstall:
	@echo "Uninstalling bash-lib..."
	@chmod +x scripts/install.sh
	@sudo ./scripts/install.sh uninstall

# clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf dist/
	@rm -f *.tar.gz

# generate Manual.md from all module help functions
man:
	@./tools/manual.sh

# show help
help:
	@echo "Available targets:"
	@echo "  check-deps   - Check if all dependencies are installed"
	@echo "  install-deps - Install all missing dependencies"
	@echo "  deps-status  - Show detailed status of all dependencies"
	@echo "  all          - Run unit tests"
	@echo "  test         - Run unit tests (alias for all)"
	@echo "  install      - Build and install bash-lib locally"
	@echo "  uninstall    - Uninstall bash-lib"
	@echo "  clean        - Remove all build artifacts"
	@echo "  man          - Generate Manual.md from all module help functions"
	@echo "  help         - Show this help message"
