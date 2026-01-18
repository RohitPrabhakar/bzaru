#!/bin/bash

# Script: Audit Firebase Security
# Purpose: Review Firebase security rules and check for vulnerabilities
# Safe to run: Yes (read-only, no modifications)

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
PROJECT_ID="dev-bzaru"
LOG_FILE="../security-automation.log"

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Firebase Security Audit${NC}"
echo -e "${YELLOW}========================================${NC}"
echo ""

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "Starting Firebase security audit..."

# Check if firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo -e "${RED}ERROR: firebase CLI not found${NC}"
    echo "Please install Firebase CLI. See CLI_SETUP.md"
    exit 1
fi

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo -e "${RED}ERROR: gcloud CLI not found${NC}"
    exit 1
fi

# Set project
gcloud config set project "$PROJECT_ID" --quiet
firebase use "$PROJECT_ID" --add 2>/dev/null || firebase use "$PROJECT_ID"

echo ""
echo -e "${BLUE}======= FIRESTORE SECURITY RULES =======${NC}"
echo ""

echo -e "${YELLOW}Fetching Firestore security rules...${NC}"

# Get Firestore rules
FIRESTORE_RULES=$(gcloud firestore operations list --filter="done:true" --limit=1 2>/dev/null || echo "")

# Try to get rules via Firebase CLI
firebase firestore:rules > /tmp/firestore-rules.txt 2>/dev/null || echo "Unable to fetch via CLI"

if [ -f /tmp/firestore-rules.txt ]; then
    echo -e "${GREEN}✓ Firestore rules retrieved${NC}"
    echo ""
    cat /tmp/firestore-rules.txt

    # Check for dangerous patterns
    echo ""
    echo -e "${YELLOW}Analyzing rules for security issues...${NC}"

    ISSUES_FOUND=0

    # Check for public read/write
    if grep -q "allow read, write: if true" /tmp/firestore-rules.txt; then
        echo -e "${RED}⚠️  CRITICAL: Public read/write access detected!${NC}"
        echo "   Found: allow read, write: if true"
        echo "   This allows ANYONE to read and write your database!"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
        log "CRITICAL: Public read/write access in Firestore rules"
    fi

    if grep -q "allow read: if true" /tmp/firestore-rules.txt; then
        echo -e "${RED}⚠️  WARNING: Public read access detected!${NC}"
        echo "   Found: allow read: if true"
        echo "   Anyone can read this collection"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
        log "WARNING: Public read access in Firestore rules"
    fi

    if grep -q "allow write: if true" /tmp/firestore-rules.txt; then
        echo -e "${RED}⚠️  WARNING: Public write access detected!${NC}"
        echo "   Found: allow write: if true"
        echo "   Anyone can write to this collection"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
        log "WARNING: Public write access in Firestore rules"
    fi

    # Check for proper authentication
    if grep -q "request.auth != null" /tmp/firestore-rules.txt; then
        echo -e "${GREEN}✓ Authentication checks found${NC}"
    else
        echo -e "${YELLOW}⚠️  No authentication checks detected${NC}"
        echo "   Consider adding: request.auth != null"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi

    if [ $ISSUES_FOUND -eq 0 ]; then
        echo -e "${GREEN}✓ No obvious security issues found${NC}"
    else
        echo -e "${RED}⚠️  Found $ISSUES_FOUND potential security issues${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Unable to fetch Firestore rules via CLI${NC}"
    echo "Manual check required:"
    echo "https://console.firebase.google.com/project/$PROJECT_ID/firestore/rules"
fi

echo ""
echo -e "${BLUE}======= STORAGE SECURITY RULES =======${NC}"
echo ""

echo -e "${YELLOW}Checking Firebase Storage rules...${NC}"

# Get Storage rules
firebase storage:rules > /tmp/storage-rules.txt 2>/dev/null || echo "Unable to fetch storage rules"

if [ -f /tmp/storage-rules.txt ]; then
    echo -e "${GREEN}✓ Storage rules retrieved${NC}"
    echo ""
    cat /tmp/storage-rules.txt

    echo ""
    echo -e "${YELLOW}Analyzing storage rules...${NC}"

    # Check for public access
    if grep -q "allow read, write: if true" /tmp/storage-rules.txt; then
        echo -e "${RED}⚠️  CRITICAL: Public storage access detected!${NC}"
        echo "   Anyone can read/write to your storage!"
        log "CRITICAL: Public storage access detected"
    elif grep -q "request.auth != null" /tmp/storage-rules.txt; then
        echo -e "${GREEN}✓ Authentication required for storage access${NC}"
    else
        echo -e "${YELLOW}⚠️  Storage rules may need review${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Unable to fetch Storage rules${NC}"
    echo "Manual check:"
    echo "https://console.firebase.google.com/project/$PROJECT_ID/storage/rules"
fi

echo ""
echo -e "${BLUE}======= REALTIME DATABASE RULES =======${NC}"
echo ""

echo -e "${YELLOW}Checking Realtime Database rules...${NC}"

# Check if Realtime Database is enabled
RTDB_URL=$(gcloud firebase database instances list --format="value(name)" 2>/dev/null | head -1)

if [ -n "$RTDB_URL" ]; then
    echo -e "${GREEN}✓ Realtime Database found: $RTDB_URL${NC}"

    # Get database rules
    firebase database:get /.settings/rules > /tmp/rtdb-rules.json 2>/dev/null || echo "{}"

    if [ -f /tmp/rtdb-rules.json ]; then
        echo ""
        cat /tmp/rtdb-rules.json

        echo ""
        echo -e "${YELLOW}Analyzing database rules...${NC}"

        # Check for public access
        if grep -q '".read": true' /tmp/rtdb-rules.json; then
            echo -e "${RED}⚠️  WARNING: Public read access in Realtime Database${NC}"
            log "WARNING: Public read access in Realtime Database"
        fi

        if grep -q '".write": true' /tmp/rtdb-rules.json; then
            echo -e "${RED}⚠️  CRITICAL: Public write access in Realtime Database${NC}"
            log "CRITICAL: Public write access in Realtime Database"
        fi
    fi
else
    echo -e "${YELLOW}Realtime Database not configured (using Firestore only)${NC}"
fi

echo ""
echo -e "${BLUE}======= RECOMMENDED SECURITY RULES =======${NC}"
echo ""

echo -e "${YELLOW}Recommended Firestore Rules:${NC}"
cat << 'EOF'
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Default: deny all access
    match /{document=**} {
      allow read, write: if false;
    }

    // Users collection: users can only read/write their own data
    match /users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    // Merchants: authenticated users can read, only owner can write
    match /merchant/{merchantId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == merchantId;
    }

    // Products: public read, owner write
    match /merchantProduct/{productId} {
      allow read: if true;  // Public product catalog
      allow write: if request.auth != null &&
                      get(/databases/$(database)/documents/merchant/$(request.auth.uid)).data != null;
    }

    // Orders: only accessible by customer or merchant involved
    match /order/{orderId} {
      allow read: if request.auth != null &&
                     (resource.data.customerId == request.auth.uid ||
                      resource.data.merchantId == request.auth.uid);
      allow create: if request.auth != null && request.resource.data.customerId == request.auth.uid;
      allow update: if request.auth != null &&
                       (resource.data.customerId == request.auth.uid ||
                        resource.data.merchantId == request.auth.uid);
    }
  }
}
EOF

echo ""
echo -e "${YELLOW}Recommended Storage Rules:${NC}"
cat << 'EOF'
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Default: deny all
    match /{allPaths=**} {
      allow read, write: if false;
    }

    // Product images: public read, merchant write
    match /products/{merchantId}/{fileName} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == merchantId;
    }

    // User profile images: authenticated read, owner write
    match /users/{userId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
EOF

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ Security Audit Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Review the security rules above"
echo "2. If issues were found, update rules in Firebase Console:"
echo "   Firestore: https://console.firebase.google.com/project/$PROJECT_ID/firestore/rules"
echo "   Storage:   https://console.firebase.google.com/project/$PROJECT_ID/storage/rules"
echo "3. Test your rules before deploying to production"
echo ""

log "Firebase security audit completed"

echo -e "${GREEN}Script completed successfully!${NC}"
echo "Log file: $LOG_FILE"
