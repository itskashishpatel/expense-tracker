Expense Tracker

A personal finance tracking app built with Flutter and Dart to manage income and expenses manually, organize transactions, and visualize spending.

Privacy-focused by design: no bank or UPI account connection is required. The app uses Firebase Cloud Firestore for its configured backend, so review your database security rules before deploying or sharing it publicly.

✨ Features
Income and expenses: Record transactions manually.
Custom categories: Create categories with personalized icons and colors.
Financial dashboard: View current balance, total income, and total expenses.
Spending analytics: Explore weekly, monthly, and yearly bar charts, along with category breakdowns.
Transaction history: Review past transactions and delete entries with swipe gestures.
Settings: Manage your name, currency, and light or dark theme.
CSV export: Export financial records for use in spreadsheets.
Category management: Organize and customize expense categories.
📱 Screenshots
Home	Add Transaction	Statistics

	
	

🛠️ Tech Stack
Framework: Flutter
Programming language: Dart
Backend and database: Firebase Cloud Firestore
State management: flutter_bloc
Charts and analytics: fl_chart
Local preferences: shared_preferences
🏗️ Architecture
Feature-first organization under lib/screens/
BLoC/Cubit pattern for state management
Separate expense_repository package using the repository pattern
Firestore integration through the repository layer
🚀 Getting Started
Prerequisites
Flutter SDK and Dart SDK
Git
Android Studio or another supported Flutter development environment
A Firebase project configured for the target platform
Installation

Clone the repository:

git clone https://github.com/YOUR-GITHUB-USERNAME/flutter-expense-tracker.git

Open the project directory:

cd flutter-expense-tracker

Configure Firebase for your platform, if required:

flutterfire configure

Install dependencies:

flutter pub get

Run the app:

flutter run
Firebase Setup

Configure Cloud Firestore and any other Firebase services used by the application. Review your Firestore Security Rules before running the app against a real database.

Do not commit service-account private keys, passwords, or other sensitive credentials. Firebase client configuration is not a substitute for properly secured database rules.

🗺️ Roadmap

User authentication and login

Monthly budgets and spending alerts

One-tap repeat expenses

Offline support and data synchronization

👩‍💻 Developer

Kashish Patel
Built as a personal project to practice Flutter development, state management, repository architecture, and Firebase integration.
