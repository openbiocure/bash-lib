# Production Dockerfile for bash-lib
# This Dockerfile downloads and installs bash-lib from GitHub releases

FROM ubuntu:22.04

ENV BASH__PATH=/opt/bash-lib
ENV DEBIAN_FRONTEND=noninteractive

# Install packages including SSL certificates (cached layer)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create bash-lib directory (cached layer)
RUN mkdir -p /opt/bash-lib

# Download and install bash-lib from GitHub releases
# Use curl with proper SSL handling
RUN curl -sSL --cacert /etc/ssl/certs/ca-certificates.crt \
    https://raw.githubusercontent.com/openbiocure/bash-lib/main/scripts/install.sh | bash

# Comprehensive installation verification
RUN echo "=== Installation Verification ===" && \
    echo "1. Checking bash-lib directory structure:" && \
    ls -la /opt/bash-lib/ && \
    echo "" && \
    echo "2. Checking lib directory:" && \
    ls -la /opt/bash-lib/lib/ && \
    echo "" && \
    echo "3. Checking init.sh exists:" && \
    ls -la /opt/bash-lib/lib/init.sh && \
    echo "" && \
    echo "4. Checking modules directory:" && \
    ls -la /opt/bash-lib/lib/modules/ && \
    echo "" && \
    echo "5. Checking scripts directory:" && \
    ls -la /opt/bash-lib/scripts/ && \
    echo "" && \
    echo "6. Verifying file permissions:" && \
    find /opt/bash-lib -name "*.sh" -exec ls -la {} \; | head -5

# Test basic functionality
RUN echo "=== Testing bash-lib functionality ===" && \
    bash -c "source /opt/bash-lib/lib/init.sh && import console && console.info '✅ bash-lib loaded successfully!'" && \
    bash -c "source /opt/bash-lib/lib/init.sh && import string && echo '✅ string module loaded'" && \
    bash -c "source /opt/bash-lib/lib/init.sh && import math && echo '✅ math module loaded'" && \
    bash -c "source /opt/bash-lib/lib/init.sh && import file && echo '✅ file module loaded'"

# Test environment variables
RUN echo "=== Testing environment setup ===" && \
    bash -c "source /opt/bash-lib/lib/init.sh && echo 'BASH__PATH: $BASH__PATH'" && \
    bash -c "source /opt/bash-lib/lib/init.sh && echo 'BASH_LIB_DEBUG: ${BASH_LIB_DEBUG:-not set}'"

# Final success message
RUN echo "🎉 bash-lib production installation completed successfully!" && \
    echo "📦 Installed from: GitHub releases" && \
    echo "📍 Location: /opt/bash-lib" && \
    echo "🔧 Ready for use in production containers"

CMD ["bash"]
