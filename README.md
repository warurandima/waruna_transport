# Waruna Transport - Business Management App

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com/)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android-green?style=for-the-badge&logo=android)](https://www.android.com)

A private, custom-built Flutter mobile application designed to manage a localized transport and construction material delivery business (sand, metal/stones, bricks, cement, etc.) in Sri Lanka. The application features native **Sinhala localization (සිංහල)** with bilingual support for seamless business operations.

---

## 🚀 Key Features

- 🔐 **Secure Local PIN Authentication**
  - Fast, privacy-first 4-digit PIN access.
  - Instant auto-login upon entering 4 digits.
  - Built-in PIN reset and update mechanism.
  - Logout clears session tokens securely via `shared_preferences`.

- 🚚 **Custom Pure-Code Pixel Art Splash Animation**
  - Bespoke 8-bit retro aesthetic tipper truck animation built purely in Flutter widgets and math curves (no heavyweight GIF/Lottie).
  - Tipper body tilts and unloads 19 granular animated sand particles onto a dashed road before driving smoothly off-screen.

- 📊 **Dynamic Dashboard & Financial Reporting**
  - Real-time income, expense, and net profit metrics.
  - Prominent Month/Year global dropdown filter (recalculates stats dynamically for any historical or current month).
  - Quick-view banner for vehicle service countdowns and tomorrow's scheduled deliveries.

- 📦 **Order Management (Full CRUD)**
  - Track materials: Sand (වැලි), Metal/Stones (ගල්), Bricks (ගඩොල්), Cement (සිමෙන්ති), Soil (පස්), or Custom materials.
  - Cash vs. Credit order tracking with automated balance syncing.
  - One-tap status updates (Pending vs. Completed).
  - Edit and delete orders with automatic debtor balance recalculation.
  - Grouped by Date descending with styled date header banners.
  - Filter chips: All (සියල්ල), Pending (ක්‍රියාත්මක වෙමින්), Completed (සම්පූර්ණයි).

- 💸 **Expense & Maintenance Tracking (Full CRUD)**
  - Categorize business expenses: Fuel (තෙල්), Vehicle Maintenance (නඩත්තු), Tires (ටයර්), and Custom Types (වෙනත්).
  - Edit and delete existing expenses with safety confirmation dialogs.
  - Grouped by Date descending with date header banners.
  - Filter chips: All (සියල්ල), Fuel (තෙල්), Maintenance (නඩත්තු), Tires (ටයර්), Other (වෙනත්).

- 👥 **Debtors Management (ණය කළමනාකරණය)**
  - Real-time debtor directory with total outstanding debt calculations.
  - Detailed debtor transaction ledger (auto-populated when a credit order is created).
  - Partial or full payment settlement with balance reduction.
  - Delete debtor profiles with confirmation.

- ⏰ **Local Notifications & Future Order Reminders**
  - Standalone reminder module to schedule future delivery targets without distorting current financial records.
  - Automated local notifications scheduled for **6:00 AM** on the target delivery date using `flutter_local_notifications` and `timezone`.
  - Filter chips (All, Pending, Completed) and Date-grouped lists.

- 📅 **Maintenance Calendar (නඩත්තු කැලැන්ඩරය)**
  - Interactive calendar view powered by `table_calendar`.
  - Visual color-coded event markers on key maintenance milestones:
    - 🔵 **Blue Marker**: Last Service Date (අවසන් සර්විස් කිරීම)
    - 🔴 **Red Marker**: Next Service Due Date (ඊළඟ සර්විස් කිරීම)
    - 🟢 **Green Marker**: Last Tire Replacement Date (ටයර් මාරුව)
  - Milestone summary cards showing remaining days and operational health.

- 🏦 **Bank Account Details Storage**
  - Manage bank accounts (Account Name, Account Number, Bank Name, Branch).
  - One-tap quick copy to clipboard for fast sharing with customers.
  - Full add, edit, and delete support.

- 📄 **Monthly PDF Business Reports**
  - Generates comprehensive PDF statements showing monthly income, expenses, net profit, and itemized transaction tables.
  - Full **Sinhala Unicode** font support rendered via Google Noto Sans Sinhala (`PdfGoogleFonts.notoSansSinhalaRegular` & `PdfGoogleFonts.notoSansSinhalaBold`), preventing box glyphs.
  - Instant print, preview, or share via standard Android share sheets.

- 🎨 **Modern UI / UX**
  - Dark / Light Mode theme toggle persisted across app restarts.
  - Navigation Drawer for fast, structured navigation across all features.
  - Micro-interactions, shimmers, and scale transitions using `flutter_animate`.

---

## 🛠️ Tech Stack

- **Framework:** [Flutter](https://flutter.dev) (Dart 3+)
- **Backend / Database:** [Firebase Cloud Firestore](https://firebase.google.com/products/firestore) (Real-time synchronization)
- **Local Persistence:** [`shared_preferences`](https://pub.dev/packages/shared_preferences)
- **UI Animations:** [`flutter_animate`](https://pub.dev/packages/flutter_animate)
- **Local Push Notifications:** [`flutter_local_notifications`](https://pub.dev/packages/flutter_local_notifications), [`timezone`](https://pub.dev/packages/timezone)
- **Calendar:** [`table_calendar`](https://pub.dev/packages/table_calendar)
- **PDF Generation & Printing:** [`pdf`](https://pub.dev/packages/pdf), [`printing`](https://pub.dev/packages/printing)
- **Typography:** [`google_fonts`](https://pub.dev/packages/google_fonts) (Noto Sans Sinhala)
- **State Management:** [`provider`](https://pub.dev/packages/provider)

---

## 📁 Project Architecture

```
lib/
├── main.dart                       # App entry point & multi-provider setup
├── models/
│   ├── bank_account_model.dart     # Bank account data structure
│   ├── debtor_model.dart           # Debtor profile & transaction history
│   ├── expense_model.dart          # Expense entry schema (Fuel, Maintenance, Tires)
│   ├── order_model.dart            # Material delivery order schema
│   ├── reminder_model.dart         # Future delivery reminder schema
│   └── service_model.dart          # Vehicle service & tire change tracking
├── providers/
│   ├── app_provider.dart           # App-wide state management
│   └── theme_provider.dart         # Dark / Light theme toggle & persistence
├── screens/
│   ├── add_expense_screen.dart     # Add / Edit expense form
│   ├── add_order_screen.dart       # Add / Edit order form
│   ├── add_reminder_screen.dart    # Add / Edit delivery reminder form
│   ├── bank_details_screen.dart    # Bank account directory & management
│   ├── dashboard_screen.dart       # Main hub (Home, Orders, Expenses, Drawer)
│   ├── debtors_screen.dart         # Debtors list & ledger detail screen
│   ├── login_screen.dart           # 4-digit PIN authentication screen
│   ├── maintenance_calendar_screen.dart # Interactive maintenance calendar
│   ├── reminders_screen.dart       # Order reminders & delivery schedule tab
│   ├── reset_pin_screen.dart       # PIN reset & verification screen
│   ├── settings_screen.dart        # Theme, service date pickers, logout
│   └── splash_screen.dart          # Splash screen hosting pixel animation
├── services/
│   ├── firestore_service.dart      # Centralized Cloud Firestore CRUD & logic
│   ├── notification_service.dart   # Local notification scheduler
│   └── pdf_service.dart            # PDF generator with Sinhala font support
├── utils/
│   ├── app_colors.dart             # Primary & secondary palette tokens
│   └── page_transitions.dart      # Custom slide-fade route transitions
└── widgets/
    └── pixel_truck_animation.dart  # 8-bit pixel tipper truck unloading animation
```

---

## ⚙️ Setup & Installation

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.24.0 or higher recommended)
- [Android Studio](https://developer.android.com/studio) / VS Code with Flutter extensions
- Android device or emulator running Android 8.0+ (API 26+)

### Installation Steps

1. **Clone the repository:**
   ```bash
   git clone https://github.com/warurandima/waruna_transport.git
   cd waruna_transport/waruna_transport
   ```

2. **Install project dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase:**
   - Place your `google-services.json` file inside the `android/app/` directory.

4. **Run the App:**
   ```bash
   flutter run
   ```

5. **Build Release APK:**
   ```bash
   flutter build apk --release
   ```

---

## 🔒 Security & Privacy

- Designed strictly as an internal business tool.
- Sensitive financial data and debtor records reside in your private Cloud Firestore instance.
- Access is guarded locally by a 4-digit PIN stored securely on device.

---

## 📄 License

This software is private and proprietary to **Waruna Transport**. All rights reserved.
