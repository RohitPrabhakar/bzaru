#!/bin/bash

# Script: Review Firebase Access & Activity
# Purpose: Check for suspicious activity and unauthorized access
# Safe to run: Yes (read-only analysis)

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
DAYS_TO_CHECK=7

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Firebase Access & Activity Review${NC}"
echo -e "${YELLOW}========================================${NC}"
echo ""
echo "Checking for suspicious activity in the last $DAYS_TO_CHECK days..."
echo ""

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "Starting Firebase access review..."

# Check if firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo -e "${RED}ERROR: firebase CLI not found${NC}"
    exit 1
fi

if ! command -v gcloud &> /dev/null; then
    echo -e "${RED}ERROR: gcloud CLI not found${NC}"
    exit 1
fi

# Set project
gcloud config set project "$PROJECT_ID" --quiet
firebase use "$PROJECT_ID" 2>/dev/null || firebase use "$PROJECT_ID" --add

echo ""
echo -e "${BLUE}======= AUTHENTICATION ACTIVITY =======${NC}"
echo ""

echo -e "${YELLOW}Fetching recent authentication events...${NC}"

# Check for authentication logs
gcloud logging read "resource.type=firebase_domain AND timestamp>=\"$(date -u -d "$DAYS_TO_CHECK days ago" +%Y-%m-%dT%H:%M:%SZ)\"" \
    --limit=100 \
    --format="table(timestamp, jsonPayload.event_type, jsonPayload.email, jsonPayload.ip)" \
    --project="$PROJECT_ID" 2>/dev/null || echo -e "${YELLOW}No authentication logs found${NC}"

# Count failed login attempts
FAILED_LOGINS=$(gcloud logging read \
    "resource.type=firebase_domain AND jsonPayload.event_type=FAILED_LOGIN AND timestamp>=\"$(date -u -d "$DAYS_TO_CHECK days ago" +%Y-%m-%dT%H:%M:%SZ)\"" \
    --limit=1000 \
    --format="value(timestamp)" \
    --project="$PROJECT_ID" 2>/dev/null | wc -l)

echo ""
echo "Failed login attempts in last $DAYS_TO_CHECK days: $FAILED_LOGINS"

if [ "$FAILED_LOGINS" -gt 50 ]; then
    echo -e "${RED}⚠️  HIGH number of failed logins detected!${NC}"
    echo "   This could indicate a brute-force attack."
    log "WARNING: High number of failed logins: $FAILED_LOGINS"
elif [ "$FAILED_LOGINS" -gt 10 ]; then
    echo -e "${YELLOW}⚠️  Moderate failed login activity${NC}"
else
    echo -e "${GREEN}✓ Normal failed login activity${NC}"
fi

echo ""
echo -e "${BLUE}======= FIRESTORE ACTIVITY =======${NC}"
echo ""

echo -e "${YELLOW}Analyzing Firestore usage patterns...${NC}"

# Get Firestore operation counts
echo "Fetching Firestore metrics..."

# Read operations
READ_OPS=$(gcloud monitoring time-series list \
    --filter='metric.type="firestore.googleapis.com/document/read_count"' \
    --start-time="$(date -u -d "$DAYS_TO_CHECK days ago" +%Y-%m-%dT%H:%M:%SZ)" \
    --format="table(points.interval.startTime, points.values)" \
    --project="$PROJECT_ID" 2>/dev/null | tail -n +2 | wc -l || echo "0")

# Write operations
WRITE_OPS=$(gcloud monitoring time-series list \
    --filter='metric.type="firestore.googleapis.com/document/write_count"' \
    --start-time="$(date -u -d "$DAYS_TO_CHECK days ago" +%Y-%m-%dT%H:%M:%SZ)" \
    --format="table(points.interval.startTime, points.values)" \
    --project="$PROJECT_ID" 2>/dev/null | tail -n +2 | wc -l || echo "0")

echo ""
echo "Firestore activity in last $DAYS_TO_CHECK days:"
echo "• Read operations:  $READ_OPS data points"
echo "• Write operations: $WRITE_OPS data points"

# Check for unusual spikes
echo ""
echo -e "${YELLOW}Checking for unusual activity spikes...${NC}"

gcloud logging read \
    "resource.type=\"firestore.googleapis.com/Database\" AND severity>=WARNING AND timestamp>=\"$(date -u -d "$DAYS_TO_CHECK days ago" +%Y-%m-%dT%H:%M:%SZ)\"" \
    --limit=20 \
    --format="table(timestamp, severity, jsonPayload.message)" \
    --project="$PROJECT_ID" 2>/dev/null || echo -e "${GREEN}✓ No warnings or errors found${NC}"

echo ""
echo -e "${BLUE}======= STORAGE ACTIVITY =======${NC}"
echo ""

echo -e "${YELLOW}Reviewing Firebase Storage usage...${NC}"

# Check Storage bucket usage
BUCKETS=$(gcloud storage buckets list --project="$PROJECT_ID" --format="value(name)" 2>/dev/null)

if [ -n "$BUCKETS" ]; then
    for bucket in $BUCKETS; do
        echo ""
        echo "Bucket: $bucket"

        # Get bucket size
        SIZE=$(gcloud storage du -s "gs://$bucket" 2>/dev/null | awk '{print $1}' || echo "Unknown")
        echo "  Size: $SIZE"

        # Check for unusual files
        RECENT_FILES=$(gcloud storage ls "gs://$bucket/**" --format="value(name)" 2>/dev/null | head -10)
        if [ -n "$RECENT_FILES" ]; then
            echo "  Recent files:"
            echo "$RECENT_FILES" | head -5 | sed 's/^/    /'
        fi
    done
else
    echo -e "${YELLOW}No storage buckets found${NC}"
fi

echo ""
echo -e "${BLUE}======= USER ACCOUNTS =======${NC}"
echo ""

echo -e "${YELLOW}Reviewing authenticated user accounts...${NC}"

# Note: Firebase CLI doesn't directly export user lists for security
# This would typically be done via Firebase Admin SDK

echo "To review user accounts in detail:"
echo "1. Go to: https://console.firebase.google.com/project/$PROJECT_ID/authentication/users"
echo "2. Check for:"
echo "   • Recently created accounts (potential spam/abuse)"
echo "   • Accounts with unusual email domains"
echo "   • Disabled accounts"
echo "   • Accounts created from unusual locations"
echo ""

echo -e "${BLUE}======= API USAGE =======${NC}"
echo ""

echo -e "${YELLOW}Checking API usage for abuse patterns...${NC}"

# Check for API quota exhaustion
gcloud logging read \
    "protoPayload.status.message=~\"quota\" AND timestamp>=\"$(date -u -d "$DAYS_TO_CHECK days ago" +%Y-%m-%dT%H:%M:%SZ)\"" \
    --limit=20 \
    --format="table(timestamp, protoPayload.status.message)" \
    --project="$PROJECT_ID" 2>/dev/null || echo -e "${GREEN}✓ No quota issues detected${NC}"

echo ""
echo -e "${BLUE}======= GEOGRAPHIC ANALYSIS =======${NC}"
echo ""

echo -e "${YELLOW}Analyzing request origins...${NC}"

# Get geographic distribution of requests
echo "Fetching geographic data from logs..."

gcloud logging read \
    "resource.type=firebase_domain AND timestamp>=\"$(date -u -d "$DAYS_TO_CHECK days ago" +%Y-%m-%dT%H:%M:%SZ)\"" \
    --limit=100 \
    --format="value(jsonPayload.ip)" \
    --project="$PROJECT_ID" 2>/dev/null | sort | uniq -c | sort -rn | head -10 > /tmp/top-ips.txt 2>/dev/null || true

if [ -s /tmp/top-ips.txt ]; then
    echo ""
    echo "Top IP addresses (last $DAYS_TO_CHECK days):"
    cat /tmp/top-ips.txt
    echo ""
    echo -e "${YELLOW}⚠️  Review these IPs for suspicious patterns:${NC}"
    echo "• Multiple requests from same IP"
    echo "• Requests from unexpected geographic regions"
    echo "• Known malicious IP ranges"
else
    echo -e "${YELLOW}No IP data available in logs${NC}"
fi

echo ""
echo -e "${BLUE}======= SECURITY RECOMMENDATIONS =======${NC}"
echo ""

echo -e "${YELLOW}Based on this review:${NC}"
echo ""

# Recommendations based on findings
echo "1. Enable App Check to prevent API abuse:"
echo "   https://firebase.google.com/docs/app-check"
echo ""
echo "2. Review and tighten Firebase Security Rules:"
echo "   Run: ./3-audit-firebase-security.sh"
echo ""
echo "3. Set up Cloud Armor for DDoS protection:"
echo "   https://cloud.google.com/armor"
echo ""
echo "4. Enable Firebase Emulator for local testing:"
echo "   Prevents accidental production data access during development"
echo ""
echo "5. Regular security audits:"
echo "   Run this script weekly to monitor for unusual patterns"
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ Access Review Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

echo -e "${YELLOW}Manual checks recommended:${NC}"
echo "• Authentication: https://console.firebase.google.com/project/$PROJECT_ID/authentication/users"
echo "• Firestore Data: https://console.firebase.google.com/project/$PROJECT_ID/firestore"
echo "• Storage Files:  https://console.firebase.google.com/project/$PROJECT_ID/storage"
echo "• Analytics:      https://console.firebase.google.com/project/$PROJECT_ID/analytics"
echo ""

log "Firebase access review completed"

echo -e "${GREEN}Script completed successfully!${NC}"
echo "Log file: $LOG_FILE"
