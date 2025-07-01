# Docker Troubleshooting Guide for bash-lib

This guide addresses the specific issue where bash-lib fails silently during initialization in Docker build environments.

## Issue Summary

**Problem**: `source ${BASH__PATH}/lib/core/init.sh` fails silently with exit code 1 in Docker containers, particularly on ARM64 platforms.

**Root Cause**: The original `init.sh` script had several issues that caused silent failures in Docker environments:
1. No debugging output in Docker environments
2. No timeout protection for hanging operations
3. Insufficient error handling for minimal container environments
4. No environment validation

## Fixed Issues

### 1. Silent Failure Resolution
- **Added comprehensive debugging** that activates automatically in Docker environments
- **Added timeout protection** to prevent infinite hangs
- **Added step-by-step initialization** with detailed logging
- **Added environment validation** to fail fast with clear error messages

### 2. Docker-Specific Enhancements
- **Automatic Docker detection** via `/.dockerenv` and `/proc/1/cgroup`
- **Debug mode activation** in Docker environments
- **Stderr redirection** to stdout for Docker build logs
- **Timeout protection** for initialization process

### 3. Error Handling Improvements
- **Non-critical error suppression** for optional components
- **Multiple verification methods** for module loading
- **Graceful degradation** when optional features fail
- **Clear error messages** with actionable information

## Testing Your Fix

### Method 1: Use the Debug Dockerfile

```bash
# Build the debug image
docker build -f Dockerfile.debug -t bash-lib-debug .

# Run the debug container
docker run -it bash-lib-debug

# Inside the container, run the test script
test-docker-init.sh
```

### Method 2: Test in Your Existing Dockerfile

Add these lines to your Dockerfile:

```dockerfile
# Enable debugging
ENV BASH_LIB_DEBUG=true
ENV BASH_LIB_DOCKER=true

# Install bash-lib
RUN curl -sSL https://raw.githubusercontent.com/openbiocure/bash-lib/main/scripts/install.sh | bash

# Test the installation
RUN bash -c "source /opt/bash-lib/lib/core/init.sh && import console && console.info 'Test successful!'"
```

### Method 3: Manual Testing

```bash
# In your Docker container
export BASH_LIB_DEBUG=true
export BASH_LIB_DOCKER=true
source /opt/bash-lib/lib/core/init.sh
import console
console.info "Hello from bash-lib!"
```

## Debug Output

With the fixes, you should see detailed debug output like this:

```
DEBUG: bash-lib init.sh starting
DEBUG: Current environment:
DEBUG: Current directory: /
DEBUG: Available commands:
DEBUG: BASH__PATH=/opt/bash-lib
DEBUG: Docker environment detected, setting timeout to 30 seconds
DEBUG: Starting main initialization...
DEBUG: Step 1 - Environment validation
DEBUG: Running in Docker container
DEBUG: Running as root user
DEBUG: Environment validation passed
DEBUG: Step 2 - BASH__PATH detection
DEBUG: BASH__PATH is valid: /opt/bash-lib
DEBUG: Step 3 - BASH__PATH validation
DEBUG: Step 4 - Build configuration
DEBUG: Step 5 - Core module imports
DEBUG: Sourcing trapper module
DEBUG: Sourcing console module
DEBUG: Step 6 - Setup traps and verbosity
DEBUG: Initialization completed successfully
DEBUG: bash-lib initialization completed successfully
```

## Common Issues and Solutions

### Issue 1: Still Getting Silent Failures

**Solution**: Ensure you're using the updated `init.sh` script:

```bash
# Check if you have the latest version
curl -sSL https://raw.githubusercontent.com/openbiocure/bash-lib/main/lib/core/init.sh | head -20
# Should show "Enhanced for Docker compatibility" in the header
```

### Issue 2: Timeout Errors

**Solution**: Increase the timeout or disable it:

```bash
# Increase timeout
export BASH_LIB_TIMEOUT=60

# Or disable timeout
unset BASH_LIB_DOCKER
```

### Issue 3: Module Loading Failures

**Solution**: Check module availability and permissions:

```bash
# Check if modules exist
ls -la /opt/bash-lib/modules/system/

# Check permissions
find /opt/bash-lib -name "*.sh" -exec ls -la {} \;

# Test individual modules
source /opt/bash-lib/modules/system/console.mod.sh
```

### Issue 4: Environment Variable Issues

**Solution**: Set required environment variables:

```bash
export BASH__PATH=/opt/bash-lib
export BASH_LIB_DEBUG=true
export BASH_LIB_DOCKER=true
```

## ARM64 Specific Issues

For ARM64 platforms (aarch64), ensure:

1. **Base image compatibility**: Use ARM64-compatible base images
2. **Package availability**: Ensure all required packages are available for ARM64
3. **Binary compatibility**: Check if any binary dependencies work on ARM64

```dockerfile
# Example ARM64 Dockerfile
FROM arm64v8/ubuntu:22.04

ENV BASH__PATH=/opt/bash-lib
ENV BASH_LIB_DEBUG=true
ENV BASH_LIB_DOCKER=true

RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    bash \
    timeout

RUN curl -sSL https://raw.githubusercontent.com/openbiocure/bash-lib/main/scripts/install.sh | bash
```

## Performance Considerations

### Debug Mode Impact
- Debug mode adds overhead but provides valuable information
- Disable in production: `unset BASH_LIB_DEBUG`
- Use only when troubleshooting: `export BASH_LIB_DEBUG=true`

### Timeout Impact
- Default timeout is 30 seconds
- Increase for slow systems: `export BASH_LIB_TIMEOUT=60`
- Disable for development: `unset BASH_LIB_DOCKER`

## Best Practices

### 1. Always Test in Docker
```bash
# Test your Dockerfile locally before pushing
docker build -t my-app .
docker run -it my-app bash -c "source /opt/bash-lib/lib/core/init.sh && import console"
```

### 2. Use Debug Mode During Development
```dockerfile
ENV BASH_LIB_DEBUG=true
ENV BASH_LIB_DOCKER=true
```

### 3. Disable Debug in Production
```dockerfile
# Production stage
FROM my-app AS production
ENV BASH_LIB_DEBUG=false
```

### 4. Add Health Checks
```dockerfile
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD bash -c "source /opt/bash-lib/lib/core/init.sh && import console && console.info 'Health check passed'"
```

## Support

If you're still experiencing issues:

1. **Run the debug test script**: `test-docker-init.sh`
2. **Check the debug output** for specific failure points
3. **Verify your environment** matches the requirements
4. **Test with the debug Dockerfile** to isolate the issue
5. **Report the issue** with debug output and environment details

## Example Working Dockerfile

```dockerfile
FROM ubuntu:22.04

# Set environment variables
ENV BASH__PATH=/opt/bash-lib
ENV DEBIAN_FRONTEND=noninteractive
ENV BASH_LIB_DEBUG=true
ENV BASH_LIB_DOCKER=true

# Install required packages
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    bash \
    timeout \
    && rm -rf /var/lib/apt/lists/*

# Install bash-lib
RUN curl -sSL https://raw.githubusercontent.com/openbiocure/bash-lib/main/scripts/install.sh | bash

# Set up bash-lib for the container
RUN echo "export BASH__PATH=/opt/bash-lib" >> /etc/bash.bashrc && \
    echo "source /opt/bash-lib/lib/core/init.sh" >> /etc/bash.bashrc

# Test the installation
RUN bash -c "source /opt/bash-lib/lib/core/init.sh && import console && console.info 'bash-lib installed successfully!'"

# Disable debug for production
ENV BASH_LIB_DEBUG=false

CMD ["bash"]
```

This Dockerfile should work reliably across different platforms and architectures.
