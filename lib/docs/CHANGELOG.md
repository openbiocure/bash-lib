# Changelog

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **CI/CD Pipeline**: Complete GitHub Actions workflow for automated testing, building, and releasing
- **Build System**: New `scripts/build.sh` script for packaging the library with cherry-picked files
- **Version Support**: Install script now supports installing specific versions (e.g., `v1.0.0`, `20241201-abc123`)
- **Release Downloads**: Install script now downloads from GitHub releases instead of main branch
- **Package Distribution**: Multiple distribution formats (tarball, zip, Homebrew formula)
- **Package Installer**: Standalone installer script for downloaded packages
- **Version Validation**: Input validation for version formats in install script

### Changed
- **Docker Installation**: Fixed 404 errors by updating all URLs to point to `scripts/` directory
- **Installation Scripts**: Consolidated Docker installation logic into the main `install.sh` script
- **Docker Detection**: Enhanced Docker environment detection with Docker-specific messaging
- **Documentation**: Updated all Docker-related documentation with correct URLs
- **Build Process**: Simplified CI workflow to use the build script as single source of truth
- **Package Structure**: Cherry-picked files from `lib/` folder, excluding `docker/` and `docs/` directories

### Removed
- **Redundant Script**: Removed the separate `install-docker.sh` script

### Fixed
- **Docker 404 Errors**: Fixed all installation script URLs in Dockerfiles and documentation
- **Installation URLs**: Updated README.md, Docker-Installation.md, and Docker-Troubleshooting.md
- **CI Badge**: Added GitHub Actions CI badge to README.md
- **Build Script**: Refactored from monolithic file generation to proper package creation

### Technical Improvements
- **Error Handling**: Better error messages and validation in install script
- **Extraction**: Simplified from ZIP to TAR extraction (more reliable)
- **Versioning**: Proper semantic versioning support with date-based fallbacks
- **Security**: Removed hardcoded tokens, using GitHub secrets instead

## [0.0.1] - Initial Release

### Added
- **Console Module**: Structured logging with colors and verbosity control
- **HTTP Module**: Full-featured HTTP client with retries, timeouts, and status checking
- **Process Module**: Process management and monitoring
- **Core Infrastructure**: Basic module system and initialization
