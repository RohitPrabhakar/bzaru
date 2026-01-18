# Bzaru - Local Marketplace App

A Flutter-based hyperlocal e-commerce marketplace connecting merchants with customers in their area.

## 🚨 SECURITY SETUP REQUIRED

**Before running this app, you MUST complete the security setup:**

👉 **Read [SECURITY.md](SECURITY.md) for detailed setup instructions**

⚠️ **Read [SECURITY_ALERT.md](SECURITY_ALERT.md) for information about previously exposed credentials**

### Quick Start:

```bash
# 1. Copy the environment template
cp .env.example .env

# 2. Edit .env and add your actual API keys
# 3. Add Firebase config files (see SECURITY.md)
# 4. Run the app
flutter run
```

---

## 📱 About Bzaru

Bzaru is a dual-sided marketplace application for local commerce:

- **For Merchants:** Manage inventory, process orders, communicate with customers
- **For Customers:** Browse local stores, place orders, track deliveries

### Key Features

- 🏪 Store management for local merchants
- 🛒 Shopping cart and checkout
- 📦 Order tracking (placed → packed → delivery → complete)
- 💬 In-app chat between merchants and customers
- 📍 Location-based store discovery
- 💳 UPI payment integration
- 🌍 Multi-language support (English, Hindi)
- 📊 Business analytics dashboard

---

## 🛠️ Tech Stack

- **Framework:** Flutter (Dart)
- **Backend:** Firebase (Auth, Firestore, Storage, Analytics)
- **State Management:** Provider
- **Maps:** Google Maps
- **Payments:** UPI
- **Local DB:** SQLite

---

## 📋 Prerequisites

- Flutter SDK (2.7.0 or higher)
- Android Studio / Xcode
- Firebase account
- Google Cloud account (for Maps API)

---

## 🚀 Setup & Installation

### 1. Clone the Repository

```bash
git clone <repository-url>
cd bzaru
```

### 2. Configure Environment

See [SECURITY.md](SECURITY.md) for detailed instructions on setting up:
- Environment variables
- API keys
- Firebase configuration

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Run the App

```bash
# Development mode
flutter run

# Release mode
flutter run --release
```

---

## 📁 Project Structure

```
lib/
├── app.dart                 # Main app configuration
├── main.dart               # App entry point
├── locator.dart           # Dependency injection
├── helper/                # Utilities and constants
├── model/                 # Data models
├── providers/             # State management
├── resource/              # API and Firebase services
├── ui/
│   ├── pages/
│   │   ├── business/     # Merchant-side screens
│   │   ├── personal/     # Customer-side screens
│   │   └── common/       # Shared screens
│   ├── theme/            # App theming
│   └── widgets/          # Reusable UI components
└── locale/               # Internationalization
```

---

## 🔐 Security

This project implements security best practices:

- ✅ Environment variables for sensitive data
- ✅ API keys excluded from version control
- ✅ Firebase config files gitignored
- ✅ Comprehensive security documentation

**See [SECURITY.md](SECURITY.md) for complete security guidelines.**

---

## 🤝 Contributing

1. Create a feature branch
2. Make your changes
3. Ensure all secrets remain in `.env` (never commit them!)
4. Submit a pull request

---

## 📄 License

[Add your license here]

---

## 📞 Support

For security issues, see [SECURITY.md](SECURITY.md)

For general questions, contact [your contact info]
