# MyFinance - Personal Finance Management App

A full-stack personal finance management application built with Flutter (frontend) and NestJS (backend), featuring comprehensive expense tracking, income management, and financial insights.

## 🚀 Features

### User Management
- **User Registration & Authentication**: JWT-based secure authentication
- **User Profile Management**: Manage personal information and preferences

### Account Management
- **Multiple Account Types**: Support for bank accounts, cash, credit cards, and e-wallets
- **Real-time Balance Tracking**: Automatic balance updates based on transactions
- **Account Overview**: Visual representation of all accounts and total balance

### Transaction Management
- **Income Tracking**: Record income with amount, date, source, and category
- **Expense Tracking**: Track expenses with receipt image upload support
- **Transaction Categories**: Predefined and custom categories for better organization
- **Transaction History**: Comprehensive list with filtering and search capabilities

### Dashboard & Analytics
- **Monthly Overview**: Income vs expenses comparison charts
- **Spending Analytics**: Category-wise spending breakdown
- **Balance Trends**: Visual representation of financial health
- **Quick Statistics**: Key financial metrics at a glance

## 🛠 Tech Stack

### Backend (NestJS)
- **Framework**: NestJS with TypeScript
- **Database**: MySQL with TypeORM
- **Authentication**: JWT with Passport
- **File Upload**: Multer for receipt images
- **API**: RESTful APIs with comprehensive validation

### Frontend (Flutter)
- **Framework**: Flutter for Android
- **State Management**: Provider pattern
- **HTTP Client**: Dio for API communication
- **UI**: Material Design 3
- **Charts**: FL Chart for data visualization
- **Image Handling**: Image picker for receipt uploads

## 📁 Project Structure

```
myfinance/
├── backend/                 # NestJS Backend
│   ├── src/
│   │   ├── auth/           # Authentication module
│   │   ├── users/          # User management
│   │   ├── accounts/       # Account management
│   │   ├── transactions/   # Transaction handling
│   │   ├── categories/     # Category management
│   │   ├── dashboard/      # Dashboard APIs
│   │   └── main.ts         # Application entry point
│   ├── uploads/            # Receipt image storage
│   ├── package.json
│   └── .env.example
│
└── frontend/               # Flutter Frontend
    ├── lib/
    │   ├── models/         # Data models
    │   ├── providers/      # State management
    │   ├── screens/        # UI screens
    │   ├── services/       # API services
    │   ├── theme/          # App theming
    │   ├── widgets/        # Reusable components
    │   └── main.dart       # App entry point
    └── pubspec.yaml
```

## 🚀 Getting Started

### Prerequisites
- Node.js (v16 or higher)
- MySQL (v8.0 or higher)
- Flutter SDK (v3.0 or higher)
- Android Studio / VS Code

### Backend Setup

1. **Navigate to backend directory**
   ```bash
   cd backend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Set up environment variables**
   ```bash
   cp .env.example .env
   ```
   Edit `.env` file with your database credentials:
   ```
   DB_HOST=localhost
   DB_PORT=3306
   DB_USERNAME=root
   DB_PASSWORD=your_password
   DB_NAME=myfinance
   JWT_SECRET=your_jwt_secret
   ```

4. **Create MySQL database**
   ```sql
   CREATE DATABASE myfinance;
   ```

5. **Start the server**
   ```bash
   npm run start:dev
   ```
   Server will run on `http://localhost:3000`

### Frontend Setup

1. **Navigate to frontend directory**
   ```bash
   cd frontend
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Update API endpoint** (if needed)
   Edit `lib/services/api_service.dart`:
   ```dart
   static const String baseUrl = 'http://10.0.2.2:3000'; // Android emulator
   // static const String baseUrl = 'http://localhost:3000'; // iOS simulator
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 📱 App Screens

### Authentication
- **Login Screen**: Email/password authentication
- **Register Screen**: New user registration with optional profile info

### Main Navigation
- **Dashboard**: Financial overview with charts and summaries
- **Transactions**: Complete transaction history with filtering
- **Accounts**: Account management and balance tracking
- **Profile**: User settings and preferences

### Transaction Management
- **Add Income**: Income entry with categorization
- **Add Expense**: Expense tracking with receipt upload
- **Transaction Details**: Comprehensive transaction information

### Account Management
- **Add Account**: Create new financial accounts
- **Account List**: Overview of all accounts with balances
- **Account Details**: Individual account management

## 🔧 API Endpoints

### Authentication
- `POST /auth/register` - User registration
- `POST /auth/login` - User login
- `GET /auth/profile` - Get user profile

### Accounts
- `GET /accounts` - Get user accounts
- `POST /accounts` - Create new account
- `PATCH /accounts/:id` - Update account
- `DELETE /accounts/:id` - Delete account

### Transactions
- `GET /transactions` - Get transactions (with filters)
- `POST /transactions` - Create transaction (with file upload)
- `PATCH /transactions/:id` - Update transaction
- `DELETE /transactions/:id` - Delete transaction
- `GET /transactions/summary/:year/:month` - Monthly summary

### Categories
- `GET /categories` - Get categories
- `POST /categories` - Create category

### Dashboard
- `GET /dashboard` - Dashboard overview
- `GET /dashboard/yearly/:year` - Yearly statistics
- `GET /dashboard/spending-by-category` - Category breakdown

## 🎨 Design Features

- **Material Design 3**: Modern, consistent UI design
- **Responsive Layout**: Optimized for various screen sizes
- **Color-coded Categories**: Visual distinction for different transaction types
- **Interactive Charts**: Engaging data visualization
- **Dark/Light Theme Support**: User preference accommodation

## 🔒 Security Features

- **JWT Authentication**: Secure token-based authentication
- **Password Hashing**: Bcrypt for secure password storage
- **Input Validation**: Comprehensive data validation
- **File Upload Security**: Image file type and size validation
- **API Rate Limiting**: Protection against abuse

## 📊 Database Schema

### Users Table
- User credentials and profile information
- Relationships to accounts and transactions

### Accounts Table
- Financial account details with balance tracking
- Support for multiple account types

### Transactions Table
- Complete transaction records with metadata
- Foreign keys to users, accounts, and categories
- Optional receipt image storage

### Categories Table
- Predefined and custom transaction categories
- Color coding for visual organization

## 🚀 Deployment

### Backend Deployment
1. Set up production MySQL database
2. Configure environment variables
3. Build the application: `npm run build`
4. Start production server: `npm run start:prod`

### Frontend Deployment
1. Build release APK: `flutter build apk --release`
2. Install on Android device or upload to Play Store

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

For support and questions:
- Create an issue on GitHub
- Contact the development team

## 🎯 Future Enhancements

- **Budgeting**: Set and track spending budgets
- **Bill Reminders**: Recurring transaction notifications
- **Export Features**: PDF reports and CSV exports
- **Multi-currency**: Support for different currencies
- **Investment Tracking**: Portfolio management features
- **Shared Accounts**: Family/group account management

---

**MyFinance** - Take control of your financial future! 💰📱