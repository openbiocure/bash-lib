#!/bin/bash

# bash-lib Build Script
# This script builds and packages the bash-lib library

set -e

# Configuration
# If a version is provided as argument, use it; otherwise use date-commit format
if [ -n "$1" ]; then
    VERSION="$1"
    PACKAGE_NAME="bash-lib-${VERSION}"
else
    VERSION="$(date +%Y%m%d)-$(git rev-parse --short HEAD)"
    PACKAGE_NAME="bash-lib-${VERSION}"
fi

DIST_DIR="dist"
PACKAGE_DIR="package/${PACKAGE_NAME}"

echo "🔨 Building bash-lib version: ${VERSION}"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf "${DIST_DIR}" "${PACKAGE_DIR}"
mkdir -p "${DIST_DIR}" "${PACKAGE_DIR}"


# Create package structure
echo "📦 Creating package structure..."
mkdir -p "${PACKAGE_DIR}/lib"

# Cherry-pick files from lib folder (exclude docker and docs)
echo "📁 Copying selected files from lib..."
cp -r lib/modules "${PACKAGE_DIR}/lib/"
cp -r lib/exceptions "${PACKAGE_DIR}/lib/"
cp -r lib/config "${PACKAGE_DIR}/lib/"
cp lib/init.sh "${PACKAGE_DIR}/lib/"

# Copy scripts
echo "📁 Copying scripts..."
cp -r scripts "${PACKAGE_DIR}/"

# Copy essential files
echo "📁 Copying essential files..."
cp README.md "${PACKAGE_DIR}/"
cp Makefile "${PACKAGE_DIR}/" 2>/dev/null || true

# Create tarball
echo "📦 Creating tarball..."
cd package
tar -czf "../${DIST_DIR}/${PACKAGE_NAME}.tar.gz" "${PACKAGE_NAME}/"
cd ..

# Create zip
echo "📦 Creating zip..."
cd package
zip -r "../${DIST_DIR}/${PACKAGE_NAME}.zip" "${PACKAGE_NAME}/"
cd ..

# Create Homebrew formula
echo "🍺 Creating Homebrew formula..."
cat > "${DIST_DIR}/bash-lib.rb" << EOF
class BashLib < Formula
  desc "A comprehensive, modular bash library for developers who want powerful, readable shell scripting"
  homepage "https://github.com/openbiocure/bash-lib"
  url "https://github.com/openbiocure/bash-lib/releases/download/${VERSION}/${PACKAGE_NAME}.tar.gz"
  sha256 "$(shasum -a 256 "${DIST_DIR}/${PACKAGE_NAME}.tar.gz" | cut -d' ' -f1)"
  license "MIT"

  def install
    prefix.install Dir["*"]
    bin.install_symlink prefix/"scripts/install.sh" => "bash-lib-install"
  end

  test do
    system "#{bin}/bash-lib-install", "help"
  end
end
EOF

# Create package installer script
echo "📦 Creating package installer script..."
cat > "${DIST_DIR}/install-package.sh" << 'EOF'
#!/bin/bash
# bash-lib Package Installer
# This script installs bash-lib from a downloaded package

set -e

BASH_LIB_PATH="${BASH__PATH:-/opt/bash-lib}"
PACKAGE_DIR="$(dirname "$(readlink -f "$0")")"

echo "📦 Installing bash-lib from package..."

# Create installation directory
sudo mkdir -p "$BASH_LIB_PATH"

# Extract and install
cd "$PACKAGE_DIR"
sudo tar -xzf bash-lib-*.tar.gz -C /tmp
sudo cp -r /tmp/bash-lib-*/* "$BASH_LIB_PATH/"

# Make scripts executable
sudo find "$BASH_LIB_PATH" -name "*.sh" -type f -exec chmod +x {} \;

# Set up environment
echo "export BASH__PATH=$BASH_LIB_PATH" >> ~/.bashrc
echo "source $BASH_LIB_PATH/lib/init.sh" >> ~/.bashrc

echo "✅ bash-lib installed successfully!"
echo "🔄 Please restart your terminal or run: source ~/.bashrc"
EOF

chmod +x "${DIST_DIR}/install-package.sh"

# Clean up package directory
rm -rf package/

echo ""
echo "✅ Build completed successfully!"
echo "📦 Package files created in ${DIST_DIR}/:"
echo "   - ${PACKAGE_NAME}.tar.gz"
echo "   - ${PACKAGE_NAME}.zip"
echo "   - bash-lib.rb (Homebrew formula)"
echo "   - install-package.sh (package installer)"
echo ""
echo "📁 Package contents:"
echo "   - lib/modules/ (all modules including core)"
echo "   - lib/exceptions/ (exception handling)"
echo "   - lib/config/ (configuration files)"
echo "   - lib/init.sh (main initialization)"
echo "   - scripts/ (installation scripts)"
echo "   - README.md, Makefile"
echo ""
echo "🚀 Next steps:"
echo "   1. Test the package: tar -tzf ${DIST_DIR}/${PACKAGE_NAME}.tar.gz"
echo "   2. Create GitHub release with the tarball"
echo "   3. Add Homebrew formula to your tap repository"
