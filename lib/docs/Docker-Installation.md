# Docker Installation Guide for bash-lib

This guide explains how to install bash-lib in Docker containers and addresses common issues.

## Quick Start

### Method 1: Using the Docker-Optimized Script (Recommended)

```dockerfile
FROM ubuntu:22.04

# Install required packages
RUN apt-get update && apt-get install -y curl unzip bash

# Install bash-lib using the main install script (auto-detects Docker)
RUN curl -sSL https://raw.githubusercontent.com/openbiocure/bash-lib/main/scripts/install.sh | bash

# Set up bash-lib for the container
RUN echo "export BASH__PATH=/opt/bash-lib" >> /etc/bash.bashrc && \
    echo "source /opt/bash-lib/lib/core/init.sh" >> /etc/bash.bashrc
```

### Method 2: Using the Main Installation Script (Fixed)

The main installation script has been updated to work in Docker containers:

```dockerfile
FROM ubuntu:22.04

# Install required packages
RUN apt-get update && apt-get install -y curl unzip bash

# Install bash-lib using the main script
RUN curl -sSL https://raw.githubusercontent.com/openbiocure/bash-lib/main/scripts/install.sh | bash

# Set up bash-lib for the container
RUN echo "export BASH__PATH=/opt/bash-lib" >> /etc/bash.bashrc && \
    echo "source /opt/bash-lib/lib/core/init.sh" >> /etc/bash.bashrc
```

### Method 3: Manual Installation

For more control over the installation process:

```dockerfile
FROM ubuntu:22.04

# Install required packages
RUN apt-get update && apt-get install -y curl unzip bash

# Manual installation
RUN mkdir -p /opt/bash-lib && \
    curl -sSL https://github.com/openbiocure/bash-lib/archive/refs/heads/main.zip -o /tmp/bash-lib.zip && \
    unzip -q /tmp/bash-lib.zip -d /tmp && \
    cp -r /tmp/bash-lib-main/* /opt/bash-lib/ && \
    find /opt/bash-lib -name "*.sh" -type f -exec chmod +x {} \; && \
    rm -rf /tmp/bash-lib.zip /tmp/bash-lib-main

# Set up bash-lib for the container
RUN echo "export BASH__PATH=/opt/bash-lib" >> /etc/bash.bashrc && \
    echo "source /opt/bash-lib/lib/core/init.sh" >> /etc/bash.bashrc
```

## Common Issues and Solutions

### Issue 1: "sudo: command not found"

**Problem**: The installation script tries to use `sudo` but it's not available in Docker containers.

**Solution**: The installation scripts now automatically detect Docker containers and root users, avoiding the use of `sudo`.

### Issue 2: "tar: This does not look like a tar archive"

**Problem**: The downloaded file is a ZIP archive, not a tar archive.

**Solution**: The installation scripts now properly handle ZIP files and try multiple extraction methods.

### Issue 3: Permission Denied

**Problem**: Cannot write to `/opt/bash-lib` due to permissions.

**Solution**: Docker containers typically run as root, so this shouldn't be an issue. If it is, ensure your Dockerfile runs as root or has appropriate permissions.

## Complete Dockerfile Examples

### Ubuntu/Debian Base Image

```dockerfile
FROM ubuntu:22.04

# Set environment variables
ENV BASH__PATH=/opt/bash-lib
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    bash \
    && rm -rf /var/lib/apt/lists/*

# Install bash-lib
RUN curl -sSL https://raw.githubusercontent.com/openbiocure/bash-lib/main/scripts/install.sh | bash

# Set up bash-lib for the container
RUN echo "export BASH__PATH=/opt/bash-lib" >> /etc/bash.bashrc && \
    echo "source /opt/bash-lib/lib/core/init.sh" >> /etc/bash.bashrc

# Verify installation
RUN bash -c "source /opt/bash-lib/lib/core/init.sh && import console && console.info 'bash-lib installed successfully!'"

CMD ["bash"]
```

### CentOS/RHEL Base Image

```dockerfile
FROM centos:8

# Set environment variables
ENV BASH__PATH=/opt/bash-lib

# Install required packages
RUN yum update -y && yum install -y \
    curl \
    unzip \
    bash \
    && yum clean all

# Install bash-lib
RUN curl -sSL https://raw.githubusercontent.com/openbiocure/bash-lib/main/scripts/install.sh | bash

# Set up bash-lib for the container
RUN echo "export BASH__PATH=/opt/bash-lib" >> /etc/bashrc && \
    echo "source /opt/bash-lib/lib/core/init.sh" >> /etc/bashrc

# Verify installation
RUN bash -c "source /opt/bash-lib/lib/core/init.sh && import console && console.info 'bash-lib installed successfully!'"

CMD ["bash"]
```

### Alpine Linux Base Image

```dockerfile
FROM alpine:latest

# Set environment variables
ENV BASH__PATH=/opt/bash-lib

# Install required packages
RUN apk add --no-cache \
    curl \
    unzip \
    bash

# Install bash-lib
RUN curl -sSL https://raw.githubusercontent.com/openbiocure/bash-lib/main/scripts/install.sh | bash

# Set up bash-lib for the container
RUN echo "export BASH__PATH=/opt/bash-lib" >> /etc/profile && \
    echo "source /opt/bash-lib/lib/core/init.sh" >> /etc/profile

# Verify installation
RUN bash -c "source /opt/bash-lib/lib/core/init.sh && import console && console.info 'bash-lib installed successfully!'"

CMD ["bash"]
```

## Testing the Installation

After building your Docker image, you can test the installation:

```bash
# Build the image
docker build -t bash-lib-test .

# Run the container
docker run -it bash-lib-test

# Inside the container, test bash-lib
import console
console.info "Hello from bash-lib!"
import string
string.help
```

## Environment Variables

You can customize the installation by setting these environment variables:

- `BASH__PATH`: The installation directory (default: `/opt/bash-lib`)
- `DEBIAN_FRONTEND`: Set to `noninteractive` for Ubuntu/Debian images

## Troubleshooting

### Check if bash-lib is installed

```bash
# Check if the directory exists
ls -la /opt/bash-lib

# Check if the init script exists
ls -la /opt/bash-lib/lib/core/init.sh

# Try to source bash-lib
source /opt/bash-lib/lib/core/init.sh
```

### Check if import function is available

```bash
# Check if import function exists
command -v import

# Try importing a module
import console
```

### Debug installation issues

```bash
# Run installation with verbose output
curl -sSL https://raw.githubusercontent.com/openbiocure/bash-lib/main/scripts/install.sh | bash -x
```

## Best Practices

1. **Use the Docker-optimized script** for container installations
2. **Set environment variables** early in your Dockerfile
3. **Verify installation** after setup
4. **Clean up package caches** to reduce image size
5. **Use multi-stage builds** for production images

## Support

If you encounter issues with Docker installation:

1. Check the [GitHub Issues](https://github.com/openbiocure/bash-lib/issues)
2. Ensure you're using the latest version of the installation scripts
3. Verify your base image has the required packages (curl, unzip, bash)
4. Check that your container has write permissions to `/opt`
