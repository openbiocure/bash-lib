SHELL:=/bin/bash

# Default target
.DEFAULT_GOAL := help

# Check and install shellspec if needed
ensure-shellspec:
	@if ! command -v shellspec >/dev/null 2>&1; then \
		echo "shellspec not found. Installing shellspec..."; \
		if command -v curl >/dev/null 2>&1; then \
			curl -fsSL https://git.io/shellspec | sh -s -- --yes; \
			echo "shellspec installed successfully."; \
			echo "Adding ~/.local/bin to PATH for this session..."; \
			export PATH="$$HOME/.local/bin:$$PATH"; \
		else \
			echo "Error: curl is required to install shellspec. Please install curl first."; \
			exit 1; \
		fi; \
	else \
		echo "shellspec is already installed."; \
	fi

# run unit tests
all: ensure-shellspec
	@export PATH="$$HOME/.local/bin:$$PATH" && shellspec --shell /bin/bash -e BASH__VERBOSE=info

# run unit tests (alias for all)
test: ensure-shellspec
	@export PATH="$$HOME/.local/bin:$$PATH" && shellspec --shell /bin/bash -e BASH__VERBOSE=info

# build merged script
build:
	@echo "Building merged script file..."
	@./build.sh

# install bash-lib locally
install: build
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
	@echo "  all       - Run unit tests"
	@echo "  test      - Run unit tests (alias for all)"
	@echo "  build     - Build the merged bash-lib.sh file"
	@echo "  install   - Build and install bash-lib locally"
	@echo "  uninstall - Uninstall bash-lib"
	@echo "  clean     - Remove build artifacts"
	@echo "  help      - Show this help message"