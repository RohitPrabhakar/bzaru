#!/bin/bash

# Google Cloud SDK Installation Script
# This script downloads and installs the Google Cloud SDK
# Run this when you have proper internet access

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Google Cloud SDK Installation${NC}"
echo -e "${YELLOW}========================================${NC}"
echo ""

INSTALL_DIR="$HOME/google-cloud-sdk"

# Check if already installed
if [ -f "$INSTALL_DIR/bin/gcloud" ]; then
    echo -e "${GREEN}Google Cloud SDK is already installed at: $INSTALL_DIR${NC}"
    echo "Version: $($INSTALL_DIR/bin/gcloud version --format='value(version)')"
    echo ""
    read -p "Reinstall? (yes/no): " reinstall
    if [ "$reinstall" != "yes" ]; then
        echo "Skipping installation"
        exit 0
    fi
    echo "Removing existing installation..."
    rm -rf "$INSTALL_DIR"
fi

echo "Installing Google Cloud SDK..."
echo ""

# Method 1: Try using curl (recommended)
echo -e "${YELLOW}Attempting installation via curl...${NC}"
if curl -o /tmp/gcloud-install.sh https://sdk.cloud.google.com 2>/dev/null; then
    bash /tmp/gcloud-install.sh --disable-prompts --install-dir=$HOME
    rm /tmp/gcloud-install.sh
    echo -e "${GREEN}✓ Installation successful via curl${NC}"
else
    echo -e "${YELLOW}curl method failed, trying alternative...${NC}"

    # Method 2: Download standalone tarball
    echo -e "${YELLOW}Downloading standalone tarball...${NC}"

    ARCH=$(uname -m)
    if [ "$ARCH" = "x86_64" ]; then
        PACKAGE="google-cloud-cli-linux-x86_64.tar.gz"
    elif [ "$ARCH" = "aarch64" ]; then
        PACKAGE="google-cloud-cli-linux-arm.tar.gz"
    else
        echo -e "${RED}Unsupported architecture: $ARCH${NC}"
        exit 1
    fi

    URL="https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/$PACKAGE"

    cd /tmp
    if wget "$URL" 2>/dev/null || curl -O "$URL" 2>/dev/null; then
        tar -xzf "$PACKAGE" -C "$HOME"
        rm "$PACKAGE"
        echo -e "${GREEN}✓ Installation successful via tarball${NC}"
    else
        echo -e "${RED}ERROR: Could not download Google Cloud SDK${NC}"
        echo ""
        echo -e "${YELLOW}Manual installation required:${NC}"
        echo "1. Go to: https://cloud.google.com/sdk/docs/install#linux"
        echo "2. Download the tarball manually"
        echo "3. Extract to $HOME/google-cloud-sdk"
        echo "4. Run: $HOME/google-cloud-sdk/install.sh"
        exit 1
    fi
fi

# Initialize gcloud
echo ""
echo -e "${YELLOW}Initializing Google Cloud SDK...${NC}"

"$INSTALL_DIR/install.sh" \
    --usage-reporting false \
    --path-update true \
    --command-completion true \
    --quiet

# Add to PATH
echo ""
echo -e "${YELLOW}Adding to PATH...${NC}"

# Detect shell
SHELL_RC=""
if [ -n "$BASH_VERSION" ]; then
    SHELL_RC="$HOME/.bashrc"
elif [ -n "$ZSH_VERSION" ]; then
    SHELL_RC="$HOME/.zshrc"
else
    SHELL_RC="$HOME/.profile"
fi

# Add to shell rc if not already there
if ! grep -q "google-cloud-sdk" "$SHELL_RC" 2>/dev/null; then
    cat >> "$SHELL_RC" << 'EOF'

# Google Cloud SDK
if [ -f '$HOME/google-cloud-sdk/path.bash.inc' ]; then
  source '$HOME/google-cloud-sdk/path.bash.inc'
fi
if [ -f '$HOME/google-cloud-sdk/completion.bash.inc' ]; then
  source '$HOME/google-cloud-sdk/completion.bash.inc'
fi
EOF
    echo -e "${GREEN}✓ Added to $SHELL_RC${NC}"
fi

# Add to current session
export PATH="$INSTALL_DIR/bin:$PATH"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Verify installation
if "$INSTALL_DIR/bin/gcloud" version &> /dev/null; then
    echo -e "${GREEN}✓ gcloud is working${NC}"
    echo "Version: $($INSTALL_DIR/bin/gcloud version --format='value(version)')"
else
    echo -e "${RED}✗ gcloud installation verification failed${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Reload your shell or run:"
echo "   source $SHELL_RC"
echo ""
echo "2. Authenticate with Google Cloud:"
echo "   gcloud auth login"
echo ""
echo "3. Set your project:"
echo "   gcloud config set project dev-bzaru"
echo ""
echo -e "${GREEN}Installation script completed!${NC}"
