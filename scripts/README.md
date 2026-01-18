# Security Automation Scripts

This directory contains scripts to automate credential rotation and monitoring setup for the Bzaru project.

## 🚀 Quick Start

### Prerequisites

You need to install and authenticate with:
1. Google Cloud SDK (`gcloud`)
2. Firebase CLI (`firebase`)

See [CLI_SETUP.md](CLI_SETUP.md) for installation instructions.

### Authentication

```bash
# Authenticate with Google Cloud
gcloud auth login

# Set your project
gcloud config set project dev-bzaru

# Authenticate with Firebase
firebase login
```

### Run the Automation

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Run the master script (rotates credentials + sets up monitoring)
./scripts/master-security-setup.sh
```

## 📁 Script Overview

| Script | Purpose | Safe to Run |
|--------|---------|-------------|
| `1-rotate-maps-api-key.sh` | Rotates Google Maps API key | ⚠️ Deletes old key |
| `2-setup-billing-alerts.sh` | Creates billing budgets and alerts | ✅ Yes |
| `3-audit-firebase-security.sh` | Reviews Firebase security rules | ✅ Yes (read-only) |
| `4-setup-firebase-monitoring.sh` | Sets up Firebase monitoring | ✅ Yes |
| `5-review-firebase-access.sh` | Checks for suspicious Firebase activity | ✅ Yes (read-only) |
| `master-security-setup.sh` | Runs all scripts in order | ⚠️ Interactive |

## 🔐 What Gets Rotated

### Automatic
- ✅ Google Maps API key (deleted and recreated with restrictions)
- ✅ Billing alerts set up
- ✅ Firebase monitoring enabled

### Manual (requires Firebase Console)
- 🔧 Firebase API keys (need to delete in console, auto-regenerate)
- 🔧 OAuth Client IDs (only if compromised)

## 📊 Monitoring Setup

The scripts will configure:

1. **Billing Alerts** (Google Cloud)
   - Alert at 50%, 75%, 90%, 100% of budget
   - Email notifications to your account

2. **Firebase Monitoring**
   - Usage quotas tracking
   - Unusual activity detection
   - Daily usage reports

3. **Security Audits**
   - Firestore security rules check
   - Storage security rules check
   - Authentication activity review

## ⚠️ Important Notes

- **Backup First**: Scripts will create backups before making changes
- **Review Changes**: Each script shows what it will do before executing
- **Credentials**: Old API keys will be deleted permanently
- **Logs**: All actions are logged to `security-automation.log`

## 🆘 Troubleshooting

### "Permission denied" errors
```bash
chmod +x scripts/*.sh
```

### "Command not found: gcloud"
See [CLI_SETUP.md](CLI_SETUP.md) for installation.

### "Project not set"
```bash
gcloud config set project dev-bzaru
```

### "Authentication required"
```bash
gcloud auth login
firebase login
```

## 📞 Support

If you encounter issues:
1. Check the `security-automation.log` file
2. Review [SECURITY_ALERT.md](../SECURITY_ALERT.md)
3. Contact your DevOps team
