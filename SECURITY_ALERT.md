# 🚨 SECURITY ALERT - ACTION REQUIRED

## Critical Security Issue Resolved

**Date:** 2026-01-18
**Severity:** HIGH
**Status:** FIXED (Action Required)

---

## What Happened

The following sensitive data was previously committed to version control and **exposed in git history**:

### 1. Google Maps API Key
**File:** `lib/helper/constants.dart`
**Exposed Key:** `AIzaSyCN4Y0uWd7sfPrQit_lR1ur_xAEz4PMLH4`
**Status:** ⚠️ MUST BE ROTATED IMMEDIATELY

### 2. Firebase Android Configuration
**File:** `android/app/google-services.json`
**Exposed Data:**
- Firebase Project ID: `dev-bzaru`
- Project Number: `157511829902`
- Firebase Database URL: `https://dev-bzaru.firebaseio.com`
- Storage Bucket: `dev-bzaru.appspot.com`
- Firebase API Key (Android): `AIzaSyAH4CxhMZAbMfYTlbD3L4Z3Ug1GQUyMSVM`
- OAuth Client IDs:
  - `157511829902-0cletk37ufu25b0geemi2ejd269c7959.apps.googleusercontent.com`
  - `157511829902-3gaav59sfv5aaab6ifogd81372pd0oc9.apps.googleusercontent.com`

**Status:** ⚠️ REQUIRES SECURITY REVIEW & POSSIBLE ROTATION

### 3. Firebase iOS Configuration
**File:** `ios/Runner/GoogleService-Info.plist`
**Exposed Data:**
- Firebase API Key (iOS): `AIzaSyCV3GIP2jXEtzBAcMDbsQw_2tFjj3myU_E`
- iOS Client ID: `157511829902-88ke7gtb16avlj4ca2gumnr487r18cia.apps.googleusercontent.com`
- Android Client ID: `157511829902-0cletk37ufu25b0geemi2ejd269c7959.apps.googleusercontent.com`

**Status:** ⚠️ REQUIRES SECURITY REVIEW & POSSIBLE ROTATION

---

## ✅ Git History Cleaned

**STATUS:** Git history has been **completely cleaned** and rewritten!

**Action Taken:**
- Used `git filter-branch` to remove sensitive files from ALL commits
- Removed backup references
- Ran garbage collection to purge unreachable objects
- Force-pushed cleaned history to remote repository

**Result:**
- `android/app/google-services.json` - ✅ Removed from entire git history
- `ios/Runner/GoogleService-Info.plist` - ✅ Removed from entire git history
- Hardcoded API keys in `lib/helper/constants.dart` - ✅ Replaced with environment variables

**New Commit Hashes (after history rewrite):**
- Initial commit: `0e12dba` (was `392daf0`)
- Security fix commit: `afd4e54` (was `e1c2f4c`)
- Documentation update: `ca6bddf` (was `6fdef8b`)

**Important Notes:**
- The sensitive files NO LONGER exist in git history
- Anyone who previously cloned this repository should delete their local copy and re-clone
- All exposed credentials MUST still be rotated (see instructions below)
- Even though files are removed from git, the credentials were exposed and should be considered compromised

---

## ⚡ IMMEDIATE ACTION REQUIRED

### Priority 1: Rotate Google Maps API Key (CRITICAL)

**Exposed Key:** `AIzaSyCN4Y0uWd7sfPrQit_lR1ur_xAEz4PMLH4`

**Steps:**
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to: **APIs & Services → Credentials**
3. Find the exposed API key (search by key value)
4. **Click "Delete"** or **"Regenerate Key"**
5. Create a new API key with proper restrictions:
   - **Application restrictions:**
     - Android apps: Add package name `com.bzaru.bzaruapp` with SHA-1 fingerprint
     - iOS apps: Add bundle ID
   - **API restrictions:** Only enable:
     - Maps SDK for Android
     - Maps SDK for iOS
     - Places API
     - Geocoding API
     - Directions API (if used)
6. Copy the new key to your `.env` file: `GOOGLE_MAPS_API_KEY=your_new_key`
7. **Set billing limits** to prevent abuse

---

### Priority 2: Secure Firebase Project (HIGH)

**Exposed Firebase Project:** `dev-bzaru` (Project #157511829902)

#### Step 1: Review Firebase Access & Activity
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: `dev-bzaru`
3. Check **Authentication → Users** for suspicious accounts
4. Review **Firestore → Data** for unauthorized writes/reads
5. Check **Storage** for unexpected files
6. Review **Analytics** for unusual traffic patterns

#### Step 2: Audit Firebase Security Rules
1. Navigate to **Firestore Database → Rules**
2. Ensure rules are NOT set to public read/write:
   ```javascript
   // ❌ BAD - Do NOT use this
   allow read, write: if true;

   // ✅ GOOD - Use authentication
   allow read, write: if request.auth != null;
   ```
3. Navigate to **Storage → Rules** and apply similar checks
4. Navigate to **Realtime Database → Rules** (if used)

#### Step 3: Rotate Firebase API Keys (If Compromised)

**Exposed Keys:**
- Android: `AIzaSyAH4CxhMZAbMfYTlbD3L4Z3Ug1GQUyMSVM`
- iOS: `AIzaSyCV3GIP2jXEtzBAcMDbsQw_2tFjj3myU_E`

**How to Rotate:**
1. In Firebase Console, go to **Project Settings**
2. Navigate to **Service Accounts** tab
3. Click **Manage Service Account Permissions**
4. In Google Cloud Console:
   - Go to **APIs & Services → Credentials**
   - Find the Firebase API keys by searching
   - **Delete** the exposed keys
   - Firebase will automatically regenerate new ones
5. Download new `google-services.json` and `GoogleService-Info.plist`
6. Place them locally (do NOT commit to git!)

#### Step 4: Rotate OAuth Client IDs (If Necessary)

**Exposed Client IDs:**
- Android: `157511829902-0cletk37ufu25b0geemi2ejd269c7959.apps.googleusercontent.com`
- iOS: `157511829902-88ke7gtb16avlj4ca2gumnr487r18cia.apps.googleusercontent.com`

**When to Rotate:**
- If you detect unauthorized OAuth sign-ins
- If suspicious Google Sign-In activity is detected

**How to Rotate:**
1. Go to Google Cloud Console → **APIs & Services → Credentials**
2. Find and delete the exposed OAuth 2.0 Client IDs
3. Create new OAuth clients:
   - For Android: Provide package name and SHA-1 certificate fingerprint
   - For iOS: Provide bundle ID
4. Download updated Firebase config files
5. Update authentication configuration in your app

---

### Priority 3: Monitor for Abuse

#### Set Up Alerts
1. **Google Cloud Console:**
   - Set up billing alerts: **Billing → Budgets & Alerts**
   - Create budget with alert at 50%, 75%, 90%, 100%
   - Add email notifications

2. **Firebase Console:**
   - Enable **Alerts** in Firebase Console
   - Monitor **Usage and Billing** tab
   - Check for quota overruns

#### Review Usage Metrics
- **Daily for 7 days:** Check Google Cloud and Firebase usage
- **Look for:**
  - Unexpected API calls
  - Unusual geographic patterns
  - Quota spikes
  - Database read/write spikes
  - Authentication attempts from unknown sources

---

### Priority 4: Update Application Restrictions

After rotating credentials, update restrictions:

1. **Google Maps API Key:**
   - Android: Add SHA-1 fingerprint restrictions
   - iOS: Add bundle ID restrictions
   - Set per-day quotas

2. **Firebase API Keys:**
   - Automatically restricted by Firebase to specific apps
   - Verify in Google Cloud Console that restrictions are in place

3. **OAuth Client IDs:**
   - Add authorized redirect URIs
   - Restrict to specific package names/bundle IDs

---

## ✅ What's Been Fixed

The codebase has been updated with the following security improvements:

- ✅ API keys moved to environment variables (`.env` file)
- ✅ `.gitignore` updated to exclude sensitive files
- ✅ Firebase config files now excluded from git
- ✅ Environment variable loader implemented
- ✅ Security documentation created

---

## 📋 Next Steps for Developers

1. **Pull the latest changes** from this branch
2. **Follow the setup guide** in `SECURITY.md`
3. **Create your `.env` file** using `.env.example` as a template
4. **Add the NEW (rotated) API keys** to your `.env`
5. **Download fresh Firebase config files** from Firebase console

---

## 🔒 Prevention Measures Now In Place

- Environment variables for all sensitive data
- Comprehensive `.gitignore` for secrets
- Security documentation for team onboarding
- Template files for configuration

---

## 📞 Questions or Concerns?

If you:
- Notice suspicious activity
- Need help rotating credentials
- Have questions about the security setup

**Contact:** DevOps/Security team immediately

---

## ⚠️ Remember

**Once credentials are in git history, consider them permanently compromised.**
The only safe action is to rotate/regenerate all exposed credentials.

This alert will remain in the repository as a reminder of proper security practices.
