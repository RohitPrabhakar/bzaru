# CLI Tools Installation Guide

This guide will help you install the Google Cloud SDK and Firebase CLI tools needed for credential rotation automation.

## 📦 Google Cloud SDK Installation

### Linux / macOS

```bash
# Download and install
curl https://sdk.cloud.google.com | bash

# Restart your shell or run:
exec -l $SHELL

# Initialize gcloud
gcloud init
```

### Alternative: Package Manager

**Ubuntu/Debian:**
```bash
# Add Cloud SDK repository
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# Import Google Cloud public key
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

# Install
sudo apt-get update && sudo apt-get install google-cloud-sdk
```

**macOS (Homebrew):**
```bash
brew install --cask google-cloud-sdk
```

### Windows

Download and run the installer:
https://cloud.google.com/sdk/docs/install#windows

---

## 🔥 Firebase CLI Installation

### Using npm (Recommended)

```bash
# Install Node.js first if you don't have it
# Then install Firebase CLI globally
npm install -g firebase-tools
```

### Alternative: Standalone Binary

**Linux/macOS:**
```bash
curl -sL https://firebase.tools | bash
```

**Windows:**
Download from: https://firebase.tools

---

## ✅ Verify Installation

```bash
# Check gcloud
gcloud version

# Check firebase
firebase --version
```

Expected output:
```
Google Cloud SDK 400.0.0+
Firebase CLI v12.0.0+
```

---

## 🔐 Authentication

### Step 1: Authenticate with Google Cloud

```bash
gcloud auth login
```

This will open a browser window for you to sign in with your Google account.

### Step 2: Set Your Project

```bash
gcloud config set project dev-bzaru
```

### Step 3: Authenticate with Firebase

```bash
firebase login
```

This will also open a browser for authentication.

### Step 4: Verify Access

```bash
# Test gcloud access
gcloud projects list

# Test Firebase access
firebase projects:list
```

You should see `dev-bzaru` in both lists.

---

## 🔧 Additional Setup

### Enable Required APIs

```bash
# Enable APIs needed for automation
gcloud services enable \
  cloudresourcemanager.googleapis.com \
  serviceusage.googleapis.com \
  cloudapis.googleapis.com \
  compute.googleapis.com \
  billing.googleapis.com
```

### Set Up Application Default Credentials

```bash
gcloud auth application-default login
```

This allows scripts to authenticate automatically.

---

## ⚠️ Troubleshooting

### "gcloud: command not found"

Add to your PATH:
```bash
# Add to ~/.bashrc or ~/.zshrc
export PATH=$PATH:$HOME/google-cloud-sdk/bin
source ~/.bashrc  # or source ~/.zshrc
```

### "firebase: command not found"

If installed with npm:
```bash
# Add npm global bin to PATH
export PATH=$PATH:$(npm config get prefix)/bin
```

### Permission Issues

```bash
# Fix npm permissions (Linux/macOS)
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
export PATH=~/.npm-global/bin:$PATH
```

---

## 📚 Next Steps

Once authenticated, proceed to run the security automation scripts:

```bash
cd /home/user/bzaru/scripts
./master-security-setup.sh
```

---

## 📖 Documentation

- [Google Cloud SDK Docs](https://cloud.google.com/sdk/docs)
- [Firebase CLI Docs](https://firebase.google.com/docs/cli)
