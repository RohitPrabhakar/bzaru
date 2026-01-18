# Remaining Work - Technical Debt & Improvements

This document tracks what was identified in the original security audit and what still needs to be addressed.

---

## ✅ COMPLETED (Security Issues)

### Critical Security - FIXED ✅
- [x] Removed hardcoded Google Maps API key from source code
- [x] Removed Firebase config files from git tracking
- [x] Cleaned git history (removed sensitive files from ALL commits)
- [x] Implemented environment variable system (.env)
- [x] Updated .gitignore to exclude sensitive files
- [x] Created comprehensive security documentation
- [x] Created automation scripts for credential rotation
- [x] Created monitoring setup scripts
- [x] Installed Firebase CLI

**Status:** Repository is now secure. Credentials are in .env (not committed).

---

## ⚠️ PENDING (Requires Action)

### 1. Credential Rotation - ACTION REQUIRED ⚠️

**Status:** Scripts created but not executed

**What needs to be done:**
- [ ] Install Google Cloud SDK (`./scripts/install-gcloud.sh`)
- [ ] Authenticate (`gcloud auth login` && `firebase login`)
- [ ] Run automation (`./scripts/master-security-setup.sh`)

**This will:**
- Rotate Google Maps API key
- Set up billing alerts
- Audit Firebase security
- Configure monitoring
- Review access logs

**Impact:** HIGH - Exposed credentials are still active until rotated

**Time:** ~20 minutes

**Dependencies:** Internet access for gcloud installation

---

## ❌ NOT STARTED (Technical Debt)

### 2. Severely Outdated Dependencies - HIGH PRIORITY ⚠️

**Status:** Not addressed

#### Dart SDK Migration
**Current:** `>=2.7.0 <3.0.0` (pre-null safety)
**Target:** `>=3.0.0` (with null safety)

**Issues:**
- Missing null safety (major security & stability feature)
- 3+ major versions behind current Dart (3.5+)
- Missing modern language features
- Performance improvements unavailable

**Impact:** HIGH
- Potential null reference errors
- Missing security patches
- Compatibility issues with modern packages
- Unable to use latest Flutter features

**Effort:** 2-3 days (significant refactoring required)

**Tasks:**
- [ ] Update Dart SDK constraint in pubspec.yaml
- [ ] Run `dart migrate` tool
- [ ] Fix null safety issues throughout codebase
- [ ] Update deprecated syntax (Key key → Key? key)
- [ ] Test thoroughly

---

#### Firebase Packages - HIGH PRIORITY ⚠️

**Current versions (2-3 years old):**
```yaml
firebase_core: ^1.0.3        # Latest: ~3.x
firebase_auth: ^1.0.2        # Latest: ~5.x
cloud_firestore: ^1.0.4      # Latest: ~5.x
firebase_storage: ^8.0.2     # Latest: ~12.x
firebase_analytics: ^8.0.2   # Latest: ~11.x
firebase_crashlytics: ^2.0.5 # Latest: ~4.x
```

**Issues:**
- Missing critical security patches
- Breaking changes in authentication
- Performance improvements unavailable
- New features not accessible
- Potential compatibility issues

**Impact:** HIGH
- Security vulnerabilities
- Missing bug fixes
- Reduced performance
- Authentication issues possible

**Effort:** 1-2 days

**Tasks:**
- [ ] Update Firebase packages to latest versions
- [ ] Review breaking changes documentation
- [ ] Update Firebase initialization code
- [ ] Update authentication flows
- [ ] Update Firestore queries (syntax changes)
- [ ] Test all Firebase functionality
- [ ] Update error handling

**Breaking changes to address:**
- Firebase initialization (moved to firebase_options.dart)
- Auth state changes API
- Firestore query syntax changes
- Storage reference changes

---

#### Deprecated Packages - MEDIUM PRIORITY

**Deprecated packages in use:**

1. **`charts_flutter: ^0.10.0`** - DEPRECATED
   - **Status:** No longer maintained
   - **Replacement:** `fl_chart` or `syncfusion_flutter_charts`
   - **Impact:** MEDIUM - used in business dashboard
   - **Effort:** 1 day
   - **Files affected:**
     - `lib/ui/pages/business/dashboard/widgets/dashboard_chart.dart`

2. **`geocoder: ^0.2.1`** - DEPRECATED
   - **Status:** No longer maintained
   - **Replacement:** `geocoding` (official Flutter package)
   - **Impact:** MEDIUM - used for address lookups
   - **Effort:** 0.5 days
   - **Files affected:**
     - Address lookup functionality
     - Store location features

**Tasks:**
- [ ] Replace charts_flutter with fl_chart
  - Migrate chart configurations
  - Update chart data structures
  - Update UI code
  - Test all dashboard charts
- [ ] Replace geocoder with geocoding package
  - Update address lookup code
  - Update location search
  - Test geocoding functionality

---

### 3. Incomplete Implementation - MEDIUM PRIORITY

**Status:** 27 TODO comments found

#### Critical TODOs (must be completed):

**Configuration Missing:**
```dart
// lib/helper/constants.dart
static const apiBaseUrl = ""; //TODO: ADD BASE URL
static const privacyTermsLink = ""; //TODO: CHANGE
```

**Impact:** MEDIUM
- API calls will fail without base URL
- Privacy policy link is broken (required for app stores)

**Tasks:**
- [ ] Set up backend API endpoint (or remove if not using)
- [ ] Create privacy policy page
- [ ] Update privacy policy link

---

#### Localization Incomplete - LOW PRIORITY

**Issues:**
- Many hardcoded strings not localized
- English & Hindi support advertised but incomplete

**Files with missing localization:**
- `lib/ui/pages/personal/account-settings/c_account_settings.dart`
- `lib/ui/pages/business/dashboard/widgets/dashboard_chart.dart`
- Multiple other UI files

**Impact:** LOW-MEDIUM
- Poor user experience for Hindi speakers
- Incomplete feature

**Effort:** 2-3 days

**Tasks:**
- [ ] Extract all hardcoded strings to locale files
- [ ] Complete Hindi translations
- [ ] Test language switching
- [ ] Ensure all UI text is localized

---

#### Commented Out Features

**Example:**
```dart
// lib/ui/pages/personal/explore/explore_screen.dart:275
// _buildPopularStores(), //TODO: POPULAR STORES
```

**Tasks:**
- [ ] Review all commented code
- [ ] Either implement or remove
- [ ] Document decisions

---

### 4. Code Quality Issues - LOW PRIORITY

#### No CI/CD Pipeline

**Status:** Not implemented

**Missing:**
- No GitHub Actions workflows
- No automated testing
- No automated builds
- No deployment automation

**Impact:** MEDIUM
- Manual testing required
- Higher risk of bugs
- Slower development cycle

**Effort:** 1-2 days

**Tasks:**
- [ ] Create `.github/workflows/` directory
- [ ] Add Flutter CI workflow:
  - Run `flutter analyze`
  - Run `flutter test`
  - Build Android APK
  - Build iOS IPA
- [ ] Add security scanning workflow
- [ ] Add dependency update automation (Dependabot)

**Example workflow needed:**
```yaml
# .github/workflows/flutter-ci.yml
name: Flutter CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
      - run: flutter build apk
```

---

#### Pre-Null Safety Code Patterns

**Examples:**
```dart
// Old syntax (pre-null safety)
const BzaruApp({Key key, @required this.home})

// Should be:
const BzaruApp({Key? key, required this.home})
```

**Status:** Will be fixed during Dart SDK migration

---

#### No Automated Testing

**Status:** Minimal tests

**Current test coverage:** Unknown (likely <10%)

**Impact:** MEDIUM
- Higher risk of regressions
- Difficult to refactor safely
- Manual testing burden

**Effort:** Ongoing (should be continuous)

**Tasks:**
- [ ] Add unit tests for business logic
- [ ] Add widget tests for UI components
- [ ] Add integration tests for critical flows
- [ ] Set up test coverage reporting
- [ ] Aim for 80%+ coverage

---

### 5. Environment Management - PARTIAL ⚠️

**Status:** Partially implemented

**What's done:**
- ✅ Environment variables with .env
- ✅ Constants loaded from environment

**What's missing:**
- [ ] Separate dev/staging/prod environments
- [ ] Environment-specific Firebase projects
- [ ] Environment-specific API endpoints
- [ ] Build flavors for Android/iOS

**Impact:** MEDIUM
- Development uses production database
- Risk of corrupting production data during testing
- No proper staging environment

**Effort:** 1-2 days

**Tasks:**
- [ ] Create separate .env files:
  - `.env.development`
  - `.env.staging`
  - `.env.production`
- [ ] Set up Android build flavors
- [ ] Set up iOS schemes
- [ ] Configure separate Firebase projects
- [ ] Update build scripts

---

## 📊 Priority Summary

### 🔴 HIGH PRIORITY (Do First)

1. **Execute credential rotation** (20 min)
   - Run security automation scripts
   - Rotate exposed API keys
   - Set up monitoring

2. **Update Firebase packages** (1-2 days)
   - Security patches needed
   - Breaking changes to handle

3. **Migrate to Dart 3 + Null Safety** (2-3 days)
   - Major stability improvement
   - Required for modern packages

4. **Complete missing configuration** (2-4 hours)
   - Add API base URL
   - Add privacy policy link

### 🟡 MEDIUM PRIORITY (Do Next)

5. **Replace deprecated packages** (1-2 days)
   - charts_flutter → fl_chart
   - geocoder → geocoding

6. **Set up CI/CD pipeline** (1-2 days)
   - Automated testing
   - Build automation

7. **Environment management** (1-2 days)
   - Separate dev/staging/prod

### 🟢 LOW PRIORITY (Nice to Have)

8. **Complete localization** (2-3 days)
   - Finish Hindi translations
   - Extract hardcoded strings

9. **Add automated tests** (ongoing)
   - Unit tests
   - Widget tests
   - Integration tests

10. **Code cleanup** (ongoing)
    - Remove commented code
    - Update documentation
    - Refactor deprecated patterns

---

## 📅 Recommended Timeline

### Week 1: Security & Critical Updates
- Day 1: Execute credential rotation + monitoring setup
- Day 2-3: Update Firebase packages
- Day 4-5: Migrate to Dart 3 + null safety
- Day 5: Complete missing configuration

### Week 2: Quality & Infrastructure
- Day 6-7: Replace deprecated packages
- Day 8-9: Set up CI/CD pipeline
- Day 10: Environment management setup

### Week 3+: Ongoing Improvements
- Complete localization
- Add automated tests
- Code cleanup and refactoring

---

## 🎯 Success Criteria

**Minimum Viable (Must Complete):**
- [x] Security issues resolved (DONE)
- [ ] Credentials rotated
- [ ] Firebase packages updated
- [ ] Dart 3 migration complete
- [ ] API base URL configured
- [ ] Privacy policy added

**Production Ready (Recommended):**
- [ ] All deprecated packages replaced
- [ ] CI/CD pipeline running
- [ ] Environment separation
- [ ] 80%+ test coverage
- [ ] Complete localization

**Ideal State:**
- [ ] All TODOs resolved
- [ ] Full automation
- [ ] Comprehensive monitoring
- [ ] Complete documentation

---

## 📝 Notes

- Security work is DONE ✅
- Credential rotation is scripted but needs execution ⚠️
- Technical debt is significant but manageable
- Most issues are standard maintenance work
- No critical bugs identified (just outdated code)

---

## 🔗 Related Documents

- [SECURITY_ALERT.md](SECURITY_ALERT.md) - Credential rotation guide
- [INSTALLATION_STATUS.md](INSTALLATION_STATUS.md) - CLI setup status
- [scripts/README.md](scripts/README.md) - Automation scripts
- Package updates: https://pub.dev/packages
- Dart migration: https://dart.dev/null-safety/migration-guide
- Firebase updates: https://firebase.google.com/support/release-notes/android

---

**Last Updated:** 2026-01-18
**Next Review:** After credential rotation completion
