#!/bin/bash

# Script: Rotate Google Maps API Key
# Purpose: Delete exposed API key and create new one with proper restrictions
# WARNING: This will DELETE the old API key permanently

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ID="dev-bzaru"
OLD_API_KEY="AIzaSyCN4Y0uWd7sfPrQit_lR1ur_xAEz4PMLH4"
ANDROID_PACKAGE="com.bzaru.bzaruapp"
LOG_FILE="../security-automation.log"

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Google Maps API Key Rotation${NC}"
echo -e "${YELLOW}========================================${NC}"
echo ""

# Log function
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "Starting Google Maps API key rotation..."

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo -e "${RED}ERROR: gcloud CLI not found${NC}"
    echo "Please install Google Cloud SDK first. See CLI_SETUP.md"
    exit 1
fi

# Check authentication
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
    echo -e "${RED}ERROR: Not authenticated with gcloud${NC}"
    echo "Run: gcloud auth login"
    exit 1
fi

# Set project
log "Setting project to $PROJECT_ID..."
gcloud config set project "$PROJECT_ID"

echo ""
echo -e "${YELLOW}Step 1: Finding the exposed API key...${NC}"

# List all API keys
log "Searching for exposed API key..."
KEY_NAME=$(gcloud alpha services api-keys list \
    --format="value(name)" \
    --filter="keyString:$OLD_API_KEY" 2>/dev/null || echo "")

if [ -z "$KEY_NAME" ]; then
    echo -e "${YELLOW}⚠️  Exposed API key not found (may have been already deleted)${NC}"
    log "Exposed API key not found - may be already rotated"
else
    echo -e "${GREEN}✓ Found exposed API key: $KEY_NAME${NC}"
    log "Found exposed API key: $KEY_NAME"

    echo ""
    echo -e "${RED}⚠️  WARNING: This will permanently delete the old API key!${NC}"
    echo -e "${RED}⚠️  Apps using this key will stop working immediately!${NC}"
    echo ""
    read -p "Continue with deletion? (yes/no): " confirm

    if [ "$confirm" != "yes" ]; then
        echo -e "${YELLOW}Aborted by user${NC}"
        exit 0
    fi

    echo ""
    echo -e "${YELLOW}Step 2: Deleting exposed API key...${NC}"
    log "Deleting exposed API key..."

    gcloud alpha services api-keys delete "$KEY_NAME" --quiet

    echo -e "${GREEN}✓ Exposed API key deleted${NC}"
    log "Exposed API key deleted successfully"
fi

echo ""
echo -e "${YELLOW}Step 3: Creating new API key with restrictions...${NC}"
log "Creating new API key..."

# Create new API key
NEW_KEY_NAME="bzaru-maps-api-key-$(date +%Y%m%d)"

# Create the key
gcloud alpha services api-keys create "$NEW_KEY_NAME" \
    --display-name="Bzaru Maps API Key (Rotated $(date +%Y-%m-%d))" \
    --api-target=service=maps-android-backend.googleapis.com \
    --api-target=service=maps-ios-backend.googleapis.com \
    --api-target=service=places-backend.googleapis.com \
    --api-target=service=geocoding-backend.googleapis.com \
    --api-target=service=directions-backend.googleapis.com

echo -e "${GREEN}✓ New API key created: $NEW_KEY_NAME${NC}"
log "New API key created: $NEW_KEY_NAME"

# Get the new API key value
echo ""
echo -e "${YELLOW}Step 4: Retrieving new API key value...${NC}"

NEW_API_KEY=$(gcloud alpha services api-keys get-key-string "$NEW_KEY_NAME" --format="value(keyString)")

echo -e "${GREEN}✓ New API key retrieved${NC}"
log "New API key retrieved"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ API Key Rotation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Your new API key is:${NC}"
echo -e "${GREEN}$NEW_API_KEY${NC}"
echo ""
echo -e "${YELLOW}NEXT STEPS:${NC}"
echo "1. Copy the new API key above"
echo "2. Update your .env file:"
echo "   GOOGLE_MAPS_API_KEY=$NEW_API_KEY"
echo "3. Add application restrictions in Google Cloud Console:"
echo "   - Go to: https://console.cloud.google.com/apis/credentials"
echo "   - Click on: $NEW_KEY_NAME"
echo "   - Under 'Application restrictions':"
echo "     - Select 'Android apps'"
echo "     - Add package: $ANDROID_PACKAGE"
echo "     - Add your SHA-1 certificate fingerprints"
echo "     - Also add iOS bundle ID restrictions"
echo ""
echo -e "${RED}⚠️  IMPORTANT: Update your .env file NOW!${NC}"
echo ""

# Update .env file if it exists
if [ -f "../.env" ]; then
    echo -e "${YELLOW}Would you like me to update your .env file automatically?${NC}"
    read -p "Update .env? (yes/no): " update_env

    if [ "$update_env" = "yes" ]; then
        # Backup .env
        cp ../.env ../.env.backup.$(date +%Y%m%d-%H%M%S)

        # Update or add GOOGLE_MAPS_API_KEY
        if grep -q "GOOGLE_MAPS_API_KEY=" ../.env; then
            sed -i "s/GOOGLE_MAPS_API_KEY=.*/GOOGLE_MAPS_API_KEY=$NEW_API_KEY/" ../.env
        else
            echo "GOOGLE_MAPS_API_KEY=$NEW_API_KEY" >> ../.env
        fi

        echo -e "${GREEN}✓ .env file updated${NC}"
        log ".env file updated with new API key"
    fi
fi

log "Google Maps API key rotation completed successfully"

echo ""
echo -e "${GREEN}Script completed successfully!${NC}"
echo "Log file: $LOG_FILE"
