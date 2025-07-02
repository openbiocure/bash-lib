# Production Dockerfile for bash-lib
# This Dockerfile downloads and installs bash-lib from GitHub releases

FROM ubuntu:22.04

ENV BASH__PATH=/opt/bash-lib
ENV DEBIAN_FRONTEND=noninteractive

# Install only minimal essential packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Download and install bash-lib from GitHub releases
RUN curl -sSL https://raw.githubusercontent.com/openbiocure/bash-lib/main/scripts/install.sh | bash

# Test basic functionality
RUN echo "=== Testing bash-lib ===" && \
    bash -c "source /opt/bash-lib/lib/init.sh && import console && console.info '✅ bash-lib installed from GitHub releases!'"

CMD ["bash"]
