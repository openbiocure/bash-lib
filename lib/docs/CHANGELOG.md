# Changelog

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Changed
- Consolidated Docker installation logic into the main install.sh script, which now auto-detects Docker environments and provides Docker-specific messaging.
- Removed the redundant install-docker.sh script.
- Updated all documentation and Dockerfiles to use the main install.sh script for both standard and Docker installations.
0.0.1
Added
 - console module (throwing output to the stdout)
 - http module
 - process module
