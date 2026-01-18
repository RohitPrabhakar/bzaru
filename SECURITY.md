# Security Setup Guide

## ⚠️ CRITICAL: Environment Configuration Required

This application uses environment variables to protect sensitive data like API keys and configuration details. You **MUST** complete this setup before running the app.

---

## 🔧 Quick Setup (First Time)

### 1. Create Your Environment File

Copy the example file to create your local `.env`:

```bash
cp .env.example .env
```

### 2. Add Your API Keys

Edit `.env` and replace the placeholder values with your actual credentials:

```env
# API Configuration
API_BASE_URL=https://your-actual-api-url.com/api/v1

# Google Maps API Key
GOOGLE_MAPS_API_KEY=your_actual_google_maps_api_key

# App Links
APP_LINK=https://bzaru.com/
PRIVACY_TERMS_LINK=https://bzaru.com/privacy-policy
```

### 3. Configure Firebase

You need to add Firebase configuration files for both iOS and Android:

#### Android:
1. Download `google-services.json` from your Firebase console
2. Place it in: `android/app/google-services.json`

#### iOS:
1. Download `GoogleService-Info.plist` from your Firebase console
2. Place it in: `ios/Runner/GoogleService-Info.plist`

**⚠️ IMPORTANT:** These files are automatically ignored by git and will NOT be committed.

---

## 🔐 Security Best Practices

### What's Protected

The following files are now **excluded from version control** (via `.gitignore`):

- `.env` - Your environment variables
- `google-services.json` - Firebase Android config
- `GoogleService-Info.plist` - Firebase iOS config
- `firebase_options.dart` - Generated Firebase options
- Any files in `**/secrets/` directories

### Never Commit:

❌ **DO NOT** commit files containing:
- API keys
- Secret keys
- Database credentials
- Firebase configuration files
- OAuth client secrets

✅ **DO** commit:
- `.env.example` - Template file with placeholder values
- Code that reads from environment variables
- This security documentation

---

## 🚨 Emergency: If You Accidentally Committed Secrets

If you've already committed sensitive data to git:

1. **Immediately rotate/regenerate all exposed credentials:**
   - Regenerate Google Maps API key in Google Cloud Console
   - Regenerate any exposed API keys
   - Update Firebase security rules if needed

2. **Remove from git history:**
   ```bash
   # This is complex - contact your team lead or DevOps
   # DO NOT attempt this without backing up your work
   ```

3. **Update your `.env` with new credentials**

---

## 📋 Environment Variables Reference

| Variable | Description | Required | Example |
|----------|-------------|----------|---------|
| `API_BASE_URL` | Backend API endpoint | Yes | `https://api.bzaru.com/v1` |
| `GOOGLE_MAPS_API_KEY` | Google Maps API key | Yes | `AIzaSy...` |
| `APP_LINK` | App download/website link | No | `https://bzaru.com/` |
| `PRIVACY_TERMS_LINK` | Privacy policy URL | Recommended | `https://bzaru.com/privacy` |

---

## 🧪 Testing Configuration

To verify your setup is correct:

1. Check that `.env` file exists and has all required values
2. Verify Firebase config files are in place
3. Run the app - it should load without errors

---

## 👥 Team Setup

When a new developer joins:

1. Share this `SECURITY.md` file
2. Have them copy `.env.example` to `.env`
3. Securely share the actual API keys (use password manager, secure chat, etc.)
4. Share Firebase config files via secure channel
5. Never share credentials via email or public channels

---

## 📞 Questions?

If you need help with security setup, contact:
- Team Lead: [Contact Info]
- DevOps Team: [Contact Info]

**Remember:** Protecting credentials is everyone's responsibility!
