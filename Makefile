SHELL:=/bin/bash

# Default target
.DEFAULT_GOAL := help

# Check and install dependencies
check-deps:
	@chmod +x dependencies-management.sh
	@./dependencies-management.sh check

# Install missing dependencies
install-deps:
	@chmod +x dependencies-management.sh
	@./dependencies-management.sh install

# Show dependency status
deps-status:
	@chmod +x dependencies-management.sh
	@./dependencies-management.sh status

# Check and install shellspec if needed (legacy target)
ensure-shellspec: install-deps

# run unit tests
all: install-deps
	@export PATH="$$HOME/.local/bin:$$PATH" && shellspec --shell /bin/bash -e BASH__VERBOSE=info

# run unit tests (alias for all)
test: install-deps
	@export PATH="$$HOME/.local/bin:$$PATH" && shellspec --shell /bin/bash -e BASH__VERBOSE=info

# build merged script
build:
	@echo "Building merged script file..."
	@./build.sh

# install bash-lib locally
install: install-deps build
	@echo "Installing bash-lib..."
	@chmod +x install.sh
	@sudo ./install.sh

# uninstall bash-lib
uninstall:
	@echo "Uninstalling bash-lib..."
	@chmod +x install.sh
	@sudo ./install.sh uninstall

# clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@rm -f dist/bash-lib.sh

# show help
help:
	@echo "Available targets:"
	@echo "  check-deps  - Check if all dependencies are installed"
	@echo "  install-deps - Install all missing dependencies"
	@echo "  deps-status - Show detailed status of all dependencies"
	@echo "  all         - Run unit tests"
	@echo "  test        - Run unit tests (alias for all)"
	@echo "  build       - Build the merged bash-lib.sh file"
	@echo "  install     - Build and install bash-lib locally"
	@echo "  uninstall   - Uninstall bash-lib"
	@echo "  clean       - Remove build artifacts"
	@echo "  help        - Show this help message"