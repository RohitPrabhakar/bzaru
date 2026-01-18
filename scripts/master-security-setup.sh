#!/bin/bash

# Master Security Setup Script
# Purpose: Orchestrate all security automation scripts
# Rotates credentials, sets up monitoring, and audits security

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
PROJECT_ID="dev-bzaru"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/../security-automation.log"

echo -e "${CYAN}"
cat << "EOF"
╔════════════════════════════════════════════════════════════╗
║                                                            ║
║         BZARU SECURITY AUTOMATION MASTER SCRIPT            ║
║                                                            ║
║  This script will:                                         ║
║  1. Rotate exposed Google Maps API key                     ║
║  2. Set up billing alerts                                  ║
║  3. Audit Firebase security rules                          ║
║  4. Configure Firebase monitoring                          ║
║  5. Review Firebase access & activity                      ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "========== MASTER SECURITY SETUP STARTED =========="

# Check prerequisites
echo ""
echo -e "${YELLOW}Checking prerequisites...${NC}"

errors=0

if ! command -v gcloud &> /dev/null; then
    echo -e "${RED}✗ gcloud CLI not found${NC}"
    errors=$((errors + 1))
else
    echo -e "${GREEN}✓ gcloud CLI installed${NC}"
fi

if ! command -v firebase &> /dev/null; then
    echo -e "${RED}✗ Firebase CLI not found${NC}"
    errors=$((errors + 1))
else
    echo -e "${GREEN}✓ Firebase CLI installed${NC}"
fi

# Check authentication
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
    echo -e "${RED}✗ Not authenticated with gcloud${NC}"
    echo "  Run: gcloud auth login"
    errors=$((errors + 1))
else
    ACCOUNT=$(gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -1)
    echo -e "${GREEN}✓ Authenticated as: $ACCOUNT${NC}"
fi

if [ $errors -gt 0 ]; then
    echo ""
    echo -e "${RED}Prerequisites not met. Please fix the errors above.${NC}"
    echo "See CLI_SETUP.md for installation instructions."
    exit 1
fi

echo ""
echo -e "${GREEN}All prerequisites met!${NC}"

# Set project
echo ""
echo -e "${YELLOW}Setting project to: $PROJECT_ID${NC}"
gcloud config set project "$PROJECT_ID" --quiet
firebase use "$PROJECT_ID" 2>/dev/null || firebase use "$PROJECT_ID" --add

echo ""
echo -e "${CYAN}════════════════════════════════════════${NC}"
echo -e "${CYAN}           EXECUTION PLAN                ${NC}"
echo -e "${CYAN}════════════════════════════════════════${NC}"
echo ""
echo "The following scripts will be executed:"
echo ""
echo "1. [CRITICAL] Rotate Google Maps API Key"
echo "   • Deletes exposed key: AIzaSyCN4Y0uWd7sfPrQit_lR1ur_xAEz4PMLH4"
echo "   • Creates new key with restrictions"
echo "   • Updates .env file"
echo ""
echo "2. [IMPORTANT] Setup Billing Alerts"
echo "   • Creates budget with spending alerts"
echo "   • Configures email notifications"
echo "   • Sets thresholds at 50%, 75%, 90%, 100%"
echo ""
echo "3. [AUDIT] Review Firebase Security Rules"
echo "   • Analyzes Firestore rules"
echo "   • Checks Storage rules"
echo "   • Identifies security vulnerabilities"
echo ""
echo "4. [MONITORING] Setup Firebase Monitoring"
echo "   • Enables monitoring APIs"
echo "   • Creates custom metrics"
echo "   • Sets up alert policies"
echo "   • Creates monitoring dashboard"
echo ""
echo "5. [REVIEW] Review Firebase Access & Activity"
echo "   • Checks authentication logs"
echo "   • Reviews Firestore usage"
echo "   • Analyzes geographic patterns"
echo "   • Identifies suspicious activity"
echo ""

echo -e "${YELLOW}════════════════════════════════════════${NC}"
echo -e "${RED}WARNING: Script 1 will DELETE the old API key!${NC}"
echo -e "${RED}This action is IRREVERSIBLE!${NC}"
echo -e "${YELLOW}════════════════════════════════════════${NC}"
echo ""

read -p "Do you want to proceed? (type 'yes' to continue): " confirm

if [ "$confirm" != "yes" ]; then
    echo ""
    echo -e "${YELLOW}Aborted by user${NC}"
    log "Master script aborted by user"
    exit 0
fi

echo ""
echo -e "${CYAN}Starting security automation...${NC}"
echo ""

# Make all scripts executable
chmod +x "$SCRIPT_DIR"/*.sh

# Track which scripts succeeded
succeeded=()
failed=()

# Script 1: Rotate API Key
echo ""
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "${BLUE}[1/5] Rotating Google Maps API Key${NC}"
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo ""

if bash "$SCRIPT_DIR/1-rotate-maps-api-key.sh"; then
    succeeded+=("API Key Rotation")
    log "Script 1 completed successfully"
else
    failed+=("API Key Rotation")
    log "ERROR: Script 1 failed"
    echo -e "${RED}API key rotation failed. Check logs.${NC}"
fi

echo ""
read -p "Press Enter to continue to billing alerts setup..."

# Script 2: Setup Billing Alerts
echo ""
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "${BLUE}[2/5] Setting Up Billing Alerts${NC}"
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo ""

if bash "$SCRIPT_DIR/2-setup-billing-alerts.sh"; then
    succeeded+=("Billing Alerts")
    log "Script 2 completed successfully"
else
    failed+=("Billing Alerts")
    log "ERROR: Script 2 failed"
    echo -e "${YELLOW}Billing alerts setup encountered errors (non-critical)${NC}"
fi

echo ""
read -p "Press Enter to continue to security audit..."

# Script 3: Audit Firebase Security
echo ""
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "${BLUE}[3/5] Auditing Firebase Security${NC}"
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo ""

if bash "$SCRIPT_DIR/3-audit-firebase-security.sh"; then
    succeeded+=("Security Audit")
    log "Script 3 completed successfully"
else
    failed+=("Security Audit")
    log "ERROR: Script 3 failed"
fi

echo ""
read -p "Press Enter to continue to monitoring setup..."

# Script 4: Setup Monitoring
echo ""
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "${BLUE}[4/5] Setting Up Firebase Monitoring${NC}"
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo ""

if bash "$SCRIPT_DIR/4-setup-firebase-monitoring.sh"; then
    succeeded+=("Monitoring Setup")
    log "Script 4 completed successfully"
else
    failed+=("Monitoring Setup")
    log "ERROR: Script 4 failed"
    echo -e "${YELLOW}Monitoring setup encountered errors (non-critical)${NC}"
fi

echo ""
read -p "Press Enter to continue to access review..."

# Script 5: Review Access
echo ""
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "${BLUE}[5/5] Reviewing Firebase Access & Activity${NC}"
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo ""

if bash "$SCRIPT_DIR/5-review-firebase-access.sh"; then
    succeeded+=("Access Review")
    log "Script 5 completed successfully"
else
    failed+=("Access Review")
    log "ERROR: Script 5 failed"
fi

# Summary
echo ""
echo -e "${CYAN}"
cat << "EOF"
╔════════════════════════════════════════════════════════════╗
║                                                            ║
║              SECURITY AUTOMATION COMPLETE                  ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo ""
echo -e "${GREEN}✓ Completed Scripts:${NC}"
for script in "${succeeded[@]}"; do
    echo -e "  ${GREEN}✓${NC} $script"
done

if [ ${#failed[@]} -gt 0 ]; then
    echo ""
    echo -e "${RED}✗ Failed Scripts:${NC}"
    for script in "${failed[@]}"; do
        echo -e "  ${RED}✗${NC} $script"
    done
fi

echo ""
echo -e "${YELLOW}════════════════════════════════════════${NC}"
echo -e "${YELLOW}         NEXT STEPS REQUIRED             ${NC}"
echo -e "${YELLOW}════════════════════════════════════════${NC}"
echo ""

echo -e "${CYAN}1. Verify New API Key in .env${NC}"
echo "   • Check that .env has the new GOOGLE_MAPS_API_KEY"
echo "   • Test the app with the new key"
echo ""

echo -e "${CYAN}2. Add Application Restrictions${NC}"
echo "   • Go to: https://console.cloud.google.com/apis/credentials"
echo "   • Add Android package name and SHA-1 fingerprints"
echo "   • Add iOS bundle ID restrictions"
echo ""

echo -e "${CYAN}3. Review Security Audit Findings${NC}"
echo "   • Check for any security issues reported in step 3"
echo "   • Update Firebase security rules if needed"
echo ""

echo -e "${CYAN}4. Monitor for 7 Days${NC}"
echo "   • Check billing alerts daily"
echo "   • Review monitoring dashboards"
echo "   • Watch for suspicious activity"
echo ""

echo -e "${CYAN}5. Complete Manual Tasks${NC}"
echo "   • Rotate Firebase API keys (if abuse detected)"
echo "   • Set up additional notification channels"
echo "   • Configure App Check for API protection"
echo ""

echo -e "${YELLOW}════════════════════════════════════════${NC}"
echo ""

echo -e "${GREEN}Full log available at: $LOG_FILE${NC}"

echo ""
echo -e "${BLUE}Important Links:${NC}"
echo "• Google Cloud Console: https://console.cloud.google.com/home/dashboard?project=$PROJECT_ID"
echo "• Firebase Console:     https://console.firebase.google.com/project/$PROJECT_ID"
echo "• API Credentials:      https://console.cloud.google.com/apis/credentials?project=$PROJECT_ID"
echo "• Billing:              https://console.cloud.google.com/billing?project=$PROJECT_ID"
echo "• Monitoring:           https://console.cloud.google.com/monitoring?project=$PROJECT_ID"
echo ""

log "========== MASTER SECURITY SETUP COMPLETED =========="

echo -e "${GREEN}Done!${NC}"
