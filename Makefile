SHELL:=/bin/bash

# Default target
.DEFAULT_GOAL := help

# run unit tests
all:
	@shellspec --shell /bin/bash -e BASH__VERBOSE=info

# run unit tests (alias for all)
test:
	@shellspec --shell /bin/bash -e BASH__VERBOSE=info

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