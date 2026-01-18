# CLI Tools Installation Status

## ✅ What's Already Installed

### 1. Node.js ✅ INSTALLED
- **Version:** v22.21.1
- **Location:** `/opt/node22/bin/node`
- **Status:** Ready to use

### 2. npm ✅ INSTALLED
- **Version:** 10.9.4
- **Location:** `/opt/node22/bin/npm`
- **Status:** Ready to use

### 3. Firebase CLI ✅ INSTALLED
- **Version:** 15.3.1
- **Installed via:** npm global package
- **Status:** Ready to use
- **Verify:** Run `firebase --version`

---

## ⚠️ What Needs Installation

### Google Cloud SDK (gcloud) ❌ NOT YET INSTALLED

**Status:** Network restrictions prevented automatic installation

**You have 3 options:**

#### Option 1: Run the Installer Script (Recommended when you have internet)
```bash
cd /home/user/bzaru/scripts
./install-gcloud.sh
```

This script will:
- Download Google Cloud SDK
- Install it to `~/google-cloud-sdk`
- Add it to your PATH
- Verify the installation

#### Option 2: Manual Installation via Package Manager
```bash
# Add Google Cloud SDK repository
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# Import Google Cloud public key
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg

# Update and install
sudo apt-get update
sudo apt-get install google-cloud-sdk
```

#### Option 3: Manual Download
1. Visit: https://cloud.google.com/sdk/docs/install#linux
2. Download: `google-cloud-cli-linux-x86_64.tar.gz`
3. Extract:
   ```bash
   tar -xzf google-cloud-cli-linux-x86_64.tar.gz -C ~/
   ```
4. Install:
   ```bash
   ~/google-cloud-sdk/install.sh
   ```
5. Add to PATH (add to `~/.bashrc`):
   ```bash
   export PATH="$HOME/google-cloud-sdk/bin:$PATH"
   ```

---

## 🔐 Authentication Setup

Once Google Cloud SDK is installed, follow these steps:

### 1. Authenticate with Google Cloud
```bash
gcloud auth login
```
This will open a browser window for you to sign in with your Google account.

### 2. Set Your Project
```bash
gcloud config set project dev-bzaru
```

### 3. Authenticate with Firebase
```bash
firebase login
```
This will also open a browser for authentication.

### 4. Enable Application Default Credentials
```bash
gcloud auth application-default login
```
This allows the scripts to authenticate automatically.

### 5. Verify Setup
```bash
# Check gcloud
gcloud projects list

# Check Firebase
firebase projects:list

# You should see "dev-bzaru" in both lists
```

---

## 🚀 Run the Security Automation

Once authenticated, you can run the credential rotation and monitoring setup:

```bash
cd /home/user/bzaru/scripts
./master-security-setup.sh
```

This will:
1. ✅ Rotate Google Maps API key
2. ✅ Set up billing alerts
3. ✅ Audit Firebase security
4. ✅ Configure monitoring
5. ✅ Review access & activity

---

## 📋 Quick Verification Checklist

Before running the automation, verify:

- [ ] `node --version` shows v22.21.1 or higher
- [ ] `npm --version` shows 10.9.4 or higher
- [ ] `firebase --version` shows 15.3.1 or higher
- [ ] `gcloud version` shows installed version
- [ ] `gcloud auth list` shows your authenticated account
- [ ] `firebase projects:list` shows dev-bzaru project

---

## ⚠️ Current Network Restrictions

**Issue:** External downloads via `curl` are blocked with HTTP 403 errors.

**Affected:**
- Direct Google Cloud SDK installation

**Workaround:**
- Use the installer script when you have proper internet access
- Or manually download and install Google Cloud SDK

**Not Affected:**
- npm packages (Firebase CLI installed successfully)
- Internal apt repositories

---

## 🆘 Troubleshooting

### "gcloud: command not found" after installation
```bash
# Reload your shell
source ~/.bashrc

# Or manually add to PATH
export PATH="$HOME/google-cloud-sdk/bin:$PATH"
```

### "Permission denied" when running scripts
```bash
chmod +x /home/user/bzaru/scripts/*.sh
```

### Can't authenticate (browser doesn't open)
```bash
# Use no-browser mode
gcloud auth login --no-launch-browser
firebase login --no-localhost
```

---

## 📞 Next Steps

1. **Install Google Cloud SDK:**
   - Run `./scripts/install-gcloud.sh` when you have internet access
   - Or follow manual installation instructions above

2. **Authenticate:**
   - Follow the authentication setup section above

3. **Run Security Automation:**
   - Execute `./scripts/master-security-setup.sh`

4. **Monitor for 7 Days:**
   - Check billing alerts daily
   - Review monitoring dashboards
   - Watch for suspicious activity

---

## 📚 Documentation

- Google Cloud SDK: https://cloud.google.com/sdk/docs
- Firebase CLI: https://firebase.google.com/docs/cli
- Security Alert: [SECURITY_ALERT.md](SECURITY_ALERT.md)
- Security Guide: [SECURITY.md](SECURITY.md)
- Scripts README: [scripts/README.md](scripts/README.md)
