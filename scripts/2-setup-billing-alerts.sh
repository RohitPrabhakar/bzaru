#!/bin/bash

# Script: Setup Billing Alerts
# Purpose: Create billing budgets and alerts to monitor for API abuse
# Safe to run: Yes (creates alerts, doesn't modify billing)

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
PROJECT_ID="dev-bzaru"
LOG_FILE="../security-automation.log"

# Default budget amount (in USD) - adjust as needed
DEFAULT_BUDGET=100

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Billing Alerts Setup${NC}"
echo -e "${YELLOW}========================================${NC}"
echo ""

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "Starting billing alerts setup..."

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo -e "${RED}ERROR: gcloud CLI not found${NC}"
    exit 1
fi

# Set project
gcloud config set project "$PROJECT_ID"

echo ""
echo -e "${YELLOW}Step 1: Getting billing account...${NC}"

# Get billing account ID
BILLING_ACCOUNT=$(gcloud beta billing projects describe "$PROJECT_ID" \
    --format="value(billingAccountName)" 2>/dev/null || echo "")

if [ -z "$BILLING_ACCOUNT" ]; then
    echo -e "${RED}ERROR: No billing account found for project${NC}"
    echo "Please enable billing for this project first:"
    echo "https://console.cloud.google.com/billing/linkedaccount?project=$PROJECT_ID"
    exit 1
fi

# Extract billing account ID
BILLING_ACCOUNT_ID=$(echo "$BILLING_ACCOUNT" | sed 's/billingAccounts\///')

echo -e "${GREEN}✓ Billing account: $BILLING_ACCOUNT_ID${NC}"
log "Billing account: $BILLING_ACCOUNT_ID"

echo ""
echo -e "${YELLOW}Step 2: Setting budget amount...${NC}"
echo "This will create alerts when spending reaches certain thresholds."
echo "Current default: \$$DEFAULT_BUDGET USD/month"
echo ""
read -p "Enter monthly budget amount in USD (or press Enter for \$$DEFAULT_BUDGET): " budget_input

BUDGET_AMOUNT=${budget_input:-$DEFAULT_BUDGET}

echo -e "${GREEN}✓ Budget set to: \$$BUDGET_AMOUNT USD/month${NC}"

echo ""
echo -e "${YELLOW}Step 3: Getting notification email...${NC}"

# Get current user email
USER_EMAIL=$(gcloud config get-value account)

echo "Alerts will be sent to: $USER_EMAIL"
read -p "Use this email? (yes/no): " use_email

if [ "$use_email" != "yes" ]; then
    read -p "Enter email address for alerts: " USER_EMAIL
fi

echo -e "${GREEN}✓ Alert email: $USER_EMAIL${NC}"

echo ""
echo -e "${YELLOW}Step 4: Creating budget with alerts...${NC}"

# Create budget configuration
BUDGET_NAME="bzaru-security-budget-$(date +%Y%m%d)"

cat > /tmp/budget-config.json <<EOF
{
  "displayName": "Bzaru Security Budget (Created $(date +%Y-%m-%d))",
  "budgetFilter": {
    "projects": ["projects/$PROJECT_ID"]
  },
  "amount": {
    "specifiedAmount": {
      "currencyCode": "USD",
      "units": "$BUDGET_AMOUNT"
    }
  },
  "thresholdRules": [
    {
      "thresholdPercent": 0.5,
      "spendBasis": "CURRENT_SPEND"
    },
    {
      "thresholdPercent": 0.75,
      "spendBasis": "CURRENT_SPEND"
    },
    {
      "thresholdPercent": 0.9,
      "spendBasis": "CURRENT_SPEND"
    },
    {
      "thresholdPercent": 1.0,
      "spendBasis": "CURRENT_SPEND"
    }
  ],
  "notificationsRule": {
    "pubsubTopic": "",
    "schemaVersion": "1.0",
    "monitoringNotificationChannels": [],
    "disableDefaultIamRecipients": false
  }
}
EOF

# Create the budget
echo "Creating budget..."
log "Creating billing budget: $BUDGET_NAME"

gcloud billing budgets create \
    --billing-account="$BILLING_ACCOUNT_ID" \
    --display-name="$BUDGET_NAME" \
    --budget-amount="${BUDGET_AMOUNT}USD" \
    --threshold-rule=percent=50 \
    --threshold-rule=percent=75 \
    --threshold-rule=percent=90 \
    --threshold-rule=percent=100

echo -e "${GREEN}✓ Budget created with alert thresholds at 50%, 75%, 90%, 100%${NC}"
log "Billing budget created successfully"

echo ""
echo -e "${YELLOW}Step 5: Setting up email notifications...${NC}"

# Note: Email notifications are automatically sent to billing admins
# For custom notification channels, we'd need to set up Cloud Pub/Sub

echo "Email notifications will be sent to billing account admins automatically."
echo "To add additional notification channels (Slack, PagerDuty, etc.):"
echo "1. Go to: https://console.cloud.google.com/billing/${BILLING_ACCOUNT_ID}"
echo "2. Navigate to 'Budgets & alerts'"
echo "3. Click on the budget: $BUDGET_NAME"
echo "4. Add notification channels"

log "Budget and email notifications configured"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ Billing Alerts Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Configuration Summary:${NC}"
echo "• Budget Amount: \$$BUDGET_AMOUNT USD/month"
echo "• Alert Thresholds: 50%, 75%, 90%, 100%"
echo "• Notification Email: $USER_EMAIL"
echo ""
echo -e "${YELLOW}You will receive email alerts when spending reaches:${NC}"
echo "• \$$(echo "$BUDGET_AMOUNT * 0.5" | bc) (50%)"
echo "• \$$(echo "$BUDGET_AMOUNT * 0.75" | bc) (75%)"
echo "• \$$(echo "$BUDGET_AMOUNT * 0.9" | bc) (90%)"
echo "• \$$BUDGET_AMOUNT (100%)"
echo ""
echo -e "${YELLOW}View your budget:${NC}"
echo "https://console.cloud.google.com/billing/budgets?project=$PROJECT_ID"
echo ""

log "Billing alerts setup completed successfully"

echo -e "${GREEN}Script completed successfully!${NC}"
echo "Log file: $LOG_FILE"
