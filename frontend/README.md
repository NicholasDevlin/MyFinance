# MyFinance Flutter App

Flutter mobile application for personal finance management.

## Features

- User authentication and registration
- Account management with multiple account types
- Income and expense tracking
- Receipt image upload for expenses
- Interactive dashboard with charts
- Transaction history and filtering
- Category-based organization

## Getting Started

### Prerequisites

- Flutter SDK (3.0+)
- Android Studio or VS Code
- Android device/emulator

### Installation

1. Install dependencies:
```bash
flutter pub get
```

2. Configure API endpoint in `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://10.0.2.2:3000'; // For Android emulator
// static const String baseUrl = 'http://localhost:3000'; // For iOS simulator
```

3. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart              # App entry point
├── models/                # Data models
│   ├── user.dart
│   ├── account.dart
│   ├── transaction.dart
│   └── category.dart
├── providers/             # State management
│   ├── auth_provider.dart
│   ├── accounts_provider.dart
│   ├── transactions_provider.dart
│   ├── categories_provider.dart
│   └── dashboard_provider.dart
├── screens/               # UI screens
│   ├── auth/
│   ├── home/
│   ├── accounts/
│   └── transactions/
├── services/              # API services
│   └── api_service.dart
├── theme/                 # App theming
│   └── app_theme.dart
└── widgets/               # Reusable components
    ├── dashboard_card.dart
    └── account_card.dart
```

## Key Features

### Authentication
- Secure login/register with JWT
- Automatic token management
- User profile management

### Account Management
- Multiple account types (Bank, Cash, Credit Card, E-Wallet)
- Real-time balance tracking
- Account creation and management

### Transaction Tracking
- Income and expense recording
- Category organization
- Receipt image upload
- Transaction history with filters

### Dashboard
- Monthly overview charts
- Spending analytics
- Balance summaries
- Category breakdowns

## State Management

The app uses the Provider pattern for state management with the following providers:

- **AuthProvider**: User authentication state
- **AccountsProvider**: Account data and operations
- **TransactionsProvider**: Transaction management
- **CategoriesProvider**: Category data
- **DashboardProvider**: Dashboard analytics

## API Integration

The app communicates with the NestJS backend through REST APIs using Dio HTTP client. All API calls are centralized in the `ApiService` class with automatic token management and error handling.

## Building for Release

```bash
flutter build apk --release
```

## Dependencies

Key dependencies used in the project:

- `provider`: State management
- `dio`: HTTP client
- `shared_preferences`: Local storage
- `fl_chart`: Charts and graphs
- `image_picker`: Camera/gallery access
- `intl`: Date formatting
- `email_validator`: Email validation